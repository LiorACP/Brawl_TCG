from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    google_application_credentials: str = "serviceAccount.json"
    firestore_project_id: str = "brawl-tcg"
    pokemon_tcg_api_key: str = ""
    default_language: str = "es"


settings = Settings()
