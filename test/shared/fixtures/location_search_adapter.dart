import 'package:bdo_event/core/common/location_search.dart';
import 'package:latlong2/latlong.dart';

class RecordingLocationSearchAdapter implements LocationSearchAdapter {
  RecordingLocationSearchAdapter({String displayName = 'Found place'})
    : result = LocationSearchResult(
        coordinates: const LatLng(18.5204, 73.8567),
        displayName: displayName,
      );

  final LocationSearchResult result;
  String? query;

  @override
  Future<LocationSearchResult?> search(String query) async {
    this.query = query;
    return result;
  }

  @override
  void dispose() {}
}
