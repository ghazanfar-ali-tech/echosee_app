import 'dart:io';
import 'package:echosee_app/app_theme.dart';
import 'package:echosee_app/provider/setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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
        // Show loading
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

    // Show loading
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
            padding: EdgeInsets.all(size.width * 0.05),
            child: Column(
              children: [
                // Profile Picture Section
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
                      height: 40, // only controls field height, not spacing
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: _nameController,
                        enabled: _isEditing,
                        style: GoogleFonts.rajdhani(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          height: 1.0, // 🔥 removes extra line height space
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
                        height: -1.0, // 🔥 removes line spacing
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
