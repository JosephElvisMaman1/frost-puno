from __future__ import annotations

from fastapi import APIRouter, Depends

from app.repositories.predictions import PredictionRepository, get_prediction_repository
from app.schemas.prediction import FrostRiskRequest, FrostRiskResponse
from app.services.prediction_service import PredictionService, get_prediction_service


router = APIRouter(prefix="/predict", tags=["prediction"])


@router.post("/frost-risk", response_model=FrostRiskResponse)
def predict_frost_risk(
    payload: FrostRiskRequest,
    service: PredictionService = Depends(get_prediction_service),
    repository: PredictionRepository = Depends(get_prediction_repository),
) -> FrostRiskResponse:
    prediction = service.predict(payload)
    repository.save_prediction(payload, prediction)
    return prediction

