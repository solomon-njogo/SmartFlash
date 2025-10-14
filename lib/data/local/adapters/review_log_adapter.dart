import 'package:hive/hive.dart';
import '../../models/review_log_model.dart';
import '../../models/fsrs_card_state_model.dart';

class ReviewLogAdapter extends TypeAdapter<ReviewLog> {
  @override
  final int typeId = 1;

  @override
  ReviewLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReviewLog(
      id: fields[0] as String,
      cardId: fields[1] as String,
      rating: fields[2] as int,
      reviewDateTime: fields[3] as DateTime,
      scheduledDays: fields[4] as int,
      elapsedDays: fields[5] as int,
      state: fields[6] as int,
      cardState: fields[7] as FSRSCardState,
      reviewType: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ReviewLog obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cardId)
      ..writeByte(2)
      ..write(obj.rating)
      ..writeByte(3)
      ..write(obj.reviewDateTime)
      ..writeByte(4)
      ..write(obj.scheduledDays)
      ..writeByte(5)
      ..write(obj.elapsedDays)
      ..writeByte(6)
      ..write(obj.state)
      ..writeByte(7)
      ..write(obj.cardState)
      ..writeByte(8)
      ..write(obj.reviewType);
  }
}