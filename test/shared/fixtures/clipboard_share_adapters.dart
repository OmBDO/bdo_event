import 'package:bdo_event/core/common/clipboard_share.dart';
import 'package:share_plus/share_plus.dart';

class RecordingClipboardAdapter implements ClipboardAdapter {
  RecordingClipboardAdapter({this.error});

  final Object? error;
  String? text;

  @override
  Future<void> setText(String text) async {
    if (error != null) throw error!;
    this.text = text;
  }
}

class RecordingShareAdapter implements ShareAdapter {
  RecordingShareAdapter({this.error});

  final Object? error;
  ShareParams? params;

  @override
  Future<ShareResult> share(ShareParams params) async {
    if (error != null) throw error!;
    this.params = params;
    return ShareResult.unavailable;
  }
}
