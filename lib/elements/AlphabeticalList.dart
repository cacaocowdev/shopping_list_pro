import 'package:flutter/material.dart';

class AlphabeticalList<T> extends StatelessWidget {

  final List<T> items;
  final String Function(T) extractor;
  final Widget Function(BuildContext, T) itemBuilder;

  final ScrollController controller;

  AlphabeticalList({
    @required List<T> items,
    @required this.extractor,
    @required this.itemBuilder,
    this.controller
  }) :  assert(items != null),
        assert(extractor != null),
        assert(itemBuilder != null),
        this.items =
  items.toList()..sort((x,y) => extractor(x).toLowerCase().compareTo(extractor(y).toLowerCase()));

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    String current;
    int idx = 0;

    while (idx < items.length) {
      var next = extractor(items[idx])[0].toUpperCase();
      if (current == next) {
        list.add(itemBuilder(context, items[idx]));
        idx++;
      } else {
        var old = current;
        current = extractor(items[idx])[0].toUpperCase();
        if (!(isDigit(old) && isDigit(current))) {
          list.add(
              ListTile(
                leading: SizedBox(
                  height: 32,
                  width: 32,
                  child: Material(
                    child: Center(child: Text(
                        isDigit(current) ? '#' : current.toUpperCase(),
                        style: Theme.of(context).textTheme.button.copyWith(color: Colors.grey[300]))),
                    shape: CircleBorder(),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: Divider(),
              ));
        }
      }
    }
    return ListView(children: list, controller: controller);
  }

  bool isDigit(String digit) {
    return num.tryParse(digit??'') != null;
  }
}