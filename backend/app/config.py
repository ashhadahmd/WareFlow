from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "WareFlow"
    DATABASE_URL: str
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 10080
    ALLOWED_ORIGINS: str = "http://localhost:3000,http://localhost:8000"

    model_config = {"env_file": [".env", "../.env"]}


settings = Settings()
