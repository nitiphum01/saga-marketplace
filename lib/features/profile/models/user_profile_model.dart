/// Minimal profile model that keeps only marketplace-required personal data.
class UserProfile {
  final String studentId;
  final String name;
  final String profileImageUrl;
  final String fieldOfStudy;
  final String school;
  final String universityEmail;

  UserProfile({
    required this.studentId,
    required this.name,
    required this.profileImageUrl,
    required this.fieldOfStudy,
    required this.school,
    required this.universityEmail,
  });

  UserProfile copyWith({
    String? studentId,
    String? name,
    String? profileImageUrl,
    String? fieldOfStudy,
    String? school,
    String? universityEmail,
  }) {
    return UserProfile(
      studentId: studentId ?? this.studentId,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      school: school ?? this.school,
      universityEmail: universityEmail ?? this.universityEmail,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'fieldOfStudy': fieldOfStudy,
      'school': school,
      'universityEmail': universityEmail,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      studentId: map['studentId'] ?? '',
      name: map['name'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      fieldOfStudy: map['fieldOfStudy'] ?? '',
      school: map['school'] ?? '',
      universityEmail: map['universityEmail'] ?? '',
    );
  }

  @override
  String toString() {
    return 'UserProfile(studentId: $studentId, name: $name, fieldOfStudy: $fieldOfStudy)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.studentId == studentId;
  }

  @override
  int get hashCode => studentId.hashCode;
}
