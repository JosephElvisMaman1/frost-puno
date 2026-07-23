"""Quality gate NO SUPERVISADO: bloquea modelos de clustering bajo el umbral de silhouette.

Reemplaza a check_model_quality.py (f1_macro) en el path productivo.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path


DEFAULT_METADATA_PATH = Path(__file__).resolve().parent / "cluster_metadata.json"


def load_silhouette(metadata_path: Path) -> float:
    if not metadata_path.exists():
        raise FileNotFoundError(f"Cluster metadata not found: {metadata_path}")

    metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
    metrics = metadata.get("metrics")
    if not isinstance(metrics, dict):
        raise ValueError("cluster_metadata.json must contain a metrics object.")

    silhouette = metrics.get("silhouette")
    if silhouette is None:
        raise ValueError("cluster_metadata.json metrics must contain silhouette.")

    return float(silhouette)


def parse_threshold(cli_threshold: float | None) -> float:
    if cli_threshold is not None:
        return cli_threshold
    return float(os.getenv("MIN_SILHOUETTE", "0.35"))


def run(metadata_path: Path, min_silhouette: float) -> int:
    silhouette = load_silhouette(metadata_path)
    print(f"Cluster quality gate: silhouette={silhouette:.6f}, minimum={min_silhouette:.6f}")

    if silhouette < min_silhouette:
        print("QUALITY GATE FAILED: cluster silhouette is below the required threshold.")
        return 1

    print("QUALITY GATE PASSED: cluster silhouette meets the required threshold.")
    return 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate FrostPuno clustering quality metrics.")
    parser.add_argument("--metadata", type=Path, default=DEFAULT_METADATA_PATH)
    parser.add_argument("--min-silhouette", type=float, default=None)
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    try:
        sys.exit(run(args.metadata, parse_threshold(args.min_silhouette)))
    except Exception as exc:  # noqa: BLE001 - CLI should print clear failure and exit non-zero.
        print(f"QUALITY GATE ERROR: {exc}", file=sys.stderr)
        sys.exit(1)
