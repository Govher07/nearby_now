from fastapi.testclient import TestClient

from main import app


client = TestClient(app)


def test_register_returns_token_and_safe_user():
    response = client.post(
        "/register",
        json={
            "name": "Test Owner",
            "email": "owner@example.com",
            "password": "secure-password",
            "role": "business_owner",
        },
    )

    assert response.status_code == 201
    body = response.json()
    assert body["token_type"] == "bearer"
    assert body["access_token"]
    assert body["user"]["email"] == "owner@example.com"
    assert "password" not in body["user"]


def test_protected_endpoint_rejects_missing_token():
    response = client.get("/saved-events")
    assert response.status_code == 401


def test_event_seeker_cannot_create_business_event():
    registration = client.post(
        "/register",
        json={
            "name": "Test Seeker",
            "email": "seeker@example.com",
            "password": "secure-password",
            "role": "event_seeker",
        },
    )
    token = registration.json()["access_token"]

    response = client.post(
        "/events",
        headers={"Authorization": f"Bearer {token}"},
        json={
            "title": "Test Event",
            "description": "Test description",
            "category": "Community",
            "date": "2026-08-10",
            "time": "6:00 PM",
        },
    )

    assert response.status_code == 403


def test_business_owner_cannot_update_another_owners_event():
    first_owner = client.post(
        "/register",
        json={
            "name": "First Owner",
            "email": "first-owner@example.com",
            "password": "secure-password",
            "role": "business_owner",
        },
    ).json()
    second_owner = client.post(
        "/register",
        json={
            "name": "Second Owner",
            "email": "second-owner@example.com",
            "password": "secure-password",
            "role": "business_owner",
        },
    ).json()

    event_payload = {
        "title": "Community Event",
        "description": "An event owned by the first business",
        "category": "Community",
        "date": "2026-08-10",
        "time": "6:00 PM",
        "address_line": "100 Main Street",
        "city": "Issaquah",
        "state": "WA",
        "country": "USA",
        "zip_code": "98027",
    }
    created_event = client.post(
        "/events",
        headers={
            "Authorization": f"Bearer {first_owner['access_token']}",
        },
        json=event_payload,
    )
    assert created_event.status_code == 200

    update_response = client.put(
        f"/events/{created_event.json()['id']}",
        headers={
            "Authorization": f"Bearer {second_owner['access_token']}",
        },
        json={**event_payload, "title": "Stolen Event"},
    )

    assert update_response.status_code == 403
