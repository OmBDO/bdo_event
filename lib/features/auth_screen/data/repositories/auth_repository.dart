import 'dart:developer' as developer;

import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/features/auth_screen/data/datasource/auth_remote_data_source.dart';
import 'package:bdo_event/features/auth_screen/data/model/auth_user_dto.dart';
import 'package:bdo_event/features/auth_screen/data/auth_error_mapper.dart';
import 'package:bdo_event/features/auth_screen/domain/repositories/auth_repository.dart';
import 'package:bdo_event/core/util/event.resource.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AuthRepository implements AuthRepositoryContract {
  AuthRepository({required this._store, required this._authDataSource});

  final SupabaseStore _store;
  final AuthRemoteDataSource _authDataSource;
  User? _currentUser;

  @override
  User? get currentUser => _currentUser;
  String? get currentUserName => _currentUser?.displayName;
  @override
  bool can(UserPermission permission) =>
      _currentUser?.hasPermission(permission) ?? false;
  @override
  bool canUpdate(Event event) =>
      can(UserPermission.manageAllEvents) ||
      (event.creatorId == _currentUser?.id &&
          can(UserPermission.updateOwnEvents));
  @override
  bool canDelete(Event event) =>
      can(UserPermission.manageAllEvents) ||
      (event.creatorId == _currentUser?.id &&
          can(UserPermission.deleteOwnEvents));
  bool canManage(Event event) => canUpdate(event);

  @override
  Future<void> initialize() async {
    final authUser = _authDataSource.currentUser;
    if (authUser == null) return;

    supabase.User userForMapping = authUser;
    try {
      userForMapping = await _authDataSource.refreshSession() ?? authUser;
    } on supabase.AuthException {
      // Continue with the persisted session when a refresh is unavailable.
    }

    _currentUser = await _mapUser(userForMapping);
    _logUserClaims('session restored', userForMapping, _currentUser!);
  }

  @override
  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required UserRole requestedRole,
  }) async {
    try {
      await _authDataSource.signUp(
        email: email.trim().toLowerCase(),
        password: password,
        displayName: name.trim(),
        requestedRole: requestedRole.storageValue,
      );
    } on supabase.AuthException catch (error) {
      return mapAuthError(error, signingUp: true);
    } on Object {
      return AppText.unableToCreateAccount;
    }
    return null;
  }

  @override
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _authDataSource.signIn(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final user = response.user;
      if (user == null) return AppText.emailOrPasswordIncorrect;
      _currentUser = await _mapUser(user);
      _logUserClaims('login succeeded', user, _currentUser!);
    } on supabase.AuthException catch (error) {
      return mapAuthError(error, signingUp: false);
    } on Object {
      return AppText.unableToSignIn;
    }
    return null;
  }

  @override
  Future<String?> updatePassword(String password) async {
    if (_currentUser == null) return AppText.pleaseSignInToChangePassword;

    try {
      await _authDataSource.updatePassword(password);
    } on supabase.AuthException catch (error) {
      return error.message.isNotEmpty
          ? error.message
          : AppText.unableToChangePassword;
    } on Object {
      return AppText.unableToChangePassword;
    }
    return null;
  }

  @override
  Future<String?> updateProfile({
    required String displayName,
    required String email,
  }) async {
    final current = _currentUser;
    if (current == null) return AppText.pleaseSignInToChangePassword;
    final trimmedName = displayName.trim();
    final normalizedEmail = email.trim().toLowerCase();
    if (trimmedName.isEmpty || normalizedEmail.isEmpty) {
      return AppText.unableToUpdateProfile;
    }

    try {
      final response = await _authDataSource.updateUserData({
        'display_name': trimmedName,
        'email': normalizedEmail,
      });
      final updatedUser = response.user;
      if (updatedUser != null) {
        _currentUser = await _mapUser(updatedUser);
      } else {
        _currentUser = current.copyWith(
          displayName: trimmedName,
          email: normalizedEmail,
        );
      }
    } on supabase.AuthException catch (error) {
      return error.message.isNotEmpty
          ? error.message
          : AppText.unableToUpdateProfile;
    } on Object {
      return AppText.unableToUpdateProfile;
    }
    return null;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    await _authDataSource.signOut();
  }

  @override
  Future<String?> logoutEverywhere() async {
    try {
      await _authDataSource.signOutEverywhere();
      _currentUser = null;
    } on Object {
      return AppText.unableToSignOutEverywhere;
    }
    return null;
  }

  /// Role changes are intentionally restricted to administrators. A future
  /// admin screen or backend sync can call this without changing the UI rules.
  Future<String?> updateUserRoles({
    required String userId,
    required Set<UserRole> roles,
  }) async {
    if (!can(UserPermission.manageUsers)) {
      return AppText.administratorAccessRequired;
    }
    if (roles.isEmpty) return AppText.roleRequired;

    return AppText.roleManagementTrustedServer;
  }

  Future<String?> updateNotificationPreference(bool enabled) async {
    final current = _currentUser;
    if (current == null) return AppText.pleaseSignInToUpdatePreferences;

    try {
      await _store.writeNotificationPreference(current.id, enabled);
    } on LocalStorageException {
      return AppText.unableToSaveNotificationPreference;
    }
    _currentUser = current.copyWith(notificationsEnabled: enabled);
    return null;
  }

  Future<User> _mapUser(supabase.User authUser) async {
    final notificationsEnabled = await _store.readNotificationPreference(
      authUser.id,
    );
    return AuthUserDto(
      user: authUser,
      notificationsEnabled: notificationsEnabled,
    ).toEntity();
  }

  void _logUserClaims(
    String source,
    supabase.User authUser,
    User mappedUser,
  ) {
    developer.log(
      'auth.userClaims $source '
      '{userId: ${authUser.id}, '
      'email: ${authUser.email}, '
      'appMetadata.roles: ${authUser.appMetadata['roles']}, '
      'userMetadata.requested_role: '
      '${authUser.userMetadata?['requested_role']}, '
      'mappedRoles: ${mappedUser.roles.map((role) => role.storageValue).toList()}, '
      'displayName: ${mappedUser.displayName}}',
      name: 'bdo_event.supabase',
    );
  }
}
