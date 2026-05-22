import 'package:echosee_app/app_constants.dart';
import 'package:echosee_app/app_theme.dart';
import 'package:echosee_app/provider/setting_provider.dart';
import 'package:echosee_app/provider/sub_title_provider.dart'
    show SubtitleProvider;
import 'package:echosee_app/provider/trans_script_provider.dart';
import 'package:echosee_app/widgets/animated_widget.dart';
import 'package:echosee_app/widgets/subtitle_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SubtitleTab extends StatelessWidget {
  const SubtitleTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<SubtitleProvider, SettingsProvider>(
      builder: (_, subtitleProv, settingsProv, __) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              const _SubtitleBackground(),

              SafeArea(
                child: Column(
                  children: [
                    _SubtitleAppBar(subtitleProv: subtitleProv),
                    Expanded(
                      child: Stack(
                        children: [
                          if (subtitleProv.isRecording)
                            const _RecordingVisualizer(),

                          if (!subtitleProv.isRecording) const _IdleState(),

                          SubtitleDisplay(),
                        ],
                      ),
                    ),

                    _SubtitleControls(
                      subtitleProv: subtitleProv,
                      settingsProv: settingsProv,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SubtitleBackground extends StatelessWidget {
  const _SubtitleBackground();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF050A14),
                  const Color(0xFF080F1E),
                  const Color(0xFF0D1421),
                ]
              : [
                  const Color(0xFFF0F7FF),
                  const Color(0xFFE8F4FF),
                  const Color(0xFFF5FBFF),
                ],
        ),
      ),
    );
  }
}

class _SubtitleAppBar extends StatelessWidget {
  final SubtitleProvider subtitleProv;
  const _SubtitleAppBar({required this.subtitleProv});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.remove_red_eye_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'EchoSee',
                style: GoogleFonts.orbitron(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const Spacer(),

          if (subtitleProv.isRecording)
            FadeSlideIn(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.error.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const _BlinkingDot(),
                    const SizedBox(width: 6),
                    Text(
                      _formatDuration(subtitleProv.sessionDuration),
                      style: GoogleFonts.rajdhani(
                        color: AppColors.error,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'FREE',
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _RecordingVisualizer extends StatefulWidget {
  const _RecordingVisualizer();

  @override
  State<_RecordingVisualizer> createState() => _RecordingVisualizerState();
}

class _RecordingVisualizerState extends State<_RecordingVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(duration: const Duration(seconds: 2), vsync: this)
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          return CustomPaint(
            painter: _WavePainter(progress: _c.value),
            size: const Size(200, 200),
          );
        },
      ),
    );
  }
}

class _IdleState extends StatelessWidget {
  const _IdleState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: FadeSlideIn(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 2,
                ),
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Icon(
                Icons.mic_none_rounded,
                size: 48,
                color: AppColors.primary.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tap to Start',
              style: GoogleFonts.orbitron(
                fontSize: 18,
                color: AppColors.primary.withOpacity(0.6),
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Real-time subtitles for your EchoSee glasses',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  _WavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < 3; i++) {
      final t = ((progress - i * 0.33) + 1) % 1;
      final radius = (size.width / 2) * t;
      final opacity = (1 - t) * 0.4;
      final paint = Paint()
        ..color = AppColors.primary.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.progress != progress;
}

class _BlinkingDot extends StatefulWidget {
  const _BlinkingDot();

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _c,
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: AppColors.error,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _SubtitleControls extends StatelessWidget {
  final SubtitleProvider subtitleProv;
  final SettingsProvider settingsProv;

  const _SubtitleControls({
    required this.subtitleProv,
    required this.settingsProv,
  });

  @override
  Widget build(BuildContext context) {
    final languages = [
      ...AppConstants.freeLanguages,
      if (settingsProv.isPremium) ...AppConstants.premiumLanguages,
    ];
    final selectedLang = settingsProv.selectedLanguage;
    final midPoint = (languages.length / 2).ceil();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...languages.take(midPoint).map((lang) {
                  final isSelected = lang['code'] == selectedLang;
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: ScaleTap(
                      onTap: () => settingsProv.setLanguage(lang['code']!),
                      child: _buildLanguageChip(lang, isSelected, context),
                    ),
                  );
                }).toList(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Image(
                    height: 50,
                    width: 50,
                    image: AssetImage(
                      'assets/icons/icon-park_translation3.png',
                    ),
                  ),
                ),
                SizedBox(width: 4),

                ...languages.skip(midPoint).map((lang) {
                  final isSelected = lang['code'] == selectedLang;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ScaleTap(
                      onTap: () => settingsProv.setLanguage(lang['code']!),
                      child: _buildLanguageChip(lang, isSelected, context),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTap(
                onTap: subtitleProv.clearSegments,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 24),

              GlowingBorder(
                active: subtitleProv.isRecording,
                glowColor: subtitleProv.isRecording
                    ? AppColors.error
                    : AppColors.primary,
                borderRadius: 40,
                child: ScaleTap(
                  onTap: () => subtitleProv.toggleListening(selectedLang),
                  child: AnimatedContainer(
                    duration: AppConstants.animNormal,
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: subtitleProv.isRecording
                            ? [AppColors.error, const Color(0xFFCC0033)]
                            : [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (subtitleProv.isRecording
                                      ? AppColors.error
                                      : AppColors.primary)
                                  .withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: AppConstants.animFast,
                      child: Icon(
                        subtitleProv.isRecording
                            ? Icons.stop_rounded
                            : Icons.mic_rounded,
                        key: ValueKey(subtitleProv.isRecording),
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),

              ScaleTap(
                onTap: () => _saveTranscript(context),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                    color: AppColors.primary.withOpacity(0.08),
                  ),
                  child: const Icon(
                    Icons.save_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageChip(
    Map<String, String> lang,
    bool isSelected,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: AppConstants.animNormal,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? AppColors.primary.withOpacity(0.5)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(lang['flag']!, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            lang['name']!,
            style: GoogleFonts.rajdhani(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.darkTextSub : AppColors.lightTextSub),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTranscript(BuildContext context) async {
    final text = context.read<SubtitleProvider>().fullTranscriptText;
    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nothing to save yet')));
      return;
    }

    final tp = context.read<TranscriptProvider>();
    final sp = context.read<SubtitleProvider>();
    final lang = context.read<SettingsProvider>().selectedLanguage;
    final isPremium = context.read<SettingsProvider>().isPremium;

    await tp.saveTranscript(
      content: text,
      language: lang,
      duration: sp.sessionDuration,
      isPremium: isPremium,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transcript saved!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
