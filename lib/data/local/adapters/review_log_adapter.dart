import 'package:hive/hive.dart';
import 'package:fsrs/fsrs.dart';
import '../../models/review_log_model.dart';

class ReviewLogModelAdapter extends TypeAdapter<ReviewLogModel> {
  @override
  final int typeId = 31;

  @override
  ReviewLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReviewLogModel(
      id: fields[0] as String,
      cardId: fields[1] as String,
      cardType: fields[2] as String,
      rating: fields[3] as Rating,
      reviewDateTime: fields[4] as DateTime,
      scheduledDays: fields[5] as int,
      elapsedDays: fields[6] as int,
      state: fields[7] as State,
      cardState: fields[8] as State,
      responseTime: fields[9] as double,
      userId: fields[10] as String?,
      metadata: fields[11] as Map<String, dynamic>?,
    );
  }

  @override
  void write(BinaryWriter writer, ReviewLogModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cardId)
      ..writeByte(2)
      ..write(obj.cardType)
      ..writeByte(3)
      ..write(obj.rating)
      ..writeByte(4)
      ..write(obj.reviewDateTime)
      ..writeByte(5)
      ..write(obj.scheduledDays)
      ..writeByte(6)
      ..write(obj.elapsedDays)
      ..writeByte(7)
      ..write(obj.state)
      ..writeByte(8)
      ..write(obj.cardState)
      ..writeByte(9)
      ..write(obj.responseTime)
      ..writeByte(10)
      ..write(obj.userId)
      ..writeByte(11)
      ..write(obj.metadata);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
