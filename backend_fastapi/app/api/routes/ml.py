from __future__ import annotations

import csv

from fastapi import APIRouter, Depends

from app.core.config import settings
from app.schemas.ml import (
    ClusterProfile,
    ClustersResponse,
    DistrictCluster,
    ModelInfoResponse,
)
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
        n_clusters=metadata.n_clusters,
    )


def _load_districts() -> list[DistrictCluster]:
    path = settings.district_clusters_path
    if not path.exists():
        return []
    districts: list[DistrictCluster] = []
    with path.open(encoding="utf-8", newline="") as handle:
        for row in csv.DictReader(handle):
            districts.append(
                DistrictCluster(
                    distrito=row["distrito"],
                    tier=row["tier"],
                    dominant_cluster=int(float(row["dominant_cluster"])),
                    cold_share=float(row["cold_share"]),
                    altitud_estimada=float(row["altitud_estimada"]),
                    temperature_2m_mean=float(row["temperature_2m_mean"]),
                    latitud=float(row["latitud"]) if row.get("latitud") else None,
                    longitud=float(row["longitud"]) if row.get("longitud") else None,
                )
            )
    return districts


@router.get("/clusters", response_model=ClustersResponse)
def clusters(registry: ModelRegistry = Depends(get_model_registry)) -> ClustersResponse:
    metadata = registry.metadata
    profiles_raw = metadata.cluster_profiles or {}
    profiles = [
        ClusterProfile(
            cluster_id=int(cid),
            tier=str(profile.get("tier", "medio")),
            size=int(profile.get("size", 0)),
            temperature_2m=float(profile.get("temperature_2m", 0.0)),
            dew_point_2m=float(profile.get("dew_point_2m", 0.0)),
        )
        for cid, profile in profiles_raw.items()
    ]
    profiles.sort(key=lambda p: p.temperature_2m)
    return ClustersResponse(
        model_name=metadata.model_name,
        version=metadata.version,
        n_clusters=metadata.n_clusters or len(profiles),
        silhouette=float(metadata.metrics.get("silhouette", 0.0)),
        profiles=profiles,
        districts=_load_districts(),
    )

