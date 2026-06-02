import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Helper único para todas las tablas de la app (sales.db).
/// Versión 3: añade tabla providers.
class DatabaseHelper {
  static const String _dbName = 'sales.db';
  static const int _version = 3;

  // ── Tablas ────────────────────────────────────────────────
  static const String tableClients   = 'clients';
  static const String tableProviders = 'providers';

  // ── Singleton ─────────────────────────────────────────────
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();
  factory DatabaseHelper() => instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ── Creación ──────────────────────────────────────────────
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableClients (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        name            TEXT    NOT NULL,
        document_number TEXT    NOT NULL,
        is_synced       INTEGER NOT NULL DEFAULT 0,
        server_id       INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableProviders (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre    TEXT    NOT NULL,
        ruc       TEXT    NOT NULL,
        telefono  TEXT    NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        server_id INTEGER
      )
    ''');
  }

  // ── Migraciones ───────────────────────────────────────────
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE $tableClients ADD COLUMN server_id INTEGER');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableProviders (
          id        INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre    TEXT    NOT NULL,
          ruc       TEXT    NOT NULL,
          telefono  TEXT    NOT NULL,
          is_synced INTEGER NOT NULL DEFAULT 0,
          server_id INTEGER
        )
      ''');
    }
  }

  // ── CRUD genérico ─────────────────────────────────────────

  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(table, row);
  }

  Future<int> update(
      String table, int id, Map<String, dynamic> row) async {
    final db = await database;
    return await db.update(table, row, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table, orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> queryPending(String table) async {
    final db = await database;
    return await db
        .query(table, where: 'is_synced = ?', whereArgs: [0]);
  }

  Future<int> updateSynced(
      String table, int id, int serverId) async {
    final db = await database;
    return await db.update(
      table,
      {'is_synced': 1, 'server_id': serverId},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateSyncedOnly(String table, int id) async {
    final db = await database;
    return await db.update(
      table,
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(String table, int id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll(String table) async {
    final db = await database;
    await db.delete(table);
  }
}
