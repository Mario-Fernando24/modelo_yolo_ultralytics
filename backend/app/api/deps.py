from __future__ import annotations

from fastapi import Depends, HTTPException, Request
from sqlalchemy.orm import Session

from ..core.database import get_db
from ..repositories.capture_repository import CaptureRepository
from ..services.capture_service import CaptureService
from ..services.detection_service import DetectionService
from ..services.detector_service import DetectorService


def get_detector(request: Request) -> DetectorService:
    detector = getattr(request.app.state, "detector", None)
    if detector is None:
        raise HTTPException(status_code=503, detail="El modelo todavía no está listo")
    return detector


def get_detection_service(
    detector: DetectorService = Depends(get_detector),
) -> DetectionService:
    return DetectionService(detector)


def get_capture_service(
    detector: DetectorService = Depends(get_detector),
    db: Session = Depends(get_db),
) -> CaptureService:
    return CaptureService(detector=detector, repository=CaptureRepository(db))
