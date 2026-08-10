from uuid import uuid4

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

import schemas
from database.database import get_db
from database.models import UserDB
from dependencies import get_authenticated_user, require_same_user
from security import create_access_token, hash_password, verify_password


router = APIRouter(tags=["authentication"])


@router.post("/register", response_model=schemas.AuthResponse, status_code=201)
def register_user(
    user: schemas.UserCreate,
    db: Session = Depends(get_db),
):
    existing_user = db.query(UserDB).filter(
        UserDB.email == user.email.lower()
    ).first()
    if existing_user is not None:
        raise HTTPException(status_code=400, detail="Email already registered")

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


@router.post("/login", response_model=schemas.AuthResponse)
def login_user(
    user: schemas.UserLogin,
    db: Session = Depends(get_db),
):
    existing_user = db.query(UserDB).filter(
        UserDB.email == user.email.lower()
    ).first()
    if existing_user is None or not verify_password(
        user.password,
        existing_user.password_hash,
    ):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    return {
        "access_token": create_access_token(existing_user.id),
        "user": existing_user,
    }


@router.get("/me/{user_id}", response_model=schemas.User)
def get_user_profile(
    user_id: str,
    db: Session = Depends(get_db),
    authenticated_user: UserDB = Depends(get_authenticated_user),
):
    require_same_user(user_id, authenticated_user)
    user = db.query(UserDB).filter(UserDB.id == user_id).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user
