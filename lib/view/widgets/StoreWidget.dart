import 'package:flutter/material.dart';
import 'package:shopping_list_pro/view/widgets/InputDialog.dart';
import 'package:shopping_list_pro/view/widgets/DefaultScaffold.dart';
import 'package:shopping_list_pro/persistence/store_repository.dart';
import 'package:shopping_list_pro/model/model.dart';

class StoreWidget extends StatefulWidget {
  final StoreRepository storeRepository;

  StoreWidget(this.storeRepository);

  @override
  State<StatefulWidget> createState() => _StoreState(storeRepository);
}

class _StoreState extends State<StoreWidget> {
  final StoreRepository _storeRepository;

  List<Store> _stores = [];

  _StoreState(this._storeRepository);

  @override
  void initState() {
    super.initState();
    _getStores();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultScaffold.build(
      body: ListView.builder(
          itemCount: _stores.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(_stores[index].name),
            onTap: () => Navigator.pushNamed(context, '/store', arguments: _stores[index]).then((val) {if (val is bool && !val) _getStores();}),
          )
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => showDialog(
            context: context,
            builder: (ctx) => InputDialog(
              title: 'Store',
            ),
          ).then((val) {
            if (val != null && val is String)
              _storeRepository.create(Store(name: val)).then((_) => _getStores());
          })),
    );
  }

  _getStores() {
    _storeRepository.listAll()
        .then((storeList) => this.setState(() => _stores = storeList));
  }
}