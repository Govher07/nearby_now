from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List
from uuid import uuid4

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# --------------------
# Event Models
# --------------------

class EventCreate(BaseModel):
    title: str
    description: str
    location: str
    category: str
    date: str
    time: str
    distance: float = 0.5


class Event(EventCreate):
    id: str


events: List[Event] = [
    Event(
        id="1",
        title="Live Music in the Park",
        description="Enjoy live music from local artists in the park.",
        location="Central Park",
        category="Music",
        date="Today",
        time="6:00 PM",
        distance=0.4,
    ),
    Event(
        id="2",
        title="Food Truck Festival",
        description="Try food from local vendors and enjoy a local outdoor event.",
        location="Downtown Plaza",
        category="Food",
        date="Tomorrow",
        time="12:00 PM",
        distance=1.2,
    ),
]


# --------------------
# Review Models
# --------------------

class ReviewCreate(BaseModel):
    rating: int
    comment: str = ""


class Review(ReviewCreate):
    id: str
    event_id: str


reviews: List[Review] = []


# --------------------
# Saved Event Models
# --------------------

class SavedEventCreate(BaseModel):
    event_id: str


class SavedEvent(SavedEventCreate):
    id: str


saved_events: List[SavedEvent] = []


# --------------------
# Root
# --------------------

@app.get("/")
def root():
    return {"message": "Nearby Now API is running"}


# --------------------
# Event Endpoints
# --------------------

@app.get("/events", response_model=List[Event])
def get_events():
    return events


@app.post("/events", response_model=Event)
def create_event(event: EventCreate):
    new_event = Event(
        id=str(uuid4()),
        **event.model_dump(),
    )

    events.append(new_event)
    return new_event


@app.delete("/events/{event_id}")
def delete_event(event_id: str):
    for event in events:
        if event.id == event_id:
            events.remove(event)

            # Also remove related reviews and saved records
            reviews[:] = [
                review for review in reviews
                if review.event_id != event_id
            ]

            saved_events[:] = [
                saved_event for saved_event in saved_events
                if saved_event.event_id != event_id
            ]

            return {"message": "Event deleted"}

    raise HTTPException(status_code=404, detail="Event not found")


# --------------------
# Review Endpoints
# --------------------

@app.get("/events/{event_id}/reviews", response_model=List[Review])
def get_reviews(event_id: str):
    return [
        review for review in reviews
        if review.event_id == event_id
    ]


@app.post("/events/{event_id}/reviews", response_model=Review)
def create_review(event_id: str, review: ReviewCreate):
    event_exists = any(event.id == event_id for event in events)

    if not event_exists:
        raise HTTPException(status_code=404, detail="Event not found")

    new_review = Review(
        id=str(uuid4()),
        event_id=event_id,
        **review.model_dump(),
    )

    reviews.append(new_review)
    return new_review


# --------------------
# Saved Event Endpoints
# --------------------

@app.get("/saved-events", response_model=List[SavedEvent])
def get_saved_events():
    return saved_events


@app.post("/saved-events", response_model=SavedEvent)
def create_saved_event(saved_event: SavedEventCreate):
    event_exists = any(event.id == saved_event.event_id for event in events)

    if not event_exists:
        raise HTTPException(status_code=404, detail="Event not found")

    already_saved = any(
        item.event_id == saved_event.event_id
        for item in saved_events
    )

    if already_saved:
        raise HTTPException(status_code=400, detail="Event already saved")

    new_saved_event = SavedEvent(
        id=str(uuid4()),
        **saved_event.model_dump(),
    )

    saved_events.append(new_saved_event)
    return new_saved_event


@app.delete("/saved-events/{event_id}")
def delete_saved_event(event_id: str):
    for saved_event in saved_events:
        if saved_event.event_id == event_id:
            saved_events.remove(saved_event)
            return {"message": "Saved event removed"}

    raise HTTPException(status_code=404, detail="Saved event not found")