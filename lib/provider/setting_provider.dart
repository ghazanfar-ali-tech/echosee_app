import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echosee_app/auth_UI/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:echosee_app/services/auth_services.dart';
import 'package:echosee_app/services/cloudinary_service.dart';
import 'package:echosee_app/models/model.dart';
import 'package:echosee_app/repositries/setting_repo.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository;
  static const String _darkModeKey = 'dark_mode';
  static const String _notificationsKey = 'notifications_enabled';

  bool _isDisposed = false;

  late SettingsModel _settings;
  bool _isNotificationsEnabled = true;

  String? _userName;
  String? _userEmail;
  String? _profileImageUrl;
  bool _isProfileLoading = false;

  StreamSubscription? _profileSub;
  StreamSubscription? _authSub;

  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get profileImageUrl => _profileImageUrl;
  bool get isProfileLoading => _isProfileLoading;

  SettingsProvider({
    SettingsRepository? repository,
    bool initialDarkMode = false,
  }) : _repository = repository ?? SettingsRepository() {
    _settings = SettingsModel(isDarkMode: initialDarkMode);
    _loadOtherSettings();
    // fetchUserProfile();
    listenToUserProfile();
  }

  bool get isDarkMode => _settings.isDarkMode;
  double get fontSize => _settings.fontSize;
  String get subtitlePosition => _settings.subtitlePosition;
  int get subtitleColor => _settings.subtitleColor;
  String get selectedLanguage => _settings.selectedLanguage;
  bool get isPremium => _settings.isPremium;
  bool get isNotificationsEnabled => _isNotificationsEnabled;

  // Load SQLite settings without touching dark mode
  Future<void> _loadOtherSettings() async {
    final settings = await _repository.getSettings();
    // Preserve the already-correct dark mode value
    _settings = settings.copyWith(isDarkMode: _settings.isDarkMode);

    final prefs = await SharedPreferences.getInstance();
    _isNotificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    if (_isNotificationsEnabled == value) return;
    _isNotificationsEnabled = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
  }

  Future<void> toggleDarkMode() async {
    final newValue = !_settings.isDarkMode;
    _settings = _settings.copyWith(isDarkMode: newValue);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, newValue);
  }

  Future<void> setDarkMode(bool value) async {
    if (_settings.isDarkMode == value) return;
    _settings = _settings.copyWith(isDarkMode: value);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<void> setFontSize(double size) async {
    _settings = _settings.copyWith(fontSize: size);
    notifyListeners();
    await _repository.updateSetting('font_size', size);
  }

  Future<void> setSubtitlePosition(String position) async {
    _settings = _settings.copyWith(subtitlePosition: position);
    notifyListeners();
    await _repository.updateSetting('subtitle_position', position);
  }

  Future<void> setSubtitleColor(int color) async {
    _settings = _settings.copyWith(subtitleColor: color);
    notifyListeners();
    await _repository.updateSetting('subtitle_color', color);
  }

  Future<void> setSelectedLanguage(String language) async {
    _settings = _settings.copyWith(selectedLanguage: language);
    notifyListeners();
    await _repository.updateSetting('selected_language', language);
  }

  Future<void> setIsPremium(bool value) async {
    _settings = _settings.copyWith(isPremium: value);
    notifyListeners();
    await _repository.updateSetting('is_premium', value);
  }

  Future<void> loadSettings() async {
    final settings = await _repository.getSettings();
    _settings = settings.copyWith(isDarkMode: _settings.isDarkMode);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _settings = _settings.copyWith(selectedLanguage: language);
    notifyListeners();
    await _repository.updateSetting('selected_language', language);
  }

  Future<void> fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isProfileLoading = true;
    notifyListeners();

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _userName = data['name'] as String?;
        _userEmail = data['email'] as String?;
        _profileImageUrl = data['profileImageUrl'] as String?;
      } else {
        // Fallback to FirebaseAuth credentials and provision Firestore doc
        _userName =
            user.displayName ?? user.email?.split('@').first ?? 'EchoSee User';
        _userEmail = user.email;
        _profileImageUrl = user.photoURL;

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': _userName,
          'email': _userEmail,
          'profileImageUrl': _profileImageUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      // Fallback
      _userName =
          user.displayName ?? user.email?.split('@').first ?? 'EchoSee User';
      _userEmail = user.email;
      _profileImageUrl = user.photoURL;
    } finally {
      _isProfileLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfileImage(File imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    _isProfileLoading = true;
    notifyListeners();

    try {
      final secureUrl = await CloudinaryService.uploadProfileImage(
        imageFile: imageFile,
        userId: user.uid,
      );
      if (secureUrl != null) {
        // Update Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'profileImageUrl': secureUrl});

        // Update FirebaseAuth
        await user.updatePhotoURL(secureUrl);

        _profileImageUrl = secureUrl;
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating profile image: $e');
      return false;
    } finally {
      _isProfileLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfileDetails(String name, String email) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    print(name);
    print(email);
    _isProfileLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'name': name, 'email': email},
      );

      // Update FirebaseAuth
      await user.updateDisplayName(name);

      _userName = name;
      _userEmail = email;
      return true;
    } catch (e) {
      print('Error updating profile details: $e');
      return false;
    } finally {
      _isProfileLoading = false;
      notifyListeners();
    }
  }

  Future<String?> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'No user signed in.';

    try {
      final email = user.email;
      if (email != null) {
        final AuthCredential credential = EmailAuthProvider.credential(
          email: email,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
        return null; // success
      }
      return 'Email address not found.';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          return 'Incorrect current password.';
        case 'weak-password':
          return 'The new password is too weak.';
        default:
          return e.message ?? 'An error occurred while updating password.';
      }
    } catch (e) {
      return e.toString();
    }
  }

  void listenToUserProfile() {
    _authSub?.cancel();

    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      _profileSub?.cancel();

      if (user == null) {
        _userName = null;
        _userEmail = null;
        _profileImageUrl = null;
        notifyListeners();
        return;
      }

      _profileSub = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((doc) {
            if (_isDisposed) return;

            // Document doesn't exist — create it now
            if (!doc.exists) {
              final fallbackName =
                  user.displayName ??
                  user.email?.split('@').first ??
                  'EchoSee User';

              FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                'uid': user.uid,
                'name': fallbackName,
                'email': user.email,
                'profileImageUrl': user.photoURL,
                'createdAt': FieldValue.serverTimestamp(),
              });

              // Set locally while Firestore write completes
              _userName = fallbackName;
              _userEmail = user.email;
              _profileImageUrl = user.photoURL;
              notifyListeners();
              return;
            }

            // Document exists — read it normally
            final data = doc.data();
            _userName =
                data?['name'] as String? ??
                user.displayName ??
                user.email?.split('@').first ??
                'EchoSee User';
            _userEmail = data?['email'] as String? ?? user.email;
            _profileImageUrl = data?['profileImageUrl'] as String?;
            notifyListeners();
          });
    });
  }

  Future<void> clearUserSession() async {
    _profileSub?.cancel();
    _authSub?.cancel();

    _profileSub = null;
    _authSub = null;

    _userName = null;
    _userEmail = null;
    _profileImageUrl = null;

    notifyListeners();

    Future.delayed(Duration(milliseconds: 500), () {
      if (!_isDisposed) listenToUserProfile();
    });
  }

  Future<void> logout() async {
    try {
      // 1. Cancel subscriptions FIRST
      _profileSub?.cancel();
      _authSub?.cancel();
      _profileSub = null;
      _authSub = null;

      // 2. Clear in-memory state
      _userName = null;
      _userEmail = null;
      _profileImageUrl = null;
      notifyListeners();

      // 3. Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 4. Sign out Firebase
      await FirebaseAuth.instance.signOut();

      // 5. Restart listener for next login
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_isDisposed) listenToUserProfile();
      });
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _profileSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }
}
