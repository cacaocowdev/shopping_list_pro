import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shopping_list_pro/model/model.dart';
import 'package:shopping_list_pro/persistence/store_repository.dart';
import 'package:shopping_list_pro/persistence/item_repository.dart';
import 'package:flutter/services.dart';

class NewItemWidget extends StatefulWidget {

  final ItemRepository _itemRepo;
  final StoreRepository _storeRepo;
  final bool _load;

  NewItemWidget(this._itemRepo, this._storeRepo, this._load);

  @override
  _NewItemState createState() => _NewItemState(_itemRepo, _storeRepo, _load);
}

class _NewItemState extends State<NewItemWidget> {

  final ItemRepository _itemRepo;
  final StoreRepository _storeRepo;
  final bool _load;

  Item _item;
  List<_MetaShopItem> selectedDropDowns = [new _MetaShopItem()];

  List<Store> stores = [];

  _NewItemState(this._itemRepo, this._storeRepo, this._load);

  @override
  void initState() {
    super.initState();
    _getShops();
  }

  @override
  Widget build(BuildContext context) {

    if (_load) {
      if (_item == null) {
        _item = ModalRoute.of(context).settings.arguments;
        selectedDropDowns.clear();
        _storeRepo.stores(_item).then((stores) =>
            stores.map((store) => new _MetaShopItem(
                store: this.stores.singleWhere((s) =>
                s.id == store.storeId),
                price: (store.price ~/ 100).toString() + ',' +
                    (store.price % 100).toString())
            ).toList()).then((list) => this.setState(() => this.selectedDropDowns = list));
      }
    }

    if (_item == null) {
      _item = new Item();
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Shopping List Pro'),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: buildForm(),
        ));
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Widget buildForm() {
    var formElements = <Widget>[
      TextFormField(
        decoration: InputDecoration(labelText: 'Name')
            .applyDefaults(Theme.of(context).inputDecorationTheme),
        validator: (value) => value.isEmpty ? 'Name missing' : null,
        onSaved: (value) => _item.name = value,
        initialValue: _item.name,
      )
    ];

    formElements.add(FlatButton.icon(
      icon: Icon(Icons.add),
      label: Text('Add Store'),
      onPressed: selectedDropDowns.length < stores.length ?
          () {
        GlobalKey<FormState>();
        this.formKey.currentState.save();
        this.setState(() => selectedDropDowns.insert(0, new _MetaShopItem()));
      } : null,
    ));

    formElements.addAll(ListTile.divideTiles(
      tiles: Iterable.generate(selectedDropDowns.length, (i) => _buildShopSelectorForm(context, i)),
      context: context,
    ));

    formElements.add(_bulidButtonBar(context));

    return Form(
      key: formKey,
      child: Flex(
        direction: Axis.vertical,
        children: formElements,
      ),
      autovalidate: true,
    );
  }

  Widget _bulidButtonBar(BuildContext context) => ButtonBar(
    children: <Widget>[
      RaisedButton(
        child: Text('Cancel'),
        onPressed: () => Navigator.pop(context, false),
      ),
      RaisedButton(
        child: Text('Save'),
        onPressed: () {
          if (formKey.currentState.validate() && _validateShopEntries()) {
            formKey.currentState.save();
            Future<int> addShops;
            if (_load) {
              _itemRepo.update(_item.id, _item);
              addShops = _storeRepo.clearItem(_item).then((_) => _item.id);
            } else {
              addShops = _itemRepo.create(_item);
            }
            addShops.then((id) =>
                selectedDropDowns.forEach(
                        (entry) =>
                        _storeRepo.addItemToStore(entry.store,
                            Item(id: id),
                            price: _interpretPriceString(entry.price))))
                .then((_) => Navigator.pop(context, true));
          }
        },
      ),
    ],
  );

  bool _validateShopEntries() {
    var valid = true;

    for (var store in selectedDropDowns) {
      store.valid = store.store != null;
      valid = store.valid && valid;
    }

    this.setState(() => valid);

    return valid;
  }

  Widget _buildShopSelectorForm(BuildContext context, int index) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 10),
      title: Column(
        children: [
          _buildShopDropdownMenu(context, index),
          _buildPriceInputField(context, index),
        ],
      ),
      trailing: IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => this.setState(() {
          selectedDropDowns.removeAt(index);
          GlobalKey<FormState>();
        }),
      ),
    );
  }

  Widget _buildShopDropdownMenu(BuildContext context, int index)
  => DropdownButtonFormField(
    decoration: InputDecoration(
      labelText: 'Shop',
      errorText: selectedDropDowns[index].valid ? null : 'Enter a store',
    ).applyDefaults(Theme.of(context).inputDecorationTheme),
    items: stores.map((store) => DropdownMenuItem(
        value: store,
        child: Text(store.name))
    ).toList(),
    onChanged: (value) => this.setState(() => selectedDropDowns[index].store = value),
    value: selectedDropDowns[index].store,
    validator: (value) {
      if (value == null
          && selectedDropDowns.length > index // TODO: Remove properly so this hack is not needed
          && !(selectedDropDowns[index].price == null
              || selectedDropDowns[index].price.trim().isEmpty)) {
        return 'Shop auswählen';
      }
      return null;
    },
  );

  Widget _buildPriceInputField(BuildContext context, int index) => Row(
    children: [
      Expanded(
          flex: 4,
          child: TextFormField(
            inputFormatters: [NumberInputFormatter()],
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onSaved: (value) => selectedDropDowns[index].price = value,
            initialValue: selectedDropDowns[index].price,
            decoration: InputDecoration(
              labelText: 'Value',
            ).applyDefaults(Theme.of(context).inputDecorationTheme),
          )),
      Expanded(
          flex: 1,
          child: Text('€')
      ),
    ],
  );

  int _interpretPriceString(String price) {
    var placeOfComma = price.indexOf('.');
    var rawPrice = price.replaceAll('.', '');
    if (placeOfComma < 0) {
      placeOfComma = price.length - 1;
    }
    var exponent = 2 - (price.length - placeOfComma - 1);
    return int.tryParse(rawPrice)??0 * (pow(10,exponent));
  }

  Future<void> _getShops() {
    return _storeRepo.listAll().then((storeList) => this.setState(() => stores = storeList));
  }
}

class _MetaShopItem {
  Store store;
  String price;
  bool valid;

  _MetaShopItem({this.store, this.price, this.valid=true});
}

class NumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var exp = RegExp(r'^[0-9]*[.]?[0-9]?[0-9]?$');
    if (exp.hasMatch(newValue.text)) {
      return newValue;
    }

    return oldValue;
  }
}