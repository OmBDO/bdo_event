import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class EventLocationMap extends StatelessWidget {
  const EventLocationMap({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final hasCoordinates = event.latitude != null && event.longitude != null;
    if (!hasCoordinates) {
      return Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4F3),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: Text(
            'Map location is not available for this event yet.',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    final point = LatLng(event.latitude!, event.longitude!);
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: FlutterMap(
          options: MapOptions(initialCenter: point, initialZoom: 14),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.bdo.event',
            ),
            const RichAttributionWidget(
              attributions: [TextSourceAttribution('OpenStreetMap contributors')],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: point,
                  width: 46,
                  height: 46,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.deepOrange,
                    size: 44,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
