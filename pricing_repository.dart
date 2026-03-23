import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/hive/boxes.dart';
import '../domain/seamstress_prices.dart';
import '../domain/my_prices.dart';

final pricingRepositoryProvider = Provider<PricingRepository>((ref) {
  return PricingRepository(AppBoxes.prices);
});

class PricingRepository {
  final Box _box;

  PricingRepository(this._box);

  void loadPrices() {
    // Загрузка цен для швеи
    if (_box.containsKey('seamstress')) {
      final saved = _box.get('seamstress') as Map;
      SeamstressPrices.fromMap(saved);
    }
    
    // Загрузка моих цен
    if (_box.containsKey('my')) {
      final saved = _box.get('my') as Map;
      MyPrices.fromMap(saved);
    }
  }

  void saveSeamstressPrices(Map<String, double> prices) {
    SeamstressPrices.fromMap(prices);
    _box.put('seamstress', prices);
  }

  void saveMyPrices(Map<String, double> prices) {
    MyPrices.fromMap(prices);
    _box.put('my', prices);
  }

  Map<String, double> getSeamstressPrices() => SeamstressPrices.toMap();
  Map<String, double> getMyPrices() => MyPrices.toMap();
}