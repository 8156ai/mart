import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../pricing/data/pricing_repository.dart';
import '../../../../core/hive/boxes.dart';
import '../../domain/seamstress_prices.dart';
import '../../domain/my_prices.dart';

final pricingRepositoryProvider = Provider<PricingRepository>((ref) {
  return PricingRepository(AppBoxes.prices);
});

final seamstressPricesProvider = Provider<Map<String, double>>((ref) {
  final repo = ref.watch(pricingRepositoryProvider);
  return repo.getSeamstressPrices();
});

final myPricesProvider = Provider<Map<String, double>>((ref) {
  final repo = ref.watch(pricingRepositoryProvider);
  return repo.getMyPrices();
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