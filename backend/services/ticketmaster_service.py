import os
from datetime import datetime
from math import atan2, cos, radians, sin, sqrt

import requests
from fastapi import HTTPException


def calculate_distance_miles(
    lat1: float,
    lng1: float,
    lat2: float,
    lng2: float,
) -> float:
    earth_radius_miles = 3958.8
    dlat = radians(lat2 - lat1)
    dlng = radians(lng2 - lng1)
    a = (
        sin(dlat / 2) ** 2
        + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlng / 2) ** 2
    )
    return round(earth_radius_miles * 2 * atan2(sqrt(a), sqrt(1 - a)), 2)


def format_time_to_ampm(time_value: str) -> str:
    if not time_value or time_value == "Unknown time":
        return "Unknown time"
    try:
        return datetime.strptime(time_value, "%H:%M:%S").strftime(
            "%I:%M %p"
        ).lstrip("0")
    except ValueError:
        return time_value


def normalize_ticketmaster_event(
    ticketmaster_event: dict,
    user_lat: float,
    user_lng: float,
) -> dict:
    event_id = ticketmaster_event.get("id", "")
    name = ticketmaster_event.get("name", "External Event")
    url = ticketmaster_event.get("url", "")
    start = ticketmaster_event.get("dates", {}).get("start", {})
    local_date = start.get("localDate", "Unknown date")
    local_time = format_time_to_ampm(start.get("localTime", "Unknown time"))
    images = ticketmaster_event.get("images", [])
    image_url = images[0]["url"] if images else None
    venues = ticketmaster_event.get("_embedded", {}).get("venues", [])
    venue = venues[0] if venues else {}
    venue_name = venue.get("name", "Unknown venue")
    city = venue.get("city", {}).get("name", "")
    state = venue.get("state", {}).get("stateCode", "")
    country = venue.get("country", {}).get("name", "")
    address_line = venue.get("address", {}).get("line1", "")
    zip_code = venue.get("postalCode")
    location = ", ".join(
        part
        for part in [venue_name, address_line, city, state, country, zip_code]
        if part
    )
    coordinates = venue.get("location", {})
    latitude = float(coordinates.get("latitude") or user_lat)
    longitude = float(coordinates.get("longitude") or user_lng)
    classifications = ticketmaster_event.get("classifications", [])
    category = "External"
    if classifications:
        category = classifications[0].get("segment", {}).get("name", "External")

    return {
        "id": f"ticketmaster_{event_id}",
        "title": name,
        "description": f"External event from Ticketmaster. {url}",
        "location": location,
        "category": category,
        "date": local_date,
        "time": local_time,
        "distance": calculate_distance_miles(
            user_lat, user_lng, latitude, longitude
        ),
        "latitude": latitude,
        "longitude": longitude,
        "owner_id": None,
        "image_url": image_url,
        "source": "ticketmaster",
        "address_line": address_line,
        "city": city,
        "state": state,
        "country": country,
        "zip_code": zip_code,
    }


def fetch_ticketmaster_events(
    lat: float,
    lng: float,
    radius: int = 25,
    keyword: str | None = None,
) -> list[dict]:
    api_key = os.getenv("TICKETMASTER_API_KEY")
    if not api_key:
        raise HTTPException(
            status_code=500,
            detail="Ticketmaster API key is not configured",
        )

    params = {
        "apikey": api_key,
        "latlong": f"{lat},{lng}",
        "radius": radius,
        "unit": "miles",
        "size": 20,
        "sort": "date,asc",
        "countryCode": "US",
    }
    if keyword:
        params["keyword"] = keyword

    response = requests.get(
        "https://app.ticketmaster.com/discovery/v2/events.json",
        params=params,
        timeout=10,
    )
    if response.status_code != 200:
        raise HTTPException(
            status_code=response.status_code,
            detail=f"Ticketmaster request failed: {response.text}",
        )

    events = response.json().get("_embedded", {}).get("events", [])
    return [normalize_ticketmaster_event(event, lat, lng) for event in events]
