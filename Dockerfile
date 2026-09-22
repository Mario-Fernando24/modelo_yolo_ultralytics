FROM python:3.12-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONPATH=/app \
    PORT=8080

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends libgl1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

COPY backend/requirements.txt /tmp/backend-requirements.txt
COPY ml/requirements.txt /tmp/ml-requirements.txt

# Torch CPU: la imagen no lleva CUDA y entra en Cloud Run.
RUN pip install --upgrade pip \
    && pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu \
    && pip install -r /tmp/backend-requirements.txt -r /tmp/ml-requirements.txt

COPY backend /app/backend
COPY ml/visionai /app/ml/visionai
COPY ml/weights/visionai_yolo8n.pt /app/ml/weights/visionai_yolo8n.pt

RUN mkdir -p /app/backend/data/uploads

EXPOSE 8080

CMD ["sh", "-c", "uvicorn backend.app.main:app --host 0.0.0.0 --port ${PORT:-8080}"]
