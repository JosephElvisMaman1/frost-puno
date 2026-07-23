from __future__ import annotations

from datetime import date, timedelta

from fastapi import APIRouter, Depends, Query

from app.api.routes.weather import get_weather_provider
from app.schemas.alerts import ClimateAnomaly, DailyAlertResponse, LivestockRisk
from app.services.alert_service import anomaly, frost_severity, livestock_risk
from app.services.model_registry import ModelRegistry, get_model_registry
from app.services.weather_providers import WeatherQuery

router = APIRouter(prefix="/alerts", tags=["alerts"])


@router.get("/today", response_model=DailyAlertResponse)
def alert_today(
    latitude: float = Query(..., ge=-18.5, le=-13.0),
    longitude: float = Query(..., ge=-71.5, le=-68.0),
    registry: ModelRegistry = Depends(get_model_registry),
) -> DailyAlertResponse:
    provider = get_weather_provider()
    query = WeatherQuery(latitude=latitude, longitude=longitude)

    forecast = provider.get_daily_forecast(query, days=1)
    today = forecast[0] if forecast else {}
    temp_min = today.get("temperature_2m_min")
    day = today.get("date")

    # Climatología reciente para detectar anomalías (últimos ~30 días con retraso de archivo).
    history_rows: list[dict] = []
    try:
        end = date.today() - timedelta(days=6)
        start = end - timedelta(days=29)
        history_rows = provider.get_history(query, start.isoformat(), end.isoformat())
    except Exception:  # noqa: BLE001 - la alerta no debe romperse si el histórico falla.
        history_rows = []

    risk_level, severity, alert, title, message = frost_severity(temp_min)
    livestock = livestock_risk(temp_min)
    anomaly_data = anomaly(temp_min, history_rows)

    return DailyAlertResponse(
        latitude=latitude,
        longitude=longitude,
        date=str(day) if day is not None else None,
        risk_level=risk_level,
        frost_alert=alert,
        severity=severity,
        temperature_min=temp_min,
        title=title,
        message=message,
        livestock=LivestockRisk(**livestock),
        anomaly=ClimateAnomaly(**anomaly_data),
        model_version=registry.metadata.version,
    )
