import 'package:testProject/models/shopping_list.dart';

class User {
  static String username;
  static String eMail;
  static List<ShoppingList> shoppingLists = new List<ShoppingList>();
  static String token;
  static int currentListIndex;
  static ShoppingList currentList;

}