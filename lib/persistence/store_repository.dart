import 'dart:async';

import 'package:shopping_list_pro/model/model.dart';

import 'crud_repository.dart';

abstract class StoreRepository extends CrudRepository<int, Store> {
  Future<List<StoreItem>> stores(Item item);

  Future<void> addItemToStore(Store store, Item item, {int price});

  Future<void> clearItem(Item item);

  Future<void> removeItemFromStore(Store store, Item item);

  Future<Map<int, int>> priceInStore(Store store);
}