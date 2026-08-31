abstract final class MigrationManifest {
  static const requiredFiles = <String>[
    '20260829000000_initial_schema.sql',
    '20260829001000_fix_role_request_trigger.sql',
    '20260829002000_event_attendees.sql',
    '20260829003000_notifications_and_arrivals.sql',
    '20260830000000_restrict_attendee_list_access.sql',
    '20260830001000_event_image_storage.sql',
    '20260830002000_use_current_roles_for_attendance.sql',
    '20260830003000_use_current_roles_for_privileged_access.sql',
    '20260830004000_enforce_event_capacity.sql',
    '20260830005000_enforce_registration_deadline.sql',
    '20260830006000_event_registration_counts.sql',
    '20260830007000_watcher_registration_name.sql',
    '20260830008000_watcher_registration_name_fallback.sql',
    '20260830009000_product_capabilities.sql',
    '20260830010000_profile_image_storage.sql',
  ];

  static String get latestFile => requiredFiles.last;

  static String get latestVersion => latestFile.split('_').first;

  static List<String> missingFrom(Iterable<String> availableFiles) {
    final available = availableFiles.toSet();
    return [
      for (final file in requiredFiles)
        if (!available.contains(file)) file,
    ];
  }

  static List<String> unexpectedDuplicates(Iterable<String> files) {
    final counts = <String, int>{};
    for (final file in files) {
      counts[file] = (counts[file] ?? 0) + 1;
    }
    return [
      for (final entry in counts.entries)
        if (entry.value > 1) entry.key,
    ];
  }

  static bool containsLatest(Iterable<String> availableFiles) =>
      availableFiles.contains(latestFile);
}
