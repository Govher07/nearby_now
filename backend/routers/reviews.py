from typing import List
from uuid import uuid4

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

import schemas
from database.database import get_db
from database.models import EventDB, ReviewDB, UserDB
from dependencies import get_authenticated_user


router = APIRouter(tags=["reviews"])


@router.get("/events/{event_id}/reviews", response_model=List[schemas.Review])
def get_reviews(event_id: str, db: Session = Depends(get_db)):
    return db.query(ReviewDB).filter(ReviewDB.event_id == event_id).all()


@router.post("/events/{event_id}/reviews", response_model=schemas.Review)
def create_review(
    event_id: str,
    review: schemas.ReviewCreate,
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_authenticated_user),
):
    event = db.query(EventDB).filter(EventDB.id == event_id).first()
    if event is None:
        raise HTTPException(status_code=404, detail="Event not found")
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
