import 'package:echosee_app/app_constants.dart';
import 'package:echosee_app/widgets/app_logo_text.dart';
import 'package:echosee_app/widgets/custom_text_field.dart';
import 'package:echosee_app/widgets/google_logo.dart';
import 'package:echosee_app/widgets/roundButton.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    final hPad = size.width * 0.06;
    final cardRadius = size.width * 0.06;

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

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
                            'Welcome Back',
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

                        customTextField(
                          hintText: 'Full Name',
                          prefixIcon: Icons.person_outline_rounded,
                          controller: nameController,
                          isDark: AppConstants.getColors(context).isDark,
                          primaryColor: AppConstants.getColors(
                            context,
                          ).primaryColor,
                        ),
                        SizedBox(height: size.height * 0.018),

                        customTextField(
                          hintText: 'Gmail',
                          prefixIcon: Icons.person_outline_rounded,
                          controller: emailController,
                          isDark: AppConstants.getColors(context).isDark,
                          primaryColor: AppConstants.getColors(
                            context,
                          ).primaryColor,
                        ),
                        SizedBox(height: size.height * 0.018),

                        customTextField(
                          hintText: 'Password',
                          prefixIcon: Icons.lock_outline_rounded,
                          suffixIcon: Icons.visibility_outlined,
                          controller: passwordController,
                          obscureText: true,
                          isDark: AppConstants.getColors(context).isDark,
                          primaryColor: AppConstants.getColors(
                            context,
                          ).primaryColor,
                        ),
                        SizedBox(height: size.height * 0.018),
                        customTextField(
                          hintText: 'Confirm Password',
                          prefixIcon: Icons.lock_outline_rounded,
                          suffixIcon: Icons.visibility_outlined,
                          controller: confirmPasswordController,
                          obscureText: true,
                          isDark: AppConstants.getColors(context).isDark,
                          primaryColor: AppConstants.getColors(
                            context,
                          ).primaryColor,
                        ),
                        SizedBox(height: size.height * 0.012),

                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {},
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
                            text: 'SignUp',
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.home);
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
                        // SizedBox(height: size.height * 0.022),

                        // SizedBox(
                        //   width: double.infinity,
                        //   child: roundedButton(
                        //     gradientColors: [
                        //       Color.fromARGB(255, 42, 63, 94),
                        //       Color.fromARGB(255, 42, 63, 94),
                        //     ],
                        //     text: 'Continue with google',
                        //     onTap: () {},
                        //     icon: Icons.g_mobiledata,
                        //     radius: 12,
                        //     useGradient: false,
                        //     //  borderColor: cardBorder,
                        //     textColor: Colors.grey.shade400,
                        //     leadingWidget: googleIcon(size),
                        //   ),
                        // ),
                        SizedBox(height: size.height * 0.025),

                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(
                                color: AppConstants.getColors(context).subText,
                                fontSize: size.width * 0.033,
                              ),
                              children: [
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () {},
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
                  ),
                  SizedBox(height: size.height * 0.04),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
