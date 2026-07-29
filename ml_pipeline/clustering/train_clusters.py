"""Entrena el modelo NO SUPERVISADO (K-Means) de FrostPuno.

Reemplaza al clasificador supervisado como artefacto productivo:
1. Agrupa observaciones climáticas de Puno en regímenes (clusters).
2. Perfila cada cluster y le asigna un nivel de riesgo de helada (alto/medio/bajo)
   ordenando por temperatura media (más frío => mayor riesgo).
3. Deriva la agrupación de distritos por riesgo a partir del cluster dominante.

Selección de k por silhouette; reporta también Davies-Bouldin e inercia (codo).
"""

from __future__ import annotations

import argparse
import logging
from pathlib import Path
from typing import Any

import joblib
import pandas as pd
from sklearn.cluster import KMeans
from sklearn.metrics import davies_bouldin_score, silhouette_score
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

from ml_pipeline.config import (
    CLUSTER_FEATURES,
    CLUSTER_INIT_OPTIONS,
    CLUSTER_K_RANGE,
    CLUSTER_N_INIT_OPTIONS,
    CLUSTER_METADATA_PATH,
    CLUSTER_MODEL_PATH,
    CLUSTER_PROFILES_PATH,
    CLUSTER_VERSION,
    DISTRICT_CLUSTERS_PATH,
    RISK_TIERS,
    TRAINING_DATASET_PATH,
)
from ml_pipeline.utils import (
    configure_logging,
    ensure_parent_dir,
    utc_now_iso,
    validate_columns,
    write_json,
)

LOGGER = logging.getLogger(__name__)
RANDOM_STATE = 42


def load_dataset(path: Path) -> pd.DataFrame:
    if not path.exists():
        raise FileNotFoundError(f"Training dataset not found: {path}")
    dataset = pd.read_csv(path)
    validate_columns(dataset, CLUSTER_FEATURES, path.name)
    return dataset.dropna(subset=CLUSTER_FEATURES)


def build_pipeline(k: int, init: str = "k-means++", n_init: int = 10) -> Pipeline:
    return Pipeline(
        steps=[
            ("scaler", StandardScaler()),
            (
                "kmeans",
                KMeans(
                    n_clusters=k,
                    init=init,
                    n_init=n_init,
                    random_state=RANDOM_STATE,
                ),
            ),
        ]
    )


def search_hyperparameters(
    features: pd.DataFrame,
    k_range: tuple[int, ...],
    init_options: tuple[str, ...] = CLUSTER_INIT_OPTIONS,
    n_init_options: tuple[int, ...] = CLUSTER_N_INIT_OPTIONS,
) -> tuple[dict[str, Any], list[dict[str, Any]], dict[int, dict[str, float]]]:
    """Grid search sobre k x init x n_init maximizando silhouette.

    Devuelve (mejores_params, grid_completo, metricas_por_k). El grid completo se
    persiste en el metadata como evidencia de hiperparámetros optimizados.
    """
    grid: list[dict[str, Any]] = []
    best_by_k: dict[int, dict[str, float]] = {}

    for k in k_range:
        if k >= len(features):
            LOGGER.warning("Skipping k=%d (>= n_samples=%d)", k, len(features))
            continue
        for init in init_options:
            for n_init in n_init_options:
                pipeline = build_pipeline(k, init=init, n_init=n_init)
                labels = pipeline.fit_predict(features)
                scaled = pipeline.named_steps["scaler"].transform(features)
                metrics = {
                    "silhouette": float(silhouette_score(scaled, labels)),
                    "davies_bouldin": float(davies_bouldin_score(scaled, labels)),
                    "inertia": float(pipeline.named_steps["kmeans"].inertia_),
                }
                grid.append({"k": k, "init": init, "n_init": n_init, **metrics})
                LOGGER.info(
                    "k=%d init=%s n_init=%d -> silhouette=%.4f db=%.4f",
                    k,
                    init,
                    n_init,
                    metrics["silhouette"],
                    metrics["davies_bouldin"],
                )
                # Mejor configuración observada para cada k (curva del codo/silhouette).
                if k not in best_by_k or metrics["silhouette"] > best_by_k[k]["silhouette"]:
                    best_by_k[k] = metrics

    if not grid:
        raise ValueError("No valid hyperparameter combination evaluated; dataset too small.")

    best = max(grid, key=lambda row: row["silhouette"])
    return best, grid, best_by_k


def assign_tiers(profiles: pd.DataFrame) -> dict[int, str]:
    """Ordena clusters por temperatura media ascendente (más frío = mayor riesgo)."""
    ordered = profiles.sort_values("temperature_2m", ascending=True).index.tolist()
    k = len(ordered)
    tier_map: dict[int, str] = {}
    for rank, cluster_id in enumerate(ordered):
        fraction = rank / (k - 1) if k > 1 else 0.0
        if fraction <= 1 / 3:
            tier = RISK_TIERS[0]  # alto (más frío)
        elif fraction <= 2 / 3:
            tier = RISK_TIERS[1]  # medio
        else:
            tier = RISK_TIERS[2]  # bajo
        tier_map[int(cluster_id)] = tier
    return tier_map


def profile_clusters(features: pd.DataFrame, labels: pd.Series) -> pd.DataFrame:
    frame = features.copy()
    frame["cluster"] = labels
    profiles = frame.groupby("cluster")[CLUSTER_FEATURES].mean()
    profiles["size"] = frame.groupby("cluster").size()
    return profiles


