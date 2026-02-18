import 'package:flutter_application_1/features/auth/models/user_model.dart';

/// Abstract service interface for authentication operations
abstract class AuthService {
  Future<User> login(String email, String password);
  Future<void> logout();
}

/// Mock implementation of AuthService with MFU student validation
class MockAuthService implements AuthService {
  /// MFU email domain
  static const String _mfuEmailDomain = '@lamduan.mfu.ac.th';

  /// Validates and logs in a user with MFU email verification
  @override
  Future<User> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Verify MFU email domain
    if (!email.endsWith(_mfuEmailDomain)) {
      throw Exception('Only MFU students allowed');
    }

    // Generate mock user data based on email
    final studentId = _extractStudentId(email);
    final user = User(
      id: 'user_${studentId}_${DateTime.now().millisecondsSinceEpoch}',
      studentId: studentId,
      email: email,
      name: _generateMockName(studentId),
      faculty: _generateMockFaculty(studentId),
      profileImage: 'https://via.placeholder.com/150?text=$studentId',
    );

    print('[MockAuthService] User logged in: ${user.email}');
    return user;
  }

  /// Logs out the current user
  @override
  Future<void> logout() async {
    // Simulate logout delay
    await Future.delayed(const Duration(milliseconds: 300));
    print('[MockAuthService] User logged out');
  }

  /// Extracts student ID from email (e.g., 'd640001' from '640001@lamduan.mfu.ac.th')
  String _extractStudentId(String email) {
    final parts = email.split('@');
    return parts[0];
  }

  /// Generates a mock name based on student ID
  String _generateMockName(String studentId) {
    final mockNames = [
      'Somchai Rungrot',
      'Niran Petchsri',
      'Supachai Wongon',
      'Aniwat Kaewprom',
      'Prawin Jaksripai',
      'Thaniya Nonta',
      'Waranont Jitmol',
      'Chutima Rungsri',
      'Duangchai Thongchit',
      'Somphet Kasimpor',
    ];
    final index = (studentId.hashCode % mockNames.length).abs();
    return mockNames[index];
  }

  /// Generates a mock faculty based on student ID
  String _generateMockFaculty(String studentId) {
    final mockFaculties = [
      'Faculty of Engineering',
      'Faculty of Science',
      'Faculty of Business',
      'Faculty of Liberal Arts',
      'Faculty of Architecture',
      'Faculty of Agricultural Technology',
      'Faculty of Information Technology',
      'Faculty of Medicine',
    ];
    final index = (studentId.hashCode % mockFaculties.length).abs();
    return mockFaculties[index];
  }
}
