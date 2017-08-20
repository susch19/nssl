import 'package:flutter/src/widgets/framework.dart';

import 's_c.dart';
import 'dart:async';
import 'package:http/http.dart';

final String listpath = "shoppinglists";

class ShoppingListSync {
  static Future<Response> getList(int listId,BuildContext context) =>
      HelperMethods.get("$listpath/$listId", context);

  static Future<Response> getLists(BuildContext context) =>
      HelperMethods.get("$listpath/batchaction/", context);

  static Future<Response> deleteList(int listId,BuildContext context) =>
      HelperMethods.delete("$listpath/$listId", context);

  static Future<Response> changeLName(int listId, String newName,BuildContext context) =>
      HelperMethods.put("$listpath/$listId", context, new ChangeListNameArgs(newName));

  static Future<Response> addList(String listName,BuildContext context) =>
      HelperMethods.post("$listpath", context, new AddListArgs(listName));

  static Future<Response> deleteProduct(int listId, int productId,BuildContext context) =>
      HelperMethods.delete("$listpath/$listId/products/$productId", context);

  static Future<Response> deleteProducts(int listId, List<int> productIds,BuildContext context) =>
      HelperMethods.post("$listpath/$listId/products/batchaction/delete", context, new DeleteProductsArgs(productIds));

  static Future<Response> addProduct(
          int listId, String productName, String gtin, int amount,BuildContext context) =>
      HelperMethods.post(
          "$listpath/$listId/products/", context,
          new AddProductArgs()
            ..amount = amount
            ..gtin = gtin
            ..productName = productName);

  static Future<Response> changeProduct(
      int listId, int productId, int change,BuildContext context) =>
      HelperMethods.put("$listpath/$listId/products/$productId", context,
          new ChangeProductArgs(change));

  static Future<Response> changeProducts(
      int listId, List<int> productIds, List<int> amount,BuildContext context) =>
      HelperMethods.post("$listpath/$listId/products/batchaction/change", context,
          new ChangeProductsArgs(productIds, amount));

  static Future<Response> deleteContributor(
          int listId, int userId,BuildContext context) //Wenn lokal gespeichert
      =>
      HelperMethods.delete("$listpath/$listId/contributors/$userId", context);

  static Future<Response> addContributor(int listId, String contributorName,BuildContext context) =>
      HelperMethods.post("$listpath/$listId/contributors/", context,
          new AddContributorArgs(contributorName));

  static Future<Response> getContributors(int listId,BuildContext context) =>
      HelperMethods.get("$listpath/$listId/contributors/", context);

  static Future<Response> changeRight(int listId, int changedUser,BuildContext context)
      => HelperMethods.put("$listpath/$listId/contributors/$changedUser", context);
}
