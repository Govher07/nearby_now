# Nearby Now

[![CI](https://github.com/Govher07/nearby_now/actions/workflows/ci.yml/badge.svg)](https://github.com/Govher07/nearby_now/actions/workflows/ci.yml)

Nearby Now is a full-stack event discovery application that helps users find nearby activities and gives local businesses tools to publish events and understand audience engagement.

The Flutter client combines community-created events with Ticketmaster listings, calculates distance from the user’s location, displays events on an interactive map, and supports saved events and community reviews. Business owners can create and manage events while tracking views and saves.

![Nearby Now mode selection](docs/screenshots/01-mode-selection.png)

## Features

### Event seekers

- Discover community-created and Ticketmaster events
- Hide outdated events from public discovery
- Order events from nearest to farthest
- Filter events by category and date
- Calculate distance using the device location
- Explore event locations on an interactive map
- Save Nearby Now and Ticketmaster events
- Organize saved events into upcoming and past sections
- Leave ratings and reviews on Nearby Now community events
- Open directions to an event
- Stay signed in with an optional Remember Me setting
- Use browser-managed password autofill

### Business owners

- Create, edit, and delete events
- Manage published events
- View event and account-level analytics
- Track event views and saves
- Review customer feedback
- Protect event-management actions with role-based authorization

### Engineering

- JWT authentication and role-based authorization
- Password hashing
- Environment-based backend and Flutter configuration
- Modular FastAPI routers and service layers
- SQLAlchemy database models and constraints
- Backend authentication and API tests
- Flutter unit tests and static analysis
- Automated GitHub Actions continuous integration

## Screenshots

### Discover nearby events

Upcoming events from Nearby Now and Ticketmaster are combined and ordered by distance.

![Discover nearby events](docs/screenshots/02-event-discovery.png)

### Save local and Ticketmaster events

Users can save events from either source. Saved events are organized into upcoming and past sections.

![Saved events](docs/screenshots/03-saved-events.png)

### Manage business events

Business owners can view event information, edit details, delete events, and monitor reviews.

![Business event details](docs/screenshots/04-business-event-details.png)

## Technology

| Layer | Technology |
| --- | --- |
| Client | Flutter and Dart |
| API | FastAPI and Python |
| Database | MySQL, SQLAlchemy, and PyMySQL |
| Authentication | JWT and password hashing |
| Maps and location | `flutter_map`, Geolocator, OpenStreetMap, and Nominatim |
| Directions | Google Maps directions links |
| External events | Ticketmaster Discovery API |
| Backend testing | pytest and FastAPI TestClient |
| Flutter testing | `flutter_test` and `flutter analyze` |
| Continuous integration | GitHub Actions |

## Architecture

```text
Flutter client
   |
   |-- REST requests ----------------------> FastAPI
   |                                          |
   |                                          |-- SQLAlchemy --> MySQL
   |                                          |
   |                                          |-- Ticketmaster Discovery API
   |                                          |
   |                                          `-- OpenStreetMap Nominatim
   |
   `-- Device location and map rendering
```

The backend is organized into focused modules:

- Routers handle HTTP requests and responses.
- Services handle Ticketmaster and geocoding integrations.
- Dependencies handle authentication and authorization.
- SQLAlchemy models handle persistent data.
- Pydantic schemas validate API input and output.

## Authentication and authorization

Nearby Now uses JWT access tokens to authenticate API requests.

Protected operations include:

- Creating, editing, and deleting business events
- Accessing business analytics
- Saving and removing events
- Creating reviews
- Accessing user-specific resources

The backend verifies ownership before allowing a business owner to modify an event. Client-provided user IDs are not trusted as proof of identity.

Passwords are hashed before being stored. Plain-text passwords are never stored by Nearby Now. Browser password saving and autofill are handled by the user’s password manager.

## Saved-event design

Nearby Now supports saving events from two different sources:

- Community events stored in the main `events` table
- Ticketmaster events stored as external saved-event snapshots

External events are not treated as business-created Nearby Now events. This keeps third-party data separate while allowing users to retain event details in their Saved Events screen.

Saved events are grouped into:

- Upcoming Events
- Past Events

Past saved events are retained so users can review their event history or remove events manually.

## Run locally

### Prerequisites

- Flutter SDK compatible with Dart `^3.11.5`
- Python 3.11 or newer
- MySQL
- Ticketmaster Discovery API key

### 1. Clone the repository

```bash
git clone https://github.com/Govher07/nearby_now.git
cd nearby_now
```

### 2. Configure the environment

Copy the example environment file:

```bash
cp .env.example .env
```

Edit `.env` with your local configuration:

```env
DATABASE_URL=mysql+pymysql://YOUR_USER:YOUR_PASSWORD@localhost/nearby_now
TICKETMASTER_API_KEY=YOUR_TICKETMASTER_KEY
JWT_SECRET_KEY=YOUR_LONG_RANDOM_SECRET
ALLOWED_ORIGINS=http://localhost:8080,http://127.0.0.1:8080
```

Generate a JWT secret:

```bash
openssl rand -hex 32
```

Never commit the completed `.env` file.

### 3. Create the database

Open MySQL and run:

```sql
CREATE DATABASE nearby_now;
```

SQLAlchemy creates the application tables when the backend starts.

Database migrations are not yet managed with Alembic.

### 4. Install and run the backend

```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload
```

The API is available at:

```text
http://127.0.0.1:8000
```

Interactive API documentation is available at:

```text
http://127.0.0.1:8000/docs
```

### 5. Run Flutter Web

Open another terminal from the repository root:

```bash
flutter pub get
flutter run -d chrome --web-port=8080
```

The fixed port matches the backend’s local CORS configuration.

The Flutter client defaults to:

```text
http://127.0.0.1:8000
```

To use a different backend address:

```bash
flutter run -d chrome \
  --web-port=8080 \
  --dart-define=API_BASE_URL=http://YOUR_BACKEND_ADDRESS:8000
```

For a physical device, use the computer’s local network address rather than `127.0.0.1`.

## Testing

### Flutter

From the repository root:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

### Backend

From the `backend` directory with the virtual environment active:

```bash
python -m pytest
```

### Continuous integration

GitHub Actions automatically runs the backend and Flutter checks for pushes and pull requests.

The CI workflow verifies:

- Python dependency installation
- Backend tests and coverage
- Flutter dependency installation
- Flutter static analysis
- Flutter tests

## Project structure

```text
lib/
  core/
    config/          Environment-based Flutter configuration
    data/            Current-user and token storage
    models/          Flutter data models
    services/        API and location services
    util/            Shared utility functions
  screens/           Event-seeker, authentication, and business screens
  widgets/           Reusable Flutter UI components

backend/
  database/          SQLAlchemy configuration and database models
  routers/           Authentication, event, review, and saved-event routes
  services/          Ticketmaster and geocoding integrations
  tests/             Authentication and API tests
  dependencies.py    Authentication and authorization dependencies
  main.py            FastAPI application configuration
  schemas.py         Pydantic request and response schemas
  security.py        Password hashing and JWT utilities

docs/
  screenshots/       Portfolio screenshots

assets/
  images/            Local event and category images

test/                 Flutter unit tests
```

## Current limitations

- The backend currently runs locally and is not publicly deployed.
- Database schema migrations are not yet managed with Alembic.
- Flutter Web does not yet use URL-based deep linking for every screen, so refreshing a nested page may return to the main navigation screen.
- Access tokens use `shared_preferences`; secure mobile storage is recommended before a production mobile release.
- Ticketmaster events cannot receive Nearby Now reviews because reviews are limited to community-created events.

## Roadmap

- Add Alembic database migrations
- Add URL-based routing and deep links for Flutter Web
- Add refresh-token support
- Use secure token storage for production mobile releases
- Expand integration and authorization tests
- Deploy the API
- Publish a hosted demo

## Author

Built by [Govher07](https://github.com/Govher07) as a full-stack portfolio project focused on Flutter development, API design, location-based discovery, authentication, third-party integrations, automated testing, and relational data modeling.
