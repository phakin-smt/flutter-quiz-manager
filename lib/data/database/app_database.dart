import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase({DatabaseFactory? factory, this.databasePath})
    : _factory = factory ?? databaseFactory;

  static const databaseName = 'quiz_manager.db';
  static const databaseVersion = 1;
  static const questionsTable = 'questions';

  final DatabaseFactory _factory;
  final String? databasePath;

  Database? _database;
  Future<Database>? _openingDatabase;

  Future<Database> get database async {
    final openDatabase = _database;
    if (openDatabase != null) {
      return openDatabase;
    }

    final openingDatabase = _openingDatabase;
    if (openingDatabase != null) {
      return openingDatabase;
    }

    final databaseFuture = _openDatabase();
    _openingDatabase = databaseFuture;

    try {
      final database = await databaseFuture;
      _database = database;
      return database;
    } finally {
      _openingDatabase = null;
    }
  }

  Future<Database> _openDatabase() async {
    final resolvedDatabasePath =
        databasePath ?? path.join(await getDatabasesPath(), databaseName);

    return _factory.openDatabase(
      resolvedDatabasePath,
      options: OpenDatabaseOptions(
        version: databaseVersion,
        onCreate: (database, version) async {
          await database.execute('''
            CREATE TABLE $questionsTable (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              question_text TEXT NOT NULL,
              choice_1 TEXT NOT NULL,
              choice_2 TEXT NOT NULL,
              choice_3 TEXT NOT NULL,
              choice_4 TEXT NOT NULL
            )
          ''');
        },
      ),
    );
  }

  Future<void> close() async {
    final openingDatabase = _openingDatabase;
    final database =
        _database ?? (openingDatabase == null ? null : await openingDatabase);

    if (database != null && database.isOpen) {
      await database.close();
    }

    _database = null;
    _openingDatabase = null;
  }
}
