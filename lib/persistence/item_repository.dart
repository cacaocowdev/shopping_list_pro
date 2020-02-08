import 'package:shopping_list_pro/model/model.dart';

import 'package:shopping_list_pro/persistence/crud_repository.dart';

abstract class ItemRepository extends CrudRepository<int, Item> {
}