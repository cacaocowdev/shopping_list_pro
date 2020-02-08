import 'package:shopping_list_pro/model/model.dart';
import 'package:shopping_list_pro/util/Mappable.dart';

class ShoppingList extends Mappable {

  static const TABLE_NAME = 'ShoppingList';
  static const COLUMN_ID = 'list_id';
  static const COLUMN_NAME = 'list_name';

  int id;
  String name;
  List<Item> items;

  ShoppingList({
    this.id,
    this.name,
    this.items
  });

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

  ShoppingList.id(
      this.id,
      {
        this.name,
        this.items
      }
      );
}