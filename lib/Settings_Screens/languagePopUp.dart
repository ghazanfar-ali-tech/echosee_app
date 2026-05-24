import 'package:echosee_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguagePopup extends StatefulWidget {
  final bool isDark;
  final String selectedLanguage;
  final ValueChanged<String> onLanguageSelected;

  const LanguagePopup({
    super.key,
    required this.isDark,
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  @override
  State<LanguagePopup> createState() => _LanguagePopupState();
}

class _LanguagePopupState extends State<LanguagePopup> {
  late String _lang;

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧', 'native': 'English'},
    {'code': 'ur', 'name': 'Urdu', 'flag': '🇵🇰', 'native': 'اردو'},
  ];

  @override
  void initState() {
    super.initState();
    _lang = widget.selectedLanguage;
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
    final previewText = _lang == 'ur'
        ? 'ہیلو، آپ کیسے ہیں؟'
        : 'Hello, how are you?';

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
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
                    'Default Language',
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
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
              const SizedBox(height: 8),
              Text(
                'Choose the language for subtitles and translations',
                style: GoogleFonts.rajdhani(fontSize: 12, color: mutedColor),
              ),
              const SizedBox(height: 20),

              Row(
                children: _languages.map((lang) {
                  final code = lang['code']!;
                  final name = lang['name']!;
                  final flag = lang['flag']!;
                  final native = lang['native']!;
                  final selected = _lang == code;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _lang = code);
                        widget.onLanguageSelected(code);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(right: code == 'en' ? 10 : 0),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withOpacity(0.12)
                              : (isDark
                                    ? const Color(0xFF252540)
                                    : const Color(0xFFF5F5FA)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(flag, style: const TextStyle(fontSize: 32)),
                            const SizedBox(height: 8),
                            Text(
                              name,
                              style: GoogleFonts.rajdhani(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: selected ? AppColors.primary : textColor,
                              ),
                            ),
                            Text(
                              native,
                              style: GoogleFonts.rajdhani(
                                fontSize: 13,
                                color: selected
                                    ? AppColors.primary.withOpacity(0.7)
                                    : mutedColor,
                              ),
                            ),
                            const SizedBox(height: 8),

                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : mutedColor.withOpacity(0.4),
                                  width: 2,
                                ),
                              ),
                              child: selected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
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
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        previewText,
                        key: ValueKey(_lang),
                        style: GoogleFonts.rajdhani(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        textDirection: _lang == 'ur'
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                      ),
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
