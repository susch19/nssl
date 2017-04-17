class User {
  User(this.username, this.password, this.email) : super();
  String username;
  String email;
  String password;

  toJson() => {"username": username, "email": email, "pwhash": password};

  static User fromJson(Map data) =>
      new User(data["username"], data["email"], data["pwhash"]);
}

class Product {
  String gtin;
  String name;
  int quantity;
  String unit;

  toJson() => {"gtin": gtin, "name": name, "quantity": quantity, "unit": unit};

  static Product fromJson(Map data) => new Product()
    ..quantity = data["quantity"]
    ..name = data["name"]
    ..gtin = data["gtin"]
    ..unit = data["utin"];
}

class ShoppingItem {
  ShoppingItem(this.id, this.amount, this.name) : super();
  int id;
  int amount;
  String name;

  toJson() => {"id": id, "amount": amount, "name": name};

  static ShoppingItem fromJson(Map data) =>
      new ShoppingItem(data["id"], data["amount"], data["name"]);
}

class ShoppingList {
  List<ShoppingItem> products;
  int id;
  String name;

  toJson() => {
        "products": products.map((p) => p.toJson()).toList(growable: false),
        "id": id,
        "name": name
      };

  static ShoppingList fromJson(Map data) => new ShoppingList()
    ..id = data["id"]
    ..name = data["name"]
    ..products =
        (data["products"] as List<Map>).map(ShoppingItem.fromJson).toList();
}

class Contributor {
  Contributor(this.id, this.listId, this.name) : super();
  int id;
  int listId;
  String name;

  toJson() => {"id": id, "listId": listId, "name": name};
  static Contributor fromJson(Map data) =>
      new Contributor(data["id"], data["listId"], data["name"]);
}
