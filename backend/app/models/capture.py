from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import Boolean, DateTime, Float, ForeignKey, Integer, String, Text, Uuid, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from ..core.database import Base


class Capture(Base):
    """Cabecera de una foto analizada y persistida."""

    __tablename__ = "captures"

    id: Mapped[uuid.UUID] = mapped_column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    source: Mapped[str] = mapped_column(String(32), default="photo")
    image_path: Mapped[str] = mapped_column(String(512))
    annotated_path: Mapped[str | None] = mapped_column(String(512), nullable=True)
    width: Mapped[int] = mapped_column(Integer, default=0)
    height: Mapped[int] = mapped_column(Integer, default=0)
    model: Mapped[str] = mapped_column(String(128), default="")
    latency_ms: Mapped[int] = mapped_column(Integer, default=0)
    has_car: Mapped[bool] = mapped_column(Boolean, default=False)
    summary: Mapped[str] = mapped_column(Text, default="")

    objects: Mapped[list[CaptureObject]] = relationship(
        back_populates="capture",
        cascade="all, delete-orphan",
        order_by="CaptureObject.confidence.desc()",
    )


class CaptureObject(Base):
    """Cada objeto detectado dentro de una captura."""

    __tablename__ = "capture_objects"

    id: Mapped[uuid.UUID] = mapped_column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    capture_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("captures.id", ondelete="CASCADE"),
        index=True,
    )
    class_name: Mapped[str] = mapped_column(String(64))
    label_es: Mapped[str] = mapped_column(String(64))
    confidence: Mapped[float] = mapped_column(Float)
    x1: Mapped[float] = mapped_column(Float)
    y1: Mapped[float] = mapped_column(Float)
    x2: Mapped[float] = mapped_column(Float)
    y2: Mapped[float] = mapped_column(Float)
    x1n: Mapped[float] = mapped_column(Float)
    y1n: Mapped[float] = mapped_column(Float)
    x2n: Mapped[float] = mapped_column(Float)
    y2n: Mapped[float] = mapped_column(Float)

    capture: Mapped[Capture] = relationship(back_populates="objects")
