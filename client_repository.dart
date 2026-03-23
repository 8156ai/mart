import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/hive/boxes.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/room.dart';
import '../models/client_model.dart';
import '../models/room_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepository(AppBoxes.clients);
});

class ClientRepository {
  final Box<ClientModel> _box;

  ClientRepository(this._box);

  List<Client> getActiveClients() {
    return _box.values
        .where((c) => !c.isArchived)
        .map((c) => c.toEntity())
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Client> getArchivedClients() {
    return _box.values
        .where((c) => c.isArchived)
        .map((c) => c.toEntity())
        .toList()
      ..sort((a, b) => (b.updatedAt ?? b.createdAt).compareTo(a.updatedAt ?? a.createdAt));
  }

  List<Client> searchClients(String query) {
    final q = query.toLowerCase();
    return _box.values
        .where((c) => !c.isArchived)
        .where((c) => 
          c.name.toLowerCase().contains(q) || 
          c.phone.contains(q)
        )
        .map((c) => c.toEntity())
        .toList();
  }

  void upsertClient(Client client) {
    final model = ClientModel.fromEntity(client);
    _box.put(client.id, model);
  }

  void deleteClient(String id) {
    _box.delete(id);
  }

  void archiveClient(String id) {
    final model = _box.get(id);
    if (model != null) {
      model.isArchived = true;
      model.updatedAt = DateTime.now();
      model.save();
    }
  }

  void unarchiveClient(String id) {
    final model = _box.get(id);
    if (model != null) {
      model.isArchived = false;
      model.updatedAt = DateTime.now();
      model.save();
    }
  }

  void addRoom(String clientId, Room room) {
    final model = _box.get(clientId);
    if (model != null) {
      model.rooms.add(RoomModel.fromEntity(room));
      model.updatedAt = DateTime.now();
      model.save();
    }
  }

  void removeRoom(String clientId, String roomId) {
    final model = _box.get(clientId);
    if (model != null) {
      model.rooms.removeWhere((r) => r.id == roomId);
      model.updatedAt = DateTime.now();
      model.save();
    }
  }

  void updateRoom(String clientId, Room updatedRoom) {
    final model = _box.get(clientId);
    if (model != null) {
      final index = model.rooms.indexWhere((r) => r.id == updatedRoom.id);
      if (index != -1) {
        model.rooms[index] = RoomModel.fromEntity(updatedRoom);
        model.updatedAt = DateTime.now();
        model.save();
      }
    }
  }
}