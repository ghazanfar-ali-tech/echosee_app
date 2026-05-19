import 'package:echosee_app/app_constants.dart';
import 'package:echosee_app/widgets/utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupProvider extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  TextEditingController get nameController => _nameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmPasswordController =>
      _confirmPasswordController;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  bool _isloading = false;
  bool get isLoading => _isloading;

  void sigupWithEmail(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Utils.toastMessage('Please fill all the fields!');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Utils.toastMessage('Passwords do not match!');
      return;
    }

    if (passwordController.text.length < 6) {
      Utils.toastMessage('Password must be at least 6 characters long!');
      return;
    }

    _isloading = true;
    notifyListeners();

    try {
      await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Utils.toastMessage('Account created successfully!');

      nameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      if (context.mounted) {
        Navigator.pushNamed(context, AppRoutes.home);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format.';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak.';
          break;
        default:
          errorMessage = 'Error: ${e.message}';
      }
      debugPrint(errorMessage);
      Utils.toastMessage(errorMessage);
    } catch (e) {
      debugPrint(e.toString());
      Utils.toastMessage('An unexpected error occurred: $e');
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  void disposeControllers() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }
}
