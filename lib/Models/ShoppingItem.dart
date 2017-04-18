class ShoppingItem {
  //int Id;
  int amount;
  int listId;
  String name;
  int id;

  @override
  String toString(){
    return name + "\u{1F}" + amount.toString() + "\u{1F}" + id.toString();
  }
}
