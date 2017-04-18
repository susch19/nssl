class ShoppingItem {
  //int Id;
  int amount;
  String name;
  int id;

  @override
  String toString(){
    return name + "\u{1F}" + amount.toString() + "\u{1F}" + id.toString();
  }
}
