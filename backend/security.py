import bcrypt
import os
from datetime import datetime, timedelta, timezone

import jwt
from dotenv import load_dotenv


load_dotenv()

JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY")
if not JWT_SECRET_KEY:
    raise RuntimeError("JWT_SECRET_KEY must be configured")
JWT_ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60


def hash_password(password: str) -> str:
    password_bytes = password.encode("utf-8")
    hashed_password = bcrypt.hashpw(
        password_bytes,
        bcrypt.gensalt(),
    )
    return hashed_password.decode("utf-8")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    try:
        return bcrypt.checkpw(
            plain_password.encode("utf-8"),
            hashed_password.encode("utf-8"),
        )
    except ValueError:
        return False


def looks_like_bcrypt_hash(value: str) -> bool:
    if not value:
        return False

    return (
        value.startswith("$2a$")
        or value.startswith("$2b$")
        or value.startswith("$2y$")
    )


def create_access_token(user_id: str) -> str:
    expires_at = datetime.now(timezone.utc) + timedelta(
        minutes=ACCESS_TOKEN_EXPIRE_MINUTES,
    )
    return jwt.encode(
        {"sub": user_id, "exp": expires_at},
        JWT_SECRET_KEY,
        algorithm=JWT_ALGORITHM,
    )


def decode_access_token(token: str) -> str | None:
    try:
        payload = jwt.decode(
            token,
            JWT_SECRET_KEY,
            algorithms=[JWT_ALGORITHM],
        )
        return payload.get("sub")
    except jwt.PyJWTError:
        return None
