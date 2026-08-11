from typing import List
from uuid import uuid4

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

import schemas
from database.database import get_db
from database.models import EventDB, SavedEventDB, SavedExternalEventDB, UserDB
from dependencies import get_authenticated_user


router = APIRouter(tags=["saved events"])


@router.get(
    "/saved-events",
    response_model=List[schemas.SavedEventDetails],
)
def get_saved_events(
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_authenticated_user),
):
    local_events = (
        db.query(EventDB)
        .join(
            SavedEventDB,
            SavedEventDB.event_id == EventDB.id,
        )
        .filter(SavedEventDB.user_id == current_user.id)
        .all()
    )

    saved_external_events = (
        db.query(SavedExternalEventDB)
        .filter(SavedExternalEventDB.user_id == current_user.id)
        .all()
    )

    external_events = [
        {
            "id": event.external_event_id,
            "title": event.title,
            "description": event.description,
            "category": event.category,
            "date": event.date,
            "time": event.time,
            "location": event.location,
            "latitude": event.latitude,
            "longitude": event.longitude,
            "image_url": event.image_url,
            "external_url": event.external_url,
            "source": event.source,
        }
        for event in saved_external_events
    ]

    return [
        *local_events,
        *external_events,
    ]


@router.post("/saved-events", response_model=schemas.SavedEvent)
def create_saved_event(
    saved_event: schemas.SavedEventCreate,
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_authenticated_user),
):
    if saved_event.source == "ticketmaster":
        already_saved = (
            db.query(SavedExternalEventDB)
            .filter(
                SavedExternalEventDB.external_event_id
                == saved_event.event_id,
                SavedExternalEventDB.user_id == current_user.id,
            )
            .first()
        )

        if already_saved is not None:
            raise HTTPException(
                status_code=400,
                detail="Event already saved",
            )

        if not saved_event.title or not saved_event.date:
            raise HTTPException(
                status_code=400,
                detail="Ticketmaster event title and date are required",
            )

        new_external_event = SavedExternalEventDB(
            id=str(uuid4()),
            external_event_id=saved_event.event_id,
            user_id=current_user.id,
            source="ticketmaster",
            title=saved_event.title,
            description=saved_event.description,
            category=saved_event.category,
            date=saved_event.date,
            time=saved_event.time,
            location=saved_event.location,
            latitude=saved_event.latitude,
            longitude=saved_event.longitude,
            image_url=saved_event.image_url,
            external_url=saved_event.external_url,
        )

        db.add(new_external_event)
        db.commit()
        db.refresh(new_external_event)

        return {
            "id": new_external_event.id,
            "event_id": new_external_event.external_event_id,
            "user_id": new_external_event.user_id,
        }

    event = (
        db.query(EventDB)
        .filter(EventDB.id == saved_event.event_id)
        .first()
    )

    if event is None:
        raise HTTPException(
            status_code=404,
            detail="Event not found",
        )

    already_saved = (
        db.query(SavedEventDB)
        .filter(
            SavedEventDB.event_id == saved_event.event_id,
            SavedEventDB.user_id == current_user.id,
        )
        .first()
    )

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

@router.delete("/saved-events/{event_id}")
def delete_saved_event(
    event_id: str,
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_authenticated_user),
):
    saved_local_event = (
        db.query(SavedEventDB)
        .filter(
            SavedEventDB.event_id == event_id,
            SavedEventDB.user_id == current_user.id,
        )
        .first()
    )

    if saved_local_event is not None:
        db.delete(saved_local_event)
        db.commit()
        return {"message": "Saved event removed"}

    saved_external_event = (
        db.query(SavedExternalEventDB)
        .filter(
            SavedExternalEventDB.external_event_id == event_id,
            SavedExternalEventDB.user_id == current_user.id,
        )
        .first()
    )

    if saved_external_event is not None:
        db.delete(saved_external_event)
        db.commit()
        return {"message": "Saved event removed"}

    raise HTTPException(
        status_code=404,
        detail="Saved event not found",
    )
