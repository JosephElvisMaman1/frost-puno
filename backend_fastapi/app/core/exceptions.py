class ModelLoadError(RuntimeError):
    """Raised when the model registry cannot be loaded."""


class PredictionError(RuntimeError):
    """Raised when a validated request cannot be transformed into a prediction."""

