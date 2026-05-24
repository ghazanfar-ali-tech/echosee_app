import 'package:echosee_app/app_constants.dart';
import 'package:echosee_app/app_theme.dart';
import 'package:echosee_app/provider/setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color? textColor;
  final bool isDark;
  final VoidCallback onTap;
  final Widget? trailing;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
    this.textColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            size: 20,
          ),
      onTap: onTap,
    );
  }
}

class NotificationsToggle extends StatelessWidget {
  final SettingsProvider sp;
  final bool isDark;
  const NotificationsToggle({required this.sp, required this.isDark});

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
            sp.isNotificationsEnabled
                ? Icons.notifications_active_rounded
                : Icons.notifications_off_rounded,
            key: ValueKey(sp.isNotificationsEnabled),
            color: AppColors.primary,
            size: 20,
          ),
        ),
      ),
      title: Text(
        'Notifications',
        style: GoogleFonts.rajdhani(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
      ),
      trailing: Switch(
        value: sp.isNotificationsEnabled,
        onChanged: (value) => sp.setNotificationsEnabled(value),
        activeColor: AppColors.primary,
      ),
    );
  }
}

class FontSizeSetting extends StatefulWidget {
  final SettingsProvider sp;
  final bool isDark;
  const FontSizeSetting({required this.sp, required this.isDark});

  @override
  State<FontSizeSetting> createState() => _FontSizeSettingState();
}

class _FontSizeSettingState extends State<FontSizeSetting> {
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  final sizes = [
    {'label': 'Small', 'value': 14.0},
    {'label': 'Medium', 'value': 18.0},
    {'label': 'Large', 'value': 22.0},
    {'label': 'X-Large', 'value': 26.0},
  ];

  void _closePopup() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() => _isOpen = false);
    }
  }

  void _showPopup(BuildContext context) {
    if (_isOpen) {
      _closePopup();
      return;
    }

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _closePopup,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),

          Positioned(
            top: offset.dy + size.height + 8,
            right: MediaQuery.of(context).size.width - offset.dx - size.width,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: widget.isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PREVIEW',
                            style: GoogleFonts.rajdhani(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: widget.isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Consumer<SettingsProvider>(
                            builder: (context, sp, _) {
                              return Text(
                                sp.selectedLanguage == 'ur'
                                    ? 'ہیلو، آپ کیسے ہیں؟'
                                    : 'Hello, how are you?',
                                style: TextStyle(
                                  fontSize: sp.fontSize,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                textDirection: sp.selectedLanguage == 'ur'
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    Divider(
                      height: 1,
                      color: widget.isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),

                    ...sizes.map((sizeData) {
                      final label = sizeData['label'] as String;
                      final value = sizeData['value'] as double;

                      return StatefulBuilder(
                        builder: (context, setInnerState) {
                          final isSelected = widget.sp.fontSize == value;
                          return InkWell(
                            onTap: () {
                              widget.sp.setFontSize(value);
                              _overlayEntry?.markNeedsBuild();
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    label,
                                    style: GoogleFonts.rajdhani(
                                      fontSize: value * 0.75,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.primary
                                          : (widget.isDark
                                                ? AppColors.darkText
                                                : AppColors.lightText),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_rounded,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),

                    Divider(
                      height: 1,
                      color: widget.isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                    InkWell(
                      onTap: _closePopup,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Text(
                            'Close',
                            style: GoogleFonts.rajdhani(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSizeLabel =
        sizes.firstWhere(
              (s) => s['value'] == widget.sp.fontSize,
              orElse: () => sizes[1],
            )['label']
            as String;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
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
          Expanded(
            child: Text(
              'Subtitle Font Size',
              style: GoogleFonts.rajdhani(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: widget.isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ),
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => _showPopup(context),
              child: Row(
                children: [
                  Text(
                    currentSizeLabel,
                    style: GoogleFonts.rajdhani(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _isOpen ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: widget.isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showChangePasswordBottomSheet(BuildContext context, SettingsProvider sp) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

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
            backgroundColor ??
            (isDark ? const Color(0xFF1E1E2E) : Colors.white),
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

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Change Password',
                      style: GoogleFonts.orbitron(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Confirm your current password and choose a secure new one.',
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: currentPasswordController,
                      obscureText: obscureCurrent,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkText
                            : AppColors.lightText,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        labelStyle: GoogleFonts.rajdhani(
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.primary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureCurrent
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.primary,
                          ),
                          onPressed: () =>
                              setState(() => obscureCurrent = !obscureCurrent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your current password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: newPasswordController,
                      obscureText: obscureNew,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkText
                            : AppColors.lightText,
                      ),
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        labelStyle: GoogleFonts.rajdhani(
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_rounded,
                          color: AppColors.primary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureNew
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.primary,
                          ),
                          onPressed: () =>
                              setState(() => obscureNew = !obscureNew),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a new password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirm,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkText
                            : AppColors.lightText,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        labelStyle: GoogleFonts.rajdhani(
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_rounded,
                          color: AppColors.primary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.primary,
                          ),
                          onPressed: () =>
                              setState(() => obscureConfirm = !obscureConfirm),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value != newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            Navigator.pop(ctx);
                            final messenger = ScaffoldMessenger.of(context);
                            _showSnackBar(
                              context,
                              message: 'Updating password...',
                              showLoader: true,
                              duration: const Duration(minutes: 1),
                            );

                            final error = await sp.changePassword(
                              currentPasswordController.text,
                              newPasswordController.text,
                            );

                            messenger.hideCurrentSnackBar();
                            if (error == null) {
                              messenger.showSnackBar(
                                _buildSnackBar(
                                  isDark: isDark,
                                  message: 'Password updated successfully!',
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              messenger.showSnackBar(
                                _buildSnackBar(
                                  isDark: isDark,
                                  message: error,
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryDark,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              'Update Password',
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
              ),
            ),
          );
        },
      );
    },
  );
}

class PremiumBanner extends StatelessWidget {
  final bool isDark;
  const PremiumBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Color(0xFF2C0B59), Color(0xFF0D256C)]
              : [
                  Color(0xFFEDF5FF), // light blue
                  Color(0xFFEDDDFF), // light purple
                  Color(0xFFFFE7F4), // light pink
                ],
          stops: isDark ? null : [0.0, 0.5, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
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
                color: Color(0xFF4F46E5),
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'EchoSee Preemium',
                style: GoogleFonts.rajdhani(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4F46E5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const PremiumFeatureItem(
            text:
                'Multi-language translation (Arabic,\nFrench, Chinese, Spanish)',
          ),
          const PremiumFeatureItem(text: 'Unlimited transcript history'),
          const PremiumFeatureItem(text: 'Speaker identification'),
          const PremiumFeatureItem(text: 'Export to PDF'),
          const PremiumFeatureItem(text: 'Advanced subtitle customization'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
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
                    colors: [
                      Color(0xFF963CFB), // 0%
                      Color(0xFFC663FF), // 50%
                      Color(0xFFFF62F2),
                    ],
                    stops: [0.0, 0.5, 1.0],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 13,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFFD952FF),
                    //width: 1.5,
                  ),
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

class PremiumFeatureItem extends StatelessWidget {
  final String text;
  const PremiumFeatureItem({required this.text});

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
                    : Color(0xFF5A3A7E).withOpacity(0.85),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String title;
  final bool isDark;
  final List<Widget> children;

  const SettingsSection({
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
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.rajdhani(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.lightBg : AppColors.darkBorder,
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

class ThemeToggle extends StatelessWidget {
  final SettingsProvider sp;
  final bool isDark;
  const ThemeToggle({required this.sp, required this.isDark});

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
