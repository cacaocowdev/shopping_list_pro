import 'dart:async';

import 'package:optional/optional.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shopping_list_pro/events/EventBroker.dart';
import 'package:shopping_list_pro/events/PersistenceEvents.dart';
import 'package:shopping_list_pro/model/model.dart';
import 'package:shopping_list_pro/persistence/shopping_list_repository.dart';
import 'package:shopping_list_pro/persistence/impl/AppDatabase.dart';
import 'sqlite_crud_repository.dart';

class SqliteShoppingListRepository extends SqliteCrudRepository<int, ShoppingList>
    implements ShoppingListRepository {

  AppDatabase _dbInstance;

  SqliteShoppingListRepository(EventBroker broker)
      : super(broker, PersistenceEvent.DELETE_SHOPPING_LIST) {
    broker.registerHandler(PersistenceEvent.DELETE_ITEM, this.deleteItemEvent);
  }

  @override
  Future<void> clear() {
    return getDatabase().then((db) => db.delete(ShoppingListItem.TABLE_NAME))
        .then((_) => super.clear());
  }

  Future<void> deleteItemEvent(dynamic id) {
    assert(id is int);
    return getDatabase()
        .then((db) => db.delete(ShoppingListItem.TABLE_NAME,
        where: '${Item.COLUMN_ID} = ?',
        whereArgs: [id]
    ));
  }

  @override
  Future<Optional<ShoppingList>> setItem(ShoppingList shoppingList, Item item, int count, {isInCart: false}) {
    return getDatabase()
        .then((db) {
      var batch = db.batch();
      batch.update(
          ShoppingListItem.TABLE_NAME,
          toPair(shoppingList, item, count, isInCart: isInCart),
          where: '${ShoppingList.COLUMN_ID} = ? AND ${Item.COLUMN_ID} = ?',
          whereArgs: [shoppingList.id, item.id],
      );
      batch.execute('''
        INSERT INTO ${ShoppingListItem.TABLE_NAME}(
          ${ShoppingList.COLUMN_ID},
          ${Item.COLUMN_ID}, 
          ${ShoppingListItem.COLUMN_ITEM_COUNT},
          ${ShoppingListItem.COLUMN_ITEM_IS_IN_CART})
          SELECT ?,?,?,? WHERE (SELECT Changes() = 0)
          ''',
          [shoppingList.id, item.id, count, isInCart]);
      batch.commit();
    })
        .then((id) => Optional.ofNullable(id))
        .then((optional) => optional.map((_) => shoppingList));
  }

  @override
  Future<Optional<ShoppingList>> deleteItem(ShoppingList shoppingList, Item item) {
    return getDatabase()
        .then((db) => db.delete(ShoppingListItem.TABLE_NAME,
        where: '${ShoppingList.COLUMN_ID} = ? AND ${Item.COLUMN_ID} = ?',
        whereArgs: [shoppingList.id, item.id]
    ))
        .then((id) => Optional.ofNullable(id))
        .then((optional) => optional.map((_) => shoppingList));
  }

  @override
  Future<Optional<List<ShoppingListItem>>> listItems(ShoppingList shoppingList) =>
    getDatabase().then((db) =>
        db.rawQuery('''
            SELECT * FROM ${ShoppingListItem.TABLE_NAME} as list 
            INNER JOIN ${Item.TABLE_NAME} as items
            ON list.${Item.COLUMN_ID} = items.${Item.COLUMN_ID}
            WHERE list.${ShoppingList.COLUMN_ID} = ?
            ''', [shoppingList.id]))
        .then((records) => Optional.ofNullable(records))
        .then((optional) => optional.map((records) => records.map((item) => ShoppingListItem.fromMap(item)).toList()));

  @override
  Future<Optional<ShoppingListItem>> setInCart(ShoppingListItem item, bool isInCart) =>
    getDatabase().then((db) =>
        db.update(
            ShoppingListItem.TABLE_NAME,
            {'''${ShoppingListItem.COLUMN_ITEM_IS_IN_CART}''': isInCart},
            where: '''${ShoppingList.COLUMN_ID} = ? AND ${Item.COLUMN_ID} = ?''',
            whereArgs: [item.listId, item.itemId]))
    .then((id) => Optional.ofNullable(id).map((_) => ShoppingListItem(itemId: id)));

  Map<String, dynamic> toPair(ShoppingList list, Item item, int count, {bool isInCart = false}) => {
    ShoppingList.COLUMN_ID: list.id,
    Item.COLUMN_ID: item.id,
    ShoppingListItem.COLUMN_ITEM_COUNT: count,
    ShoppingListItem.COLUMN_ITEM_IS_IN_CART: isInCart,
  };

  @override
  get tableName => ShoppingList.TABLE_NAME;

  @override
  get idColumn => ShoppingList.COLUMN_ID;

  @override
  ShoppingList fromMap(Map<String, dynamic> map) => ShoppingList.fromMap(map);

  Future<Database> getDatabase() {
    if (_dbInstance == null) {
      _dbInstance = AppDatabase();
    }
    return _dbInstance.getDatabase();
  }
}