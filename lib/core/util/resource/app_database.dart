
abstract final class AppDatabase {
  static const eventsTable = 'events';
  static const eventRegistrationsTable = 'event_registrations';
  static const id = 'id';
  static const eventId = 'event_id';
  static const userId = 'user_id';
  static const creatorId = 'creator_id';
  static const createdAt = 'created_at';
  static const registeredAt = 'registered_at';
  static const registrationStatus = 'status';
  static const cancelledAt = 'cancelled_at';
  static const registrationToken = 'registration_token';
  static const checkInsTable = 'event_check_ins';
  static const checkedInAt = 'checked_in_at';
  static const checkedInBy = 'checked_in_by';
  static const activeRegistration = 'active';
  static const revokedRegistration = 'revoked';
  static const payload = 'payload';
  static const isCheckedIn = 'is_checked_in';
}