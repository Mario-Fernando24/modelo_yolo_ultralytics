from __future__ import annotations

import uuid
from pathlib import Path

from fastapi import HTTPException

from ..models.capture import Capture, CaptureObject
from ..repositories.capture_repository import CaptureRepository
from ..schemas.detection import CaptureListItem, CaptureResponse
from .detection_mapper import to_detected_object, to_detection_response
from .detector_service import DetectorService
from .storage_service import StorageService


class CaptureService:
    """Foto persistida: YOLO + disco + PostgreSQL."""

    def __init__(
        self,
        detector: DetectorService,
        repository: CaptureRepository,
        storage: StorageService | None = None,
    ) -> None:
        self.detector = detector
        self.repository = repository
        self.storage = storage or StorageService()

    def create(self, image_bytes: bytes) -> CaptureResponse:
        result, latency_ms = self.detector.analyze_bytes(image_bytes)
        payload = to_detection_response(result, latency_ms, self.detector.model_name)

        capture_id = uuid.uuid4()
        image_name = f"{capture_id}.jpg"
        annotated_name = f"{capture_id}_annot.jpg"
        self.storage.save_jpeg(image_name, image_bytes)
        self.detector.annotate_bytes(image_bytes, self.storage.resolve(annotated_name))

        capture = Capture(
            id=capture_id,
            source="photo",
            image_path=image_name,
            annotated_path=annotated_name,
            width=result.width,
            height=result.height,
            model=self.detector.model_name,
            latency_ms=latency_ms,
            has_car=payload.has_car,
            summary=payload.message,
            objects=[
                CaptureObject(
                    class_name=item.class_name,
                    label_es=item.label_es,
                    confidence=item.confidence,
                    x1=item.x1,
                    y1=item.y1,
                    x2=item.x2,
                    y2=item.y2,
                    x1n=item.x1n,
                    y1n=item.y1n,
                    x2n=item.x2n,
                    y2n=item.y2n,
                )
                for item in result.detections
            ],
        )
        saved = self.repository.add(capture)
        return self._to_response(saved, payload)

    def list_recent(self) -> list[CaptureListItem]:
        return [
            CaptureListItem(
                id=row.id,
                created_at=row.created_at,
                has_car=row.has_car,
                summary=row.summary,
                object_count=len(row.objects),
                image_url=f"/media/{row.image_path}",
                annotated_url=f"/media/{row.annotated_path}" if row.annotated_path else None,
            )
            for row in self.repository.list_recent()
        ]

    def get(self, capture_id: uuid.UUID) -> CaptureResponse:
        capture = self._require(capture_id)
        cars = [item for item in capture.objects if item.class_name == "car"]
        payload = CaptureResponse(
            id=capture.id,
            created_at=capture.created_at,
            image_url=f"/media/{capture.image_path}",
            annotated_url=f"/media/{capture.annotated_path}" if capture.annotated_path else None,
            source=capture.source,
            has_car=capture.has_car,
            car_count=len(cars),
            car_confidence=max((item.confidence for item in cars), default=None),
            message=capture.summary,
            objects=[to_detected_object(item) for item in capture.objects],
            width=capture.width,
            height=capture.height,
            latency_ms=capture.latency_ms,
            model=capture.model,
        )
        return payload

    def original_path(self, capture_id: uuid.UUID) -> Path:
        capture = self._require(capture_id)
        path = self.storage.resolve(capture.image_path)
        if not path.exists():
            raise HTTPException(status_code=404, detail="La fotografía no está en disco")
        return path

    def _require(self, capture_id: uuid.UUID) -> Capture:
        capture = self.repository.get(capture_id)
        if capture is None:
            raise HTTPException(status_code=404, detail="Captura no encontrada")
        return capture

    def _to_response(self, capture: Capture, payload) -> CaptureResponse:
        return CaptureResponse(
            id=capture.id,
            created_at=capture.created_at,
            image_url=f"/media/{capture.image_path}",
            annotated_url=f"/media/{capture.annotated_path}" if capture.annotated_path else None,
            source=capture.source,
            has_car=payload.has_car,
            car_count=payload.car_count,
            car_confidence=payload.car_confidence,
            message=payload.message,
            objects=payload.objects,
            width=payload.width,
            height=payload.height,
            latency_ms=payload.latency_ms,
            model=payload.model,
        )
