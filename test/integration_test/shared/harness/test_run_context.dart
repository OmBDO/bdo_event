class TestRunContext {
  const TestRunContext(this.runId);

  factory TestRunContext.create({String? seed}) {
    final source = seed?.trim().isNotEmpty == true
        ? seed!.trim()
        : DateTime.now().toUtc().microsecondsSinceEpoch.toString();
    return TestRunContext(_normalize(source));
  }

  final String runId;

  String namespace(String testId) {
    final normalizedTestId = _normalize(testId);
    return '$runId-$normalizedTestId';
  }

  static String _normalize(String value) {
    final normalized = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return normalized.isEmpty ? 'run' : normalized;
  }
}
