import 'package:flutter/material.dart';
import 'package:shopping_list_pro/model/model.dart';

class NewShoppingListWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NewShoppingListState();
}

class _NewShoppingListState extends State<NewShoppingListWidget> {

  String _name = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Shopping List'),
      ),
      body: Padding(padding: EdgeInsets.symmetric(horizontal: 10.0),child: Flex(
        direction: Axis.vertical,
        children: <Widget>[TextField(
          decoration: InputDecoration(
            labelText: 'Name',
          ),
          onChanged: (str) => _name = str,
        ),
          ButtonBar(
            children: <Widget>[
              RaisedButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              RaisedButton(
                child: Text('Create'),
                onPressed: () => Navigator.pop<ShoppingList>(context,
                    ShoppingList(name: _name)),
              ),
            ],
          )
        ],
      ),
    ));
  }
}