//Some comment
import 'dart:convert';
import 'package:testProject/pages/pages.dart';
import 'package:testProject/manager/manager_export.dart';
import 'package:testProject/models/model_export.dart';
import 'package:testProject/server_communication/return_classes.dart';
import 'package:testProject/server_communication/s_c.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

void main() {
  Startup.initialize().whenComplete(() => runApp(new NSSL()));
}

ThemeData dTheme = new ThemeData(
    primarySwatch: Colors.teal,
    accentColor: Colors.teal[600],
    brightness: Brightness.dark);
ThemeData lTheme = new ThemeData(
    primarySwatch: Colors.blue,
    accentColor: Colors.teal[600],
    brightness: Brightness.light);
bool themed = true;

class NSSL extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Home();
  }
}

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  static BuildContext cont;
  final GlobalKey<ScaffoldState> _mainScaffoldKey =
      new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _drawerScaffoldKey =
      new GlobalKey<ScaffoldState>();

  static const platform =
      const MethodChannel('com.yourcompany.testProject/Scandit');

  String ean = "";
  List mainList;
  bool performanceOverlay = false;
  bool materialGrid = false;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'NSSL',
        color: Colors.grey[500],
        theme: (themed ? lTheme : dTheme)
            .copyWith(platform: TargetPlatform.android),
        home: new Scaffold(
            key: _mainScaffoldKey,
            appBar: new AppBar(
                title: new Text(User.currentList.name),
                actions: <Widget>[
                  new PopupMenuButton<String>(
                      onSelected: selectedOption,
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuItem<String>>[
                            const PopupMenuItem<String>(
                                value: 'Login/Register',
                                child: const Text('Login/Register')),
                            const PopupMenuItem<String>(
                                value: 'Options',
                                child: const Text('Change Theme')),
                            const PopupMenuItem<String>(
                                value: 'PerformanceOverlay',
                                child: const Text('Toggle Performance Overlay')),
                            const PopupMenuItem<String>(
                                value: 'materialGrid',
                                child: const Text('Toggle Materialgrid')),
                          ])
                ]),
            body: new Builder(builder: buildBody),
            drawer: _buildDrawer(context),
            persistentFooterButtons: [
              new FlatButton(child: const Text("SCAN"), onPressed: _getEAN),
              new FlatButton(child: const Text("SEARCH"), onPressed: search)
            ]),
        routes: <String, WidgetBuilder>{
          '/login': (BuildContext context) => new LoginPage(),
          '/registration': (BuildContext context) => new Registration(),
          '/search': (BuildContext context) => new ProductAddPage(),
        },
        showPerformanceOverlay: performanceOverlay,
        showSemanticsDebugger: false,
        debugShowMaterialGrid: materialGrid);
  }

  Widget buildBody(BuildContext context) {
    cont = context;

    mainList = User.currentList.shoppingItems.map((x) {
      var lt = new ListTile(
          title: new Row(children: [
            new Expanded(child: new Text(x.name, maxLines: 2, softWrap: true)),
          ]),
          leading: new PopupMenuButton<String>(
            child: new Row(children: [
              new Text(x.amount.toString() + "x"),
              const Icon(Icons.expand_more, size: 16.0),
              new SizedBox(height: 38.0), //for larger clickable size (2 Lines)
            ]),
            initialValue: x.amount.toString(),
            onSelected: (y) => shoppingItemChange(x, int.parse(y) - x.amount),
            itemBuilder: buildChangeMenuItems,
          ));

      return new Dismissible(
        key: new ObjectKey(lt),
        child: lt,
        onDismissed: (DismissDirection d) => handleDismissMain(d, x),
        direction: DismissDirection.startToEnd,
        background: new Container(
            decoration: new BoxDecoration(
                color: Theme.of(context).primaryColor),
            child: new ListTile(
                leading: new Icon(Icons.delete,
                    color: Theme.of(context).accentIconTheme.color,
                    size: 36.0))),
      );
    }).toList(growable: true);

    var lv = new ListView(
      children: mainList.toList(),
      physics: const AlwaysScrollableScrollPhysics(),
    );

    return new RefreshIndicator(
      child: lv,
      onRefresh: _handleMainListRefresh,
    );
  }

  void showInSnackBar(String value,
      {Duration duration: null, SnackBarAction action}) {
    _mainScaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(value),
        duration: duration ?? new Duration(seconds: 3),
        action: action));
  }

  void showInDraweSnackBar(String value,
      {Duration duration: null, SnackBarAction action}) {
    _drawerScaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(value),
        duration: duration ?? new Duration(seconds: 3),
        action: action));
  }

  Future register() => Navigator.pushNamed(cont, "/registration");
  Future search() => Navigator.pushNamed(cont, "/search");

  Future login() => Navigator.pushNamed(cont, "/login");

  //Future handleDismissDrawer(DismissDirection dir, Widget w) =>
  //    handleDismiss(dir, w, drawerList.children);
  void handleDismissMain(DismissDirection dir, ShoppingItem s) {
    final String action =
        (dir == DismissDirection.endToStart) ? 'archived' : 'deleted';
    var index = User.currentList.shoppingItems.indexOf(s);
    setState(() => User.currentList.shoppingItems.remove(s));
    _mainScaffoldKey.currentState.removeCurrentSnackBar();
    ShoppingListSync.deleteProduct(User.currentList.id, s.id);
    User.currentList.save();
    showInSnackBar('You have $action ${s.name}',
        action: new SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              setState(() {
                User.currentList.shoppingItems.insert(index, s);
                ShoppingListSync.changeProduct(
                    User.currentList.id, s.id, s.amount);
                _mainScaffoldKey.currentState.removeCurrentSnackBar();
                User.currentList.save();
              });
            }),
        duration: new Duration(seconds: 10));
  }

  Future handleDismiss(
      DismissDirection direction, Widget item, List list) async {
    final String action =
        (direction == DismissDirection.endToStart) ? 'archived' : 'deleted';
    var index = list.indexOf(item);
    setState(() => list.remove(item));
    _mainScaffoldKey.currentState.removeCurrentSnackBar();

    showInSnackBar('You have $action $item',
        action: new SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              setState(() {
                list.insert(index, item);
                _mainScaffoldKey.currentState.removeCurrentSnackBar();
              });
            }),
        duration: new Duration(seconds: 10));
  }

  double valueStore = 0.0;

  void addANewList() {
    setState(() {
      themed = !themed;
    });
  }

  void selectedOption(String s) {
    switch (s) {
      case "Login/Register":
        login();
        break;
      case "Options":
        addANewList();
        break;
      case "PerformanceOverlay":
        setState(() => performanceOverlay = !performanceOverlay);
        break;
      case "materialGrid":
        setState(() => materialGrid = !materialGrid);
        break;
    }
  }

  void changeCurrentList(int index) => setState(() {
        User.currentListIndex = index;
        setState(() => User.currentList = User.shoppingLists[index]);
        if (FileManager.fileExists("lastList.txt"))
          FileManager.deleteFile("lastList.txt");
        FileManager.createFile("lastList.txt");
        FileManager.write("lastList.txt", User.currentList.id.toString());
      });

  Future<Null> _getEAN() async {
    await platform.invokeMethod('getEAN');
    platform.setMethodCallHandler(setEAN);
  }

  Future<dynamic> setEAN(MethodCall methodCall) async {
    String method = methodCall.method;

    if (method == "setEAN") {
      ean = methodCall.arguments;
      var firstRequest = await ProductSync.getProduct(ean);
      var z = JSON.decode((firstRequest).body);
      var k = ProductAddPage.fromJson(z);

      if (k.success) {
        var res = await ShoppingListSync.addProduct(
            User.currentList.id, k.name, '-', 1);
        var p = AddListItemResult.fromJson(res.body);
        setState(() => User.currentList.shoppingItems.add(new ShoppingItem()
          ..name = p.name
          ..amount = 1
          ..id = p.productId));
        return;
      }
      Navigator.push(
          cont,
          new MaterialPageRoute<DismissDialogAction>(
            builder: (BuildContext context) => new AddProductToDatabase(ean),
            fullscreenDialog: true,
          ));
    }
  }

  void addList() {
    var tec = new TextEditingController();

    var sdo = new SimpleDialogOption(
        child: new Column(children: [
      new TextField(
          decoration: const InputDecoration(
              hintText: 'The name of the new list', labelText: 'listname'),
          controller: tec,
          autofocus: true,
          onSubmitted: addListServer),
      new Row(children: [
        new FlatButton(
            child: const Text("CANCEL"),
            onPressed: () => Navigator.pop(cont, "")),
        new FlatButton(
            child: const Text("ACCEPT"),
            onPressed: () {
              Navigator.pop(cont, "");
              addListServer(tec.text);
            })
      ], mainAxisAlignment: MainAxisAlignment.end)
    ]));

    var sd = new SimpleDialog(
      title: const Text("Add new List"),
      children: [sdo],
    );

    showDialog(child: sd, context: cont);
  }

  Future addListServer(String listName) async {
    var res = await ShoppingListSync.addList(listName);
    var newListRes = AddListResult.fromJson(res.body);
    var newList = new ShoppingList()
      ..id = newListRes.id
      ..name = newListRes.name;
    setState(() => User.shoppingLists.add(newList));
    User.currentListIndex = User.shoppingLists.indexOf(newList);
    FileManager.createFile("ShoppingLists/${newList.id}.sl");
    FileManager.writeln("ShoppingLists/${newList.id}.sl", newList.name);
  }

  bool b = true;
  Widget _buildDrawer(BuildContext context) {
    var userheader = new UserAccountsDrawerHeader(
      accountName: new Text(User.username ?? "Not logged in yet"),
      accountEmail: new Text(User.eMail ?? "Not logged in yet"),
      currentAccountPicture: new CircleAvatar(
          child: new Text(User.username.substring(0, 2).toUpperCase()),
          backgroundColor: Theme.of(cont ?? context).accentColor),
    );

    var list = User.shoppingLists.isNotEmpty
        ? User.shoppingLists
            .map((x) => new ListTile(
                  title: new Text(x.name),
                  onTap: () => changeCurrentList(User.shoppingLists.indexOf(x)),
                  trailing: new PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      onSelected: drawerListItemMenuClicked,
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            new PopupMenuItem<String>(
                              value:
                                  x.id.toString() + "\u{1E}" + "Contributors",
                              child: const ListTile(
                                leading: const Icon(Icons.person_add),
                                title: const Text('Contributors'),
                              ),
                            ),
                            new PopupMenuItem<String>(
                                value: x.id.toString() + "\u{1E}" + 'Rename',
                                child: const ListTile(
                                    leading: const Icon(Icons.mode_edit),
                                    title: const Text('Rename'))),
                            const PopupMenuDivider(), // ignore: list_element_type_not_assignable
                            new PopupMenuItem<String>(
                                value: x.id.toString() + "\u{1E}" + 'Remove',
                                child: const ListTile(
                                    leading: const Icon(Icons.delete),
                                    title: const Text('Remove')))
                          ]),
                ))
            .toList()
        : [
            const ListTile(title: const Text("nothing")),
            const ListTile(title: const Text("here"))
          ];
    //drawerList = new MyList<ListTile>(children: list);

    var d = new Scaffold(
        key: _drawerScaffoldKey,
        body: new RefreshIndicator(
            child: new ListView(children: [
              userheader,
              new Column(children: list),
            ], physics: const AlwaysScrollableScrollPhysics()),
            onRefresh: _handleDrawerRefresh,
            displacement: 1.0),
        persistentFooterButtons: [
          new FlatButton(child: const Text("ADD LIST"), onPressed: addList)
        ]);

    return new Drawer(child: d);
  }

  Future drawerListItemMenuClicked(String value) async {
    var splitted = value.split('\u{1E}');
    int id = int.parse(splitted[0]);
    switch (splitted[1]) {
      case "Contributors":
        Navigator.push(cont,
            new MaterialPageRoute<DismissDialogAction>(
              builder: (BuildContext context) =>new ContributorsPage(id),
              fullscreenDialog: true,
            ));
        break;
      case "Rename":
        /*var put = await ShoppingListSync.changeLName(id, "Demo");
        showInDraweSnackBar("${put.statusCode}" + put.reasonPhrase);
        var res = Result.fromJson((put.body));
        if (!res.success) showInDraweSnackBar(res.error);*/
        break;
      case "Remove":
        var res = Result.fromJson((await ShoppingListSync.deleteList(id)).body);
        if (!res.success)
          showInDraweSnackBar(res.error);
        else {
          showInDraweSnackBar("Removed ${User.shoppingLists
                  .firstWhere((x) => x.id == id)
                  .name}");
          setState(() => User.shoppingLists.removeWhere((x) => x.id == id));
        }
        break;
    }
  }

  Future<Null> _handleDrawerRefresh() async {
    User.shoppingLists.clear(); //TODO is there a faster way of renew a list?
    for (int id in InfoResult.fromJson((await UserSync.info()).body).listIds) {
      var res =
          GetListResult.fromJson(((await ShoppingListSync.getList(id)).body));
      var list = new ShoppingList()
        ..id = res.id
        ..name = res.name
        ..shoppingItems = new List<ShoppingItem>();
      for (var item in res.products)
        list.shoppingItems.add(new ShoppingItem()
          ..name = item.name
          ..id = item.id
          ..amount = item.amount);
      setState(() => User.shoppingLists.add(list));
      list.save();
    }
    return new Future<Null>.value();
  }

  Future<Null> _handleMainListRefresh() async {
    User.currentList.shoppingItems
        .clear(); //TODO is there a faster way of renew a list?
    var res = GetListResult
        .fromJson((await ShoppingListSync.getList(User.currentList.id)).body);
    for (var item in res.products)
      User.currentList.shoppingItems.add(new ShoppingItem()
        ..name = item.name
        ..id = item.id
        ..amount = item.amount);
    setState(() {});
    User.currentList.save();

    return new Future<Null>.value();
  }

  Future shoppingItemChange(ShoppingItem s, int change) async {
    var res = ChangeListItemResult.fromJson((await ShoppingListSync
            .changeProduct(User.currentList.id, s.id, change))
        .body);
    setState(() {
      s.id = res.id;
      s.amount = res.amount;
      s.name = res.name;
    });
  }

  List<PopupMenuEntry<String>> buildChangeMenuItems(BuildContext context) {
    var list = new List<PopupMenuEntry<String>>();
    for (int i = 1; i <= 30; i++)
      list.add(new PopupMenuItem<String>(
          value: i.toString(), child: new Text(i.toString())));
    return list;
  }

/*void mainListItemMenuClicked(String value) {
    var splitted = value.split('\u{1E}');
    int id = int.parse(splitted[0]);
    switch (splitted[1]) {
      case "Remove":
        handleDismissMain(DismissDirection.startToEnd,
            User.currentList.shoppingItems.firstWhere((x) => x.id == id));
        break;
    }
  }

  trailing: new PopupMenuButton<String>(
  padding: EdgeInsets.zero,
  onSelected: mainListItemMenuClicked,
  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        new PopupMenuItem<String>(
          value: x.id.toString() + "\u{1E}" + "Change",
          child: new ListTile(
            leading: const Icon(Icons.mode_edit),
            title: const Text('Change'),
            // trailing: new FlatButton(
            //     child: const Text("+1"), onPressed: () {}),
          ),
        ),
        const PopupMenuDivider(), // ignore: list_element_type_not_assignable
        new PopupMenuItem<String>(
            value: x.id.toString() + "\u{1E}" + 'Remove',
            child: new ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove')))
      ]),
  */ //TODO Save for later potential use
}
