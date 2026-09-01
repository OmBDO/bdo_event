import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

abstract interface class ClipboardAdapter {
  Future<void> setText(String text);
}

Future<bool> tryCopyText(ClipboardAdapter adapter, String text) async {
  try {
    await adapter.setText(text);
    return true;
  } on Object {
    return false;
  }
}

class SystemClipboardAdapter implements ClipboardAdapter {
  const SystemClipboardAdapter();

  @override
  Future<void> setText(String text) => Clipboard.setData(
    ClipboardData(text: text),
  );
}

abstract interface class ShareAdapter {
  Future<ShareResult> share(ShareParams params);
}

Future<ShareResult?> tryShareContent(
  ShareAdapter adapter,
  ShareParams params,
) async {
  try {
    return await adapter.share(params);
  } on Object {
    return null;
  }
}

class SharePlusAdapter implements ShareAdapter {
  const SharePlusAdapter();

  @override
  Future<ShareResult> share(ShareParams params) =>
      SharePlus.instance.share(params);
}
