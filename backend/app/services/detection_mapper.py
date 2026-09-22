from __future__ import annotations

from ..schemas.detection import DetectedObject, DetectionResponse


# Convierte un objeto de predicción de VisionAI a un objeto de respuesta de detección.
def to_detected_object(item) -> DetectedObject:
    return DetectedObject(
        class_name=item.class_name,
        label_es=item.label_es,
        confidence=round(item.confidence, 4),
        confidence_pct=round(item.confidence * 100, 1),
        x1=item.x1,
        y1=item.y1,
        x2=item.x2,
        y2=item.y2,
        x1n=item.x1n,
        y1n=item.y1n,
        x2n=item.x2n,
        y2n=item.y2n,
    )


# Arma un resumen de los objetos detectados, incluyendo si hay un automóvil, la cantidad y la confianza máxima.
def build_summary(detections) -> tuple[bool, int, float | None, str]:
    """Arma el texto que ve Flutter: si hay auto y el % de cada objeto."""
    cars = [item for item in detections if item.class_name == "car"]
    has_car = bool(cars)
    car_count = len(cars)
    car_confidence = max((item.confidence for item in cars), default=None)

    if not detections:
        return False, 0, None, "No se detectaron objetos de VisionAI."

    if has_car:
        pct = round(car_confidence * 100)
        if car_count == 1:
            message = f"Sí, es un automóvil ({pct}%)."
        else:
            message = f"Sí, hay {car_count} automóviles. Confianza máxima: {pct}%."
        others = [item for item in detections if item.class_name != "car"]
        if others:
            extra = ", ".join(
                f"{item.label_es} {round(item.confidence * 100)}%" for item in others[:4]
            )
            message += f" También: {extra}."
        return has_car, car_count, car_confidence, message

    listed = ", ".join(
        f"{item.label_es} {round(item.confidence * 100)}%" for item in detections[:5]
    )
    return False, 0, None, f"No se detectó un automóvil. Objetos: {listed}."


# Convierte el resultado de predicción de VisionAI a un objeto de respuesta de detección.
def to_detection_response(result, latency_ms: int, model_name: str) -> DetectionResponse:
    has_car, car_count, car_confidence, message = build_summary(result.detections)
    return DetectionResponse(
        has_car=has_car,
        car_count=car_count,
        car_confidence=None if car_confidence is None else round(car_confidence, 4),
        message=message,
        objects=[to_detected_object(item) for item in result.detections],
        width=result.width,
        height=result.height,
        latency_ms=latency_ms,
        model=model_name,
    )
