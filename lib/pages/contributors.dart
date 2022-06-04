import 'package:flutter/material.dart';
import 'package:nssl/localization/nssl_strings.dart';
import 'package:nssl/models/model_export.dart';
import 'package:nssl/server_communication//s_c.dart';
import 'dart:async';
import 'package:nssl/server_communication/return_classes.dart';

class ContributorsPage extends StatefulWidget {
  ContributorsPage(this.listId, {Key? key, this.title}) : super(key: key);
  final String? title;
  final int listId;
  @override
  _ContributorsPagePageState createState() => new _ContributorsPagePageState(listId);
}

class _ContributorsPagePageState extends State<ContributorsPage> {
  final GlobalKey<ScaffoldState> _mainScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey _iff = GlobalKey();
  GlobalKey _ib = GlobalKey();
  TextEditingController tec = TextEditingController();
  List<ContributorResult> conList = <ContributorResult>[];
  int k = 1;
  late int listId;

  _ContributorsPagePageState(int listId) {
    this.listId = listId;
  }

  @override
  void initState() {
    super.initState();
    ShoppingListSync.getContributors(listId, context).then((o) {
      if (o.statusCode == 500) {
        showInSnackBar("Internal Server Error");
        return;
      }
      GetContributorsResult z = GetContributorsResult.fromJson(o.body);
      if (!z.success! || z.contributors.length <= 0)
        showInSnackBar(NSSLStrings.of(context).genericErrorMessageSnackbar() + o.reasonPhrase!,
            duration: Duration(seconds: 10));
      else
        setState(() => conList.addAll(z.contributors));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _mainScaffoldKey,
        appBar: AppBar(
            title: Form(
                child: TextField(
                    key: _iff,
                    decoration: InputDecoration(hintText: NSSLStrings.of(context).nameOfNewContributorHint()),
                    onSubmitted: (x) => _addContributor(x),
                    autofocus: true,
                    controller: tec))),
        floatingActionButton: FloatingActionButton(
            onPressed: () => {},
            child: IconButton(
                key: _ib,
                icon: Icon(Icons.add),
                onPressed: () {
                  _addContributor(tec.text);
                })),
        body: buildBody());
  }

  Future _addContributor(String value) async {
    var o = await ShoppingListSync.addContributor(listId, value, context);
    AddContributorResult z = AddContributorResult.fromJson(o.body);
    if (!z.success!)
      showInSnackBar(NSSLStrings.of(context).genericErrorMessageSnackbar() + z.error!, duration: Duration(seconds: 10));
    else
      setState(() => conList.add(ContributorResult()
        ..name = z.name
        ..userId = z.id
        ..isAdmin = false));
  }

  Widget buildBody() {
    bool? isAdmin = false;
    if (conList.length > 0) {
      isAdmin = conList.firstWhere((x) => x.name!.toLowerCase() == User.username!.toLowerCase()).isAdmin;
      var listView = ListView.builder(
          itemBuilder: (c, i) {
            return ListTile(
                title: Text(conList[i].name! +
                    (conList[i].isAdmin!
                        ? NSSLStrings.of(context).contributorAdmin()
                        : NSSLStrings.of(context).contributorUser())),
                trailing: isAdmin! && conList[i].name!.toLowerCase() != User.username!.toLowerCase()
                    ? PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        onSelected: popupMenuClicked,
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                  value: conList[i].userId.toString() +
                                      "\u{1E}ChangeRight", //x.id.toString() + "\u{1E}" + 'Rename',
                                  child: ListTile(
                                      leading: (conList[i].isAdmin!
                                          ? const Icon(Icons.arrow_downward)
                                          : const Icon(Icons.arrow_upward)),
                                      title: (conList[i].isAdmin!
                                          ? Text(NSSLStrings.of(context).demoteMenu())
                                          : Text(NSSLStrings.of(context).promoteMenu())))),
                              const PopupMenuDivider(), // ignore: list_element_type_not_assignable
                              PopupMenuItem<String>(
                                  value: conList[i].userId.toString() +
                                      "\u{1E}Remove", //x.id.toString() + "\u{1E}" + 'Remove',
                                  child: ListTile(
                                      leading: const Icon(Icons.delete), title: Text(NSSLStrings.of(context).remove())))
                            ])
                    : const Text(""),
                onTap: () => {});
          },
          itemCount: conList.length);
      return listView;
    } else
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: SizedBox(width: 40.0, height: 40.0, child: CircularProgressIndicator()),
            padding: const EdgeInsets.only(top: 16.0),
          )
        ],
      );
  }

  void showInSnackBar(String value, {Duration? duration, SnackBarAction? action}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(value), duration: duration ?? Duration(seconds: 3), action: action));
  }

  Future popupMenuClicked(String value) async {
    var splitted = value.split("\u{1E}");
    var command = splitted[1];
    switch (command) {
      case "Remove":
        var userId = int.parse(splitted[0]);
        var res = await ShoppingListSync.deleteContributor(listId, userId, context);
        var enres = Result.fromJson(res.body);
        if (!enres.success!)
          showInSnackBar(enres.error!);
        else {
          showInSnackBar(conList.firstWhere((x) => x.userId == userId).name! + " was removed successfully");
          setState(() => conList.removeWhere((x) => x.userId == userId));
        }
        break;
      case "ChangeRight":
        var userId = int.parse(splitted[0]);
        var res = await ShoppingListSync.changeRight(listId, userId, context);
        var enres = Result.fromJson(res.body);
        if (!enres.success!)
          showInSnackBar(enres.error!);
        else {
          ShoppingListSync.getContributors(listId, context).then((o) {
            if (o.statusCode == 500) {
              showInSnackBar("Internal Server Error");
              return;
            }
            GetContributorsResult z = GetContributorsResult.fromJson(o.body);
            if (!z.success! || z.contributors.length <= 0)
              showInSnackBar(NSSLStrings.of(context).genericErrorMessageSnackbar() + z.error!,
                  duration: Duration(seconds: 10));
            else
              conList.clear();
            setState(() => conList.addAll(z.contributors));
          });
        }
        break;
    }
  }
}
