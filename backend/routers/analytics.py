from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database.database import get_db
from database.models import EventDB, SavedEventDB, UserDB
from dependencies import require_business_owner, require_same_user


router = APIRouter(tags=["analytics"])


@router.get("/events/{event_id}/save-count")
def get_event_save_count(event_id: str, db: Session = Depends(get_db)):
    event = db.query(EventDB).filter(EventDB.id == event_id).first()
    if event is None:
        raise HTTPException(status_code=404, detail="Event not found")
    return {
        "event_id": event_id,
        "save_count": db.query(SavedEventDB).filter(
            SavedEventDB.event_id == event_id
        ).count(),
    }


@router.post("/events/{event_id}/view")
def add_event_view(event_id: str, db: Session = Depends(get_db)):
    event = db.query(EventDB).filter(EventDB.id == event_id).first()
    if event is None:
        raise HTTPException(status_code=404, detail="Event not found")
    event.views = (event.views or 0) + 1
    db.commit()
    db.refresh(event)
    return {"event_id": event_id, "views": event.views}


@router.get("/events/{event_id}/analytics")
def get_event_analytics(
    event_id: str,
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(require_business_owner),
):
    event = db.query(EventDB).filter(EventDB.id == event_id).first()
    if event is None:
        raise HTTPException(status_code=404, detail="Event not found")
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


@router.get("/my-events/{owner_id}/analytics")
def get_business_analytics(
    owner_id: str,
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(require_business_owner),
):
    require_same_user(owner_id, current_user)
    events = db.query(EventDB).filter(EventDB.owner_id == owner_id).all()
    event_ids = [event.id for event in events]
    total_saves = 0
    if event_ids:
        total_saves = db.query(SavedEventDB).filter(
            SavedEventDB.event_id.in_(event_ids)
        ).count()
    return {
        "owner_id": owner_id,
        "total_events": len(events),
        "total_views": sum((event.views or 0) for event in events),
        "total_saves": total_saves,
    }
