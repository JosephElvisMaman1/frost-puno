from __future__ import annotations

import logging

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes import alerts, chuno, health, ml, predict, predictions, weather
from app.core.config import settings
from app.core.exceptions import ModelLoadError, PredictionError


logging.basicConfig(
    level=settings.log_level,
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
)


def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.app_name,
        version=settings.api_version,
        description="Backend MVP for FrostPuno frost-risk prediction.",
    )
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=False,
        allow_methods=["GET", "POST"],
        allow_headers=["Content-Type"],
    )

    @app.exception_handler(ModelLoadError)
    async def model_load_error_handler(_: Request, exc: ModelLoadError) -> JSONResponse:
        return JSONResponse(
            status_code=503,
            content={
                "error": {
                    "code": "MODEL_UNAVAILABLE",
                    "message": str(exc),
                }
            },
        )

    @app.exception_handler(PredictionError)
    async def prediction_error_handler(_: Request, exc: PredictionError) -> JSONResponse:
        return JSONResponse(
            status_code=422,
            content={
                "error": {
                    "code": "PREDICTION_ERROR",
                    "message": str(exc),
                }
            },
        )

    app.include_router(health.router)
    app.include_router(ml.router)
    app.include_router(predict.router)
    app.include_router(predictions.router)
    app.include_router(weather.router)
    app.include_router(chuno.router)
    app.include_router(alerts.router)
    return app


app = create_app()
