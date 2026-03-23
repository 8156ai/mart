import 'package:hive_flutter/hive_flutter.dart';
import '../../features/clients/data/models/client_model.dart';

class AppBoxes {
  static Box<ClientModel> get clients => Hive.box<ClientModel>('clients_box');
  static Box get prices => Hive.box('prices_box');
}