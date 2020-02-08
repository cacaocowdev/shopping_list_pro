import 'package:flutter/material.dart';
import 'package:shopping_list_pro/model/ViewStoreModel.dart';
import 'package:shopping_list_pro/model/model.dart';
import 'package:shopping_list_pro/persistence/store_repository.dart';

class ViewStoreWidget extends StatefulWidget {

  final StoreRepository repo;

  ViewStoreWidget(this.repo);

  @override
  State<StatefulWidget> createState() => _ViewStoreState(repo);
}

class _ViewStoreState extends State<ViewStoreWidget> {

  final StoreRepository repo;

  _ViewStoreState(this.repo);

  final ViewStoreModel model = ViewStoreModel();

  List<VerboseStoreItem> vItems = [];

  Store store;

  @override
  Widget build(BuildContext context) {

    if (store == null) {
      store = ModalRoute.of(context).settings.arguments;
      _refresh(store.id);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Store'),
      ),
      body: ListView.builder(
        itemCount: vItems.length,
        itemBuilder: (context, i) => _buildItems(vItems[i]),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.delete_forever),
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Theme.of(context).colorScheme.onError,
        onPressed: () => repo.delete(store.id).then((_) => Navigator.pop(context, false)),
      ),
    );
  }

  Widget _buildItems(VerboseStoreItem item) {
    return ListTile(
      title: Text(item.name),
      trailing: Text(_fmt(item.price)),
      onTap: () => Navigator.pushNamed(context, '/edit-item',
          arguments: Item(id:  item.id, name: item.name)),
    );
  }

  String _fmt(int price) {
    var cents = price % 100;
    return '${(price / 100).floor()} ${(cents < 10 ? ',0':',')}$cents €';
  }

  _refresh(int store) {
    model.itemsOfStore(store).then((list) =>
        this.setState(() => this.vItems = list));
  }
}