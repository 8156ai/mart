import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/client.dart';
import 'room_model.dart';

part 'client_model.g.dart';

@HiveType(typeId: 1)
class ClientModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String phone;

  @HiveField(3)
  late String status;

  @HiveField(4)
  late List<RoomModel> rooms;

  @HiveField(5)
  late bool isArchived;

  @HiveField(6)
  late DateTime createdAt;

  @HiveField(7)
  DateTime? updatedAt;

  ClientModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.status,
    required this.rooms,
    this.isArchived = false,
    required this.createdAt,
    this.updatedAt,
  });

  // 🔧 Entity → Model
  factory ClientModel.fromEntity(Client client) {
    return ClientModel(
      id: client.id,
      name: client.name,
      phone: client.phone,
      status: client.status,
      rooms: client.rooms.map(RoomModel.fromEntity).toList(),
      isArchived: client.isArchived,
      createdAt: client.createdAt,
      updatedAt: client.updatedAt,
    );
  }

  // 🔧 Model → Entity
  Client toEntity() {
    return Client(
      id: id,
      name: name,
      phone: phone,
      status: status,
      rooms: rooms.map((r) => r.toEntity()).toList(),
      isArchived: isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}