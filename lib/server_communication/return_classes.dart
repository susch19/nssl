import 'dart:convert';

import 'package:nssl/models_json.dart';

class BaseResult {
  late bool success;
  late String error;
  static BaseResult fromJson(String dataString) => _fromJson(jsonDecode(dataString));

  static BaseResult _fromJson(Map data) {
    var r = BaseResult();
    r.success = data["success"];
    r.error = data["error"] as String? ?? "";
    return r;
  }
}

class CreateResult extends BaseResult {
  int? id;
  String? username;
  String? eMail;
  static CreateResult fromJson(String dataString) => _fromJson(jsonDecode(dataString));

  static CreateResult _fromJson(Map data) {
    var r = CreateResult();
    r.success = data["success"];
    r.error = data["error"] as String? ?? "";
    r.id = data["id"];
    r.username = data["username"];
    r.eMail = data["eMail"];

    return r;
  }
}

class LoginResult extends BaseResult {
  late int id;
  late String username;
  late String eMail;
  late String token;
  static LoginResult fromJson(String dataString) => _fromJson(jsonDecode(dataString));
  static LoginResult _fromJson(Map data) {
    var r = LoginResult();
    r.success = data["success"];
    r.error = data["error"] as String? ?? "";
    r.id = data["id"];
    r.username = data["username"];
    r.eMail = data["eMail"];
    r.token = data["token"];
    return r;
  }
}

class AddContributorResult extends BaseResult {
  String? name;
  int? id;
  static AddContributorResult fromJson(String dataString) => _fromJson(jsonDecode(dataString));

  static AddContributorResult _fromJson(Map data) {
    var r = AddContributorResult();
    r.success = data["success"];
    r.error = data["error"] as String? ?? "";
    r.id = data["id"];
    r.name = data["name"];
    return r;
  }
}

class ContributorResult {
  String? name;
  int? userId;
  bool? isAdmin;
}

class GetContributorsResult extends BaseResult {
  late List<ContributorResult> contributors;

  static GetContributorsResult fromJson(String dataString) => _fromJson(jsonDecode(dataString));

  static GetContributorsResult _fromJson(Map data) {
    var r = GetContributorsResult();
    r.success = data["success"];
    r.error = data["error"] as String? ?? "";
    List<dynamic> unMaped = data["contributors"] ?? <dynamic>[];
    r.contributors = unMaped
        .map((x) => ContributorResult()
          ..name = x["name"]
          ..isAdmin = x["isAdmin"]
          ..userId = x["userId"])
        .toList();
    return r;
  }
}

class ProductResult extends BaseResult {
  String? name;
  String? gtin;
  double? quantity;
  String? unit;
  static ProductResult fromJson(String dataString) => _fromJson(jsonDecode(dataString));

  static ProductResult _fromJson(Map data) {
    var r = ProductResult();
    r.success = data["success"];
    r.error = data["error"] as String? ?? "";
    r.gtin = data["gtin"];
    r.quantity = data["quantitity"];
    r.unit = data["unit"];
    r.name = data["name"];
    return r;
  }
}

class AddListItemResult extends BaseResult {
  late int productId;
  late String name;
  String? gtin;
  static AddListItemResult fromJson(String dataString) => _fromJson(jsonDecode(dataString));

  static AddListItemResult _fromJson(Map data) {
    var r = AddListItemResult();
    r.success = data["success"];
    r.error = data["error"] as String? ?? "";
    r.productId = data["productId"];
    r.gtin = data["gtin"];
    r.name = data["name"];
    return r;
  }
}

class ChangeListItemResult extends BaseResult {
  late String name;
  late int id;
  late int amount;
  late int listId;
  late DateTime? changed;
  static ChangeListItemResult fromJson(String dataString) => _fromJson(jsonDecode(dataString));

  static ChangeListItemResult _fromJson(Map data) {
    var r = ChangeListItemResult();
    r.success = data["success"];
    r.error = data["error"] as String? ?? "";
    r.id = data["id"];
    r.amount = data["amount"];
    r.listId = data["listId"];
    r.name = data["name"];
    r.changed = DateTime.tryParse(data["changed"]);
    return r;
  }
}

