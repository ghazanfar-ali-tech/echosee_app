import 'package:echosee_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
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
          _buildSectionTitle('1. Information We Collect', isDark),
          _buildParagraph(
            'We collect information you provide directly to us, such as when you create or modify your account, use our services, or communicate with us. This may include your name, email address, and profile picture.',
            isDark,
          ),
          SizedBox(height: 16),
          _buildSectionTitle('2. How We Use Information', isDark),
          _buildParagraph(
            'We use the information we collect to provide, maintain, and improve our services, such as facilitating audio transcriptions, securing your account, and providing customer support.',
            isDark,
          ),
          SizedBox(height: 16),
          _buildSectionTitle('3. Data Storage and Security', isDark),
          _buildParagraph(
            'We implement robust security measures to protect your personal information. Audio data processed for transcriptions is handled securely and we do not permanently store recordings unless explicitly saved by you.',
            isDark,
          ),
          SizedBox(height: 16),
          _buildSectionTitle('4. Third-Party Services', isDark),
          _buildParagraph(
            'We may use third-party services to facilitate our services. These third parties have access to your Personal Information only to perform these tasks on our behalf and are obligated not to disclose or use it for any other purpose.',
            isDark,
          ),
          SizedBox(height: 16),
          _buildSectionTitle('5. Changes to This Policy', isDark),
          _buildParagraph(
            'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page. These changes are effective immediately after they are posted on this page.',
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
