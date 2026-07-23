from __future__ import annotations

import logging
import math
import time
from dataclasses import dataclass
from typing import Protocol

import httpx

from app.schemas.weather import CurrentWeatherResponse


LOGGER = logging.getLogger(__name__)


@dataclass(frozen=True)
class WeatherQuery:
    latitude: float
    longitude: float


class WeatherProvider(Protocol):
    name: str

    def get_current_weather(self, query: WeatherQuery) -> CurrentWeatherResponse | None:
        """Return current weather or None when the provider has no usable data."""


class SenamhiProvider:
    name = "SENAMHI"

    _puno_reference_stations = (
        ("Puno", -15.8402, -70.0219, 3827.0),
        ("Juliaca", -15.4997, -70.1333, 3825.0),
        ("Ilave", -16.0833, -69.6667, 3850.0),
    )

    def get_current_weather(self, query: WeatherQuery) -> CurrentWeatherResponse | None:
        station_name, distance_km = self._nearest_station(query)
        LOGGER.info(
            "SENAMHI provider prepared nearest station=%s distance=%.2f km; no stable public API configured.",
            station_name,
            distance_km,
        )
        return None

    def nearest_station_metadata(self, query: WeatherQuery) -> tuple[str, float]:
        return self._nearest_station(query)

    def _nearest_station(self, query: WeatherQuery) -> tuple[str, float]:
        nearest = min(
            self._puno_reference_stations,
            key=lambda station: _distance_km(query.latitude, query.longitude, station[1], station[2]),
        )
        return nearest[0], _distance_km(query.latitude, query.longitude, nearest[1], nearest[2])


class OpenMeteoProvider:
    name = "Open-Meteo"

    def __init__(self, client: httpx.Client | None = None) -> None:
        self._client = client or httpx.Client(timeout=12)

    def get_current_weather(self, query: WeatherQuery) -> CurrentWeatherResponse | None:
        response = self._client.get(
            "https://api.open-meteo.com/v1/forecast",
            params={
                "latitude": query.latitude,
                "longitude": query.longitude,
                "current": ",".join(
                    [
                        "temperature_2m",
                        "relative_humidity_2m",
                        "apparent_temperature",
                        "dew_point_2m",
                        "precipitation",
                        "cloud_cover",
                        "wind_speed_10m",
                    ],
                ),
                "timezone": "auto",
            },
        )
        response.raise_for_status()
        payload = response.json()
        current = payload.get("current") or {}
        return CurrentWeatherResponse(
            latitude=query.latitude,
            longitude=query.longitude,
            temperature=_num(current.get("temperature_2m")),
            apparent_temperature=_num(current.get("apparent_temperature")),
            humidity=_num(current.get("relative_humidity_2m")),
            wind_speed=_num(current.get("wind_speed_10m")),
            cloud_cover=_num(current.get("cloud_cover")),
            dew_point=_num(current.get("dew_point_2m")),
            precipitation=_num(current.get("precipitation")),
            observed_at=current.get("time"),
            provider=self.name,
            source_priority=["SENAMHI", "Open-Meteo"],
            fallback_used=True,
            limitations=[
                "SENAMHI is prioritized conceptually, but no stable unauthenticated API is configured in this MVP.",
                "Open-Meteo is used as fallback/global weather source for current app predictions.",
            ],
        )


    def get_daily_forecast(self, query: WeatherQuery, days: int = 7) -> list[dict[str, float | str | None]]:
        """Pronóstico diario Open-Meteo para el módulo de chuño."""
        response = self._client.get(
            "https://api.open-meteo.com/v1/forecast",
            params={
                "latitude": query.latitude,
                "longitude": query.longitude,
                "daily": ",".join(
                    [
                        "temperature_2m_min",
                        "temperature_2m_max",
                        "relative_humidity_2m_max",
                        "cloud_cover_mean",
                        "precipitation_sum",
                    ],
                ),
                "forecast_days": days,
                "timezone": "auto",
            },
        )
        response.raise_for_status()
        return _rows_from_daily(response.json().get("daily") or {})

    def get_history(
        self, query: WeatherQuery, start_date: str, end_date: str
    ) -> list[dict[str, float | str | None]]:
        """Serie histórica diaria vía Open-Meteo Archive API (sin API key)."""
        response = self._client.get(
            "https://archive-api.open-meteo.com/v1/archive",
            params={
                "latitude": query.latitude,
                "longitude": query.longitude,
                "start_date": start_date,
                "end_date": end_date,
                "daily": ",".join(
                    [
                        "temperature_2m_min",
                        "temperature_2m_max",
                        "relative_humidity_2m_mean",
                    ],
                ),
                "timezone": "auto",
            },
        )
        response.raise_for_status()
        return _rows_from_daily(response.json().get("daily") or {})