class AddListResult extends BaseResult {
  int id;
  String name;
  AddListResult(this.id, this.name);

  static AddListResult fromJson(String dataString) => _fromJson(jsonDecode(dataString));

  static AddListResult _fromJson(Map data) {
    var r = AddListResult(data["id"], data["name"]);
    r.success = data["success"];
    r.error = data["error"] as String? ?? "";
    return r;
  }
}

class GetListResult {
  int? id;
  String? name;
  int? userId;
  String? owner;
  DateTime? changed;
  DateTime? created;
  Iterable<ShoppingItem>? products;
  String? contributors;

  static GetListResult fromJson(String dataString) => _fromJson(jsonDecode(dataString));

  static GetListResult _fromJson(Map data) {
    var r = GetListResult();
    r.id = data["id"];
    r.name = data["name"];
    r.userId = data["userId"];
    r.owner = data["owner"];
    var unMaped = data["products"] ?? <Map>[];
    r.products = unMaped.map<ShoppingItem>((x) => ShoppingItem(x["id"], x["amount"], x["name"],
        DateTime.tryParse(x["changed"]), DateTime.tryParse(x["created"]), x["sortOrder"]));

    r.contributors = data["contributors"];

    return r;
  }
}

class GetListsResult {
  late Iterable<ShoppingList> shoppingLists;

  static GetListsResult fromJson(String dataString) => _fromJson(jsonDecode(dataString));

  static GetListsResult _fromJson(Map data) {
    var r = GetListsResult();

    List<dynamic> unmappedShoppingLists = data["lists"];
    r.shoppingLists = unmappedShoppingLists.map((s) => ShoppingList(
        s["id"],
        s["name"],
        s["products"]
            .map((x) => ShoppingItem(x["id"], x["amount"], x["name"], DateTime.tryParse(x["changed"]),
                DateTime.tryParse(x["created"]), x["sortOrder"] as int? ?? -1))
            .toList()
            .cast<ShoppingItem>()));

    return r;
  }
}

class GetBoughtListResult {
  int? id;
  String? name;
  late Iterable<ShoppingItem> products;

  static GetBoughtListResult fromJson(String dataString) => _fromJson(jsonDecode(dataString));

  static GetBoughtListResult _fromJson(Map data) {
    var r = GetBoughtListResult();
    r.id = data["id"];
    r.name = data["name"];
    List<dynamic> unMaped = data["products"] ?? <Map>[];
    r.products = unMaped.map((x) => ShoppingItem(x["id"], x["boughtAmount"], x["name"], DateTime.tryParse(x["changed"]),
        DateTime.tryParse(x["created"]), x["sortOrder"]));
    return r;
  }
}

class InfoResult {
  int? id;
  String? username;
  String? eMail;
  List<int>? listIds;
  static InfoResult fromJson(String dataString) => _fromJson(jsonDecode(dataString));

  static InfoResult _fromJson(Map data) {
    var r = InfoResult();
    r.id = data["id"];
    r.username = data["username"];
    r.eMail = data["eMail"];
    r.listIds = data["listIds"];
    return r;
  }
}

class HashResult extends Result {
  int? hash;

  static HashResult fromJson(String dataString) => _fromJson(jsonDecode(dataString));
  static HashResult _fromJson(Map data) {
    var r = HashResult();
    r.success = data["success"];
    r.error = data["error"] as String? ?? "";
    r.hash = data["hash"];
    return r;
  }
}

class Result extends BaseResult {
  static Result fromJson(String dataString) => _fromJson(jsonDecode(dataString));

  static Result _fromJson(Map data) {
    var r = Result();
    r.success = data["success"];
    r.error = data["error"] as String? ?? "";
    return r;
  }
}

class SessionRefreshResult {
  String? token;
  static SessionRefreshResult fromJson(String dataString) => _fromJson(jsonDecode(dataString));

  static SessionRefreshResult _fromJson(Map data) {
    var r = SessionRefreshResult();
    r.token = data["token"];
    return r;
  }
}
