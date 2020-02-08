import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:shopping_list_pro/events/EventBroker.dart';
import 'package:shopping_list_pro/events/PersistenceEvents.dart';
import 'package:shopping_list_pro/model/model.dart';
import 'package:shopping_list_pro/persistence/item_repository.dart';
import 'package:shopping_list_pro/persistence/impl/AppDatabase.dart';
import 'sqlite_crud_repository.dart';

class SqliteItemRepository extends SqliteCrudRepository<int, Item>
    implements ItemRepository {

  AppDatabase _dbInstance;

  SqliteItemRepository(EventBroker broker)
      : super(broker, PersistenceEvent.DELETE_ITEM);

  @override
  Future<Database> getDatabase() {
    if (_dbInstance == null) {
      _dbInstance = AppDatabase();
    }
    return _dbInstance.getDatabase();
  }

  @override
  get tableName => Item.TABLE_NAME;

  @override
  get idColumn => Item.COLUMN_ID;

  @override
  Item fromMap(Map<String, dynamic> map) {
    return Item.fromMap(map);
  }
}