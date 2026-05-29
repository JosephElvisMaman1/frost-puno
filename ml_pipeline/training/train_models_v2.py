from __future__ import annotations

import argparse
import logging
from pathlib import Path
from typing import Any, Literal

import joblib
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestClassifier
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import confusion_matrix
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

from ml_pipeline.config import (
    CONFUSION_MATRIX_V2_PATH,
    LEAKAGE_FEATURES,
    METRICS_COMPARISON_V2_PATH,
    MODEL_METADATA_PATH,
    MODEL_METADATA_V2_PATH,
    MODEL_PATH,
    MODEL_V2_PATH,
    NUMERIC_FEATURES_V2,
    PROJECT_ROOT,
    TARGET_COLUMN,
    TRAINING_DATASET_PATH,
    TRAINING_DATASET_V2_PATH,
)
from ml_pipeline.features.build_features_v2 import build_dataset_v2
from ml_pipeline.training.train_models import RANDOM_STATE, evaluate_predictions
from ml_pipeline.utils import configure_logging, ensure_parent_dir, utc_now_iso, validate_columns, write_json


LOGGER = logging.getLogger(__name__)
LABEL_ORDER = ["bajo", "medio", "alto"]
SplitStrategy = Literal["district", "time"]


def repo_relative(path: Path) -> str:
    return path.relative_to(PROJECT_ROOT).as_posix()


def load_or_create_dataset_v2(source_path: Path, dataset_path: Path) -> pd.DataFrame:
    if dataset_path.exists():
        dataset = pd.read_csv(dataset_path)
    else:
        if not source_path.exists():
            raise FileNotFoundError(f"Source dataset not found: {source_path}")
        dataset = build_dataset_v2(pd.read_csv(source_path))
        ensure_parent_dir(dataset_path)
        dataset.to_csv(dataset_path, index=False)

    validate_columns(
        dataset,
        ["fecha", "time", "distrito", "ubigeo", *NUMERIC_FEATURES_V2, TARGET_COLUMN],
        dataset_path.name,
    )
    leaked = [column for column in LEAKAGE_FEATURES if column in dataset.columns]
    if leaked:
        raise ValueError(f"Dataset v2 contains leakage columns: {leaked}")
    return dataset.dropna(subset=[*NUMERIC_FEATURES_V2, TARGET_COLUMN])


def split_by_district(
    dataset: pd.DataFrame,
    test_size: float,
) -> tuple[pd.DataFrame, pd.DataFrame, pd.Series, pd.Series, dict[str, Any]]:
    districts = dataset["distrito"].dropna().drop_duplicates().sample(
        frac=1,
        random_state=RANDOM_STATE,
    )
    test_count = max(1, round(len(districts) * test_size))
    test_districts = set(districts.tail(test_count))
    train_districts = set(districts) - test_districts
    train = dataset[dataset["distrito"].isin(train_districts)].copy()
    test = dataset[dataset["distrito"].isin(test_districts)].copy()
    if train.empty or test.empty:
        raise ValueError("District split produced an empty train or test partition.")

    return (
        train[NUMERIC_FEATURES_V2],
        test[NUMERIC_FEATURES_V2],
        train[TARGET_COLUMN],
        test[TARGET_COLUMN],
        {
            "strategy": "district",
            "test_size": test_size,
            "train_districts": sorted(train_districts),
            "test_districts": sorted(test_districts),
            "train_rows": int(len(train)),
            "test_rows": int(len(test)),
        },
    )


def split_by_time(
    dataset: pd.DataFrame,
    test_size: float,
) -> tuple[pd.DataFrame, pd.DataFrame, pd.Series, pd.Series, dict[str, Any]]:
    dated = dataset.copy()
    dated["datetime"] = pd.to_datetime(dated["time"], errors="coerce")
    if dated["datetime"].isna().any():
        raise ValueError("Dataset v2 contains invalid timestamps.")
    ordered_dates = dated["datetime"].dt.date.drop_duplicates().sort_values()
    test_count = max(1, round(len(ordered_dates) * test_size))
    cutoff = set(ordered_dates.tail(test_count))
    train = dated[~dated["datetime"].dt.date.isin(cutoff)].copy()
    test = dated[dated["datetime"].dt.date.isin(cutoff)].copy()
    if train.empty or test.empty:
        raise ValueError("Time split produced an empty train or test partition.")

    return (
        train[NUMERIC_FEATURES_V2],
        test[NUMERIC_FEATURES_V2],
        train[TARGET_COLUMN],
        test[TARGET_COLUMN],
        {
            "strategy": "time",
            "test_size": test_size,
            "train_start": str(train["datetime"].min()),
            "train_end": str(train["datetime"].max()),
            "test_start": str(test["datetime"].min()),
            "test_end": str(test["datetime"].max()),
            "train_rows": int(len(train)),
            "test_rows": int(len(test)),
        },
    )


def split_dataset_v2(
    dataset: pd.DataFrame,
    strategy: SplitStrategy,
    test_size: float,
) -> tuple[pd.DataFrame, pd.DataFrame, pd.Series, pd.Series, dict[str, Any]]:
    if strategy == "district":
        return split_by_district(dataset, test_size)
    if strategy == "time":
        return split_by_time(dataset, test_size)
    raise ValueError(f"Unsupported split strategy: {strategy}")


