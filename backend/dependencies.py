from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from database.database import get_db
from database.models import UserDB
from security import decode_access_token


oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")


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


def require_same_user(requested_user_id: str, current_user: UserDB) -> None:
    if requested_user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You cannot access another user's data",
        )
