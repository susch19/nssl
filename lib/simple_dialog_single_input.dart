import 'package:flutter/material.dart';

class SimpleDialogSingleInput {
  static SimpleDialog create(
      {String hintText,
      String labelText,
      String title,
      ValueChanged<String> onSubmitted,
      BuildContext context}) {
    var tec = new TextEditingController();

    var sdo = new SimpleDialogOption(
      child: new Column(
        children: [
          new TextField(
              decoration:
                  new InputDecoration(hintText: hintText, labelText: labelText),
              controller: tec,
              autofocus: true,
              onSubmitted: (s) {
                Navigator.pop(context);
                onSubmitted(s);
              }),
          new Row(children: [
            new FlatButton(
                child: const Text("CANCEL"),
                onPressed: () => Navigator.pop(context, "")),
            new FlatButton(
                child: const Text("ACCEPT"),
                onPressed: () {
                  Navigator.pop(context, "");
                  onSubmitted(tec.text);
                })
          ], mainAxisAlignment: MainAxisAlignment.end),
        ],
      ),
    );

    return new SimpleDialog(
      title: new Text(title),
      children: [sdo],
    );
  }
}
