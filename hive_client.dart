import 'package:hive_flutter/hive_flutter.dart';
import '../../features/clients/data/models/client_model.dart';
import '../../features/clients/data/models/room_model.dart';

class HiveClient {
  static const String clientsBox = 'clients_box';
  static const String pricesBox = 'prices_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // 🔧 Регистрация адаптеров
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(RoomModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ClientModelAdapter());
    }
    
    // 🔧 Открытие боксов
    await Hive.openBox<ClientModel>(clientsBox);
    await Hive.openBox(pricesBox);
  }

  static Box<ClientModel> get clients => Hive.box<ClientModel>(clientsBox);
  static Box get prices => Hive.box(pricesBox);
}