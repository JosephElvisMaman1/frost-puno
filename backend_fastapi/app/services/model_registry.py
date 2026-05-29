from __future__ import annotations

import json
import logging
from functools import lru_cache
from pathlib import Path
from typing import Any

import joblib

from app.core.config import settings
from app.core.exceptions import ModelLoadError
from app.schemas.ml import ModelMetadata


LOGGER = logging.getLogger(__name__)


class ModelRegistry:
    def __init__(self, model_path: Path, metadata_path: Path) -> None:
        self.model_path = model_path
        self.metadata_path = metadata_path
        self._model: Any | None = None
        self._metadata: ModelMetadata | None = None

    @property
    def model(self) -> Any:
        if self._model is None:
            self._model = self._load_model()
        return self._model

    @property
    def metadata(self) -> ModelMetadata:
        if self._metadata is None:
            self._metadata = self._load_metadata()
        return self._metadata

    def _load_model(self) -> Any:
        if not self.model_path.exists():
            raise ModelLoadError(f"Model artifact not found at {self.model_path}")

        try:
            LOGGER.info("Loading model artifact from %s", self.model_path)
            return joblib.load(self.model_path)
        except Exception as exc:  # noqa: BLE001 - convert registry failures into API-safe errors.
            raise ModelLoadError("Could not load the registered model artifact.") from exc

    def _load_metadata(self) -> ModelMetadata:
        if not self.metadata_path.exists():
            raise ModelLoadError(f"Model metadata not found at {self.metadata_path}")

        try:
            raw_metadata = json.loads(self.metadata_path.read_text(encoding="utf-8"))
            return ModelMetadata.model_validate(raw_metadata)
        except Exception as exc:  # noqa: BLE001 - convert malformed metadata into API-safe errors.
            raise ModelLoadError("Could not load model metadata.") from exc


@lru_cache(maxsize=1)
def get_model_registry() -> ModelRegistry:
    return ModelRegistry(settings.model_path, settings.model_metadata_path)

