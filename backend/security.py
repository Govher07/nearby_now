import bcrypt


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
