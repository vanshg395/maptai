import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:maptai_shopping/screens/product_details_screen.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String id;

  OrderDetailsScreen(this.id);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  List<dynamic> _orderData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    setState(() {
      _isLoading = true;
    });
    final url = 'https://api.maptai.com/order/items/?order_id=${widget.id}';
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader:
            Provider.of<Auth>(context, listen: false).token,
      },
    );
    if (response.statusCode == 200) {
      final resBody = json.decode(response.body);
      setState(() {
        _orderData = resBody['payload'];
      });
      print(_orderData);
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
          'Sample Order Items',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    if (_orderData.length > 0)
                      ..._orderData[0]['order_items']
                          .map(
                            (item) => GestureDetector(
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                      color: Colors.black.withOpacity(0.1),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  leading: item['product_images'].length == 0
                                      ? null
                                      : CachedNetworkImage(
                                          imageUrl: item['product_images'][0]
                                              ['product_image'],
                                        ),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 30),
                                  title:
                                      Text(item['item_name']['product_name']),
                                  trailing: Text('x${item['quantity']}'),
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) => ProductDetailsScreen(
                                        item['cart_item']['id'],
                                        item['item_name']['product_name'],
                                        ''),
                                  ),
                                );
                              },
                            ),
                          )
                          .toList(),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
