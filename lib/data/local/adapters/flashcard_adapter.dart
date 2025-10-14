import 'package:hive/hive.dart';
import '../../models/flashcard_model.dart';
import '../../models/fsrs_card_state_model.dart';

class FlashcardModelAdapter extends TypeAdapter<FlashcardModel> {
  @override
  final int typeId = 2;

  @override
  FlashcardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FlashcardModel(
      id: fields[0] as String,
      front: fields[1] as String,
      back: fields[2] as String,
      deckId: fields[3] as String,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
      fsrsState: fields[6] as FSRSCardState?,
      userId: fields[7] as String?,
      tags: (fields[8] as List).cast<String>(),
      difficulty: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FlashcardModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.front)
      ..writeByte(2)
      ..write(obj.back)
      ..writeByte(3)
      ..write(obj.deckId)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.fsrsState)
      ..writeByte(7)
      ..write(obj.userId)
      ..writeByte(8)
      ..write(obj.tags)
      ..writeByte(9)
      ..write(obj.difficulty);
  }
}