import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:maptai_shopping/utils/http_exception.dart';

class Cart with ChangeNotifier {
  List<CartItem> _items = [];
  String baseUrl = "https://api.maptai.com/";

  List<CartItem> get items {
    return _items;
  }

  int get numberOfCartItems {
    return items.length;
  }

  CartItem getifExist(String id) {
    if (_items.where((element) => element.productId == id).length > 0) {
      return _items.where((element) => element.productId == id).toList()[0];
    }
    return CartItem(cartId: '', quantity: 0, productId: '');
  }

  Future<void> addItem(String jwtToken, String cartItem, int quantity,
      String productName) async {
    print(cartItem);
    try {
      print('>>>>>>>>>>>>>>addCartItems');
      final url = baseUrl + 'cart/cartlist/add/';
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': jwtToken
          },
          body: json.encode({"cart_item": cartItem, "quantity": quantity}));
      print(response.statusCode.toString() + ">>cart");
      print(response.body.toString() + ">>cart");

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final responseBody = json.decode(response.body)["payload"];
        _items.add(
          CartItem(
            name: productName,
            cartId: responseBody["id"],
            productId: cartItem,
            quantity: responseBody["quantity"],
          ),
        );
        print(responseBody["id"]);
        getItems(jwtToken);
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
      String jwtToken, String cartItem, String productName) async {
    try {
      print('>>>>>>>>>>>>>>removeCartItems');
      final url = baseUrl + 'cart/cartlist/delete/';
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': jwtToken
          },
          body: json.encode({"id": cartItem}));
      print('------------------------');
      print(cartItem);
      print(url);
      print(json.encode({"id": cartItem}));

      print('------------------------');
      print(response.statusCode);
      print(response.body);
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        _items.removeWhere((item) => item.anotherId == cartItem);
        notifyListeners();
      } else if (response.statusCode == 401) {
        throw HttpException('Please logout and login');
      } else if (response.statusCode == 404) {
        throw HttpException('Looks like product already deleted from wishlist');
      } else {
        throw HttpException('Error');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getItems(String jwtToken) async {
    _items = [];
    try {
      print('>>>>>>>>>>>>>>getCartItems');
      final url = baseUrl + 'cart/cartlist/add/';
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': jwtToken
        },
      );
      print('>>>>>>>>>>>>>>>>>');
      print(url);
      print(jwtToken);
      print('>>>>>>>>>>>>>>>>>');

      print(response.statusCode.toString() + ">>cart");
      print(response.body);
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final responseBody = json.decode(response.body)["payload"];
        for (var i = 0; i < responseBody["cart_details"].length; i++) {
          String productImage = '';
          String productBulkPrice = '';
          String productDescription = '';
          for (var j = 0; j < responseBody["additional_details"].length; j++) {
            print(responseBody["cart_details"][i]["cart_item"]);
            print(responseBody["additional_details"][j]["product"]["id"]);

            if (responseBody["cart_details"][i]["cart_item"] ==
                responseBody["additional_details"][j]["product"]["id"]) {
              if (responseBody["additional_details"][j]["product_image"]
                      .length >
                  0) {
                productImage = responseBody["additional_details"][j]
                    ["product_image"][0]["product_image"];
              }
              productBulkPrice = responseBody["additional_details"][j]
                      ["sample_details"]["sample_cost"]
                  .toString();
              print(responseBody["additional_details"][j]["bulkorder_details"]
                  ["bulk_order_price"]);
              print(productBulkPrice);
              productDescription = responseBody["additional_details"][j]
                  ["product"]["product_description"];
            }
          }
          _items.add(
            CartItem(
                name: responseBody["cart_details"][i]["item_name"]
                    ["product_name"],
                cartId: responseBody["cart_details"][i]["cart"],
                productId: responseBody["cart_details"][i]["cart_item"],
                quantity: responseBody["cart_details"][i]["quantity"],
                image: productImage,
                description: productDescription,
                price: productBulkPrice,
                anotherId: responseBody["cart_details"][i]["id"]),
          );
        }
      } else if (response.statusCode == 401) {
        throw HttpException('Please logout and login');
      } else if (response.statusCode == 404) {
        print(response.body);
        print("No cart list");
      } else {
        print(response.body);
        print("No cart list");
      }
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  void clearLocalCart() {
    _items = [];
  }
}

class CartItem {
  final String name;
  final String description;
  final String image;
  final String price;
  final String cartId;
  final String productId;
  final int quantity;
  final String anotherId;

  CartItem({
    this.name,
    this.productId,
    this.description,
    this.price,
    this.cartId,
    this.quantity,
    this.image,
    this.anotherId,
  });
}
