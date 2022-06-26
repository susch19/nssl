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
import 'package:nssl/helper/iterable_extensions.dart';
import '../main.dart';
import 'barcode_scanner_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainPage extends ConsumerStatefulWidget {
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends ConsumerState<MainPage> with TickerProviderStateMixin, WidgetsBindingObserver {
  final ScrollController _mainController = ScrollController();
  final ScrollController _drawerController = ScrollController();

  String? ean = "";
  bool performanceOverlay = false;
  bool materialGrid = false;

  AnimationController? _controller;
  Animation<double>? _drawerContentsOpacity;
  Animation<Offset>? _drawerDetailsPosition;
  bool _showDrawerContents = true;
  bool insideSortAndOrderCrossedOut = false;
  bool insideUpdateOrderIndicies = false;

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state.index == 0) {
      await Startup.loadMessagesFromFolder(ref);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Startup.deleteMessagesFromFolder();
    Startup.initializeNewListsFromServer(ref);

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
    var currentList = ref.watch(currentListProvider);
    return Scaffold(
        appBar: AppBar(
            title: Text(
              currentList?.name ?? NSSLStrings.of(context).noListLoaded(),
            ),
            actions: _getMainDropdownActions(context)),
        body: ShoppingListWidget(this),
        floatingActionButton: acceptReordingFAB(),
        drawer: _buildDrawer(context),
        persistentFooterButtons: ref.watch(_isReorderingProvider) || currentList == null
            ? <Widget>[]
            : <Widget>[
                  TextButton(
                      child: Text(NSSLStrings.of(context).addPB()), onPressed: () => _addWithoutSearchDialog(context))
                ] +
                (Platform.isAndroid
                    ? [TextButton(child: Text(NSSLStrings.of(context).scanPB()), onPressed: () => _getEAN(currentList))]
                    : []) +
                [TextButton(child: Text(NSSLStrings.of(context).searchPB()), onPressed: search)]);
  }

  void _onReorderItems(int oldIndex, int newIndex) {
    var currentList = ref.watch(currentShoppingItemsProvider);

    if (currentList.isEmpty) return;

    ShoppingItem olditem = currentList[oldIndex];
    currentList.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    currentList.remove(olditem);
    if (newIndex > oldIndex) {
      currentList.insert(newIndex - 1, olditem);
    } else
      currentList.insert(newIndex, olditem);

    var newList = <ShoppingItem>[];
    int currentSortOrder = 0;
    for (int i = 0; i < currentList.length; i++) {
      var currItem = currentList[i];
      if (i < oldIndex && i < newIndex) {
        newList.add(currItem);
        currentSortOrder = currentList[i].sortOrder;
      } else if (i >= oldIndex || i >= newIndex) {
        newList.add(currItem.cloneWith(newSortOrder: ++currentSortOrder));
      }
    }

    var shoppingState = ref.watch(shoppingItemsProvider.notifier);
    var newState = shoppingState.state.toList();
    newState.removeElements(currentList);
    newState.addAll(newList);
    shoppingState.state = newState;
  }

  void showInSnackBar(String value, {Duration? duration, SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(value), duration: duration ?? Duration(seconds: 3), action: action));
  }

  void showInDrawerSnackBar(String value, {Duration? duration, SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(value), duration: duration ?? Duration(seconds: 3), action: action));
  }

  Future register() => Navigator.pushNamed(context, "/registration");

  Future search() => Navigator.pushNamed(context, "/search");

  Future login() => Navigator.pushNamed(context, "/login");

  Future addProduct() => Navigator.pushNamed(context, "/addProduct");

  void handleDismissMain(DismissDirection dir, ShoppingItem s) async {
    var list = ref.watch(currentListProvider);

    if (list == null) return;
    var listProvider = ref.read(shoppingListsProvider);

    final String action =
        (dir == DismissDirection.endToStart) ? NSSLStrings.of(context).archived() : NSSLStrings.of(context).deleted();
    await listProvider.deleteSingleItem(list, s);

    ShoppingListSync.deleteProduct(list.id, s.id, context);

    showInSnackBar(NSSLStrings.of(context).youHaveActionItemMessage() + "${s.name} $action",
        action: SnackBarAction(
            label: NSSLStrings.of(context).undo(),
            onPressed: () {
              listProvider.addSingleItem(list, s);
              ShoppingListSync.changeProductAmount(list.id, s.id, s.amount, context);
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
            }),
        duration: Duration(seconds: 10));
  }

  Future selectedOption(String s) async {
    switch (s) {
      case "Login/Register":
        login();
        break;
      case "options":
        await Navigator.push(
                context,
                MaterialPageRoute<DismissDialogAction>(
                  builder: (BuildContext context) => SettingsPage(),
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
      case "logout":
        _logout();
        break;
      case "ChangePassword":
        Navigator.push(
            context,
            MaterialPageRoute<DismissDialogAction>(
              builder: (BuildContext context) => ChangePasswordPage(),
              fullscreenDialog: true,
            ));
        break;
      case "reorderItems":
        var reordering = ref.watch(_isReorderingProvider.notifier);
        reordering.state = !reordering.state;
        break;
    }
  }

  void changeCurrentList(int index) {
    var currList = ref.watch(currentListIndexProvider.notifier);
    currList.state = index;
    var currUser = ref.read(userProvider);
    currUser.save(index);
    Navigator.of(context).pop();
  }

  Future<Null> _getEAN(ShoppingList currentList) async {
    ean = await Navigator.push(
        context,
        MaterialPageRoute<String>(
          builder: (BuildContext context) => BarcodeScannerScreen(),
          fullscreenDialog: true,
        ));

    if (ean == null || ean == "" || ean == "Permissions denied") return;

    var firstRequest = await ProductSync.getProduct(ean, context);
    var z = jsonDecode((firstRequest).body);
    var k = ProductAddPage.fromJson(z);

    if (k.success) {
      RegExp reg = RegExp("([0-9]+[.,]?[0-9]*(\\s)?[gkmlGKML]{1,2})");
      String? name = reg.hasMatch(k.name!) ? k.name : "${k.name} ${k.quantity}${k.unit}";
      var shoppingItems = ref.read(shoppingItemsPerListProvider.create(currentList.id));
      var item = shoppingItems.firstOrNull((x) => x.name == name);
      if (item != null) {
        var answer = await ShoppingListSync.changeProductAmount(currentList.id, item.id, 1, context);
        var p = ChangeListItemResult.fromJson((answer).body);
        var newItem = item.cloneWith(newAmount: p.amount, newChanged: p.changed);
        item.exchange(newItem, ref);
      } else {
        var p =
            AddListItemResult.fromJson((await ShoppingListSync.addProduct(currentList.id, name, '-', 1, context)).body);

        var items = ref.watch(shoppingItemsProvider.notifier);
        var newState = items.state.toList();
        int sortOrder = 0;
        if (shoppingItems.length > 0) sortOrder = shoppingItems.last.sortOrder + 1;
        newState.add(ShoppingItem(p.name, currentList.id, sortOrder, amount: 1, id: p.productId));
        items.state = newState;
      }
      var provider = ref.read(shoppingListsProvider);
      provider.save(currentList);

      return;
    }
    Navigator.push(
        context,
        MaterialPageRoute<DismissDialogAction>(
            builder: (BuildContext context) => AddProductToDatabase(ean), fullscreenDialog: true));
  }

  void chooseListToAddDialog() {
    var dialog = AlertDialog(
      title: Text(NSSLStrings.of(context).chooseListToAddTitle()),
      content: Container(
        width: 80,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: [
            ListTile(
              title: Text(NSSLStrings.of(context).chooseAddListDialog()),
              onTap: () {
                Navigator.pop(context, "");
                addListDialog();
              },
            ),
            ListTile(
              title: Text(NSSLStrings.of(context).chooseAddRecipeDialog()),
              onTap: () {
                Navigator.pop(context, "");
                addRecipeDialog();
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(child: Text(NSSLStrings.of(context).cancelButton()), onPressed: () => Navigator.pop(context, "")),
      ],
    );

    showDialog(builder: (BuildContext context) => dialog, context: context, barrierDismissible: false);
  }

  void addListDialog() {
    var sd = SimpleDialogSingleInput.create(
        hintText: NSSLStrings.of(context).newNameOfListHint(),
        labelText: NSSLStrings.of(context).listName(),
        onSubmitted: createNewList,
        title: NSSLStrings.of(context).addNewListTitle(),
        context: context);

    showDialog(builder: (BuildContext context) => sd, context: context, barrierDismissible: false);
  }

  void addRecipeDialog() {
    var sd = SimpleDialogSingleInput.create(
        hintText: NSSLStrings.of(context).recipeNameHint(),
        labelText: NSSLStrings.of(context).recipeName(),
        onSubmitted: createNewRecipe,
        title: NSSLStrings.of(context).addNewRecipeTitle(),
        context: context);

    showDialog(builder: (BuildContext context) => sd, context: context, barrierDismissible: false);
  }

  Future renameListDialog(int listId) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => SimpleDialogSingleInput.create(
            hintText: NSSLStrings.of(context).renameListHint(),
            labelText: NSSLStrings.of(context).listName(),
            onSubmitted: (s) => renameList(listId, s),
            title: NSSLStrings.of(context).renameListTitle(),
            context: context));
  }

  Future createNewRecipe(String idOrUrl) async {
    var provider = ref.read(shoppingListsProvider);
    var indexProvider = ref.watch(currentListIndexProvider.notifier);
    var res = await ShoppingListSync.addRecipe(idOrUrl, context);
    var newListRes = GetListResult.fromJson(res.body);
    var newList = ShoppingList(newListRes.id!, newListRes.name!);

    var items = ref.watch(shoppingItemsProvider.notifier);
    var newState = items.state.toList();
    if (newListRes.products != null)
      newState.addAll(newListRes.products!.map((e) => ShoppingItem(e.name, newList.id, e.sortOrder,
          amount: e.amount, id: e.id, created: e.created, changed: e.changed)));

    items.state = newState;

    provider.addList(newList);

    indexProvider.state = provider.shoppingLists.indexOf(newList);
    provider.save(newList);
  }

  Future createNewList(String listName) async {
    var provider = ref.read(shoppingListsProvider);
    var currentListProvider = ref.watch(currentListIndexProvider.notifier);
    var res = await ShoppingListSync.addList(listName, context);
    var newListRes = AddListResult.fromJson(res.body);
    var newList = ShoppingList(newListRes.id, newListRes.name);
    provider.addList(newList);

    currentListProvider.state = provider.shoppingLists.indexOf(newList);
    provider.save(newList);
  }

  Widget _buildDrawer(BuildContext context) {
    var user = ref.watch(userProvider);
    var isDarkTheme = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    var userheader = UserAccountsDrawerHeader(
      accountName: Text(user.username == "" ? NSSLStrings.of(context).notLoggedInYet() : user.username),
      accountEmail: Text(user.eMail == "" ? NSSLStrings.of(context).notLoggedInYet() : user.username),
      currentAccountPicture: CircleAvatar(
          child: Text(
            user.username.substring(0, 2).toUpperCase(),
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
    var shoppingListsController = ref.watch(shoppingListsProvider);
    var list = shoppingListsController.shoppingLists.isNotEmpty
        ? shoppingListsController.shoppingLists
            .map((x) => ListTile(
                  title: Text(x.name),
                  onTap: () => changeCurrentList(shoppingListsController.shoppingLists
                      .indexOf(shoppingListsController.shoppingLists.firstWhere((y) => y.id == x.id))),
                  trailing: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      onSelected: (v) async => await drawerListItemMenuClicked(v),
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: x.id.toString() + "\u{1E}" + "Contributors",
                              child: ListTile(
                                leading: const Icon(Icons.person_add),
                                title: Text(NSSLStrings.of(context).contributors()),
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: x.id.toString() + "\u{1E}" + "BoughtList",
                              child: ListTile(
                                leading: const Icon(Icons.history),
                                title: Text(NSSLStrings.of(context).boughtProducts()),
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
                                    title: Text(NSSLStrings.of(context).rename()))),
                            PopupMenuItem<String>(
                                value: x.id.toString() + "\u{1E}" + 'Auto-Sync',
                                child: ListTile(
                                    leading: Icon(x.messagingEnabled ? Icons.check_box : Icons.check_box_outline_blank),
                                    title: Text(NSSLStrings.of(context).autoSync()))),
                            const PopupMenuDivider(),
                            PopupMenuItem<String>(
                                value: x.id.toString() + "\u{1E}" + 'Remove',
                                child: ListTile(
                                    leading: const Icon(Icons.delete), title: Text(NSSLStrings.of(context).remove())))
                          ]),
                ))
            .toList()
        : [
            ListTile(title: Text(NSSLStrings.of(context).noListsInDrawerMessage())),
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
                              title: Text(NSSLStrings.of(context).refresh()),
                              onTap: () => _handleDrawerRefresh(),
                            ),
                            ListTile(
                              leading: const Icon(Icons.restore_page_outlined),
                              title: Text(
                                NSSLStrings.of(context).changePasswordPD(),
                              ),
                              onTap: () => selectedOption("ChangePassword"),
                            ),
                            ListTile(
                              leading: const Icon(Icons.exit_to_app),
                              title: Text(NSSLStrings.of(context).logout()),
                              onTap: () async {
                                await _logout();
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
          TextButton(child: Text(NSSLStrings.of(context).addListPB()), onPressed: chooseListToAddDialog)
        ]);

    return Drawer(child: d);
  }

  Future<void> _logout() async {
    var user = ref.read(userProvider);

    await user.delete();
    var userState = ref.watch(userStateProvider.notifier);
    userState.state = User.empty;

    var restartState = ref.watch(appRestartProvider.notifier);
    restartState.state = restartState.state + 1;
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
            context,
            MaterialPageRoute<DismissDialogAction>(
              builder: (BuildContext context) => BoughtItemsPage(id),
              fullscreenDialog: true,
            ));
        break;
      case "Rename":
        renameListDialog(id);
        break;
      case "Remove":
        var deleteList = ref.read(shoppingListByIdProvider.create(id));
        if (deleteList == null) return;
        var cont = context;
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => SimpleDialogAcceptDeny.create(
                title: NSSLStrings.of(context).deleteListTitle() + deleteList.name,
                text: NSSLStrings.of(context).deleteListText(),
                onSubmitted: (s) async {
                  var res = Result.fromJson((await ShoppingListSync.deleteList(id, context)).body);
                  if (!(res.success))
                    showInDrawerSnackBar(res.error);
                  else {
                    var currentList = ref.read(currentListProvider);
                    var shoppingListController = ref.read(shoppingListsProvider);
                    if (currentList == null || currentList.id == id) {
                      var other = shoppingListController.shoppingLists.firstOrNull((l) => l.id != id);
                      if (other != null) changeCurrentList(shoppingListController.shoppingLists.indexOf(other));
                    }
                    shoppingListController.removeList(deleteList.id);
                    showInDrawerSnackBar(deleteList.name + " " + NSSLStrings.of(cont).removed());
                  }
                },
                context: context));
        break;
      case "Auto-Sync":
        var shoppingListController = ref.read(shoppingListsProvider);
        shoppingListController.toggleFirebaseMessaging(id);

        break;
      case "ExportAsPdf":
        ExportManager.exportAsPDF(
            ref.read(shoppingListByIdProvider.create(id))!, ref.read(shoppingItemsPerListProvider.create(id)), context);
        break;
    }
  }

  Future<Null> _handleDrawerRefresh() async {
    await ref.read(shoppingListsProvider).reloadAllLists();
  }

  Future<Null> _handleMainListRefresh(int id) => _handleListRefresh(id);

  Future<Null> _handleListRefresh(int listId) async {
    await ref.read(shoppingListsProvider).refresh(ref.read(shoppingListByIdProvider.create(listId))!);
  }

  Future<Null> shoppingItemChange(ShoppingItem s, int change) async {
    var res = ChangeListItemResult.fromJson(
        (await ShoppingListSync.changeProductAmount(s.listId, s.id, change, context)).body);
    if (!res.success) return;
    s.exchange(s.cloneWith(newAmount: res.amount, newChanged: res.changed), ref);
  }

  var amountPopList = <PopupMenuEntry<String>>[];
  List<PopupMenuEntry<String>> buildChangeMenuItems(BuildContext context) {
    if (amountPopList.length == 0)
      for (int i = 1; i <= 99; i++)
        amountPopList.add(PopupMenuItem<String>(value: i.toString(), child: Text(i.toString())));
    return amountPopList;
  }

  Future<Null> crossOutMainListItem(ShoppingItem x) async {
    var newItem = x.cloneWith(newCrossedOut: !x.crossedOut);
    x.exchange(newItem, ref);
    var provider = ref.read(shoppingListsProvider);
    var currentList = ref.read(currentListProvider);
    if (currentList != null) provider.save(currentList);
  }

  void _addWithoutSearchDialog(BuildContext extContext) {
    showDialog(
        context: extContext,
        barrierDismissible: false,
        builder: (BuildContext context) => SimpleDialogSingleInput.create(
            context: context,
            title: NSSLStrings.of(context).addProduct(),
            hintText: NSSLStrings.of(context).addProductWithoutSearch(),
            labelText: NSSLStrings.of(context).productName(),
            onSubmitted: _addWithoutSearch));
  }

  Future<Null> renameList(int id, String text) async {
    var put = await ShoppingListSync.changeLName(id, text, context);
    showInDrawerSnackBar("${put.statusCode}" + put.reasonPhrase!);
    var res = Result.fromJson((put.body));
    if (!res.success) showInDrawerSnackBar(res.error);
    var listsProvider = ref.read(shoppingListsProvider);
    listsProvider.rename(id, text);
  }

  Future<Null> _addWithoutSearch(String value) async {
    var list = ref.read(currentListProvider);
    if (list == null) return;
    var shoppingItems = ref.read(currentShoppingItemsProvider);

    var same = shoppingItems.firstOrNull((x) => x.name.toLowerCase() == value.toLowerCase());
    if (same != null) {
      var res = await ShoppingListSync.changeProductAmount(list.id, same.id, 1, context);
      if (res.statusCode != 200) showInSnackBar(res.reasonPhrase!);
      var product = ChangeListItemResult.fromJson(res.body);
      if (!product.success) showInSnackBar(product.error);
      same.exchange(
          same.cloneWith(
              newAmount: product.amount,
              newChanged: product.changed,
              newId: product.id,
              newName: product.name,
              newListId: product.listId),
          ref);
    } else {
      var res = await ShoppingListSync.addProduct(list.id, value, null, 1, context);
      if (res.statusCode != 200) showInSnackBar(res.reasonPhrase!);
      var product = AddListItemResult.fromJson(res.body);
      if (!product.success) showInSnackBar(product.error);
      var sips = ref.watch(shoppingItemsProvider.notifier);
      var newState = sips.state.toList();
      var order = 0;
      if (shoppingItems.length > 0) order = shoppingItems.last.sortOrder + 1;

      newState.add(ShoppingItem(product.name, list.id, order, id: product.productId, amount: 1, crossedOut: false));
      sips.state = newState;
    }
    var listProv = ref.watch(shoppingListsProvider);
    listProv.save(list);
  }

  Future<Null> _deleteCrossedOutItems() async {
    var list = ref.read(currentListProvider);
    if (list == null) return;
    var shoppingList = ref.read(currentShoppingItemsProvider);

    var sublist = shoppingList.where((s) => s.crossedOut).toList();
    var res = await ShoppingListSync.deleteProducts(list.id, sublist.map((s) => s.id).toList(), context);
    if (!Result.fromJson(res.body).success) return;
    var shoppingItemsState = ref.watch(shoppingItemsProvider.notifier);
    var newState = shoppingItemsState.state.toList();

    newState.removeElements(sublist);

    shoppingItemsState.state = newState;
    var listProv = ref.watch(shoppingListsProvider);
    listProv.save(list);
    showInSnackBar(NSSLStrings.of(context).messageDeleteAllCrossedOut(),
        duration: Duration(seconds: 10),
        action: SnackBarAction(
            label: NSSLStrings.of(context).undo(),
            onPressed: () async {
              var res = await ShoppingListSync.changeProducts(
                  list.id, sublist.map((s) => s.id).toList(), sublist.map((s) => s.amount).toList(), context);
              var hashResult = HashResult.fromJson(res.body);
              int ownHash = 0;
              for (var item in sublist) ownHash += item.id + item.amount;
              if (ownHash == hashResult.hash) {
                var shoppingItemsState = ref.watch(shoppingItemsProvider.notifier);
                var newState = shoppingItemsState.state.toList();
                newState.addAll(sublist);
                shoppingItemsState.state = newState;
                var listProv = ref.watch(shoppingListsProvider);
                listProv.save(list);
              } else
                _handleListRefresh(list.id);
            }));
  }

  renameListItem(ShoppingItem shoppingItem) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => SimpleDialogSingleInput.create(
            context: context,
            title: NSSLStrings.of(context).renameListItem(),
            hintText: NSSLStrings.of(context).renameListHint(),
            labelText: NSSLStrings.of(context).renameListItemLabel(),
            defaultText: shoppingItem.name,
            maxLines: 2,
            onSubmitted: (s) async {
              var currentList = ref.read(currentListProvider);
              if (currentList == null) return;

              var res = ChangeListItemResult.fromJson(
                  (await ShoppingListSync.changeProductName(currentList.id, shoppingItem.id, s, context)).body);

              var items = ref.watch(shoppingItemsProvider.notifier);
              var newState = items.state.toList();
              var item = newState.firstWhere((x) => x.id == shoppingItem.id);
              newState.remove(item);
              newState.add(
                item.cloneWith(newName: res.name),
              );
              items.state = newState;
            }));
  }

  Widget? acceptReordingFAB() {
    var isReordering = ref.watch(_isReorderingProvider);
    if (!isReordering) return null;
    return FloatingActionButton(
      child: Icon(
        Icons.check,
      ),
      onPressed: () async {
        var reorderingState = ref.watch(_isReorderingProvider.notifier);
        reorderingState.state = false;
        var currentList = ref.read(currentListProvider);
        var ids = ref.read(currentShoppingItemsProvider);
        await ShoppingListSync.reorderProducts(currentList!.id, ids.map((e) => e.id).toList(), context);
      },
    );
  }

  List<Widget> _getMainDropdownActions(BuildContext context) {
    var isReorderingItems = ref.watch(_isReorderingProvider);
    if (isReorderingItems) return <Widget>[];

    return <Widget>[
      // IconButton(
      //     onPressed: () {
      //       Navigator.push(
      //           context,
      //           MaterialPageRoute<DismissDialogAction>(
      //             builder: (BuildContext context) => SettingsPage(),
      //             fullscreenDialog: true,
      //           ));
      //     },
      //     icon: Icon(Icons.settings)),
      PopupMenuButton<String>(
          onSelected: selectedOption,
          itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                PopupMenuItem<String>(
                  value: 'deleteCrossedOut',
                  child: Text(
                    NSSLStrings.of(context).deleteCrossedOutPB(),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'reorderItems',
                  child: Text(
                    NSSLStrings.of(context).reorderItems(),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'options',
                  child: Text(
                    NSSLStrings.of(context).options(),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Text(
                    NSSLStrings.of(context).logout(),
                  ),
                ),
              ])
    ];
  }
}

final _isReorderingProvider = StateProvider<bool>((final _) {
  return false;
});

class ShoppingListWidget extends ConsumerWidget {
  final MainPageState mainPageState;
  const ShoppingListWidget(this.mainPageState, {Key? key}) : super(key: key);

  void updateOrderIndiciesAndSave(ShoppingList currentList, List<ShoppingItem> shoppingItems, WidgetRef ref) async {
    // var newItems = <ShoppingItem>[];
    // var curSortOrder = 0;
    // for (var i = 0; i < shoppingItems.length; i++) {
    //   var curItem = shoppingItems[i];
    //   if (curItem.sortWithOffset > curSortOrder)
    //     newItems.add(curItem);
    //   else
    //     newItems.add(curItem.cloneWith(newSortOrder: ++curSortOrder));
    // }
    // var itemsState = ref.watch(shoppingItemsProvider.notifier);
    // var newState = itemsState.state.toList();
    // newState.removeElements(shoppingItems);
    // newState.addAll(newItems);
    // itemsState.state = newState;

    // var listProvider = ref.read(shoppingListsProvider);
    // listProvider.save(currentList);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var currentList = ref.watch(currentListProvider);
    if (currentList == null) return const Text("");
    var shoppingItems = ref.watch(currentShoppingItemsProvider);
    if (shoppingItems.isEmpty) return const Text("");

    if (shoppingItems.any((item) => item.sortOrder == -1)) updateOrderIndiciesAndSave(currentList, shoppingItems, ref);

    shoppingItems.sort((a, b) => a.sortWithOffset.compareTo(b.sortWithOffset));
    var lv;
    if (shoppingItems.length > 0) {
      final isReorderingItems = ref.watch(_isReorderingProvider);
      var mainList = shoppingItems.map((x) {
        return getListTileForShoppingItem(x, isReorderingItems, context);
      }).toList(growable: true);

      if (isReorderingItems) {
        lv = ReorderableListView(
            onReorder: mainPageState._onReorderItems, scrollDirection: Axis.vertical, children: mainList);
      } else {
        lv = CustomScrollView(
          controller: mainPageState._mainController,
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
      onRefresh: () => mainPageState._handleMainListRefresh(currentList.id),
    );
  }

  Widget getListTileForShoppingItem(ShoppingItem? x, bool isReorderingItems, BuildContext context) {
    if (x == null || x.name == "") return Text("Null");
    // return Text(x.name!);

    var lt = ListTile(
      key: ValueKey(x),
      title: Wrap(
        children: [
          Text(
            x.name,
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
        onSelected: (y) => mainPageState.shoppingItemChange(x, int.parse(y) - x.amount),
        itemBuilder: mainPageState.buildChangeMenuItems,
      ),
      trailing: isReorderingItems ? Icon(Icons.reorder) : null,
      onTap: isReorderingItems ? null : (() => mainPageState.crossOutMainListItem(x)),
      onLongPress: isReorderingItems ? null : (() => mainPageState.renameListItem(x)),
    );

    if (isReorderingItems) {
      return lt;
    } else {
      return Dismissible(
        key: ValueKey(x),
        child: lt,
        onDismissed: (DismissDirection d) => mainPageState.handleDismissMain(d, x),
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
  }
}