class HybridWeatherProvider:
    name = "HybridWeatherProvider"

    def __init__(
        self,
        senamhi_provider: SenamhiProvider | None = None,
        open_meteo_provider: OpenMeteoProvider | None = None,
        cache_ttl_seconds: int = 600,
    ) -> None:
        self._senamhi = senamhi_provider or SenamhiProvider()
        self._open_meteo = open_meteo_provider or OpenMeteoProvider()
        self._cache_ttl_seconds = cache_ttl_seconds
        self._cache: dict[tuple[float, float], tuple[float, CurrentWeatherResponse]] = {}

    def get_current_weather(self, query: WeatherQuery) -> CurrentWeatherResponse:
        cache_key = (round(query.latitude, 4), round(query.longitude, 4))
        cached = self._cache.get(cache_key)
        now = time.time()
        if cached and now - cached[0] < self._cache_ttl_seconds:
            return cached[1]

        station_name, station_distance = self._senamhi.nearest_station_metadata(query)
        try:
            senamhi_weather = self._senamhi.get_current_weather(query)
            if senamhi_weather is not None:
                result = senamhi_weather
            else:
                result = self._fallback_to_open_meteo(query, station_name, station_distance)
        except Exception as exc:  # noqa: BLE001 - weather lookup must not break predictions.
            LOGGER.warning("SENAMHI provider failed; using Open-Meteo fallback: %s", exc)
            result = self._fallback_to_open_meteo(query, station_name, station_distance)

        self._cache[cache_key] = (now, result)
        return result

    def get_daily_forecast(self, query: WeatherQuery, days: int = 7) -> list[dict[str, float | str | None]]:
        return self._open_meteo.get_daily_forecast(query, days=days)

    def get_history(
        self, query: WeatherQuery, start_date: str, end_date: str
    ) -> list[dict[str, float | str | None]]:
        return self._open_meteo.get_history(query, start_date, end_date)

    def _fallback_to_open_meteo(
        self,
        query: WeatherQuery,
        station_name: str,
        station_distance: float,
    ) -> CurrentWeatherResponse:
        result = self._open_meteo.get_current_weather(query)
        if result is None:
            return CurrentWeatherResponse(
                latitude=query.latitude,
                longitude=query.longitude,
                provider="unavailable",
                source_priority=["SENAMHI", "Open-Meteo"],
                fallback_used=True,
                station_name=station_name,
                station_distance_km=station_distance,
                limitations=["No weather provider returned usable data."],
            )
        return result.model_copy(
            update={
                "station_name": station_name,
                "station_distance_km": station_distance,
            },
        )


def _distance_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    radius_km = 6371.0
    d_lat = math.radians(lat2 - lat1)
    d_lon = math.radians(lon2 - lon1)
    a = (
        math.sin(d_lat / 2) ** 2
        + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(d_lon / 2) ** 2
    )
    return round(radius_km * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a)), 2)


def _num(value: object) -> float | None:
    if value is None:
        return None
    return float(value)


def _rows_from_daily(daily: dict[str, list]) -> list[dict[str, float | str | None]]:
    """Transpone el bloque `daily` de Open-Meteo (columnas) en filas por fecha."""
    dates = daily.get("time") or []
    keys = [key for key in daily if key != "time"]
    rows: list[dict[str, float | str | None]] = []
    for index, date in enumerate(dates):
        row: dict[str, float | str | None] = {"date": date}
        for key in keys:
            values = daily.get(key) or []
            row[key] = _num(values[index]) if index < len(values) else None
        rows.append(row)
    return rows
