from __future__ import annotations

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from .api.routes import captures, detect, health
from .core.config import UPLOAD_DIR
from .core.database import Base, engine
from .models import Capture  # noqa: F401  — registra la tabla en metadata
from .services.detector_service import DetectorService


@asynccontextmanager
async def lifespan(app: FastAPI):
    Base.metadata.create_all(bind=engine)
    app.state.detector = DetectorService()
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
