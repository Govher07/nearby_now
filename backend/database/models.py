from sqlalchemy import Column, Float, ForeignKey, Integer, String, UniqueConstraint

from database.database import Base


class UserDB(Base):
    __tablename__ = "users"

    id = Column(String(100), primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    email = Column(String(255), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    role = Column(String(50), nullable=False)

class EventDB(Base):
    __tablename__ = "events"

    id = Column(String(100), primary_key=True, index=True)
    title = Column(String(255), nullable=False)
    description = Column(String(1000), nullable=False)
    category = Column(String(100), nullable=False)
    date = Column(String(100), nullable=False)
    time = Column(String(100), nullable=False)
    distance = Column(Float, default=0.5)
    location = Column(String(255), nullable=True)
    address_line = Column(String(255), nullable=False)
    city = Column(String(100), nullable=False)
    state = Column(String(100), nullable=False)
    country = Column(String(100), nullable=False)
    zip_code = Column(String(30), nullable=False)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    owner_id = Column(String(100), ForeignKey("users.id"), nullable=True)
    image_url = Column(String(1000), nullable=True)
    source = Column(String(100), default="nearby_now")
    views = Column(Integer, default=0)


class ReviewDB(Base):
    __tablename__ = "reviews"

    id = Column(String(100), primary_key=True, index=True)
    event_id = Column(String(100), ForeignKey("events.id"), nullable=False)
    user_id = Column(String(100), ForeignKey("users.id"), nullable=True)
    rating = Column(Integer, nullable=False)
    comment = Column(String(1000), default="")


class SavedEventDB(Base):
    __tablename__ = "saved_events"
    __table_args__ = (
        UniqueConstraint("event_id", "user_id", name="uq_saved_event_user"),
    )

    id = Column(String(100), primary_key=True, index=True)
    event_id = Column(String(100), ForeignKey("events.id"), nullable=False)
    user_id = Column(String(100), ForeignKey("users.id"), nullable=True)

class SavedExternalEventDB(Base):
    __tablename__ = "saved_external_events"
    __table_args__ = (
        UniqueConstraint(
            "external_event_id",
            "user_id",
            name="uq_saved_external_event_user",
        ),
    )

    id = Column(String(100), primary_key=True, index=True)
    external_event_id = Column(String(255), nullable=False)
    user_id = Column(
        String(100),
        ForeignKey("users.id"),
        nullable=False,
    )

    source = Column(String(50), nullable=False, default="ticketmaster")
    title = Column(String(255), nullable=False)
    description = Column(String(1000), nullable=True)
    category = Column(String(100), nullable=True)
    date = Column(String(100), nullable=False)
    time = Column(String(100), nullable=True)
    location = Column(String(1000), nullable=True)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    image_url = Column(String(1000), nullable=True)
    external_url = Column(String(1000), nullable=True)