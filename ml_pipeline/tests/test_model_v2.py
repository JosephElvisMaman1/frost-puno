from __future__ import annotations

import pandas as pd

from ml_pipeline.config import LEAKAGE_FEATURES, NUMERIC_FEATURES_V2, TARGET_COLUMN
from ml_pipeline.evaluation.evaluate_observed_events import load_observations
from ml_pipeline.features.build_features_v2 import build_dataset_v2
from ml_pipeline.training.train_models_v2 import split_dataset_v2


def _sample_dataset() -> pd.DataFrame:
    rows = []
    districts = ["A", "B", "C", "D"]
    for index, district in enumerate(districts):
        for hour in range(4):
            rows.append(
                {
                    "fecha": f"2024-06-0{hour + 1}",
                    "time": f"2024-06-0{hour + 1}T0{hour}:00",
                    "distrito": district,
                    "ubigeo": f"210{index}",
                    "latitud": -15.0 - index,
                    "longitud": -70.0 - index,
                    "altitud_estimada": 3800 + index,
                    "temperature_2m": float(hour - 2),
                    "relative_humidity_2m": 70.0,
                    "apparent_temperature": float(hour - 3),
                    "dew_point_2m": -2.0,
                    "precipitation": 0.0,
                    "cloud_cover": 20.0,
                    "wind_speed_10m": 7.0,
                    "mes": 6,
                    "hora": hour,
                    "temperatura_minima_diaria": -2.0,
                    "horas_bajo_cero": 3,
                    "riesgo_helada": "alto" if hour < 2 else "medio",
                }
            )
    return pd.DataFrame(rows)


def test_dataset_v2_removes_leakage_features() -> None:
    dataset = build_dataset_v2(_sample_dataset())

    for column in LEAKAGE_FEATURES:
        assert column not in dataset.columns
    assert TARGET_COLUMN in dataset.columns
    assert set(NUMERIC_FEATURES_V2).issubset(dataset.columns)


def test_district_split_keeps_districts_disjoint() -> None:
    dataset = build_dataset_v2(_sample_dataset())

    x_train, x_test, y_train, y_test, metadata = split_dataset_v2(
        dataset,
        strategy="district",
        test_size=0.5,
    )

    assert not x_train.empty
    assert not x_test.empty
    assert not y_train.empty
    assert not y_test.empty
    assert set(metadata["train_districts"]).isdisjoint(metadata["test_districts"])


def test_time_split_uses_recent_dates_for_test() -> None:
    dataset = build_dataset_v2(_sample_dataset())

    _, _, y_train, y_test, metadata = split_dataset_v2(
        dataset,
        strategy="time",
        test_size=0.25,
    )

    assert not y_train.empty
    assert not y_test.empty
    assert metadata["strategy"] == "time"
    assert metadata["train_end"] < metadata["test_start"]


def test_observation_validation_adds_time_features(tmp_path) -> None:
    observations_path = tmp_path / "observations.csv"
    pd.DataFrame(
        [
            {
                "observed_at": "2024-06-01T03:00:00",
                "distrito": "Puno",
                "latitud": -15.8402,
                "longitud": -70.0219,
                "altitud_estimada": 3827,
                "temperature_2m": -2.1,
                "relative_humidity_2m": 71,
                "apparent_temperature": -3.8,
                "dew_point_2m": -4.0,
                "precipitation": 0,
                "cloud_cover": 18,
                "wind_speed_10m": 8,
                "riesgo_helada_observado": "alto",
                "fuente_observacion": "SENAMHI_sample",
            }
        ]
    ).to_csv(observations_path, index=False)

    observations = load_observations(observations_path)

    assert set(NUMERIC_FEATURES_V2).issubset(observations.columns)
    assert observations.loc[0, "mes"] == 6
    assert observations.loc[0, "hora"] == 3
