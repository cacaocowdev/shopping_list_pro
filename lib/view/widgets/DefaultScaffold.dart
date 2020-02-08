import 'package:flutter/material.dart';

class DefaultScaffold {
  static final List<Map<String, String>> pages = [
    {'page': 'Home', 'link': '/'},
    {'page': 'Items', 'link': '/items'},
    {'page': 'Shopping Lists', 'link': '/lists'},
    {'page': 'Stores', 'link': '/stores'},
  ];

  static Widget build({
    @required Widget body,
    Widget floatingActionButton,
    FloatingActionButtonLocation floatingActionButtonLocation,
    Widget appBar,
    Widget bottomNavigationBar,
  }) => Scaffold (
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      appBar: appBar?? AppBar(
          title: Row(
              children: [
                Text('Shopping List Pro'),
                Icon(Icons.shopping_cart),
              ]
          ),
      ),
      bottomNavigationBar: bottomNavigationBar,
      drawer: Drawer(
        child: Column(
          children: [
            SizedBox(height: 50.0),
            Text('Navigation'),
            ListView.builder(
                shrinkWrap: true,
                itemCount: pages.length,
                itemBuilder: (context, id) => ListTile(
                  title: Text(pages[id]['page']),
                  onTap: () {
                    Navigator.popUntil(context, (route) => route.isFirst && !route.willHandlePopInternally);
                    Navigator.pushNamed(context, pages[id]['link']);
                  },
                )
            ),
          ],
        ),
      )
  );
}