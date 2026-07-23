# Criterios de riesgo para ganado (alertas)

Umbrales usados por `/alerts/today` (bloque `livestock`) para avisar al ganadero
altoandino. En el altiplano de Puno las heladas causan **mortalidad neonatal** en crías
de alpaca y ovino; los adultos resisten mejor. Valores **MVP defendibles**, no cifras
oficiales SENAMHI.

| Nivel | Umbral (mínima diaria) | Mensaje |
|---|---|---|
| alto | `temp_min ≤ -6 °C` | Proteja crías de alpaca y ovino; peligro de mortalidad neonatal. |
| medio | `-6 < temp_min ≤ -2 °C` | Abrigue crías y revise cobertizos antes del anochecer. |
| bajo | `temp_min > -2 °C` | Sin riesgo relevante por temperatura esta noche. |

Definidos en `backend_fastapi/app/services/alert_service.py` (`livestock_risk`).

## Anomalía climática

`/alerts/today` también compara la mínima de hoy con la **climatología reciente**
(media y desviación de los últimos ~30 días vía Open-Meteo Archive). Se marca
`is_unusual` si `temp_min_hoy < media − 1.5 × desviación`. Es climatología reciente, no
serie multianual — suficiente para el MVP.
