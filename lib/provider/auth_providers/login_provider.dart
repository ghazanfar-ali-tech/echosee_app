import 'package:echosee_app/app_constants.dart';
import 'package:echosee_app/services/auth_services.dart';
import 'package:echosee_app/widgets/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginProvider extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isloading = false;
  bool get isLoading => _isloading;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;

  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  bool _isGoogleLoading = false;
  bool get isGoogleLoading => _isGoogleLoading;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void loginWithEmail(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Utils.toastMessage("Please fill all the fields!");
      return;
    }
    if (passwordController.text.length < 6) {
      Utils.toastMessage("Password must be at least 6 characters long!");
      return;
    }

    _isloading = true;
    notifyListeners();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      await AuthService.saveLoginState();
      Utils.toastMessage('Login successfully!');
      _emailController.clear();
      _passwordController.clear();

      if (context.mounted) {
        Navigator.pushNamed(context, AppRoutes.home);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }
      debugPrint(errorMessage);
      Utils.toastMessage(errorMessage);
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  void loginWithGoogle(BuildContext context) async {
    _isGoogleLoading = true;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // user cancelled
      if (googleUser == null) {
        _isGoogleLoading = false;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      await AuthService.saveLoginState(); // ✅ save session

      Utils.toastMessage('Login successfully!');

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      debugPrint(e.toString());
      Utils.toastMessage('Google sign in failed: $e');
    } finally {
      _isGoogleLoading = false;
      notifyListeners();
    }
  }

  void disposeControllers() {
    _emailController.dispose();
    _passwordController.dispose();
  }
}
