from datetime import datetime
from math import atan2, cos, radians, sin, sqrt
from typing import List
from uuid import uuid4
import os

import requests
from dotenv import load_dotenv
from fastapi import Depends, FastAPI, HTTPException, Query, status
from fastapi.security import OAuth2PasswordBearer
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session

import schemas
from database.database import Base, engine, get_db
from database.models import EventDB, ReviewDB, SavedEventDB, UserDB
from security import (
    create_access_token,
    decode_access_token,
    hash_password,
    verify_password,
)


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

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")


# --------------------
# Helpers
# --------------------

def get_authenticated_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db),
) -> UserDB:
    user_id = decode_access_token(token)
    if user_id is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired access token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    user = db.query(UserDB).filter(UserDB.id == user_id).first()
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User no longer exists",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return user


def require_business_owner(
    current_user: UserDB = Depends(get_authenticated_user),
) -> UserDB:
    if current_user.role != "business_owner":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Business owner account required",
        )
    return current_user


def require_same_user(requested_user_id: str, current_user: UserDB):
    if requested_user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You cannot access another user's data",
        )

def calculate_distance_miles(
    lat1: float,
    lng1: float,
    lat2: float,
    lng2: float,
):
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
    zip_code = venue.get("postalCode")

    location = ", ".join(
        part for part in [venue_name, address_line, city, state, country, zip_code]
        if part
    )

    coordinates = venue.get("location", {})
    latitude = float(coordinates.get("latitude") or user_lat)
    longitude = float(coordinates.get("longitude") or user_lng)

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
        "zip_code": zip_code,
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
# Auth
# --------------------

@app.post("/register", response_model=schemas.AuthResponse, status_code=201)
def register_user(
    user: schemas.UserCreate,
    db: Session = Depends(get_db),
):
    existing_user = db.query(UserDB).filter(
        UserDB.email == user.email.lower()
    ).first()

    if existing_user is not None:
        raise HTTPException(
            status_code=400,
            detail="Email already registered",
        )

    new_user = UserDB(
        id=str(uuid4()),
        name=user.name,
        email=user.email.lower(),
        password_hash=hash_password(user.password),
        role=user.role,
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return {
        "access_token": create_access_token(new_user.id),
        "user": new_user,
    }


@app.post("/login", response_model=schemas.AuthResponse)
def login_user(
    user: schemas.UserLogin,
    db: Session = Depends(get_db),
):
    existing_user = db.query(UserDB).filter(
        UserDB.email == user.email.lower()
    ).first()

    if existing_user is None:
        raise HTTPException(
            status_code=401,
            detail="Invalid email or password",
        )

    stored_password = existing_user.password_hash

    password_is_valid = verify_password(user.password, stored_password)

    if not password_is_valid:
        raise HTTPException(
            status_code=401,
            detail="Invalid email or password",
        )

    return {
        "access_token": create_access_token(existing_user.id),
        "user": existing_user,
    }


@app.get("/me/{user_id}", response_model=schemas.User)
def get_user_profile(
    user_id: str,
    db: Session = Depends(get_db),
    authenticated_user: UserDB = Depends(get_authenticated_user),
):
    require_same_user(user_id, authenticated_user)
    user = db.query(UserDB).filter(UserDB.id == user_id).first()

    if user is None:
        raise HTTPException(
            status_code=404,
            detail="User not found",
        )

    return user


# --------------------
# Geocoding
# --------------------

@app.get("/geocode")
def geocode_address(address: str = Query(...)):
    cleaned_address = address.strip()

    if not cleaned_address:
        raise HTTPException(
            status_code=400,
            detail="Address is required",
        )

    address_parts = [
        part.strip()
        for part in cleaned_address.split(",")
        if part.strip()
    ]

    search_queries = []

    # 1. Try full address first.
    search_queries.append(cleaned_address)

    # 2. Try without street address.
    if len(address_parts) >= 4:
        search_queries.append(", ".join(address_parts[1:]))

    # 3. Try city + state + zip.
    if len(address_parts) >= 5:
        city = address_parts[1]
        state = address_parts[2]
        zip_code = address_parts[4]
        search_queries.append(f"{city}, {state} {zip_code}")

    # 4. Try city + state.
    if len(address_parts) >= 3:
        city = address_parts[1]
        state = address_parts[2]
        search_queries.append(f"{city}, {state}")

    search_queries = list(dict.fromkeys(search_queries))

    service_failed = False

    for query in search_queries:
        response = requests.get(
            "https://nominatim.openstreetmap.org/search",
            params={
                "q": query,
                "format": "json",
                "limit": 1,
                "countrycodes": "us",
                "addressdetails": 1,
            },
            headers={
                "User-Agent": "nearby-now-local-dev/1.0",
            },
            timeout=10,
        )

        if response.status_code != 200:
            service_failed = True
            continue

        results = response.json()

        if results:
            first_result = results[0]

            return {
                "latitude": float(first_result["lat"]),
                "longitude": float(first_result["lon"]),
                "matched_address": first_result.get("display_name", query),
                "searched_query": query,
            }

    if service_failed:
        raise HTTPException(
            status_code=502,
            detail="Geocoding service failed",
        )

    raise HTTPException(
        status_code=404,
        detail=f"Address not found. Tried: {search_queries}",
    )


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
    current_user: UserDB = Depends(require_business_owner),
):
    require_same_user(owner_id, current_user)
    return db.query(EventDB).filter(
        EventDB.owner_id == owner_id
    ).all()


