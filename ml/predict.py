#!/usr/bin/env python3
"""Inferencia del detector VisionAI sobre una imagen."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from visionai.constants import DEFAULT_CONFIDENCE, PRETRAINED_WEIGHTS
from visionai.model import VisionAIYOLO

ML_ROOT = Path(__file__).resolve().parent
TRAINED_WEIGHTS = ML_ROOT / "weights" / "visionai_yolo8n.pt"
DEFAULT_OUTPUT = ML_ROOT / "outputs" / "prediccion.jpg"


def resolve_weights(explicit: Path | None) -> Path | str:
    if explicit is not None:
        return explicit
    if TRAINED_WEIGHTS.exists():
        return TRAINED_WEIGHTS
    return PRETRAINED_WEIGHTS


def main() -> None:
    parser = argparse.ArgumentParser(description="Detectar objetos VisionAI")
    parser.add_argument("image", type=Path, help="Ruta de la imagen")
    parser.add_argument("--weights", type=Path, default=None)
    parser.add_argument("--conf", type=float, default=DEFAULT_CONFIDENCE)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    args = parser.parse_args()

    if not args.image.exists():
        raise SystemExit(f"No existe la imagen: {args.image}")

    weights = resolve_weights(args.weights)
    print(f"Pesos: {weights}")
    detector = VisionAIYOLO(weights=weights, confidence=args.conf)
    detections = detector.predict(args.image)
    detector.annotate(args.image, args.output, confidence=args.conf)

    payload = [item.to_dict() for item in detections]
    print(json.dumps(payload, indent=2, ensure_ascii=False))
    print(f"Imagen anotada: {args.output}")
    print(f"Objetos: {len(detections)}")


if __name__ == "__main__":
    main()
