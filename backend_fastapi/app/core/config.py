from __future__ import annotations

from pathlib import Path

from pydantic import AliasChoices, Field
from pydantic_settings import BaseSettings, SettingsConfigDict


PROJECT_ROOT = Path(__file__).resolve().parents[3]


class Settings(BaseSettings):
    app_name: str = Field(default="FrostPuno API", validation_alias=AliasChoices("APP_NAME", "FROST_PUNO_APP_NAME"))
    api_version: str = Field(default="0.1.0", validation_alias=AliasChoices("API_VERSION", "FROST_PUNO_API_VERSION"))
    log_level: str = Field(default="INFO", validation_alias=AliasChoices("LOG_LEVEL", "FROST_PUNO_LOG_LEVEL"))

    # Modelo productivo: K-Means no supervisado (reemplaza al clasificador supervisado).
    model_path: Path = Field(
        default=PROJECT_ROOT / "ml_pipeline" / "registry" / "frost_cluster_model.joblib",
        validation_alias=AliasChoices("MODEL_PATH", "FROST_PUNO_MODEL_PATH"),
    )
    model_metadata_path: Path = Field(
        default=PROJECT_ROOT / "ml_pipeline" / "registry" / "cluster_metadata.json",
        validation_alias=AliasChoices("MODEL_METADATA_PATH", "FROST_PUNO_MODEL_METADATA_PATH"),
    )
    district_clusters_path: Path = Field(
        default=PROJECT_ROOT / "data" / "processed" / "district_clusters.csv",
        validation_alias=AliasChoices("DISTRICT_CLUSTERS_PATH", "FROST_PUNO_DISTRICT_CLUSTERS_PATH"),
    )

    supabase_url: str | None = Field(default=None, validation_alias=AliasChoices("SUPABASE_URL", "FROST_PUNO_SUPABASE_URL"))
    supabase_service_role_key: str | None = Field(
        default=None,
        validation_alias=AliasChoices("SUPABASE_SERVICE_ROLE_KEY", "FROST_PUNO_SUPABASE_SERVICE_ROLE_KEY"),
    )
    enable_supabase: bool = Field(default=False, validation_alias=AliasChoices("ENABLE_SUPABASE", "FROST_PUNO_PERSIST_PREDICTIONS"))
    cors_allowed_origins: str = Field(
        default="http://127.0.0.1:5174,http://127.0.0.1:5173,http://localhost:5174,http://localhost:5173",
        validation_alias=AliasChoices("CORS_ORIGINS", "CORS_ALLOWED_ORIGINS", "FROST_PUNO_CORS_ALLOWED_ORIGINS"),
    )

    @property
    def cors_origins(self) -> list[str]:
        return [origin.strip() for origin in self.cors_allowed_origins.split(",") if origin.strip()]

    model_config = SettingsConfigDict(
        env_file=(PROJECT_ROOT / ".env", PROJECT_ROOT / "backend_fastapi" / ".env"),
        extra="ignore",
    )


settings = Settings()
