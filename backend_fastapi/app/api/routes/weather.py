from __future__ import annotations

from functools import lru_cache

from fastapi import APIRouter, Query

from app.schemas.weather import CurrentWeatherResponse, HistoryDay, WeatherHistoryResponse
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


@router.get("/history", response_model=WeatherHistoryResponse)
def weather_history(
    latitude: float = Query(..., ge=-18.5, le=-13.0),
    longitude: float = Query(..., ge=-71.5, le=-68.0),
    start: str = Query(..., description="Fecha inicio YYYY-MM-DD"),
    end: str = Query(..., description="Fecha fin YYYY-MM-DD"),
) -> WeatherHistoryResponse:
    rows = get_weather_provider().get_history(
        WeatherQuery(latitude=latitude, longitude=longitude), start, end
    )
    days = [
        HistoryDay(
            date=str(row.get("date")),
            temperature_min=row.get("temperature_2m_min"),
            temperature_max=row.get("temperature_2m_max"),
            humidity_mean=row.get("relative_humidity_2m_mean"),
        )
        for row in rows
    ]
    return WeatherHistoryResponse(
        latitude=latitude,
        longitude=longitude,
        start_date=start,
        end_date=end,
        days=days,
    )
