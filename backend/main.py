from fastapi import Depends, FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List
from uuid import uuid4
import os
import requests
from dotenv import load_dotenv
from math import radians, sin, cos, sqrt, atan2
from datetime import datetime

import schemas
from database.database import Base, engine, get_db
from database.models import EventDB, ReviewDB, SavedEventDB, UserDB

load_dotenv()

Base.metadata.create_all(bind=engine)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def calculate_distance_miles(lat1: float, lng1: float, lat2: float, lng2: float):
    earth_radius_miles = 3958.8

    dlat = radians(lat2 - lat1)
    dlng = radians(lng2 - lng1)

    a = (
        sin(dlat / 2) ** 2
        + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlng / 2) ** 2
    )

    c = 2 * atan2(sqrt(a), sqrt(1 - a))

    return round(earth_radius_miles * c, 2)

def format_time_to_ampm(time_value: str):
    if not time_value or time_value == "Unknown time":
        return "Unknown time"

    try:
        parsed_time = datetime.strptime(time_value, "%H:%M:%S")
        return parsed_time.strftime("%I:%M %p").lstrip("0")
    except ValueError:
        return time_value
    

def normalize_ticketmaster_event(
    ticketmaster_event: dict,
    user_lat: float,
    user_lng: float,
):
    event_id = ticketmaster_event.get("id", "")
    name = ticketmaster_event.get("name", "External Event")
    url = ticketmaster_event.get("url", "")

    dates = ticketmaster_event.get("dates", {})
    start = dates.get("start", {})
    local_date = start.get("localDate", "Unknown date")
    local_time = format_time_to_ampm(
        start.get("localTime", "Unknown time")
    )

    images = ticketmaster_event.get("images", [])
    image_url = images[0]["url"] if images else None

    embedded = ticketmaster_event.get("_embedded", {})
    venues = embedded.get("venues", [])
    venue = venues[0] if venues else {}

    venue_name = venue.get("name", "Unknown venue")
    city = venue.get("city", {}).get("name", "")
    state = venue.get("state", {}).get("stateCode", "")
    country = venue.get("country", {}).get("name", "")
    address_line = venue.get("address", {}).get("line1", "")

    location = ", ".join(
        part for part in [venue_name, address_line, city, state, country]
        if part
    )

    coordinates = venue.get("location", {})
    latitude = float(coordinates.get("latitude", 40.785091))
    longitude = float(coordinates.get("longitude", -73.968285))

    distance = calculate_distance_miles(
        user_lat,
        user_lng,
        latitude,
        longitude,
    )

    classifications = ticketmaster_event.get("classifications", [])
    category = "External"

    if classifications:
        category = classifications[0].get("segment", {}).get("name", "External")

    return {
        "id": f"ticketmaster_{event_id}",
        "title": name,
        "description": f"External event from Ticketmaster. {url}",
        "location": location,
        "category": category,
        "date": local_date,
        "time": local_time,
        "distance": distance,
        "latitude": latitude,
        "longitude": longitude,
        "owner_id": None,
        "image_url": image_url,
        "source": "ticketmaster",
        "address_line": address_line,
        "city": city,
        "state": state,
        "country": country,
        "zip_code": None,
        "source": "ticketmaster",
    }


def fetch_ticketmaster_events(
    lat: float,
    lng: float,
    radius: int = 25,
    keyword: str | None = None,
):
    api_key = os.getenv("TICKETMASTER_API_KEY")

    if not api_key:
        raise HTTPException(
            status_code=500,
            detail="Ticketmaster API key is not configured",
        )

    params = {
        "apikey": api_key,
        "latlong": f"{lat},{lng}",
        "radius": radius,
        "unit": "miles",
        "size": 20,
        "sort": "date,asc",
        "countryCode": "US",
    }

    if keyword:
        params["keyword"] = keyword

    response = requests.get(
        "https://app.ticketmaster.com/discovery/v2/events.json",
        params=params,
        timeout=10,
    )

    if response.status_code != 200:
        raise HTTPException(
            status_code=response.status_code,
            detail=f"Ticketmaster request failed: {response.text}",
        )

    data = response.json()
    events = data.get("_embedded", {}).get("events", [])

    return [
        normalize_ticketmaster_event(event, lat, lng)
        for event in events
    ]



