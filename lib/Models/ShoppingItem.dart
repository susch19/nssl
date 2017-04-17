class ShoppingItem {
  //int Id;
  int amount;
  int listId;
  String name;
  int id;

  @override
  String toString(){
    return name + "\u{31}" + amount.toString() + "\u{31}" + id.toString();
  }
}
