from __future__ import annotations

from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = PROJECT_ROOT / "data"
RAW_DIR = DATA_DIR / "raw"
PROCESSED_DIR = DATA_DIR / "processed"
EXTERNAL_DIR = DATA_DIR / "external"

LOCATIONS_EXTERNAL_PATH = EXTERNAL_DIR / "inei_puno_districts.csv"
LOCATIONS_PROCESSED_PATH = PROCESSED_DIR / "locations_puno.csv"
WEATHER_RAW_PATH = RAW_DIR / "weather_open_meteo.csv"
TRAINING_DATASET_PATH = PROCESSED_DIR / "frost_training_dataset.csv"
TRAINING_DATASET_V2_PATH = PROCESSED_DIR / "frost_training_dataset_v2.csv"

REGISTRY_DIR = PROJECT_ROOT / "ml_pipeline" / "registry"
MODEL_PATH = REGISTRY_DIR / "frost_risk_model.joblib"
MODEL_METADATA_PATH = REGISTRY_DIR / "model_metadata.json"
MODEL_V2_PATH = REGISTRY_DIR / "frost_risk_model_v0_2_0.joblib"
MODEL_METADATA_V2_PATH = REGISTRY_DIR / "model_metadata_v0_2_0.json"

EVALUATION_DIR = PROJECT_ROOT / "ml_pipeline" / "evaluation"
METRICS_COMPARISON_PATH = EVALUATION_DIR / "metrics_comparison.json"
EVALUATION_REPORT_PATH = EVALUATION_DIR / "evaluation_report.json"
CONFUSION_MATRIX_PATH = EVALUATION_DIR / "confusion_matrix.csv"
CONFUSION_MATRIX_V2_PATH = EVALUATION_DIR / "confusion_matrix_v0_2_0.csv"
METRICS_COMPARISON_V2_PATH = EVALUATION_DIR / "metrics_comparison_v0_2_0.json"

REQUIRED_LOCATION_COLUMNS = [
    "ubigeo",
    "departamento",
    "provincia",
    "distrito",
    "latitud",
    "longitud",
    "altitud_estimada",
    "poblacion_total",
    "poblacion_rural",
    "porcentaje_rural",
]

OPEN_METEO_HOURLY_VARIABLES = [
    "temperature_2m",
    "relative_humidity_2m",
    "apparent_temperature",
    "dew_point_2m",
    "precipitation",
    "cloud_cover",
    "wind_speed_10m",
]

NUMERIC_FEATURES = [
    "latitud",
    "longitud",
    "altitud_estimada",
    "poblacion_total",
    "poblacion_rural",
    "porcentaje_rural",
    "temperature_2m",
    "relative_humidity_2m",
    "apparent_temperature",
    "dew_point_2m",
    "precipitation",
    "cloud_cover",
    "wind_speed_10m",
    "mes",
    "hora",
    "temperatura_minima_diaria",
    "horas_bajo_cero",
]

LEAKAGE_FEATURES = [
    "temperatura_minima_diaria",
    "horas_bajo_cero",
]

NUMERIC_FEATURES_V2 = [
    "latitud",
    "longitud",
    "altitud_estimada",
    "temperature_2m",
    "relative_humidity_2m",
    "apparent_temperature",
    "dew_point_2m",
    "precipitation",
    "cloud_cover",
    "wind_speed_10m",
    "mes",
    "hora",
]

TARGET_COLUMN = "riesgo_helada"
