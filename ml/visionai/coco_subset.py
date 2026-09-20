"""Descarga un subconjunto COCO y lo convierte al formato YOLO de 7 clases."""

from __future__ import annotations

import json
import random
import urllib.request
import zipfile
from collections import defaultdict
from pathlib import Path

from .constants import COCO_CATEGORY_ID, VISIONAI_CLASS_NAMES

ANNOTATIONS_URL = (
    "http://images.cocodataset.org/annotations/annotations_trainval2017.zip"
)
VAL_IMAGE_URL = "http://images.cocodataset.org/val2017/{file_name}"
ANNOTATIONS_JSON = "annotations/instances_val2017.json"


def build_coco_subset(
    dest: Path,
    images_per_class: int = 25,
    val_ratio: float = 0.2,
    seed: int = 42,
) -> Path:
    dest = dest.resolve()
    raw_dir = dest / "raw"
    raw_dir.mkdir(parents=True, exist_ok=True)

    annotations = _load_annotations(raw_dir)
    selected = _sample_images(annotations, images_per_class=images_per_class, seed=seed)
    _download_images(selected, raw_dir / "images")
    data_yaml = _write_yolo_dataset(dest, selected, annotations, val_ratio=val_ratio, seed=seed)
    return data_yaml


def _load_annotations(raw_dir: Path) -> dict:
    json_path = raw_dir / "instances_val2017.json"
    if not json_path.exists():
        zip_path = raw_dir / "annotations_trainval2017.zip"
        if not zip_path.exists():
            print("Descargando anotaciones COCO 2017…")
            _download(ANNOTATIONS_URL, zip_path)
        print("Extrayendo instances_val2017.json…")
        with zipfile.ZipFile(zip_path) as archive:
            with archive.open(ANNOTATIONS_JSON) as src, json_path.open("wb") as dst:
                dst.write(src.read())
    with json_path.open() as handle:
        return json.load(handle)


def _sample_images(annotations: dict, images_per_class: int, seed: int) -> list[dict]:
    category_to_name = {COCO_CATEGORY_ID[name]: name for name in VISIONAI_CLASS_NAMES}
    allowed_ids = set(category_to_name)

    image_by_id = {image["id"]: image for image in annotations["images"]}
    images_by_class: dict[str, set[int]] = defaultdict(set)
    for ann in annotations["annotations"]:
        cat_id = ann["category_id"]
        if cat_id not in allowed_ids:
            continue
        if ann.get("iscrowd"):
            continue
        images_by_class[category_to_name[cat_id]].add(ann["image_id"])

    rng = random.Random(seed)
    selected_ids: set[int] = set()
    for name in VISIONAI_CLASS_NAMES:
        pool = sorted(images_by_class[name])
        rng.shuffle(pool)
        selected_ids.update(pool[:images_per_class])

    selected = [image_by_id[image_id] for image_id in sorted(selected_ids)]
    print(f"Imágenes seleccionadas: {len(selected)}")
    return selected


def _download_images(images: list[dict], image_dir: Path) -> None:
    image_dir.mkdir(parents=True, exist_ok=True)
    for index, image in enumerate(images, start=1):
        target = image_dir / image["file_name"]
        if target.exists():
            continue
        url = VAL_IMAGE_URL.format(file_name=image["file_name"])
        print(f"[{index}/{len(images)}] {image['file_name']}")
        _download(url, target)


def _write_yolo_dataset(
    dest: Path,
    images: list[dict],
    annotations: dict,
    val_ratio: float,
    seed: int,
) -> Path:
    category_to_index = {
        COCO_CATEGORY_ID[name]: index for index, name in enumerate(VISIONAI_CLASS_NAMES)
    }
    anns_by_image: dict[int, list[dict]] = defaultdict(list)
    for ann in annotations["annotations"]:
        if ann["category_id"] not in category_to_index:
            continue
        if ann.get("iscrowd"):
            continue
        anns_by_image[ann["image_id"]].append(ann)

    rng = random.Random(seed)
    shuffled = list(images)
    rng.shuffle(shuffled)
    val_count = max(1, int(len(shuffled) * val_ratio))
    splits = {
        "val": shuffled[:val_count],
        "train": shuffled[val_count:],
    }

    raw_images = dest / "raw" / "images"
    for split, split_images in splits.items():
        image_dir = dest / "images" / split
        label_dir = dest / "labels" / split
        image_dir.mkdir(parents=True, exist_ok=True)
        label_dir.mkdir(parents=True, exist_ok=True)
        for image in split_images:
            src = raw_images / image["file_name"]
            dst = image_dir / image["file_name"]
            if not dst.exists():
                _link_or_copy(src, dst)
            label_path = label_dir / f"{Path(image['file_name']).stem}.txt"
            label_path.write_text(
                _yolo_labels(image, anns_by_image[image["id"]], category_to_index)
            )

    yaml_path = dest / "dataset.yaml"
    names_block = "\n".join(
        f"  {index}: {name}" for index, name in enumerate(VISIONAI_CLASS_NAMES)
    )
    yaml_path.write_text(
        (
            f"path: {dest}\n"
            "train: images/train\n"
            "val: images/val\n"
            "names:\n"
            f"{names_block}\n"
        )
    )
    print(f"Dataset YOLO escrito en {yaml_path}")
    print(f"  train: {len(splits['train'])}  val: {len(splits['val'])}")
    return yaml_path


def _yolo_labels(
    image: dict,
    anns: list[dict],
    category_to_index: dict[int, int],
) -> str:
    width = float(image["width"])
    height = float(image["height"])
    lines: list[str] = []
    for ann in anns:
        x, y, w, h = ann["bbox"]
        if w <= 0 or h <= 0:
            continue
        x_center = (x + w / 2.0) / width
        y_center = (y + h / 2.0) / height
        nw = w / width
        nh = h / height
        x_center = min(max(x_center, 0.0), 1.0)
        y_center = min(max(y_center, 0.0), 1.0)
        nw = min(max(nw, 0.0), 1.0)
        nh = min(max(nh, 0.0), 1.0)
        class_id = category_to_index[ann["category_id"]]
        lines.append(f"{class_id} {x_center:.6f} {y_center:.6f} {nw:.6f} {nh:.6f}")
    return "\n".join(lines) + ("\n" if lines else "")


def _link_or_copy(src: Path, dst: Path) -> None:
    try:
        dst.symlink_to(src)
    except OSError:
        dst.write_bytes(src.read_bytes())


def _download(url: str, dest: Path) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    tmp = dest.with_suffix(dest.suffix + ".part")
    request = urllib.request.Request(url, headers={"User-Agent": "VisionAI/1.0"})
    with urllib.request.urlopen(request, timeout=120) as response, tmp.open("wb") as handle:
        while True:
            chunk = response.read(1024 * 256)
            if not chunk:
                break
            handle.write(chunk)
    tmp.replace(dest)
