from __future__ import annotations

import sys
import time
from pathlib import Path

from ..core.config import CONFIDENCE, PROJECT_ROOT, WEIGHTS_PATH

sys.path.insert(0, str(PROJECT_ROOT / "ml"))

from visionai.model import PredictResult, VisionAIYOLO


class DetectorService:
    """Envuelve YOLO: una instancia en memoria para toda la API."""

    def __init__(self) -> None:
        # Inicializa el detector con los pesos y la confianza especificados.
        self.weights = Path(WEIGHTS_PATH)
        self.model = VisionAIYOLO(weights=self.weights, confidence=CONFIDENCE)

    @property
    def model_name(self) -> str:
        return self.weights.name

    # Analiza bytes de imagen y devuelve el resultado de predicción junto con la latencia en milisegundos.
    def analyze_bytes(self, data: bytes) -> tuple[PredictResult, int]:
        started = time.perf_counter()
        result = self.model.predict_detailed(data)
        latency_ms = int((time.perf_counter() - started) * 1000)
        print(f"DetectorService.analyze_bytes: latency {latency_ms} ms")
        print(f"DetectorService.analyze_bytes: result {result}")
        return result, latency_ms

    # Anota bytes de imagen y guarda la imagen anotada en la ruta de salida especificada.
    def annotate_bytes(self, data: bytes, output: Path) -> Path:
        return self.model.annotate(data, output)
