import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:bdo_event/core/util/event_resource.dart';

class EventDeepLinkService {
  EventDeepLinkService({AppLinks? appLinks}) : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;

  Stream<Uri> get uriStream => _appLinks.uriLinkStream;

  Future<Uri?> get initialUri => _appLinks.getInitialLink();

  static const linkBaseUrl = AppDeepLinks.baseUrl;

  static Uri eventUri(String eventId) => Uri.parse(
    '$linkBaseUrl/${AppDeepLinks.eventsPath}/${Uri.encodeComponent(eventId)}',
  );

  static String? eventIdFromUri(Uri uri) {
    if (uri.scheme != AppDeepLinks.httpsScheme &&
        uri.scheme != AppDeepLinks.customScheme) {
      return null;
    }
    final segments = uri.pathSegments;
    final String? encodedEventId;
    if (uri.scheme == AppDeepLinks.customScheme) {
      if (uri.host != AppDeepLinks.eventsPath || segments.length != 1) {
        return null;
      }
      encodedEventId = segments.single;
    } else {
      if (uri.host != Uri.parse(linkBaseUrl).host ||
          segments.length != 2 ||
          segments.first != AppDeepLinks.eventsPath) {
        return null;
      }
      encodedEventId = segments.last;
    }

    final eventId = encodedEventId.trim();
    return eventId.isEmpty ? null : eventId;
  }
}