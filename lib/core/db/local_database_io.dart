import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class LocalDatabase {
  Database? _database;

  Future<Database> get _connection async {
    if (_database != null) return _database!;

    final directory = await getApplicationDocumentsDirectory();
    final databasePath = path.join(directory.path, 'bdo_event.db');
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE users (email TEXT PRIMARY KEY, payload TEXT NOT NULL)',
        );
        await database.execute(
          'CREATE TABLE events (id TEXT PRIMARY KEY, payload TEXT NOT NULL)',
        );
        await database.execute(
          'CREATE TABLE registrations ('
          'user_id TEXT NOT NULL, event_id TEXT NOT NULL, '
          'payload TEXT NOT NULL, PRIMARY KEY (user_id, event_id))',
        );
      },
    );
    return _database!;
  }

  Future<Map<String, String>> readUsers() async {
    final rows = await (await _connection).query('users');
    return {
      for (final row in rows)
        row['email']! as String: row['payload']! as String,
    };
  }

  Future<void> writeUsers(Map<String, String> records) async {
    final database = await _connection;
    await database.transaction((transaction) async {
      await transaction.delete('users');
      for (final entry in records.entries) {
        await transaction.insert('users', {
          'email': entry.key,
          'payload': entry.value,
        });
      }
    });
  }

  Future<List<String>> readEvents() async {
    final rows = await (await _connection).query('events');
    return [for (final row in rows) row['payload']! as String];
  }

  Future<void> writeEvents(Map<String, String> records) async {
    final database = await _connection;
    await database.transaction((transaction) async {
      await transaction.delete('events');
      for (final entry in records.entries) {
        await transaction.insert('events', {
          'id': entry.key,
          'payload': entry.value,
        });
      }
    });
  }

  Future<List<String>> readRegistrations(String userId) async {
    final rows = await (await _connection).query(
      'registrations',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return [for (final row in rows) row['payload']! as String];
  }

  Future<void> writeRegistrations(
    String userId,
    Map<String, String> records,
  ) async {
    final database = await _connection;
    await database.transaction((transaction) async {
      await transaction.delete(
        'registrations',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      for (final entry in records.entries) {
        await transaction.insert('registrations', {
          'user_id': userId,
          'event_id': entry.key,
          'payload': entry.value,
        });
      }
    });
  }
}
