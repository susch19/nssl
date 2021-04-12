class TestClass{
  int test;
  String o;

  TestClass(this.test, this.o);

  TestClass.intOnly(this.test);
}

class ShoppingItem {
  //extends JsonDecoder{
  int amount;
  String name;
  int id;
  DateTime  created;
  DateTime  changed;
  bool crossedOut = false;
  int  sortOrder;

  ShoppingItem(this.name);

  @override
  String toString() {
    return name + "\u{1F}" + amount.toString() + "\u{1F}" + id.toString();
  }

  ShoppingItem clone(){
    return ShoppingItem(name)
    ..amount=amount
    ..id=id
    ..created=created
    ..changed=changed
    ..crossedOut=crossedOut
    ..sortOrder=sortOrder;
  }

  ShoppingItem.fromJson(String s) : name = s;

  Map<String, dynamic> toJson() => {'name': name};
}
