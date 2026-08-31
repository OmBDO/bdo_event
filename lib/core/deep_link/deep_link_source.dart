import 'dart:async';

abstract interface class DeepLinkSource {
  Stream<Uri> get uriStream;

  Future<Uri?> get initialUri;
}
