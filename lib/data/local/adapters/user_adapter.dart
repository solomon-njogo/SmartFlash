import 'package:hive/hive.dart';
import '../../models/user_model.dart';

/// Hive adapter for UserModel
class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      email: fields[1] as String,
      displayName: fields[2] as String?,
      photoUrl: fields[3] as String?,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
      isEmailVerified: fields[6] as bool? ?? true,
      preferences: fields[7] as Map<String, dynamic>?,
      isOnline: fields[8] as bool? ?? false,
      lastSeen: fields[9] as DateTime?,
      googleId: fields[10] as String?,
      firstName: fields[11] as String?,
      lastName: fields[12] as String?,
      locale: fields[13] as String?,
      isPremium: fields[14] as bool? ?? false,
      premiumExpiresAt: fields[15] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.photoUrl)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.isEmailVerified)
      ..writeByte(7)
      ..write(obj.preferences)
      ..writeByte(8)
      ..write(obj.isOnline)
      ..writeByte(9)
      ..write(obj.lastSeen)
      ..writeByte(10)
      ..write(obj.googleId)
      ..writeByte(11)
      ..write(obj.firstName)
      ..writeByte(12)
      ..write(obj.lastName)
      ..writeByte(13)
      ..write(obj.locale)
      ..writeByte(14)
      ..write(obj.isPremium)
      ..writeByte(15)
      ..write(obj.premiumExpiresAt);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
