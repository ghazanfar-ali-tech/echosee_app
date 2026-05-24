import 'dart:io';
import 'package:echosee_app/Settings_Screens/setting_widgets.dart';
import 'package:echosee_app/app_constants.dart';
import 'package:echosee_app/app_theme.dart';
import 'package:echosee_app/provider/setting_provider.dart';
import 'package:echosee_app/widgets/animated_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _showSnackBar(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    bool showLoader = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      _buildSnackBar(
        isDark: isDark,
        message: message,
        backgroundColor: backgroundColor,
        showLoader: showLoader,
        duration: duration,
      ),
    );
  }

  SnackBar _buildSnackBar({
    required bool isDark,
    required String message,
    Color? backgroundColor,
    bool showLoader = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    return SnackBar(
      duration: duration,
      backgroundColor:
          backgroundColor ?? (isDark ? const Color(0xFF1E1E2E) : Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      elevation: 4,
      content: Row(
        children: [
          if (showLoader) ...[
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(width: 12),
          ] else if (backgroundColor == Colors.green) ...[
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 18,
            ),
            const SizedBox(width: 12),
          ] else if (backgroundColor == Colors.red) ...[
            const Icon(Icons.error_rounded, color: Colors.red, size: 18),
            const SizedBox(width: 12),
          ] else ...[
            Icon(Icons.info_rounded, color: AppColors.primary, size: 18),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final sp = context.read<SettingsProvider>();
    _nameController.text = sp.userName ?? '';
    _emailController.text = sp.userEmail ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage(SettingsProvider sp) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                const SizedBox(width: 16),
                Text('Uploading to Cloudinary...'),
              ],
            ),
            duration: Duration(minutes: 1),
          ),
        );

        final success = await sp.updateProfileImage(File(pickedFile.path));

        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (success) {
          _showSnackBar(
            context,
            message: 'Profile image updated successfully!',
            backgroundColor: Colors.green,
          );
        } else {
          _showSnackBar(
            context,
            message:
                'Failed to upload image. Please check Cloudinary settings.',
            backgroundColor: Colors.red,
          );
        }
      }
    } catch (e) {
      _showSnackBar(context, message: 'Error: $e', backgroundColor: Colors.red);
    }
  }

  Future<void> _saveChanges(SettingsProvider sp) async {
    final newName = _nameController.text.trim();
    final newEmail = _emailController.text.trim();

    if (newName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Text('Saving changes...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    final success = await sp.updateProfileDetails(newName, newEmail);

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (success) {
      setState(() {
        _isEditing = false;
      });
      _showSnackBar(
        context,
        message: 'Profile image updated successfully!',
        backgroundColor: Colors.green,
      );
    } else {
      _showSnackBar(
        context,
        message: 'Failed to update profile',
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<SettingsProvider>(
      builder: (context, sp, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              sp.userName ?? 'Profile',
              style: GoogleFonts.orbitron(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              if (!_isEditing)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  child: Text(
                    'Edit',
                    style: GoogleFonts.rajdhani(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              if (_isEditing)
                TextButton(
                  onPressed: () => _saveChanges(sp),
                  child: Text(
                    'Save',
                    style: GoogleFonts.rajdhani(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.01),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _isEditing ? () => _pickAndUploadImage(sp) : null,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 58,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          backgroundImage:
                              sp.profileImageUrl != null &&
                                  sp.profileImageUrl!.isNotEmpty
                              ? NetworkImage(sp.profileImageUrl!)
                              : null,
                          child:
                              sp.profileImageUrl == null ||
                                  sp.profileImageUrl!.isEmpty
                              ? Icon(
                                  Icons.person_rounded,
                                  size: 60,
                                  color: AppColors.primary,
                                )
                              : null,
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              // border: Border.all(
                              //   color: isDark
                              //       ? AppColors.darkBackground
                              //       : AppColors.lightBackground,
                              //   width: 3,
                              // ),
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      if (sp.isProfileLoading)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 10),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: _nameController,
                        enabled: _isEditing,
                        style: GoogleFonts.rajdhani(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.lightText,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      sp.userEmail ?? "",
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        height: -1.0,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.all(size.width * 0.04),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.025),

                      FadeSlideIn(
                        delay: const Duration(milliseconds: 60),
                        child: SettingsSection(
                          title: 'Preferences',
                          isDark: isDark,
                          children: [
                            FontSizeSetting(sp: sp, isDark: isDark),
                            Divider(
                              height: 1,

                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),

                            SettingsTile(
                              icon: Icons.g_translate_rounded,
                              label: 'Default Language',
                              color: AppColors.primary,
                              isDark: isDark,
                              onTap: () {},
                            ),

                            Divider(
                              height: 1,

                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                            // SizedBox(height: size.height * 0.01),
                            ThemeToggle(sp: sp, isDark: isDark),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        child: SettingsTile(
                          icon: Icons.switch_account_rounded,
                          label: 'Speaker ID',
                          color: AppColors.primary,
                          isDark: isDark,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Enabled',
                                style: GoogleFonts.rajdhani(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.lightTextMuted,
                                size: 20,
                              ),
                            ],
                          ),
                          onTap: () {},
                        ),
                      ),
                      SizedBox(height: size.height * 0.025),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 1),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Accounts".toUpperCase(),
                            style: GoogleFonts.rajdhani(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.lightBg
                                  : AppColors.darkBorder,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        child: SettingsTile(
                          icon: Icons.workspace_premium_rounded,
                          label: 'Subscription',
                          color: AppColors.primary,
                          isDark: isDark,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3CD),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFFFD700).withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Freemium',
                              style: GoogleFonts.rajdhani(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFB8860B),
                              ),
                            ),
                          ),
                          onTap: () {},
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),

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
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<void> _launchUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

void _showSnackBar(
  BuildContext context, {
  required String message,
  Color? backgroundColor,
  bool showLoader = false,
  Duration duration = const Duration(seconds: 3),
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: duration,
      backgroundColor:
          backgroundColor ?? (isDark ? const Color(0xFF1E1E2E) : Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      elevation: 4,
      content: Row(
        children: [
          if (showLoader) ...[
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? AppColors.primary : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ] else if (backgroundColor == Colors.green) ...[
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 18,
            ),
            const SizedBox(width: 12),
          ] else if (backgroundColor == Colors.red) ...[
            const Icon(Icons.error_rounded, color: Colors.red, size: 18),
            const SizedBox(width: 12),
          ] else ...[
            Icon(
              Icons.info_rounded,
              color: isDark ? AppColors.primary : AppColors.primary,
              size: 18,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

SnackBar _buildSnackBar({
  required bool isDark,
  required String message,
  Color? backgroundColor,
  bool showLoader = false,
  Duration duration = const Duration(seconds: 3),
}) {
  return SnackBar(
    duration: duration,
    backgroundColor:
        backgroundColor ?? (isDark ? const Color(0xFF1E1E2E) : Colors.white),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.all(16),
    elevation: 4,
    content: Row(
      children: [
        if (showLoader) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
        ] else if (backgroundColor == Colors.green) ...[
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
          const SizedBox(width: 12),
        ] else if (backgroundColor == Colors.red) ...[
          const Icon(Icons.error_rounded, color: Colors.red, size: 18),
          const SizedBox(width: 12),
        ] else ...[
          Icon(Icons.info_rounded, color: AppColors.primary, size: 18),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            message,
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ),
      ],
    ),
  );
}
