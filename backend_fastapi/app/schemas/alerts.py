from __future__ import annotations

from pydantic import BaseModel, ConfigDict


class LivestockRisk(BaseModel):
    level: str  # alto | medio | bajo
    message: str


class ClimateAnomaly(BaseModel):
    historical_mean: float | None = None
    delta: float | None = None
    is_unusual: bool = False
    message: str


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
    livestock: LivestockRisk
    anomaly: ClimateAnomaly
    model_version: str

    model_config = ConfigDict(extra="forbid")
