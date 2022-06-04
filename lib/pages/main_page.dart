import 'dart:convert';
import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:nssl/helper/simple_dialog.dart';
import 'package:nssl/manager/export_manager.dart';
import 'package:nssl/options/themes.dart';
import 'package:nssl/pages/pages.dart';
import 'package:nssl/manager/manager_export.dart';
import 'package:nssl/models/model_export.dart';
import 'package:nssl/server_communication/return_classes.dart';
import 'package:nssl/server_communication/s_c.dart';
import 'package:nssl/helper/simple_dialog_single_input.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:nssl/localization/nssl_strings.dart';
import 'package:nssl/firebase/cloud_messsaging.dart';

import '../main.dart';
import 'barcode_scanner_page.dart';

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> with TickerProviderStateMixin, WidgetsBindingObserver {
  BuildContext? cont;

  final ScrollController _mainController = ScrollController();
  final ScrollController _drawerController = ScrollController();

  String? ean = "";
  bool performanceOverlay = false;
  bool materialGrid = false;
  bool isReorderingItems = false;

  AnimationController? _controller;
  Animation<double>? _drawerContentsOpacity;
  Animation<Offset>? _drawerDetailsPosition;
  bool _showDrawerContents = true;
  bool insideSortAndOrderCrossedOut = false;
  bool insideUpdateOrderIndicies = false;

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state.index == 0) {
      await Startup.loadMessagesFromFolder(setState);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Startup.deleteMessagesFromFolder();
    Startup.initializeNewListsFromServer(setState);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _drawerContentsOpacity = CurvedAnimation(
      parent: ReverseAnimation(_controller!),
      curve: Curves.fastOutSlowIn,
    );
    _drawerDetailsPosition = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.fastOutSlowIn,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
              User.currentList?.name ?? NSSLStrings.of(context)!.noListLoaded(),
            ),
            actions: isReorderingItems
                ? <Widget>[]
                : <Widget>[
                    PopupMenuButton<String>(
                        onSelected: selectedOption,
                        itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                              PopupMenuItem<String>(
                                  value: 'Options', child: Text(NSSLStrings.of(context)!.changeTheme())),
                              PopupMenuItem<String>(
                                  value: 'deleteCrossedOut',
                                  child: Text(NSSLStrings.of(context)!.deleteCrossedOutPB())),
                              PopupMenuItem<String>(
                                  value: 'reorderItems', child: Text(NSSLStrings.of(context)!.reorderItems())),
                            ])
                  ]),
        body: buildBody(context),
        floatingActionButton: isReorderingItems ? acceptReordingFAB() : null,
        drawer: _buildDrawer(context),
        persistentFooterButtons: isReorderingItems
            ? <Widget>[]
            : <Widget>[
                  TextButton(
                      child: Text(NSSLStrings.of(context)!.addPB()), onPressed: () => _addWithoutSearchDialog(context))
                ] +
                (Platform.isAndroid
                    ? [TextButton(child: Text(NSSLStrings.of(context)!.scanPB()), onPressed: _getEAN)]
                    : []) +
                [TextButton(child: Text(NSSLStrings.of(context)!.searchPB()), onPressed: search)]);
  }

  Widget buildBody(BuildContext context) {
    cont = context;

    if (User.currentList == null || User.currentList!.shoppingItems == null) return const Text("");
    if (User.currentList!.shoppingItems!.any((item) => item?.sortOrder == null)) updateOrderIndiciesAndSave();

    User.currentList!.shoppingItems!.sort((a, b) => a!.sortOrder!.compareTo(b!.sortOrder!));
    var lv;
    if (User.currentList!.shoppingItems!.length > 0) {
      var mainList = User.currentList!.shoppingItems!.map((x) {
        if (x == null || x.name == null) return Text("Null");
        // return Text(x.name!);

        var lt = ListTile(
          key: ValueKey(x),
          title: Wrap(
            children: [
              Text(
                x.name ?? "",
                maxLines: 2,
                softWrap: true,
                style: TextStyle(decoration: x.crossedOut ? TextDecoration.lineThrough : TextDecoration.none),
              ),
            ],
          ),
          leading: PopupMenuButton<String>(
            child: FittedBox(
              child: Row(children: [
                Text(x.amount.toString() + "x"),
                const Icon(Icons.expand_more, size: 16.0),
                SizedBox(height: 38.0), //for larger clickable size (2 Lines)
              ]),
            ),
            initialValue: x.amount.toString(),
            onSelected: (y) => shoppingItemChange(x, int.parse(y) - x.amount),
            itemBuilder: buildChangeMenuItems,
          ),
          trailing: isReorderingItems ? Icon(Icons.reorder) : null,
          onTap: isReorderingItems ? null : (() => crossOutMainListItem(x)),
          onLongPress: isReorderingItems ? null : (() => renameListItem(x)),
        );

        if (isReorderingItems) {
          return lt;
        } else {
          return Dismissible(
            key: ValueKey(x),
            child: lt,
            onDismissed: (DismissDirection d) => handleDismissMain(d, x),
            direction: DismissDirection.startToEnd,
            background: Container(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: ListTile(
                leading: Icon(Icons.delete,
                    //  color: Theme.of(context).accentIconTheme.color,
                    size: 36.0),
              ),
            ),
          );
        }
      }).toList(growable: true);

      if (isReorderingItems) {
        lv = ReorderableListView(onReorder: _onReorderItems, scrollDirection: Axis.vertical, children: mainList);
      } else {
        lv = CustomScrollView(
          controller: _mainController,
          slivers: [
            SliverFixedExtentList(
                delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                  return Container(
                    alignment: FractionalOffset.center,
                    child: mainList[index],
                  );
                }, childCount: mainList.length),
                itemExtent: 50.0)
          ],
          physics: AlwaysScrollableScrollPhysics(),
        );
      }
    } else
      lv = ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[ListTile(title: const Text(""))],
      );
    return RefreshIndicator(
      child: lv,
      onRefresh: _handleMainListRefresh,
    );
  }

  void _onReorderItems(int oldIndex, int newIndex) {
    if (User.currentList == null) return;

    ShoppingItem? item = User.currentList!.shoppingItems![oldIndex];
    if (item?.crossedOut ?? false) return;
    setState(
      () {
        item!.sortOrder = newIndex;
        for (var old = oldIndex + 1; old < newIndex; old++) {
          item = User.currentList!.shoppingItems![old];
          if (!item!.crossedOut)
            User.currentList!.shoppingItems![old]!.sortOrder = User.currentList!.shoppingItems![old]!.sortOrder! - 1;
        }
        for (var newI = newIndex; newI < oldIndex; newI++) {
          item = User.currentList!.shoppingItems![newI];
          if (!item!.crossedOut)
            User.currentList!.shoppingItems![newI]!.sortOrder = User.currentList!.shoppingItems![newI]!.sortOrder! - 1;
        }
      },
    );
  }

  void sortAndOrderCrossedOut() {
    final crossedOffset = 0xFFFFFFFF;
    setState(() {
      for (var crossedOut
          in User.currentList?.shoppingItems?.where((x) => x!.crossedOut && x.sortOrder! < crossedOffset) ??
              <ShoppingItem>[]) {
        crossedOut?.sortOrder = crossedOut.sortOrder! + crossedOffset;
      }
      for (var notCrossedOut
          in User.currentList?.shoppingItems?.where((x) => !x!.crossedOut && x.sortOrder! > crossedOffset) ??
              <ShoppingItem>[]) {
        notCrossedOut!.sortOrder = notCrossedOut.sortOrder! - crossedOffset;
      }
    });
  }

  void updateOrderIndiciesAndSave({bool syncToServer = false}) async {
    var i = 1;
    for (var item in User.currentList?.shoppingItems ?? <ShoppingItem>[]) {
      item?.sortOrder = i;
      i++;
    }
    sortAndOrderCrossedOut();
    User.currentList?.save();
  }

  void showInSnackBar(String value, {Duration? duration, SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(value), duration: duration ?? Duration(seconds: 3), action: action));
  }

  void showInDrawerSnackBar(String value, {Duration? duration, SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(value), duration: duration ?? Duration(seconds: 3), action: action));
  }

  Future register() => Navigator.pushNamed(cont!, "/registration");

  Future search() => Navigator.pushNamed(cont!, "/search");

  Future login() => Navigator.pushNamed(cont!, "/login");

  Future addProduct() => Navigator.pushNamed(cont!, "/addProduct");

  void handleDismissMain(DismissDirection dir, ShoppingItem s) async {
    var list = User.currentList;
    final String action =
        (dir == DismissDirection.endToStart) ? NSSLStrings.of(context)!.archived() : NSSLStrings.of(context)!.deleted();
    var index = list!.shoppingItems!.indexOf(s);
    await list.deleteSingleItem(s);
    setState(() {});
    ShoppingListSync.deleteProduct(list.id, s.id, context);
    updateOrderIndiciesAndSave();
    showInSnackBar(NSSLStrings.of(context)!.youHaveActionItemMessage() + "${s.name} $action",
        action: SnackBarAction(
            label: NSSLStrings.of(context)!.undo(),
            onPressed: () {
              setState(() {
                list.addSingleItem(s, index: index);
                ShoppingListSync.changeProductAmount(list.id, s.id, s.amount, context);
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                updateOrderIndiciesAndSave();
              });
            }),
        duration: Duration(seconds: 10));
  }

  Future selectedOption(String s) async {
    switch (s) {
      case "Login/Register":
        login();
        break;
      case "Options":
        await Navigator.push(
                cont!,
                MaterialPageRoute<DismissDialogAction>(
                  builder: (BuildContext context) => CustomThemePage(),
                  fullscreenDialog: true,
                ))
            .whenComplete(() => AdaptiveTheme.of(context)
                .setTheme(light: Themes.lightTheme.theme!, dark: Themes.darkTheme.theme, notify: true));
        break;
      case "PerformanceOverlay":
        setState(() => performanceOverlay = !performanceOverlay);
        break;
      case "deleteCrossedOut":
        _deleteCrossedOutItems();
        break;
      case "materialGrid":
        setState(() => materialGrid = !materialGrid);
        break;
      case "ChangePassword":
        Navigator.push(
            cont!,
            MaterialPageRoute<DismissDialogAction>(
              builder: (BuildContext context) => ChangePasswordPage(),
              fullscreenDialog: true,
            ));
        break;
      case "reorderItems":
        setState(() => isReorderingItems = !isReorderingItems);
        break;
    }
  }

  void changeCurrentList(int index) => setState(() {
        setState(() => User.currentList = User.shoppingLists[index]);
        User.currentListIndex = User.shoppingLists[index].id;
        User.save();
        Navigator.of(context).pop();
      });

  Future<Null> _getEAN() async {
    ean = await Navigator.push(
        cont!,
        MaterialPageRoute<String>(
          builder: (BuildContext context) => BarcodeScannerScreen(),
          fullscreenDialog: true,
        ));

    if (ean == null || ean == "" || ean == "Permissions denied") return;

    var list = User.currentList;
    var firstRequest = await ProductSync.getProduct(ean, cont);
    var z = jsonDecode((firstRequest).body);
    var k = ProductAddPage.fromJson(z);

    if (k.success!) {
      RegExp reg = RegExp("([0-9]+[.,]?[0-9]*(\\s)?[gkmlGKML]{1,2})");
      String? name = reg.hasMatch(k.name!) ? k.name : "${k.name} ${k.quantity}${k.unit}";
      var item = list?.shoppingItems?.firstWhere((x) => x!.name == name, orElse: () => null);
      ShoppingItem afterAdd;
      if (item != null) {
        var answer = await ShoppingListSync.changeProductAmount(list!.id, item.id, 1, cont);
        var p = ChangeListItemResult.fromJson((answer).body);
        setState(() {
          item.amount = p.amount;
          item.changed = p.changed;
        });
      } else {
        var p = AddListItemResult.fromJson((await ShoppingListSync.addProduct(list!.id, name, '-', 1, cont)).body);
        afterAdd = ShoppingItem("${p.name}")
          ..amount = 1
          ..id = p.productId;
        setState(() {
          list.shoppingItems!.add(afterAdd);
          updateOrderIndiciesAndSave();
        });
      }
      list.save();
      return;
    }
    Navigator.push(
        context,
        MaterialPageRoute<DismissDialogAction>(
            builder: (BuildContext context) => AddProductToDatabase(ean), fullscreenDialog: true));
  }

  void addListDialog() {
    var sd = SimpleDialogSingleInput.create(
        hintText: NSSLStrings.of(context)!.newNameOfListHint(),
        labelText: NSSLStrings.of(context)!.listName(),
        onSubmitted: createNewList,
        title: NSSLStrings.of(context)!.addNewListTitle(),
        context: cont);

    showDialog(builder: (BuildContext context) => sd, context: cont!, barrierDismissible: false);
  }

  Future renameListDialog(int listId) {
    return showDialog(
        context: cont!,
        barrierDismissible: false,
        builder: (BuildContext context) => SimpleDialogSingleInput.create(
            hintText: NSSLStrings.of(context)!.renameListHint(),
            labelText: NSSLStrings.of(context)!.listName(),
            onSubmitted: (s) => renameList(listId, s),
            title: NSSLStrings.of(context)!.renameListTitle(),
            context: cont));
  }

  Future createNewList(String listName) async {
    var res = await ShoppingListSync.addList(listName, cont);
    var newListRes = AddListResult.fromJson(res.body);
    var newList = ShoppingList(newListRes.id, newListRes.name);
    setState(() => User.shoppingLists.add(newList));
    changeCurrentList(User.shoppingLists.indexOf(newList));
    firebaseMessaging?.subscribeToTopic(newList.id.toString() + "shoppingListTopic");
    newList.save();
  }

  Widget _buildDrawer(BuildContext context) {
    var isDarkTheme = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    var userheader = UserAccountsDrawerHeader(
      accountName: Text(User.username ?? NSSLStrings.of(context)!.notLoggedInYet()),
      accountEmail: Text(User.eMail ?? NSSLStrings.of(context)!.notLoggedInYet()),
      currentAccountPicture: CircleAvatar(
          child: Text(
            User.username?.substring(0, 2).toUpperCase() ?? "",
            style: TextStyle(color: isDarkTheme ? Colors.black : Colors.white),
          ),
          backgroundColor: isDarkTheme
              ? Themes.darkTheme.theme!.floatingActionButtonTheme.backgroundColor
              : Themes.lightTheme.theme!.floatingActionButtonTheme.backgroundColor),
      onDetailsPressed: () {
        _showDrawerContents = !_showDrawerContents;
        _showDrawerContents ? _controller!.reverse() : _controller!.forward();
      },
    );

    var list = User.shoppingLists.isNotEmpty
        ? User.shoppingLists
            .map((x) => ListTile(
                  title: Text(x.name ?? ""),
                  onTap: () =>
                      changeCurrentList(User.shoppingLists.indexOf(User.shoppingLists.firstWhere((y) => y.id == x.id))),
                  trailing: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      onSelected: (v) async => await drawerListItemMenuClicked(v),
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: x.id.toString() + "\u{1E}" + "Contributors",
                              child: ListTile(
                                leading: const Icon(Icons.person_add),
                                title: Text(NSSLStrings.of(context)!.contributors()),
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: x.id.toString() + "\u{1E}" + "BoughtList",
                              child: ListTile(
                                leading: const Icon(Icons.history),
                                title: Text(NSSLStrings.of(context)!.boughtProducts()),
                                // NSSLStrings.of(context)!.contributors()),
                              ),
                            ),
                            //Deactivated, because it's not working at the moment
                            // PopupMenuItem<String>(
                            //   value: x.id.toString() + "\u{1E}" + 'ExportAsPdf',
                            //   child: ListTile(
                            //       leading: const Icon(Icons.picture_as_pdf),
                            //       title: Text(NSSLStrings.of(context)!.exportAsPdf())),
                            // ),
                            PopupMenuItem<String>(
                                value: x.id.toString() + "\u{1E}" + 'Rename',
                                child: ListTile(
                                    leading: const Icon(Icons.mode_edit),
                                    title: Text(NSSLStrings.of(context)!.rename()))),
                            PopupMenuItem<String>(
                                value: x.id.toString() + "\u{1E}" + 'Auto-Sync',
                                child: ListTile(
                                    leading: Icon(x.messagingEnabled ? Icons.check_box : Icons.check_box_outline_blank),
                                    title: Text(NSSLStrings.of(context)!.autoSync()))),
                            const PopupMenuDivider(),
                            PopupMenuItem<String>(
                                value: x.id.toString() + "\u{1E}" + 'Remove',
                                child: ListTile(
                                    leading: const Icon(Icons.delete), title: Text(NSSLStrings.of(context)!.remove())))
                          ]),
                ))
            .toList()
        : [
            ListTile(title: Text(NSSLStrings.of(context)!.noListsInDrawerMessage())),
          ];
    var emptyListTiles = <ListTile>[];
    for (int i = 0; i < list.length - 2; i++)
      emptyListTiles.add(ListTile(
        title: const Text(("")),
      ));
    var d = Scaffold(
        body: RefreshIndicator(
            child: ListView(
              controller: _drawerController,
              children: <Widget>[
                userheader,
                Stack(
                  children: <Widget>[
                    FadeTransition(
                      opacity: _drawerContentsOpacity!,
                      child: Column(children: list),
                    ),
                    SlideTransition(
                      position: _drawerDetailsPosition!,
                      child: FadeTransition(
                        opacity: ReverseAnimation(_drawerContentsOpacity!),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            ListTile(
                              leading: const Icon(Icons.sync),
                              title: Text(NSSLStrings.of(context)!.refresh()),
                              onTap: () => _handleDrawerRefresh(),
                            ),
                            ListTile(
                              leading: const Icon(Icons.restore_page_outlined),
                              title: Text(
                                NSSLStrings.of(context)!.changePasswordPD(),
                              ),
                              onTap: () => selectedOption("ChangePassword"),
                            ),
                            ListTile(
                              leading: const Icon(Icons.exit_to_app),
                              title: Text(NSSLStrings.of(context)!.logout()),
                              onTap: () async {
                                await User.delete();
                                User.username = null;
                                User.eMail = null;
                                User.token = null;
                                runApp(NSSL());
                              },
                            ),
                            Column(children: emptyListTiles)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              physics: AlwaysScrollableScrollPhysics(),
            ),
            onRefresh: _handleDrawerRefresh,
            displacement: 1.0),
        persistentFooterButtons: [
          TextButton(child: Text(NSSLStrings.of(context)!.addListPB()), onPressed: addListDialog)
        ]);

    return Drawer(child: d);
  }

  Future drawerListItemMenuClicked(String value) async {
    var splitted = value.split('\u{1E}');
    int id = int.parse(splitted[0]);
    switch (splitted[1]) {
      case "Contributors":
        Navigator.maybeOf(context)?.push(MaterialPageRoute<DismissDialogAction>(
          builder: (BuildContext context) => ContributorsPage(id),
          fullscreenDialog: true,
        ));
        break;
      case "BoughtList":
        await Navigator.push(
            cont!,
            MaterialPageRoute<DismissDialogAction>(
              builder: (BuildContext context) => BoughtItemsPage(id),
              fullscreenDialog: true,
            ));
        setState(() {});
        break;
      case "Rename":
        renameListDialog(id);
        break;
      case "Remove":
        var deleteList = User.shoppingLists.firstWhere((x) => x.id == id);
        showDialog(
            context: cont!,
            barrierDismissible: false,
            builder: (BuildContext context) => SimpleDialogAcceptDeny.create(
                title: NSSLStrings.of(cont)?.deleteListTitle() ?? "" + deleteList.name!,
                text: NSSLStrings.of(cont)?.deleteListText() ?? "",
                onSubmitted: (s) async {
                  var res = Result.fromJson((await ShoppingListSync.deleteList(id, cont)).body);
                  if (!(res.success ?? false))
                    showInDrawerSnackBar(res.error!);
                  else {
                    showInDrawerSnackBar(deleteList.name! + " " + NSSLStrings.of(cont)!.removed());
                    if (User.currentList!.id! == id) {
                      changeCurrentList(User.shoppingLists.indexOf(User.shoppingLists.firstWhere((l) => l.id != id)));
                    }
                    setState(() => User.shoppingLists.removeWhere((x) => x.id == id));
                  }
                },
                context: cont));
        break;
      case "Auto-Sync":
        var list = User.shoppingLists.firstWhere((x) => x.id == id);
        list.messagingEnabled ? list.unsubscribeFromFirebaseMessaging() : list.subscribeForFirebaseMessaging();
        list.messagingEnabled = !list.messagingEnabled;
        list.save();
        break;
      case "ExportAsPdf":
        ExportManager.exportAsPDF(User.shoppingLists.firstWhere((x) => x.id == id), context);
        break;
    }
  }

  Future<Null> _handleDrawerRefresh() async {
    await ShoppingList.reloadAllLists(context);
    setState(() => {});
  }

  Future<Null> _handleMainListRefresh() => _handleListRefresh(User.currentList!.id);

  Future<Null> _handleListRefresh(int? listId) async {
    await User.shoppingLists.firstWhere((s) => s.id == listId).refresh(cont);
    setState(() {});
  }

  Future<Null> shoppingItemChange(ShoppingItem s, int change) async {
    var res = ChangeListItemResult.fromJson(
        (await ShoppingListSync.changeProductAmount(User.currentList!.id!, s.id, change, cont)).body);
    setState(() {
      s.id = res.id;
      s.amount = res.amount;
      s.name = res.name;
      s.changed = res.changed;
    });
  }

  var amountPopList = <PopupMenuEntry<String>>[];
  List<PopupMenuEntry<String>> buildChangeMenuItems(BuildContext context) {
    if (amountPopList.length == 0)
      for (int i = 1; i <= 99; i++)
        amountPopList.add(PopupMenuItem<String>(value: i.toString(), child: Text(i.toString())));
    return amountPopList;
  }

  Future<Null> crossOutMainListItem(ShoppingItem x) async {
    setState(() => x.crossedOut = !x.crossedOut);
    await User.currentList?.save();

    if (!isReorderingItems) {
      sortAndOrderCrossedOut();
    }
  }

  void _addWithoutSearchDialog(BuildContext extContext) {
    showDialog(
        context: extContext,
        barrierDismissible: false,
        builder: (BuildContext context) => SimpleDialogSingleInput.create(
            context: context,
            title: NSSLStrings.of(context)!.addProduct(),
            hintText: NSSLStrings.of(context)!.addProductWithoutSearch(),
            labelText: NSSLStrings.of(context)!.productName(),
            onSubmitted: _addWithoutSearch));
  }

  Future<Null> renameList(int id, String text) async {
    var put = await ShoppingListSync.changeLName(id, text, cont);
    showInDrawerSnackBar("${put.statusCode}" + put.reasonPhrase!);
    var res = Result.fromJson((put.body));
    if (!res.success!) showInDrawerSnackBar(res.error!);
  }

  Future<Null> _addWithoutSearch(String value) async {
    var list = User.currentList;
    var same = list!.shoppingItems!.where((x) => x!.name!.toLowerCase() == value.toLowerCase());
    if (same.length > 0) {
      var res = await ShoppingListSync.changeProductAmount(list.id, same.first!.id!, 1, cont);
      if (res.statusCode != 200) showInSnackBar(res.reasonPhrase!);
      var product = ChangeListItemResult.fromJson(res.body);
      if (!product.success!) showInSnackBar(product.error!);
      setState(() {
        same.first!.amount = product.amount;
        same.first!.changed = product.changed;
      });
      same.first;
    } else {
      var res = await ShoppingListSync.addProduct(list.id, value, null, 1, cont);
      if (res.statusCode != 200) showInSnackBar(res.reasonPhrase!);
      var product = AddListItemResult.fromJson(res.body);
      if (!product.success!) showInSnackBar(product.error!);
      setState(() => list.shoppingItems!.add(ShoppingItem(product.name)
        ..id = product.productId
        ..amount = 1
        ..crossedOut = false));
      updateOrderIndiciesAndSave();
    }
  }

  Future<Null> _deleteCrossedOutItems() async {
    var list = User.currentList;
    var sublist = list!.shoppingItems!.where((s) => s!.crossedOut).toList();
    var res = await ShoppingListSync.deleteProducts(list.id, sublist.map((s) => s!.id).toList(), cont);
    if (!Result.fromJson(res.body).success!) return;
    setState(() {
      for (var item in sublist) list.shoppingItems?.remove(item);
    });
    updateOrderIndiciesAndSave();
    showInSnackBar(NSSLStrings.of(context)!.messageDeleteAllCrossedOut(),
        duration: Duration(seconds: 10),
        action: SnackBarAction(
            label: NSSLStrings.of(context)!.undo(),
            onPressed: () async {
              var res = await ShoppingListSync.changeProducts(
                  list.id, sublist.map((s) => s!.id).toList(), sublist.map((s) => s!.amount).toList(), cont);
              var hashResult = HashResult.fromJson(res.body);
              int ownHash = 0;
              for (var item in sublist) ownHash += item!.id! + item.amount;
              if (ownHash == hashResult.hash) {
                setState(() => list.shoppingItems?.addAll(sublist));
                updateOrderIndiciesAndSave();
                list.save();
              } else
                _handleListRefresh(list.id);
            }));
  }

  renameListItem(ShoppingItem? x) {
    showDialog(
        context: cont!,
        barrierDismissible: false,
        builder: (BuildContext context) => SimpleDialogSingleInput.create(
            context: cont,
            title: NSSLStrings.of(context)!.renameListItem(),
            hintText: NSSLStrings.of(context)!.renameListHint(),
            labelText: NSSLStrings.of(context)!.renameListItemLabel(),
            defaultText: x?.name ?? "",
            maxLines: 2,
            onSubmitted: (s) async {
              var res = ChangeListItemResult.fromJson(
                  (await ShoppingListSync.changeProductName(User.currentList!.id, x!.id, s, cont)).body);
              setState(() {
                x.id = res.id;
                x.amount = res.amount;
                x.name = res.name;
                x.changed = res.changed;
              });
            }));
  }

  Widget acceptReordingFAB() => FloatingActionButton(
        child: Icon(
          Icons.check,
        ),
        onPressed: () async {
          var ids = <ShoppingItem>[];
          ids.addAll(User.currentList!.shoppingItems!.map((e) => e!.clone()));
          ids.forEach((element) {
            if (element.sortOrder! > 0xffffffff) element.sortOrder = element.sortOrder! - 0xffffffff;
          });
          ids.sort((x, y) => x.sortOrder!.compareTo(y.sortOrder!));
          await ShoppingListSync.reorderProducts(User.currentList!.id, ids.map((e) => e.id).toList(), context);
          setState(() {
            isReorderingItems = false;
          });
        },
      );
}
