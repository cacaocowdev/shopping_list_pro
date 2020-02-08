import 'package:optional/optional.dart';
import 'package:shopping_list_pro/util/Mappable.dart';

abstract class CrudRepository<T, U extends Mappable> {
  Future<void> clear();

  Future<int> create(U value);

  Future<List<U>> listAll();

  Future<Optional<U>> get(T id);

  Future<void> delete(T id);

  Future<void> update(T id, U val);
}