from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    PROJECT_NAME: str = "WareFlow"
    DATABASE_URL: str = "postgresql://postgres:postgres@localhost:5432/wareflow"
    SECRET_KEY: str = "change-this-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7

    model_config = {"env_file": [".env", "../.env"]}


settings = Settings()
