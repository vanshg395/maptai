import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:maptai_shopping/utils/http_exception.dart';

class Wishlist with ChangeNotifier {
  List<WishItem> _items = [];
  String baseUrl = "https://api.maptai.com/";
  List<WishItem> get items {
    return _items;
  }

  int get numberOfwishItems {
    return items.length;
  }

  Future<void> addItem(
    String jwtToken,
    String wishItem,
    String productName,
    String desc,
    String price,
  ) async {
    try {
      print('>>>>>>>>>>>>>>addwishItems');
      final url = baseUrl + 'cart/wishlist/add/';
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': jwtToken
          },
          body: json.encode({
            "items_list": [wishItem]
          }));
      print(response.statusCode);
      print(price);
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        _items.add(
          WishItem(
            name: productName,
            productId: wishItem,
            description: desc,
            price: price,
          ),
        );
        notifyListeners();
      } else if (response.statusCode == 401) {
        throw HttpException('Please logout and login');
      } else {
        throw HttpException('Error');
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> removeItem(
      String jwtToken, String wishItem, String productName) async {
    try {
      print('>>>>>>>>>>>>>>removewishItems');
      final url = baseUrl + 'cart/wishlist/delete/';
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': jwtToken
          },
          body: json.encode({"product_id": wishItem}));
      print(response.statusCode);
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        _items.removeWhere((item) => item.productId == wishItem);
        notifyListeners();
      } else if (response.statusCode == 401) {
        throw HttpException('Please logout and login');
      } else if (response.statusCode == 404) {
        throw HttpException('Looks like product already deleted from wishlist');
      } else {
        throw HttpException('Error');
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> getItems(String jwtToken) async {
    try {
      print('>>>>>>>>>>>>>>getwishItems');
      final url = baseUrl + 'cart/wishlist/add/';
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': jwtToken
        },
      );
      print(url);
      print(jwtToken);
      print(response.statusCode.toString() + "> Wishlist");
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body)["payload"];
        print(responseBody["wishlist"][0]["wished_item"][0]);
        _items = [];
        for (var i = 0;
            i < responseBody["wishlist"][0]["wished_item"].length;
            i++) {
          _items.add(
            WishItem(
              name: responseBody["wishlist"][0]["wished_item"][i]
                  ["product_name"],
              description: responseBody["wishlist"][0]["wished_item"][i]
                  ["product_description"],
              price: responseBody["wishlist"][0]["wished_item"][i]["price"],
              productId: responseBody["wishlist"][0]["wished_item"][i]["id"],
            ),
          );
        }
      } else if (response.statusCode == 401) {
        throw HttpException('Please logout and login');
      } else if (response.statusCode == 204) {
        print("No elements");
      } else {
        throw HttpException('Error');
      }
    } catch (e) {
      throw e;
    }
  }

  void clearLocalWishlist() {
    _items = [];
  }
}

class WishItem {
  final String name;
  final String description;
  final String price;
  final String productId;

  WishItem({
    this.name,
    this.description,
    this.price,
    this.productId,
  });
}
