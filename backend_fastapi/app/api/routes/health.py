from __future__ import annotations

from fastapi import APIRouter

from app.core.config import settings
from app.schemas.health import HealthResponse


router = APIRouter(tags=["health"])


@router.get("/health", response_model=HealthResponse)
def health_check() -> HealthResponse:
    model_exists = settings.model_path.exists()
    metadata_exists = settings.model_metadata_path.exists()
    return HealthResponse(
        status="ok" if model_exists and metadata_exists else "degraded",
        app_name=settings.app_name,
        version=settings.api_version,
        model_available=model_exists and metadata_exists,
    )

