from __future__ import annotations

from datetime import datetime, timezone

from fastapi import APIRouter, Query

from app.api.routes.weather import get_weather_provider
from app.schemas.chuno import ChunoWindowResponse
from app.services.chuno_service import evaluate_window
from app.services.weather_providers import WeatherQuery

router = APIRouter(prefix="/chuno", tags=["chuno"])


@router.get("/window", response_model=ChunoWindowResponse)
def chuno_window(
    latitude: float = Query(..., ge=-18.5, le=-13.0),
    longitude: float = Query(..., ge=-71.5, le=-68.0),
    days: int = Query(7, ge=1, le=16),
) -> ChunoWindowResponse:
    provider = get_weather_provider()
    forecast = provider.get_daily_forecast(WeatherQuery(latitude=latitude, longitude=longitude), days=days)
    current_month = datetime.now(timezone.utc).month
    return evaluate_window(latitude, longitude, current_month, forecast)
