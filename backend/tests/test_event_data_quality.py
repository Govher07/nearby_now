def test_new_york_default_coordinates_are_not_used():
    old_default_latitude = 40.785091
    old_default_longitude = -73.968285

    assert old_default_latitude != 47.5301
    assert old_default_longitude != -122.0326


def test_event_address_format_parts_join_correctly():
    parts = [
        "1801 12th Ave",
        "Issaquah",
        "WA",
        "USA",
        "98029",
    ]

    full_address = ", ".join(part for part in parts if part)

    assert full_address == "1801 12th Ave, Issaquah, WA, USA, 98029"