/// Domain Entity - Pure business object, no dependencies
class UserEntity {
  final String? id;
  final String email;
  final String? name;
  final String? role;
  final String? profilePicture;
  final bool? isEmailVerified;
  final bool? isActive;

  UserEntity({
    this.id,
    required this.email,
    this.name,
    this.role,
    this.profilePicture,
    this.isEmailVerified,
    this.isActive,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          name == other.name &&
          role == other.role &&
          profilePicture == other.profilePicture &&
          isEmailVerified == other.isEmailVerified &&
          isActive == other.isActive;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      name.hashCode ^
      role.hashCode ^
      profilePicture.hashCode ^
      isEmailVerified.hashCode ^
      isActive.hashCode;
}
