from __future__ import annotations

import os
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[3]
BACKEND_ROOT = PROJECT_ROOT / "backend"
DATA_DIR = BACKEND_ROOT / "data"
UPLOAD_DIR = DATA_DIR / "uploads"

DATA_DIR.mkdir(parents=True, exist_ok=True)
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql+psycopg://visionai:visionai@127.0.0.1:5433/visionai",
)

TRAINED_WEIGHTS = PROJECT_ROOT / "ml" / "weights" / "visionai_yolo8n.pt"
PRETRAINED_WEIGHTS = PROJECT_ROOT / "ml" / "yolov8n.pt"
WEIGHTS_PATH = TRAINED_WEIGHTS if TRAINED_WEIGHTS.exists() else PRETRAINED_WEIGHTS

CONFIDENCE = float(os.getenv("VISIONAI_CONFIDENCE", "0.35"))
HOST = os.getenv("VISIONAI_HOST", "0.0.0.0")
PORT = int(os.getenv("VISIONAI_PORT", "8001"))
