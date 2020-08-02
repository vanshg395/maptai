import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maptai_shopping/screens/category_products.dart';
import 'package:maptai_shopping/screens/product_details_screen.dart';

import '../widgets/subcat_widget.dart';
import 'package:http/http.dart' as http;

class SubCategorySelectScreen extends StatefulWidget {
  @override
  _SubCategorySelectScreenState createState() =>
      _SubCategorySelectScreenState();

  final String catId;
  final String catName;

  SubCategorySelectScreen(this.catId, this.catName);
}

class _SubCategorySelectScreenState extends State<SubCategorySelectScreen> {
  List<dynamic> subCats = [];
  List<dynamic> prods = [];
  int _reqCount = 0;
  @override
  void initState() {
    super.initState();
    getData();
    getData2();
  }

  var baseUrl = "https://api.maptai.com/";

  Future<void> getData() async {
    setState(() {
      _reqCount++;
    });
    try {
      final url = baseUrl + 'subcategories/fromCategory/';
      final response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            'category_ids': [widget.catId]
          }));
      if (response.statusCode == 200) {
        final resBody = json.decode(response.body);
        setState(() {
          subCats = resBody['payload'];
        });
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      _reqCount--;
    });
  }

  Future<void> getData2() async {
    setState(() {
      _reqCount++;
    });
    try {
      final url = baseUrl + 'product/search/bycategory/';
      final response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            'category_id': widget.catId,
          }));
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final resBody = json.decode(response.body);
        setState(() {
          prods = resBody;
        });
      }
    } catch (e) {
      print(e);
    }

    setState(() {
      _reqCount--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.catName,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _reqCount != 0
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).primaryColor,
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      'Sub-Categories',
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  Container(
                    height: 200,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: subCats
                          .map(
                            (subcat) => SubcategoryDetailCard(
                                name: subcat['sub_category_file'][0]
                                    ["sub_category"]["sub_categories"],
                                image: subcat['sub_category_file'][0]["image"],
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) =>
                                          SubCatProdPaginatedScreen(
                                        subcat['sub_category_file'][0]
                                            ["sub_category"]["sub_categories"],
                                        subcat['sub_category_file'][0]
                                            ["sub_category"]['id'],
                                      ),
                                    ),
                                  );
                                }),
                          )
                          .toList(),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      'All Products',
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  ...prods
                      .map(
                        (p) => ProductCard(
                          p['product']['id'],
                          p['product']['product_name'],
                          p['product']['product_description'],
                          p['sample_details']['sample_cost'].toString(),
                          p['product']['pictures'].length == 0
                              ? ''
                              : p['product']['pictures'][0]['product_image'],
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name;
  final String description;
  final String price;
  final String image;
  final String id;

  ProductCard(this.id, this.name, this.description, this.price, this.image);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: double.infinity,
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
              width: 140,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                image: DecorationImage(
                  image: NetworkImage(image),
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
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyText1.copyWith(),
                    ),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(),
                    ),
                    Text(
                      '€  $price',
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                            fontWeight: FontWeight.bold,
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
            builder: (ctx) => ProductDetailsScreen(id, name, image),
          ),
        );
      },
    );
  }
}
