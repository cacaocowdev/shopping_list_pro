import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class InputDialog extends StatefulWidget {

  InputDialog({
    Key key,
    this.title,
    this.titlePadding = const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
    this.contentPadding = const EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 16.0),
    this.backgroundColor,
    this.elevation,
    this.shape,
  }): assert(titlePadding != null),
        assert(contentPadding != null),
        super(key: key);

  final String title;

  final EdgeInsetsGeometry titlePadding;

  final EdgeInsetsGeometry contentPadding;

  final Color backgroundColor;

  final double elevation;

  final ShapeBorder shape;

  @override
  State<StatefulWidget> createState() => InputDialogState(
    title: this.title,
    titlePadding: this.titlePadding,
    contentPadding: this.contentPadding,
    backgroundColor: this.backgroundColor,
    elevation: this.elevation,
    shape: this.shape,
  );
}

class InputDialogState extends State<InputDialog> {

  InputDialogState({
    this.title,
    this.titlePadding = const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
    this.contentPadding = const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 16.0),
    this.backgroundColor,
    this.elevation,
    this.shape,
  });

  final String title;

  final EdgeInsetsGeometry titlePadding;

  final EdgeInsetsGeometry contentPadding;

  final Color backgroundColor;

  final double elevation;

  final ShapeBorder shape;

  String _value;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));

    List<Widget> body = [];

    body.add(
        SingleChildScrollView(
          child: TextField(
            decoration: InputDecoration(
              labelText: this.title,
            ),
            onChanged: (val) => this._value = val,

          ),
          padding: this.contentPadding,
        )
    );

    body.add(ButtonBar(
      children: <Widget>[
        FlatButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        FlatButton(
          child: Text('Okay'),
          onPressed: () => Navigator.pop(context, this._value),
        )
      ],
    ));

    Widget dialogChild = IntrinsicWidth(
      stepWidth: 56.0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 280.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: body,
        ),
      ),
    );

    return Dialog(
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      child: dialogChild,
    );
  }
}