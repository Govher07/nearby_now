# Nearby Now

Nearby Now is a full-stack event discovery application that helps people find nearby activities and helps local businesses publish events and understand audience engagement.

The Flutter client combines community-created events with Ticketmaster listings, calculates distance from the user's location, displays events on a map, and supports saved events and reviews. Business accounts can create and manage events and view basic analytics such as views and saves.

> This project is under active development. Authentication and deployment improvements are in progress; see [Current limitations](#current-limitations).

## Features

### Event seekers

- Discover internal and Ticketmaster events
- Filter events by category and date
- Calculate distance using the device location
- Explore events on a map
- Save events and leave ratings and reviews
- Open directions to an event

### Business owners

- Create, edit, and delete events
- Manage published events
- View event and account-level view/save analytics

## Technology

| Layer | Technology |
|---|---|
| Client | Flutter and Dart |
| API | FastAPI and Python |
| Database | MySQL, SQLAlchemy, and PyMySQL |
| Maps/location | flutter_map, Google Maps, Geolocator, OpenStreetMap Nominatim |
| External events | Ticketmaster Discovery API |
| Testing | flutter_test, pytest, FastAPI TestClient |

## Architecture

```text
Flutter client
   |-- REST requests --> FastAPI
   |                       |-- SQLAlchemy --> MySQL
   |                       |-- Ticketmaster Discovery API
   |                       `-- OpenStreetMap Nominatim
   `-- Device location and map rendering
```

## Run locally

### Prerequisites

- Flutter SDK compatible with Dart `^3.11.5`
- Python 3.11 or newer
- MySQL
- Ticketmaster Discovery API key for external events

### 1. Configure the backend

```bash
cp .env.example .env
```

Edit `.env` with your database credentials and Ticketmaster API key. Never commit the completed `.env` file.

Create the database:

```sql
CREATE DATABASE nearby_now;
```

Install and run the API:

```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload
```

The API is available at `http://127.0.0.1:8000`. Interactive API documentation is at `http://127.0.0.1:8000/docs`.

### 2. Run Flutter

From the repository root:

```bash
flutter pub get
flutter run
```

The client defaults to `http://127.0.0.1:8000`. Override it for a physical device or deployed API:

```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_COMPUTER_IP:8000
```

## Tests

Run the Flutter tests and analyzer:

```bash
flutter test
flutter analyze
```

Run the backend tests from `backend/` with the virtual environment active:

```bash
pytest
```

## Project structure

```text
lib/
  core/       Models, constants, storage, and API services
  screens/    User and business screens
  widgets/    Reusable Flutter widgets
backend/
  database/   SQLAlchemy configuration and models
  tests/      API and data-quality tests
  main.py     FastAPI application and routes
assets/       Local event/category imagery
test/         Flutter unit tests
```

## Current limitations

- The API is currently designed for local development and is not deployed.
- Access tokens are currently stored with `shared_preferences`; secure mobile storage is planned before release.
- The backend routes are being separated into smaller router and service modules.
- Database migrations are not yet configured.
- Screenshots and a hosted demo will be added after the security work is complete.

## Roadmap

- Refresh tokens and secure mobile token storage
- Environment-based Flutter API configuration
- Alembic database migrations
- Integration and authorization tests
- Automated checks with GitHub Actions
- Hosted demo and production deployment

## Author

Built by [Govher07](https://github.com/Govher07) as a full-stack portfolio project focused on mobile development, API design, location-based discovery, third-party integrations, and relational data modeling.
