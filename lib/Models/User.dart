import 'package:testProject/Models/ShoppingList.dart';

class User {
  static String username;
  static String eMail;
  static List<ShoppingList> shoppingLists = new List<ShoppingList>();
  static String token;
  static int currentListIndex;
  static ShoppingList currentList;

}