from __future__ import annotations

import argparse
import logging
from pathlib import Path

import pandas as pd

from ml_pipeline.config import (
    LOCATIONS_EXTERNAL_PATH,
    LOCATIONS_PROCESSED_PATH,
    REQUIRED_LOCATION_COLUMNS,
)
from ml_pipeline.utils import configure_logging, ensure_parent_dir, validate_columns


LOGGER = logging.getLogger(__name__)


def load_locations(input_path: Path) -> pd.DataFrame:
    if not input_path.exists():
        raise FileNotFoundError(f"Location file not found: {input_path}")

    locations = pd.read_csv(input_path, dtype={"ubigeo": str})
    validate_columns(locations, REQUIRED_LOCATION_COLUMNS, "inei_puno_districts.csv")
    return locations


def clean_locations(locations: pd.DataFrame) -> pd.DataFrame:
    cleaned = locations.copy()
    cleaned["ubigeo"] = cleaned["ubigeo"].astype(str).str.zfill(6)

    text_columns = ["departamento", "provincia", "distrito"]
    for column in text_columns:
        cleaned[column] = cleaned[column].astype(str).str.strip()

    numeric_columns = [
        "latitud",
        "longitud",
        "altitud_estimada",
        "poblacion_total",
        "poblacion_rural",
        "porcentaje_rural",
    ]
    for column in numeric_columns:
        cleaned[column] = pd.to_numeric(cleaned[column], errors="coerce")

    if cleaned[numeric_columns].isna().any().any():
        bad_columns = cleaned[numeric_columns].columns[cleaned[numeric_columns].isna().any()].tolist()
        raise ValueError(f"Location file has invalid numeric values in columns: {bad_columns}")

    if not cleaned["latitud"].between(-18.5, -13.0).all():
        raise ValueError("Some latitudes are outside the expected range for Puno.")
    if not cleaned["longitud"].between(-71.5, -68.0).all():
        raise ValueError("Some longitudes are outside the expected range for Puno.")
    if not cleaned["porcentaje_rural"].between(0, 100).all():
        raise ValueError("porcentaje_rural must be between 0 and 100.")

    return cleaned.drop_duplicates(subset=["ubigeo"]).sort_values(["provincia", "distrito"])


def save_locations(locations: pd.DataFrame, output_path: Path) -> None:
    ensure_parent_dir(output_path)
    locations.to_csv(output_path, index=False)
    LOGGER.info("Saved %s locations to %s", len(locations), output_path)


def run(input_path: Path, output_path: Path) -> None:
    locations = load_locations(input_path)
    cleaned = clean_locations(locations)
    save_locations(cleaned, output_path)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate and process Puno district locations.")
    parser.add_argument("--input", type=Path, default=LOCATIONS_EXTERNAL_PATH)
    parser.add_argument("--output", type=Path, default=LOCATIONS_PROCESSED_PATH)
    return parser.parse_args()


if __name__ == "__main__":
    configure_logging()
    args = parse_args()
    run(args.input, args.output)

