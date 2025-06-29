class User {
  User(this.username, this.password, this.email) : super();
  String? username;
  String? email;
  String? password;

  toJson() => {"username": username, "email": email, "pwhash": password};

  static User fromJson(Map data) => User(data["username"], data["email"], data["pwhash"]);
}

class Product {
  String? gtin;
  String? name;
  int? quantity;
  String? unit;

  toJson() => {"gtin": gtin, "name": name, "quantity": quantity, "unit": unit};

  static Product fromJson(Map data) => Product()
    ..quantity = data["quantity"]
    ..name = data["name"]
    ..gtin = data["gtin"]
    ..unit = data["utin"];
}

class ShoppingItem {
  ShoppingItem(this.id, this.amount, this.name, this.changed, this.created, this.sortOrder, this.gtin) : super();
  int id;
  int amount;
  String name;
  String? gtin;
  DateTime? changed;
  DateTime? created;
  int sortOrder;

  toJson() => {
        "id": id,
        "amount": amount,
        "name": name,
        "changed": changed,
        "created": created,
        "sortOrder": sortOrder,
        "gtin": gtin
      };

  static ShoppingItem fromJson(Map data) => ShoppingItem(
      data["id"],
      data["amount"],
      data["name"],
      DateTime.tryParse(data["changed"]),
      DateTime.tryParse(data["created"]),
      data["order"] ?? data["sortOrder"],
      data["gtin"]);
}

class ShoppingList {
  List<ShoppingItem> products;
  int id;
  String name;

  ShoppingList(this.id, this.name, this.products);

  toJson() => {"products": products.map((p) => p.toJson()).toList(growable: false), "id": id, "name": name};

  static ShoppingList fromJson(Map data) => ShoppingList(
      data["id"] as int, data["name"] as String, (data["products"] as List<Map>).map(ShoppingItem.fromJson).toList());
}

class Contributor {
  Contributor(this.id, this.listId, this.name) : super();
  int? id;
  int? listId;
  String? name;

  toJson() => {"id": id, "listId": listId, "name": name};
  static Contributor fromJson(Map data) => Contributor(data["id"], data["listId"], data["name"]);
}
