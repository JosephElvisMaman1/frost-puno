"""Reglas del módulo estacional de chuño.

Umbrales documentados en docs/chuno_criteria.md (mayo–agosto; congelamiento
nocturno ≤ −5 °C; secado con cielo despejado, aire seco y sin lluvia).
"""

from __future__ import annotations

from app.schemas.chuno import ChunoDay, ChunoWindowResponse

SEASON_MONTHS = [5, 6, 7, 8]
MIN_CONSECUTIVE_GOOD_DAYS = 3

# Umbrales base ("buen día")
FREEZE_MAX = -5.0
PRECIP_MAX = 0.2
CLOUD_MAX = 40.0
HUMIDITY_MAX = 60.0

# Umbrales "excelente"
FREEZE_EXCELLENT = -8.0
CLOUD_EXCELLENT = 20.0
HUMIDITY_EXCELLENT = 50.0


def _classify(temp_min, precip, cloud, humidity) -> tuple[str, bool]:
    if temp_min is None:
        return "no_apto", False
    precip = precip if precip is not None else 0.0
    cloud = cloud if cloud is not None else 100.0
    humidity = humidity if humidity is not None else 100.0

    good = temp_min <= FREEZE_MAX and precip <= PRECIP_MAX and cloud <= CLOUD_MAX and humidity <= HUMIDITY_MAX
    if good:
        excellent = (
            temp_min <= FREEZE_EXCELLENT
            and cloud <= CLOUD_EXCELLENT
            and humidity <= HUMIDITY_EXCELLENT
            and precip <= 0.0
        )
        return ("excelente" if excellent else "bueno"), True

    if temp_min > -2.0 or precip > 1.0:
        return "no_apto", False
    return "marginal", False


def _best_streak(days: list[ChunoDay]) -> int:
    best = current = 0
    for day in days:
        current = current + 1 if day.is_good_day else 0
        best = max(best, current)
    return best


def evaluate_window(
    latitude: float,
    longitude: float,
    current_month: int,
    forecast_rows: list[dict],
) -> ChunoWindowResponse:
    in_season = current_month in SEASON_MONTHS

    days: list[ChunoDay] = []
    for row in forecast_rows:
        tier, is_good = _classify(
            row.get("temperature_2m_min"),
            row.get("precipitation_sum"),
            row.get("cloud_cover_mean"),
            row.get("relative_humidity_2m_max"),
        )
        days.append(
            ChunoDay(
                date=str(row.get("date")),
                temperature_min=row.get("temperature_2m_min"),
                temperature_max=row.get("temperature_2m_max"),
                humidity_max=row.get("relative_humidity_2m_max"),
                cloud_cover_mean=row.get("cloud_cover_mean"),
                precipitation_sum=row.get("precipitation_sum"),
                tier=tier,
                is_good_day=is_good,
            )
        )

    best_streak = _best_streak(days)
    optimal = in_season and best_streak >= MIN_CONSECUTIVE_GOOD_DAYS

    if not in_season:
        message = "Fuera de temporada de chuño (mayo–agosto). El módulo se reactiva en la estación seca fría."
    elif optimal:
        message = (
            f"Ventana óptima detectada: {best_streak} días consecutivos aptos para congelar y secar chuño."
        )
    else:
        message = (
            "En temporada, pero aún sin una ventana de 3 días consecutivos aptos. "
            "Monitoree el pronóstico nocturno."
        )

    return ChunoWindowResponse(
        in_season=in_season,
        season_months=SEASON_MONTHS,
        latitude=latitude,
        longitude=longitude,
        days=days,
        optimal_window=optimal,
        best_streak=best_streak,
        message=message,
    )
