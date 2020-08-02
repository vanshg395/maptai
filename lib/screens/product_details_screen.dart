import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:maptai_shopping/screens/cart_screen.dart';
import 'package:maptai_shopping/utils/currency.dart';
import 'package:maptai_shopping/widgets/common_button.dart';
import 'package:maptai_shopping/widgets/common_field.dart';
import 'package:maptai_shopping/widgets/related_products.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import './bulk_inquiry_screen.dart';
import '../widgets/image_slider.dart';
import '../providers/wishlist.dart';
import '../providers/auth.dart';
import '../providers/cart.dart';

class ProductDetailsScreen extends StatefulWidget {
  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();

  final String id;
  final String name;
  final String url;

  ProductDetailsScreen(this.id, this.name, this.url);
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  GlobalKey<FormState> _formKey = GlobalKey();
  bool _isLoading = false;
  List<dynamic> _data = [];
  List<dynamic> _data1 = [];
  CartItem cart;
  bool _cartItemExists = false;
  int quantity = 1;
  FlutterToast flutterToast;
  Map<String, String> _productEnquiry = {"message": "", "product": ""};
  double _convertedPrice = 0;
  String _convertedPriceSymbol = '';
  double rate;

  @override
  void initState() {
    super.initState();
    getData();
    flutterToast = FlutterToast(context);
  }

  var baseUrl = "https://api.maptai.com/";

  Future<void> getData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final url = baseUrl + 'product/productDetail/?product_id=${widget.id}';
      final response = await http.get(url);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final resBody = json.decode(response.body);

