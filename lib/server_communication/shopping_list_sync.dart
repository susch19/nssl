
import 'package:flutter/material.dart';

import 's_c.dart';
import 'dart:async';
import 'package:http/http.dart';

final String listpath = "shoppinglists";

class ShoppingListSync {
  static Future<Response> getList(int listId,BuildContext context, {bool bought = false}) =>
      HelperMethods.get("$listpath/$listId/$bought", context);

  static Future<Response> getLists(BuildContext context) =>
      HelperMethods.get("$listpath/batchaction/", context);

  static Future<Response> deleteList(int listId,BuildContext context) =>
      HelperMethods.delete("$listpath/$listId", context);

  static Future<Response> changeLName(int listId, String newName,BuildContext context) =>
      HelperMethods.put("$listpath/$listId", context, ChangeListNameArgs(newName));

  static Future<Response> addList(String listName,BuildContext context) =>
      HelperMethods.post("$listpath", context, AddListArgs(listName));

  static Future<Response> deleteProduct(int listId, int productId,BuildContext context) =>
      HelperMethods.delete("$listpath/$listId/products/$productId", context);

  static Future<Response> deleteProducts(int listId, List<int> productIds,BuildContext context) =>
      HelperMethods.post("$listpath/$listId/products/batchaction/delete", context, DeleteProductsArgs(productIds));

  static Future<Response> addProduct(
          int listId, String productName, String gtin, int amount,BuildContext context) =>
      HelperMethods.post(
          "$listpath/$listId/products/", context,
          AddProductArgs()
            ..amount = amount
            ..gtin = gtin
            ..productName = productName);

  static Future<Response> changeProductAmount(
      int listId, int productId, int change,BuildContext context) =>
      HelperMethods.put("$listpath/$listId/products/$productId", context,
          ChangeProductArgs(change: change, newName: ""));

  static Future<Response> changeProductName(
      int listId, int productId, String newName,BuildContext context) =>
      HelperMethods.put("$listpath/$listId/products/$productId", context,
          ChangeProductArgs(change: 0, newName: newName));

  static Future<Response> changeProducts(
      int listId, List<int> productIds, List<int> amount,BuildContext context) =>
      HelperMethods.post("$listpath/$listId/products/batchaction/change", context,
          ChangeProductsArgs(productIds, amount));

  static Future<Response> reorderProducts(int listId, List<int> productIds,BuildContext context) =>
      HelperMethods.post("$listpath/$listId/products/batchaction/order", context, DeleteProductsArgs(productIds));


  static Future<Response> deleteContributor(
          int listId, int userId,BuildContext context) //Wenn lokal gespeichert
      =>
      HelperMethods.delete("$listpath/$listId/contributors/$userId", context);

  static Future<Response> addContributor(int listId, String contributorName,BuildContext context) =>
      HelperMethods.post("$listpath/$listId/contributors/", context,
          AddContributorArgs(contributorName));

  static Future<Response> getContributors(int listId,BuildContext context) =>
      HelperMethods.get("$listpath/$listId/contributors/", context);

  static Future<Response> changeRight(int listId, int changedUser,BuildContext context)
      => HelperMethods.put("$listpath/$listId/contributors/$changedUser", context);
}
