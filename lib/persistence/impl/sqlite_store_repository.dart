import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:shopping_list_pro/events/EventBroker.dart';
import 'package:shopping_list_pro/events/PersistenceEvents.dart';
import 'package:shopping_list_pro/model/model.dart';
import 'package:shopping_list_pro/persistence/store_repository.dart';
import 'package:shopping_list_pro/persistence/impl/AppDatabase.dart';
import 'sqlite_crud_repository.dart';

class SqliteStoreRepository extends SqliteCrudRepository<int, Store>
    implements StoreRepository {

  AppDatabase _dbInstance;

  SqliteStoreRepository(EventBroker broker)
      : super(broker, PersistenceEvent.DELETE_STORE) {
    broker.registerHandler(PersistenceEvent.DELETE_ITEM, this.deleteItemEvent);
  }

  void deleteItemEvent(dynamic id) {
    assert(id is int);
    getDatabase().then((db) => db.delete(
        StoreItem.TABLE_NAME,
        where: '${Item.COLUMN_ID} = ?',
        whereArgs: [id]));
  }

  @override
  Future<void> delete(int id) =>
      getDatabase().then((db) => db.delete(
          StoreItem.TABLE_NAME,
          where: '${Store.COLUMN_ID} =  ?',
          whereArgs: [id]
      ).then((_) => super.delete(id)));
  
  @override
  Future<void> addItemToStore(Store shop, Item item, {int price}) =>
    getDatabase().then((db) => db.insert(
        StoreItem.TABLE_NAME,
        toMap(StoreItem(storeId: shop.id, itemId: item.id, price: price))));

  @override
  Future<List<StoreItem>> stores(Item item) =>
    getDatabase()
        .then((db) => db.rawQuery('''
          SELECT * FROM ${Store.TABLE_NAME} as shop
          INNER JOIN ${StoreItem.TABLE_NAME} as item on
          shop.${Store.COLUMN_ID} = item.${Store.COLUMN_ID}
          WHERE item.${Item.COLUMN_ID} = ?  
        ''', [item.id]))
        .then((records) => records.map((record) => StoreItem.fromMap(record)))
        .then((mapped) => mapped.toList());

  @override
  Future<void> clear() => getDatabase()
      .then((db) => db.delete(StoreItem.TABLE_NAME))
        .then((_) => super.clear());

  @override
  Future<void> clearItem(Item item) =>
      getDatabase().then((db) => db.delete(
          StoreItem.TABLE_NAME,
          where: '${Item.COLUMN_ID} = ?',
          whereArgs: [item.id],
      ));

  @override
  Future<void> removeItemFromStore(Store shop, Item item) =>
    getDatabase().then((db) => db.delete(
        StoreItem.TABLE_NAME,
        where: '${Store.COLUMN_ID} = ? AND ${Item.COLUMN_ID} = ?',
        whereArgs: [shop.id, item.id]),
    );

  @override
  Future<Map<int, int>> priceInStore(Store shop) =>
    getDatabase().then((db) =>
        db.query(
            StoreItem.TABLE_NAME,
            where: '${Store.COLUMN_ID} = ?',
            whereArgs: [shop.id]))
        .then((records) => records.map((item) =>
        MapEntry(item[Item.COLUMN_ID] as int, item[StoreItem.COLUMN_ITEM_PRICE] as int)).toList())
        .then((records) => Map.fromEntries(records));

  Map<String, dynamic> toMap(StoreItem item) =>
    {
      Store.COLUMN_ID: item.storeId,
      Item.COLUMN_ID: item.itemId,
      StoreItem.COLUMN_ITEM_PRICE: item.price,
    };

  Store fromMap(Map<String, dynamic> map) => Store.fromMap(map);

  get tableName => Store.TABLE_NAME;
  get idColumn => Store.COLUMN_ID;

  Future<Database> getDatabase() {
    if (_dbInstance == null) {
      _dbInstance = AppDatabase();
    }
    return _dbInstance.getDatabase();
  }
}