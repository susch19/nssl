import 'package:flutter/material.dart';
import 'package:nssl/localization/nssl_strings.dart';

class SimpleDialogSingleInput {

  static AlertDialog create(
      {String hintText,
      String labelText,
      String title,
      String defaultText = "",
      int maxLines = 1,
      ValueChanged<String> onSubmitted,
      BuildContext context}) {
    var tec = new TextEditingController();
    tec.text = defaultText;

    return new AlertDialog(
        title: new Text(title),
        content: new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              new TextField(
                  decoration:
                  new InputDecoration(hintText: hintText, labelText: labelText),
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
          new FlatButton(
              child: new Text(NSSLStrings.of(context).cancelButton()),
              onPressed: () => Navigator.pop(context, "")),
          new FlatButton(
              child: new Text(NSSLStrings.of(context).acceptButton()),
              onPressed: () {
                Navigator.pop(context, "");
                onSubmitted(tec.text);
              })
        ]);

//    var sdo = new SimpleDialogOption(
//      child: new Column(
//        children: [
//          new TextField(
//              decoration:
//                  new InputDecoration(hintText: hintText, labelText: labelText),
//              controller: tec,
//              autofocus: true,
//              onSubmitted: (s) {
//                Navigator.pop(context);
//                onSubmitted(s);
//              }),
//          new Row(children: [
//            new FlatButton(
//                child: new Text(NSSLStrings.of(context).cancelButton()),
//                onPressed: () => Navigator.pop(context, "")),
//            new FlatButton(
//                child: new Text(NSSLStrings.of(context).acceptButton()),
//                onPressed: () {
//                  Navigator.pop(context, "");
//                  onSubmitted(tec.text);
//                })
//          ], mainAxisAlignment: MainAxisAlignment.end),
//        ],
//      ),
//    );
//    return new AlertDialog(
//      title: new Text(title),
//      actions: [sdo],
//    );
  }
}
