import 'package:flutter/material.dart';

import 's_c.dart';
import 'dart:async';
import 'package:http/http.dart';

final String productsPath = "products";
class ProductSync
{
   static Future<Response> getProduct(String gtin, BuildContext context)
  =>  HelperMethods.get("$productsPath/$gtin", context);

   static Future<Response> getProducts(String name, int page, BuildContext context)
  =>  HelperMethods.get("$productsPath/$name?page=$page", context);

   static Future<Response> addNewProduct(String gtin, String name, double quantity, String unit, BuildContext context)
  =>  HelperMethods.post("$productsPath/", context, new AddNewProductArgs(gtin, name, unit, quantity));
}