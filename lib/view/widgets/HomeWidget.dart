import 'package:flutter/material.dart';
import 'package:shopping_list_pro/view/widgets/DefaultScaffold.dart';

class HomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultScaffold.build(
      body: Text('Home'),
    );
  }
}