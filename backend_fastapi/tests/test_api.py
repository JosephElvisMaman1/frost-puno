from __future__ import annotations

import httpx
from fastapi.testclient import TestClient

from app.main import app
from app.repositories.predictions import NoOpPredictionRepository
from app.repositories.supabase_prediction_repository import SupabasePredictionRepository
from app.schemas.prediction import FrostRiskRequest, FrostRiskResponse


client = TestClient(app)


def sample_request() -> FrostRiskRequest:
    return FrostRiskRequest(
        district="Puno",
        province="Puno",
        populated_center="Centro poblado demo",
        latitude=-15.8402,
        longitude=-70.0219,
        altitude=3827,
        rural_population=1200,
        agricultural_activity=True,
        main_crop="papa",
        temperature_min=-2.5,
        temperature_max=12.4,
        feels_like=-4.0,
        humidity=68,
        wind_speed=7,
        cloud_cover=20,
        dew_point=-3.5,
        precipitation=0,
        month=6,
        hour=3,
        hours_below_zero=4,
    )


def sample_response() -> FrostRiskResponse:
    return FrostRiskResponse(
        risk_level="alto",
        confidence=0.98,
        recommendation="Existe alto riesgo de helada.",
        chuno_conditions="favorables",
        model_version="v0.1.0",
        data_sources=["Open-Meteo Historical API"],
    )


def test_health_check() -> None:
    response = client.get("/health")

    assert response.status_code == 200
    body = response.json()
    assert body["status"] in {"ok", "degraded"}
    assert "model_available" in body


def test_model_info_returns_registry_metadata() -> None:
    response = client.get("/ml/model-info")

    assert response.status_code == 200
    body = response.json()
    assert body["model_name"] == "RandomForestClassifier"
    assert body["version"] == "v0.1.0"
    assert "f1_macro" in body["metrics"]
    assert "Open-Meteo Historical API" in body["data_sources"]


def test_predict_frost_risk_high_risk() -> None:
    payload = {
        "district": "Puno",
        "province": "Puno",
        "populated_center": "Centro poblado demo",
        "latitude": -15.8402,
        "longitude": -70.0219,
        "altitude": 3827,
        "rural_population": 1200,
        "agricultural_activity": True,
        "main_crop": "papa",
        "temperature_min": -2.5,
        "temperature_max": 12.4,
        "feels_like": -4.0,
        "humidity": 68,
        "wind_speed": 7,
        "cloud_cover": 20,
        "dew_point": -3.5,
        "precipitation": 0,
        "month": 6,
        "hour": 3,
        "hours_below_zero": 4,
    }

    response = client.post("/predict/frost-risk", json=payload)

    assert response.status_code == 200
    body = response.json()
    assert body["risk_level"] == "alto"
    assert 0 <= body["confidence"] <= 1
    assert body["model_version"] == "v0.1.0"
    assert body["chuno_conditions"] == "favorables"


def test_prediction_history_returns_empty_without_supabase() -> None:
    response = client.get("/predictions/history")

    assert response.status_code == 200
    assert response.json() == []


def test_noop_repository_does_not_persist_and_returns_empty_history() -> None:
    repository = NoOpPredictionRepository()

    repository.save_prediction(sample_request(), sample_response())

    assert repository.list_history(limit=10) == []


def test_supabase_repository_insert_failure_does_not_raise(caplog) -> None:
    def handler(_: httpx.Request) -> httpx.Response:
        return httpx.Response(status_code=500, json={"message": "database unavailable"})

    client_with_error = httpx.Client(transport=httpx.MockTransport(handler))
    repository = SupabasePredictionRepository(
        supabase_url="https://example.supabase.co",
        service_role_key="test-service-role-key",
        client=client_with_error,
    )

    repository.save_prediction(sample_request(), sample_response())

    assert "Could not persist prediction to Supabase" in caplog.text


def test_supabase_repository_history_failure_returns_empty() -> None:
    def handler(_: httpx.Request) -> httpx.Response:
        return httpx.Response(status_code=401, json={"message": "unauthorized"})

    client_with_error = httpx.Client(transport=httpx.MockTransport(handler))
    repository = SupabasePredictionRepository(
        supabase_url="https://example.supabase.co",
        service_role_key="test-service-role-key",
        client=client_with_error,
    )

    assert repository.list_history(limit=10) == []
