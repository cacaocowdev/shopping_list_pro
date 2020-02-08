import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shopping_list_pro/elements/AlphabeticalList.dart';
import 'package:shopping_list_pro/persistence/item_repository.dart';
import 'package:shopping_list_pro/model/model.dart';

class SelectItemsWidget extends StatefulWidget {

  final ItemRepository repo;

  SelectItemsWidget(
      this.repo,
      );

  @override
  _SelectItemsState createState() => _SelectItemsState(this.repo);
}

class _SelectItemsState extends State<SelectItemsWidget> {

  ItemRepository repo;
  List<Item> items = [];

  List<Item> fItems;
  Map<int, bool> selected;

  _SelectItemsState(
      this.repo,
      );

  @override
  void initState() {
    super.initState();
    _refreshItems();
    scrollController = ScrollController();
    scrollController.addListener(() { if ((scrollController.position.userScrollDirection == ScrollDirection.forward) != showCheck) setState(() => this.showCheck = !showCheck);});
  }

  ScrollController scrollController;
  bool showCheck = true;

  @override
  Widget build(BuildContext context) {
    final SelectItemsOptions options = ModalRoute.of(context).settings.arguments;

    if (fItems  == null || fItems.isEmpty) {
      fItems = items;
    }
    fItems.removeWhere((item) => options?.exclude?.contains(item.id));
    if (selected == null || selected.isEmpty) {
      selected = Map.fromIterable(options?.select??[], key: (x) => x, value: (x) => true);
    }

    var fab = FloatingActionButton(
        onPressed: () =>
            Navigator.pop(context, fItems
                .where((item) => selected[item.id]??false)
            ),
        child: Icon(Icons.check),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Choose items'),
        actions: <Widget>[IconButton(icon: Icon(Icons.add), onPressed: () => Navigator.pushNamed(context, '/create-item').then((created) {
          print(context);
          if (created) {
            _refreshItems();
          }
        }))],
      ),
      body: AlphabeticalList<Item>(
        itemBuilder: (context, item) => listItem(context, item),
        extractor: (item) => item.name,
        items: fItems,
        controller: scrollController,
      ),
      floatingActionButton: showCheck ? fab : null,
    );
  }

  Widget listItem(BuildContext context, Item item) {
    return ListTile(
      trailing: Checkbox(
          value: selected[item.id]?? false,
          onChanged: (v) => this.setState(() => selected[item.id] = v,
          )),
      title: Text(item.name),
    );
  }

  _refreshItems() {
    this.repo.listAll()
        .then((list) => setState(() => this.fItems = this.items = list));
  }
}

class SelectItemsOptions {
  List<int> exclude;
  List<int> select;

  SelectItemsOptions({
    this.exclude = const [],
    this.select = const [],
  });
}