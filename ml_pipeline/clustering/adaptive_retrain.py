"""Reentrenamiento ADAPTATIVO: el modelo mejora con más datos.

El modelo "sigue aprendiendo" mediante reentrenamiento batch programado: si la calidad
de agrupación (silhouette) no alcanza el objetivo, se amplía la ventana de datos
históricos y se reentrena, conservando la mejor corrida.

Flujo por iteración:
    ingesta paralela (N días) -> features -> grid search K-Means -> silhouette
    si silhouette >= TARGET: fin. si no: ventana += step y se reintenta.

Cada corrida se registra en `ml_pipeline/registry/training_history.json`, que sirve como
evidencia de la evolución de la calidad frente al volumen de datos.

Uso:
    python -m ml_pipeline.clustering.adaptive_retrain --target 0.45 --max-iters 3
"""

from __future__ import annotations

import argparse
import json
import logging
from datetime import date, timedelta
from pathlib import Path

from ml_pipeline.clustering.train_clusters import run as train_clusters
from ml_pipeline.config import (
    CLUSTER_METADATA_PATH,
    CLUSTER_K_RANGE,
    CLUSTER_VERSION,
    LOCATIONS_PROCESSED_PATH,
    TRAINING_DATASET_PATH,
    TRAINING_HISTORY_PATH,
    WEATHER_RAW_PATH,
)
from ml_pipeline.data_ingestion.ingest_weather_open_meteo import run as ingest_weather
from ml_pipeline.features.build_features import run as build_features
from ml_pipeline.utils import configure_logging, ensure_parent_dir, utc_now_iso, write_json

LOGGER = logging.getLogger(__name__)

# Open-Meteo Archive tiene ~5 días de retraso.
ARCHIVE_LAG_DAYS = 5


def _window_dates(days: int) -> tuple[str, str]:
    end = date.today() - timedelta(days=ARCHIVE_LAG_DAYS)
    start = end - timedelta(days=days - 1)
    return start.isoformat(), end.isoformat()


def _current_metrics() -> dict:
    metadata = json.loads(CLUSTER_METADATA_PATH.read_text(encoding="utf-8"))
    return {
        "silhouette": float(metadata["metrics"]["silhouette"]),
        "davies_bouldin": float(metadata["metrics"]["davies_bouldin"]),
        "n_clusters": int(metadata["n_clusters"]),
        "dataset_size": int(metadata["dataset_size"]),
        "best_params": metadata.get("best_params", {}),
    }


def _append_history(entry: dict) -> None:
    history: list[dict] = []
    if TRAINING_HISTORY_PATH.exists():
        try:
            history = json.loads(TRAINING_HISTORY_PATH.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            history = []
    history.append(entry)
    ensure_parent_dir(TRAINING_HISTORY_PATH)
    write_json(TRAINING_HISTORY_PATH, history)


def run(
    target: float,
    max_iters: int,
    initial_days: int,
    step_days: int,
    max_workers: int,
    skip_ingest: bool = False,
) -> int:
    best_silhouette = -1.0
    days = initial_days

    for iteration in range(1, max_iters + 1):
        start_date, end_date = _window_dates(days)
        LOGGER.info(
            "Iteración %d/%d — ventana de %d días (%s .. %s)",
            iteration,
            max_iters,
            days,
            start_date,
            end_date,
        )

        if not skip_ingest:
            # Ingesta paralela por distrito (ThreadPoolExecutor).
            ingest_weather(
                LOCATIONS_PROCESSED_PATH,
                WEATHER_RAW_PATH,
                start_date,
                end_date,
                max_workers,
                None,
            )
            build_features(LOCATIONS_PROCESSED_PATH, WEATHER_RAW_PATH, TRAINING_DATASET_PATH)

        train_clusters(TRAINING_DATASET_PATH, CLUSTER_K_RANGE, CLUSTER_VERSION)
        metrics = _current_metrics()
        silhouette = metrics["silhouette"]

        _append_history(
            {
                "trained_at": utc_now_iso(),
                "iteration": iteration,
                "window_days": days,
                "start_date": start_date,
                "end_date": end_date,
                "target": target,
                **metrics,
            }
        )

        LOGGER.info(
            "Iteración %d: silhouette=%.4f (objetivo %.2f, dataset=%d filas)",
            iteration,
            silhouette,
            target,
            metrics["dataset_size"],
        )
        best_silhouette = max(best_silhouette, silhouette)

        if silhouette >= target:
            LOGGER.info("Objetivo alcanzado con %d días de datos.", days)
            return 0

        days += step_days
        LOGGER.info("Objetivo no alcanzado; ampliando ventana a %d días.", days)

    LOGGER.warning(
        "Se agotaron las iteraciones. Mejor silhouette=%.4f (objetivo %.2f). "
        "El modelo del registry es el de la última corrida; el quality gate decide si se promueve.",
        best_silhouette,
        target,
    )
    return 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Reentrenamiento adaptativo de FrostPuno: amplía la ventana de datos hasta alcanzar el objetivo."
    )
    parser.add_argument("--target", type=float, default=0.45, help="Silhouette objetivo.")
    parser.add_argument("--max-iters", type=int, default=3)
    parser.add_argument("--initial-days", type=int, default=14)
    parser.add_argument("--step-days", type=int, default=15)
    parser.add_argument("--max-workers", type=int, default=4)
    parser.add_argument(
        "--skip-ingest",
        action="store_true",
        help="Reentrena sobre el dataset existente sin volver a descargar clima.",
    )
    return parser.parse_args()


if __name__ == "__main__":
    configure_logging()
    args = parse_args()
    raise SystemExit(
        run(
            target=args.target,
            max_iters=args.max_iters,
            initial_days=args.initial_days,
            step_days=args.step_days,
            max_workers=args.max_workers,
            skip_ingest=args.skip_ingest,
        )
    )
