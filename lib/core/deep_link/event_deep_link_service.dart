import 'dart:async';

import 'package:app_links/app_links.dart';

class EventDeepLinkService {
  EventDeepLinkService({AppLinks? appLinks}) : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;

  Stream<Uri> get uriStream => _appLinks.uriLinkStream;

  Future<Uri?> get initialUri => _appLinks.getInitialLink();

  static const linkBaseUrl = String.fromEnvironment(
    'EVENT_LINK_BASE_URL',
    defaultValue: 'https://bdo-event.app',
  );

  static Uri eventUri(String eventId) => Uri.parse(
    '$linkBaseUrl/events/${Uri.encodeComponent(eventId)}',
  );

  static String? eventIdFromUri(Uri uri) {
    if (uri.scheme != 'https' && uri.scheme != 'bdoevent') return null;
    if (uri.scheme == 'https' && uri.host != Uri.parse(linkBaseUrl).host) {
      return null;
    }

    final segments = uri.pathSegments;
    if (segments.length != 2 || segments.first != 'events') return null;
    final eventId = Uri.decodeComponent(segments.last).trim();
    return eventId.isEmpty ? null : eventId;
  }
}