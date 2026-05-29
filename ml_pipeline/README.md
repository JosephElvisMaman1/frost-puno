# Frost Puno ML Pipeline

Primer pipeline de aprendizaje supervisado para clasificar riesgo de helada en Puno.

## Flujo

1. Validar ubicaciones distritales desde `data/external/inei_puno_districts.csv`.
2. Descargar clima horario desde Open-Meteo Historical API.
3. Construir features y etiquetas iniciales.
4. Validar dataset.
5. Entrenar y comparar Logistic Regression, Decision Tree y Random Forest.
6. Registrar el mejor modelo en `ml_pipeline/registry/`.

## Ejecucion rapida en Windows

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r ml_pipeline\requirements.txt

python -m ml_pipeline.data_ingestion.ingest_locations
python -m ml_pipeline.data_ingestion.ingest_weather_open_meteo --start-date 2024-06-01 --end-date 2024-06-14 --max-workers 4
python -m ml_pipeline.features.build_features
python -m ml_pipeline.preprocessing.validate_dataset
python -m ml_pipeline.training.train_models --version v0.1.0
python -m ml_pipeline.evaluation.evaluate_model
```

Para una prueba corta:

```powershell
python -m ml_pipeline.data_ingestion.ingest_weather_open_meteo --start-date 2024-06-01 --end-date 2024-06-03 --limit 3
```

## Notas

- El dataset territorial inicial es una semilla MVP y debe reemplazarse por exportaciones oficiales completas de INEI EstaDist/CPV 2017 antes de usar el sistema fuera de una demo.
- Las etiquetas iniciales son reglas basadas en temperatura minima y horas bajo cero; no son observaciones oficiales de dano agricola.
- SENAMHI queda priorizado para validacion oficial en fase 2.
