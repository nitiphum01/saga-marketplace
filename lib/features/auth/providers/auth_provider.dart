import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/auth/models/user_model.dart';
import 'package:flutter_application_1/features/auth/services/auth_service.dart';

/// Provider for managing authentication state
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  /// Internal state
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({required AuthService authService}) : _authService = authService;

  // Getters for state access
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  /// Logs in a user with email and password
  Future<void> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.login(email, password);
      _setLoading(false);
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      _setLoading(false);
      rethrow;
    }
  }

  /// Logs out the current user
  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.logout();
      _user = null;
      _setLoading(false);
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
      _setLoading(false);
      rethrow;
    }
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
