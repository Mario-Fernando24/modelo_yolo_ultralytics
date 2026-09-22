from fastapi import APIRouter, Depends, File, HTTPException, UploadFile

from ..deps import get_detection_service
from ..files import read_image
from ...schemas.detection import DetectionResponse
from ...services.detection_service import DetectionService

router = APIRouter(tags=["detección"])


@router.post("/detect", response_model=DetectionResponse)
async def detect_live(
    file: UploadFile = File(..., description="Fotograma de la cámara"),
    service: DetectionService = Depends(get_detection_service),
):
    """Cámara en vivo: analiza y NO guarda en PostgreSQL."""
    data = await read_image(file)
    try:
        print(f"Received frame of size: {len(data.capitalize())} bytes")
        return service.analyze_frame(data)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
