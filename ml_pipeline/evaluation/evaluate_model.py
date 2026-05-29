from __future__ import annotations

import argparse
import json
import logging
from pathlib import Path

import joblib
import pandas as pd
from sklearn.metrics import confusion_matrix

from ml_pipeline.config import (
    CONFUSION_MATRIX_PATH,
    EVALUATION_REPORT_PATH,
    MODEL_METADATA_PATH,
    MODEL_PATH,
    NUMERIC_FEATURES,
    TARGET_COLUMN,
    TRAINING_DATASET_PATH,
)
from ml_pipeline.training.train_models import evaluate_predictions, split_dataset
from ml_pipeline.utils import configure_logging, ensure_parent_dir, validate_columns, write_json


LOGGER = logging.getLogger(__name__)
LABEL_ORDER = ["bajo", "medio", "alto"]


def load_metadata(path: Path) -> dict:
    if not path.exists():
        raise FileNotFoundError(f"Model metadata not found: {path}")
    return json.loads(path.read_text(encoding="utf-8"))


def run(dataset_path: Path, model_path: Path, metadata_path: Path) -> None:
    if not model_path.exists():
        raise FileNotFoundError(f"Model file not found: {model_path}")
    if not dataset_path.exists():
        raise FileNotFoundError(f"Dataset file not found: {dataset_path}")

    dataset = pd.read_csv(dataset_path)
    validate_columns(dataset, [*NUMERIC_FEATURES, TARGET_COLUMN], "frost_training_dataset.csv")
    metadata = load_metadata(metadata_path)
    model = joblib.load(model_path)

    _, x_test, _, y_test = split_dataset(dataset, test_size=0.25)
    predictions = model.predict(x_test)
    metrics = evaluate_predictions(y_test, predictions)
    matrix = confusion_matrix(y_test, predictions, labels=LABEL_ORDER)

    ensure_parent_dir(CONFUSION_MATRIX_PATH)
    pd.DataFrame(matrix, index=LABEL_ORDER, columns=LABEL_ORDER).to_csv(CONFUSION_MATRIX_PATH)

    report = {
        "model_name": metadata.get("model_name"),
        "version": metadata.get("version"),
        "features": NUMERIC_FEATURES,
        "target": TARGET_COLUMN,
        "metrics": metrics,
        "label_order": LABEL_ORDER,
        "confusion_matrix_path": str(CONFUSION_MATRIX_PATH),
    }
    write_json(EVALUATION_REPORT_PATH, report)
    LOGGER.info("Evaluation report saved to %s", EVALUATION_REPORT_PATH)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Evaluate the registered FrostPuno model.")
    parser.add_argument("--dataset", type=Path, default=TRAINING_DATASET_PATH)
    parser.add_argument("--model", type=Path, default=MODEL_PATH)
    parser.add_argument("--metadata", type=Path, default=MODEL_METADATA_PATH)
    return parser.parse_args()


if __name__ == "__main__":
    configure_logging()
    args = parse_args()
    run(args.dataset, args.model, args.metadata)

