enum ProfileVisibility {
  private('private', 'Only me'),
  registeredUsers('registered_users', 'Registered users'),
  public('public', 'Everyone');

  const ProfileVisibility(this.storageValue, this.label);

  final String storageValue;
  final String label;

  static ProfileVisibility fromStorage(String? value) => values.firstWhere(
    (visibility) => visibility.storageValue == value,
    orElse: () => ProfileVisibility.private,
  );
}

enum RegistrationVisibility {
  private('private', 'Only me'),
  organizers('organizers', 'Organizers'),
  public('public', 'Everyone');

  const RegistrationVisibility(this.storageValue, this.label);

  final String storageValue;
  final String label;

  static RegistrationVisibility fromStorage(String? value) => values.firstWhere(
    (visibility) => visibility.storageValue == value,
    orElse: () => RegistrationVisibility.private,
  );
}