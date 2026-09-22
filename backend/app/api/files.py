from fastapi import HTTPException, UploadFile


async def read_image(file: UploadFile) -> bytes:
    data = await file.read()
    if not data:
        raise HTTPException(status_code=400, detail="La imagen está vacía")
    return data
