"""Modelo VisionAI: YOLO (PyTorch / Ultralytics) para detección de 7 clases."""

from __future__ import annotations

from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any

from .constants import (
    CLASS_LABELS_ES,
    COCO80_INDEX,
    DEFAULT_CONFIDENCE,
    PRETRAINED_WEIGHTS,
    VISIONAI_CLASS_NAMES,
)


@dataclass(frozen=True, slots=True)
class Detection:
    class_name: str
    label_es: str
    confidence: float
    x1: float
    y1: float
    x2: float
    y2: float
    x1n: float
    y1n: float
    x2n: float
    y2n: float

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


@dataclass(frozen=True, slots=True)
class PredictResult:
    detections: list[Detection]
    width: int
    height: int


def decode_source(image: str | Path | bytes | bytearray | Any) -> Any:
    if isinstance(image, (bytes, bytearray, memoryview)):
        import cv2
        import numpy as np

        buffer = np.frombuffer(bytes(image), dtype=np.uint8)
        bgr = cv2.imdecode(buffer, cv2.IMREAD_COLOR)
        if bgr is None:
            raise ValueError("No se pudo decodificar la imagen")
        return cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB)
    if isinstance(image, Path):
        return str(image)
    return image


def _orig_size(result: Any, source: Any) -> tuple[int, int]:
    shape = getattr(result, "orig_shape", None)
    if shape is not None and len(shape) >= 2:
        return int(shape[0]), int(shape[1])
    if hasattr(source, "shape"):
        return int(source.shape[0]), int(source.shape[1])
    return 0, 0


def select_device() -> str:
    import torch

    if torch.cuda.is_available():
        return "0"
    mps = getattr(torch.backends, "mps", None)
    if mps is not None and mps.is_available():
        return "mps"
    return "cpu"


class VisionAIYOLO:
    """
    Detector YOLO restringido a las clases de VisionAI.

    Acepta un checkpoint de 80 clases COCO (filtra en inferencia) o un
    modelo fine-tuned de 7 clases.
    """

    def __init__(
        self,
        weights: str | Path = PRETRAINED_WEIGHTS,
        confidence: float = DEFAULT_CONFIDENCE,
        device: str | None = None,
    ) -> None:
        from ultralytics import YOLO

        self.weights = Path(weights)
        self.confidence = confidence
        self.device = device or select_device()
        self.model = YOLO(str(weights))
        self.class_filter = self._class_filter()

    def _class_filter(self) -> list[int] | None:
        names = _model_names(self.model)
        name_set = set(names.values())
        if name_set == set(VISIONAI_CLASS_NAMES) and len(names) == len(VISIONAI_CLASS_NAMES):
            return None
        return [COCO80_INDEX[name] for name in VISIONAI_CLASS_NAMES]

    def predict(
        self,
        image: str | Path | bytes | bytearray | Any,
        confidence: float | None = None,
    ) -> list[Detection]:
        return self.predict_detailed(image, confidence=confidence).detections

    def predict_detailed(
        self,
        image: str | Path | bytes | bytearray | Any,
        confidence: float | None = None,
    ) -> PredictResult:
        conf = self.confidence if confidence is None else confidence
        source = decode_source(image)
        kwargs: dict[str, Any] = {
            "source": source,
            "conf": conf,
            "device": self.device,
            "verbose": False,
        }
        if self.class_filter is not None:
            kwargs["classes"] = self.class_filter

        results = self.model.predict(**kwargs)
        if not results:
            return PredictResult(detections=[], width=0, height=0)
        result = results[0]
        height, width = _orig_size(result, source)
        return PredictResult(
            detections=_detections_from_result(result),
            width=width,
            height=height,
        )

    def annotate(
        self,
        image: str | Path | bytes | bytearray | Any,
        output: str | Path,
        confidence: float | None = None,
    ) -> Path:
        conf = self.confidence if confidence is None else confidence
        kwargs: dict[str, Any] = {
            "source": decode_source(image),
            "conf": conf,
            "device": self.device,
            "verbose": False,
        }
        if self.class_filter is not None:
            kwargs["classes"] = self.class_filter

        result = self.model.predict(**kwargs)[0]
        plotted = result.plot()
        output_path = Path(output)
        output_path.parent.mkdir(parents=True, exist_ok=True)

        import cv2

        cv2.imwrite(str(output_path), plotted)
        return output_path


def _model_names(model: Any) -> dict[int, str]:
    names = model.names
    if isinstance(names, dict):
        return {int(k): str(v) for k, v in names.items()}
    return {i: str(name) for i, name in enumerate(names)}


def _detections_from_result(result: Any) -> list[Detection]:
    boxes = result.boxes
    if boxes is None or len(boxes) == 0:
        return []

    names = _model_names(result)
    xyxy = boxes.xyxy.cpu().numpy()
    xyxyn = boxes.xyxyn.cpu().numpy()
    confs = boxes.conf.cpu().numpy()
    classes = boxes.cls.cpu().numpy().astype(int)

    detections: list[Detection] = []
    allowed = set(VISIONAI_CLASS_NAMES)
    for i in range(len(boxes)):
        class_name = names.get(int(classes[i]), str(classes[i]))
        if class_name not in allowed:
            continue
        x1, y1, x2, y2 = (float(v) for v in xyxy[i])
        x1n, y1n, x2n, y2n = (float(v) for v in xyxyn[i])
        detections.append(
            Detection(
                class_name=class_name,
                label_es=CLASS_LABELS_ES[class_name],
                confidence=float(confs[i]),
                x1=x1,
                y1=y1,
                x2=x2,
                y2=y2,
                x1n=x1n,
                y1n=y1n,
                x2n=x2n,
                y2n=y2n,
            )
        )
    detections.sort(key=lambda item: item.confidence, reverse=True)
    return detections
