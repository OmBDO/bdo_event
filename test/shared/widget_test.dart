// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('role permissions keep event management scoped', () {
    final user = User(
      id: 'user-1',
      displayName: 'User',
      email: 'user@example.com',
      createdAt: DateTime(2026),
    );
    final watcher = User(
      id: 'watcher-1',
      displayName: 'Watcher',
      email: 'watcher@example.com',
      roles: {UserRole.watcher},
      createdAt: DateTime(2026),
    );
    final admin = User(
      id: 'admin-1',
      displayName: 'Admin',
      email: 'admin@example.com',
      roles: {UserRole.admin},
      createdAt: DateTime(2026),
    );

    expect(user.hasPermission(UserPermission.registerForEvents), isTrue);
    expect(user.hasPermission(UserPermission.createEvents), isFalse);
    expect(user.hasPermission(UserPermission.scanRegistrations), isFalse);
    expect(watcher.hasPermission(UserPermission.registerForEvents), isTrue);
    expect(watcher.hasPermission(UserPermission.scanRegistrations), isTrue);
    expect(watcher.hasPermission(UserPermission.createEvents), isFalse);
    expect(admin.hasPermission(UserPermission.createEvents), isTrue);
    expect(admin.hasPermission(UserPermission.scanRegistrations), isTrue);
    expect(admin.hasPermission(UserPermission.manageUsers), isTrue);
  });
}
