import 'dart:convert';

class ShoppingItem {//extends JsonDecoder{
  int amount;
  String name;
  int id;
  DateTime created;
  DateTime changed;
  bool crossedOut = false;

  ShoppingItem(this.name);

  @override
  String toString(){
    return name + "\u{1F}" + amount.toString() + "\u{1F}" + id.toString();
  }

  ShoppingItem.fromJson(String s): name = s;

  Map<String, dynamic> toJson() => { 'name': name };
}
