from __future__ import annotations

from app.schemas.prediction import FrostRiskRequest


def build_recommendation(risk_level: str, payload: FrostRiskRequest) -> tuple[str, str]:
    crop = payload.main_crop or "cultivos sensibles"

    if risk_level == "alto":
        recommendation = (
            "Existe alto riesgo de helada. Se recomienda proteger cultivos sensibles, "
            f"priorizar vigilancia de {crop} y revisar ganado o infraestructura expuesta."
        )
    elif risk_level == "medio":
        recommendation = (
            "Existe riesgo medio de helada. Se recomienda monitorear la temperatura nocturna "
            "y preparar medidas preventivas si el descenso continua."
        )
    else:
        recommendation = (
            "El riesgo de helada es bajo para las condiciones enviadas. Mantenga seguimiento "
            "si hay cambios bruscos de viento, nubosidad o temperatura."
        )

    if payload.temperature_min <= 0 and payload.hours_below_zero >= 3 and payload.precipitation <= 1:
        chuno_conditions = "favorables"
        recommendation += " Las condiciones pueden ser favorables para la produccion de chuno."
    elif payload.temperature_min <= 3:
        chuno_conditions = "posibles"
    else:
        chuno_conditions = "no_favorables"

    return recommendation, chuno_conditions

