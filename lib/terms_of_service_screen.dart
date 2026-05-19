import 'package:echosee_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms of Service',
          style: GoogleFonts.orbitron(
            fontSize: size.width * 0.05,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(size.width * 0.06),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.security_update_good,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Last Updated: May 2026',
                    style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          _buildSectionTitle('1. Acceptance of Terms', isDark),
          _buildParagraph(
            'By accessing and using EchoSee, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by these terms, please do not use our service.',
            isDark,
          ),
          SizedBox(height: 16),
          _buildSectionTitle('2. User License', isDark),
          _buildParagraph(
            'Permission is granted to temporarily download one copy of EchoSee for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title.',
            isDark,
          ),
          SizedBox(height: 16),
          _buildSectionTitle('3. Disclaimer', isDark),
          _buildParagraph(
            'The materials on EchoSee are provided on an \'as is\' basis. EchoSee makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.',
            isDark,
          ),
          SizedBox(height: 16),
          _buildSectionTitle('4. Limitations', isDark),
          _buildParagraph(
            'In no event shall EchoSee or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use EchoSee.',
            isDark,
          ),
          SizedBox(height: 16),
          _buildSectionTitle('5. Revisions and Errata', isDark),
          _buildParagraph(
            'The materials appearing on EchoSee could include technical, typographical, or photographic errors. EchoSee does not warrant that any of the materials on its app are accurate, complete, or current.',
            isDark,
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.orbitron(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text, bool isDark) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 15,
        height: 1.6,
        color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
      ),
    );
  }
}
