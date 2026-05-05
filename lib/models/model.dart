import 'package:echosee_app/domain/transcript_entity.dart';

class TranscriptModel extends TranscriptEntity {
  const TranscriptModel({
    required super.id,
    required super.title,
    required super.content,
    required super.language,
    required super.createdAt,
    required super.duration,
    required super.wordCount,
    super.speakerCount,
    super.isPremium,
  });

  factory TranscriptModel.fromMap(Map<String, dynamic> map) {
    return TranscriptModel(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      language: map['language'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      duration: Duration(seconds: map['duration'] as int),
      wordCount: map['word_count'] as int,
      speakerCount: map['speaker_count'] as int? ?? 1,
      isPremium: (map['is_premium'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'language': language,
      'created_at': createdAt.toIso8601String(),
      'duration': duration.inSeconds,
      'word_count': wordCount,
      'speaker_count': speakerCount,
      'is_premium': isPremium ? 1 : 0,
    };
  }

  factory TranscriptModel.fromEntity(TranscriptEntity entity) {
    return TranscriptModel(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      language: entity.language,
      createdAt: entity.createdAt,
      duration: entity.duration,
      wordCount: entity.wordCount,
      speakerCount: entity.speakerCount,
      isPremium: entity.isPremium,
    );
  }
}

class SubtitleSegment {
  final String id;
  final String text;
  final String? speaker;
  final String language;
  final DateTime timestamp;
  final double confidence;
  final bool isFinal;

  const SubtitleSegment({
    required this.id,
    required this.text,
    required this.language,
    required this.timestamp,
    this.speaker,
    this.confidence = 1.0,
    this.isFinal = false,
  });

  SubtitleSegment copyWith({
    String? text,
    String? speaker,
    bool? isFinal,
    double? confidence,
  }) {
    return SubtitleSegment(
      id: id,
      text: text ?? this.text,
      language: language,
      timestamp: timestamp,
      speaker: speaker ?? this.speaker,
      confidence: confidence ?? this.confidence,
      isFinal: isFinal ?? this.isFinal,
    );
  }
}

class SettingsModel {
  final bool isDarkMode;
  final double fontSize;
  final String subtitlePosition;
  final int subtitleColor;
  final String selectedLanguage;
  final bool isPremium;

  const SettingsModel({
    this.isDarkMode = true,
    this.fontSize = 18.0,
    this.subtitlePosition = 'bottom',
    this.subtitleColor = 0xFF00D4FF,
    this.selectedLanguage = 'en-US',
    this.isPremium = false,
  });

  SettingsModel copyWith({
    bool? isDarkMode,
    double? fontSize,
    String? subtitlePosition,
    int? subtitleColor,
    String? selectedLanguage,
    bool? isPremium,
  }) {
    return SettingsModel(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      fontSize: fontSize ?? this.fontSize,
      subtitlePosition: subtitlePosition ?? this.subtitlePosition,
      subtitleColor: subtitleColor ?? this.subtitleColor,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      isDarkMode: (map['dark_mode'] as int? ?? 1) == 1,
      fontSize: (map['font_size'] as num?)?.toDouble() ?? 18.0,
      subtitlePosition: map['subtitle_position'] as String? ?? 'bottom',
      subtitleColor: map['subtitle_color'] as int? ?? 0xFF00D4FF,
      selectedLanguage: map['selected_language'] as String? ?? 'en-US',
      isPremium: (map['is_premium'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dark_mode': isDarkMode ? 1 : 0,
      'font_size': fontSize,
      'subtitle_position': subtitlePosition,
      'subtitle_color': subtitleColor,
      'selected_language': selectedLanguage,
      'is_premium': isPremium ? 1 : 0,
    };
  }
}
