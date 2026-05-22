import 'package:echosee_app/app_constants.dart';
import 'package:echosee_app/app_theme.dart';
import 'package:echosee_app/provider/setting_provider.dart';
import 'package:echosee_app/services/auth_services.dart';
import 'package:echosee_app/widgets/animated_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Logout',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.w700,
            color: AppColors.error,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.rajdhani(
            fontSize: 15,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.rajdhani(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              await AuthService.clearLoginState();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
            child: Text(
              'Logout',
              style: GoogleFonts.rajdhani(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<SettingsProvider>(
      builder: (_, sp, __) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Settings',
              style: GoogleFonts.orbitron(
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          body: ListView(
            padding: EdgeInsets.all(size.width * 0.04),
            children: [
              FadeSlideIn(
                child: Container(
                  padding: EdgeInsets.all(size.width * 0.05),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.15),
                        AppColors.primaryDark.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: size.width * 0.08,
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        child: user?.photoURL == null
                            ? Icon(
                                Icons.person_rounded,
                                size: size.width * 0.08,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                      SizedBox(width: size.width * 0.04),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? 'EchoSee User',
                              style: GoogleFonts.orbitron(
                                fontSize: size.width * 0.04,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkText
                                    : AppColors.lightText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: size.height * 0.005),
                            Text(
                              user?.email ?? '',
                              style: GoogleFonts.rajdhani(
                                fontSize: size.width * 0.033,
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.lightTextMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: size.height * 0.008),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.025),

              FadeSlideIn(
                delay: const Duration(milliseconds: 60),
                child: _SettingsSection(
                  title: 'Display',
                  isDark: isDark,
                  children: [
                    _ThemeToggle(sp: sp, isDark: isDark),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                    _FontSizeSetting(sp: sp, isDark: isDark),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.025),
              if (!sp.isPremium) ...[
                FadeSlideIn(
                  delay: const Duration(milliseconds: 30),
                  child: _PremiumBanner(isDark: isDark),
                ),
                SizedBox(height: size.height * 0.025),
              ],

              SizedBox(height: size.height * 0.02),

              FadeSlideIn(
                delay: const Duration(milliseconds: 120),
                child: _SettingsSection(
                  title: 'Support & Legal',
                  isDark: isDark,
                  children: [
                    _SettingsTile(
                      icon: Icons.people_alt_rounded,
                      label: 'Contact Developer',
                      color: const Color(0xFF0077B5),
                      isDark: isDark,
                      onTap: () => _launchUrl(
                        'https://www.linkedin.com/company/your-company',
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                    _SettingsTile(
                      icon: Icons.description_rounded,
                      label: 'Terms of Service',
                      color: AppColors.primary,
                      isDark: isDark,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.termsOfService,
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                    _SettingsTile(
                      icon: Icons.privacy_tip_rounded,
                      label: 'Privacy Policy',
                      color: AppColors.primary,
                      isDark: isDark,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.privacyPolicy),
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.02),

              FadeSlideIn(
                delay: const Duration(milliseconds: 180),
                child: _SettingsSection(
                  title: 'Account',
                  isDark: isDark,
                  children: [
                    _SettingsTile(
                      icon: Icons.logout_rounded,
                      label: 'Logout',
                      color: AppColors.error,
                      textColor: AppColors.error,
                      isDark: isDark,
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.03),

              Center(
                child: Text(
                  'EchoSee v1.0.0',
                  style: GoogleFonts.rajdhani(
                    fontSize: size.width * 0.032,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                    letterSpacing: 1,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color? textColor;
  final bool isDark;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: GoogleFonts.rajdhani(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color:
              textColor ?? (isDark ? AppColors.darkText : AppColors.lightText),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final bool isDark;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.isDark,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
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
  final bool isDark;
  const _ThemeToggle({required this.sp, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: AnimatedSwitcher(
          duration: AppConstants.animNormal,
          child: Icon(
            sp.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            key: ValueKey(sp.isDarkMode),
            color: AppColors.primary,
            size: 20,
          ),
        ),
      ),
      title: Text(
        'Dark Mode',
        style: GoogleFonts.rajdhani(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
      ),
      trailing: Switch(
        value: sp.isDarkMode,
        onChanged: (_) => sp.toggleDarkMode(),
        activeColor: AppColors.primary,
      ),
    );
  }
}

class _FontSizeSetting extends StatelessWidget {
  final SettingsProvider sp;
  final bool isDark;
  const _FontSizeSetting({required this.sp, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final sizes = [
      {'label': 'Small', 'value': 14.0},
      {'label': 'Medium', 'value': 18.0},
      {'label': 'Large', 'value': 22.0},
      {'label': 'X-Large', 'value': 26.0},
    ];

    final currentSizeLabel =
        sizes.firstWhere(
              (s) => s['value'] == sp.fontSize,
              orElse: () => sizes[1],
            )['label']
            as String;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.text_fields_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Font Size',
                style: GoogleFonts.rajdhani(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const Spacer(),
              Text(
                currentSizeLabel,
                style: GoogleFonts.rajdhani(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Hello, How are you.',
            style: TextStyle(
              fontSize: sp.fontSize,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: sizes.map((sizeData) {
              final label = sizeData['label'] as String;
              final value = sizeData['value'] as double;
              final isSelected = sp.fontSize == value;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ScaleTap(
                    onTap: () => sp.setFontSize(value),
                    child: AnimatedContainer(
                      duration: AppConstants.animNormal,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                        ),
                      ),
                      child: Text(
                        label,
                        style: GoogleFonts.rajdhani(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.lightTextMuted),
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
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

class _PremiumBanner extends StatelessWidget {
  final bool isDark;
  const _PremiumBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Color(0xFF2C0B59), Color(0xFF0D256C)]
              : [
                  Color(0xFFD9B3F5), // deeper lilac purple
                  Color(0xFFB8C8F8), // soft periwinkle blue (bottom-right)
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Color(0xFF9B6FD4).withOpacity(0.40),
                  blurRadius: 28,
                  spreadRadius: 4,
                  offset: Offset(0, 10),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                color: Color(0xFF9E54FF),
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'EchoSee Freemium',
                style: GoogleFonts.rajdhani(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF9E54FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _PremiumFeatureItem(
            text:
                'Multi-language translation (Arabic,\nFrench, Chinese, Spanish)',
          ),
          const _PremiumFeatureItem(text: 'Unlimited transcript history'),
          const _PremiumFeatureItem(text: 'Speaker identification'),
          const _PremiumFeatureItem(text: 'Export to PDF'),
          const _PremiumFeatureItem(text: 'Advanced subtitle customization'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {}, // Can add action to upgrade
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.zero,
              ).copyWith(elevation: WidgetStateProperty.all(0)),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8A2BE2), Color(0xFF00E5FF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Upgrade Now',
                    style: GoogleFonts.rajdhani(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumFeatureItem extends StatelessWidget {
  final String text;
  const _PremiumFeatureItem({required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 12),
            child: Icon(
              Icons.radio_button_checked,
              color: Color(0xFF5A3A7E).withOpacity(0.85),
              size: 14,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark
                    ? Colors.white.withOpacity(0.8)
                    : Color(
                        0xFF5A3A7E,
                      ).withOpacity(0.85), // deep purple for light mode
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
