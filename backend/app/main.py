from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.database import engine, Base
from app.routers import (
    auth_router,
    warehouses_router,
    inventory_router,
    suppliers_router,
    orders_router,
    reports_router,
)

Base.metadata.create_all(bind=engine)

app = FastAPI(title="WareFlow API")

# Configure CORS
origins = [
    origin.strip() for origin in settings.ALLOWED_ORIGINS.split(",") if origin.strip()
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(warehouses_router)
app.include_router(inventory_router)
app.include_router(suppliers_router)
app.include_router(orders_router)
app.include_router(reports_router)


@app.get("/")
def root():
    return {"message": "Welcome to WareFlow API"}
