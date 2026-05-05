import 'dart:async';
import 'package:echosee_app/models/model.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';

enum SubtitleState { idle, listening, processing, error }

class SubtitleProvider extends ChangeNotifier {
  final SpeechToText _speech = SpeechToText();
  final _uuid = const Uuid();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  SubtitleState _state = SubtitleState.idle;
  bool _isInitialized = false;
  bool _isOffline = false;
  bool _isRecording = false;

  List<SubtitleSegment> _segments = [];
  SubtitleSegment? _currentSegment;
  String _currentInterim = '';
  String? _errorMessage;

  String _currentSpeaker = 'Speaker 1';
  int _speakerIndex = 0;

  DateTime? _sessionStart;
  Duration _sessionDuration = Duration.zero;
  Timer? _sessionTimer;

  SubtitleState get state => _state;
  bool get isInitialized => _isInitialized;
  bool get isOffline => _isOffline;
  bool get isRecording => _isRecording;
  List<SubtitleSegment> get segments => List.unmodifiable(_segments);
  SubtitleSegment? get currentSegment => _currentSegment;
  String get currentInterim => _currentInterim;
  String? get errorMessage => _errorMessage;
  String get currentSpeaker => _currentSpeaker;
  Duration get sessionDuration => _sessionDuration;

  SubtitleProvider() {
    _initConnectivity();
  }

  void _initConnectivity() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final wasOffline = _isOffline;
      _isOffline = results.every((r) => r == ConnectivityResult.none);
      if (wasOffline != _isOffline) notifyListeners();
    });
  }

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      _errorMessage = 'Microphone permission denied';
      notifyListeners();
      return false;
    }

    try {
      _isInitialized = await _speech.initialize(
        onStatus: _onStatus,
        onError: _onError,
      );
      notifyListeners();
      return _isInitialized;
    } catch (e) {
      _errorMessage = 'Failed to initialize speech: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> startListening(String languageCode) async {
    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) return;
    }

    if (_isRecording) return;

    _isRecording = true;
    _state = SubtitleState.listening;
    _sessionStart = DateTime.now();
    _segments = [];
    _currentSegment = null;
    _currentInterim = '';
    _startSessionTimer();
    notifyListeners();

    await _speech.listen(
      onResult: _onResult,
      localeId: languageCode,
      listenMode: ListenMode.dictation,
      partialResults: true,
      cancelOnError: false,
      pauseFor: const Duration(seconds: 3),
      listenFor: const Duration(hours: 1),
    );
  }

  Future<void> stopListening() async {
    _isRecording = false;
    _state = SubtitleState.idle;
    _stopSessionTimer();
    await _speech.stop();

    if (_currentInterim.isNotEmpty) {
      _finalizeSegment(_currentInterim);
      _currentInterim = '';
    }
    _currentSegment = null;
    notifyListeners();
  }

  Future<void> toggleListening(String languageCode) async {
    if (_isRecording) {
      await stopListening();
    } else {
      await startListening(languageCode);
    }
  }

  void _onResult(SpeechRecognitionResult result) {
    final text = result.recognizedWords.trim();
    if (text.isEmpty) return;

    if (result.finalResult) {
      _finalizeSegment(text);
      _currentInterim = '';
      _currentSegment = null;
    } else {
      _currentInterim = text;
      _currentSegment = SubtitleSegment(
        id: _uuid.v4(),
        text: text,
        language: 'en-US',
        timestamp: DateTime.now(),
        speaker: _currentSpeaker,
        isFinal: false,
      );
    }
    notifyListeners();
  }

  void _finalizeSegment(String text) {
    if (text.isEmpty) return;

    final segment = SubtitleSegment(
      id: _uuid.v4(),
      text: text,
      language: 'en-US',
      timestamp: DateTime.now(),
      speaker: _currentSpeaker,
      isFinal: true,
    );
    _segments.add(segment);

    if (_segments.length > 50) {
      _segments = _segments.sublist(_segments.length - 50);
    }
  }

  void _onStatus(String status) {
    if (status == 'listening') {
      _state = SubtitleState.listening;
    } else if (status == 'notListening') {
      if (_isRecording) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_isRecording) {
            _speech.listen(
              onResult: _onResult,
              pauseFor: const Duration(seconds: 3),
              listenFor: const Duration(hours: 1),
            );
          }
        });
      }
    }
    notifyListeners();
  }

  void _onError(dynamic error) {
    _errorMessage = error.toString();
    _state = SubtitleState.error;
    notifyListeners();
  }

  void switchSpeaker() {
    _speakerIndex = (_speakerIndex + 1) % 4;
    _currentSpeaker = 'Speaker ${_speakerIndex + 1}';
    notifyListeners();
  }

  void clearSegments() {
    _segments.clear();
    _currentSegment = null;
    _currentInterim = '';
    notifyListeners();
  }

  String get fullTranscriptText {
    return _segments.map((s) => s.text).join(' ');
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_sessionStart != null) {
        _sessionDuration = DateTime.now().difference(_sessionStart!);
        notifyListeners();
      }
    });
  }

  void _stopSessionTimer() {
    _sessionTimer?.cancel();
    if (_sessionStart != null) {
      _sessionDuration = DateTime.now().difference(_sessionStart!);
    }
  }

  void addGlassesSubtitle(String text, {String? speaker}) {
    final segment = SubtitleSegment(
      id: _uuid.v4(),
      text: text,
      language: 'en-US',
      timestamp: DateTime.now(),
      speaker: speaker ?? _currentSpeaker,
      isFinal: true,
    );
    _segments.add(segment);
    _currentSegment = segment;
    notifyListeners();
  }

  @override
  void dispose() {
    _speech.stop();
    _sessionTimer?.cancel();
    _connectivitySub?.cancel();
    super.dispose();
  }
}
