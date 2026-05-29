from __future__ import annotations

import argparse
import logging
from pathlib import Path

import pandas as pd

from ml_pipeline.config import NUMERIC_FEATURES, TARGET_COLUMN, TRAINING_DATASET_PATH
from ml_pipeline.utils import configure_logging, validate_columns


LOGGER = logging.getLogger(__name__)
EXPECTED_TARGETS = {"bajo", "medio", "alto"}


def validate_training_dataset(path: Path) -> None:
    if not path.exists():
        raise FileNotFoundError(f"Training dataset not found: {path}")

    dataset = pd.read_csv(path)
    validate_columns(dataset, [*NUMERIC_FEATURES, TARGET_COLUMN], "frost_training_dataset.csv")

    if dataset.empty:
        raise ValueError("Training dataset is empty.")

    missing = dataset[NUMERIC_FEATURES].isna().sum()
    critical_missing = missing[missing > 0]
    if not critical_missing.empty:
        raise ValueError(f"Training dataset has missing feature values: {critical_missing.to_dict()}")

    targets = set(dataset[TARGET_COLUMN].dropna().unique())
    unexpected = targets - EXPECTED_TARGETS
    if unexpected:
        raise ValueError(f"Unexpected target classes: {unexpected}")

    impossible_ranges = {
        "relative_humidity_2m": dataset["relative_humidity_2m"].between(0, 100).all(),
        "cloud_cover": dataset["cloud_cover"].between(0, 100).all(),
        "wind_speed_10m": (dataset["wind_speed_10m"] >= 0).all(),
        "precipitation": (dataset["precipitation"] >= 0).all(),
    }
    failed = [name for name, ok in impossible_ranges.items() if not ok]
    if failed:
        raise ValueError(f"Climate variables outside expected ranges: {failed}")

    LOGGER.info("Dataset validation passed: %s rows, classes=%s", len(dataset), sorted(targets))


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate Frost Puno training dataset.")
    parser.add_argument("--dataset", type=Path, default=TRAINING_DATASET_PATH)
    return parser.parse_args()


if __name__ == "__main__":
    configure_logging()
    args = parse_args()
    validate_training_dataset(args.dataset)

