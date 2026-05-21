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
