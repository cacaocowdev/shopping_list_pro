import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:shopping_list_pro/persistence/item_repository.dart';
import 'package:shopping_list_pro/persistence/shopping_list_repository.dart';
import 'package:shopping_list_pro/persistence/store_repository.dart';
import 'package:shopping_list_pro/persistence/impl/sqlite_item_repository.dart';
import 'package:shopping_list_pro/persistence/impl/sqlite_shopping_list_repository.dart';
import 'package:shopping_list_pro/persistence/impl/sqlite_store_repository.dart';
import 'package:shopping_list_pro/view/widgets/ItemListWidget.dart';
import 'package:shopping_list_pro/view/widgets/NewItemWidget.dart';
import 'package:shopping_list_pro/view/widgets/HomeWidget.dart';
import 'package:shopping_list_pro/view/widgets/ShoppingListsWidget.dart';
import 'package:shopping_list_pro/view/widgets/NewShoppingListWidget.dart';
import 'package:shopping_list_pro/view/widgets/ViewShoppingListWidget.dart';
import 'package:shopping_list_pro/view/widgets/SelectItemsWidget.dart';
import 'package:shopping_list_pro/view/widgets/StoreWidget.dart';
import 'package:shopping_list_pro/events/EventBroker.dart';
import 'package:shopping_list_pro/view/widgets/ViewStoreWidget.dart';

void main() {
  setUpDependencies();
  runApp(ShoppingListPro(Injector.getInjector()));
}

/// Registers all interdependencies with the dependency injector.
void setUpDependencies() {
  final injector = Injector.getInjector();
  injector.map((i) => EventBroker(), isSingleton: true);
  injector.map<ShoppingListRepository>((i) => SqliteShoppingListRepository(i.get()), isSingleton: true);
  injector.map<ItemRepository>((i) => SqliteItemRepository(i.get()), isSingleton: true);
  injector.map<StoreRepository>((i) => SqliteStoreRepository(i.get()), isSingleton: true);
}

class ShoppingListPro extends StatelessWidget {
  // This widget is the root of your application.

  final Injector injector;

  ShoppingListPro(this.injector);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping List Pro',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.teal,
      ),

      routes: {
        '/': (context) => HomeWidget(injector.get()),
        '/items': (context) => ItemListWidget(injector.get()),
        '/create-item': (context) => NewItemWidget(injector.get(), injector.get(), false),
        '/edit-item': (context) => NewItemWidget(injector.get(), injector.get(), true),
        '/add-items': (context) => SelectItemsWidget(injector.get()),
        '/lists': (context) => ShoppingListsWidget(injector.get()),
        '/new-list': (context) => NewShoppingListWidget(),
        '/view-list': (context) => ViewShoppingListWidget(injector.get(), injector.get()),
        '/stores': (context) =>  StoreWidget(injector.get()),
        '/store': (context) => ViewStoreWidget(injector.get()),
      },
    );
  }
}