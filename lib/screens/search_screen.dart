import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import 'package:maptai_shopping/providers/wishlist.dart';
import 'package:maptai_shopping/screens/wishlist_screen.dart';
import 'package:provider/provider.dart';
import 'package:maptai_shopping/widgets/search_widget.dart';
import 'package:http/http.dart' as http;
import 'package:websafe_svg/websafe_svg.dart';

import '../providers/cart.dart';
import './cart_screen.dart';
import '../widgets/common_field.dart';
import '../providers/auth.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController(text: '');
  List<dynamic> _data = [];

  bool _isLoading = false;

  var baseUrl = "https://api.maptai.com/";

  Future<void> _search(String searchKey) async {
    print("searhc");

    setState(() {
      _isLoading = true;
    });
    try {
      final url = baseUrl + 'product/search/?search=$searchKey';
      final response = await http.get(url);
      print(response.statusCode);
      if (response.statusCode == 200) {
        _data = [];
        final resBody = json.decode(response.body)["payload"];

        for (var i = 0; i < resBody.length; i++) {
          var image = '';
          for (var j = 0; j < resBody[i]["product_image"].length; j++) {
            if (resBody[i]["product_image"][j]["image_name"] ==
                "Primary Image") {
              image = resBody[i]["product_image"][j]["product_image"];
              break;
            }
          }
          var price = resBody[i]["sample_details"]["sample_cost"].toString();

          _data.add({
            "image": image,
            "product_name": resBody[i]["product"]["product_name"].toString(),
            "product_des": resBody[i]["product"]["product_description"],
            "price": price.toString(),
            "id": resBody[i]["product"]["id"]
          });
        }
        print(_data);
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: <Widget>[
          if (Provider.of<Auth>(context).isAuth)
            IconButton(
              icon: Badge(
                showBadge: Provider.of<Wishlist>(context).numberOfwishItems == 0
                    ? false
                    : true,
                animationType: BadgeAnimationType.scale,
                animationDuration: Duration(milliseconds: 200),
                child: Icon(Icons.favorite),
                badgeContent: Text(
                  Provider.of<Wishlist>(context).numberOfwishItems.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => WishlistScreen(),
                  ),
                );
              },
            ),
          if (Provider.of<Auth>(context).isAuth)
            IconButton(
              icon: Badge(
                showBadge: Provider.of<Cart>(context).numberOfCartItems == 0
                    ? false
                    : true,
                animationType: BadgeAnimationType.scale,
                animationDuration: Duration(milliseconds: 200),
                child: Icon(Icons.shopping_cart),
                badgeContent: Text(
                  Provider.of<Cart>(context).numberOfCartItems.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => CartScreen(),
                  ),
                );
              },
            ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    child: CommonField(
                      controller: _searchController,
                      bgColor: Colors.white,
                      borderColor: Colors.grey,
                      borderRadius: 10,
                      placeholder: 'Enter Keywords',
                      suffixIcon: InkWell(
                        child: Icon(Icons.cancel),
                        onTap: () {
                          if (_searchController.text != '') {
                            setState(() {
                              _searchController.text = '';
                            });
                          } else {
                            FocusScope.of(context).unfocus();
                          }
                        },
                      ),
                      onFieldSubmitted: (value) {
                        _search(value);
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _search(_searchController.text);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              alignment:
                  _data.length == 0 ? Alignment.center : Alignment.topCenter,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: _data.length == 0
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: <Widget>[
                    SearchProducts(_data),
                  ],
                ),
              ),
            ),
    );
  }
}
