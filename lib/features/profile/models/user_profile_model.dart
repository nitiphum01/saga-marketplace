/// Model representing detailed user profile information for students
class UserProfile {
  final String studentId;
  final String name;
  final String profileImageUrl;

  // Academic Information
  final String programOfStudy;
  final String fieldOfStudy;
  final String school;

  // Contact Information
  final String mobilePhone;
  final String personalEmail;
  final String universityEmail;

  // Emergency Contact
  final String emergencyContactName;
  final String emergencyContactPhone;

  // Advisor Information
  final String advisorName;
  final String advisorPhone;
  final String advisorEmail;

  UserProfile({
    required this.studentId,
    required this.name,
    required this.profileImageUrl,
    required this.programOfStudy,
    required this.fieldOfStudy,
    required this.school,
    required this.mobilePhone,
    required this.personalEmail,
    required this.universityEmail,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.advisorName,
    required this.advisorPhone,
    required this.advisorEmail,
  });

  /// Create a copy of the profile with updated fields
  UserProfile copyWith({
    String? studentId,
    String? name,
    String? profileImageUrl,
    String? programOfStudy,
    String? fieldOfStudy,
    String? school,
    String? mobilePhone,
    String? personalEmail,
    String? universityEmail,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? advisorName,
    String? advisorPhone,
    String? advisorEmail,
  }) {
    return UserProfile(
      studentId: studentId ?? this.studentId,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      programOfStudy: programOfStudy ?? this.programOfStudy,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      school: school ?? this.school,
      mobilePhone: mobilePhone ?? this.mobilePhone,
      personalEmail: personalEmail ?? this.personalEmail,
      universityEmail: universityEmail ?? this.universityEmail,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      advisorName: advisorName ?? this.advisorName,
      advisorPhone: advisorPhone ?? this.advisorPhone,
      advisorEmail: advisorEmail ?? this.advisorEmail,
    );
  }

  /// Convert to Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'programOfStudy': programOfStudy,
      'fieldOfStudy': fieldOfStudy,
      'school': school,
      'mobilePhone': mobilePhone,
      'personalEmail': personalEmail,
      'universityEmail': universityEmail,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'advisorName': advisorName,
      'advisorPhone': advisorPhone,
      'advisorEmail': advisorEmail,
    };
  }

  /// Create from Map for deserialization
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      studentId: map['studentId'] ?? '',
      name: map['name'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      programOfStudy: map['programOfStudy'] ?? '',
      fieldOfStudy: map['fieldOfStudy'] ?? '',
      school: map['school'] ?? '',
      mobilePhone: map['mobilePhone'] ?? '',
      personalEmail: map['personalEmail'] ?? '',
      universityEmail: map['universityEmail'] ?? '',
      emergencyContactName: map['emergencyContactName'] ?? '',
      emergencyContactPhone: map['emergencyContactPhone'] ?? '',
      advisorName: map['advisorName'] ?? '',
      advisorPhone: map['advisorPhone'] ?? '',
      advisorEmail: map['advisorEmail'] ?? '',
    );
  }

  @override
  String toString() {
    return 'UserProfile(studentId: $studentId, name: $name, programOfStudy: $programOfStudy)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserProfile && other.studentId == studentId;
  }

  @override
  int get hashCode => studentId.hashCode;
}
