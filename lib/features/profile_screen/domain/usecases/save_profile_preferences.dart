import 'package:bdo_event/features/profile_screen/domain/entities/profile_preferences.dart';
import 'package:bdo_event/features/profile_screen/domain/repositories/profile_preferences_repository.dart';

class SaveProfilePreferences {
  const SaveProfilePreferences(this._repository);

  final ProfilePreferencesRepositoryContract _repository;

  Future<void> call(ProfilePreferences preferences) =>
      _repository.save(preferences);
}