def build_preprocessor(scale: bool) -> ColumnTransformer:
    steps: list[tuple[str, Any]] = [("imputer", SimpleImputer(strategy="median"))]
    if scale:
        steps.append(("scaler", StandardScaler()))
    numeric_pipeline = Pipeline(steps=steps)
    return ColumnTransformer(transformers=[("numeric", numeric_pipeline, NUMERIC_FEATURES_V2)])


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


def train_and_compare_v2(
    dataset: pd.DataFrame,
    strategy: SplitStrategy,
    test_size: float,
) -> tuple[str, Pipeline, dict[str, dict[str, float]], pd.Series, list[str], dict[str, Any]]:
    x_train, x_test, y_train, y_test, split_metadata = split_dataset_v2(dataset, strategy, test_size)
    LOGGER.info("Dataset v2 rows=%s", len(dataset))
    LOGGER.info("Dataset v2 features=%s", NUMERIC_FEATURES_V2)
    LOGGER.info("Split strategy=%s metadata=%s", strategy, split_metadata)

    metrics: dict[str, dict[str, float]] = {}
    trained_models: dict[str, Pipeline] = {}
    predictions_by_model: dict[str, list[str]] = {}
    for name, model in candidate_models().items():
        LOGGER.info("Training v0.2.0 candidate %s", name)
        model.fit(x_train, y_train)
        predictions = model.predict(x_test)
        predictions_by_model[name] = [str(item) for item in predictions]
        metrics[name] = evaluate_predictions(y_test, predictions)
        trained_models[name] = model
        LOGGER.info("%s v0.2.0 metrics: %s", name, metrics[name])

    best_model_name = "RandomForestClassifier"
    return (
        best_model_name,
        trained_models[best_model_name],
        metrics,
        y_test,
        predictions_by_model[best_model_name],
        split_metadata,
    )


def save_registry_v2(
    model_name: str,
    model: Pipeline,
    metrics: dict[str, dict[str, float]],
    y_test: pd.Series,
    predictions: list[str],
    dataset: pd.DataFrame,
    version: str,
    split_metadata: dict[str, Any],
) -> None:
    ensure_parent_dir(MODEL_V2_PATH)
    joblib.dump(model, MODEL_V2_PATH)
    write_json(METRICS_COMPARISON_V2_PATH, metrics)

    matrix = confusion_matrix(y_test, predictions, labels=LABEL_ORDER)
    ensure_parent_dir(CONFUSION_MATRIX_V2_PATH)
    pd.DataFrame(matrix, index=LABEL_ORDER, columns=LABEL_ORDER).to_csv(CONFUSION_MATRIX_V2_PATH)

    metadata = {
        "model_name": model_name,
        "version": version,
        "created_at": utc_now_iso(),
        "status": "experimental",
        "production_model_unchanged": True,
        "production_model_path": repo_relative(MODEL_PATH),
        "production_metadata_path": repo_relative(MODEL_METADATA_PATH),
        "model_path": repo_relative(MODEL_V2_PATH),
        "dataset_path": repo_relative(TRAINING_DATASET_V2_PATH),
        "features": NUMERIC_FEATURES_V2,
        "removed_leakage_features": LEAKAGE_FEATURES,
        "target": TARGET_COLUMN,
        "split": split_metadata,
        "metrics": metrics[model_name],
        "all_model_metrics": metrics,
        "selection_reason": "RandomForestClassifier is kept as the v0.2.0 baseline model; LogisticRegression is reported only for comparison.",
        "label_order": LABEL_ORDER,
        "confusion_matrix_path": repo_relative(CONFUSION_MATRIX_V2_PATH),
        "dataset_size": int(len(dataset)),
        "data_sources": [
            "Open-Meteo Historical API",
            "INEI-compatible curated district seed for Puno MVP",
        ],
        "limitations": [
            "Labels remain rule-based and are not official observed frost events.",
            "Leakage-derived features were removed from model inputs.",
            "District split estimates generalization to unseen districts, but still requires SENAMHI/campo ground truth.",
            "This model is experimental and is not used by FastAPI production endpoints.",
        ],
    }
    write_json(MODEL_METADATA_V2_PATH, metadata)
    LOGGER.info("Saved v0.2.0 model to %s", MODEL_V2_PATH)
    LOGGER.info("Saved v0.2.0 metadata to %s", MODEL_METADATA_V2_PATH)
    LOGGER.info("Saved v0.2.0 confusion matrix to %s", CONFUSION_MATRIX_V2_PATH)


def run(
    source_path: Path,
    dataset_path: Path,
    version: str,
    strategy: SplitStrategy,
    test_size: float,
) -> None:
    dataset = load_or_create_dataset_v2(source_path, dataset_path)
    best_model_name, best_model, metrics, y_test, predictions, split_metadata = train_and_compare_v2(
        dataset,
        strategy,
        test_size,
    )
    save_registry_v2(best_model_name, best_model, metrics, y_test, predictions, dataset, version, split_metadata)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Train FrostPuno v0.2.0 without leakage features.")
    parser.add_argument("--source", type=Path, default=TRAINING_DATASET_PATH)
    parser.add_argument("--dataset", type=Path, default=TRAINING_DATASET_V2_PATH)
    parser.add_argument("--version", default="v0.2.0")
    parser.add_argument("--split-strategy", choices=["district", "time"], default="district")
    parser.add_argument("--test-size", type=float, default=0.30)
    return parser.parse_args()


if __name__ == "__main__":
    configure_logging()
    args = parse_args()
    run(args.source, args.dataset, args.version, args.split_strategy, args.test_size)
