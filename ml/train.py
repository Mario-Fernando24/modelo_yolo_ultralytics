#!/usr/bin/env python3
"""Fine-tuning de YOLOv8n sobre las 7 clases de VisionAI."""

from __future__ import annotations

import argparse
import shutil
from pathlib import Path

from visionai.coco_subset import build_coco_subset
from visionai.constants import PRETRAINED_WEIGHTS
from visionai.model import select_device

ML_ROOT = Path(__file__).resolve().parent
DEFAULT_DATA = ML_ROOT / "data" / "visionai" / "dataset.yaml"
WEIGHTS_DIR = ML_ROOT / "weights"
RUNS_DIR = ML_ROOT / "runs"


def main() -> None:
    parser = argparse.ArgumentParser(description="Entrenar YOLO VisionAI")
    parser.add_argument("--data", type=Path, default=DEFAULT_DATA)
    parser.add_argument("--weights", default=PRETRAINED_WEIGHTS)
    parser.add_argument("--epochs", type=int, default=20)
    parser.add_argument("--imgsz", type=int, default=640)
    parser.add_argument("--batch", type=int, default=8)
    parser.add_argument("--images-per-class", type=int, default=25)
    parser.add_argument("--device", default=None)
    args = parser.parse_args()

    if not args.data.exists():
        print("No hay dataset local. Preparando subconjunto COCO…")
        args.data = build_coco_subset(
            dest=ML_ROOT / "data" / "visionai",
            images_per_class=args.images_per_class,
        )

    device = args.device or select_device()
    print(f"Dispositivo: {device}")
    print(f"Dataset: {args.data}")

    from ultralytics import YOLO

    model = YOLO(args.weights)
    model.train(
        data=str(args.data),
        epochs=args.epochs,
        imgsz=args.imgsz,
        batch=args.batch,
        device=device,
        project=str(RUNS_DIR),
        name="visionai",
        exist_ok=True,
        patience=8,
        workers=2,
        pretrained=True,
        plots=True,
    )

    best = RUNS_DIR / "visionai" / "weights" / "best.pt"
    WEIGHTS_DIR.mkdir(parents=True, exist_ok=True)
    exported = WEIGHTS_DIR / "visionai_yolo8n.pt"
    shutil.copy2(best, exported)
    print(f"Modelo guardado en {exported}")


if __name__ == "__main__":
    main()
