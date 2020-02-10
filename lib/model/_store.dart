import 'package:shopping_list_pro/util/Mappable.dart';

class Store extends Mappable {

  static const TABLE_NAME = 'Store';
  static const COLUMN_ID = 'store_id';
  static const COLUMN_NAME = 'store_name';

  int id;
  String name;

  Store({
    this.id,
    this.name
  });

  Map<String, Object> toMap() => {
    COLUMN_ID: id,
    COLUMN_NAME: name,
  };

  factory Store.fromMap(Map<String, dynamic> map) {
    assert(map.containsKey(COLUMN_ID));
    assert(map.containsKey(COLUMN_NAME));
    return Store(id: map[COLUMN_ID], name: map[COLUMN_NAME]);
  }
}