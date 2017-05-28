import 'package:flutter/material.dart';
import 'package:testProject/models/model_export.dart';
import 'package:flutter/widgets.dart';
import 'package:testProject/server_communication//s_c.dart';
import 'dart:async';
import 'dart:convert';
import 'package:testProject/server_communication/return_classes.dart';

class ContributorsPage extends StatefulWidget {
  ContributorsPage(this.listId, {Key key, this.title}) : super(key: key);
  final String title;
  final int listId;
  @override
  _ContributorsPagePageState createState() =>
      new _ContributorsPagePageState(listId);
}

class _ContributorsPagePageState extends State<ContributorsPage> {
  final GlobalKey<ScaffoldState> _mainScaffoldKey =
      new GlobalKey<ScaffoldState>();
  GlobalKey _iff = new GlobalKey();
  GlobalKey _ib = new GlobalKey();
  TextEditingController tec = new TextEditingController();
  List<ContributorResult> conList = new List<ContributorResult>();
  int k = 1;
  int listId;
  _ContributorsPagePageState(int listId) {
    this.listId = listId;
    ShoppingListSync.getContributors(listId).then((o) {
      if (o.statusCode == 500) {
        showInSnackBar("Internal Server Error");
        return;
      }
      GetContributorsResult z = GetContributorsResult.fromJson(o.body);
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
      AddContributorResult z = AddContributorResult.fromJson(o.body);
      if (!z.success)
        showInSnackBar("Something went wrong!\n${z.error}",
            duration: new Duration(seconds: 10));
      else
        setState(() => conList.add(new ContributorResult()
          ..name = z.name
          ..userId = z.id
          ..isAdmin = false));
    });
  }

  Widget buildBody() {
    bool isAdmin = false;
    if (conList.length > 0) {
      isAdmin = conList.firstWhere((x) => x.name == User.username).isAdmin;
      var listView = new ListView.builder(
          itemBuilder: (c, i) {
            return new ListTile(
                title: new Text(conList[i].name +
                    (conList[i].isAdmin ? " - Admin" : " - User")),
                trailing: isAdmin && conList[i].name != User.username
                    ? new PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        onSelected: popupMenuClicked,
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                              new PopupMenuItem<String>(
                                  value: conList[i].userId.toString() +
                                      "\u{1E}ChangeRight", //x.id.toString() + "\u{1E}" + 'Rename',
                                  child: new ListTile(
                                      leading: (conList[i].isAdmin
                                          ? const Icon(Icons.arrow_downward)
                                          : const Icon(Icons.arrow_upward)),
                                      title: (conList[i].isAdmin
                                          ? const Text('Demote')
                                          : const Text('Promote')))),
                              const PopupMenuDivider(), // ignore: list_element_type_not_assignable
                              new PopupMenuItem<String>(
                                  value: conList[i].userId.toString() +
                                      "\u{1E}Remove", //x.id.toString() + "\u{1E}" + 'Remove',
                                  child: const ListTile(
                                      leading: const Icon(Icons.delete),
                                      title: const Text('Remove')))
                            ])
                    : const Text(""),
                onTap: () => {});
          },
          itemCount: conList.length);
      return listView;
    } else
      return new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new Container(
            child: new SizedBox(
                width: 40.0,
                height: 40.0,
                child: new CircularProgressIndicator()),
            padding: const EdgeInsets.only(top: 16.0),
          )
        ],
      );
  }

  void showInSnackBar(String value,
      {Duration duration: null, SnackBarAction action}) {
    _mainScaffoldKey.currentState.removeCurrentSnackBar();
    _mainScaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(value),
        duration: duration ?? new Duration(seconds: 3),
        action: action));
  }

  Future popupMenuClicked(String value) async {
    var splitted = value.split("\u{1E}");
    var command = splitted[1];
    switch (command) {
      case "Remove":
        var userId = int.parse(splitted[0]);
        var res = await ShoppingListSync.deleteContributor(listId, userId);
        var enres = Result.fromJson(res.body);
        if (!enres.success)
          showInSnackBar(enres.error);
        else {
          showInSnackBar(conList.firstWhere((x) => x.userId == userId).name +
              " was removed successfully");
          setState(() => conList.removeWhere((x) => x.userId == userId));
        }
        break;
      case "ChangeRight":
        var userId = int.parse(splitted[0]);
        var res = await ShoppingListSync.changeRight(listId, userId);
        var enres = Result.fromJson(res.body);
        if (!enres.success)
          showInSnackBar(enres.error);
        else {
          ShoppingListSync.getContributors(listId).then((o) {
            if (o.statusCode == 500) {
              showInSnackBar("Internal Server Error");
              return;
            }
            GetContributorsResult z = GetContributorsResult.fromJson(o.body);
            if (!z.success || z.contributors.length <= 0)
              showInSnackBar("Something went completely wrong!\n${z.error}",
                  duration: new Duration(seconds: 10));
            else
              conList.clear();
            setState(() => conList.addAll(z.contributors));
          });
        }
        break;
    }
  }
}
