import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LocationSearchResult {
  const LocationSearchResult({
    required this.coordinates,
    required this.displayName,
  });

  final LatLng coordinates;
  final String displayName;
}

abstract interface class LocationSearchAdapter {
  Future<LocationSearchResult?> search(String query);

  void dispose();
}

class NominatimLocationSearchAdapter implements LocationSearchAdapter {
  NominatimLocationSearchAdapter({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<LocationSearchResult?> search(String query) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'jsonv2',
      'limit': '1',
    });
    final response = await _client.get(
      uri,
      headers: {'User-Agent': 'bdo-event'},
    );
    if (response.statusCode != 200) return null;

    final decoded = jsonDecode(response.body);
    if (decoded is! List || decoded.isEmpty) return null;
    final result = decoded.first;
    if (result is! Map<String, dynamic>) return null;
    final latitude = double.tryParse(result['lat'] as String? ?? '');
    final longitude = double.tryParse(result['lon'] as String? ?? '');
    if (latitude == null || longitude == null) return null;

    return LocationSearchResult(
      coordinates: LatLng(latitude, longitude),
      displayName: result['display_name'] as String? ?? query,
    );
  }

  @override
  void dispose() => _client.close();
}
