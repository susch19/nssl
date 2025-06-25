import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nssl/localization/nssl_strings.dart';
import 'package:nssl/models/model_export.dart';
import 'package:nssl/server_communication//s_c.dart';
import 'dart:async';
import 'package:nssl/server_communication/return_classes.dart';

class ContributorsPage extends HookConsumerWidget {
  ContributorsPage(this.listId, {Key? key, this.title}) : super(key: key);
  final String? title;
  final int listId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tec = useTextEditingController();
    final conList = useState(<ContributorResult>[]);

    useEffect(() {
      ShoppingListSync.getContributors(listId, context).then((o) {
        if (o.statusCode == 500) {
          showInSnackBar(context, "Internal Server Error");
          return;
        }
        GetContributorsResult z = GetContributorsResult.fromJson(o.body);
        if (!z.success || z.contributors.length <= 0)
          showInSnackBar(
              context,
              NSSLStrings.of(context).genericErrorMessageSnackbar() +
                  o.reasonPhrase!,
              duration: Duration(seconds: 10));
        else {
          conList.value.addAll(z.contributors);
          conList.value = conList.value.toList();
        }
      });
      return null;
    }, [listId]);

    return Scaffold(
        appBar: AppBar(
            title: Form(
                child: TextField(
                    decoration: InputDecoration(
                        hintText:
                            NSSLStrings.of(context).nameOfNewContributorHint()),
                    onSubmitted: (x) => _addContributor(context, conList, x),
                    autofocus: true,
                    controller: tec))),
        floatingActionButton: FloatingActionButton(
            onPressed: () => {},
            child: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  _addContributor(context, conList, tec.text);
                })),
        body: buildBody(context, ref, conList));
  }

  Future _addContributor(BuildContext context,
      ValueNotifier<List<ContributorResult>> contributors, String value) async {
    var o = await ShoppingListSync.addContributor(listId, value, context);
    AddContributorResult z = AddContributorResult.fromJson(o.body);
    if (!z.success)
      showInSnackBar(context,
          NSSLStrings.of(context).genericErrorMessageSnackbar() + z.error,
          duration: Duration(seconds: 10));
    else {
      contributors.value.add(ContributorResult()
        ..name = z.name
        ..userId = z.id
        ..isAdmin = false);
      contributors.value = contributors.value.toList();
    }
  }

  Widget buildBody(BuildContext context, WidgetRef ref,
      ValueNotifier<List<ContributorResult>> contributorNotifier) {
    final conList = contributorNotifier.value;
    bool? isAdmin = false;
    if (conList.length > 0) {
      var user = ref.watch(userProvider);
      isAdmin = conList
          .firstWhere(
              (x) => x.name!.toLowerCase() == user.username.toLowerCase())
          .isAdmin;
      var listView = ListView.builder(
          itemBuilder: (c, i) {
            return ListTile(
                title: Text(conList[i].name! +
                    (conList[i].isAdmin!
                        ? NSSLStrings.of(context).contributorAdmin()
                        : NSSLStrings.of(context).contributorUser())),
                trailing: isAdmin! &&
                        conList[i].name!.toLowerCase() !=
                            user.username.toLowerCase()
                    ? PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        onSelected: (a) =>
                            popupMenuClicked(context, contributorNotifier, a),
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                  value: conList[i].userId.toString() +
                                      "\u{1E}ChangeRight", //x.id.toString() + "\u{1E}" + 'Rename',
                                  child: ListTile(
                                      leading: (conList[i].isAdmin!
                                          ? const Icon(Icons.arrow_downward)
                                          : const Icon(Icons.arrow_upward)),
                                      title: (conList[i].isAdmin!
                                          ? Text(NSSLStrings.of(context)
                                              .demoteMenu())
                                          : Text(NSSLStrings.of(context)
                                              .promoteMenu())))),
                              const PopupMenuDivider(), // ignore: list_element_type_not_assignable
                              PopupMenuItem<String>(
                                  value: conList[i].userId.toString() +
                                      "\u{1E}Remove", //x.id.toString() + "\u{1E}" + 'Remove',
                                  child: ListTile(
                                      leading: const Icon(Icons.delete),
                                      title: Text(
                                          NSSLStrings.of(context).remove())))
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
            child: SizedBox(
                width: 40.0, height: 40.0, child: CircularProgressIndicator()),
            padding: const EdgeInsets.only(top: 16.0),
          )
        ],
      );
  }

  void showInSnackBar(BuildContext context, String value,
      {Duration? duration, SnackBarAction? action}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(value),
        duration: duration ?? Duration(seconds: 3),
        action: action));
  }

  Future popupMenuClicked(
      BuildContext context,
      ValueNotifier<List<ContributorResult>> contributorNotifier,
      String value) async {
    final conList = contributorNotifier.value;
    var splitted = value.split("\u{1E}");
    var command = splitted[1];
    switch (command) {
      case "Remove":
        var userId = int.parse(splitted[0]);
        var res =
            await ShoppingListSync.deleteContributor(listId, userId, context);
        var enres = Result.fromJson(res.body);
        if (!enres.success)
          showInSnackBar(context, enres.error);
        else {
          showInSnackBar(
              context,
              conList.firstWhere((x) => x.userId == userId).name! +
                  " was removed successfully");
          conList.removeWhere((x) => x.userId == userId);
          contributorNotifier.value = conList.toList();
        }
        break;
      case "ChangeRight":
        var userId = int.parse(splitted[0]);
        var res = await ShoppingListSync.changeRight(listId, userId, context);
        var enres = Result.fromJson(res.body);
        if (!enres.success)
          showInSnackBar(context, enres.error);
        else {
          ShoppingListSync.getContributors(listId, context).then((o) {
            if (o.statusCode == 500) {
              showInSnackBar(context, "Internal Server Error");
              return;
            }
            GetContributorsResult z = GetContributorsResult.fromJson(o.body);
            if (!z.success || z.contributors.length <= 0)
              showInSnackBar(
                  context,
                  NSSLStrings.of(context).genericErrorMessageSnackbar() +
                      z.error,
                  duration: Duration(seconds: 10));
            else
              conList.clear();
            conList.addAll(z.contributors);
            contributorNotifier.value = conList.toList();
          });
        }
        break;
    }
  }
}
