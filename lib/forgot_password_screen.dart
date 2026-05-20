import 'package:echosee_app/app_constants.dart';
import 'package:echosee_app/widgets/custom_text_field.dart';
import 'package:echosee_app/widgets/roundButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      Fluttertoast.showToast(msg: "Password reset link sent! Check your email.");
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message ?? "An error occurred");
    } catch (e) {
      Fluttertoast.showToast(msg: "Something went wrong.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final hPad = size.width * 0.06;
    final cardRadius = size.width * 0.06;
    final colors = AppConstants.getColors(context);

    return Scaffold(
      backgroundColor: colors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - padding.top - padding.bottom - kToolbarHeight,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.02),
                  Icon(
                    Icons.lock_reset_rounded,
                    size: size.width * 0.25,
                    color: colors.primaryColor,
                  ),
                  SizedBox(height: size.height * 0.04),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: size.height * 0.035,
                    ),
                    decoration: BoxDecoration(
                      color: colors.cardColor,
                      borderRadius: BorderRadius.circular(cardRadius),
                      border: Border.all(color: colors.cardBorder, width: 1.5),
                      boxShadow: colors.isDark
                          ? [
                              BoxShadow(
                                color: const Color(0xFF00D4FF).withOpacity(0.04),
                                blurRadius: 24,
                                spreadRadius: 2,
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.orbitron(
                              color: colors.primaryText,
                              fontSize: size.width * 0.055,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
                        Center(
                          child: Text(
                            'Enter your email address to receive a password reset link.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.subText,
                              fontSize: size.width * 0.035,
                              height: 1.4,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.04),
                        Form(
                          key: _formKey,
                          child: CustomTextField(
                            hintText: 'Enter Gmail',
                            prefixIcon: Icons.email_rounded,
                            controller: _emailController,
                            isDark: colors.isDark,
                            primaryColor: colors.primaryColor,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your email";
                              }
                              if (!value.contains('@') || !value.contains('.')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: size.height * 0.04),
                        SizedBox(
                          width: double.infinity,
                          child: roundedButton(
                            text: 'Reset Password',
                            isLoading: _isLoading,
                            onTap: _resetPassword,
                            icon: Icons.send_rounded,
                            radius: 12,
                            gradientColors: const [
                              Color(0xFF7B2FBE),
                              Color(0xFF00D4FF),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
