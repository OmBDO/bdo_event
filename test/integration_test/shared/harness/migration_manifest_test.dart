import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'migration_manifest.dart';

void main() {
  test('repository contains every required migration exactly once', () {
    final directory = Directory('supabase/migrations');
    final files = directory
        .listSync()
        .whereType<File>()
        .map((file) => file.uri.pathSegments.last)
        .toList();

    expect(MigrationManifest.missingFrom(files), isEmpty);
    expect(MigrationManifest.unexpectedDuplicates(files), isEmpty);
    expect(MigrationManifest.containsLatest(files), isTrue);
    expect(MigrationManifest.latestVersion, '20260830010000');
  });

  test('reports missing migrations from an available-file list', () {
    final missing = MigrationManifest.missingFrom(const [
      '20260829000000_initial_schema.sql',
    ]);

    expect(missing, hasLength(MigrationManifest.requiredFiles.length - 1));
    expect(missing, isNot(contains('20260829000000_initial_schema.sql')));
  });

  test('reports duplicate migration names', () {
    final duplicate = MigrationManifest.unexpectedDuplicates(const [
      'one.sql',
      'two.sql',
      'one.sql',
    ]);

    expect(duplicate, ['one.sql']);
  });

  test('reports when the latest migration is absent', () {
    expect(
      MigrationManifest.containsLatest(const [
        '20260829000000_initial_schema.sql',
      ]),
      isFalse,
    );
  });
}
