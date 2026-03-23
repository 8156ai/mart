// 🔧 ДОБАВИТЬ ИМПОРТ В НАЧАЛО ФАЙЛА:
import 'room.dart';  // ✅ Импортируем Room

class Client {
  final String id;
  final String name;
  final String phone;
  final String status; // 'work' | 'done'
  final List<Room> rooms;  // ✅ Теперь Room известен
  final bool isArchived;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.status,
    required this.rooms,
    this.isArchived = false,
    required this.createdAt,
    this.updatedAt,
  });

  double get totalIncome => rooms.fold(0, (sum, r) => sum + r.clientPrice);
  double get totalCost => rooms.fold(0, (sum, r) => sum + r.totalCost);
  double get totalProfit => totalIncome - totalCost;

  Client copyWith({
    String? name,
    String? phone,
    String? status,
    List<Room>? rooms,
    bool? isArchived,
    DateTime? updatedAt,
  }) {
    return Client(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      rooms: rooms ?? this.rooms,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}