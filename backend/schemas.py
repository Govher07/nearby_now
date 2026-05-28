from pydantic import BaseModel


class UserCreate(BaseModel):
    name: str
    email: str
    password: str
    role: str


class UserLogin(BaseModel):
    email: str
    password: str


class User(BaseModel):
    id: str
    name: str
    email: str
    role: str

    class Config:
        from_attributes = True


class EventCreate(BaseModel):
    title: str
    description: str
    location: str | None = None
    category: str
    date: str
    time: str
    distance: float = 0.5
    address_line: str | None = None
    city: str | None = None
    state: str | None = None
    country: str | None = None
    zip_code: str | None = None
    latitude: float | None = None
    longitude: float | None = None
    owner_id: str | None = None
    image_url: str | None = None
    source: str | None = "nearby_now"


class Event(EventCreate):
    id: str

    class Config:
        from_attributes = True


class ReviewCreate(BaseModel):
    rating: int
    comment: str = ""
    user_id: str | None = None


class Review(ReviewCreate):
    id: str
    event_id: str

    class Config:
        from_attributes = True


class SavedEventCreate(BaseModel):
    event_id: str
    user_id: str | None = None


class SavedEvent(SavedEventCreate):
    id: str

    class Config:
        from_attributes = True