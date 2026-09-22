from __future__ import annotations

from .detector_service import DetectorService
from .detection_mapper import to_detection_response
from ..schemas.detection import DetectionResponse


class DetectionService:
    """Lógica de la cámara en vivo: analizar y responder, sin tocar la BD."""

    def __init__(self, detector: DetectorService) -> None:
        self.detector = detector

    def analyze_frame(self, image_bytes: bytes) -> DetectionResponse:
        result, latency_ms = self.detector.analyze_bytes(image_bytes)
        print(f"DetectionService.analyze_frame: result {result}")
        return to_detection_response(result, latency_ms, self.detector.model_name)
