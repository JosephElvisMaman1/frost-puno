from __future__ import annotations

import argparse
import logging
from pathlib import Path

import pandas as pd

from ml_pipeline.config import (
    LOCATIONS_PROCESSED_PATH,
    OPEN_METEO_HOURLY_VARIABLES,
    TRAINING_DATASET_PATH,
    WEATHER_RAW_PATH,
)
from ml_pipeline.utils import configure_logging, ensure_parent_dir, validate_columns


LOGGER = logging.getLogger(__name__)


def load_inputs(locations_path: Path, weather_path: Path) -> tuple[pd.DataFrame, pd.DataFrame]:
    if not locations_path.exists():
        raise FileNotFoundError(f"Locations file not found: {locations_path}")
    if not weather_path.exists():
        raise FileNotFoundError(f"Weather file not found: {weather_path}")

    locations = pd.read_csv(locations_path, dtype={"ubigeo": str})
    weather = pd.read_csv(weather_path, dtype={"ubigeo": str})

    validate_columns(
        locations,
        [
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
        ],
        "locations_puno.csv",
    )
    validate_columns(weather, ["ubigeo", "time", *OPEN_METEO_HOURLY_VARIABLES], "weather_open_meteo.csv")
    return locations, weather


def label_frost_risk(temperature_min: float, hours_below_zero: int) -> str:
    if temperature_min <= 0 or hours_below_zero >= 3:
        return "alto"
    if 0 < temperature_min <= 3:
        return "medio"
    return "bajo"


def build_training_dataset(locations: pd.DataFrame, weather: pd.DataFrame) -> pd.DataFrame:
    weather_clean = weather.copy()
    weather_clean["datetime"] = pd.to_datetime(weather_clean["time"], errors="coerce")
    if weather_clean["datetime"].isna().any():
        raise ValueError("Weather data contains invalid datetime values.")

    for column in OPEN_METEO_HOURLY_VARIABLES:
        weather_clean[column] = pd.to_numeric(weather_clean[column], errors="coerce")

    missing_weather = weather_clean[OPEN_METEO_HOURLY_VARIABLES].isna().sum()
    if (missing_weather > 0).any():
        LOGGER.warning("Weather data has missing values: %s", missing_weather[missing_weather > 0].to_dict())

    weather_clean["fecha"] = weather_clean["datetime"].dt.date.astype(str)
    weather_clean["mes"] = weather_clean["datetime"].dt.month
    weather_clean["hora"] = weather_clean["datetime"].dt.hour
    weather_clean["is_below_zero"] = weather_clean["temperature_2m"] < 0

    daily = (
        weather_clean.groupby(["ubigeo", "fecha"], as_index=False)
        .agg(
            temperatura_minima_diaria=("temperature_2m", "min"),
            horas_bajo_cero=("is_below_zero", "sum"),
        )
    )

    dataset = weather_clean.merge(daily, on=["ubigeo", "fecha"], how="left")
    location_columns = [
        "ubigeo",
        "altitud_estimada",
        "poblacion_total",
        "poblacion_rural",
        "porcentaje_rural",
    ]
    dataset = dataset.drop(columns=["latitud", "longitud", "departamento", "provincia", "distrito"], errors="ignore")
    dataset = dataset.merge(locations, on="ubigeo", how="left", suffixes=("", "_location"))

    validate_columns(dataset, location_columns, "merged training dataset")
    dataset["riesgo_helada"] = dataset.apply(
        lambda row: label_frost_risk(row["temperatura_minima_diaria"], int(row["horas_bajo_cero"])),
        axis=1,
    )
    dataset["actividad_agropecuaria"] = True
    dataset["cultivo_relevante"] = "papa"
    dataset["temporada_agricola"] = dataset["mes"].map(infer_agricultural_season)

    ordered_columns = [
        "fecha",
        "time",
        "departamento",
        "provincia",
        "distrito",
        "ubigeo",
        "latitud",
        "longitud",
        "altitud_estimada",
        "poblacion_total",
        "poblacion_rural",
        "porcentaje_rural",
        "actividad_agropecuaria",
        "cultivo_relevante",
        *OPEN_METEO_HOURLY_VARIABLES,
        "mes",
        "hora",
        "temporada_agricola",
        "temperatura_minima_diaria",
        "horas_bajo_cero",
        "riesgo_helada",
    ]
    return dataset[ordered_columns].sort_values(["ubigeo", "time"])


def infer_agricultural_season(month: int) -> str:
    if month in {5, 6, 7, 8}:
        return "heladas_invernales"
    if month in {9, 10, 11}:
        return "siembra"
    if month in {12, 1, 2, 3}:
        return "campania_lluvias"
    return "transicion"


def save_dataset(dataset: pd.DataFrame, output_path: Path) -> None:
    ensure_parent_dir(output_path)
    dataset.to_csv(output_path, index=False)
    LOGGER.info(
        "Saved training dataset with %s rows and class distribution %s to %s",
        len(dataset),
        dataset["riesgo_helada"].value_counts().to_dict(),
        output_path,
    )


def run(locations_path: Path, weather_path: Path, output_path: Path) -> None:
    locations, weather = load_inputs(locations_path, weather_path)
    dataset = build_training_dataset(locations, weather)
    save_dataset(dataset, output_path)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build Frost Puno ML features and labels.")
    parser.add_argument("--locations", type=Path, default=LOCATIONS_PROCESSED_PATH)
    parser.add_argument("--weather", type=Path, default=WEATHER_RAW_PATH)
    parser.add_argument("--output", type=Path, default=TRAINING_DATASET_PATH)
    return parser.parse_args()


if __name__ == "__main__":
    configure_logging()
    args = parse_args()
    run(args.locations, args.weather, args.output)

