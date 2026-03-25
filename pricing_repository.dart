import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/hive/boxes.dart';
import '../domain/seamstress_prices.dart';
import '../domain/my_prices.dart';

class PricingRepository {
  final Box _box;

  PricingRepository(this._box);

  void loadPrices() {
    if (_box.containsKey('seamstress')) {
      final saved = _box.get('seamstress') as Map<String, dynamic>?;
      if (saved != null) {
        SeamstressPrices.fromMap(saved);
      }
    }
    
    if (_box.containsKey('my')) {
      final saved = _box.get('my') as Map<String, dynamic>?;
      if (saved != null) {
        MyPrices.fromMap(saved);
      }
    }
  }

  void saveSeamstressPrices(Map<String, double> prices) {
    SeamstressPrices.fromMap(prices.cast<String, dynamic>());
    _box.put('seamstress', prices);
  }

  void saveMyPrices(Map<String, double> prices) {
    MyPrices.fromMap(prices.cast<String, dynamic>());
    _box.put('my', prices);
  }

  Map<String, double> getSeamstressPrices() => SeamstressPrices.toMap();
  Map<String, double> getMyPrices() => MyPrices.toMap();
}