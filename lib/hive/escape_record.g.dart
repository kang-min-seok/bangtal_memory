// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'escape_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EscapeRecordAdapter extends TypeAdapter<EscapeRecord> {
  @override
  final int typeId = 0;

  @override
  EscapeRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EscapeRecord(
      id: fields[0] as int,
      date: fields[1] as String,
      storeName: fields[2] as String,
      themeName: fields[3] as String,
      difficulty: fields[4] as String,
      satisfaction: fields[5] as String,
      genre: fields[6] as String,
      region: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, EscapeRecord obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.storeName)
      ..writeByte(3)
      ..write(obj.themeName)
      ..writeByte(4)
      ..write(obj.difficulty)
      ..writeByte(5)
      ..write(obj.satisfaction)
      ..writeByte(6)
      ..write(obj.genre)
      ..writeByte(7)
      ..write(obj.region);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EscapeRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
