import 'package:flutter/material.dart';
import 'package:shopping_list_pro/model/ViewStoreModel.dart';
import 'package:shopping_list_pro/model/model.dart';
import 'package:shopping_list_pro/persistence/shopping_list_repository.dart';
import 'package:shopping_list_pro/persistence/store_repository.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shopping_list_pro/view/widgets/SelectItemsWidget.dart';

class ViewShoppingListWidget extends StatefulWidget {

  final ShoppingListRepository repo;
  final StoreRepository storeRepo;

  ViewShoppingListWidget(
      this.repo,
      this.storeRepo,
      );

  @override
  State<StatefulWidget> createState() => _ViewShoppingListState();
}

class _ViewShoppingListState extends State<ViewShoppingListWidget> with SingleTickerProviderStateMixin  {

  final List<Tab> tabs = <Tab>[
    Tab(text: 'List'),
    Tab(text: 'Cart'),
  ];

  final ViewStoreModel model = ViewStoreModel();

  static final Store _defaultShop = Store(id: -1, name: "All");

  List<VerboseListItem> sItems = [];
  List<VerboseListItem> cItems = [];
  List<Store> stores = [];

  TabController _tabController;

  ShoppingList sList;

  bool editing = false;

  // Variables for cart value calculations
  Store _selectedShop;
  int sum;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);
    selectedShop = _defaultShop;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (sList == null) {
      sList = ModalRoute.of(context).settings.arguments;
      _refreshItems(sList);
      _refreshShops();
    }

    return WillPopScope(child: Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          _storeSelectorMenu(context),
        ],
        title: Text(sList.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
        ),
      ),
      body: TabBarView(
        children: [
          _shoppingList(context, sList),
          _shoppingCart(),
        ],
        controller: _tabController,
      ),
      floatingActionButton: editing ? FloatingActionButton(
          backgroundColor: Colors.redAccent,
          child: Icon(Icons.clear),
          onPressed: () => this.setState(() => this.editing = false))
          : SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        overlayOpacity: 0.0,
        children:
        [
          SpeedDialChild(
            child: Icon(Icons.add),
            onTap: () => Navigator.pushNamed(context, '/add-items',
                arguments: SelectItemsOptions(exclude: List.of(sItems.followedBy(cItems).map(((item) => item.id))))
            ).then((items) {
              if (items != null && items is Iterable<Item>) {
                items.forEach((item) => widget.repo.setItem(sList, item, 1));
                _refreshItems(sList);
              }
            }),
          ),
          SpeedDialChild(
            child: Icon(Icons.delete),
            onTap: () => widget.repo.delete(sList.id).then((_) => Navigator.pop(context)),
          ),
          SpeedDialChild(
            child: Icon(Icons.edit),
            onTap: () => this.setState(() => this.editing = true),
          )
        ],
      ),
    ),
    onWillPop: () async {
      var old = !editing;
      if (editing) {
        this.setState(() => editing = false);
      }
      return old;
    },
    );
  }

  Widget _storeSelectorMenu(BuildContext context) =>
      PopupMenuButton(
        icon: Icon(Icons.more_vert),
        itemBuilder: (context) => stores.followedBy([_defaultShop])
            .map((store) => PopupMenuItem(
          child: RadioListTile(
              title: Text(store.name),
              value: store,
              groupValue: _selectedShop,
              onChanged: (v) {
                this.setState(() => selectedShop = v);
                _refreshItems(sList);
                Navigator.pop(context);
              }),
        )).toList(),
      );

  Widget _shoppingList(BuildContext context, ShoppingList sList) {
    return ListView.builder(
        itemCount: sItems.length,
        itemBuilder: (context, idx) =>
            _shoppingListItem(context, sItems[idx])
    );
  }

  Widget _shoppingListItem(BuildContext context, VerboseListItem item) {
    return Dismissible(
      direction: DismissDirection.startToEnd,
      key: Key(item.id.toString() + item.count.toString()),
      child: ListTile(
          title: Text(item.name),
          trailing: _itemCount(context, item),
          onTap: () => Navigator.pushNamed(context, '/edit-item', arguments: Item(id: item.id, name: item.name))
      ),
      onDismissed: (d) {
        this.setState(() => sItems.removeWhere((it) => it.id == item.id));
        widget.repo.setInCart(item.toShoppingListItem(sList), true)
            .then((_) => _refreshItems(ShoppingList.id(sList.id)));
      },
    );
  }

  Widget _itemCount(BuildContext context, VerboseListItem item) {
    var children;

    if (editing) {
      children = [
        FlatButton(
          child: Icon(Icons.remove),
          onPressed: item.count <= 0 ? null :  () => widget.repo.setItem(ShoppingList(id: sList.id), Item(id: item.id), item.count - 1, isInCart: item.isInCart).then((_) => _refreshItems(ShoppingList(id: sList.id))),
        ),
        Text(item.count.toString()),
        FlatButton(
          child: Icon(Icons.add),
          onPressed: () => widget.repo.setItem(ShoppingList(id: sList.id), Item(id: item.id), item.count + 1, isInCart: item.isInCart).then((_) => _refreshItems(ShoppingList(id: sList.id))),
        ),
        FlatButton(
          child: Icon(Icons.clear),
          onPressed: () => widget.repo.deleteItem(ShoppingList(id: sList.id), Item(id: item.id)).then((_) => _refreshItems(ShoppingList(id: sList.id))),
        )
      ];
    } else if (_selectedShop != null && _selectedShop.id != -1 && item.price != item.bestPrice) {
      children = [
        Column(
          children: [
            Text('${item.count.toString()}x ${_fmt(item.price)}'),
            Text('(${item.bestStore}: ${_fmt(item.bestPrice)})', style: Theme.of(context).textTheme.body1.copyWith(color: Theme.of(context).textTheme.caption.color))
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        )];
    } else if (_selectedShop != null && _selectedShop.id != -1) {
      children = [
        Column(
          children: [
            Text('${item.count.toString()}x ${_fmt(item.price)}')
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        )];
    } else {
      children = [
        Text('x${item.count.toString()}')
      ];
    }

    return
      Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
  }

  Widget _shoppingCart() {
    return Flex(
        direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              flex: 8,
              child: ListView.builder(
                  itemCount: cItems.length,
                  itemBuilder: (context, idx) =>
                      _shoppingCartItem(context, cItems[idx])
              )
          ),
          Divider(indent: 20.0, height:50.0, endIndent: 20.0, thickness: 1.0,),
          Expanded(
            child: Container(
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [Text('Value:', style: Theme.of(context).textTheme.title), Text(_fmt(sum))]),
                padding: EdgeInsets.only(left: 20.0, right: 100.0)
            ),
          ),
        ]
    );
  }

  Widget _shoppingCartItem(BuildContext context, VerboseListItem item) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      key: Key(item.id.toString() + item.count.toString()),
      child: ListTile(
          title: Text(item.name),
          trailing: _itemCount(context, item),
          onTap: () => Navigator.pushNamed(context, '/edit-item', arguments: Item(id: item.id, name: item.name))
      ),
      onDismissed: (d) {
        this.setState(() => cItems.removeWhere((it) => it.id == item.id));
        widget.repo.setInCart(item.toShoppingListItem(sList), false)
            .then((_) => _refreshItems(ShoppingList.id(sList.id)));
      },
    );
  }

  _refreshItems(ShoppingList sList) {
    model.listItems(sList, store: _selectedShop).then(
            (items) {
          cItems = <VerboseListItem>[];
          sItems = items.where((i) {
            if (i.isInCart) {
              cItems.add(i);
            }
            return !i.isInCart;
          }).toList();
        }).then((_) => _refreshPrice());
  }

  _refreshShops() {
    widget.storeRepo.listAll()
        .then((stores) => this.setState(() =>  this.stores = stores));
  }

  _refreshPrice() {
    if (_selectedShop == null ||_selectedShop.id == -1) {
      this.setState(() => this.sum = null);
    } else {
      model.calculateItemValue(sList, _selectedShop).then((value) => this.setState(() => this.sum = value));
    }
  }

  set selectedShop(Store value) {
    _selectedShop = value;
    _refreshPrice();
  }

  String _fmt(int price) {
    if (price == null) {
      return '--.- €';
    }
    var cents = price % 100;
    return '${(price / 100).floor()},${cents < 10 ? '0' : ''}$cents €';
  }
}