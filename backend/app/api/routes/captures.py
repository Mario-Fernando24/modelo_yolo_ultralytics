import uuid

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from fastapi.responses import FileResponse

from ..deps import get_capture_service
from ..files import read_image
from ...schemas.detection import CaptureListItem, CaptureResponse
from ...services.capture_service import CaptureService

router = APIRouter(tags=["capturas"])


@router.post("/captures", response_model=CaptureResponse)
async def create_capture(
    file: UploadFile = File(..., description="Fotografía a analizar y guardar"),
    service: CaptureService = Depends(get_capture_service),
):
    """Analiza, guarda el JPG y escribe captures + capture_objects."""
    data = await read_image(file)
    try:
        return service.create(data)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.get("/captures", response_model=list[CaptureListItem])
def list_captures(service: CaptureService = Depends(get_capture_service)):
    return service.list_recent()


@router.get("/captures/{capture_id}", response_model=CaptureResponse)
def get_capture(
    capture_id: uuid.UUID,
    service: CaptureService = Depends(get_capture_service),
):
    return service.get(capture_id)


@router.get("/captures/{capture_id}/image")
def get_capture_image(
    capture_id: uuid.UUID,
    service: CaptureService = Depends(get_capture_service),
):
    path = service.original_path(capture_id)
    return FileResponse(path, media_type="image/jpeg")
