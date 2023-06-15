import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_customers/models/merchant.dart';

class FavoriteMerchantsListNotifier extends StateNotifier<List<Merchant>> {
  FavoriteMerchantsListNotifier() : super([]);

  void update(List<Merchant> merchantList) {
    state = merchantList;
  }
}

final favoriteMerchantListProvider =
    StateNotifierProvider<FavoriteMerchantsListNotifier, List<Merchant>>(
  (ref) => FavoriteMerchantsListNotifier(),
);
