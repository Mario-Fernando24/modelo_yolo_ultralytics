from fastapi import APIRouter, Depends

from ..deps import get_detector
from ...services.detector_service import DetectorService

router = APIRouter(tags=["salud"])


@router.get("/")
def root():
    return {
        "name": "VisionAI",
        "docs": "/docs",
        "health": "/health",
        "detect": "POST /detect",
        "captures": "POST /captures",
    }


@router.get("/health")
def health(detector: DetectorService = Depends(get_detector)):
    return {"status": "ok", "model": detector.model_name}
