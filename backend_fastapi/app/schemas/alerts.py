from __future__ import annotations

from pydantic import BaseModel, ConfigDict


class DailyAlertResponse(BaseModel):
    latitude: float
    longitude: float
    date: str | None = None
    risk_level: str  # alto | medio | bajo
    frost_alert: bool
    severity: str  # fuerte | moderada | ninguna
    temperature_min: float | None = None
    title: str
    message: str
    model_version: str

    model_config = ConfigDict(extra="forbid")