def district_groupings(dataset: pd.DataFrame, labels: pd.Series, tier_map: dict[int, str]) -> pd.DataFrame:
    frame = dataset.copy()
    frame["cluster"] = labels.to_numpy()
    frame["tier"] = frame["cluster"].map(tier_map)
    high_risk = {cid for cid, tier in tier_map.items() if tier == RISK_TIERS[0]}

    rows: list[dict[str, Any]] = []
    for distrito, group in frame.groupby("distrito"):
        dominant_cluster = int(group["cluster"].mode().iloc[0])
        rows.append(
            {
                "distrito": distrito,
                "ubigeo": group["ubigeo"].iloc[0] if "ubigeo" in group else None,
                "latitud": float(group["latitud"].iloc[0]) if "latitud" in group else None,
                "longitud": float(group["longitud"].iloc[0]) if "longitud" in group else None,
                "altitud_estimada": float(group["altitud_estimada"].iloc[0]),
                "dominant_cluster": dominant_cluster,
                "tier": tier_map[dominant_cluster],
                "cold_share": float(group["cluster"].isin(high_risk).mean()),
                "temperature_2m_mean": float(group["temperature_2m"].mean()),
                "observations": int(len(group)),
            }
        )
    return pd.DataFrame(rows).sort_values("cold_share", ascending=False).reset_index(drop=True)


def run(dataset_path: Path, k_range: tuple[int, ...], version: str) -> None:
    dataset = load_dataset(dataset_path)
    features = dataset[CLUSTER_FEATURES]

    best_params, grid, k_scores = search_hyperparameters(features, k_range)
    best_k = int(best_params["k"])
    LOGGER.info(
        "Selected k=%d init=%s n_init=%d by silhouette=%.4f (grid of %d combos).",
        best_k,
        best_params["init"],
        best_params["n_init"],
        best_params["silhouette"],
        len(grid),
    )

    pipeline = build_pipeline(
        best_k,
        init=str(best_params["init"]),
        n_init=int(best_params["n_init"]),
    )
    labels = pd.Series(pipeline.fit_predict(features), index=features.index, name="cluster")

    profiles = profile_clusters(features, labels)
    tier_map = assign_tiers(profiles)
    profiles["tier"] = profiles.index.map(tier_map)

    districts = district_groupings(dataset, labels, tier_map)

    # Persist artefactos
    ensure_parent_dir(CLUSTER_MODEL_PATH)
    joblib.dump(pipeline, CLUSTER_MODEL_PATH)
    ensure_parent_dir(CLUSTER_PROFILES_PATH)
    profiles.to_csv(CLUSTER_PROFILES_PATH)
    ensure_parent_dir(DISTRICT_CLUSTERS_PATH)
    districts.to_csv(DISTRICT_CLUSTERS_PATH, index=False)

    metadata = {
        "model_name": "KMeans",
        "version": version,
        "created_at": utc_now_iso(),
        "features": CLUSTER_FEATURES,
        "target": "cluster_risk_tier",
        "n_clusters": int(best_k),
        "metrics": {
            "silhouette": float(best_params["silhouette"]),
            "davies_bouldin": float(best_params["davies_bouldin"]),
            "inertia": float(best_params["inertia"]),
        },
        # Hiperparámetros optimizados por grid search (evidencia para el informe).
        "best_params": {
            "n_clusters": best_k,
            "init": best_params["init"],
            "n_init": int(best_params["n_init"]),
            "scaler": "StandardScaler",
            "random_state": RANDOM_STATE,
        },
        "hyperparameter_search": {
            "criterion": "silhouette",
            "grid": {
                "k": list(k_range),
                "init": list(CLUSTER_INIT_OPTIONS),
                "n_init": list(CLUSTER_N_INIT_OPTIONS),
            },
            "combinations_evaluated": len(grid),
            "results": grid,
        },
        "all_k_metrics": {str(k): v for k, v in k_scores.items()},
        "dataset_size": int(len(dataset)),
        "cluster_tiers": {str(cid): tier for cid, tier in tier_map.items()},
        "cluster_profiles": {
            str(cid): {
                **{feat: float(profiles.loc[cid, feat]) for feat in CLUSTER_FEATURES},
                "size": int(profiles.loc[cid, "size"]),
                "tier": tier_map[cid],
            }
            for cid in profiles.index
        },
        "data_sources": [
            "Open-Meteo Historical/Forecast API",
            "INEI-compatible curated district seed for Puno MVP",
            "SENAMHI documented as prioritized official source (no stable public API in MVP)",
        ],
        "limitations": [
            "Modelo no supervisado: los niveles de riesgo se derivan del perfil térmico de cada cluster, no de etiquetas oficiales.",
            "La semilla de distritos INEI es un MVP y debe reemplazarse por exportes oficiales para producción.",
            "SENAMHI aún no aporta observaciones de campo como validación cruzada del clustering.",
        ],
    }
    write_json(CLUSTER_METADATA_PATH, metadata)
    LOGGER.info(
        "Saved cluster model to %s, metadata to %s, district groupings to %s",
        CLUSTER_MODEL_PATH,
        CLUSTER_METADATA_PATH,
        DISTRICT_CLUSTERS_PATH,
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Train FrostPuno unsupervised K-Means model.")
    parser.add_argument("--dataset", type=Path, default=TRAINING_DATASET_PATH)
    parser.add_argument("--version", default=CLUSTER_VERSION)
    return parser.parse_args()


if __name__ == "__main__":
    configure_logging()
    args = parse_args()
    run(args.dataset, CLUSTER_K_RANGE, args.version)
