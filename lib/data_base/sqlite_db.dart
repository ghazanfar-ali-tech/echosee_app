// lib/data/datasources/database_helper.dart
import 'package:echosee_app/app_constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Transcripts table
    await db.execute('''
      CREATE TABLE ${AppConstants.transcriptsTable} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        language TEXT NOT NULL,
        created_at TEXT NOT NULL,
        duration INTEGER NOT NULL DEFAULT 0,
        word_count INTEGER NOT NULL DEFAULT 0,
        speaker_count INTEGER NOT NULL DEFAULT 1,
        is_premium INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Settings table
    await db.execute('''
      CREATE TABLE ${AppConstants.settingsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dark_mode INTEGER NOT NULL DEFAULT 1,
        font_size REAL NOT NULL DEFAULT 18.0,
        subtitle_position TEXT NOT NULL DEFAULT 'bottom',
        subtitle_color INTEGER NOT NULL DEFAULT ${0xFF00D4FF},
        selected_language TEXT NOT NULL DEFAULT 'en-US',
        is_premium INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Insert default settings
    await db.insert(AppConstants.settingsTable, {
      'dark_mode': 1,
      'font_size': 18.0,
      'subtitle_position': 'bottom',
      'subtitle_color': 0xFF00D4FF,
      'selected_language': 'en-US',
      'is_premium': 0,
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future migrations
  }

  // ============ TRANSCRIPT OPERATIONS ============

  Future<String> insertTranscript(Map<String, dynamic> transcript) async {
    final db = await database;
    await db.insert(
      AppConstants.transcriptsTable,
      transcript,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return transcript['id'] as String;
  }

  Future<List<Map<String, dynamic>>> getAllTranscripts({
    int? limit,
    String? searchQuery,
  }) async {
    final db = await database;

    if (searchQuery != null && searchQuery.isNotEmpty) {
      return await db.query(
        AppConstants.transcriptsTable,
        where: 'title LIKE ? OR content LIKE ?',
        whereArgs: ['%$searchQuery%', '%$searchQuery%'],
        orderBy: 'created_at DESC',
        limit: limit,
      );
    }

    return await db.query(
      AppConstants.transcriptsTable,
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  Future<Map<String, dynamic>?> getTranscriptById(String id) async {
    final db = await database;
    final results = await db.query(
      AppConstants.transcriptsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> deleteTranscript(String id) async {
    final db = await database;
    await db.delete(
      AppConstants.transcriptsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getTranscriptCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.transcriptsTable}',
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<void> deleteOldestTranscript() async {
    final db = await database;
    final oldest = await db.query(
      AppConstants.transcriptsTable,
      orderBy: 'created_at ASC',
      limit: 1,
    );
    if (oldest.isNotEmpty) {
      await deleteTranscript(oldest.first['id'] as String);
    }
  }

  Future<void> enforceTranscriptLimit(int limit) async {
    final count = await getTranscriptCount();
    if (count >= limit) {
      await deleteOldestTranscript();
    }
  }

  // ============ SETTINGS OPERATIONS ============

  Future<Map<String, dynamic>?> getSettings() async {
    final db = await database;
    final results = await db.query(AppConstants.settingsTable, limit: 1);
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    final db = await database;
    final existing = await db.query(AppConstants.settingsTable, limit: 1);

    if (existing.isEmpty) {
      await db.insert(AppConstants.settingsTable, settings);
    } else {
      await db.update(
        AppConstants.settingsTable,
        settings,
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
