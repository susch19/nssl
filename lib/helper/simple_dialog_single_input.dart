import 'package:flutter/material.dart';
import 'package:nssl/localization/nssl_strings.dart';

class SimpleDialogSingleInput {
  static AlertDialog create({
    String hintText,
    String labelText,
    String title,
    String defaultText = "",
    int maxLines = 1,
    ValueChanged<String> onSubmitted,
    BuildContext context,
  }) {
    var tec = TextEditingController();
    tec.text = defaultText;

    return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              TextField(
                  decoration: InputDecoration(hintText: hintText, labelText: labelText),
                  controller: tec,
                  maxLines: maxLines,
                  autofocus: true,
                  onSubmitted: (s) {
                    Navigator.pop(context);
                    onSubmitted(s);
                  }),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(child: Text(NSSLStrings.of(context).cancelButton()), onPressed: () => Navigator.pop(context, "")),
          TextButton(
              child: Text(NSSLStrings.of(context).acceptButton()),
              onPressed: () {
                Navigator.pop(context, "");
                onSubmitted(tec.text);
              })
        ]);
  }
}
