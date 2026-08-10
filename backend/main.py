import os

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from database.database import Base, engine
from routers import analytics, auth, events, reviews, saved_events


load_dotenv()
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Nearby Now API",
    description="API for discovering, creating, reviewing, and saving local events.",
    version="1.0.0",
)

allowed_origins = [
    origin.strip()
    for origin in os.getenv(
        "ALLOWED_ORIGINS",
        "http://localhost:3000,http://localhost:8080",
    ).split(",")
    if origin.strip()
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(events.router)
app.include_router(analytics.router)
app.include_router(reviews.router)
app.include_router(saved_events.router)


@app.get("/", tags=["health"])
def root():
    return {"message": "Nearby Now API is running"}
