from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class FrostRiskRequest(BaseModel):
    district: str = Field(..., min_length=1, examples=["Puno"])
    province: str = Field(..., min_length=1, examples=["Puno"])
    populated_center: str | None = Field(default=None, examples=["Centro poblado demo"])
    latitude: float = Field(..., ge=-18.5, le=-13.0, examples=[-15.8402])
    longitude: float = Field(..., ge=-71.5, le=-68.0, examples=[-70.0219])
    altitude: float = Field(..., ge=0, le=7000, examples=[3827])
    rural_population: int = Field(..., ge=0, examples=[1200])
    total_population: int | None = Field(default=None, ge=0, examples=[5000])
    rural_percentage: float | None = Field(default=None, ge=0, le=100, examples=[24.0])
    agricultural_activity: bool = Field(default=True)
    main_crop: str | None = Field(default="papa", min_length=1)
    temperature_min: float = Field(..., ge=-30, le=40, examples=[-2.5])
    temperature_max: float = Field(..., ge=-30, le=45, examples=[12.4])
    feels_like: float = Field(..., ge=-40, le=45, examples=[-4.0])
    humidity: float = Field(..., ge=0, le=100, examples=[68])
    wind_speed: float = Field(..., ge=0, le=200, examples=[7])
    cloud_cover: float = Field(..., ge=0, le=100, examples=[20])
    dew_point: float = Field(..., ge=-40, le=40, examples=[-3.5])
    precipitation: float = Field(..., ge=0, le=500, examples=[0])
    month: int = Field(..., ge=1, le=12, examples=[6])
    hour: int = Field(..., ge=0, le=23, examples=[3])
    hours_below_zero: int = Field(..., ge=0, le=24, examples=[4])

    model_config = ConfigDict(extra="forbid")


class FrostRiskResponse(BaseModel):
    risk_level: str
    confidence: float = Field(..., ge=0, le=1)
    recommendation: str
    chuno_conditions: str
    model_version: str
    data_sources: list[str]

    model_config = ConfigDict(extra="forbid")


class FrostPredictionHistoryItem(BaseModel):
    id: str
    district: str
    province: str
    populated_center: str | None = None
    latitude: float
    longitude: float
    altitude: float | None = None
    risk_level: str
    confidence: float = Field(..., ge=0, le=1)
    chuno_conditions: str
    recommendation: str
    model_version: str
    data_sources: list[str]
    created_at: str

    model_config = ConfigDict(extra="ignore")