# --------------------
# Root
# --------------------

@app.get("/")
def root():
    return {"message": "Nearby Now API is running"}

# --------------------
# Login
# --------------------

@app.post("/register", response_model=schemas.User)
def register_user(
    user: schemas.UserCreate,
    db: Session = Depends(get_db),
):
    existing_user = db.query(UserDB).filter(
        UserDB.email == user.email
    ).first()

    if existing_user is not None:
        raise HTTPException(status_code=400, detail="Email already registered")

    new_user = UserDB(
        id=str(uuid4()),
        name=user.name,
        email=user.email,
        password_hash=user.password,
        role=user.role,
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return new_user


@app.post("/login", response_model=schemas.User)
def login_user(
    user: schemas.UserLogin,
    db: Session = Depends(get_db),
):
    existing_user = db.query(UserDB).filter(
        UserDB.email == user.email
    ).first()

    if existing_user is None:
        raise HTTPException(status_code=401, detail="Invalid email or password")

    if existing_user.password_hash != user.password:
        raise HTTPException(status_code=401, detail="Invalid email or password")

    return existing_user


@app.get("/me/{user_id}", response_model=schemas.User)
def get_current_user(
    user_id: str,
    db: Session = Depends(get_db),
):
    user = db.query(UserDB).filter(UserDB.id == user_id).first()

    if user is None:
        raise HTTPException(status_code=404, detail="User not found")

    return user


# --------------------
# Event Endpoints
# --------------------

@app.get("/events", response_model=List[schemas.Event])
def get_events(db: Session = Depends(get_db)):
    return db.query(EventDB).all()   

@app.get("/my-events/{owner_id}", response_model=List[schemas.Event])
def get_my_events(
    owner_id: str,
    db: Session = Depends(get_db),
):
    return db.query(EventDB).filter(
        EventDB.owner_id == owner_id
    ).all()


@app.post("/events", response_model=schemas.Event)
def create_event(
    event: schemas.EventCreate,
    db: Session = Depends(get_db),
):
    full_location = ", ".join(
        part for part in [
            event.address_line,
            event.city,
            event.state,
            event.country,
            event.zip_code,
        ]
        if part
    )

    new_event = EventDB(
        id=str(uuid4()),
        title=event.title,
        description=event.description,
        location=full_location or event.location,
        category=event.category,
        date=event.date,
        time=event.time,
        distance=event.distance,
        latitude=event.latitude,
        longitude=event.longitude,
        owner_id=event.owner_id,
        address_line=event.address_line,
        city=event.city,
        state=event.state,
        country=event.country,
        zip_code=event.zip_code,
    )

    db.add(new_event)
    db.commit()
    db.refresh(new_event)

    return new_event

@app.get("/events/{event_id}/save-count")
def get_event_save_count(
    event_id: str,
    db: Session = Depends(get_db),
):
    event = db.query(EventDB).filter(EventDB.id == event_id).first()

    if event is None:
        raise HTTPException(status_code=404, detail="Event not found")

    save_count = db.query(SavedEventDB).filter(
        SavedEventDB.event_id == event_id
    ).count()

    return {
        "event_id": event_id,
        "save_count": save_count,
    }

@app.post("/events/{event_id}/view")
def add_event_view(
    event_id: str,
    db: Session = Depends(get_db),
):
    event = db.query(EventDB).filter(EventDB.id == event_id).first()

    if event is None:
        raise HTTPException(status_code=404, detail="Event not found")

    event.views = (event.views or 0) + 1

    db.commit()
    db.refresh(event)

    return {
        "event_id": event_id,
        "views": event.views,
    }


@app.delete("/events/{event_id}")
def delete_event(event_id: str, db: Session = Depends(get_db)):
    event = db.query(EventDB).filter(EventDB.id == event_id).first()
    if event is None:
        raise HTTPException(status_code=404, detail="Event not found")
    
    

    # remove related reviews 
    db.query(ReviewDB).filter(ReviewDB.event_id == event_id).delete()
    #Remove from saved list 
    db.query(SavedEventDB).filter(
        SavedEventDB.event_id == event_id
    ).delete() 

    #then delete the event and commit
    db.delete(event)
    db.commit()

    return {"message": "Event deleted"}
   

@app.put("/events/{event_id}", response_model=schemas.Event)
def update_event(
    event_id: str,
    updated_event: schemas.EventCreate,
    db: Session = Depends(get_db),
):
    event = db.query(EventDB).filter(EventDB.id == event_id).first()

    if event is None:
        raise HTTPException(status_code=404, detail="Event not found")

    full_location = ", ".join(
        part for part in [
            updated_event.address_line,
            updated_event.city,
            updated_event.state,
            updated_event.country,
            updated_event.zip_code,
        ]
        if part
    )

    event.title = updated_event.title
    event.description = updated_event.description
    event.location = full_location or updated_event.location
    event.category = updated_event.category
    event.date = updated_event.date
    event.time = updated_event.time
    event.distance = updated_event.distance
    event.latitude = updated_event.latitude
    event.longitude = updated_event.longitude
    event.owner_id = updated_event.owner_id
    event.address_line = updated_event.address_line
    event.city = updated_event.city
    event.state = updated_event.state
    event.country = updated_event.country
    event.zip_code = updated_event.zip_code

    db.commit()
    db.refresh(event)

    return event

@app.get("/external-events")
def get_external_events(
    lat: float,
    lng: float,
    radius: int = 25,
    keyword: str | None = None,
):
    return fetch_ticketmaster_events(
        lat=lat,
        lng=lng,
        radius=radius,
        keyword=keyword,
    )

# --------------------
# Review Endpoints
# --------------------

@app.get("/events/{event_id}/reviews", response_model=List[schemas.Review])
def get_reviews(event_id: str, db: Session = Depends(get_db)):
    return db.query(ReviewDB).filter(ReviewDB.event_id == event_id).all()


@app.post("/events/{event_id}/reviews", response_model=schemas.Review)
def create_review(event_id: str, review: schemas.ReviewCreate, db: Session = Depends(get_db)):
    #need to check if the event exist first 
    event_exists = db.query(EventDB).filter(EventDB.id == event_id).first()
    if event_exists is None:
        raise HTTPException(status_code=404, detail="Event not found")

    new_review = ReviewDB(
        id=str(uuid4()),
        event_id=event_id,
        user_id=review.user_id,
        rating=review.rating,
        comment=review.comment,
    )

    db.add(new_review)
    db.commit()
    db.refresh(new_review)
    return new_review


# --------------------
# Saved Event Endpoints
# --------------------

@app.get("/saved-events", response_model=List[schemas.SavedEvent])
def get_saved_events(db: Session = Depends(get_db)):
    return db.query(SavedEventDB).all()


@app.post("/saved-events", response_model=schemas.SavedEvent)
def create_saved_event(
    saved_event: schemas.SavedEventCreate,
    db: Session = Depends(get_db),
):
    event = db.query(EventDB).filter(
        EventDB.id == saved_event.event_id
    ).first()

    if event is None:
        raise HTTPException(status_code=404, detail="Event not found")

    already_saved = db.query(SavedEventDB).filter(
        SavedEventDB.event_id == saved_event.event_id,
        SavedEventDB.user_id == saved_event.user_id,
    ).first()

    if already_saved is not None:
        raise HTTPException(status_code=400, detail="Event already saved")

    new_saved_event = SavedEventDB(
        id=str(uuid4()),
        event_id=saved_event.event_id,
        user_id=saved_event.user_id,
    )

    db.add(new_saved_event)
    db.commit()
    db.refresh(new_saved_event)

    return new_saved_event


@app.delete("/saved-events/{event_id}")
def delete_saved_event(
    event_id: str,
    db: Session = Depends(get_db),
):
    saved_event = db.query(SavedEventDB).filter(
        SavedEventDB.event_id == event_id
    ).first()

    if saved_event is None:
        raise HTTPException(status_code=404, detail="Saved event not found")

    db.delete(saved_event)
    db.commit()

    return {"message": "Saved event removed"}