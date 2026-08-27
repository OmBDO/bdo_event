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
    final attendee = User(
      id: 'attendee-1',
      displayName: 'Attendee',
      email: 'attendee@example.com',
      createdAt: DateTime(2026),
    );
    final organizer = User(
      id: 'organizer-1',
      displayName: 'Organizer',
      email: 'organizer@example.com',
      roles: {UserRole.organizer},
      createdAt: DateTime(2026),
    );
    final administrator = User(
      id: 'admin-1',
      displayName: 'Admin',
      email: 'admin@example.com',
      roles: {UserRole.administrator},
      createdAt: DateTime(2026),
    );

    expect(attendee.hasPermission(UserPermission.registerForEvents), isTrue);
    expect(attendee.hasPermission(UserPermission.createEvents), isFalse);
    expect(organizer.hasPermission(UserPermission.updateOwnEvents), isTrue);
    expect(organizer.hasPermission(UserPermission.manageAllEvents), isFalse);
    expect(administrator.hasPermission(UserPermission.manageUsers), isTrue);
  });
}
