from __future__ import annotations

import argparse
import logging
from pathlib import Path

import pandas as pd

from ml_pipeline.config import (
    LEAKAGE_FEATURES,
    NUMERIC_FEATURES_V2,
    TARGET_COLUMN,
    TRAINING_DATASET_PATH,
    TRAINING_DATASET_V2_PATH,
)
from ml_pipeline.utils import configure_logging, ensure_parent_dir, validate_columns


LOGGER = logging.getLogger(__name__)


REQUIRED_CONTEXT_COLUMNS = ["fecha", "time", "distrito", "ubigeo"]


def build_dataset_v2(source: pd.DataFrame) -> pd.DataFrame:
    validate_columns(
        source,
        [*REQUIRED_CONTEXT_COLUMNS, *NUMERIC_FEATURES_V2, TARGET_COLUMN],
        "frost_training_dataset.csv",
    )
    dataset = source[
        [*REQUIRED_CONTEXT_COLUMNS, *NUMERIC_FEATURES_V2, TARGET_COLUMN]
    ].copy()
    leaked = [column for column in LEAKAGE_FEATURES if column in dataset.columns]
    if leaked:
        raise ValueError(f"Dataset v2 still contains leakage columns: {leaked}")
    return dataset


def run(source_path: Path, output_path: Path) -> None:
    if not source_path.exists():
        raise FileNotFoundError(f"Source dataset not found: {source_path}")

    source = pd.read_csv(source_path)
    dataset = build_dataset_v2(source)
    ensure_parent_dir(output_path)
    dataset.to_csv(output_path, index=False)
    LOGGER.info("Dataset v2 source: %s", source_path)
    LOGGER.info("Dataset v2 output: %s", output_path)
    LOGGER.info("Dataset v2 shape: rows=%s columns=%s", len(dataset), len(dataset.columns))
    LOGGER.info("Dataset v2 features: %s", NUMERIC_FEATURES_V2)
    LOGGER.info("Dataset v2 class distribution: %s", dataset[TARGET_COLUMN].value_counts().to_dict())


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build FrostPuno dataset v2 without leakage features.")
    parser.add_argument("--source", type=Path, default=TRAINING_DATASET_PATH)
    parser.add_argument("--output", type=Path, default=TRAINING_DATASET_V2_PATH)
    return parser.parse_args()


if __name__ == "__main__":
    configure_logging()
    args = parse_args()
    run(args.source, args.output)
