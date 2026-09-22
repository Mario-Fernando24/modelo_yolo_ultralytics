from __future__ import annotations

from pathlib import Path

from ..core.config import UPLOAD_DIR


class StorageService:
    """Guarda JPEGs en disco. La BD solo guarda el nombre del archivo."""

    def __init__(self, upload_dir: Path | None = None) -> None:
        self.upload_dir = upload_dir or UPLOAD_DIR
        self.upload_dir.mkdir(parents=True, exist_ok=True)

    def save_jpeg(self, filename: str, data: bytes) -> Path:
        path = self.upload_dir / filename
        path.write_bytes(data)
        return path

    def resolve(self, filename: str) -> Path:
        return self.upload_dir / filename
