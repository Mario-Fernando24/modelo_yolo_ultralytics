from __future__ import annotations

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field


class DetectedObject(BaseModel):
    class_name: str
    label_es: str
    confidence: float
    confidence_pct: float
    x1: float
    y1: float
    x2: float
    y2: float
    x1n: float
    y1n: float
    x2n: float
    y2n: float


class DetectionResponse(BaseModel):
    has_car: bool
    car_count: int
    car_confidence: float | None = None
    message: str
    objects: list[DetectedObject]
    width: int
    height: int
    latency_ms: int
    model: str


class CaptureResponse(DetectionResponse):
    id: UUID
    created_at: datetime
    image_url: str
    annotated_url: str | None = None
    source: str = "photo"


class CaptureListItem(BaseModel):
    id: UUID
    created_at: datetime
    has_car: bool
    summary: str
    object_count: int = Field(default=0)
    image_url: str
    annotated_url: str | None = None
