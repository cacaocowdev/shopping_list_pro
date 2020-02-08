import 'model.dart';

class ShoppingListItem {

  static const TABLE_NAME = 'ShoppingListItem';
  static const COLUMN_ITEM_COUNT = 'item_count';
  static const COLUMN_ITEM_IS_IN_CART = 'item_is_in_cart';

  int listId;
  int itemId;
  String itemName;
  int itemCounter;
  bool isInCart;

  ShoppingListItem({
    this.listId,
    this.itemId,
    this.itemName,
    this.itemCounter
  });

  ShoppingListItem.fromMap(Map<String, dynamic> map) {
    assert(map.containsKey(ShoppingList.COLUMN_ID));
    assert(map.containsKey(Item.COLUMN_ID));
    assert(map.containsKey(Item.COLUMN_NAME));
    assert(map.containsKey(COLUMN_ITEM_COUNT));
    assert(map.containsKey(COLUMN_ITEM_IS_IN_CART));
    this.listId = map[ShoppingList.COLUMN_ID];
    this.itemId = map[Item.COLUMN_ID];
    this.itemName = map[Item.COLUMN_NAME];
    this.itemCounter = map[COLUMN_ITEM_COUNT];
    this.isInCart = map[COLUMN_ITEM_IS_IN_CART] == 1;
  }
}