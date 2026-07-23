from __future__ import annotations

from pydantic import BaseModel, ConfigDict


class ChunoDay(BaseModel):
    date: str
    temperature_min: float | None = None
    temperature_max: float | None = None
    humidity_max: float | None = None
    cloud_cover_mean: float | None = None
    precipitation_sum: float | None = None
    tier: str  # excelente | bueno | marginal | no_apto
    is_good_day: bool


class ChunoWindowResponse(BaseModel):
    in_season: bool
    season_months: list[int]
    latitude: float
    longitude: float
    days: list[ChunoDay]
    optimal_window: bool
    best_streak: int
    message: str
    criteria_source: str = "docs/chuno_criteria.md"

    model_config = ConfigDict(extra="forbid")
