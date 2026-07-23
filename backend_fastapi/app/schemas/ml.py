from __future__ import annotations

from typing import Any

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
    n_clusters: int | None = None

    model_config = ConfigDict(extra="forbid")


class ModelMetadata(ModelInfoResponse):
    # Campos del modelo no supervisado (K-Means). extra="ignore" tolera
    # metadata legacy del clasificador supervisado sin romper la carga.
    all_model_metrics: dict[str, dict[str, float]] | None = None
    all_k_metrics: dict[str, dict[str, float]] | None = None
    cluster_tiers: dict[str, str] | None = None
    cluster_profiles: dict[str, dict[str, Any]] | None = None

    model_config = ConfigDict(extra="ignore")


class ClusterProfile(BaseModel):
    cluster_id: int
    tier: str
    size: int
    temperature_2m: float
    dew_point_2m: float


class DistrictCluster(BaseModel):
    distrito: str
    tier: str
    dominant_cluster: int
    cold_share: float
    altitud_estimada: float
    temperature_2m_mean: float
    latitud: float | None = None
    longitud: float | None = None


class ClustersResponse(BaseModel):
    model_name: str
    version: str
    n_clusters: int
    silhouette: float
    profiles: list[ClusterProfile]
    districts: list[DistrictCluster]

