import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import './product_details_screen.dart';

class CountryProductsScreen extends StatefulWidget {
  @override
  _CountryProductsScreenState createState() => _CountryProductsScreenState();

  final String country;

  CountryProductsScreen(this.country);
}

class _CountryProductsScreenState extends State<CountryProductsScreen> {
  List<dynamic> _displayedItems = [];
  ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  FlutterToast flutterToast;

  int offset = 0;
  int limit = 9;

  @override
  void initState() {
    super.initState();
    getData();
    flutterToast = FlutterToast(context);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    setState(() {
      _isLoading = true;
    });
    final url =
        'https://api.maptai.com/product/buyerHomePageWebsite/?country=${widget.country}';
    try {
      final response = await http.post(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: json.encode({
          'offset': offset,
          'limit': limit,
        }),
      );
      print(response.statusCode);
      print(response.body);
      List<dynamic> _newItems = [];
      if (response.statusCode == 200) {
        final resBody = json.decode(response.body);
        _newItems = resBody['payload']['data'];
        if (_newItems.length != 0) {
          offset += 10;
          limit += 10;
          setState(() {
            _displayedItems += _newItems;
          });
        } else {
          Widget toast = Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: Colors.grey[300],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error),
                SizedBox(
                  width: 12.0,
                ),
                Text("No More Products"),
              ],
            ),
          );

          flutterToast.showToast(
            child: toast,
            gravity: ToastGravity.BOTTOM,
            toastDuration: Duration(seconds: 2),
          );
        }
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
          '${widget.country} Products',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (!_isLoading &&
                scrollInfo.metrics.pixels >
                    scrollInfo.metrics.maxScrollExtent + 100) {
              print('hey');
              getData();
              setState(() {
                _isLoading = true;
              });
              _scrollController.animateTo(
                scrollInfo.metrics.maxScrollExtent + 100,
                duration: Duration(milliseconds: 100),
                curve: Curves.linear,
              );
            }
          },
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (ctx, i) => ProductCard(
                    _displayedItems[i]['product_name'],
                    _displayedItems[i]['product_description'],
                    _displayedItems[i]['product_image'].length == 0
                        ? ''
                        : _displayedItems[i]['product_image'][0]
                            ['product_image'],
                    _displayedItems[i]['minimum_order_quantity'].toString(),
                    _displayedItems[i]['id'],
                  ),
                  itemCount: _displayedItems.length,
                ),
              ),
              if (_isLoading)
                SafeArea(
                  child: Container(
                    margin: EdgeInsets.all(30),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String productName;
  final String description;
  final String url;
  final String moq;
  final String id;

  ProductCard(this.productName, this.description, this.url, this.moq, this.id);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: 300,
        height: 100,
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
        child: Row(
          children: <Widget>[
            Container(
              width: 100,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(url),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyText1.copyWith(),
                    ),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(),
                    ),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyText1.copyWith(),
                        children: [
                          TextSpan(
                            text: 'Minimum Order: ',
                          ),
                          TextSpan(
                            text: '$moq',
                            style:
                                Theme.of(context).textTheme.subtitle2.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => ProductDetailsScreen(id, productName, url),
          ),
        );
      },
    );
  }
}
