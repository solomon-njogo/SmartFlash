import 'package:hive/hive.dart';
import 'package:fsrs/fsrs.dart';
import '../../models/fsrs_card_state_model.dart';

class FSRSCardStateAdapter extends TypeAdapter<FSRSCardState> {
  @override
  final int typeId = 30;

  @override
  FSRSCardState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FSRSCardState(
      cardId: fields[0] as int,
      state: fields[1] as State,
      step: fields[2] as int,
      stability: fields[3] as double?,
      difficulty: fields[4] as double?,
      due: fields[5] as DateTime,
      lastReview: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, FSRSCardState obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.cardId)
      ..writeByte(1)
      ..write(obj.state)
      ..writeByte(2)
      ..write(obj.step)
      ..writeByte(3)
      ..write(obj.stability)
      ..writeByte(4)
      ..write(obj.difficulty)
      ..writeByte(5)
      ..write(obj.due)
      ..writeByte(6)
      ..write(obj.lastReview);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FSRSCardStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
