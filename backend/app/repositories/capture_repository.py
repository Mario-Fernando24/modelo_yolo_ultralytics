from __future__ import annotations

import uuid

from sqlalchemy.orm import Session

from ..models.capture import Capture


class CaptureRepository:
    """Acceso a PostgreSQL. Las rutas no hablan con SQLAlchemy directo."""

    def __init__(self, db: Session) -> None:
        self.db = db

    def add(self, capture: Capture) -> Capture:
        self.db.add(capture)
        self.db.commit()
        self.db.refresh(capture)
        return capture

    def list_recent(self, limit: int = 100) -> list[Capture]:
        return (
            self.db.query(Capture)
            .order_by(Capture.created_at.desc())
            .limit(limit)
            .all()
        )

    def get(self, capture_id: uuid.UUID) -> Capture | None:
        return self.db.get(Capture, capture_id)
