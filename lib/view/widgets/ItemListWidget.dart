import 'package:flutter/material.dart';
import 'package:shopping_list_pro/elements/AlphabeticalList.dart';
import 'package:shopping_list_pro/model/model.dart';
import 'package:shopping_list_pro/persistence/item_repository.dart';
import 'package:shopping_list_pro/view/widgets/DefaultScaffold.dart';

class ItemListWidget extends StatefulWidget {
  final ItemRepository repo;

  ItemListWidget(this.repo);

  @override
  _ItemListState createState() =>
      _ItemListState(this.repo);

}

class _ItemListState extends State<ItemListWidget> {
  List<Item> items = [];
  final ItemRepository repo;

  _ItemListState(
      this.repo
      );

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultScaffold.build(
      body: AlphabeticalList<Item>(
        items: this.items,
        extractor: (item) => item.name,
        itemBuilder: itemCard,
      ),
      floatingActionButton: Builder(
          builder: (ctx) => FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, '/create-item')
                .then((created) {
              if (created) {
                _refreshItems();
                Scaffold.of(ctx).showSnackBar(
                    SnackBar(content: Text("Created item")));
              }
            }),
            child: Icon(Icons.add),
          )),
    );
  }

  Widget itemCard(BuildContext context, Item item) {
    return Dismissible(
        key: Key(item.name + item.id.toString()),
        onDismissed: (direction) {
          if (item != null) {
            repo.delete(item.id).then((_) => _refreshItems());
            Scaffold.of(context).showSnackBar(SnackBar(content: Text('Deleted item')));
          }
        },
        child: ListTile(
          title: Text(item.name),
          onTap: () => Navigator.pushNamed(context, '/edit-item', arguments: item),
        )
    );
  }

  _refreshItems() {
    this.repo.listAll()
        .then((list) => setState(() => this.items = list));
  }
}