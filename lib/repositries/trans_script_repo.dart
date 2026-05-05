// lib/data/repositories/transcript_repository.dart
import 'package:echosee_app/app_constants.dart';
import 'package:echosee_app/data_base/sqlite_db.dart';
import 'package:echosee_app/domain/transcript_entity.dart';
import 'package:echosee_app/models/model.dart';
import 'package:uuid/uuid.dart';

class TranscriptRepository {
  final DatabaseHelper _db;
  final _uuid = const Uuid();

  TranscriptRepository({DatabaseHelper? db}) : _db = db ?? DatabaseHelper();

  Future<List<TranscriptEntity>> getTranscripts({
    bool isPremium = false,
    String? searchQuery,
  }) async {
    final maps = await _db.getAllTranscripts(
      limit: isPremium ? null : AppConstants.freeTranscriptLimit,
      searchQuery: searchQuery,
    );
    return maps.map((m) => TranscriptModel.fromMap(m)).toList();
  }

  Future<TranscriptEntity?> getById(String id) async {
    final map = await _db.getTranscriptById(id);
    if (map == null) return null;
    return TranscriptModel.fromMap(map);
  }

  Future<TranscriptEntity> saveTranscript({
    required String title,
    required String content,
    required String language,
    required Duration duration,
    int speakerCount = 1,
    bool isPremium = false,
  }) async {
    // Enforce free limit
    if (!isPremium) {
      await _db.enforceTranscriptLimit(AppConstants.freeTranscriptLimit);
    }

    final id = _uuid.v4();
    final wordCount = content.trim().split(RegExp(r'\s+')).length;

    final model = TranscriptModel(
      id: id,
      title: title,
      content: content,
      language: language,
      createdAt: DateTime.now(),
      duration: duration,
      wordCount: wordCount,
      speakerCount: speakerCount,
      isPremium: isPremium,
    );

    await _db.insertTranscript(model.toMap());
    return model;
  }

  Future<void> deleteTranscript(String id) async {
    await _db.deleteTranscript(id);
  }

  Future<int> getCount() async {
    return await _db.getTranscriptCount();
  }
}
