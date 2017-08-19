import 'package:flutter/material.dart';
import 'package:testProject/localization/nssl_strings.dart';
class _SystemPadding extends StatelessWidget {
  final Widget child;

  _SystemPadding({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return new AnimatedContainer(
        padding: mediaQuery.padding,
        duration: const Duration(milliseconds: 33),
        child: child);
  }
}
class SimpleDialogSingleInput {

  static _SystemPadding create(
      {String hintText,
      String labelText,
      String title,
      ValueChanged<String> onSubmitted,
      BuildContext context}) {
    var tec = new TextEditingController();

    return new _SystemPadding(child: new AlertDialog(
        title: new Text(title),
        content: new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              new TextField(
                  decoration:
                  new InputDecoration(hintText: hintText, labelText: labelText),
                  controller: tec,
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
              child: new Text(NSSLStrings.instance.cancelButton()),
              onPressed: () => Navigator.pop(context, "")),
          new FlatButton(
              child: new Text(NSSLStrings.instance.acceptButton()),
              onPressed: () {
                Navigator.pop(context, "");
                onSubmitted(tec.text);
              })
        ]));

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
//                child: new Text(NSSLStrings.instance.cancelButton()),
//                onPressed: () => Navigator.pop(context, "")),
//            new FlatButton(
//                child: new Text(NSSLStrings.instance.acceptButton()),
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
