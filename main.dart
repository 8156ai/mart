import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/clients/data/models/client_model.dart';
import 'features/clients/data/models/room_model.dart';
import 'features/pricing/data/pricing_repository.dart';
import 'features/clients/presentation/screens/project_page.dart';

late Box<ClientModel> clientsBox;
late Box pricesBox;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(RoomModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ClientModelAdapter());
    }

    clientsBox = await Hive.openBox<ClientModel>('clients_box');
    pricesBox = await Hive.openBox('prices_box');

    final pricingRepo = PricingRepository(pricesBox);
    pricingRepo.loadPrices();

    print("✅ HIVE & PRICING ИНИЦИАЛИЗИРОВАНЫ");

  } catch (e) {
    print("❌ ERROR: $e");
  }

  runApp(const CurtainApp());
}

class CurtainApp extends StatelessWidget {
  const CurtainApp({super.key});

  @override
  Widget build(BuildContext context) => ProviderScope(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'МАРТ ПРО 8',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B2346),
          primary: const Color(0xFF8B2346),
          secondary: const Color(0xFFA52A5A),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF8B2346),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B2346),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const ProjectPage(),
    ),
  );
}