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


def test_model_info_returns_cluster_metadata() -> None:
    response = client.get("/ml/model-info")

    assert response.status_code == 200
    body = response.json()
    assert body["model_name"] == "KMeans"
    assert body["version"].endswith("clustering")
    assert "silhouette" in body["metrics"]
    assert body["n_clusters"] >= 2


def test_clusters_endpoint_returns_profiles_and_districts() -> None:
    response = client.get("/ml/clusters")

    assert response.status_code == 200
    body = response.json()
    assert body["n_clusters"] == len(body["profiles"])
    assert body["profiles"], "expected at least one cluster profile"
    assert body["districts"], "expected district groupings"
    tiers = {district["tier"] for district in body["districts"]}
    assert tiers.issubset({"alto", "medio", "bajo"})


def test_predict_frost_risk_returns_cluster_tier() -> None:
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
    assert body["risk_level"] in {"alto", "medio", "bajo"}
    assert 0 <= body["confidence"] <= 1
    assert body["model_version"].endswith("clustering")
    assert body["chuno_conditions"] == "favorables"


def test_prediction_history_returns_empty_without_supabase() -> None:
    response = client.get("/predictions/history")

    assert response.status_code == 200
    assert response.json() == []


def test_current_weather_contract(monkeypatch) -> None:
    from app.api.routes import weather
    from app.schemas.weather import CurrentWeatherResponse

    class FakeWeatherProvider:
        def get_current_weather(self, query):
            return CurrentWeatherResponse(
                latitude=query.latitude,
                longitude=query.longitude,
                temperature=-1.5,
                humidity=70,
                provider="Open-Meteo",
                source_priority=["SENAMHI", "Open-Meteo"],
                fallback_used=True,
            )

    weather.get_weather_provider.cache_clear()
    monkeypatch.setattr(weather, "get_weather_provider", lambda: FakeWeatherProvider())

    response = client.get("/weather/current?latitude=-15.8402&longitude=-70.0219")

    assert response.status_code == 200
    body = response.json()
    assert body["provider"] == "Open-Meteo"
    assert body["fallback_used"] is True


class _FakeForecastProvider:
    def __init__(self, rows):
        self._rows = rows

    def get_daily_forecast(self, query, days=7):
        return self._rows

    def get_history(self, query, start_date, end_date):
        return self._rows


def test_chuno_window_flags_optimal_streak(monkeypatch) -> None:
    from app.api.routes import chuno

    cold_day = {
        "date": "2026-06-10",
        "temperature_2m_min": -7.0,
        "temperature_2m_max": 16.0,
        "relative_humidity_2m_max": 45.0,
        "cloud_cover_mean": 15.0,
        "precipitation_sum": 0.0,
    }
    rows = [dict(cold_day, date=f"2026-06-{10 + i}") for i in range(4)]
    monkeypatch.setattr(chuno, "get_weather_provider", lambda: _FakeForecastProvider(rows))

    response = client.get("/chuno/window?latitude=-15.8402&longitude=-70.0219")

    assert response.status_code == 200
    body = response.json()
    assert body["best_streak"] >= 3
    assert all(day["is_good_day"] for day in body["days"])
    # optimal_window depende de la temporada real; el streak siempre debe reflejar los días buenos.
    assert body["days"][0]["tier"] in {"excelente", "bueno"}


def test_alert_today_strong_frost(monkeypatch) -> None:
    from app.api.routes import alerts

    rows = [{"date": "2026-06-10", "temperature_2m_min": -6.0}]
    monkeypatch.setattr(alerts, "get_weather_provider", lambda: _FakeForecastProvider(rows))

    response = client.get("/alerts/today?latitude=-15.8402&longitude=-70.0219")

    assert response.status_code == 200
    body = response.json()
    assert body["frost_alert"] is True
    assert body["severity"] == "fuerte"
    assert body["risk_level"] == "alto"


def test_weather_history_contract(monkeypatch) -> None:
    from app.api.routes import weather

    rows = [
        {
            "date": "2026-06-01",
            "temperature_2m_min": -5.0,
            "temperature_2m_max": 14.0,
            "relative_humidity_2m_mean": 55.0,
        }
    ]
    weather.get_weather_provider.cache_clear()
    monkeypatch.setattr(weather, "get_weather_provider", lambda: _FakeForecastProvider(rows))

    response = client.get(
        "/weather/history?latitude=-15.8402&longitude=-70.0219&start=2026-06-01&end=2026-06-01"
    )

    assert response.status_code == 200
    body = response.json()
    assert body["days"][0]["temperature_min"] == -5.0
    assert body["days"][0]["humidity_mean"] == 55.0


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
