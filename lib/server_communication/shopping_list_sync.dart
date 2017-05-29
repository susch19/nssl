import 's_c.dart';
import 'dart:async';
import 'package:http/http.dart';

final String listpath = "shoppinglists";

class ShoppingListSync {
  static Future<Response> getList(int listId) =>
      HelperMethods.get("$listpath/$listId");

  static Future<Response> deleteList(int listId) =>
      HelperMethods.delete("$listpath/$listId");

  static Future<Response> changeLName(int listId, String newName) =>
      HelperMethods.put("$listpath/$listId", new ChangeListNameArgs(newName));

  static Future<Response> addList(String listName) =>
      HelperMethods.post("$listpath", new AddListArgs(listName));

  static Future<Response> deleteProduct(int listId, int productId) =>
      HelperMethods.delete("$listpath/$listId/products/$productId");

  static Future<Response> deleteProducts(int listId, List<int> productIds) =>
      HelperMethods.post("$listpath/$listId/products/batchaction/delete", new DeleteProductsArgs(productIds));

  static Future<Response> addProduct(
          int listId, String productName, String gtin, int amount) =>
      HelperMethods.post(
          "$listpath/$listId/products/",
          new AddProductArgs()
            ..amount = amount
            ..gtin = gtin
            ..productName = productName);

  static Future<Response> changeProduct(
      int listId, int productId, int change) =>
      HelperMethods.put("$listpath/$listId/products/$productId",
          new ChangeProductArgs(change));

  static Future<Response> changeProducts(
      int listId, List<int> productIds, List<int> amount) =>
      HelperMethods.post("$listpath/$listId/products/batchaction/change",
          new ChangeProductsArgs(productIds, amount));

  static Future<Response> deleteContributor(
          int listId, int userId) //Wenn lokal gespeichert
      =>
      HelperMethods.delete("$listpath/$listId/contributors/$userId");

  static Future<Response> addContributor(int listId, String contributorName) =>
      HelperMethods.post("$listpath/$listId/contributors/",
          new AddContributorArgs(contributorName));

  static Future<Response> getContributors(int listId) =>
      HelperMethods.get("$listpath/$listId/contributors/");

  static Future<Response> changeRight(int listId, int changedUser)
      => HelperMethods.put("$listpath/$listId/contributors/$changedUser");
}
