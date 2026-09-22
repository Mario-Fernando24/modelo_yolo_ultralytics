from __future__ import annotations

import threading

from fastapi import Depends, HTTPException, Request
from sqlalchemy.orm import Session

from ..core.database import get_db
from ..repositories.capture_repository import CaptureRepository
from ..services.capture_service import CaptureService
from ..services.detection_service import DetectionService
from ..services.detector_service import DetectorService

_load_lock = threading.Lock()


def get_or_load_detector(app) -> DetectorService:
    detector = getattr(app.state, "detector", None)
    if detector is not None:
        return detector
    with _load_lock:
        detector = getattr(app.state, "detector", None)
        if detector is None:
            app.state.detector = DetectorService()
        return app.state.detector


def get_detector(request: Request) -> DetectorService:
    try:
        return get_or_load_detector(request.app)
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"El modelo no pudo cargarse: {exc}") from exc


def get_detection_service(
    detector: DetectorService = Depends(get_detector),
) -> DetectionService:
    return DetectionService(detector)


def get_capture_service(
    detector: DetectorService = Depends(get_detector),
    db: Session = Depends(get_db),
) -> CaptureService:
    return CaptureService(detector=detector, repository=CaptureRepository(db))
