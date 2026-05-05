// lib/domain/entities/transcript_entity.dart
class TranscriptEntity {
  final String id;
  final String title;
  final String content;
  final String language;
  final DateTime createdAt;
  final Duration duration;
  final int wordCount;
  final int speakerCount;
  final bool isPremium;

  const TranscriptEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.language,
    required this.createdAt,
    required this.duration,
    required this.wordCount,
    this.speakerCount = 1,
    this.isPremium = false,
  });

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get languageFlag {
    const flags = {
      'en-US': '🇺🇸',
      'ur-PK': '🇵🇰',
      'ar-SA': '🇸🇦',
      'fr-FR': '🇫🇷',
      'zh-CN': '🇨🇳',
      'es-ES': '🇪🇸',
    };
    return flags[language] ?? '🌐';
  }

  String get previewText {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }
}
