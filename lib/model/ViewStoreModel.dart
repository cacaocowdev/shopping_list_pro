import 'package:shopping_list_pro/persistence/impl/AppDatabase.dart';
import 'package:shopping_list_pro/model/model.dart';

class ViewStoreModel {

  static const String BEST_PRICE = 'best_price';
  static const String BEST_STORE = 'best_store';

  final AppDatabase db = AppDatabase();

  Future<List<VerboseStoreItem>> itemsOfStore(int id) {
    return db.getDatabase().then((db) => db.rawQuery(
        '''
        SELECT i.${Item.COLUMN_ID}, i.${Item.COLUMN_NAME}, s.${StoreItem.COLUMN_ITEM_PRICE}
        FROM ${Item.TABLE_NAME} i INNER JOIN ${StoreItem.TABLE_NAME} s
        ON i.${Item.COLUMN_ID} = s.${Item.COLUMN_ID}
        WHERE s.${Store.COLUMN_ID} = ?
        ''',
        [id]))
    .then((records) => records.map((record) =>
        VerboseStoreItem(record[Item.COLUMN_ID], record[Item.COLUMN_NAME],
            record[StoreItem.COLUMN_ITEM_PRICE]))
        .toList());
  }

  Future<int> calculateItemValue(ShoppingList list, Store store) {
    return db.getDatabase().then((db) => db.rawQuery('''
        SELECT SUM(p.${StoreItem.COLUMN_ITEM_PRICE} * l.${ShoppingListItem.COLUMN_ITEM_COUNT}) as sum FROM ${ShoppingListItem.TABLE_NAME} l
        INNER JOIN ${StoreItem.TABLE_NAME} p
        ON l.${Item.COLUMN_ID} = p.${Item.COLUMN_ID}
        WHERE l.${ShoppingList.COLUMN_ID} = ? AND p.${Store.COLUMN_ID} = ? AND l.${ShoppingListItem.COLUMN_ITEM_IS_IN_CART} == 1
    ''', [list.id, store.id]))
      .then((records) => records.first).then((value) => value['sum']?? 0);
  }

  Future<List<VerboseListItem>> listItems(ShoppingList shoppingList, {Store store}) {

    var query = '''
          SELECT * FROM ${ShoppingListItem.TABLE_NAME} l
          INNER JOIN ${Item.TABLE_NAME} i
          ON i.${Item.COLUMN_ID} = l.${Item.COLUMN_ID}
          WHERE l.${ShoppingList.COLUMN_ID} = ?
          ''';

    var arguments = [shoppingList.id];

    if (store != null && store.id >= 0) {
      query = '''
          SELECT
            i.${Item.COLUMN_ID},
            i.${Item.COLUMN_NAME},
            l.${ShoppingListItem.COLUMN_ITEM_COUNT},
            l.${ShoppingListItem.COLUMN_ITEM_IS_IN_CART},
            p.${StoreItem.COLUMN_ITEM_PRICE},
            p2.${StoreItem.COLUMN_ITEM_PRICE} as $BEST_PRICE,
            s.${Store.COLUMN_NAME} as $BEST_STORE 
          FROM ${ShoppingListItem.TABLE_NAME} l
          INNER JOIN ${Item.TABLE_NAME} i
          ON i.${Item.COLUMN_ID} = l.${Item.COLUMN_ID}
          INNER JOIN ${StoreItem.TABLE_NAME} p
          ON i.${Item.COLUMN_ID} = p.${Item.COLUMN_ID}
          INNER JOIN (
            SELECT i_i.${Item.COLUMN_ID} as ${Item.COLUMN_ID}, MIN(p_i.${StoreItem.COLUMN_ITEM_PRICE}) as $BEST_PRICE  FROM ${Item.TABLE_NAME} i_i
            INNER JOIN ${StoreItem.TABLE_NAME} p_i
            ON i_i.${Item.COLUMN_ID} = p_i.${Item.COLUMN_ID}
            GROUP BY p_i.${Item.COLUMN_ID}
            ) as e
          ON i.${Item.COLUMN_ID} = e.${Item.COLUMN_ID}
          INNER JOIN ${StoreItem.TABLE_NAME} p2
          ON p2.${StoreItem.COLUMN_ITEM_PRICE} = e.$BEST_PRICE
          INNER JOIN ${Store.TABLE_NAME} s
          ON p2.${Store.COLUMN_ID} = s.${Store.COLUMN_ID}
          WHERE l.${ShoppingList.COLUMN_ID} = ? -- change for other shopping list
          AND p.${Store.COLUMN_ID} = ? -- change for other shop
          GROUP BY i.${Item.COLUMN_ID}
      ''';
      arguments.add(store.id);
    }

    return db.getDatabase()
        .then((db) => db.rawQuery(query, arguments))
    .then((records) => records.map((record) => VerboseListItem(
        record[Item.COLUMN_ID], record[Item.COLUMN_NAME],
        record[StoreItem.COLUMN_ITEM_PRICE],
        record[ShoppingListItem.COLUMN_ITEM_COUNT],
        record[ShoppingListItem.COLUMN_ITEM_IS_IN_CART] != 0,
        bestPrice: record[BEST_PRICE],
        bestStore: record[BEST_STORE])).toList());
  }
}

class VerboseStoreItem {

  VerboseStoreItem(this.id, this.name, this.price);

  int id;
  String name;
  int price;
}

class VerboseListItem{

  VerboseListItem(this.id, this.name, this.price, this.count, this.isInCart, {this.bestPrice, this.bestStore});

  int id;
  String name;
  int price;
  int count;
  bool isInCart;
  int bestPrice;
  String bestStore;

  ShoppingListItem toShoppingListItem(ShoppingList list) {
    return ShoppingListItem(
      itemCounter: count,
      itemId: id,
      itemName: name,
      listId: list.id
    );
  }
}