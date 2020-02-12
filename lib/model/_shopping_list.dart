import 'package:shopping_list_pro/model/model.dart';
import 'package:shopping_list_pro/util/Mappable.dart';

class ShoppingList extends Mappable {
  static const TABLE_NAME = 'ShoppingList';
  static const COLUMN_ID = 'list_id';
  static const COLUMN_NAME = 'list_name';

  int id;
  String name;
  List<Item> items;

  ShoppingList({this.id, this.name, this.items});

  Map<String, Object> toMap() => {
        COLUMN_ID: id,
        COLUMN_NAME: name,
      };

  ShoppingList.fromMap(Map<String, dynamic> map) {
    assert(map.containsKey(COLUMN_ID));
    assert(map.containsKey(COLUMN_NAME));
    this.id = map[COLUMN_ID];
    this.name = map[COLUMN_NAME];
  }

  ShoppingList.id(this.id, {this.name, this.items});
}

class ShoppingListMetadata {
  static const COLUMN_COUNT = "item_count";
  static const COLUMN_OPEN_COUNT = "open_item_count";

  int id;
  String name;
  int itemCount;
  int openItemCount;

  ShoppingListMetadata.fromMap(Map<String, dynamic> map) {
    assert(map.containsKey(ShoppingList.COLUMN_ID));
    assert(map.containsKey(ShoppingList.COLUMN_NAME));
    assert(map.containsKey(COLUMN_COUNT));
    assert(map.containsKey(COLUMN_OPEN_COUNT));
    this.id = map[ShoppingList.COLUMN_ID];
    this.name = map[ShoppingList.COLUMN_NAME];
    this.itemCount = map[COLUMN_COUNT];
    this.openItemCount = map[COLUMN_OPEN_COUNT];
  }
}
