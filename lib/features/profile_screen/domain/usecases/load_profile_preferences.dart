import 'package:bdo_event/features/profile_screen/domain/entities/profile_preferences.dart';
import 'package:bdo_event/features/profile_screen/domain/repositories/profile_preferences_repository.dart';

class LoadProfilePreferences {
  const LoadProfilePreferences(this._repository);

  final ProfilePreferencesRepositoryContract _repository;

  ProfilePreferences call() => _repository.load();
}
