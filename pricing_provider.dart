import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../pricing/data/pricing_repository.dart';
import '../../../../core/hive/boxes.dart';
import '../../domain/seamstress_prices.dart';
import '../../domain/my_prices.dart';

final pricingRepositoryProvider = Provider<PricingRepository>((ref) {
  return PricingRepository(AppBoxes.prices);
});

// ✅ Цены для швеи (значения по умолчанию)
Map<String, double> _defaultSeamstressPrices = {
  // ============= ПОРТЬЕРЫ И ТЮЛЬ =============
  'curtainsBase': 350.0,        // Портьеры / Тюль до 3м (руб/м)
  'curtainsLining': 520.0,      // Портьеры на подкладе (руб/м)
  
  // ============= РИМСКИЕ ШТОРЫ =============
  'romanTape': 680.0,           // Римские шторы на ленте (руб/м²)
  'romanLining': 900.0,         // Римские шторы на подкладе (руб/м²)
  
  // ============= НАДБАВКИ =============
  'over3mPercent': 0.1,         // Надбавка за высоту более 3м (+10%)
  'complexFabricPercent': 0.2,  // Сложная ткань (+20%)
  'handFold': 130.0,            // Ручная складка (руб/м)
  'seam': 120.0,                // Стачной шов (руб)
  'lining': 520.0,              // Подклад (руб/м) - добавляется к портьерам
  
  // ============= КОЛЬЦА =============
  'romanRing': 20.0,            // Кольцо для римских штор (руб/шт)
};

// ✅ Ваши цены (значения по умолчанию)
Map<String, double> _defaultMyPrices = {
  // ============= ПОРТЬЕРЫ И ТЮЛЬ =============
  'curtainsBase': 1000.0,       // Портьеры / Тюль (руб/м) - ваша цена
  'curtainsLining': 1450.0,     // Портьеры на подкладе (руб/м) - ваша цена
  
  // ============= РИМСКИЕ ШТОРЫ =============
  'romanTape': 1320.0,          // Римские шторы на ленте (руб/м²) - ваша цена
  'romanLining': 1600.0,        // Римские шторы на подкладе (руб/м²) - ваша цена
  
  // ============= НАДБАВКИ =============
  'over3mPercent': 0.1,         // Надбавка за высоту более 3м (+10%)
  'complexFabricPercent': 0.2,  // Сложная ткань (+20%)
  'handFold': 1250.0,           // Ручная складка (руб/м) - ваша цена
  'seam': 280.0,                // Стачной шов (руб) - ваша цена
  'lining': 1450.0,             // Подклад (руб/м) - ваша цена
  
  // ============= КОЛЬЦА =============
  'romanRing': 20.0,            // Кольцо для римских штор (руб/шт) - ваша цена
};

final seamstressPricesProvider = Provider<Map<String, double>>((ref) {
  final repo = ref.watch(pricingRepositoryProvider);
  final prices = repo.getSeamstressPrices();
  
  // Если в хранилище нет данных, возвращаем значения по умолчанию
  if (prices.isEmpty) {
    return _defaultSeamstressPrices;
  }
  
  // Объединяем с дефолтными, чтобы новые ключи появились
  return {..._defaultSeamstressPrices, ...prices};
});

final myPricesProvider = Provider<Map<String, double>>((ref) {
  final repo = ref.watch(pricingRepositoryProvider);
  final prices = repo.getMyPrices();
  
  // Если в хранилище нет данных, возвращаем значения по умолчанию
  if (prices.isEmpty) {
    return _defaultMyPrices;
  }
  
  // Объединяем с дефолтными, чтобы новые ключи появились
  return {..._defaultMyPrices, ...prices};
});

class PricingNotifier extends StateNotifier<void> {
  final PricingRepository _repository;

  PricingNotifier(this._repository) : super(null);

  void load() => _repository.loadPrices();

  void updateSeamstressPrices(Map<String, double> prices) {
    _repository.saveSeamstressPrices(prices);
    state = null;
  }

  void updateMyPrices(Map<String, double> prices) {
    _repository.saveMyPrices(prices);
    state = null;
  }
}

final pricingNotifierProvider = StateNotifierProvider<PricingNotifier, void>((ref) {
  final repo = ref.watch(pricingRepositoryProvider);
  return PricingNotifier(repo)..load();
});