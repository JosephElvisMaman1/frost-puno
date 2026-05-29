from __future__ import annotations

from pydantic import BaseModel, ConfigDict


class HealthResponse(BaseModel):
    status: str
    app_name: str
    version: str
    model_available: bool

    model_config = ConfigDict(extra="forbid")

