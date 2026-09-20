"""Taxonomía VisionAI alineada con COCO / YOLO."""

from __future__ import annotations

VISIONAI_CLASS_NAMES: tuple[str, ...] = (
    "person",
    "car",
    "bus",
    "motorcycle",
    "dog",
    "cat",
    "bird",
)

CLASS_LABELS_ES: dict[str, str] = {
    "person": "Persona",
    "car": "Automóvil",
    "bus": "Bus",
    "motorcycle": "Motocicleta",
    "dog": "Perro",
    "cat": "Gato",
    "bird": "Ave",
}

# Índices 0-79 que usa YOLO preentrenado en COCO (no los category_id originales).
COCO80_INDEX: dict[str, int] = {
    "person": 0,
    "car": 2,
    "motorcycle": 3,
    "bus": 5,
    "bird": 14,
    "cat": 15,
    "dog": 16,
}

# category_id del JSON oficial de COCO (con huecos).
COCO_CATEGORY_ID: dict[str, int] = {
    "person": 1,
    "car": 3,
    "motorcycle": 4,
    "bus": 6,
    "bird": 16,
    "cat": 17,
    "dog": 18,
}

PRETRAINED_WEIGHTS = "yolov8n.pt"
DEFAULT_CONFIDENCE = 0.35