        cart = Provider.of<Cart>(context, listen: false).getifExist(widget.id);
        _data = resBody['payload'];
        print(cart.quantity);
        if (cart.quantity > 0) {
          setState(() {
            _cartItemExists = true;
          });
        }
      }
    } catch (e) {
      print(e);
    }
    getRelatedproducts();
  }

  Future<void> getRelatedproducts() async {
    try {
      final url = baseUrl + 'product/related/show/';
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          {"product_id": widget.id},
        ),
      );
      print('--------------');
      print(url);
      print(widget.id);
      print('--------------');
      print(response.statusCode);
      if (response.statusCode == 200) {
        final resBody = json.decode(response.body);
        setState(() {
          _data1 = resBody['payload'];
        });
      }
    } catch (e) {
      print(e);
    }
    getCurrency();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    try {
      Navigator.of(context).pop();
      showDialog(
        barrierDismissible: false,
        context: context,
        child: Dialog(
          child: Container(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
      await Provider.of<Cart>(context, listen: false).addItem(
        Provider.of<Auth>(context, listen: false).token,
        widget.id,
        quantity,
        widget.name,
      );
      Navigator.of(context).pop();
      setState(() {
        _cartItemExists = true;
      });
      Widget toast = Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.grey[300],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check),
            SizedBox(
              width: 12.0,
            ),
            Text("Item added to Cart"),
          ],
        ),
      );

      flutterToast.showToast(
        child: toast,
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 2),
      );
    } catch (e) {
      print(e);
      await showDialog(
        context: context,
        child: AlertDialog(
          title: Text('Error'),
          content: Text('Something went wrong. Please try again later.'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _submitQuery() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    _productEnquiry["product"] = widget.id;
    try {
      final url = baseUrl + 'message/user/create/';
      final response = await http.post(url,
          headers: {
            'Authorization': Provider.of<Auth>(context, listen: false).token,
            'Content-Type': 'application/json'
          },
          body: json.encode(_productEnquiry));
      print(response.statusCode);
      if (response.statusCode == 201) {
        Navigator.of(context).pop();
        Widget toast = Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: Colors.grey[300],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check),
              SizedBox(
                width: 12.0,
              ),
              Text("Inquiry Sent"),
            ],
          ),
        );

        flutterToast.showToast(
          child: toast,
          gravity: ToastGravity.BOTTOM,
          toastDuration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _addToCart() async {
    await showDialog(
      context: context,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: Text(
                      'Add to Cart',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    padding: EdgeInsets.all(20),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _data[0]["product"]["product_name"],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                '$_convertedPriceSymbol ${_convertedPrice.toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).primaryColor,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 6,
                          spreadRadius: 2,
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Disclaimer',
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Sample Prices are excluding Shipping and Custom charges. (Shipping and Custom Charges will be calculated on checkout.',
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: CommonField(
                      bgColor: Colors.white,
                      borderColor: Colors.grey,
                      borderRadius: 10,
                      placeholder: 'Quantity',
                      keyboardType: TextInputType.numberWithOptions(
                        signed: false,
                        decimal: false,
                      ),
                      validator: (value) {
                        if (value == '') {
                          return 'This field is required';
                        }
                      },
                      onSaved: (value) {
                        quantity = int.parse(value);
                      },
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Center(
                    child: CommonButton(
                      title: 'Add',
                      onPressed: _submit,
                      bgColor: Theme.of(context).primaryColor,
                      borderColor: Theme.of(context).primaryColor,
                      borderRadius: 10,
                      fontSize: 18,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _raiseGeneralInquiry() async {
    await showDialog(
      context: context,
      child: StatefulBuilder(
        builder: (ctx, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: Text(
                        'General Inquiry',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: CommonField(
                        bgColor: Colors.white,
                        borderColor: Colors.grey,
                        borderRadius: 10,
                        placeholder: 'Enter your Message',
                        maxLines: 5,
                        topPadding: 20,
                        validator: (value) {
                          if (value == '') {
                            return 'This field is required';
                          }
                        },
                        onSaved: (value) {
                          _productEnquiry["message"] = value;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : CommonButton(
                              title: 'Submit',
                              onPressed: () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                await _submitQuery();
                                setState(() {
                                  _isLoading = false;
                                });
                              },
                              bgColor: Theme.of(context).primaryColor,
                              borderColor: Theme.of(context).primaryColor,
                              borderRadius: 10,
                              fontSize: 18,
                            ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getCurrency() async {
    final response = await http.get(
        'http://api.ipapi.com/api/check?access_key=95235ad01973864b1878b2ff1c4e9bc6');
    print(response.statusCode);
    if (response.statusCode == 200) {
      final resBody = json.decode(response.body);
      final url =
          'http://data.fixer.io/api/latest?access_key=ca5a0ea8cb6b2621d111b7c90ac2dcad&base=EUR&symbols=INR,BDT,USD,NGN';
      final response2 = await http.get(url);
      print(response2.statusCode);
      print(response2.body);
      if (response2.statusCode == 200) {
        final resBody2 = json.decode(response2.body);
        if (resBody['country_code'] == 'IN') {
          rate = resBody2['rates']['INR'];
          _convertedPrice = _data[0]["sample_details"]["sample_cost"] * rate;
          _convertedPriceSymbol = currency['INR']['symbol'];
        } else if (resBody['country_code'] == 'BD') {
          rate = resBody2['rates']['BDT'];
          _convertedPrice = _data[0]["sample_details"]["sample_cost"] * rate;
          _convertedPriceSymbol = currency['BDT']['symbol'];
        } else if (resBody['country_code'] == 'NG') {
          rate = resBody2['rates']['NGN'];
          _convertedPrice = _data[0]["sample_details"]["sample_cost"] * rate;
          _convertedPriceSymbol = currency['NGN']['symbol'];
        } else {
          rate = resBody2['rates']['USD'];
          _convertedPrice = _data[0]["sample_details"]["sample_cost"] * rate;
          _convertedPriceSymbol = currency['USD']['symbol'];
        }
      } else {
        _convertedPrice = _data[0]["sample_details"]["sample_cost"];
        _convertedPriceSymbol = '\€';
      }
    } else {
      _convertedPrice = _data[0]["sample_details"]["sample_cost"];
      _convertedPriceSymbol = '\€';
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('>>>>>>>');
    // print(_data[0]["bulkorder_details"]["bulk_order_price"]);
    print('>>>>>>>');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Item Information',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: <Widget>[
          if (Provider.of<Auth>(context, listen: false).isAuth)
            IconButton(
              icon: Icon(
                Provider.of<Wishlist>(context, listen: false)
                            .items
                            .where((element) => element.productId == widget.id)
                            .length ==
                        1
                    ? Icons.favorite
                    : Icons.favorite_border,
              ),
              onPressed: () async {
                if (Provider.of<Wishlist>(context, listen: false)
                        .items
                        .where((element) => element.productId == widget.id)
                        .length ==
                    1) {
                  await Provider.of<Wishlist>(context, listen: false)
                      .removeItem(
                          Provider.of<Auth>(context, listen: false).token,
                          widget.id,
                          widget.name);
                  setState(() {});
                  Widget toast = Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      color: Colors.grey[300],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check),
                        SizedBox(
                          width: 12.0,
                        ),
                        Text("Removed from Wishlist"),
                      ],
                    ),
                  );

                  flutterToast.showToast(
                    child: toast,
                    gravity: ToastGravity.BOTTOM,
                    toastDuration: Duration(seconds: 2),
                  );
                } else {
                  await Provider.of<Wishlist>(context, listen: false).addItem(
                    Provider.of<Auth>(context, listen: false).token,
                    widget.id,
                    widget.name,
                    _data[0]["product"]["product_description"],
                    _data[0]["bulkorder_details"]["bulk_order_price"]
                        .toString(),
                  );
                  setState(() {});
                  Widget toast = Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      color: Colors.grey[300],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check),
                        SizedBox(
                          width: 12.0,
                        ),
                        Text("Added to Wishlist"),
                      ],
                    ),
                  );

                  flutterToast.showToast(
                    child: toast,
                    gravity: ToastGravity.BOTTOM,
                    toastDuration: Duration(seconds: 2),
                  );
                }
              },
            ),
          if (Provider.of<Auth>(context, listen: false).isAuth)
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
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).primaryColor,
                ),
              ),
            )
          : SafeArea(
              bottom: false,
              child: Container(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ImageSlider(_data[0]["product"]["pictures"],
                          _data[0]["product"]["videos"]),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: double.infinity,
                        margin:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                        padding: EdgeInsets.all(20),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    _data[0]["product"]["product_name"],
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    '$_convertedPriceSymbol ${_convertedPrice.toStringAsFixed(_convertedPriceSymbol == 'Rs' ? 0 : 2)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .copyWith(),
                                      children: [
                                        TextSpan(
                                          text: 'Minimum Order: ',
                                        ),
                                        TextSpan(
                                          text:
                                              '${_data[0]["product"]["minimum_order_quantity"].toString()} ${_data[0]["bulkorder_details"]["bulk_order_price_unit"]}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.share),
                              onPressed: () async {
                                await Share.share(
                                  'https://onlala.com/product.html?id=${widget.id}',
                                  subject: 'Share Product',
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: double.infinity,
                        margin:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                        padding: EdgeInsets.all(20),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Sample Details',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Sample Price',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              color: Theme.of(context).canvasColor,
                              padding: EdgeInsets.all(10),
                              width: double.infinity,
                              child: Text(
                                '$_convertedPriceSymbol ${(_data[0]["sample_details"]["sample_cost"] * rate).toStringAsFixed(_convertedPriceSymbol == 'Rs' ? 0 : 2)} ',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Order Lead Time',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              color: Theme.of(context).canvasColor,
                              padding: EdgeInsets.all(10),
                              width: double.infinity,
                              child: Text(
                                '${_data[0]["sample_details"]["sample_from_time_range"]} - ${_data[0]["sample_details"]["sample_to_time_range"]} Days',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'HS Code',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              color: Theme.of(context).canvasColor,
                              padding: EdgeInsets.all(10),
                              width: double.infinity,
                              child: Text(
                                '${_data[0]["sample_details"]["hs_code"]}',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Sample Dimension (Courier)',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              color: Theme.of(context).canvasColor,
                              padding: EdgeInsets.all(10),
                              width: double.infinity,
                              child: Text(
                                '${_data[0]["sample_details"]["sample_dimension_length"]} X ${_data[0]["sample_details"]["sample_dimension_breadth"]} X ${_data[0]["sample_details"]["sample_dimension_height"]} ${_data[0]["sample_details"]["sample_dimension_unit"]}',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Sample Weight (Courier)',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              color: Theme.of(context).canvasColor,
                              padding: EdgeInsets.all(10),
                              width: double.infinity,
                              child: Text(
                                '${_data[0]["sample_details"]["sample_weight"]} ${_data[0]["sample_details"]["sample_weight_unit"]}',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Sample Policy',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              color: Theme.of(context).canvasColor,
                              padding: EdgeInsets.all(10),
                              width: double.infinity,
                              child: Text(
                                '${_data[0]["sample_details"]["sample_policy"]}',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: double.infinity,
                        margin:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                        padding: EdgeInsets.all(20),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Quick Details',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(),
                                children: [
                                  TextSpan(
                                    text: 'Model Number: ',
                                  ),
                                  TextSpan(
                                    text: '${_data[0]["product"]["model_no"]}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              '${_data[0]["product"]["product_description"]}',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: double.infinity,
                        margin:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                        padding: EdgeInsets.all(20),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Bulk Details',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Price in $_convertedPriceSymbol (Negotiable)',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              color: Theme.of(context).canvasColor,
                              padding: EdgeInsets.all(10),
                              width: double.infinity,
                              // child: Text(
                              //   '${(double.parse(_data[0]["bulkorder_details"]["bulk_order_price"]) * rate).toStringAsFixed(_convertedPriceSymbol == 'Rs' ? 0 : 2)}/${_data[0]["bulkorder_details"]["bulk_order_price_unit"]}    ${_data[0]["bulkorder_details"]["bulk_order_price_type"]}',
                              //   style: Theme.of(context).textTheme.bodyText1,
                              // ),
                              child: RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyText1,
                                  children: [
                                    // TextSpan(
                                    //   text:
                                    //       '${(double.parse(_data[0]["bulkorder_details"]["bulk_order_price"]) * rate).toStringAsFixed(_convertedPriceSymbol == 'Rs' ? 0 : 2)}/${_data[0]["bulkorder_details"]["bulk_order_price_unit"]}    ',
                                    //   style: Theme.of(context)
                                    //       .textTheme
                                    //       .bodyText1
                                    //       .copyWith(
                                    //           color: Theme.of(context)
                                    //               .primaryColor),
                                    // ),
                                    TextSpan(
                                      text:
                                          '${_data[0]["bulkorder_details"]["bulk_order_price_type"]}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Order Lead Time',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              color: Theme.of(context).canvasColor,
                              padding: EdgeInsets.all(10),
                              width: double.infinity,
                              child: Text(
                                '${_data[0]["bulkorder_details"]["bulk_order_from_time_range"]} to ${_data[0]["bulkorder_details"]["bulk_order_to_time_range"]} Days',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Units Per Carton',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              color: Theme.of(context).canvasColor,
                              padding: EdgeInsets.all(10),
                              width: double.infinity,
                              child: Text(
                                '${_data[0]["product"]["quantity_per_carton"]}',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Cart Dimension',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              color: Theme.of(context).canvasColor,
                              padding: EdgeInsets.all(10),
                              width: double.infinity,
                              child: Text(
                                '${_data[0]["carton_details"]["carton_dimension_length"]} x ${_data[0]["carton_details"]["carton_dimension_breadth"]} x ${_data[0]["carton_details"]["carton_dimension_height"]} ${_data[0]["carton_details"]["carton_dimension_unit"]}',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Sample Weight',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              color: Theme.of(context).canvasColor,
                              padding: EdgeInsets.all(10),
                              width: double.infinity,
                              child: Text(
                                '${_data[0]["carton_details"]["carton_weight"]} ${_data[0]["carton_details"]["carton_weight_unit"]}',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: double.infinity,
                        margin:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                        padding: EdgeInsets.all(20),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Payment Details',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Payment Method',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              color: Theme.of(context).canvasColor,
                              padding: EdgeInsets.all(10),
                              width: double.infinity,
                              child: Text(
                                '${_data[0]["product"]["payment_method"]}',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Country Port',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              color: Theme.of(context).canvasColor,
                              padding: EdgeInsets.all(10),
                              width: double.infinity,
                              child: Text(
                                '${_data[0]["bulkorder_details"]["bulk_order_port"]}',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Technology Transfer',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              color: Theme.of(context).canvasColor,
                              padding: EdgeInsets.all(10),
                              width: double.infinity,
                              child: Text(
                                _data[0]["product"]["tech_transfer_investment"]
                                    ? 'Yes'
                                    : 'No',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: double.infinity,
                        margin:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).accentColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 6,
                              spreadRadius: 2,
                              color: Colors.black.withOpacity(0.1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Disclaimer',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Sample Prices are excluding Shipping and Custom charges. (Shipping and Custom Charges will be calculated on checkout.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      if (_data1.length > 0)
                        SizedBox(
                          height: 30,
                        ),
                      if (_data1.length > 0) RelatedProducts(_data1),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: !Provider.of<Auth>(context, listen: false).isAuth
          ? null
          : Container(
              height: 60,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 2, 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'General Inquiry',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                      ),
                      onTap: _raiseGeneralInquiry,
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(2, 0, 2, 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Bulk Inquiry',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => BulkInquiryScreen(
                              _data[0]["product"]["product_name"],
                              widget.id,
                              _data[0]["product"]["product_description"],
                              _data[0]["sample_details"]["sample_cost"]
                                  .toString(),
                              widget.url,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      child: Container(
                          margin: EdgeInsets.fromLTRB(2, 0, 10, 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Add to Cart',
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.bodyText1.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                          )),
                      onTap: _addToCart,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
