from __future__ import annotations

import argparse
import logging
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import date, timedelta
from pathlib import Path
from typing import Any

import pandas as pd
import requests

from ml_pipeline.config import (
    LOCATIONS_PROCESSED_PATH,
    OPEN_METEO_HOURLY_VARIABLES,
    WEATHER_RAW_PATH,
)
from ml_pipeline.utils import configure_logging, ensure_parent_dir, validate_columns


LOGGER = logging.getLogger(__name__)
ARCHIVE_URL = "https://archive-api.open-meteo.com/v1/archive"


def default_date_range() -> tuple[str, str]:
    end = date.today() - timedelta(days=5)
    start = end - timedelta(days=13)
    return start.isoformat(), end.isoformat()


def load_locations(path: Path, limit: int | None = None) -> pd.DataFrame:
    if not path.exists():
        raise FileNotFoundError(f"Processed locations file not found: {path}")

    locations = pd.read_csv(path, dtype={"ubigeo": str})
    validate_columns(
        locations,
        ["ubigeo", "departamento", "provincia", "distrito", "latitud", "longitud"],
        "locations_puno.csv",
    )
    if limit is not None:
        locations = locations.head(limit)
    return locations


def fetch_weather_for_location(location: dict[str, Any], start_date: str, end_date: str) -> pd.DataFrame:
    params = {
        "latitude": location["latitud"],
        "longitude": location["longitud"],
        "start_date": start_date,
        "end_date": end_date,
        "hourly": ",".join(OPEN_METEO_HOURLY_VARIABLES),
        "timezone": "America/Lima",
        "temperature_unit": "celsius",
        "wind_speed_unit": "kmh",
        "precipitation_unit": "mm",
    }
    response = requests.get(ARCHIVE_URL, params=params, timeout=60)
    response.raise_for_status()
    payload = response.json()

    hourly = payload.get("hourly")
    if not hourly or "time" not in hourly:
        raise ValueError(f"Open-Meteo response has no hourly data for ubigeo={location['ubigeo']}")

    weather = pd.DataFrame(hourly)
    weather["ubigeo"] = location["ubigeo"]
    weather["departamento"] = location["departamento"]
    weather["provincia"] = location["provincia"]
    weather["distrito"] = location["distrito"]
    weather["latitud"] = location["latitud"]
    weather["longitud"] = location["longitud"]
    weather["data_source"] = "Open-Meteo Historical API"
    return weather


def fetch_weather_batch(
    locations: pd.DataFrame,
    start_date: str,
    end_date: str,
    max_workers: int,
) -> pd.DataFrame:
    frames: list[pd.DataFrame] = []
    failures: list[str] = []

    records = locations.to_dict(orient="records")
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {
            executor.submit(fetch_weather_for_location, record, start_date, end_date): record
            for record in records
        }
        for future in as_completed(futures):
            record = futures[future]
            try:
                frame = future.result()
                frames.append(frame)
                LOGGER.info("Fetched weather for %s - %s", record["ubigeo"], record["distrito"])
            except Exception as exc:  # noqa: BLE001 - keep batch failures visible by location.
                message = f"{record['ubigeo']} {record['distrito']}: {exc}"
                failures.append(message)
                LOGGER.error("Weather fetch failed for %s", message)

    if not frames:
        raise RuntimeError(f"No weather data fetched. Failures: {failures}")
    if failures:
        LOGGER.warning("Weather fetch completed with %s failures.", len(failures))

    return pd.concat(frames, ignore_index=True)


def save_weather(weather: pd.DataFrame, output_path: Path) -> None:
    ensure_parent_dir(output_path)
    weather.to_csv(output_path, index=False)
    LOGGER.info("Saved %s weather rows to %s", len(weather), output_path)


def run(
    locations_path: Path,
    output_path: Path,
    start_date: str,
    end_date: str,
    max_workers: int,
    limit: int | None,
) -> None:
    locations = load_locations(locations_path, limit=limit)
    weather = fetch_weather_batch(locations, start_date, end_date, max_workers=max_workers)
    save_weather(weather, output_path)


def parse_args() -> argparse.Namespace:
    start_date, end_date = default_date_range()
    parser = argparse.ArgumentParser(description="Fetch hourly weather from Open-Meteo for Puno districts.")
    parser.add_argument("--locations", type=Path, default=LOCATIONS_PROCESSED_PATH)
    parser.add_argument("--output", type=Path, default=WEATHER_RAW_PATH)
    parser.add_argument("--start-date", default=start_date)
    parser.add_argument("--end-date", default=end_date)
    parser.add_argument("--max-workers", type=int, default=4)
    parser.add_argument("--limit", type=int, default=None, help="Optional number of locations for quick smoke runs.")
    return parser.parse_args()


if __name__ == "__main__":
    configure_logging()
    args = parse_args()
    run(args.locations, args.output, args.start_date, args.end_date, args.max_workers, args.limit)

