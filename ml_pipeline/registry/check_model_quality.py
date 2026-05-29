from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path


DEFAULT_METADATA_PATH = Path(__file__).resolve().parent / "model_metadata.json"


def load_f1_macro(metadata_path: Path) -> float:
    if not metadata_path.exists():
        raise FileNotFoundError(f"Model metadata not found: {metadata_path}")

    metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
    metrics = metadata.get("metrics")
    if not isinstance(metrics, dict):
        raise ValueError("model_metadata.json must contain a metrics object.")

    f1_macro = metrics.get("f1_macro")
    if f1_macro is None:
        raise ValueError("model_metadata.json metrics must contain f1_macro.")

    return float(f1_macro)


def parse_threshold(cli_threshold: float | None) -> float:
    if cli_threshold is not None:
        return cli_threshold
    return float(os.getenv("MIN_F1_MACRO", "0.70"))


def run(metadata_path: Path, min_f1_macro: float) -> int:
    f1_macro = load_f1_macro(metadata_path)
    print(f"Model quality gate: f1_macro={f1_macro:.6f}, minimum={min_f1_macro:.6f}")

    if f1_macro < min_f1_macro:
        print("QUALITY GATE FAILED: model f1_macro is below the required threshold.")
        return 1

    print("QUALITY GATE PASSED: model f1_macro meets the required threshold.")
    return 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate Frost Puno model quality metrics.")
    parser.add_argument("--metadata", type=Path, default=DEFAULT_METADATA_PATH)
    parser.add_argument("--min-f1-macro", type=float, default=None)
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    try:
        sys.exit(run(args.metadata, parse_threshold(args.min_f1_macro)))
    except Exception as exc:  # noqa: BLE001 - CLI should print clear failure and exit non-zero.
        print(f"QUALITY GATE ERROR: {exc}", file=sys.stderr)
        sys.exit(1)

