import 'package:bdo_event/features/profile_screen/domain/entities/profile_preferences.dart';

abstract interface class ProfilePreferencesRepositoryContract {
  ProfilePreferences load();

  Future<void> save(ProfilePreferences preferences);
}
