import 'package:flutter/material.dart';
import 'package:notetaker/services/crud/crud_exceptions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;

class NotesService {
  Database? _db;

  Future<DatabaseNote> updateNote({
    required int note,
    required String text,
  }) async {
    final db = _getDatabaseOrThrow();

    await getNote(noteId: note);

    final updateCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });

    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      return await getNote(noteId: note);
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();

    final notes = await db.query(noteTable);

    return notes.map((noteRow) => DatabaseNote.fromrow(noteRow));
  }

  Future<DatabaseNote> getNote({required int noteId}) async {
    final db = _getDatabaseOrThrow();

    final notes =
        await db.query(noteTable, where: 'id = ?', whereArgs: [noteId]);

    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      return DatabaseNote.fromrow(notes.first);
    }
  }

  Future<void> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    await db.delete(noteTable);
  }

  Future<void> deleteNote({required int noteId}) async {
    final db = _getDatabaseOrThrow();

    final deletedcount =
        await db.delete(noteTable, where: 'id = ?', whereArgs: [noteId]);

    if (deletedcount == 0) {
      throw CouldNotDeleteNote();
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();

    // make sure user exists and has correct id
    final dbUser = await getUser(email: owner.email);
    if (owner != dbUser) {
      throw CouldNotFindUser();
    }

    const text = '';

    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );

    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw UserNotFound();
    } else {
      return DatabaseUser.fromrow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }
    final userId =
        await db.insert(userTable, {emailColumn: email.toLowerCase()});
    return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbname);
      final db = await openDatabase(dbPath);
      _db = db;

      const createUserTable = '''CREATE TABLE "user" (
	    "id"	INTEGER NOT NULL,
	    "email"	TEXT NOT NULL UNIQUE,
	    PRIMARY KEY("id" AUTOINCREMENT));''';

      await db.execute(createUserTable);

      const createNotesTable = '''CREATE TABLE "note" (
	    "id"	INTEGER NOT NULL,
	    "user_id"	INTEGER NOT NULL UNIQUE,
	    "text"	TEXT,
	    PRIMARY KEY("id" AUTOINCREMENT));''';

      await db.execute(createNotesTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromrow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() {
    return "User, ID = $id, Email = $email";
  }

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromrow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int == 1 ? true : false);
}

const dbname = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
