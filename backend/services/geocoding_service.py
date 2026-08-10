import requests
from fastapi import HTTPException


def geocode_address(address: str) -> dict:
    cleaned_address = address.strip()
    if not cleaned_address:
        raise HTTPException(status_code=400, detail="Address is required")

    address_parts = [
        part.strip()
        for part in cleaned_address.split(",")
        if part.strip()
    ]
    search_queries = [cleaned_address]

    if len(address_parts) >= 4:
        search_queries.append(", ".join(address_parts[1:]))
    if len(address_parts) >= 5:
        search_queries.append(
            f"{address_parts[1]}, {address_parts[2]} {address_parts[4]}"
        )
    if len(address_parts) >= 3:
        search_queries.append(f"{address_parts[1]}, {address_parts[2]}")

    search_queries = list(dict.fromkeys(search_queries))
    service_failed = False

    for query in search_queries:
        response = requests.get(
            "https://nominatim.openstreetmap.org/search",
            params={
                "q": query,
                "format": "json",
                "limit": 1,
                "countrycodes": "us",
                "addressdetails": 1,
            },
            headers={"User-Agent": "nearby-now-local-dev/1.0"},
            timeout=10,
        )

        if response.status_code != 200:
            service_failed = True
            continue

        results = response.json()
        if results:
            first_result = results[0]
            return {
                "latitude": float(first_result["lat"]),
                "longitude": float(first_result["lon"]),
                "matched_address": first_result.get("display_name", query),
                "searched_query": query,
            }

    if service_failed:
        raise HTTPException(status_code=502, detail="Geocoding service failed")

    raise HTTPException(
        status_code=404,
        detail=f"Address not found. Tried: {search_queries}",
    )
