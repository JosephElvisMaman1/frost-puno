from __future__ import annotations

import argparse
import logging
from pathlib import Path
from typing import Any

import joblib
import pandas as pd
from sklearn.metrics import accuracy_score, confusion_matrix, f1_score, precision_score, recall_score

from ml_pipeline.config import (
    MODEL_METADATA_V2_PATH,
    MODEL_V2_PATH,
    NUMERIC_FEATURES_V2,
    OBSERVATION_EVALUATION_PATH,
    OBSERVATION_REQUIRED_COLUMNS,
    PROJECT_ROOT,
    SENAMHI_OBSERVATIONS_PATH,
)
from ml_pipeline.training.train_models_v2 import LABEL_ORDER
from ml_pipeline.utils import configure_logging, ensure_parent_dir, utc_now_iso, validate_columns, write_json


LOGGER = logging.getLogger(__name__)


def repo_relative(path: Path) -> str:
    return path.relative_to(PROJECT_ROOT).as_posix()


def load_observations(path: Path) -> pd.DataFrame:
    observations = pd.read_csv(path)
    validate_columns(observations, OBSERVATION_REQUIRED_COLUMNS, path.name)
    observations["datetime"] = pd.to_datetime(observations["observed_at"], errors="coerce")
    if observations["datetime"].isna().any():
        raise ValueError("Observation file contains invalid observed_at values.")
    observations["mes"] = observations["datetime"].dt.month
    observations["hora"] = observations["datetime"].dt.hour
    return observations.dropna(subset=[*NUMERIC_FEATURES_V2, "riesgo_helada_observado"])


def evaluate_observations(model_path: Path, observations_path: Path, output_path: Path) -> dict[str, Any]:
    LOGGER.info("Loading model=%s", model_path)
    LOGGER.info("Loading observed events=%s", observations_path)
    model = joblib.load(model_path)
    observations = load_observations(observations_path)

    y_true = observations["riesgo_helada_observado"].astype(str)
    y_pred = model.predict(observations[NUMERIC_FEATURES_V2])

    metrics = {
        "accuracy": float(accuracy_score(y_true, y_pred)),
        "precision_macro": float(precision_score(y_true, y_pred, average="macro", zero_division=0)),
        "recall_macro": float(recall_score(y_true, y_pred, average="macro", zero_division=0)),
        "f1_macro": float(f1_score(y_true, y_pred, average="macro", zero_division=0)),
    }
    matrix = confusion_matrix(y_true, y_pred, labels=LABEL_ORDER)
    mismatches = observations.assign(prediccion=y_pred)
    mismatches = mismatches[mismatches["riesgo_helada_observado"] != mismatches["prediccion"]]

    report: dict[str, Any] = {
        "created_at": utc_now_iso(),
        "status": "sample_validation",
        "model_path": repo_relative(model_path),
        "model_metadata_path": repo_relative(MODEL_METADATA_V2_PATH),
        "observations_path": repo_relative(observations_path),
        "rows": int(len(observations)),
        "features": NUMERIC_FEATURES_V2,
        "target": "riesgo_helada_observado",
        "metrics": metrics,
        "label_order": LABEL_ORDER,
        "confusion_matrix": matrix.tolist(),
        "mismatches": mismatches[
            ["observed_at", "distrito", "riesgo_helada_observado", "prediccion", "fuente_observacion"]
        ].to_dict(orient="records"),
        "limitations": [
            "This file is a schema/sample for official observation validation, not a complete SENAMHI extraction.",
            "Observed frost labels must be replaced with official SENAMHI/campo data before academic promotion.",
            "The result is used to decide whether a future model version should be retrained or rejected.",
        ],
    }
    ensure_parent_dir(output_path)
    write_json(output_path, report)
    LOGGER.info("Saved observation evaluation to %s", output_path)
    return report


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Evaluate FrostPuno v0.2.0 against observed frost events.")
    parser.add_argument("--model", type=Path, default=MODEL_V2_PATH)
    parser.add_argument("--observations", type=Path, default=SENAMHI_OBSERVATIONS_PATH)
    parser.add_argument("--output", type=Path, default=OBSERVATION_EVALUATION_PATH)
    return parser.parse_args()


if __name__ == "__main__":
    configure_logging()
    args = parse_args()
    evaluate_observations(args.model, args.observations, args.output)
