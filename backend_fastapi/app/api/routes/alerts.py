from __future__ import annotations

from fastapi import APIRouter, Depends, Query

from app.api.routes.weather import get_weather_provider
from app.schemas.alerts import DailyAlertResponse
from app.services.model_registry import ModelRegistry, get_model_registry
from app.services.weather_providers import WeatherQuery

router = APIRouter(prefix="/alerts", tags=["alerts"])

# Umbrales de alerta sobre la mínima diaria pronosticada (°C).
STRONG_FROST_MAX = -4.0
MILD_FROST_MAX = 0.0


@router.get("/today", response_model=DailyAlertResponse)
def alert_today(
    latitude: float = Query(..., ge=-18.5, le=-13.0),
    longitude: float = Query(..., ge=-71.5, le=-68.0),
    registry: ModelRegistry = Depends(get_model_registry),
) -> DailyAlertResponse:
    provider = get_weather_provider()
    forecast = provider.get_daily_forecast(WeatherQuery(latitude=latitude, longitude=longitude), days=1)
    today = forecast[0] if forecast else {}
    temp_min = today.get("temperature_2m_min")
    date = today.get("date")

    if temp_min is not None and temp_min <= STRONG_FROST_MAX:
        risk_level, severity, alert = "alto", "fuerte", True
        title = "Riesgo de helada fuerte"
        message = (
            "Hoy hay riesgo de helada fuerte. Se recomienda resguardar el ganado y proteger los cultivos."
        )
    elif temp_min is not None and temp_min <= MILD_FROST_MAX:
        risk_level, severity, alert = "medio", "moderada", True
        title = "Riesgo de helada moderada"
        message = (
            "Hoy hay riesgo de helada moderada. Monitoree la temperatura nocturna y prepare medidas preventivas."
        )
    else:
        risk_level, severity, alert = "bajo", "ninguna", False
        title = "Sin alerta de helada"
        message = "No se prevé helada significativa para hoy. Mantenga seguimiento ante cambios bruscos."

    return DailyAlertResponse(
        latitude=latitude,
        longitude=longitude,
        date=str(date) if date is not None else None,
        risk_level=risk_level,
        frost_alert=alert,
        severity=severity,
        temperature_min=temp_min,
        title=title,
        message=message,
        model_version=registry.metadata.version,
    )
