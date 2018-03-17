import 'package:flutter/material.dart';
import 'package:testProject/localization/nssl_strings.dart';
import 'package:testProject/models/model_export.dart';
import 'package:flutter/widgets.dart';
import 'package:testProject/server_communication//s_c.dart';
import 'dart:async';
import 'package:testProject/server_communication/return_classes.dart';

class BoughtItemsPage extends StatefulWidget {
  BoughtItemsPage(this.listId, {Key key, this.title}) : super(key: key);
  final String title;
  final int listId;
  @override
  _BoughtItemsPagePageState createState() =>
      new _BoughtItemsPagePageState(listId);
}

class _BoughtItemsPagePageState extends State<BoughtItemsPage> {
  final GlobalKey<ScaffoldState> _mainScaffoldKey =
      new GlobalKey<ScaffoldState>();
  GlobalKey _iff = new GlobalKey();
  GlobalKey _ib = new GlobalKey();
  TextEditingController tec = new TextEditingController();
  List<ContributorResult> conList = new List<ContributorResult>();
  int k = 1;
  int listId;

  _BoughtItemsPagePageState(int listId) {
    this.listId = listId;
    ShoppingListSync.getContributors(listId, context).then((o) {
      if (o.statusCode == 500) {
        showInSnackBar("Internal Server Error");
        return;
      }
      GetContributorsResult z = GetContributorsResult.fromJson(o.body);
      if (!z.success || z.contributors.length <= 0)
        showInSnackBar(NSSLStrings.of(context).genericErrorMessageSnackbar() + o.reasonPhrase,
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
                    decoration: new InputDecoration(
                        hintText: NSSLStrings.of(context).nameOfNewContributorHint()),
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
    var o = await ShoppingListSync.addContributor(listId, value, context);
    AddContributorResult z = AddContributorResult.fromJson(o.body);
    if (!z.success)
      showInSnackBar(NSSLStrings.of(context).genericErrorMessageSnackbar() + z.error,
          duration: new Duration(seconds: 10));
    else
      setState(() => conList.add(new ContributorResult()
        ..name = z.name
        ..userId = z.id
        ..isAdmin = false));
  }

  Widget buildBody() {
    bool isAdmin = false;
    if (conList.length > 0) {
      isAdmin = conList
          .firstWhere(
              (x) => x.name.toLowerCase() == User.username.toLowerCase())
          .isAdmin;
      var listView = new ListView.builder(
          itemBuilder: (c, i) {
            return new ListTile(
                title: new Text(conList[i].name +
                    (conList[i].isAdmin
                        ? NSSLStrings.of(context).contributorAdmin()
                        : NSSLStrings.of(context).contributorUser())),
                trailing: isAdmin &&
                        conList[i].name.toLowerCase() !=
                            User.username.toLowerCase()
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
                                          ? new Text(NSSLStrings.of(context).demoteMenu())
                                          : new Text(NSSLStrings.of(context).promoteMenu())))),
                              const PopupMenuDivider(), // ignore: list_element_type_not_assignable
                              new PopupMenuItem<String>(
                                  value: conList[i].userId.toString() +
                                      "\u{1E}Remove", //x.id.toString() + "\u{1E}" + 'Remove',
                                  child: new ListTile(
                                      leading: const Icon(Icons.delete),
                                      title: new Text(NSSLStrings.of(context).remove())))
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
      {Duration duration, SnackBarAction action}) {
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
        var res =
            await ShoppingListSync.deleteContributor(listId, userId, context);
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
        var res = await ShoppingListSync.changeRight(listId, userId, context);
        var enres = Result.fromJson(res.body);
        if (!enres.success)
          showInSnackBar(enres.error);
        else {
          ShoppingListSync.getContributors(listId, context).then((o) {
            if (o.statusCode == 500) {
              showInSnackBar("Internal Server Error");
              return;
            }
            GetContributorsResult z = GetContributorsResult.fromJson(o.body);
            if (!z.success || z.contributors.length <= 0)
              showInSnackBar(NSSLStrings.of(context).genericErrorMessageSnackbar() + z.error,
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
