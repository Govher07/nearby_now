from typing import List
from uuid import uuid4

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

import schemas
from database.database import get_db
from database.models import EventDB, ReviewDB, SavedEventDB, UserDB
from dependencies import require_business_owner, require_same_user
from services.geocoding_service import geocode_address
from services.ticketmaster_service import fetch_ticketmaster_events


router = APIRouter(tags=["events"])


@router.get("/geocode")
def geocode(address: str = Query(...)):
    return geocode_address(address)


@router.get("/events", response_model=List[schemas.Event])
def get_events(db: Session = Depends(get_db)):
    return db.query(EventDB).all()


@router.get("/my-events/{owner_id}", response_model=List[schemas.Event])
def get_my_events(
    owner_id: str,
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(require_business_owner),
):
    require_same_user(owner_id, current_user)
    return db.query(EventDB).filter(EventDB.owner_id == owner_id).all()


@router.post("/events", response_model=schemas.Event)
def create_event(
    event: schemas.EventCreate,
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(require_business_owner),
):
    full_location = ", ".join(
        part
        for part in [
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


@router.put("/events/{event_id}", response_model=schemas.Event)
def update_event(
    event_id: str,
    updated_event: schemas.EventCreate,
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(require_business_owner),
):
    event = db.query(EventDB).filter(EventDB.id == event_id).first()
    if event is None:
        raise HTTPException(status_code=404, detail="Event not found")
    if event.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="You do not own this event")

    full_location = ", ".join(
        part
        for part in [
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


@router.delete("/events/{event_id}")
def delete_event(
    event_id: str,
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(require_business_owner),
):
    event = db.query(EventDB).filter(EventDB.id == event_id).first()
    if event is None:
        raise HTTPException(status_code=404, detail="Event not found")
    if event.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="You do not own this event")

    db.query(ReviewDB).filter(ReviewDB.event_id == event_id).delete()
    db.query(SavedEventDB).filter(SavedEventDB.event_id == event_id).delete()
    db.delete(event)
    db.commit()
    return {"message": "Event deleted"}


@router.get("/external-events")
def get_external_events(
    lat: float,
    lng: float,
    radius: int = Query(default=25, ge=1, le=100),
    keyword: str | None = None,
):
    return fetch_ticketmaster_events(lat, lng, radius, keyword)
