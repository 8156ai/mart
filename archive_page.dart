import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/client.dart';
import '../providers/client_provider.dart';
import 'add_room_dialog.dart';
import '../../../../shared/services/invoice_generator.dart';
import '../../../../shared/services/technical_task_generator.dart';

class ArchivePage extends ConsumerStatefulWidget {
  const ArchivePage({super.key});

  @override
  ConsumerState<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends ConsumerState<ArchivePage> {
  String _searchQuery = '';
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final allClients = ref.watch(clientNotifierProvider);

    final filtered = allClients.where((c) {
      final matchSearch = _searchQuery.isEmpty ||
          c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.phone.contains(_searchQuery);

      if (!matchSearch) return false;
      if (_filter == 'work') return c.status == 'work';
      if (_filter == 'done') return c.status == 'done';
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('АРХИВ КЛИЕНТОВ'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Поиск клиента',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterButton('Все', 'all'),
                const SizedBox(width: 8),
                _buildFilterButton('В работе', 'work'),
                const SizedBox(width: 8),
                _buildFilterButton('Закрыты', 'done'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Найдено: ${filtered.length}', style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty ? 'Нет клиентов' : 'Не найдено',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final client = filtered[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: client.status == 'work' ? Colors.orange : Colors.green,
                            child: Text(client.name[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              '${client.phone} • ${client.rooms.length} комнат • Доход: ${client.totalProfit.toStringAsFixed(0)} руб'),
                          trailing: PopupMenuButton(
                            itemBuilder: (ctx) => [
                              PopupMenuItem(
                                child: const Text('Статус'),
                                onTap: () => _changeStatus(client),
                              ),
                              PopupMenuItem(
                                child: const Text('Удалить'),
                                onTap: () => _deleteClient(client),
                              ),
                            ],
                          ),
                          onTap: () => _showDetails(client),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String value) {
    final isActive = _filter == value;
    return Expanded(
      child: FilterChip(
        label: Text(label),
        selected: isActive,
        onSelected: (selected) => setState(() => _filter = value),
        backgroundColor: Colors.grey.shade200,
        selectedColor: const Color(0xFF8B2346),
        labelStyle: TextStyle(
          color: isActive ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _changeStatus(Client client) {
    final newStatus = client.status == 'work' ? 'done' : 'work';
    final updated = client.copyWith(status: newStatus, updatedAt: DateTime.now());
    ref.read(clientNotifierProvider.notifier).updateClient(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Статус: ${newStatus == 'work' ? 'В работе' : 'Закрыт'}'),
        backgroundColor: newStatus == 'work' ? Colors.orange : Colors.green,
      ),
    );
  }

  void _deleteClient(Client client) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить клиента?'),
        content: Text('Будут удалены все данные о ${client.name}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              ref.read(clientNotifierProvider.notifier).deleteClient(client.id);
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDetails(Client client) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => ClientDetailsSheet(client: client),
    );
  }
}

class ClientDetailsSheet extends ConsumerWidget {
  final Client client;

  const ClientDetailsSheet({required this.client});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      builder: (ctx, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text(client.phone, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: client.status == 'work' ? Colors.orange.shade100 : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      client.status == 'work' ? 'В работе' : 'Закрыт',
                      style: TextStyle(
                        color: client.status == 'work' ? Colors.orange.shade800 : Colors.green.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                color: const Color(0xFF8B2346).withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildRow('Общий доход', client.totalIncome, Colors.green),
                      _buildRow('Общие расходы', client.totalCost, Colors.orange),
                      const Divider(),
                      _buildRow('ПРИБЫЛЬ', client.totalProfit,
                          client.totalProfit >= 0 ? Colors.green : Colors.red,
                          isBold: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Комнаты', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ElevatedButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => AddRoomDialog(client: client),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Добавить'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (client.rooms.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Нет комнат', style: TextStyle(color: Colors.grey.shade600)),
                  ),
                )
              else
                for (var room in client.rooms)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      title: Text(room.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${room.fabricMeters.toStringAsFixed(2)} м х ${room.clientPrice.toStringAsFixed(0)} руб'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildRoomRow('Ткань', '${room.fabricMeters.toStringAsFixed(2)} м'),
                              _buildRoomRow('Пошив швеи', '${room.sewingCostSeamstress.toStringAsFixed(0)} руб'),
                              _buildRoomRow('Мой пошив', '${room.sewingCostMy.toStringAsFixed(0)} руб'),
                              _buildRoomRow('Клиент платит', '${room.clientPrice.toStringAsFixed(0)} руб', Colors.green),
                              _buildRoomRow('Себестоимость', '${room.totalCost.toStringAsFixed(0)} руб', Colors.orange),
                              _buildRoomRow('ДОХОД', '${room.profit.toStringAsFixed(0)} руб',
                                  room.profit >= 0 ? Colors.green : Colors.red),
                              _buildRoomRow('Окон', '${(room.technicalSpecs['windows'] ?? 1).toString()} шт'),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  // ✅ КНОПКА ТЕХЗАДАНИЯ
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        TechnicalTaskGenerator.generate(
                                          context: context,
                                          roomName: room.name,
                                          cornice: room.technicalSpecs['cornice'] ?? 0,
                                          height: room.technicalSpecs['height'] ?? 0,
                                          coef: room.technicalSpecs['coef'] ?? 2,
                                          topHem: room.technicalSpecs['topHem'] ?? 0,
                                          bottomHem: room.technicalSpecs['bottomHem'] ?? 0,
                                          leftHem: room.technicalSpecs['leftHem'] ?? 0,
                                          rightHem: room.technicalSpecs['rightHem'] ?? 0,
                                          panels: (room.technicalSpecs['panels'] ?? 1).toInt(),
                                          fabricMeters: room.fabricMeters,
                                          sewingCostSeamstress: room.sewingCostSeamstress,
                                          options: room.technicalSpecs,
                                          techComment: room.cuttingInfo,
                                          isHandFold: room.technicalSpecs['isHandFold'] ?? false,
                                          isTape: room.technicalSpecs['isSeam'] ?? false,
                                        );
                                      },
                                      icon: const Icon(Icons.image),
                                      label: const Text('Техзадание'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        backgroundColor: Colors.orange,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // ✅ КНОПКА УДАЛЕНИЯ
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        ref
                                            .read(clientNotifierProvider.notifier)
                                            .removeRoom(client.id, room.id);
                                        Navigator.pop(context);
                                      },
                                      icon: const Icon(Icons.delete),
                                      label: const Text('Удалить'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        backgroundColor: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  final rooms = client.rooms
                      .map((r) => {
                            'name': r.name,
                            'fabricMeters': r.fabricMeters,
                            'clientPrice': r.clientPrice,
                          })
                      .toList();

                  InvoiceGenerator.generateClientInvoice(
                    context: context,
                    clientName: client.name,
                    clientPhone: client.phone,
                    rooms: rooms,
                    totalAmount: client.totalIncome,
                  );
                },
                icon: const Icon(Icons.receipt),
                label: const Text('СЧЕТ (PNG)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.purple,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(String label, double value, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text('${value.toStringAsFixed(0)} руб',
              style: TextStyle(fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildRoomRow(String label, String value, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}