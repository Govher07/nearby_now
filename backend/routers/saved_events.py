from typing import List
from uuid import uuid4

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

import schemas
from database.database import get_db
from database.models import EventDB, SavedEventDB, UserDB
from dependencies import get_authenticated_user


router = APIRouter(tags=["saved events"])


@router.get("/saved-events", response_model=List[schemas.SavedEvent])
def get_saved_events(
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_authenticated_user),
):
    return db.query(SavedEventDB).filter(
        SavedEventDB.user_id == current_user.id
    ).all()


@router.post("/saved-events", response_model=schemas.SavedEvent)
def create_saved_event(
    saved_event: schemas.SavedEventCreate,
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_authenticated_user),
):
    event = db.query(EventDB).filter(
        EventDB.id == saved_event.event_id
    ).first()
    if event is None:
        raise HTTPException(status_code=404, detail="Event not found")

    already_saved = db.query(SavedEventDB).filter(
        SavedEventDB.event_id == saved_event.event_id,
        SavedEventDB.user_id == current_user.id,
    ).first()
    if already_saved is not None:
        raise HTTPException(status_code=400, detail="Event already saved")

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
    saved_event = db.query(SavedEventDB).filter(
        SavedEventDB.event_id == event_id,
        SavedEventDB.user_id == current_user.id,
    ).first()
    if saved_event is None:
        raise HTTPException(status_code=404, detail="Saved event not found")
    db.delete(saved_event)
    db.commit()
    return {"message": "Saved event removed"}
