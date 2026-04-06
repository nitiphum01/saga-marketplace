import 'package:flutter_application_1/features/auth/models/user_model.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;

/// Abstract service interface for authentication operations
abstract class AuthService {
  Future<User> login(String studentId, String password);
  Future<void> logout();
}

/// Mock implementation of AuthService with MFU student validation
class MockAuthService implements AuthService {
  /// MFU email domain
  static const String _mfuEmailDomain = '@lamduan.mfu.ac.th';

  /// Mock password injected at build/run time.
  /// Example: --dart-define=MOCK_AUTH_PASSWORD=your-dev-password
  static const String _mockAuthPassword = String.fromEnvironment(
    'MOCK_AUTH_PASSWORD',
  );

  /// Mock users keyed by MFU email
  static const Map<String, Map<String, String>> _mockUsers = {
    '6731503017@lamduan.mfu.ac.th': {
      'studentId': '6731503017',
      'name': 'John Doe',
      'faculty': 'School of Information Technology',
    },
    '6731503001@lamduan.mfu.ac.th': {
      'studentId': '6731503001',
      'name': 'Alice Smith',
      'faculty': 'School of Science',
    },
    '6731503002@lamduan.mfu.ac.th': {
      'studentId': '6731503002',
      'name': 'Bob Johnson',
      'faculty': 'School of Management',
    },
    '6731503003@lamduan.mfu.ac.th': {
      'studentId': '6731503003',
      'name': 'Emma Davis',
      'faculty': 'School of Liberal Arts',
    },
    '6731503004@lamduan.mfu.ac.th': {
      'studentId': '6731503004',
      'name': 'Liam Wilson',
      'faculty': 'School of Health Science',
    },
    '6731503005@lamduan.mfu.ac.th': {
      'studentId': '6731503005',
      'name': 'Olivia Brown',
      'faculty': 'School of Law',
    },
  };

  static void _ensureMockAuthConfigured() {
    if (kReleaseMode) {
      throw Exception(
        'MockAuthService is disabled in release builds. Use a real backend auth provider.',
      );
    }

    if (_mockAuthPassword.isEmpty) {
      throw Exception(
        'Missing MOCK_AUTH_PASSWORD. Run with --dart-define=MOCK_AUTH_PASSWORD=<password>.',
      );
    }
  }

  /// Validates and logs in a user with student ID + password.
  /// The domain is appended automatically before credential lookup.
  @override
  Future<User> login(String studentId, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    _ensureMockAuthConfigured();

    final normalizedStudentId = studentId.trim();
    if (!_isValidStudentId(normalizedStudentId)) {
      throw Exception('Student ID must be exactly 10 digits');
    }

    final finalEmail = '$normalizedStudentId$_mfuEmailDomain';
    final userData = _mockUsers[finalEmail];

    if (userData == null) {
      throw Exception('Invalid credentials');
    }

    if (password != _mockAuthPassword) {
      throw Exception('Invalid credentials');
    }

    final user = User(
      id: 'user_${userData['studentId']}',
      studentId: userData['studentId']!,
      email: finalEmail,
      name: userData['name']!,
      faculty: userData['faculty']!,
      profileImage:
          'https://via.placeholder.com/150?text=${userData['studentId']}',
    );
    return user;
  }

  /// Logs out the current user
  @override
  Future<void> logout() async {
    // Simulate logout delay
    await Future.delayed(const Duration(milliseconds: 300));
  }

  bool _isValidStudentId(String studentId) {
    return RegExp(r'^\d{10}$').hasMatch(studentId);
  }
}
