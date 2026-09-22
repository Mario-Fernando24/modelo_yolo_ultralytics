from __future__ import annotations

import logging
import threading
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from .api.deps import get_or_load_detector
from .api.routes import captures, detect, health
from .core.config import UPLOAD_DIR
from .core.database import Base, engine
from .models import Capture  # noqa: F401  — registra la tabla en metadata

logger = logging.getLogger("visionai")


def _prepare(app: FastAPI) -> None:
    """Carga tablas y YOLO después de que el puerto ya esté abierto."""
    try:
        Base.metadata.create_all(bind=engine)
    except Exception:
        logger.exception("No se pudieron crear las tablas. Revisa DATABASE_URL y la conexión a Cloud SQL.")
    try:
        get_or_load_detector(app)
    except Exception:
        logger.exception("No se pudo cargar YOLO.")


@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.detector = None
    threading.Thread(target=_prepare, args=(app,), daemon=True).start()
    yield


def create_app() -> FastAPI:
    application = FastAPI(
        title="VisionAI",
        description="Detección de objetos para la app Flutter (cámara en vivo e historial).",
        lifespan=lifespan,
    )
    application.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    application.include_router(health.router)
    application.include_router(detect.router)
    application.include_router(captures.router)
    application.mount("/media", StaticFiles(directory=str(UPLOAD_DIR)), name="media")
    return application


app = create_app()
