import 'package:flutter/material.dart';
import 'package:nssl/localization/nssl_strings.dart';

class SimpleDialogAcceptDeny {
  static AlertDialog create(
      {String title = "",
      String text = "",
      ValueChanged<String>? onSubmitted,
      BuildContext? context}) {
    return AlertDialog(
            title: title == "" ? null : Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[Text(text)],
              ),
            ),
            actions: <Widget>[
          TextButton(
              child: Text(NSSLStrings.of(context)!.cancelButton()),
              onPressed: () => Navigator.pop(context!, "")),
          TextButton(
              child: Text(NSSLStrings.of(context)!.acceptButton()),
              onPressed: () {
                Navigator.pop(context!, "");
                onSubmitted!("");
              })
        ]);
  }
}
