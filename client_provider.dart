import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/room.dart';
import '../../data/repositories/client_repository.dart';

final activeClientsProvider = Provider<List<Client>>((ref) {
  final repo = ref.watch(clientRepositoryProvider);
  return repo.getActiveClients();
});

final archivedClientsProvider = Provider<List<Client>>((ref) {
  final repo = ref.watch(clientRepositoryProvider);
  return repo.getArchivedClients();
});

class ClientNotifier extends StateNotifier<List<Client>> {
  final ClientRepository _repository;

  ClientNotifier(this._repository) : super([]);

  void load() {
    state = _repository.getActiveClients();
  }

  void addClient(Client client) {
    _repository.upsertClient(client);
    state = _repository.getActiveClients();
  }

  void updateClient(Client client) {
    _repository.upsertClient(client);
    state = _repository.getActiveClients();
  }

  void deleteClient(String id) {
    _repository.deleteClient(id);
    state = _repository.getActiveClients();
  }

  void archiveClient(String id) {
    _repository.archiveClient(id);
    state = _repository.getActiveClients();
  }

  void unarchiveClient(String id) {
    _repository.unarchiveClient(id);
    state = _repository.getActiveClients();
  }

  void addRoom(String clientId, Room room) {
    _repository.addRoom(clientId, room);
    state = _repository.getActiveClients();
  }

  void removeRoom(String clientId, String roomId) {
    _repository.removeRoom(clientId, roomId);
    state = _repository.getActiveClients();
  }
}

final clientNotifierProvider = StateNotifierProvider<ClientNotifier, List<Client>>((ref) {
  final repo = ref.watch(clientRepositoryProvider);
  final notifier = ClientNotifier(repo);
  notifier.load();
  return notifier;
});