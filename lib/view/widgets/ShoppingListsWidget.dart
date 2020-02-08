import 'package:flutter/material.dart';
import 'package:shopping_list_pro/view/widgets/DefaultScaffold.dart';
import 'package:shopping_list_pro/model/model.dart';
import 'package:shopping_list_pro/persistence/shopping_list_repository.dart';

class ShoppingListsWidget extends StatefulWidget {

  final ShoppingListRepository repo;

  ShoppingListsWidget(
      this.repo,
      );

  @override
  State<StatefulWidget> createState() => _ShoppingListsState(repo);
}

class _ShoppingListsState extends State<ShoppingListsWidget> with WidgetsBindingObserver {

  final ShoppingListRepository repo;
  List<ShoppingList> shoppingLists = [];

  _ShoppingListsState(
      this.repo
      );

  @override
  void initState() {
    super.initState();
    _refreshLists();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultScaffold.build(
      body: ListView.builder(
          itemCount: this.shoppingLists.length,
          itemBuilder: (context, id) =>
              _listItem(context,
                  this.shoppingLists[id])
      ),
      floatingActionButton: Builder(
          builder: (ctx) =>
              FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () => Navigator.pushNamed(context, '/new-list')
                    .then((list) {
                  if (list != null) {
                    repo.create(list)
                        .then((_) => _refreshLists());
                    Scaffold.of(ctx)
                        .showSnackBar(SnackBar(content: Text('Create list')));
                  }
                }),
              )),
    );
  }

  Widget _listItem(BuildContext context, ShoppingList list) {
    return Dismissible(
      key: Key(list.name+list.id.toString()),
      onDismissed: (_) {
        repo.delete(list.id).then((_) => _refreshLists());
        Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted list'),
            )
        );
      },
      child: ListTile(
        onTap: () => Navigator.pushNamed(context, '/view-list', arguments: list)
            .then((_) => _refreshLists()),
        title: Text(list.name),
      ),
    );
  }

  void _refreshLists() {
    repo.listAll().then((list) => this.setState(() => this.shoppingLists = list));
  }
}