// lib/presentation/widgets/subtitle/subtitle_display.dart
import 'package:echosee_app/app_theme.dart';
import 'package:echosee_app/models/model.dart';
import 'package:echosee_app/provider/setting_provider.dart';
import 'package:echosee_app/provider/sub_title_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubtitleDisplay extends StatelessWidget {
  const SubtitleDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SubtitleProvider, SettingsProvider>(
      builder: (_, subtitleProv, settingsProv, __) {
        final position = settingsProv.subtitlePosition;
        final fontSize = settingsProv.fontSize;
        final color = settingsProv.subtitleColor;

        return Align(
          alignment: _getAlignment(position),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: position == 'bottom' ? 32 : 0,
              top: position == 'top' ? 32 : 0,
            ),
            child: _SubtitleBox(
              subtitleProvider: subtitleProv,
              fontSize: fontSize,
              subtitleColor: color,
            ),
          ),
        );
      },
    );
  }

  Alignment _getAlignment(String position) {
    switch (position) {
      case 'top':
        return Alignment.topCenter;
      case 'center':
        return Alignment.center;
      default:
        return Alignment.bottomCenter;
    }
  }
}

class _SubtitleBox extends StatelessWidget {
  final SubtitleProvider subtitleProvider;
  final double fontSize;
  final Color subtitleColor;

  const _SubtitleBox({
    required this.subtitleProvider,
    required this.fontSize,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final current = subtitleProvider.currentSegment;
    final interim = subtitleProvider.currentInterim;

    final displayText = current?.text ?? interim;
    if (displayText.isEmpty && !subtitleProvider.isRecording) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      constraints: const BoxConstraints(maxWidth: 600),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current/Interim segment
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: child,
                ),
              );
            },
            child: displayText.isNotEmpty
                ? _SubtitleCard(
                    key: ValueKey(displayText.hashCode),
                    text: displayText,
                    speaker: current?.speaker,
                    fontSize: fontSize,
                    subtitleColor: subtitleColor,
                    isDark: isDark,
                    isFinal: current?.isFinal ?? false,
                  )
                : const SizedBox.shrink(),
          ),

          // Recent segments trail
          if (subtitleProvider.segments.isNotEmpty) ...[
            const SizedBox(height: 8),
            _RecentSegments(
              segments: subtitleProvider.segments.reversed.take(2).toList(),
              fontSize: fontSize * 0.8,
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }
}

class _SubtitleCard extends StatelessWidget {
  final String text;
  final String? speaker;
  final double fontSize;
  final Color subtitleColor;
  final bool isDark;
  final bool isFinal;

  const _SubtitleCard({
    super.key,
    required this.text,
    required this.fontSize,
    required this.subtitleColor,
    required this.isDark,
    required this.isFinal,
    this.speaker,
  });

  Color _getSpeakerColor(String? speaker) {
    switch (speaker) {
      case 'Speaker 1':
        return AppColors.speaker1;
      case 'Speaker 2':
        return AppColors.speaker2;
      case 'Speaker 3':
        return AppColors.speaker3;
      case 'Speaker 4':
        return AppColors.speaker4;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final speakerColor = _getSpeakerColor(speaker);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.subtitleBgDark : AppColors.subtitleBgLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFinal
              ? speakerColor.withOpacity(0.4)
              : AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: speakerColor.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (speaker != null) ...[
            _SpeakerTag(speaker: speaker!, color: speakerColor),
            const SizedBox(height: 6),
          ],
          Text(
            text,
            style: TextStyle(
              color: subtitleColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              height: 1.4,
              letterSpacing: 0.3,
              shadows: [
                Shadow(color: subtitleColor.withOpacity(0.3), blurRadius: 8),
              ],
            ),
          ),
          if (!isFinal) ...[const SizedBox(height: 6), _TypingIndicator()],
        ],
      ),
    );
  }
}

class _SpeakerTag extends StatefulWidget {
  final String speaker;
  final Color color;

  const _SpeakerTag({required this.speaker, required this.color});

  @override
  State<_SpeakerTag> createState() => _SpeakerTagState();
}

class _SpeakerTagState extends State<_SpeakerTag>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.color.withOpacity(0.4), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              widget.speaker,
              style: TextStyle(
                color: widget.color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final delay = i / 3;
            final t = (_controller.value - delay).clamp(0.0, 1.0);
            final opacity = (0.3 + 0.7 * (t < 0.5 ? t * 2 : (1 - t) * 2)).clamp(
              0.3,
              1.0,
            );
            return Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _RecentSegments extends StatelessWidget {
  final List<SubtitleSegment> segments;
  final double fontSize;
  final bool isDark;

  const _RecentSegments({
    required this.segments,
    required this.fontSize,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: segments.reversed.map((seg) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Opacity(
            opacity: 0.4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withOpacity(0.4)
                    : Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                seg.text,
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSub
                      : AppColors.lightTextSub,
                  fontSize: fontSize,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Offline Banner ───
class OfflineBanner extends StatefulWidget {
  final bool isOffline;

  const OfflineBanner({super.key, required this.isOffline});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(OfflineBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOffline) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: Container(
        color: AppColors.offline,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            const _PulsingOfflineIcon(),
            const SizedBox(width: 10),
            const Text(
              'OFFLINE MODE — Subtitles stored locally',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingOfflineIcon extends StatefulWidget {
  const _PulsingOfflineIcon();

  @override
  State<_PulsingOfflineIcon> createState() => _PulsingOfflineIconState();
}

class _PulsingOfflineIconState extends State<_PulsingOfflineIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: const Icon(Icons.wifi_off, color: Colors.white, size: 16),
    );
  }
}
