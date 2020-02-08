import 'model.dart';

class StoreItem {

  static const TABLE_NAME = 'ShopItem';
  static const COLUMN_ITEM_PRICE = 'item_price';

  int storeId;
  int itemId;
  int price;

  StoreItem({
    this.storeId,
    this.itemId,
    this.price,
  });

  StoreItem.fromMap(Map<String, dynamic> map) {
    assert(map.containsKey(Store.COLUMN_ID));
    assert(map.containsKey(Item.COLUMN_ID));
    assert(map.containsKey(COLUMN_ITEM_PRICE));
    this.storeId = map[Store.COLUMN_ID];
    this.itemId = map[Item.COLUMN_ID];
    this.price = map[COLUMN_ITEM_PRICE];
  }
}