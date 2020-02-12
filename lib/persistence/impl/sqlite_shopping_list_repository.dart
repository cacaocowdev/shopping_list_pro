import 'dart:async';

import 'package:optional/optional.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shopping_list_pro/events/EventBroker.dart';
import 'package:shopping_list_pro/events/PersistenceEvents.dart';
import 'package:shopping_list_pro/model/model.dart';
import 'package:shopping_list_pro/persistence/shopping_list_repository.dart';
import 'package:shopping_list_pro/persistence/impl/AppDatabase.dart';
import 'sqlite_crud_repository.dart';

class SqliteShoppingListRepository
    extends SqliteCrudRepository<int, ShoppingList>
    implements ShoppingListRepository {
  AppDatabase _dbInstance;

  SqliteShoppingListRepository(EventBroker broker)
      : super(broker, PersistenceEvent.DELETE_SHOPPING_LIST) {
    broker.registerHandler(PersistenceEvent.DELETE_ITEM, this.deleteItemEvent);
  }

  @override
  Future<void> clear() {
    return getDatabase()
        .then((db) => db.delete(ShoppingListItem.TABLE_NAME))
        .then((_) => super.clear());
  }

  Future<void> deleteItemEvent(dynamic id) {
    assert(id is int);
    return getDatabase().then((db) => db.delete(ShoppingListItem.TABLE_NAME,
        where: '${Item.COLUMN_ID} = ?', whereArgs: [id]));
  }

  @override
  Future<Optional<ShoppingList>> setItem(
      ShoppingList shoppingList, Item item, int count,
      {isInCart: false}) {
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
          ''', [shoppingList.id, item.id, count, isInCart]);
          batch.commit();
        })
        .then((id) => Optional.ofNullable(id))
        .then((optional) => optional.map((_) => shoppingList));
  }

  @override
  Future<Optional<ShoppingList>> deleteItem(
      ShoppingList shoppingList, Item item) {
    return getDatabase()
        .then((db) => db.delete(ShoppingListItem.TABLE_NAME,
            where: '${ShoppingList.COLUMN_ID} = ? AND ${Item.COLUMN_ID} = ?',
            whereArgs: [shoppingList.id, item.id]))
        .then((id) => Optional.ofNullable(id))
        .then((optional) => optional.map((_) => shoppingList));
  }

  @override
  Future<Optional<List<ShoppingListItem>>> listItems(
          ShoppingList shoppingList) =>
      getDatabase()
          .then((db) => db.rawQuery('''
            SELECT * FROM ${ShoppingListItem.TABLE_NAME} as list 
            INNER JOIN ${Item.TABLE_NAME} as items
            ON list.${Item.COLUMN_ID} = items.${Item.COLUMN_ID}
            WHERE list.${ShoppingList.COLUMN_ID} = ?
            ''', [shoppingList.id]))
          .then((records) => Optional.ofNullable(records))
          .then((optional) => optional.map((records) =>
              records.map((item) => ShoppingListItem.fromMap(item)).toList()));

  @override
  Future<Optional<ShoppingListItem>> setInCart(
          ShoppingListItem item, bool isInCart) =>
      getDatabase()
          .then((db) => db.update(ShoppingListItem.TABLE_NAME,
              {'''${ShoppingListItem.COLUMN_ITEM_IS_IN_CART}''': isInCart},
              where:
                  '''${ShoppingList.COLUMN_ID} = ? AND ${Item.COLUMN_ID} = ?''',
              whereArgs: [item.listId, item.itemId]))
          .then((id) =>
              Optional.ofNullable(id).map((_) => ShoppingListItem(itemId: id)));

  @override
  Future<Optional<List<ShoppingListMetadata>>> getListMetadata(
          {int id, int limit}) => // TODO: regard arguments
      getDatabase()
          .then((db) => db.rawQuery('''
    SELECT
      s.${ShoppingList.COLUMN_ID},
      s.${ShoppingList.COLUMN_NAME},
      m.${ShoppingListMetadata.COLUMN_COUNT},
      o.${ShoppingListMetadata.COLUMN_OPEN_COUNT}
    FROM ${ShoppingList.TABLE_NAME} as s
    INNER JOIN (
      SELECT
        ${ShoppingList.COLUMN_ID},
        COUNT(${ShoppingListItem.COLUMN_ITEM_COUNT}) as ${ShoppingListMetadata.COLUMN_COUNT}
      FROM ${ShoppingListItem.TABLE_NAME}
      GROUP BY ${ShoppingList.COLUMN_ID}
    ) as m
    ON s.${ShoppingList.COLUMN_ID} = m.${ShoppingList.COLUMN_ID}
    INNER JOIN (
      SELECT
        ${ShoppingList.COLUMN_ID},
        COUNT(${ShoppingListItem.COLUMN_ITEM_COUNT}) as ${ShoppingListMetadata.COLUMN_OPEN_COUNT}
      FROM ${ShoppingListItem.TABLE_NAME}
      WHERE ${ShoppingListItem.COLUMN_ITEM_IS_IN_CART} = 0
      GROUP BY ${ShoppingList.COLUMN_ID}
    ) as o
    ON s.${ShoppingList.COLUMN_ID} = o.${ShoppingList.COLUMN_ID}
    LIMIT 5
    '''))
          .then((rows) => Optional.ofNullable(rows))
          .then((optional) => optional.map((e) =>
              e.map((row) => ShoppingListMetadata.fromMap(row)).toList()));

  Map<String, dynamic> toPair(ShoppingList list, Item item, int count,
          {bool isInCart = false}) =>
      {
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
