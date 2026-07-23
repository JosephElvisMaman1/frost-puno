from __future__ import annotations

import logging
from functools import lru_cache
from typing import Any

import pandas as pd

from app.core.exceptions import PredictionError
from app.schemas.prediction import FrostRiskRequest, FrostRiskResponse
from app.services.model_registry import ModelRegistry, get_model_registry
from app.services.recommendation_service import build_recommendation


LOGGER = logging.getLogger(__name__)


class PredictionService:
    def __init__(self, registry: ModelRegistry) -> None:
        self.registry = registry

    def predict(self, payload: FrostRiskRequest) -> FrostRiskResponse:
        metadata = self.registry.metadata
        feature_frame = self._to_feature_frame(payload, metadata.features)
        tier_map = metadata.cluster_tiers or {}

        try:
            model = self.registry.model
            cluster_id = int(model.predict(feature_frame)[0])
            risk_level = tier_map.get(str(cluster_id), "medio")
            confidence = self._cluster_confidence(model, feature_frame)
        except Exception as exc:  # noqa: BLE001 - expose stable API error instead of model internals.
            LOGGER.exception("Prediction failed.")
            raise PredictionError("The model could not generate a prediction for the request.") from exc

        recommendation, chuno_conditions = build_recommendation(risk_level, payload)
        return FrostRiskResponse(
            risk_level=risk_level,
            confidence=confidence,
            recommendation=recommendation,
            chuno_conditions=chuno_conditions,
            model_version=metadata.version,
            data_sources=metadata.data_sources,
        )

    def _to_feature_frame(self, payload: FrostRiskRequest, feature_names: list[str]) -> pd.DataFrame:
        # Vector para el modelo no supervisado: la temperatura mínima es la señal
        # de helada relevante y se mapea a temperature_2m.
        feature_values: dict[str, Any] = {
            "latitud": payload.latitude,
            "longitud": payload.longitude,
            "altitud_estimada": payload.altitude,
            "temperature_2m": payload.temperature_min,
            "relative_humidity_2m": payload.humidity,
            "apparent_temperature": payload.feels_like,
            "dew_point_2m": payload.dew_point,
            "precipitation": payload.precipitation,
            "cloud_cover": payload.cloud_cover,
            "wind_speed_10m": payload.wind_speed,
            "mes": payload.month,
            "hora": payload.hour,
        }

        missing = [name for name in feature_names if name not in feature_values]
        if missing:
            raise PredictionError(f"Request cannot build required model features: {missing}")

        return pd.DataFrame([{name: feature_values[name] for name in feature_names}])

    @staticmethod
    def _cluster_confidence(model: Any, feature_frame: pd.DataFrame) -> float:
        """Confianza por cercanía relativa al centroide más cercano (KMeans.transform)."""
        if not hasattr(model, "transform"):
            return 1.0

        distances = model.transform(feature_frame)[0]
        inverse = 1.0 / (distances + 1e-9)
        total = float(inverse.sum())
        if total <= 0:
            return 1.0
        return float(inverse.max() / total)


@lru_cache(maxsize=1)
def get_prediction_service() -> PredictionService:
    return PredictionService(get_model_registry())

