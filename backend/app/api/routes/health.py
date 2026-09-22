from fastapi import APIRouter, Request

router = APIRouter(tags=["salud"])


@router.get("/")
def root():
    return {
        "name": "VisionAI",
        "docs": "/docs",
        "health": "/health",
        "detect": "POST /detect",
        "captures": "POST /captures",
    }


@router.get("/health")
def health(request: Request):
    detector = getattr(request.app.state, "detector", None)
    if detector is None:
        return {"status": "starting", "model": None}
    return {"status": "ok", "model": detector.model_name}
