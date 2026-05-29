from __future__ import annotations

from pydantic import BaseModel, ConfigDict


class ModelInfoResponse(BaseModel):
    model_name: str
    version: str
    created_at: str
    features: list[str]
    target: str
    metrics: dict[str, float]
    dataset_size: int
    data_sources: list[str]
    limitations: list[str]

    model_config = ConfigDict(extra="forbid")


class ModelMetadata(ModelInfoResponse):
    all_model_metrics: dict[str, dict[str, float]] | None = None

