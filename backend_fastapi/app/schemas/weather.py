from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class CurrentWeatherResponse(BaseModel):
    latitude: float
    longitude: float
    temperature: float | None = None
    apparent_temperature: float | None = None
    humidity: float | None = None
    wind_speed: float | None = None
    cloud_cover: float | None = None
    dew_point: float | None = None
    precipitation: float | None = None
    observed_at: str | None = None
    provider: str
    source_priority: list[str]
    station_name: str | None = None
    station_distance_km: float | None = None
    fallback_used: bool = False
    limitations: list[str] = Field(default_factory=list)

    model_config = ConfigDict(extra="forbid")


class HistoryDay(BaseModel):
    date: str
    temperature_min: float | None = None
    temperature_max: float | None = None
    humidity_mean: float | None = None


class WeatherHistoryResponse(BaseModel):
    latitude: float
    longitude: float
    start_date: str
    end_date: str
    provider: str = "Open-Meteo Archive"
    days: list[HistoryDay]

    model_config = ConfigDict(extra="forbid")
