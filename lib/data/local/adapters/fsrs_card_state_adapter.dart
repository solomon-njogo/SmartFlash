import 'package:hive/hive.dart';
import '../../models/fsrs_card_state_model.dart';

class FSRSCardStateAdapter extends TypeAdapter<FSRSCardState> {
  @override
  final int typeId = 0;

  @override
  FSRSCardState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FSRSCardState(
      due: fields[0] as DateTime,
      stability: fields[1] as double,
      difficulty: fields[2] as double,
      elapsedDays: fields[3] as int,
      scheduledDays: fields[4] as int,
      reps: fields[5] as int,
      lapses: fields[6] as int,
      state: fields[7] as int,
      lastReview: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FSRSCardState obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.due)
      ..writeByte(1)
      ..write(obj.stability)
      ..writeByte(2)
      ..write(obj.difficulty)
      ..writeByte(3)
      ..write(obj.elapsedDays)
      ..writeByte(4)
      ..write(obj.scheduledDays)
      ..writeByte(5)
      ..write(obj.reps)
      ..writeByte(6)
      ..write(obj.lapses)
      ..writeByte(7)
      ..write(obj.state)
      ..writeByte(8)
      ..write(obj.lastReview);
  }
}