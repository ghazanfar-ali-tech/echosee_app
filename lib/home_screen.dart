import 'package:echosee_app/app_constants.dart';
import 'package:echosee_app/app_theme.dart';
import 'package:echosee_app/bluetooth_screen.dart';

import 'package:echosee_app/provider/bluetooth_provider.dart';
import 'package:echosee_app/provider/setting_provider.dart';
import 'package:echosee_app/provider/sub_title_provider.dart';
import 'package:echosee_app/provider/trans_script_provider.dart';
import 'package:echosee_app/widgets/animated_widget.dart';
import 'package:echosee_app/widgets/subtitle_widget.dart';
import 'package:echosee_app/yamnet_module/yamnet_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadSettings();
      context.read<SubtitleProvider>().initialize();
      context.read<BluetoothProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _navIndex,
        children: [
          BluetoothHomePage(),
          _SubtitleTab(),
          _TranscriptsTab(),
          const YamnetScreen(),
          _SettingsTab(),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isConnected =
        context.watch<BluetoothProvider>().status == BluetoothStatus.connected;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.bluetooth_searching,
                label: 'Glasses',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
                badge: isConnected,
                badgeColor: AppColors.success,
              ),
              _NavItem(
                icon: Icons.closed_caption_rounded,
                label: 'Subtitles',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.history_rounded,
                label: 'Transcripts',
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.swipe_vertical_sharp,
                label: 'yamnet',
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),

              _NavItem(
                icon: Icons.tune_rounded,
                label: 'Settings',
                isSelected: currentIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool badge;
  final Color? badgeColor;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge = false,
    this.badgeColor,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: widget.isSelected ? 1.0 : 0.0,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(_NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primary.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      widget.icon,
                      key: ValueKey(widget.isSelected),
                      color: widget.isSelected
                          ? AppColors.primary
                          : (isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextSub),
                      size: 24,
                    ),
                  ),
                  if (widget.badge)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: widget.badgeColor ?? AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkSurface
                                : AppColors.lightSurface,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.rajdhani(
                  fontSize: 11,
                  fontWeight: widget.isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: widget.isSelected
                      ? AppColors.primary
                      : (isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextSub),
                  letterSpacing: 0.5,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubtitleTab extends StatelessWidget {
  const _SubtitleTab();

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

class _IdleState extends StatelessWidget {
  const _IdleState();

  @override
  Widget build(BuildContext context) {
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
                color: AppColors.darkTextMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: languages.map((lang) {
                final isSelected = lang['code'] == selectedLang;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ScaleTap(
                    onTap: () => settingsProv.setLanguage(lang['code']!),
                    child: AnimatedContainer(
                      duration: AppConstants.animNormal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.5)
                              : AppColors.darkBorder,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            lang['flag']!,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            lang['name']!,
                            style: GoogleFonts.rajdhani(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.darkTextSub,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
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
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.darkTextMuted,
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

class _TranscriptsTab extends StatefulWidget {
  const _TranscriptsTab();

  @override
  State<_TranscriptsTab> createState() => _TranscriptsTabState();
}

class _TranscriptsTabState extends State<_TranscriptsTab> {
  bool _searchExpanded = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isPremium = context.read<SettingsProvider>().isPremium;
      context.read<TranscriptProvider>().loadTranscripts(isPremium: isPremium);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TranscriptProvider, SettingsProvider>(
      builder: (_, tp, sp, __) {
        return Scaffold(
          appBar: AppBar(
            title: _searchExpanded
                ? _SearchField(
                    controller: _searchController,
                    onChanged: tp.setSearchQuery,
                    onClose: () {
                      setState(() => _searchExpanded = false);
                      tp.setSearchQuery('');
                      _searchController.clear();
                    },
                  )
                : null,
            leading: !_searchExpanded
                ? Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      'EchoSee',
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : null,
            leadingWidth: 120,
            actions: [
              if (!_searchExpanded && sp.isPremium)
                IconButton(
                  onPressed: () => setState(() => _searchExpanded = true),
                  icon: const Icon(Icons.search_rounded),
                ),
              if (!sp.isPremium)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.darkBorder,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${tp.transcripts.length}/${AppConstants.freeTranscriptLimit}',
                        style: GoogleFonts.rajdhani(
                          color: AppColors.darkTextSub,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: _buildBody(tp, sp),
        );
      },
    );
  }

  Widget _buildBody(TranscriptProvider tp, SettingsProvider sp) {
    if (tp.status == TranscriptStatus.loading) {
      return _buildSkeleton();
    }

    final transcripts = tp.filteredTranscripts;
    if (transcripts.isEmpty) {
      return _EmptyTranscripts();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transcripts.length,
      itemBuilder: (context, i) {
        final t = transcripts[i];
        return FadeSlideIn(
          delay: Duration(milliseconds: 60 * i),
          beginOffset: const Offset(0.05, 0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TranscriptCard(
              transcript: t,
              onTap: () => _openTranscript(context, t, tp),
              onDelete: () => tp.deleteTranscript(t.id),
              onExport: sp.isPremium ? () => _export(context, t, tp) : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ShimmerBox(
          width: double.infinity,
          height: 100,
          borderRadius: 16,
        ),
      ),
    );
  }

  void _openTranscript(context, t, tp) {
    tp.selectTranscript(t);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) =>
            _TranscriptDetailScreen(transcript: t),
        transitionsBuilder: (_, animation, __, child) {
          return ScaleTransition(
            scale: Tween(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }

  Future<void> _export(context, t, tp) async {
    final path = await tp.exportToPdf(t);
    if (context.mounted && path != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text('PDF exported successfully'),
            ],
          ),
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

class _SearchField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClose,
  });

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _width;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(duration: AppConstants.animNormal, vsync: this);
    _width = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _width,
      builder: (_, __) => SizeTransition(
        sizeFactor: _width,
        axis: Axis.horizontal,
        child: TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          autofocus: true,
          style: GoogleFonts.inter(color: AppColors.darkText),
          decoration: InputDecoration(
            hintText: 'Search transcripts...',
            hintStyle: GoogleFonts.inter(color: AppColors.darkTextMuted),
            border: InputBorder.none,
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.primary,
            ),
            suffixIcon: IconButton(
              onPressed: widget.onClose,
              icon: const Icon(
                Icons.close_rounded,
                color: AppColors.darkTextMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TranscriptCard extends StatelessWidget {
  final dynamic transcript;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onExport;

  const _TranscriptCard({
    required this.transcript,
    required this.onTap,
    required this.onDelete,
    this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScaleTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  transcript.languageFlag,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    transcript.title,
                    style: GoogleFonts.rajdhani(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  transcript.formattedDate,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.darkTextMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              transcript.previewText,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _MetaChip(
                  icon: Icons.timer_outlined,
                  label: transcript.formattedDuration,
                ),
                const SizedBox(width: 8),
                _MetaChip(
                  icon: Icons.text_fields_rounded,
                  label: '${transcript.wordCount}w',
                ),
                const Spacer(),
                if (onExport != null)
                  IconButton(
                    onPressed: onExport,
                    icon: const Icon(
                      Icons.picture_as_pdf_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: AppColors.error,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.rajdhani(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTranscripts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeSlideIn(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              size: 64,
              color: AppColors.primary.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'No Transcripts Yet',
              style: GoogleFonts.rajdhani(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTextMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start recording and save your conversations',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.darkTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TranscriptDetailScreen extends StatelessWidget {
  final dynamic transcript;
  const _TranscriptDetailScreen({required this.transcript});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(transcript.languageFlag + '  ' + transcript.title),
        actions: [
          IconButton(icon: const Icon(Icons.share_rounded), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeSlideIn(
              child: Row(
                children: [
                  _MetaChip(
                    icon: Icons.calendar_today_outlined,
                    label: transcript.formattedDate,
                  ),
                  const SizedBox(width: 8),
                  _MetaChip(
                    icon: Icons.timer_outlined,
                    label: transcript.formattedDuration,
                  ),
                  const SizedBox(width: 8),
                  _MetaChip(
                    icon: Icons.text_fields_rounded,
                    label: '${transcript.wordCount} words',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FadeSlideIn(
              delay: const Duration(milliseconds: 100),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Text(
                  transcript.content,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    height: 1.7,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (_, sp, __) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FadeSlideIn(
                child: _SettingsSection(
                  title: 'Display',
                  children: [
                    _ThemeToggle(sp: sp),
                    const Divider(height: 1),
                    _FontSizeSelector(sp: sp),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FadeSlideIn(
                delay: const Duration(milliseconds: 80),
                child: _SettingsSection(
                  title: 'Subtitle',
                  children: [
                    _PositionSelector(sp: sp),
                    const Divider(height: 1),
                    _ColorSelector(sp: sp),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FadeSlideIn(
                delay: const Duration(milliseconds: 160),
                child: _PremiumBanner(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.rajdhani(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  final SettingsProvider sp;
  const _ThemeToggle({required this.sp});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: AnimatedSwitcher(
        duration: AppConstants.animNormal,
        child: Icon(
          sp.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          key: ValueKey(sp.isDarkMode),
          color: AppColors.primary,
        ),
      ),
      title: Text(
        'Dark Mode',
        style: GoogleFonts.rajdhani(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      trailing: Switch(
        value: sp.isDarkMode,
        onChanged: (_) => sp.toggleDarkMode(),
      ),
    );
  }
}

class _FontSizeSelector extends StatelessWidget {
  final SettingsProvider sp;
  const _FontSizeSelector({required this.sp});

  @override
  Widget build(BuildContext context) {
    const sizes = [
      {'label': 'Small', 'value': 14.0},
      {'label': 'Medium', 'value': 18.0},
      {'label': 'Large', 'value': 24.0},
      {'label': 'X-Large', 'value': 30.0},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_size_rounded, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                'Font Size',
                style: GoogleFonts.rajdhani(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              AnimatedContainer(
                duration: AppConstants.animNormal,
                child: Text(
                  sizes
                      .firstWhere(
                        (s) => s['value'] == sp.fontSize,
                        orElse: () => sizes[1],
                      )['label']
                      .toString(),
                  style: GoogleFonts.rajdhani(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          AnimatedDefaultTextStyle(
            duration: AppConstants.animNormal,
            style: TextStyle(
              fontSize: sp.fontSize,
              color: sp.subtitleColor,
              fontWeight: FontWeight.w500,
            ),
            child: const Text('Preview Text'),
          ),
          const SizedBox(height: 12),
          Row(
            children: sizes.map((size) {
              final isSelected = sp.fontSize == size['value'];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ScaleTap(
                    onTap: () => sp.setFontSize(size['value'] as double),
                    child: AnimatedContainer(
                      duration: AppConstants.animNormal,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.5)
                              : AppColors.darkBorder,
                        ),
                      ),
                      child: Text(
                        size['label'].toString(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rajdhani(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.darkTextMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PositionSelector extends StatelessWidget {
  final SettingsProvider sp;
  const _PositionSelector({required this.sp});

  @override
  Widget build(BuildContext context) {
    const positions = [
      {
        'label': 'Top',
        'value': 'top',
        'icon': Icons.vertical_align_top_rounded,
      },
      {
        'label': 'Center',
        'value': 'center',
        'icon': Icons.vertical_align_center_rounded,
      },
      {
        'label': 'Bottom',
        'value': 'bottom',
        'icon': Icons.vertical_align_bottom_rounded,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(
            Icons.format_line_spacing_rounded,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Text(
            'Position',
            style: GoogleFonts.rajdhani(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          ...positions.map((pos) {
            final isSelected = sp.subtitlePosition == pos['value'];
            return Padding(
              padding: const EdgeInsets.only(left: 6),
              child: ScaleTap(
                onTap: () => sp.setSubtitlePosition(pos['value'] as String),
                child: AnimatedContainer(
                  duration: AppConstants.animNormal,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.5)
                          : AppColors.darkBorder,
                    ),
                  ),
                  child: Icon(
                    pos['icon'] as IconData,
                    size: 20,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.darkTextMuted,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ColorSelector extends StatelessWidget {
  final SettingsProvider sp;
  const _ColorSelector({required this.sp});

  final _colors = const [
    Color(0xFF00D4FF),
    Color(0xFFFFFFFF),
    Color(0xFFFFD700),
    Color(0xFF7BFF6E),
    Color(0xFFFF6EC7),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.palette_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            'Subtitle Color',
            style: GoogleFonts.rajdhani(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          ..._colors.map((color) {
            final isSelected = sp.subtitleColor.value == color.value;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ScaleTap(
                onTap: () => sp.setSubtitleColor(color),
                child: AnimatedContainer(
                  duration: AppConstants.animNormal,
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlowingBorder(
      glowColor: AppColors.accent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accent.withOpacity(0.2),
              AppColors.primary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.accentGlow,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  'EchoSee Premium',
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentGlow,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '• Multi-language translation (Arabic, French, Chinese, Spanish)\n'
              '• Unlimited transcript history\n'
              '• Speaker identification\n'
              '• Export to PDF\n'
              '• Advanced subtitle customization',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.darkTextSub,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            ScaleTap(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accent, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Upgrade to Premium',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
