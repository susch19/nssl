class ShoppingItem {
  int amount;
  String name;
  int id;
  bool crossedOut = false;

  @override
  String toString(){
    return name + "\u{1F}" + amount.toString() + "\u{1F}" + id.toString();
  }
}
