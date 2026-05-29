from __future__ import annotations

import logging
from typing import Any

import httpx

from app.schemas.prediction import FrostPredictionHistoryItem, FrostRiskRequest, FrostRiskResponse


LOGGER = logging.getLogger(__name__)


class SupabasePredictionRepository:
    def __init__(
        self,
        supabase_url: str,
        service_role_key: str,
        client: httpx.Client | None = None,
    ) -> None:
        self.supabase_url = supabase_url.rstrip("/")
        self.service_role_key = service_role_key
        self.client = client or httpx.Client(timeout=10)

    def save_prediction(self, request: FrostRiskRequest, response: FrostRiskResponse) -> None:
        payload = self._build_insert_payload(request, response)
        try:
            result = self.client.post(
                f"{self.supabase_url}/rest/v1/frost_predictions",
                headers=self._headers(prefer="return=minimal"),
                json=payload,
            )
            result.raise_for_status()
        except Exception as exc:  # noqa: BLE001 - prediction should still be returned if persistence fails.
            LOGGER.warning("Could not persist prediction to Supabase: %s", exc)

    def list_history(self, limit: int = 20) -> list[FrostPredictionHistoryItem]:
        safe_limit = max(1, min(limit, 100))
        try:
            result = self.client.get(
                f"{self.supabase_url}/rest/v1/frost_predictions",
                headers=self._headers(),
                params={
                    "select": (
                        "id,district,province,populated_center,latitude,longitude,altitude,"
                        "risk_level,confidence,chuno_conditions,recommendation,model_version,"
                        "data_sources,created_at"
                    ),
                    "order": "created_at.desc",
                    "limit": str(safe_limit),
                },
            )
            result.raise_for_status()
            rows = result.json()
            if not isinstance(rows, list):
                LOGGER.warning("Unexpected Supabase history response shape: %s", type(rows).__name__)
                return []
            return [FrostPredictionHistoryItem.model_validate(row) for row in rows]
        except Exception as exc:  # noqa: BLE001 - history endpoint should degrade gracefully for MVP.
            LOGGER.warning("Could not read prediction history from Supabase: %s", exc)
            return []

    def _headers(self, prefer: str | None = None) -> dict[str, str]:
        headers = {
            "apikey": self.service_role_key,
            "Authorization": f"Bearer {self.service_role_key}",
            "Content-Type": "application/json",
        }
        if prefer:
            headers["Prefer"] = prefer
        return headers

    @staticmethod
    def _build_insert_payload(request: FrostRiskRequest, response: FrostRiskResponse) -> dict[str, Any]:
        return {
            "user_id": None,
            "district": request.district,
            "province": request.province,
            "populated_center": request.populated_center,
            "latitude": request.latitude,
            "longitude": request.longitude,
            "altitude": request.altitude,
            "input_payload": request.model_dump(mode="json"),
            "risk_level": response.risk_level,
            "confidence": response.confidence,
            "chuno_conditions": response.chuno_conditions,
            "recommendation": response.recommendation,
            "model_version": response.model_version,
            "data_sources": response.data_sources,
        }

