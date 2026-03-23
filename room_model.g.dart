// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoomModelAdapter extends TypeAdapter<RoomModel> {
  @override
  final int typeId = 0;

  @override
  RoomModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoomModel(
      id: fields[0] as String,
      name: fields[1] as String,
      fabricMeters: fields[2] as double,
      clientPrice: fields[3] as double,
      fabricCost: fields[4] as double,
      sewingCostSeamstress: fields[5] as double,
      sewingCostMy: fields[6] as double,
      profileCost: fields[7] as double,
      profileMarkup: fields[8] as double,
      totalCost: fields[9] as double,
      comment: fields[10] as String,
      contacts: fields[11] as String,
      cuttingInfo: fields[12] as String,
      isCompleted: fields[13] as bool,
      technicalSpecs: (fields[14] as Map).cast<String, dynamic>(),
      createdAt: fields[15] as DateTime,
      clientDeadline: fields[16] as DateTime?,
      seamstressDeadline: fields[17] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, RoomModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.fabricMeters)
      ..writeByte(3)
      ..write(obj.clientPrice)
      ..writeByte(4)
      ..write(obj.fabricCost)
      ..writeByte(5)
      ..write(obj.sewingCostSeamstress)
      ..writeByte(6)
      ..write(obj.sewingCostMy)
      ..writeByte(7)
      ..write(obj.profileCost)
      ..writeByte(8)
      ..write(obj.profileMarkup)
      ..writeByte(9)
      ..write(obj.totalCost)
      ..writeByte(10)
      ..write(obj.comment)
      ..writeByte(11)
      ..write(obj.contacts)
      ..writeByte(12)
      ..write(obj.cuttingInfo)
      ..writeByte(13)
      ..write(obj.isCompleted)
      ..writeByte(14)
      ..write(obj.technicalSpecs)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.clientDeadline)
      ..writeByte(17)
      ..write(obj.seamstressDeadline);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
