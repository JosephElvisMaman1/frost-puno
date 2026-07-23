"""Lógica de la alerta diaria: helada, riesgo para ganado y anomalía climática.

Umbrales de ganado documentados en docs/livestock_criteria.md (crías de alpaca y
ovino del altiplano son vulnerables a mortalidad neonatal por helada). Son valores
MVP defendibles, no cifras oficiales SENAMHI.
"""

from __future__ import annotations

from statistics import mean, pstdev

# Umbrales de helada sobre la mínima diaria (°C).
STRONG_FROST_MAX = -4.0
MILD_FROST_MAX = 0.0

# Umbrales para ganado (crías vulnerables).
LIVESTOCK_HIGH_MAX = -6.0
LIVESTOCK_MEDIUM_MAX = -2.0

# Anomalía: se marca inusual si la mínima cae bajo media - K*desviación.
ANOMALY_K = 1.5


def frost_severity(temp_min: float | None) -> tuple[str, str, bool, str, str]:
    """Devuelve (risk_level, severity, alert, title, message) para heladas."""
    if temp_min is not None and temp_min <= STRONG_FROST_MAX:
        return (
            "alto",
            "fuerte",
            True,
            "Riesgo de helada fuerte",
            "Hoy hay riesgo de helada fuerte. Se recomienda resguardar el ganado y proteger los cultivos.",
        )
    if temp_min is not None and temp_min <= MILD_FROST_MAX:
        return (
            "medio",
            "moderada",
            True,
            "Riesgo de helada moderada",
            "Hoy hay riesgo de helada moderada. Monitoree la temperatura nocturna y prepare medidas preventivas.",
        )
    return (
        "bajo",
        "ninguna",
        False,
        "Sin alerta de helada",
        "No se prevé helada significativa para hoy. Mantenga seguimiento ante cambios bruscos.",
    )


def livestock_risk(temp_min: float | None) -> dict[str, str]:
    """Riesgo específico para ganado altoandino (crías de alpaca y ovino)."""
    if temp_min is not None and temp_min <= LIVESTOCK_HIGH_MAX:
        return {
            "level": "alto",
            "message": (
                "Riesgo alto para el ganado: proteja crías de alpaca y ovino esta noche; "
                "peligro de mortalidad neonatal por frío."
            ),
        }
    if temp_min is not None and temp_min <= LIVESTOCK_MEDIUM_MAX:
        return {
            "level": "medio",
            "message": (
                "Riesgo medio para el ganado: abrigue a las crías y revise cobertizos antes del anochecer."
            ),
        }
    return {
        "level": "bajo",
        "message": "Sin riesgo relevante para el ganado por temperatura esta noche.",
    }


def anomaly(temp_min_today: float | None, history_rows: list[dict]) -> dict:
    """Compara la mínima de hoy con la climatología reciente (últimos ~30 días)."""
    values = [
        row["temperature_2m_min"]
        for row in history_rows
        if row.get("temperature_2m_min") is not None
    ]
    if temp_min_today is None or len(values) < 5:
        return {
            "historical_mean": None,
            "delta": None,
            "is_unusual": False,
            "message": "Sin datos históricos suficientes para evaluar anomalías.",
        }

    historical_mean = mean(values)
    deviation = pstdev(values)
    delta = temp_min_today - historical_mean
    is_unusual = deviation > 0 and temp_min_today < historical_mean - ANOMALY_K * deviation

    if is_unusual:
        message = (
            f"Helada inusual: {abs(delta):.1f} °C por debajo de lo normal para estas fechas."
        )
    else:
        message = "Temperatura dentro de lo normal para la temporada."

    return {
        "historical_mean": round(historical_mean, 1),
        "delta": round(delta, 1),
        "is_unusual": is_unusual,
        "message": message,
    }
