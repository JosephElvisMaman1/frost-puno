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

        try:
            model = self.registry.model
            predicted_label = str(model.predict(feature_frame)[0])
            confidence = self._confidence(model, feature_frame, predicted_label)
        except Exception as exc:  # noqa: BLE001 - expose stable API error instead of model internals.
            LOGGER.exception("Prediction failed.")
            raise PredictionError("The model could not generate a prediction for the request.") from exc

        recommendation, chuno_conditions = build_recommendation(predicted_label, payload)
        return FrostRiskResponse(
            risk_level=predicted_label,
            confidence=confidence,
            recommendation=recommendation,
            chuno_conditions=chuno_conditions,
            model_version=metadata.version,
            data_sources=metadata.data_sources,
        )

    def _to_feature_frame(self, payload: FrostRiskRequest, feature_names: list[str]) -> pd.DataFrame:
        total_population = payload.total_population or max(payload.rural_population, 1)
        rural_percentage = (
            payload.rural_percentage
            if payload.rural_percentage is not None
            else min(100.0, (payload.rural_population / total_population) * 100)
        )
        feature_values: dict[str, Any] = {
            "latitud": payload.latitude,
            "longitud": payload.longitude,
            "altitud_estimada": payload.altitude,
            "poblacion_total": total_population,
            "poblacion_rural": payload.rural_population,
            "porcentaje_rural": rural_percentage,
            "temperature_2m": payload.temperature_min,
            "relative_humidity_2m": payload.humidity,
            "apparent_temperature": payload.feels_like,
            "dew_point_2m": payload.dew_point,
            "precipitation": payload.precipitation,
            "cloud_cover": payload.cloud_cover,
            "wind_speed_10m": payload.wind_speed,
            "mes": payload.month,
            "hora": payload.hour,
            "temperatura_minima_diaria": payload.temperature_min,
            "horas_bajo_cero": payload.hours_below_zero,
        }

        missing = [name for name in feature_names if name not in feature_values]
        if missing:
            raise PredictionError(f"Request cannot build required model features: {missing}")

        return pd.DataFrame([{name: feature_values[name] for name in feature_names}])

    @staticmethod
    def _confidence(model: Any, feature_frame: pd.DataFrame, predicted_label: str) -> float:
        if not hasattr(model, "predict_proba"):
            return 1.0

        probabilities = model.predict_proba(feature_frame)[0]
        classes = getattr(model, "classes_", None)
        if classes is None and hasattr(model, "named_steps"):
            classes = getattr(model.named_steps.get("model"), "classes_", None)
        if classes is None:
            return float(max(probabilities))

        class_to_probability = {
            str(label): float(probability)
            for label, probability in zip(classes, probabilities, strict=False)
        }
        return class_to_probability.get(predicted_label, float(max(probabilities)))


@lru_cache(maxsize=1)
def get_prediction_service() -> PredictionService:
    return PredictionService(get_model_registry())

