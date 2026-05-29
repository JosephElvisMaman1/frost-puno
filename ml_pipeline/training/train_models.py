from __future__ import annotations

import argparse
import logging
from pathlib import Path
from typing import Any

import joblib
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, f1_score, precision_score, recall_score
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier

from ml_pipeline.config import (
    METRICS_COMPARISON_PATH,
    MODEL_METADATA_PATH,
    MODEL_PATH,
    NUMERIC_FEATURES,
    TARGET_COLUMN,
    TRAINING_DATASET_PATH,
)
from ml_pipeline.utils import configure_logging, ensure_parent_dir, utc_now_iso, validate_columns, write_json


LOGGER = logging.getLogger(__name__)
RANDOM_STATE = 42


def load_dataset(path: Path) -> pd.DataFrame:
    if not path.exists():
        raise FileNotFoundError(f"Training dataset not found: {path}")

    dataset = pd.read_csv(path)
    validate_columns(dataset, [*NUMERIC_FEATURES, TARGET_COLUMN], "frost_training_dataset.csv")
    return dataset.dropna(subset=[*NUMERIC_FEATURES, TARGET_COLUMN])


def split_dataset(dataset: pd.DataFrame, test_size: float) -> tuple[pd.DataFrame, pd.DataFrame, pd.Series, pd.Series]:
    x = dataset[NUMERIC_FEATURES]
    y = dataset[TARGET_COLUMN]
    class_counts = y.value_counts()
    stratify = y if len(class_counts) > 1 and class_counts.min() >= 2 else None
    return train_test_split(x, y, test_size=test_size, random_state=RANDOM_STATE, stratify=stratify)


def build_preprocessor(scale: bool) -> ColumnTransformer:
    steps: list[tuple[str, Any]] = [("imputer", SimpleImputer(strategy="median"))]
    if scale:
        steps.append(("scaler", StandardScaler()))
    numeric_pipeline = Pipeline(steps=steps)
    return ColumnTransformer(transformers=[("numeric", numeric_pipeline, NUMERIC_FEATURES)])


def candidate_models() -> dict[str, Pipeline]:
    return {
        "LogisticRegression": Pipeline(
            steps=[
                ("preprocess", build_preprocessor(scale=True)),
                (
                    "model",
                    LogisticRegression(max_iter=1000, class_weight="balanced", random_state=RANDOM_STATE),
                ),
            ]
        ),
        "DecisionTreeClassifier": Pipeline(
            steps=[
                ("preprocess", build_preprocessor(scale=False)),
                (
                    "model",
                    DecisionTreeClassifier(max_depth=6, class_weight="balanced", random_state=RANDOM_STATE),
                ),
            ]
        ),
        "RandomForestClassifier": Pipeline(
            steps=[
                ("preprocess", build_preprocessor(scale=False)),
                (
                    "model",
                    RandomForestClassifier(
                        n_estimators=150,
                        max_depth=10,
                        class_weight="balanced",
                        random_state=RANDOM_STATE,
                        n_jobs=-1,
                    ),
                ),
            ]
        ),
    }


def evaluate_predictions(y_true: pd.Series, y_pred: pd.Series | list[str]) -> dict[str, float]:
    return {
        "accuracy": float(accuracy_score(y_true, y_pred)),
        "precision_macro": float(precision_score(y_true, y_pred, average="macro", zero_division=0)),
        "recall_macro": float(recall_score(y_true, y_pred, average="macro", zero_division=0)),
        "f1_macro": float(f1_score(y_true, y_pred, average="macro", zero_division=0)),
    }


def train_and_compare(dataset: pd.DataFrame, test_size: float) -> tuple[str, Pipeline, dict[str, dict[str, float]]]:
    x_train, x_test, y_train, y_test = split_dataset(dataset, test_size=test_size)
    metrics: dict[str, dict[str, float]] = {}
    trained_models: dict[str, Pipeline] = {}

    for name, model in candidate_models().items():
        LOGGER.info("Training %s", name)
        model.fit(x_train, y_train)
        predictions = model.predict(x_test)
        metrics[name] = evaluate_predictions(y_test, predictions)
        trained_models[name] = model
        LOGGER.info("%s metrics: %s", name, metrics[name])

    tie_break_priority = {
        "RandomForestClassifier": 3,
        "DecisionTreeClassifier": 2,
        "LogisticRegression": 1,
    }
    best_model_name = max(
        metrics,
        key=lambda model_name: (metrics[model_name]["f1_macro"], tie_break_priority.get(model_name, 0)),
    )
    return best_model_name, trained_models[best_model_name], metrics


def save_registry(
    model_name: str,
    model: Pipeline,
    metrics: dict[str, dict[str, float]],
    dataset: pd.DataFrame,
    version: str,
) -> None:
    ensure_parent_dir(MODEL_PATH)
    joblib.dump(model, MODEL_PATH)
    write_json(METRICS_COMPARISON_PATH, metrics)

    metadata = {
        "model_name": model_name,
        "version": version,
        "created_at": utc_now_iso(),
        "features": NUMERIC_FEATURES,
        "target": TARGET_COLUMN,
        "metrics": metrics[model_name],
        "all_model_metrics": metrics,
        "dataset_size": int(len(dataset)),
        "data_sources": [
            "Open-Meteo Historical API",
            "INEI-compatible curated district seed for Puno MVP",
            "SENAMHI documented for validation in phase 2",
            "MIDAGRI/SIEA documented as agrarian enrichment in phase 2",
        ],
        "limitations": [
            "Initial labels are rule-based and derived from temperature thresholds.",
            "The curated INEI district file is an MVP seed and must be replaced with official exports for production.",
            "Daily minimum temperature and hours below zero are label-derived features, so baseline metrics can be optimistic.",
            "SENAMHI station observations are not yet used as ground-truth labels.",
        ],
    }
    write_json(MODEL_METADATA_PATH, metadata)
    LOGGER.info("Saved best model to %s and metadata to %s", MODEL_PATH, MODEL_METADATA_PATH)


def run(dataset_path: Path, version: str, test_size: float) -> None:
    dataset = load_dataset(dataset_path)
    best_model_name, best_model, metrics = train_and_compare(dataset, test_size=test_size)
    save_registry(best_model_name, best_model, metrics, dataset, version=version)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Train and compare FrostPuno ML models.")
    parser.add_argument("--dataset", type=Path, default=TRAINING_DATASET_PATH)
    parser.add_argument("--version", default="v0.1.0")
    parser.add_argument("--test-size", type=float, default=0.25)
    return parser.parse_args()


if __name__ == "__main__":
    configure_logging()
    args = parse_args()
    run(args.dataset, args.version, args.test_size)
