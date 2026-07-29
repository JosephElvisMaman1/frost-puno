"""Pruebas de funcionamiento del MANTENIMIENTO e INTEGRACIÓN CONTINUA.

Verifican que los flujos automatizados del elemento inteligente funcionan:

1. El reentrenamiento produce artefactos válidos y agrupa todos los distritos.
2. El quality gate APRUEBA el modelo productivo actual.
3. El quality gate BLOQUEA un modelo degradado (barrera real de la IC).
4. La metadata documenta los hiperparámetros optimizados (grid search).
"""

from __future__ import annotations

import json

import joblib
import pytest

from ml_pipeline.config import (
    CLUSTER_FEATURES,
    CLUSTER_METADATA_PATH,
    CLUSTER_MODEL_PATH,
    DISTRICT_CLUSTERS_PATH,
    RISK_TIERS,
)
from ml_pipeline.registry.check_cluster_quality import run as run_gate


@pytest.fixture(scope="module")
def metadata() -> dict:
    assert CLUSTER_METADATA_PATH.exists(), "Falta cluster_metadata.json: entrena el modelo primero."
    return json.loads(CLUSTER_METADATA_PATH.read_text(encoding="utf-8"))


def test_registry_artifacts_exist(metadata: dict) -> None:
    """El reentrenamiento deja modelo, metadata y agrupación de distritos."""
    assert CLUSTER_MODEL_PATH.exists()
    assert DISTRICT_CLUSTERS_PATH.exists()
    assert metadata["model_name"] == "KMeans"
    assert metadata["features"] == CLUSTER_FEATURES
    assert metadata["n_clusters"] >= 3


def test_model_loads_and_predicts(metadata: dict) -> None:
    """El artefacto serializado se puede cargar e inferir (contrato con el backend)."""
    import pandas as pd

    pipeline = joblib.load(CLUSTER_MODEL_PATH)
    sample = pd.DataFrame([{name: 0.0 for name in metadata["features"]}])
    cluster = int(pipeline.predict(sample)[0])
    assert 0 <= cluster < metadata["n_clusters"]


def test_district_groupings_cover_all_districts() -> None:
    """Cada distrito queda asignado a un tier de riesgo válido."""
    import pandas as pd

    districts = pd.read_csv(DISTRICT_CLUSTERS_PATH)
    assert len(districts) >= 13, "Se esperan al menos los 13 distritos del MVP."
    assert set(districts["tier"]).issubset(set(RISK_TIERS))
    assert districts["distrito"].is_unique


def test_hyperparameters_are_optimized(metadata: dict) -> None:
    """La metadata documenta la búsqueda de hiperparámetros (evidencia de optimización)."""
    search = metadata["hyperparameter_search"]
    assert search["criterion"] == "silhouette"
    assert search["combinations_evaluated"] >= 12
    best = metadata["best_params"]
    assert best["n_clusters"] == metadata["n_clusters"]
    assert best["init"] in search["grid"]["init"]
    # La configuración elegida es realmente la mejor del grid.
    best_row = max(search["results"], key=lambda r: r["silhouette"])
    assert best_row["k"] == best["n_clusters"]


def test_quality_gate_passes_for_production_model() -> None:
    """El gate aprueba el modelo actualmente en el registry."""
    assert run_gate(CLUSTER_METADATA_PATH, min_silhouette=0.35) == 0


def test_quality_gate_blocks_degraded_model(tmp_path, metadata: dict) -> None:
    """El gate DETIENE la integración si el modelo empeora (barrera de mantenimiento)."""
    degraded = dict(metadata)
    degraded["metrics"] = {"silhouette": 0.10, "davies_bouldin": 3.0, "inertia": 1.0}
    bad_path = tmp_path / "cluster_metadata.json"
    bad_path.write_text(json.dumps(degraded), encoding="utf-8")

    assert run_gate(bad_path, min_silhouette=0.35) == 1
