import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_customers/models/menu_item.dart';

class FavoriteMenuItemListNotifier extends StateNotifier<List<MenuItem>> {
  FavoriteMenuItemListNotifier() : super([]);

  void update(List<MenuItem> menuItemList) {
    state = menuItemList;
  }
}

final favoriteMenuItemListProvider =
    StateNotifierProvider<FavoriteMenuItemListNotifier, List<MenuItem>>(
  (ref) => FavoriteMenuItemListNotifier(),
);
