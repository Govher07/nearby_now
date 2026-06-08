import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/models/event.dart';
import '../core/services/event_service.dart';
import '../core/services/location_service.dart';
import 'event_details_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late Future<_MapData> mapFuture;

  @override
  void initState() {
    super.initState();
    mapFuture = loadMapData();
  }

  Future<_MapData> loadMapData() async {
    final List<Event> events = await EventService.fetchAllEvents();

    LatLng? currentUserLocation;

    try {
      final position = await LocationService.getCurrentLocation();

      currentUserLocation = LatLng(
        position.latitude,
        position.longitude,
      );
    } catch (error) {
      debugPrint('Could not get user location: $error');
    }

    return _MapData(
      events: events,
      userLocation: currentUserLocation,
    );
  }

  void refreshEvents() {
    setState(() {
      mapFuture = loadMapData();
    });
  }

  LatLng getMapCenter({
    required List<Event> events,
    required LatLng? userLocation,
  }) {
    if (userLocation != null) {
      return userLocation;
    }

    if (events.isNotEmpty) {
      return LatLng(
        events.first.latitude,
        events.first.longitude,
      );
    }

    // Last fallback only if location fails and there are no events.
    return const LatLng(47.6062, -122.3321);
  }

  void openEventPreview(Event event) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(event.category),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 17),
                  const SizedBox(width: 6),
                  Text('${event.date} • ${event.time}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(event.fullAddress),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailsScreen(event: event),
                      ),
                    );
                  },
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Marker> buildEventMarkers(List<Event> events) {
    return events.map((event) {
      return Marker(
        point: LatLng(event.latitude, event.longitude),
        width: 48,
        height: 48,
        child: GestureDetector(
          onTap: () {
            openEventPreview(event);
          },
          child: const Icon(
            Icons.location_on,
            size: 42,
            color: Colors.red,
          ),
        ),
      );
    }).toList();
  }

  Marker? buildUserMarker(LatLng? userLocation) {
    if (userLocation == null) {
      return null;
    }

    return Marker(
      point: userLocation,
      width: 44,
      height: 44,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.20),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.my_location,
          color: Colors.blue,
          size: 30,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<_MapData>(
        future: mapFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Could not load map events.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final _MapData data = snapshot.data ??
              const _MapData(
                events: [],
                userLocation: null,
              );

          final List<Event> events = data.events;
          final LatLng? userLocation = data.userLocation;

          final List<Marker> markers = [
            ...buildEventMarkers(events),
            if (buildUserMarker(userLocation) != null)
              buildUserMarker(userLocation)!,
          ];

          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: getMapCenter(
                    events: events,
                    userLocation: userLocation,
                  ),
                  initialZoom: 12,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.nearby_now',
                  ),
                  MarkerLayer(
                    markers: markers,
                  ),
                ],
              ),
              Positioned(
                top: 48,
                left: 16,
                right: 16,
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.map_outlined),
                    title: const Text('Event Map'),
                    subtitle: Text('${events.length} event locations shown'),
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: refreshEvents,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MapData {
  final List<Event> events;
  final LatLng? userLocation;

  const _MapData({
    required this.events,
    required this.userLocation,
  });
}