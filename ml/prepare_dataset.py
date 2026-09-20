#!/usr/bin/env python3
"""Prepara un subconjunto COCO de 7 clases en formato YOLO."""

from __future__ import annotations

import argparse
from pathlib import Path

from visionai.coco_subset import build_coco_subset

ML_ROOT = Path(__file__).resolve().parent


def main() -> None:
    parser = argparse.ArgumentParser(description="Dataset VisionAI (COCO → YOLO, 7 clases)")
    parser.add_argument("--dest", type=Path, default=ML_ROOT / "data" / "visionai")
    parser.add_argument("--images-per-class", type=int, default=25)
    parser.add_argument("--val-ratio", type=float, default=0.2)
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()
    yaml_path = build_coco_subset(
        dest=args.dest,
        images_per_class=args.images_per_class,
        val_ratio=args.val_ratio,
        seed=args.seed,
    )
    print(f"Listo: {yaml_path}")


if __name__ == "__main__":
    main()
