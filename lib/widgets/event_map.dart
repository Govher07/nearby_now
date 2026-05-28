import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/models/event.dart';

class EventMap extends StatelessWidget {
  final List<Event> events;
  final double height;

  const EventMap({
    super.key,
    required this.events,
    this.height = 250,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Container(
        height: height,
        width: double.infinity,
        alignment: Alignment.center,
        color: Colors.grey[300],
        child: const Text('No events to show on map'),
      );
    }

    final Event firstEvent = events.first;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(
            firstEvent.latitude,
            firstEvent.longitude,
          ),
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.nearby_now',
          ),
          MarkerLayer(
            markers: events.map((event) {
              return Marker(
                point: LatLng(event.latitude, event.longitude),
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_pin,
                  size: 40,
                  color: Colors.red,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}