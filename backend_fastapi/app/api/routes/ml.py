from __future__ import annotations

from fastapi import APIRouter, Depends

from app.schemas.ml import ModelInfoResponse
from app.services.model_registry import ModelRegistry, get_model_registry


router = APIRouter(prefix="/ml", tags=["ml"])


@router.get("/model-info", response_model=ModelInfoResponse)
def model_info(registry: ModelRegistry = Depends(get_model_registry)) -> ModelInfoResponse:
    metadata = registry.metadata
    return ModelInfoResponse(
        model_name=metadata.model_name,
        version=metadata.version,
        created_at=metadata.created_at,
        features=metadata.features,
        target=metadata.target,
        metrics=metadata.metrics,
        dataset_size=metadata.dataset_size,
        data_sources=metadata.data_sources,
        limitations=metadata.limitations,
    )

