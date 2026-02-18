class User {
  final String id;
  final String studentId;
  final String email;
  final String name;
  final String faculty;
  final String? profileImage;

  User({
    required this.id,
    required this.studentId,
    required this.email,
    required this.name,
    required this.faculty,
    this.profileImage,
  });

  /// Creates a copy of this User with optional field replacements
  User copyWith({
    String? id,
    String? studentId,
    String? email,
    String? name,
    String? faculty,
    String? profileImage,
  }) {
    return User(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      email: email ?? this.email,
      name: name ?? this.name,
      faculty: faculty ?? this.faculty,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  /// Converts User instance to Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'email': email,
      'name': name,
      'faculty': faculty,
      'profileImage': profileImage,
    };
  }

  /// Creates User instance from Map
  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      studentId: map['studentId'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      faculty: map['faculty'] as String,
      profileImage: map['profileImage'] as String?,
    );
  }

  @override
  String toString() => 'User(id: $id, email: $email, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          studentId == other.studentId &&
          email == other.email &&
          name == other.name &&
          faculty == other.faculty &&
          profileImage == other.profileImage;

  @override
  int get hashCode =>
      id.hashCode ^
      studentId.hashCode ^
      email.hashCode ^
      name.hashCode ^
      faculty.hashCode ^
      profileImage.hashCode;
}
