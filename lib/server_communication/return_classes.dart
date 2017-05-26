import 'dart:convert';

import 'package:testProject/models_json.dart';

class CreateResult {
  bool success;
  String error;
  int id;
  String username;
  String eMail;
  static CreateResult fromJson(String dataString) =>
      _fromJson(JSON.decode(dataString));

  static CreateResult _fromJson(Map data) {
    var r = new CreateResult();
    r.success = data["success"];
    r.error = data["error"];
    r.id = data["id"];
    r.username = data["username"];
    r.eMail = data["eMail"];
    return r;
  }
}

class LoginResult {
  bool success;
  String error;
  int id;
  String username;
  String eMail;
  String token;
  static LoginResult fromJson(String dataString) =>
      _fromJson(JSON.decode(dataString));
  static LoginResult _fromJson(Map data) {
    var r = new LoginResult();
    r.success = data["success"];
    r.error = data["error"];
    r.id = data["id"];
    r.username = data["username"];
    r.eMail = data["eMail"];
    r.token = data["token"];
    return r;
  }
}

class AddContributorResult {
  bool success;
  String error;
  String name;
  int id;
  static AddContributorResult fromJson(String dataString) =>
      _fromJson(JSON.decode(dataString));

  static AddContributorResult _fromJson(Map data) {
    var r = new AddContributorResult();
    r.success = data["success"];
    r.error = data["error"];
    r.id = data["id"];
    r.name = data["name"];
    return r;
  }
}

class ContributorResult {
  String name;
  int userId;
  bool isAdmin;
}

class GetContributorsResult {
  bool success;
  String error;
  List<ContributorResult> contributors;

  static GetContributorsResult fromJson(String dataString) =>
      _fromJson(JSON.decode(dataString));

  static GetContributorsResult _fromJson(Map data) {
    var r = new GetContributorsResult();
    r.success = data["success"];
    r.error = data["error"];
    List<Map> unMaped = data["contributors"] ?? new List<Map>();
    r.contributors = unMaped.map((x) => new ContributorResult()
      ..name = x["name"]
      ..isAdmin = x["isAdmin"]
      ..userId = x["userId"]).toList();
    return r;
  }
}

class ProductResult {
  bool success;
  String error;
  String name;
  String gtin;
  int quantity;
  String unit;
  static ProductResult fromJson(String dataString) =>
      _fromJson(JSON.decode(dataString));

  static ProductResult _fromJson(Map data) {
    var r = new ProductResult();
    r.success = data["success"];
    r.error = data["error"];
    r.gtin = data["gtin"];
    r.quantity = data["quantitity"];
    r.unit = data["unit"];
    r.name = data["name"];
    return r;
  }
}

class AddListItemResult {
  bool success;
  String error;
  int productId;
  String name;
  String gtin;
  static AddListItemResult fromJson(String dataString) =>
      _fromJson(JSON.decode(dataString));

  static AddListItemResult _fromJson(Map data) {
    var r = new AddListItemResult();
    r.success = data["success"];
    r.error = data["error"];
    r.productId = data["productId"];
    r.gtin = data["gtin"];
    r.name = data["name"];
    return r;
  }
}

class ChangeListItemResult {
  bool success;
  String error;
  String name;
  int id;
  int amount;
  int listId;
  static ChangeListItemResult fromJson(String dataString) =>
      _fromJson(JSON.decode(dataString));

  static ChangeListItemResult _fromJson(Map data) {
    var r = new ChangeListItemResult();
    r.success = data["success"];
    r.error = data["error"];
    r.id = data["id"];
    r.amount = data["amount"];
    r.listId = data["listId"];
    r.name = data["name"];
    return r;
  }
}

class AddListResult {
  bool success;
  String error;
  int id;
  String name;
  static AddListResult fromJson(String dataString) =>
      _fromJson(JSON.decode(dataString));

  static AddListResult _fromJson(Map data) {
    var r = new AddListResult();
    r.success = data["success"];
    r.error = data["error"];
    r.id = data["id"];
    r.name = data["name"];
    return r;
  }
}

class GetListResult {
  int id;
  String name;
  int userId;
  String owner;
  Iterable<ShoppingItem> products;
  String contributors;

  static GetListResult fromJson(String dataString) =>
      _fromJson(JSON.decode(dataString));

  static GetListResult _fromJson(Map data) {
    var r = new GetListResult();
    r.id = data["id"];
    r.name = data["name"];
    r.userId = data["userId"];
    r.owner = data["owner"];
    List<Map> unMaped = data["products"] ?? new List<Map>();
    r.products =
        unMaped.map((x) => new ShoppingItem(x["id"], x["amount"], x["name"]));
    r.contributors = data["contributors"];
    return r;
  }
}

class InfoResult {
  int id;
  String username;
  String eMail;
  List<int> listIds;
  static InfoResult fromJson(String dataString) =>
      _fromJson(JSON.decode(dataString));

  static InfoResult _fromJson(Map data) {
    var r = new InfoResult();
    r.id = data["id"];
    r.username = data["username"];
    r.eMail = data["eMail"];
    r.listIds = data["listIds"]; //TODO listids richtig geschrieben?
    return r;
  }
}

class Result {
  bool success;
  String error;
  static Result fromJson(String dataString) =>
      _fromJson(JSON.decode(dataString));

  static Result _fromJson(Map data) {
    var r = new Result();
    r.success = data["success"];
    r.error = data["error"];
    return r;
  }
}

class SessionRefreshResult {
  String token;
  static SessionRefreshResult fromJson(String dataString) =>
      _fromJson(JSON.decode(dataString));

  static SessionRefreshResult _fromJson(Map data) {
    var r = new SessionRefreshResult();
    r.token = data["token"];
    return r;
  }
}
