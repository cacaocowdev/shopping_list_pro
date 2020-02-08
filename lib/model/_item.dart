import 'package:shopping_list_pro/util/Mappable.dart';

class Item extends Mappable {

  static const TABLE_NAME = 'Item';
  static const COLUMN_ID = 'item_id';
  static const COLUMN_NAME = 'item_name';

  int id;
  String name;

  Item({
    this.id,
    this.name
  });

  Map<String, Object> toMap() => {
    COLUMN_ID: id,
    COLUMN_NAME: name,
  };

  factory Item.fromMap(Map<String, dynamic> map) {
    assert(map.containsKey(COLUMN_ID));
    assert(map.containsKey(COLUMN_NAME));
    return Item(id: map[COLUMN_ID], name: map[COLUMN_NAME]);
  }

  Item.id(
      this.id,
      {
        this.name,
      });
}