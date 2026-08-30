import 'package:pler_to_pler_app/features/authentication/domain/entities/user_entity.dart';

/// Data Model - Handles JSON serialization/deserialization
/// Maps to/from Domain Entity
class UserModel {
  final String? id;
  final String email;
  final String? name;
  final String? role;
  final String? profilePicture;
  final bool? isEmailVerified;
  final bool? isActive;

  UserModel({
    this.id,
    required this.email,
    this.name,
    this.role,
    this.profilePicture,
    this.isEmailVerified,
    this.isActive,
  });

  /// Create from JSON (API response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? json['_id'] as String?,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? json['fullName'] as String?,
      role: json['role'] as String?,
      profilePicture: json['profilePicture'] as String? ?? 
                      json['avatar'] as String? ?? 
                      json['image'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? 
                       json['emailVerified'] as bool?,
      isActive: json['isActive'] as bool? ?? json['active'] as bool?,
    );
  }

  /// Convert to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'profilePicture': profilePicture,
      'isEmailVerified': isEmailVerified,
      'isActive': isActive,
    };
  }

  /// Convert to Domain Entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      role: role,
      profilePicture: profilePicture,
      isEmailVerified: isEmailVerified,
      isActive: isActive,
    );
  }

  /// Create from Entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      role: entity.role,
      profilePicture: entity.profilePicture,
      isEmailVerified: entity.isEmailVerified,
      isActive: entity.isActive,
    );
  }
}
