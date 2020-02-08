import 'package:sqflite/sqflite.dart';
import 'package:optional/optional.dart';
import 'package:shopping_list_pro/util/Mappable.dart';
import 'package:shopping_list_pro/events/EventBroker.dart';

abstract class SqliteCrudRepository<T, U extends Mappable> {

  final EventBroker _broker;
  final String _deleteEvent;

  SqliteCrudRepository(this._broker, this._deleteEvent);

  Future<Database> getDatabase();

  Future<void> clear() =>
      getDatabase().then((db) => db.delete(tableName));

  Future<int> create(U value) =>
      getDatabase().then((db) => db.insert(tableName, value.toMap()))
      .then((id) => id);

  Future<List<U>> listAll() {
    return getDatabase().then((db) => db.query(tableName))
        .then((records) => records.map((value) => fromMap(value)))
        .then((ite) => ite.toList());
  }

  Future<Optional<U>> get(T id) {
    return getDatabase().then((db) => db.query(tableName,
        where: '$idColumn = ?', whereArgs: [id]))
        .then((records) => records.first)
        .then((item) => Optional.ofNullable(item))
        .then((opt) => opt.map((val) => fromMap(val)));
  }

  Future<void> delete(T id) =>
    getDatabase()
        .then((db) => db.delete(tableName, where: '$idColumn = ?', whereArgs: [id]))
        .then((changed) { if (changed > 0) _broker.triggerEvent(_deleteEvent, id);});

  Future<void> update(T id, U val) =>
    getDatabase().then((db) => db.update(tableName, val.toMap(),
        where: '$idColumn = ?', whereArgs: [id]));

  U fromMap(Map<String, dynamic> map);

  String get tableName;
  String get idColumn;
}