import 's_c.dart';
import 'dart:async';
import 'package:http/http.dart';

final String productsPath = "products";
class ProductSync
{
   static Future<Response> getProduct(String gtin)
  =>  HelperMethods.get("$productsPath/$gtin");

   static Future<Response> getProducts(String name, int page)
  =>  HelperMethods.get("$productsPath/$name?page=$page");

   static Future<Response> addNewProduct(String gtin, String name, double quantity, String unit)
  =>  HelperMethods.post("$productsPath/", new AddNewProductArgs(gtin, name, unit, quantity));
}