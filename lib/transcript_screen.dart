import 'package:echosee_app/app_constants.dart';
import 'package:echosee_app/app_theme.dart';
import 'package:echosee_app/provider/setting_provider.dart';
import 'package:echosee_app/provider/trans_script_provider.dart';
import 'package:echosee_app/widgets/animated_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TranscriptsTab extends StatefulWidget {
  const TranscriptsTab();

  @override
  State<TranscriptsTab> createState() => _TranscriptsTabState();
}

class _TranscriptsTabState extends State<TranscriptsTab> {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      'Transcripts',
                      style: GoogleFonts.orbitron(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  )
                : null,
            leadingWidth: 120,
            actions: [
              if (!_searchExpanded && sp.isPremium)
                IconButton(
                  onPressed: () => setState(() => _searchExpanded = true),
                  icon: Icon(
                    Icons.search_rounded,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
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
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${tp.transcripts.length}/${AppConstants.freeTranscriptLimit}',
                        style: GoogleFonts.rajdhani(
                          color: isDark
                              ? AppColors.darkTextSub
                              : AppColors.lightTextSub,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: _buildBody(tp, sp, isDark),
        );
      },
    );
  }

  Widget _buildBody(TranscriptProvider tp, SettingsProvider sp, bool isDark) {
    if (tp.status == TranscriptStatus.loading) {
      return _buildSkeleton();
    }

    final transcripts = tp.filteredTranscripts;
    if (transcripts.isEmpty) {
      return _EmptyTranscripts(isDark: isDark);
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
              isDark: isDark,
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

class _TranscriptDetailScreen extends StatefulWidget {
  final dynamic transcript;
  const _TranscriptDetailScreen({required this.transcript});

  @override
  State<_TranscriptDetailScreen> createState() =>
      _TranscriptDetailScreenState();
}

class _TranscriptDetailScreenState extends State<_TranscriptDetailScreen> {
  double _fontSize = 15.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transcript.languageFlag + '  ' + widget.transcript.title,
          style: GoogleFonts.rajdhani(
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share_rounded,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeSlideIn(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaChip(
                    icon: Icons.calendar_today_outlined,
                    label: widget.transcript.formattedDate,
                    isDark: isDark,
                  ),
                  _MetaChip(
                    icon: Icons.timer_outlined,
                    label: widget.transcript.formattedDuration,
                    isDark: isDark,
                  ),
                  _MetaChip(
                    icon: Icons.text_fields_rounded,
                    label: '${widget.transcript.wordCount} words',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            FadeSlideIn(
              delay: const Duration(milliseconds: 50),
              child: Align(
                alignment: Alignment.centerRight,
                child: _FontSizeControls(
                  fontSize: _fontSize,
                  isDark: isDark,
                  onFontSizeChanged: (newSize) {
                    setState(() => _fontSize = newSize);
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),
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
                  widget.transcript.content,
                  style: GoogleFonts.inter(
                    fontSize: _fontSize,
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

class _FontSizeControls extends StatelessWidget {
  final double fontSize;
  final bool isDark;
  final ValueChanged<double> onFontSizeChanged;

  const _FontSizeControls({
    required this.fontSize,
    required this.isDark,
    required this.onFontSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTap(
            onTap: fontSize > 12 ? () => onFontSizeChanged(fontSize - 1) : null,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fontSize > 12
                    ? AppColors.primary.withOpacity(0.15)
                    : Colors.transparent,
              ),
              child: Icon(
                Icons.remove_rounded,
                size: 18,
                color: fontSize > 12
                    ? AppColors.primary
                    : (isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Aa',
            style: GoogleFonts.rajdhani(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          ScaleTap(
            onTap: fontSize < 24 ? () => onFontSizeChanged(fontSize + 1) : null,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fontSize < 24
                    ? AppColors.primary.withOpacity(0.15)
                    : Colors.transparent,
              ),
              child: Icon(
                Icons.add_rounded,
                size: 18,
                color: fontSize < 24
                    ? AppColors.primary
                    : (isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TranscriptCard extends StatelessWidget {
  final dynamic transcript;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onExport;

  const _TranscriptCard({
    required this.transcript,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
    this.onExport,
  });

  @override
  Widget build(BuildContext context) {
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
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
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
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _MetaChip(
                  icon: Icons.text_fields_rounded,
                  label: '${transcript.wordCount}w',
                  isDark: isDark,
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
  final bool isDark;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

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
  final bool isDark;

  const _EmptyTranscripts({required this.isDark});

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
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start recording and save your conversations',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _width,
      builder: (_, __) => SizeTransition(
        sizeFactor: _width,
        axis: Axis.horizontal,
        child: TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          autofocus: true,
          style: GoogleFonts.inter(
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
          decoration: InputDecoration(
            hintText: 'Search transcripts...',
            hintStyle: GoogleFonts.inter(
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextMuted,
            ),
            border: InputBorder.none,
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.primary,
            ),
            suffixIcon: IconButton(
              onPressed: widget.onClose,
              icon: Icon(
                Icons.close_rounded,
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
