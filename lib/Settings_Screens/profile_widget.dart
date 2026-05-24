import 'package:echosee_app/app_theme.dart' show AppColors;
import 'package:echosee_app/widgets/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageFontPopup extends StatefulWidget {
  final bool isDark;
  final String selectedLanguage;
  final String selectedSize;
  final ValueChanged<String> onLanguageSelected;
  final ValueChanged<String> onSizeSelected;

  const LanguageFontPopup({
    required this.isDark,
    required this.selectedLanguage,
    required this.selectedSize,
    required this.onLanguageSelected,
    required this.onSizeSelected,
  });

  @override
  State<LanguageFontPopup> createState() => _LanguageFontPopupState();
}

class _LanguageFontPopupState extends State<LanguageFontPopup> {
  late String _lang;
  late String _size;

  final List<String> _languages = ['English', 'Urdu'];
  final List<Map<String, dynamic>> _sizes = [
    {'label': 'Small', 'tag': 'Aa', 'fontSize': 13.0},
    {'label': 'Medium', 'tag': 'Aa', 'fontSize': 17.0},
    {'label': 'Large', 'tag': 'Aa', 'fontSize': 22.0},
    {'label': 'XXLarge', 'tag': 'Aa', 'fontSize': 28.0},
  ];

  @override
  void initState() {
    super.initState();
    _lang = widget.selectedLanguage;
    _size = widget.selectedSize;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bg = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final border = isDark ? const Color(0xFF2E2E4E) : const Color(0xFFE0E0E0);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final mutedColor = isDark
        ? const Color(0xFF8888AA)
        : const Color(0xFF888899);

    final previewText = _lang == 'English'
        ? AppTranslator.translate('hello_how_are_you')
        : AppTranslator.translate('hello_how_are_you');

    final previewFontSize =
        _sizes.firstWhere(
              (s) => s['label'] == _size,
              orElse: () => _sizes[1],
            )['fontSize']
            as double;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.88,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.15),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.g_translate_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Language & Display',
                    style: GoogleFonts.orbitron(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.close_rounded,
                      color: mutedColor,
                      size: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Text(
                'LANGUAGE',
                style: GoogleFonts.rajdhani(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: mutedColor,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: _languages.map((lang) {
                  final selected = _lang == lang;
                  final flag = lang == 'English' ? '🇬🇧' : '🇵🇰';
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _lang = lang);
                        widget.onLanguageSelected(lang);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(
                          right: lang == 'English' ? 8 : 0,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withOpacity(0.15)
                              : (isDark
                                    ? const Color(0xFF252540)
                                    : const Color(0xFFF5F5FA)),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(flag, style: const TextStyle(fontSize: 26)),
                            const SizedBox(height: 6),
                            Text(
                              lang,
                              style: GoogleFonts.rajdhani(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: selected ? AppColors.primary : textColor,
                              ),
                            ),
                            if (lang == 'Urdu')
                              Text(
                                'اردو',
                                style: GoogleFonts.rajdhani(
                                  fontSize: 12,
                                  color: mutedColor,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              Text(
                'TEXT SIZE',
                style: GoogleFonts.rajdhani(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: mutedColor,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: _sizes.map((s) {
                  final label = s['label'] as String;
                  final fs = s['fontSize'] as double;
                  final selected = _size == label;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _size = label);
                        widget.onSizeSelected(label);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(
                          right: label != 'XXLarge' ? 6 : 0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withOpacity(0.15)
                              : (isDark
                                    ? const Color(0xFF252540)
                                    : const Color(0xFFF5F5FA)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Aa',
                              style: GoogleFonts.rajdhani(
                                fontSize: fs,
                                fontWeight: FontWeight.w700,
                                color: selected ? AppColors.primary : textColor,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              label,
                              style: GoogleFonts.rajdhani(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? AppColors.primary
                                    : mutedColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF252540)
                      : const Color(0xFFF0F0FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PREVIEW',
                      style: GoogleFonts.rajdhani(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: mutedColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      previewText,
                      style: GoogleFonts.rajdhani(
                        fontSize: previewFontSize,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      textDirection: _lang == 'Urdu'
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
