import 'package:echosee_app/app_constants.dart';
import 'package:echosee_app/provider/auth_providers/login_provider.dart';
import 'package:echosee_app/widgets/custom_text_field.dart';
import 'package:echosee_app/widgets/app_logo_text.dart';
import 'package:echosee_app/widgets/google_logo.dart';
import 'package:echosee_app/widgets/roundButton.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    final hPad = size.width * 0.06;
    final cardRadius = size.width * 0.06;

    return Scaffold(
      backgroundColor: AppConstants.getColors(context).bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - padding.top - padding.bottom,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.08),
                  buildLogo(
                    AppConstants.getColors(context).isDark,
                    AppConstants.getColors(context).primaryColor,
                    AppConstants.getColors(context).subText,
                    size,
                  ),
                  SizedBox(height: size.height * 0.05),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: size.height * 0.035,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.getColors(context).cardColor,
                      borderRadius: BorderRadius.circular(cardRadius),
                      border: Border.all(
                        color: AppConstants.getColors(context).cardBorder,
                        width: 1.5,
                      ),
                      boxShadow: AppConstants.getColors(context).isDark
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF00D4FF,
                                ).withOpacity(0.04),
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
                            'Create Account',
                            style: GoogleFonts.orbitron(
                              color: AppConstants.getColors(
                                context,
                              ).primaryText,
                              fontSize: size.width * 0.055,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.006),
                        Center(
                          child: Text(
                            'login to Continue',
                            style: TextStyle(
                              color: AppConstants.getColors(context).subText,
                              fontSize: size.width * 0.035,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.03),
                        Consumer<LoginProvider>(
                          builder: (context, provider, child) {
                            return Form(
                              key: provider.formKey,
                              child: Column(
                                children: [
                                  CustomTextField(
                                    hintText: 'Gmail',
                                    prefixIcon: Icons.email_outlined,
                                    controller: provider.emailController,
                                    isDark: AppConstants.getColors(
                                      context,
                                    ).isDark,
                                    primaryColor: AppConstants.getColors(
                                      context,
                                    ).primaryColor,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Enter Gmail";
                                      }
                                      if (!value.contains('@') ||
                                          !value.contains('.')) {
                                        return 'Please enter a valid email address';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: size.height * 0.018),

                                  CustomTextField(
                                    hintText: 'Password',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    suffixIcon: provider.isPasswordVisible
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    controller: provider.passwordController,
                                    obscureText: !provider.isPasswordVisible,
                                    onSuffixTap: () =>
                                        provider.togglePasswordVisibility(),
                                    isDark: AppConstants.getColors(
                                      context,
                                    ).isDark,
                                    primaryColor: AppConstants.getColors(
                                      context,
                                    ).primaryColor,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Enter Password";
                                      }
                                      if (value.length < 6) {
                                        return "Password must be at least 6 characters long!";
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: size.height * 0.012),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.forgotPassword,
                                        );
                                      },
                                      child: Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          color: AppConstants.getColors(
                                            context,
                                          ).primaryColor,
                                          fontSize: size.width * 0.033,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.025),

                                  SizedBox(
                                    width: double.infinity,
                                    child: roundedButton(
                                      text: 'login',
                                      isLoading: provider.isLoading,
                                      onTap: () {
                                        provider.loginWithEmail(context);
                                      },
                                      icon: Icons.login,
                                      radius: 12,
                                      gradientColors: const [
                                        Color(0xFF7B2FBE),
                                        Color(0xFF00D4FF),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.022),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: AppConstants.getColors(
                                            context,
                                          ).cardBorder,
                                          thickness: 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Text(
                                          'OR',
                                          style: TextStyle(
                                            color: AppConstants.getColors(
                                              context,
                                            ).subText,
                                            fontSize: size.width * 0.032,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: AppConstants.getColors(
                                            context,
                                          ).cardBorder,
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.022),

                                  roundedButton(
                                    progressIndcatorColor:
                                        AppConstants.getColors(context).isDark
                                        ? Colors.black.withAlpha(200)
                                        : Colors.blue,
                                    gradientColors:
                                        AppConstants.getColors(context).isDark
                                        ? [
                                            Color.fromARGB(255, 42, 63, 94),
                                            Color.fromARGB(255, 42, 63, 94),
                                          ]
                                        : [Colors.transparent],
                                    text: 'Continue with google',
                                    isLoading: provider.isGoogleLoading,
                                    onTap: () {
                                      provider.loginWithGoogle(context);
                                    },
                                    leadingWidget: provider.isGoogleLoading
                                        ? null
                                        : googleIcon(size),
                                    icon: Icons.g_mobiledata,
                                    radius: 12,
                                    borderColor:
                                        AppConstants.getColors(context).isDark
                                        ? Colors.transparent
                                        : Colors.grey.withAlpha(100),
                                    useGradient: false,
                                    //  borderColor: cardBorder,
                                    textColor: const Color(0xFF6780A9),
                                    // leadingWidget: googleIcon(size),
                                  ),
                                  SizedBox(height: size.height * 0.025),

                                  Center(
                                    child: RichText(
                                      text: TextSpan(
                                        text: "Don't have an account? ",
                                        style: TextStyle(
                                          color: AppConstants.getColors(
                                            context,
                                          ).subText,
                                          fontSize: size.width * 0.033,
                                        ),
                                        children: [
                                          WidgetSpan(
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.pushReplacementNamed(
                                                  context,
                                                  AppRoutes.signup,
                                                );
                                              },
                                              child: Text(
                                                'Sign Up',
                                                style: TextStyle(
                                                  color: AppConstants.getColors(
                                                    context,
                                                  ).primaryColor,
                                                  fontSize: size.width * 0.033,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(height: size.height * 0.04),
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
