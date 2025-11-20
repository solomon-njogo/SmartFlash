import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// User model for local and remote storage (Google OAuth only)
@HiveType(typeId: 0)
@JsonSerializable()
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String? displayName;

  @HiveField(3)
  final String? photoUrl;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  @HiveField(6)
  final bool isEmailVerified;

  @HiveField(7)
  final Map<String, dynamic>? preferences;

  @HiveField(8)
  final bool isOnline;

  @HiveField(9)
  final DateTime? lastSeen;

  @HiveField(10)
  final String? googleId;

  @HiveField(11)
  final String? firstName;

  @HiveField(12)
  final String? lastName;

  @HiveField(13)
  final String? locale;

  @HiveField(14)
  final bool isPremium;

  @HiveField(15)
  final DateTime? premiumExpiresAt;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isEmailVerified = true, // Google accounts are verified
    this.preferences,
    this.isOnline = false,
    this.lastSeen,
    this.googleId,
    this.firstName,
    this.lastName,
    this.locale,
    this.isPremium = false,
    this.premiumExpiresAt,
  });

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    Map<String, dynamic>? preferences,
    bool? isOnline,
    DateTime? lastSeen,
    String? googleId,
    String? firstName,
    String? lastName,
    String? locale,
    bool? isPremium,
    DateTime? premiumExpiresAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      preferences: preferences ?? this.preferences,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      googleId: googleId ?? this.googleId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      locale: locale ?? this.locale,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Get full name from first and last name
  String? get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return displayName;
  }

  /// Check if user has premium access
  bool get hasActivePremium {
    if (!isPremium) return false;
    if (premiumExpiresAt == null) return true; // Lifetime premium
    return DateTime.now().isBefore(premiumExpiresAt!);
  }

  /// Get user's initials for avatar
  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName!.substring(0, 1)}${lastName!.substring(0, 1)}'
          .toUpperCase();
    }
    if (displayName != null && displayName!.isNotEmpty) {
      final parts = displayName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'
            .toUpperCase();
      }
      return displayName!.substring(0, 1).toUpperCase();
    }
    return email.substring(0, 1).toUpperCase();
  }

  /// Create UserModel from Google OAuth data
  factory UserModel.fromGoogleAuth({
    required String id,
    required String email,
    String? displayName,
    String? photoUrl,
    String? firstName,
    String? lastName,
    String? locale,
    Map<String, dynamic>? preferences,
  }) {
    final now = DateTime.now();
    return UserModel(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      createdAt: now,
      updatedAt: now,
      isEmailVerified: true,
      preferences: preferences,
      isOnline: true,
      lastSeen: now,
      googleId: id,
      firstName: firstName,
      lastName: lastName,
      locale: locale,
      isPremium: false,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, displayName: $displayName, googleId: $googleId)';
  }
}
