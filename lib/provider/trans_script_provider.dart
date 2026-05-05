import 'dart:io';
import 'package:echosee_app/app_constants.dart';
import 'package:echosee_app/domain/transcript_entity.dart';
import 'package:echosee_app/repositries/trans_script_repo.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

enum TranscriptStatus { initial, loading, loaded, saving, deleting, error }

class TranscriptProvider extends ChangeNotifier {
  final TranscriptRepository _repo;

  TranscriptStatus _status = TranscriptStatus.initial;
  List<TranscriptEntity> _transcripts = [];
  TranscriptEntity? _selectedTranscript;
  String? _errorMessage;
  String _searchQuery = '';
  bool _exportSuccess = false;

  TranscriptProvider({TranscriptRepository? repo})
    : _repo = repo ?? TranscriptRepository();

  TranscriptStatus get status => _status;
  List<TranscriptEntity> get transcripts => _transcripts;
  TranscriptEntity? get selectedTranscript => _selectedTranscript;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get exportSuccess => _exportSuccess;

  List<TranscriptEntity> get filteredTranscripts {
    if (_searchQuery.isEmpty) return _transcripts;
    final q = _searchQuery.toLowerCase();
    return _transcripts
        .where(
          (t) =>
              t.title.toLowerCase().contains(q) ||
              t.content.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> loadTranscripts({bool isPremium = false}) async {
    _status = TranscriptStatus.loading;
    notifyListeners();

    try {
      _transcripts = await _repo.getTranscripts(isPremium: isPremium);
      _status = TranscriptStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = TranscriptStatus.error;
    }
    notifyListeners();
  }

  Future<TranscriptEntity?> saveTranscript({
    required String content,
    required String language,
    required Duration duration,
    int speakerCount = 1,
    bool isPremium = false,
  }) async {
    if (content.trim().isEmpty) return null;

    _status = TranscriptStatus.saving;
    notifyListeners();

    try {
      final title = _generateTitle(content, language);
      final entity = await _repo.saveTranscript(
        title: title,
        content: content,
        language: language,
        duration: duration,
        speakerCount: speakerCount,
        isPremium: isPremium,
      );
      await loadTranscripts(isPremium: isPremium);
      return entity;
    } catch (e) {
      _errorMessage = e.toString();
      _status = TranscriptStatus.error;
      notifyListeners();
      return null;
    }
  }

  String _generateTitle(String content, String language) {
    final words = content.trim().split(RegExp(r'\s+'));
    final preview = words.take(5).join(' ');
    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return '$preview... ($time)';
  }

  Future<void> deleteTranscript(String id) async {
    _status = TranscriptStatus.deleting;
    notifyListeners();

    try {
      await _repo.deleteTranscript(id);
      _transcripts.removeWhere((t) => t.id == id);
      _status = TranscriptStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = TranscriptStatus.error;
    }
    notifyListeners();
  }

  void selectTranscript(TranscriptEntity? transcript) {
    _selectedTranscript = transcript;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<String?> exportToPdf(TranscriptEntity transcript) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'EchoSee Transcript',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                transcript.title,
                style: const pw.TextStyle(fontSize: 16),
              ),
              pw.Divider(),
            ],
          ),
          build: (context) => [
            pw.Row(
              children: [
                pw.Text('Date: ${transcript.formattedDate}'),
                pw.SizedBox(width: 24),
                pw.Text('Duration: ${transcript.formattedDuration}'),
                pw.SizedBox(width: 24),
                pw.Text('Words: ${transcript.wordCount}'),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              transcript.content,
              style: const pw.TextStyle(fontSize: 12, lineSpacing: 4),
            ),
          ],
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/echosee_${transcript.id}.pdf');
      await file.writeAsBytes(await pdf.save());

      _exportSuccess = true;
      notifyListeners();
      Future.delayed(const Duration(seconds: 2), () {
        _exportSuccess = false;
        notifyListeners();
      });

      return file.path;
    } catch (e) {
      _errorMessage = 'Export failed: $e';
      notifyListeners();
      return null;
    }
  }

  bool canSaveMore(bool isPremium) {
    if (isPremium) return true;
    return _transcripts.length < AppConstants.freeTranscriptLimit;
  }

  int get remainingSlots =>
      AppConstants.freeTranscriptLimit - _transcripts.length;
}
