from fastapi.testclient import TestClient

from main import app


client = TestClient(app)


class FakeResponse:
    def __init__(self, status_code, payload):
        self.status_code = status_code
        self._payload = payload

    def json(self):
        return self._payload


def test_geocode_address_success(monkeypatch):
    def fake_get(url, params=None, headers=None, timeout=None):
        return FakeResponse(
            200,
            [
                {
                    "lat": "47.5301",
                    "lon": "-122.0326",
                }
            ],
        )

    monkeypatch.setattr("main.requests.get", fake_get)

    response = client.get(
        "/geocode",
        params={
            "address": "1801 12th Ave, Issaquah, WA, USA, 98029",
        },
    )

    assert response.status_code == 200

    data = response.json()

    assert data["latitude"] == 47.5301
    assert data["longitude"] == -122.0326


def test_geocode_address_not_found(monkeypatch):
    def fake_get(url, params=None, headers=None, timeout=None):
        return FakeResponse(200, [])

    monkeypatch.setattr("main.requests.get", fake_get)

    response = client.get(
        "/geocode",
        params={
            "address": "Address That Does Not Exist",
        },
    )

    assert response.status_code == 404
    assert "Address not found" in response.text


def test_geocode_service_failure(monkeypatch):
    def fake_get(url, params=None, headers=None, timeout=None):
        return FakeResponse(500, {})

    monkeypatch.setattr("main.requests.get", fake_get)

    response = client.get(
        "/geocode",
        params={
            "address": "Seattle, WA",
        },
    )

    assert response.status_code == 500
    assert "Geocoding service failed" in response.text