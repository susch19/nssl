class TestClass {
  int test;
  String? o;

  TestClass(this.test, this.o);

  TestClass.intOnly(this.test);
}

class ShoppingItem {
  //extends JsonDecoder{
  int amount = 1;
  String? name;
  int? id;
  DateTime? created;
  DateTime? changed;
  bool crossedOut = false;
  int? sortOrder;

  ShoppingItem(this.name);

  @override
  String toString() {
    return name! + "\u{1F}" + amount.toString() + "\u{1F}" + id.toString();
  }

  /// Creates a copy, with only including [amount] and [name]
  ShoppingItem copy() {
    return ShoppingItem(name)..amount = amount;
  }

  /// Creates an identical clone, where all fields are the same as
  /// the parent item
  ShoppingItem clone() {
    return ShoppingItem(name)
      ..amount = amount
      ..id = id
      ..created = created
      ..changed = changed
      ..crossedOut = crossedOut
      ..sortOrder = sortOrder;
  }

  ShoppingItem.fromJson(String s) : name = s;

  Map<String, dynamic> toJson() => {'name': name};
}
