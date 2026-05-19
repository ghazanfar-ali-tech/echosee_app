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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCard
            : AppColors.lightCard,
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
          style: GoogleFonts.rajdhani(fontSize: 15),
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
                                color: AppColors.darkTextMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: size.height * 0.008),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: sp.isPremium
                                    ? AppColors.accent.withOpacity(0.2)
                                    : AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: sp.isPremium
                                      ? AppColors.accent.withOpacity(0.5)
                                      : AppColors.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                sp.isPremium ? '⭐ Premium' : 'Free Plan',
                                style: GoogleFonts.rajdhani(
                                  fontSize: size.width * 0.03,
                                  fontWeight: FontWeight.w700,
                                  color: sp.isPremium
                                      ? AppColors.accentGlow
                                      : AppColors.primary,
                                ),
                              ),
                            ),
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
                  children: [_ThemeToggle(sp: sp)],
                ),
              ),

              SizedBox(height: size.height * 0.02),

              FadeSlideIn(
                delay: const Duration(milliseconds: 120),
                child: _SettingsSection(
                  title: 'Support & Legal',
                  children: [
                    _SettingsTile(
                      icon: Icons.people_alt_rounded,
                      label: 'Contact Developer',
                      color: const Color(0xFF0077B5),
                      onTap: () => _launchUrl(
                        'https://www.linkedin.com/company/your-company',
                      ),
                    ),
                    const Divider(height: 1, indent: 56),
                    _SettingsTile(
                      icon: Icons.description_rounded,
                      label: 'Terms of Service',
                      color: AppColors.primary,
                      onTap: () => _launchUrl('https://your-website.com/terms'),
                    ),
                    const Divider(height: 1, indent: 56),
                    _SettingsTile(
                      icon: Icons.privacy_tip_rounded,
                      label: 'Privacy Policy',
                      color: AppColors.primary,
                      onTap: () =>
                          _launchUrl('https://your-website.com/privacy'),
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.02),

              FadeSlideIn(
                delay: const Duration(milliseconds: 180),
                child: _SettingsSection(
                  title: 'Account',
                  children: [
                    _SettingsTile(
                      icon: Icons.logout_rounded,
                      label: 'Logout',
                      color: AppColors.error,
                      textColor: AppColors.error,
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
                    color: AppColors.darkTextMuted,
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
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.color,
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
              textColor ??
              (Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkText
                  : AppColors.lightText),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.darkTextMuted,
        size: 20,
      ),
      onTap: onTap,
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
        style: GoogleFonts.rajdhani(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      trailing: Switch(
        value: sp.isDarkMode,
        onChanged: (_) => sp.toggleDarkMode(),
        activeColor: AppColors.primary,
      ),
    );
  }
}
