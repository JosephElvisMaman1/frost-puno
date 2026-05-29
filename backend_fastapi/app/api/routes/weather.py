from __future__ import annotations

from functools import lru_cache

from fastapi import APIRouter, Query

from app.schemas.weather import CurrentWeatherResponse
from app.services.weather_providers import HybridWeatherProvider, WeatherQuery


router = APIRouter(prefix="/weather", tags=["weather"])


@lru_cache(maxsize=1)
def get_weather_provider() -> HybridWeatherProvider:
    return HybridWeatherProvider()


@router.get("/current", response_model=CurrentWeatherResponse)
def current_weather(
    latitude: float = Query(..., ge=-18.5, le=-13.0),
    longitude: float = Query(..., ge=-71.5, le=-68.0),
) -> CurrentWeatherResponse:
    return get_weather_provider().get_current_weather(
        WeatherQuery(latitude=latitude, longitude=longitude),
    )
