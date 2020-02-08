import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shopping_list_pro/model/model.dart';

class AppDatabase {
  static const _DATABASE_FILE = '/shopping_list_pro.db';
  static const _VERSION = 1;

  Database _dbInstance;

  Future<Database> getDatabase() async {
    if (_dbInstance == null) {
      Sqflite.devSetDebugModeOn(true);
      final path = await getDatabasesPath()
          .then((dir) => dir + _DATABASE_FILE);
      _dbInstance = await openDatabase(
        path,
        version: _VERSION,
        onCreate: (db, version) async {
          var batch = db.batch();
          batch.execute('''
            CREATE TABLE ${ShoppingList.TABLE_NAME} (
              ${ShoppingList.COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
              ${ShoppingList.COLUMN_NAME} TEXT
            );
          ''');
          batch.execute('''CREATE TABLE ${ShoppingListItem.TABLE_NAME} (
              ${ShoppingList.COLUMN_ID} INTEGER,
              ${Item.COLUMN_ID} INTEGER,
              ${ShoppingListItem.COLUMN_ITEM_COUNT} INTEGER,
              ${ShoppingListItem.COLUMN_ITEM_IS_IN_CART} BOOLEAN,
              UNIQUE(${ShoppingList.COLUMN_ID}, ${Item.COLUMN_ID})
            );
          ''');
          batch.execute('''CREATE TABLE ${Item.TABLE_NAME} (
              ${Item.COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
              ${Item.COLUMN_NAME} TEXT
            );
          ''');
          batch.execute('''CREATE TABLE ${Store.TABLE_NAME} (
              ${Store.COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
              ${Store.COLUMN_NAME} TEXT
            );
          ''');
          batch.execute('''CREATE TABLE ${StoreItem.TABLE_NAME} (
              ${Store.COLUMN_ID} INTEGER,
              ${Item.COLUMN_ID} INETEGER,
              ${StoreItem.COLUMN_ITEM_PRICE} INTEGER,
              UNIQUE(${Store.COLUMN_ID}, ${Item.COLUMN_ID})
            );
          ''');
          await batch.commit();
        },
      );
    }
    return _dbInstance;
  }
}