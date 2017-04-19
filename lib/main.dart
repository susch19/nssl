//Some comment
import 'dart:convert';
import 'package:testProject/Pages/Registration.dart';
import 'package:testProject/Pages/Login.dart';
import 'package:testProject/Pages/ProductAdd.dart';
import 'package:testProject/list.dart';
import 'package:testProject/Manager/Manager.dart';
import 'package:testProject/Models/Models.dart';
import 'package:testProject/ServerCommunication/SC.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

void main() {
  Startup.initialize().whenComplete(() => runApp(new NSSL()));
}

//final List<ShoppingList> shoppingLists = new List<ShoppingList>();

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

  static const platform =
      const MethodChannel('com.yourcompany.testProject/Scandit');

  String ean = "";
  MyList<ListTile> drawerList;
  List mainList;
  bool performanceOverlay = false;

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
                            new PopupMenuItem<String>(
                                value: 'Login/Register',
                                child: new Text('Login/Register')),
                            new PopupMenuItem<String>(
                                value: 'Options',
                                child: new Text('Change Theme')),
                            new PopupMenuItem<String>(
                                value: 'PerformanceOverlay',
                                child: new Text('Toggle Performance Overlay')),
                          ])
                ]),
            body: new Builder(builder: buildBody),
            drawer: _buildDrawer(context),
            persistentFooterButtons: [
              new FlatButton(child: new Text("Scan"), onPressed: _getEAN),
              new FlatButton(child: new Text("Search"), onPressed: search)
            ]),
        routes: <String, WidgetBuilder>{
          '/login': (BuildContext context) => new LoginPage(),
          '/registration': (BuildContext context) => new Registration(),
          '/search': (BuildContext context) => new ProductAddPage()
        },
        showPerformanceOverlay: performanceOverlay);
  }

  Widget buildBody(BuildContext context) {
    cont = context;
    /* MyList<ListTile> mainList;
    if (User.shoppingLists != null || User.shoppingLists.isNotEmpty) {
      var list = User.currentList ?? new ShoppingList();
      if (list.shoppingItems == null || list.shoppingItems.isEmpty)
        mainList =
            new MyList(children: [new ListTile(title: new Text("no items"))]);
      else
        mainList = new MyList(
            children: list.shoppingItems.map((x) {
              return new ListTile(
                  title: new Row(children: [
                new Align(
                    child: new Text(x.name != "" ? x.name : "empty"),
                    alignment: FractionalOffset.centerLeft),
                new Align(
                    child:
                        new Text(x.amount != 0 ? x.amount.toString() : "empty"),
                    alignment: FractionalOffset.centerRight)
              ]));
            }).toList(),
            //divider: true,
           // onRefresh: refresh,
            //onDismiss: handleDismissMain,
            //dismissDirection: DismissDirection.startToEnd
        );
    } else
      mainList =
          new MyList(children: [new ListTile(title: new Text("no items"))]);*/

    mainList = User.currentList.shoppingItems.map((x) {
      var lt = new ListTile(
        title: new Row(children: [
          new Align(
              child: new Text(
                  x.amount != 0 ? x.amount.toString() + "x " : "empty"),
              alignment: FractionalOffset.centerRight),
          new Align(
              child: new Text(x.name != "" ? x.name : "empty",
                  maxLines: 2, softWrap: true),
              alignment: FractionalOffset.centerLeft),
        ]),
      );

      return new Dismissible(
        key: new ObjectKey(lt),
        child: lt,
        onDismissed: (DismissDirection d) => handleDismissMain(d, lt, x),
        direction: DismissDirection.startToEnd,
        background: new Container(
            decoration: new BoxDecoration(
                backgroundColor: Theme.of(context).primaryColor),
            child: new ListTile(
                leading: new Icon(Icons.delete,
                    color: Theme.of(context).accentIconTheme.color,
                    size: 36.0))),
      );
    }).toList(growable: true);

    //mainList = ListTile.divideTiles(context: context, tiles: mainList);

    /*var secondList = mainList.map((f)=> new Dismissible(
        key: new ObjectKey(f),
        child: f,
    onDismissed: (DismissDirection d) => handleDismissMain(d, f),
    direction: DismissDirection.startToEnd,
    background: new Container(
    decoration: new BoxDecoration(
    backgroundColor: Theme.of(context).primaryColor),
    child: new ListTile(
    leading: new Icon(Icons.delete,
    color: Theme.of(context).accentIconTheme.color,
    size: 36.0))),
    )).toList();*/
    var lv = new ListView(children: mainList.toList());

    return lv;
  }

  void showInSnackBar(String value,
      {Duration duration: null, SnackBarAction action}) {
    _mainScaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(value),
        duration: duration ?? new Duration(seconds: 3),
        action: action));
  }

  Future register() => Navigator.pushNamed(cont, "/registration");
  Future search() => Navigator.pushNamed(cont, "/search");

  Future login() {
    return Navigator.pushNamed(cont, "/login");
    //Navigator.pushNamed(cont, "/login");
    //var sd = new SimpleDialog(title: const Text("login"), children: [new LoginPage(scaffoldKey: _mainScaffoldKey)]);

    //return showDialog(context: cont, child: sd);
  }
  //Navigator.push(cont, new MaterialPageRoute(builder: (x) => new LoginPage()));

  Future handleDismissDrawer(DismissDirection dir, Widget w) =>
      handleDismiss(dir, w, drawerList.children);
  void handleDismissMain(DismissDirection dir, Widget w, ShoppingItem s) {
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

    //ShoppingListSync.deleteProduct(User.currentList.id, )

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
    }
  }

  void changeCurrentList(int index) => setState(() {
        User.currentListIndex = index;
        setState(() => User.currentList = User.shoppingLists[index]);
      });

  Future<Null> _getEAN() async {
    await platform.invokeMethod('getEAN');
    platform.setMethodCallHandler(setEAN);
  }

  Future<dynamic> setEAN(MethodCall methodCall) async {
    String method = methodCall.method;

    if (method == "setEAN") {
      ean = methodCall.arguments;
      //SimpleDialog sd = new SimpleDialog(children: [new Text(ean)]);
      //showDialog(context: cont, child: sd);
      var z = JSON.decode((await ProductSync.getProduct(ean)).body);
      var k = ProductAddPage.fromJson(z);
      var res = await ShoppingListSync.addProduct(
          User.currentList.id, k.name, '-', 1);
      var p = AddListItemResult.fromJson(res.body);
      setState(() => User.currentList.shoppingItems.add(new ShoppingItem()
        ..name = p.name
        ..amount = 1
        ..id = p.productId));
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
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(cont, "")),
        new FlatButton(
            child: const Text("Accept"),
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
    /*.then((x) async {
      */
  }

  Future addListServer(String listName) async {
    var res = await ShoppingListSync.addList(listName);
    var newListRes = AddListResult.fromJson(res.body);
    var newList = new ShoppingList()
      ..id = newListRes.id
      ..name = newListRes.name;
    setState(() => User.shoppingLists.add(newList));
    User.currentListIndex = User.shoppingLists.indexOf(newList);
    //setState(() => User.currentListId); //TODO is this needed?
    FileManager.createFile("ShoppingLists/${newList.id}.sl");
    FileManager.writeln("ShoppingLists/${newList.id}.sl", newList.name);
  }

  bool b = true;
  Widget _buildDrawer(BuildContext context) {
    var userheader = new UserAccountsDrawerHeader(
      accountName: new Text(User.username ?? "Not logged in yer"),
      accountEmail: new Text(User.eMail ?? "Not logged in yet"),
      currentAccountPicture: new CircleAvatar(child: const Text("SH")),
    );
    // actions: [new IconButton(icon: new Icon(Icons.add), onPressed: addList)

    //User.shoppingLists.add(new ShoppingList());
    //User.shoppingLists.add(new ShoppingList());
    //User.shoppingLists.add(new ShoppingList());
    var list = User.shoppingLists.isNotEmpty
        ? User.shoppingLists
            .map((x) => new ListTile(
                title: new Text(x.name),
                onTap: () => changeCurrentList(User.shoppingLists.indexOf(x))))
            .toList()
        : [
            new ListTile(title: const Text("nothing")),
            new ListTile(title: const Text("here"))
          ];
    drawerList = new MyList<ListTile>(children: list);
    //,
    //onDismiss: handleDismissDrawer,
    //dismissDirection: DismissDirection.startToEnd);

    var d = new Scaffold(
        body: new RefreshIndicator(
            child: new ListView(children: [
              userheader,
              new Column(children: drawerList.children),
            ], physics: const AlwaysScrollableScrollPhysics()),
            onRefresh: _handleDrawerRefresh,
            displacement: 1.0),
        persistentFooterButtons: [
          new FlatButton(child: const Text("add list"), onPressed: addList)
        ]);

    return new Drawer(child: d);
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
      setState(()=>User.shoppingLists.add(list));
      list.save();
    }
    return new Future<Null>.value();
  }
}
