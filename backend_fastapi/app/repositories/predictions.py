from __future__ import annotations

import logging
from functools import lru_cache
from typing import Protocol

from app.core.config import settings
from app.schemas.prediction import FrostPredictionHistoryItem, FrostRiskRequest, FrostRiskResponse


LOGGER = logging.getLogger(__name__)


class PredictionRepository(Protocol):
    def save_prediction(self, request: FrostRiskRequest, response: FrostRiskResponse) -> None:
        """Persist a prediction when a backing store is configured."""

    def list_history(self, limit: int = 20) -> list[FrostPredictionHistoryItem]:
        """Return recent predictions."""


class NoOpPredictionRepository:
    def save_prediction(self, request: FrostRiskRequest, response: FrostRiskResponse) -> None:
        LOGGER.info(
            "Prediction persistence disabled. district=%s risk=%s model=%s",
            request.district,
            response.risk_level,
            response.model_version,
        )

    def list_history(self, limit: int = 20) -> list[FrostPredictionHistoryItem]:
        LOGGER.info("Prediction history requested while persistence is disabled. limit=%s", limit)
        return []


@lru_cache(maxsize=1)
def get_prediction_repository() -> PredictionRepository:
    if settings.enable_supabase:
        if settings.supabase_url and settings.supabase_service_role_key:
            from app.repositories.supabase_prediction_repository import SupabasePredictionRepository

            return SupabasePredictionRepository(
                supabase_url=settings.supabase_url,
                service_role_key=settings.supabase_service_role_key,
            )
        LOGGER.warning("ENABLE_SUPABASE=true but SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY is missing. Using NoOp.")
    return NoOpPredictionRepository()
