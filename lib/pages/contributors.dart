import 'package:flutter/material.dart';
import 'package:testProject/models/model_export.dart';
import 'package:flutter/widgets.dart';
import 'package:testProject/server_communication//s_c.dart';
import 'dart:async';
import 'dart:convert';
import 'package:testProject/server_communication/return_classes.dart';

class ContributorsPage extends StatefulWidget {
  ContributorsPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ContributorsPagePageState createState() => new _ContributorsPagePageState();
}

class _ContributorsPagePageState extends State<ContributorsPage> {
  final GlobalKey<ScaffoldState> _mainScaffoldKey =
      new GlobalKey<ScaffoldState>();
  GlobalKey _iff = new GlobalKey();
  GlobalKey _ib = new GlobalKey();
  TextEditingController tec = new TextEditingController();
  List<ContributorResult> conList = new List<ContributorResult>();
  int k = 1;

  _ContributorsPagePageState() {
    ShoppingListSync.getContributors(User.currentList.id).then((o) {
      if (o.statusCode == 500) {
        showInSnackBar("Internal Server Error");
        return;
      }
      GetContributorsResult z = JSON.decode(o.body);
      if (!z.success || z.contributors.length <= 0)
        showInSnackBar("Something went completely wrong!\n${o.reasonPhrase}",
            duration: new Duration(seconds: 10));
      else
        setState(() => conList.addAll(z.contributors));
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _mainScaffoldKey,
        appBar: new AppBar(
            title: new Form(
                child: new TextField(
                    key: _iff,
                    decoration: const InputDecoration(
                        hintText: "Name of new Contributor"),
                    onSubmitted: (x) => _addContributor(x),
                    autofocus: true,
                    controller: tec))),
        floatingActionButton: new FloatingActionButton(
            onPressed: () => {},
            child: new IconButton(
                key: _ib,
                icon: new Icon(Icons.add),
                onPressed: () {
                  _addContributor(tec.text);
                })),
        body: buildBody());
  }

  Future _addContributor(String value) async {
    ShoppingListSync.addContributor(User.currentList.id, value).then((o) {
      AddContributorResult z = JSON.decode(o.body);
      if (!z.success)
        showInSnackBar("Something went wrong!\n${o.reasonPhrase}",
            duration: new Duration(seconds: 10));
      else
        setState(() => conList.add(new ContributorResult()
          ..name = z.name
          ..userId = z.id
          ..isAdmin = false));
    });
  }

  Widget buildBody() {
    if (conList.length > 0) {
      var listView = new ListView.builder(
          itemBuilder: (c, i) {
            return new ListTile(
                title: new Text(conList[i].name +
                    (conList[i].isAdmin ? " - Admin" : " - User")),
                onTap: () => {});
          },
          itemCount: conList.length);
      return listView;
    } else
      return new Text("");
  }

  void showInSnackBar(String value,
      {Duration duration: null, SnackBarAction action}) {
    _mainScaffoldKey.currentState.removeCurrentSnackBar();
    _mainScaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(value),
        duration: duration ?? new Duration(seconds: 3),
        action: action));
  }
}
