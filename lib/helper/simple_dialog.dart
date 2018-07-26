import 'package:flutter/material.dart';
import 'package:testProject/localization/nssl_strings.dart';

class SimpleDialogAcceptDeny {
  static AlertDialog create(
      {String title = "",
      String text = "",
      ValueChanged<String> onSubmitted,
      BuildContext context}) {
    return new AlertDialog(
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
        ]);
  }
}
