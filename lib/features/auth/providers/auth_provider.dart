import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_application_1/features/auth/models/user_model.dart';
import 'package:flutter_application_1/features/auth/services/auth_service.dart';
import 'package:flutter_application_1/core/services/notification_service.dart';

/// Provider for managing authentication state
class AuthProvider extends ChangeNotifier {
  static const String _mfuDomain = '@mfu.ac.th';
  static const String _lamduanDomain = '@lamduan.mfu.ac.th';

  final fb_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final NotificationService _notificationService;

  // Kept for constructor compatibility with current app wiring.
  final AuthService _authService;

  /// Internal state
  User? _user;
  bool _isProfileSetupComplete = false;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({
    required AuthService authService,
    fb_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
    NotificationService? notificationService,
  }) : _authService = authService,
       _firebaseAuth = firebaseAuth ?? fb_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(),
       _notificationService = notificationService ?? NotificationService();

  // Getters for state access
  User? get user => _user;
  User? get profile => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isProfileSetupComplete => _isProfileSetupComplete;
  bool get needsProfileSetup => isAuthenticated && !_isProfileSetupComplete;

  String get postLoginRoute => needsProfileSetup ? '/profile-setup' : '/home';

  /// Returns current user id, or a fallback guest id when not logged in.
  String getCurrentUserId() {
    return _user?.id ?? 'user_guest';
  }

  /// Google Sign-In + Firebase Auth with strict university domain check.
  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final googleUser = await _googleSignIn.signIn();

      // User closed Google account picker.
      if (googleUser == null) {
        _setLoading(false);
        return;
      }

      final normalizedEmail = googleUser.email.toLowerCase().trim();
      if (!_isAllowedUniversityEmail(normalizedEmail)) {
        await _googleSignIn.signOut();
        await _firebaseAuth.signOut();

        throw Exception(
          'Access Restricted. Please use your MFU university email.',
        );
      }

      final googleAuth = await googleUser.authentication;

      final credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Google sign-in failed. Please try again.');
      }

      final signedInEmail = (firebaseUser.email ?? '').toLowerCase().trim();
      if (!_isAllowedUniversityEmail(signedInEmail)) {
        await _googleSignIn.signOut();
        await _firebaseAuth.signOut();

        throw Exception(
          'Access Restricted. Please use your MFU university email.',
        );
      }

      _user = User(
        id: firebaseUser.uid,
        studentId: _deriveStudentIdFromEmail(signedInEmail),
        email: signedInEmail,
        name: firebaseUser.displayName?.trim().isNotEmpty == true
            ? firebaseUser.displayName!.trim()
            : 'Student User',
        faculty: '',
        profileImage: firebaseUser.photoURL,
      );

      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        _isProfileSetupComplete = userDoc.exists;

        final notificationsEnabled =
            userDoc.data()?['notificationsEnabled'] as bool? ?? false;
        if (notificationsEnabled) {
          await _notificationService.saveCurrentDeviceToken(firebaseUser.uid);
        }
      } catch (e) {
        _isProfileSetupComplete = false;
        throw Exception(e.toString());
      }

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  /// Backward-compatibility for existing callers that still invoke login().
  Future<void> login(String studentId, String password) async {
    await signInWithGoogle();
  }

  /// Logs out the current user
  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      final currentUserId = _user?.id;
      if (currentUserId != null && currentUserId.isNotEmpty) {
        try {
          await _notificationService.disableNotificationsForDevice(
            currentUserId,
          );
        } catch (_) {
          // Continue logout even if token cleanup fails.
        }
      }

      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      _user = null;
      _isProfileSetupComplete = false;
      _setLoading(false);
    } catch (e) {
      // Fallback to legacy service to avoid breaking existing flows.
      try {
        await _authService.logout();
      } catch (_) {}

      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  bool _isAllowedUniversityEmail(String email) {
    return email.endsWith(_mfuDomain) || email.endsWith(_lamduanDomain);
  }

  String _deriveStudentIdFromEmail(String email) {
    final atIndex = email.indexOf('@');
    if (atIndex <= 0) return '';
    return email.substring(0, atIndex);
  }

  void markProfileSetupComplete() {
    _isProfileSetupComplete = true;
    notifyListeners();
  }

  /// Helper method to update loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Helper method to set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Helper method to clear error message
  void _clearError() {
    _errorMessage = null;
  }
}
