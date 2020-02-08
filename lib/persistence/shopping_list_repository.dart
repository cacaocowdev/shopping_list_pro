import 'dart:async';

import 'package:optional/optional.dart';
import 'package:shopping_list_pro/model/model.dart';

import 'crud_repository.dart';

abstract class ShoppingListRepository extends CrudRepository<int, ShoppingList> {
  Future<Optional<ShoppingList>> setItem(ShoppingList shoppingList, Item item, int count, {bool isInCart});

  Future<Optional<ShoppingList>> deleteItem(ShoppingList shoppingList, Item item);

  Future<Optional<List<ShoppingListItem>>> listItems(ShoppingList list);

  Future<Optional<ShoppingListItem>> setInCart(ShoppingListItem item, bool isInCart);
}