from typing import Literal

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class UserCreate(BaseModel):
    name: str = Field(min_length=2, max_length=100)
    email: EmailStr
    password: str = Field(min_length=8, max_length=72)
    role: Literal["event_seeker", "business_owner"]


class UserLogin(BaseModel):
    email: EmailStr
    password: str = Field(min_length=1, max_length=72)


class User(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    name: str
    email: str
    role: str

class AuthResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: User


class EventCreate(BaseModel):
    title: str = Field(min_length=2, max_length=255)
    description: str = Field(min_length=2, max_length=1000)
    location: str | None = None
    category: str
    date: str
    time: str
    distance: float = Field(default=0.5, ge=0)
    address_line: str | None = None
    city: str | None = None
    state: str | None = None
    country: str | None = None
    zip_code: str | None = None
    latitude: float | None = Field(default=None, ge=-90, le=90)
    longitude: float | None = Field(default=None, ge=-180, le=180)
    owner_id: str | None = None
    image_url: str | None = None
    source: str | None = "nearby_now"


class Event(EventCreate):
    model_config = ConfigDict(from_attributes=True)

    id: str
    views: int = 0


class ReviewCreate(BaseModel):
    rating: int = Field(ge=1, le=5)
    comment: str = Field(default="", max_length=1000)
    user_id: str | None = None


class Review(ReviewCreate):
    model_config = ConfigDict(from_attributes=True)

    id: str
    event_id: str


class SavedEventCreate(BaseModel):
    event_id: str
    source: str = "nearby_now"

    title: str | None = None
    description: str | None = None
    category: str | None = None
    date: str | None = None
    time: str | None = None
    location: str | None = None
    latitude: float | None = None
    longitude: float | None = None
    image_url: str | None = None
    external_url: str | None = None

    user_id: str | None = None


class SavedEvent(SavedEventCreate):
    model_config = ConfigDict(from_attributes=True)

    id: str

class SavedEventDetails(BaseModel):
    id: str
    title: str
    description: str | None = None
    category: str | None = None
    date: str
    time: str | None = None
    location: str | None = None
    latitude: float | None = None
    longitude: float | None = None
    image_url: str | None = None
    external_url: str | None = None
    source: str = "nearby_now"

    model_config = ConfigDict(from_attributes=True)
