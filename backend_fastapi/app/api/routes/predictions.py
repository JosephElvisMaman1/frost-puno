from __future__ import annotations

from fastapi import APIRouter, Depends, Query

from app.repositories.predictions import PredictionRepository, get_prediction_repository
from app.schemas.prediction import FrostPredictionHistoryItem


router = APIRouter(prefix="/predictions", tags=["predictions"])


@router.get("/history", response_model=list[FrostPredictionHistoryItem])
def prediction_history(
    limit: int = Query(default=20, ge=1, le=100),
    repository: PredictionRepository = Depends(get_prediction_repository),
) -> list[FrostPredictionHistoryItem]:
    return repository.list_history(limit=limit)
