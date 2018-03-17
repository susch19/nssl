import 'package:flutter/material.dart';
import 'package:testProject/localization/nssl_strings.dart';

class _SystemPadding extends StatelessWidget {
  final Widget child;

  _SystemPadding({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return new AnimatedContainer(
        padding: mediaQuery.viewInsets,
        duration: const Duration(milliseconds: 33),
        child: child);
  }
}

class SimpleDialogAcceptDeny {
  static _SystemPadding create(
      {String title = "",
      String text = "",
      ValueChanged<String> onSubmitted,
      BuildContext context}) {
    return new _SystemPadding(
        child: new AlertDialog(
            title: title == "" ? null : new Text(title),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[text == "" ? null : new Text(text)],
              ),
            ),
            actions: <Widget>[
          new FlatButton(
              child: new Text(NSSLStrings.of(context).cancelButton()),
              onPressed: () => Navigator.pop(context, "")),
          new FlatButton(
              child: new Text(NSSLStrings.of(context).acceptButton()),
              onPressed: () {
                Navigator.pop(context, "");
                onSubmitted("");
              })
        ]));
  }
}
