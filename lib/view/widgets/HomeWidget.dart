import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shopping_list_pro/model/_shopping_list.dart';
import 'package:shopping_list_pro/persistence/shopping_list_repository.dart';
import 'package:shopping_list_pro/view/widgets/DefaultScaffold.dart';

class HomeWidget extends StatefulWidget {
  final ShoppingListRepository listRepository;

  HomeWidget(this.listRepository);

  @override
  State<StatefulWidget> createState() => _HomeState(listRepository);
}

class _HomeState extends State<HomeWidget> {
  final ShoppingListRepository listRepository;

  List<ShoppingListMetadata> lists = [];

  _HomeState(this.listRepository);

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext ctx) {
    return DefaultScaffold.build(
      body: Container(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          shrinkWrap: true,
          children: [
            Card(
              child: Column(
                children: <Widget>[
                  ListView.separated(
                    separatorBuilder: (ctx, int) => Divider(),
                    shrinkWrap: true,
                    itemBuilder: _buildShoppingListMetadata,
                    itemCount: lists.length,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    child: RaisedButton.icon(
                        icon: Icon(Icons.add),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/new-list')
                                .then((list) {
                              if (list != null) {
                                listRepository
                                    .create(list)
                                    .then((_) => _getData());
                                Navigator.pushNamed(context, '/view-list',
                                    arguments: list);
                              }
                            }),
                        label: Text('Create new list')),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.stretch,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildShoppingListMetadata(BuildContext context, int id) => ListTile(
        title: Text(lists[id].name),
        trailing: Text('${lists[id].openItemCount}/${lists[id].itemCount}'),
        onTap: () => Navigator.pushNamed(context, '/view-list',
            arguments: ShoppingList(id: lists[id].id, name: lists[id].name)),
      );

  _getData() {
    listRepository.getListMetadata().then((opt) =>
        opt.ifPresent((list) => this.setState(() => this.lists = list)));
  }
}
