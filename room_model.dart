import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/room.dart';

part 'room_model.g.dart';

@HiveType(typeId: 0)
class RoomModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double fabricMeters;

  @HiveField(3)
  final double clientPrice;

  @HiveField(4)
  final double fabricCost;

  @HiveField(5)
  final double sewingCostSeamstress;

  @HiveField(6)
  final double sewingCostMy;

  @HiveField(7)
  final double profileCost;

  @HiveField(8)
  final double profileMarkup;

  @HiveField(9)
  final double totalCost;

  @HiveField(10)
  final String comment;

  @HiveField(11)
  final String contacts;

  @HiveField(12)
  final String cuttingInfo;

  @HiveField(13)
  final bool isCompleted;

  @HiveField(14)
  final Map<String, dynamic> technicalSpecs;

  @HiveField(15)
  final DateTime createdAt;

  @HiveField(16)
  final DateTime? clientDeadline;

  @HiveField(17)
  final DateTime? seamstressDeadline;

  RoomModel({
    required this.id,
    required this.name,
    required this.fabricMeters,
    required this.clientPrice,
    required this.fabricCost,
    required this.sewingCostSeamstress,
    required this.sewingCostMy,
    required this.profileCost,
    required this.profileMarkup,
    required this.totalCost,
    required this.comment,
    this.contacts = '',
    this.cuttingInfo = '',
    this.isCompleted = false,
    required this.technicalSpecs,
    required this.createdAt,
    this.clientDeadline,
    this.seamstressDeadline,
  });

  // 🔧 Конвертация: Entity → Model
  factory RoomModel.fromEntity(Room room) {
    return RoomModel(
      id: room.id,
      name: room.name,
      fabricMeters: room.fabricMeters,
      clientPrice: room.clientPrice,
      fabricCost: room.fabricCost,
      sewingCostSeamstress: room.sewingCostSeamstress,
      sewingCostMy: room.sewingCostMy,
      profileCost: room.profileCost,
      profileMarkup: room.profileMarkup,
      totalCost: room.totalCost,
      comment: room.comment,
      contacts: room.contacts,
      cuttingInfo: room.cuttingInfo,
      isCompleted: room.isCompleted,
      technicalSpecs: room.technicalSpecs,
      createdAt: room.createdAt,
      clientDeadline: room.clientDeadline,
      seamstressDeadline: room.seamstressDeadline,
    );
  }

  // 🔧 Конвертация: Model → Entity
  Room toEntity() {
    return Room(
      id: id,
      name: name,
      fabricMeters: fabricMeters,
      clientPrice: clientPrice,
      fabricCost: fabricCost,
      sewingCostSeamstress: sewingCostSeamstress,
      sewingCostMy: sewingCostMy,
      profileCost: profileCost,
      profileMarkup: profileMarkup,
      totalCost: totalCost,
      comment: comment,
      contacts: contacts,
      cuttingInfo: cuttingInfo,
      isCompleted: isCompleted,
      technicalSpecs: technicalSpecs,
      createdAt: createdAt,
      clientDeadline: clientDeadline,
      seamstressDeadline: seamstressDeadline,
    );
  }
}