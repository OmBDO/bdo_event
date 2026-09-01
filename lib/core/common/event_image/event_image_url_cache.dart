class ExpiringImageUrlCache {
  ExpiringImageUrlCache({
    this.maxEntries = 100,
    this.timeToLive = const Duration(minutes: 50),
  }) : assert(maxEntries > 0);

  final int maxEntries;
  final Duration timeToLive;
  final _entries = <String, _CacheEntry>{};

  String? get(String path, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    _removeExpired(currentTime);
    final entry = _entries.remove(path);
    if (entry == null) return null;
    _entries[path] = entry;
    return entry.url;
  }

  void put(String path, String url, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    _removeExpired(currentTime);
    _entries.remove(path);
    _entries[path] = _CacheEntry(
      url: url,
      expiresAt: currentTime.add(timeToLive),
    );
    while (_entries.length > maxEntries) {
      _entries.remove(_entries.keys.first);
    }
  }

  void _removeExpired(DateTime now) {
    _entries.removeWhere((path, entry) => !entry.expiresAt.isAfter(now));
  }
}

class _CacheEntry {
  const _CacheEntry({required this.url, required this.expiresAt});

  final String url;
  final DateTime expiresAt;
}