@app.post("/events", response_model=schemas.Event)
def create_event(
    event: schemas.EventCreate,
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(require_business_owner),
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
        owner_id=current_user.id,
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


@app.put("/events/{event_id}", response_model=schemas.Event)
def update_event(
    event_id: str,
    updated_event: schemas.EventCreate,
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(require_business_owner),
):
    event = db.query(EventDB).filter(EventDB.id == event_id).first()

    if event is None:
        raise HTTPException(
            status_code=404,
            detail="Event not found",
        )

    if event.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="You do not own this event")

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
    event.address_line = updated_event.address_line
    event.city = updated_event.city
    event.state = updated_event.state
    event.country = updated_event.country
    event.zip_code = updated_event.zip_code

    db.commit()
    db.refresh(event)

    return event


@app.delete("/events/{event_id}")
def delete_event(
    event_id: str,
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(require_business_owner),
):
    event = db.query(EventDB).filter(EventDB.id == event_id).first()

    if event is None:
        raise HTTPException(
            status_code=404,
            detail="Event not found",
        )

    if event.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="You do not own this event")

    db.query(ReviewDB).filter(
        ReviewDB.event_id == event_id
    ).delete()

    db.query(SavedEventDB).filter(
        SavedEventDB.event_id == event_id
    ).delete()

    db.delete(event)
    db.commit()

    return {"message": "Event deleted"}


@app.get("/external-events")
def get_external_events(
    lat: float,
    lng: float,
    radius: int = Query(default=25, ge=1, le=100),
    keyword: str | None = None,
):
    return fetch_ticketmaster_events(
        lat=lat,
        lng=lng,
        radius=radius,
        keyword=keyword,
    )


# --------------------
# Analytics Endpoints
# --------------------

@app.get("/events/{event_id}/save-count")
def get_event_save_count(
    event_id: str,
    db: Session = Depends(get_db),
):
    event = db.query(EventDB).filter(EventDB.id == event_id).first()

    if event is None:
        raise HTTPException(
            status_code=404,
            detail="Event not found",
        )

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
        raise HTTPException(
            status_code=404,
            detail="Event not found",
        )

    event.views = (event.views or 0) + 1

    db.commit()
    db.refresh(event)

    return {
        "event_id": event_id,
        "views": event.views,
    }


@app.get("/events/{event_id}/analytics")
def get_event_analytics(
    event_id: str,
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(require_business_owner),
):
    event = db.query(EventDB).filter(EventDB.id == event_id).first()

    if event is None:
        raise HTTPException(
            status_code=404,
            detail="Event not found",
        )

    if event.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="You do not own this event")

    save_count = db.query(SavedEventDB).filter(
        SavedEventDB.event_id == event_id
    ).count()

    return {
        "event_id": event_id,
        "views": event.views or 0,
        "save_count": save_count,
    }


@app.get("/my-events/{owner_id}/analytics")
def get_business_analytics(
    owner_id: str,
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(require_business_owner),
):
    require_same_user(owner_id, current_user)
    events = db.query(EventDB).filter(
        EventDB.owner_id == owner_id
    ).all()

    event_ids = [event.id for event in events]

    total_saves = 0

    if event_ids:
        total_saves = db.query(SavedEventDB).filter(
            SavedEventDB.event_id.in_(event_ids)
        ).count()

    total_views = sum((event.views or 0) for event in events)

    return {
        "owner_id": owner_id,
        "total_events": len(events),
        "total_views": total_views,
        "total_saves": total_saves,
    }


# --------------------
# Review Endpoints
# --------------------

@app.get("/events/{event_id}/reviews", response_model=List[schemas.Review])
def get_reviews(
    event_id: str,
    db: Session = Depends(get_db),
):
    return db.query(ReviewDB).filter(
        ReviewDB.event_id == event_id
    ).all()


@app.post("/events/{event_id}/reviews", response_model=schemas.Review)
def create_review(
    event_id: str,
    review: schemas.ReviewCreate,
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_authenticated_user),
):
    event_exists = db.query(EventDB).filter(
        EventDB.id == event_id
    ).first()

    if event_exists is None:
        raise HTTPException(
            status_code=404,
            detail="Event not found",
        )

    new_review = ReviewDB(
        id=str(uuid4()),
        event_id=event_id,
        user_id=current_user.id,
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
def get_saved_events(
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_authenticated_user),
):
    return db.query(SavedEventDB).filter(
        SavedEventDB.user_id == current_user.id
    ).all()


@app.post("/saved-events", response_model=schemas.SavedEvent)
def create_saved_event(
    saved_event: schemas.SavedEventCreate,
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_authenticated_user),
):
    event = db.query(EventDB).filter(
        EventDB.id == saved_event.event_id
    ).first()

    if event is None:
        raise HTTPException(
            status_code=404,
            detail="Event not found",
        )

    already_saved = db.query(SavedEventDB).filter(
        SavedEventDB.event_id == saved_event.event_id,
        SavedEventDB.user_id == current_user.id,
    ).first()

    if already_saved is not None:
        raise HTTPException(
            status_code=400,
            detail="Event already saved",
        )

    new_saved_event = SavedEventDB(
        id=str(uuid4()),
        event_id=saved_event.event_id,
        user_id=current_user.id,
    )

    db.add(new_saved_event)
    db.commit()
    db.refresh(new_saved_event)

    return new_saved_event


@app.delete("/saved-events/{event_id}")
def delete_saved_event(
    event_id: str,
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_authenticated_user),
):
    saved_event = db.query(SavedEventDB).filter(
        SavedEventDB.event_id == event_id,
        SavedEventDB.user_id == current_user.id,
    ).first()

    if saved_event is None:
        raise HTTPException(
            status_code=404,
            detail="Saved event not found",
        )

    db.delete(saved_event)
    db.commit()

    return {"message": "Saved event removed"}
