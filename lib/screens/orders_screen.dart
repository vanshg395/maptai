import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import 'package:intl/intl.dart';
import 'package:maptai_shopping/providers/wishlist.dart';
import 'package:maptai_shopping/screens/order_details_screen.dart';
import 'package:maptai_shopping/screens/wishlist_screen.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:http/http.dart' as http;

import '../providers/cart.dart';
import '../providers/auth.dart';
import '../widgets/common_button.dart';
import './login_screen.dart';
import './register_screen.dart';
import './cart_screen.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getOrders();
  }

  Future<void> getOrders() async {
    if (!Provider.of<Auth>(context, listen: false).isAuth) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final url = 'https://api.maptai.com/order/';
    try {
      final response = await http.get(
        url,
        headers: {
          HttpHeaders.authorizationHeader:
              Provider.of<Auth>(context, listen: false).token,
        },
      );
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final resBody = json.decode(response.body);
        setState(() {
          _orders = resBody['results'];
        });
      }
    } catch (e) {}
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sample Orders',
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
      ),
      body: Provider.of<Auth>(context, listen: false).isAuth
          ? _isLoading
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
                        if (_orders.length > 0)
                          ..._orders
                              .map(
                                (order) => OrderCard(
                                  order['id'],
                                  order['technical_specification'],
                                  order['terms_of_delivery'],
                                  order['payment_terms'],
                                  order['additional_message'],
                                  order['call_our_executive'],
                                  order['reports_qc_stand'],
                                  order['timestamp'],
                                  order['order_status'],
                                ),
                              )
                              .toList(),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                )
          : Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.account_box,
                    size: 100,
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  CommonButton(
                    bgColor: Theme.of(context).primaryColor,
                    borderColor: Theme.of(context).primaryColor,
                    height: 50,
                    width: 200,
                    fontSize: 16,
                    onPressed: () {
                      Navigator.of(context)
                          .push(
                        MaterialPageRoute(
                          builder: (ctx) => LoginScreen(),
                        ),
                      )
                          .then((value) {
                        if (value != null) {
                          setState(() {});
                          getOrders();
                        }
                      });
                    },
                    borderRadius: 10,
                    title: 'LOGIN',
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  CommonButton(
                    bgColor: Theme.of(context).accentColor,
                    borderColor: Theme.of(context).accentColor,
                    height: 50,
                    width: 200,
                    fontSize: 16,
                    onPressed: () async {
                      Location location = new Location();

                      bool _serviceEnabled;
                      PermissionStatus _permissionGranted;
                      LocationData _locationData;

                      _serviceEnabled = await location.serviceEnabled();
                      if (!_serviceEnabled) {
                        _serviceEnabled = await location.requestService();
                        if (!_serviceEnabled) {
                          return;
                        }
                      }

                      _permissionGranted = await location.hasPermission();
                      if (_permissionGranted == PermissionStatus.denied) {
                        _permissionGranted = await location.requestPermission();
                        if (_permissionGranted != PermissionStatus.granted) {
                          return;
                        }
                      }
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        child: Dialog(
                          child: Container(
                            height: 120,
                            width: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                CircularProgressIndicator(),
                                SizedBox(
                                  width: 20,
                                ),
                                Text('Getting Your Location'),
                              ],
                            ),
                          ),
                        ),
                      );

                      _locationData = await location.getLocation();
                      Navigator.of(context).pop();
                      print(_locationData.latitude);
                      print(_locationData.longitude);
                      final coordinates = Coordinates(
                        _locationData.latitude,
                        _locationData.longitude,
                      );
                      final address = await Geocoder.local
                          .findAddressesFromCoordinates(coordinates);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => RegisterScreen(address.first),
                        ),
                      );
                    },
                    borderRadius: 10,
                    title: 'SIGN UP',
                  ),
                ],
              ),
            ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final String techSpec;
  final String tod;
  final String paymentTerms;
  final String msg;
  final bool coe;
  final bool rqcStand;
  final String dateTime;
  final int status;
  final String id;

  OrderCard(
    this.id,
    this.techSpec,
    this.tod,
    this.paymentTerms,
    this.msg,
    this.coe,
    this.rqcStand,
    this.dateTime,
    this.status,
  );

  @override
  Widget build(BuildContext context) {
    print(status == 0);
    print(status);
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        width: double.infinity,
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
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                children: [
                  TextSpan(
                    text: 'Order placed at: ',
                  ),
                  TextSpan(
                    text: DateFormat('MMM dd, y')
                            .format(DateTime.parse(dateTime)) +
                        ' | ' +
                        TimeOfDay.fromDateTime(DateTime.parse(dateTime))
                            .format(context),
                    style: Theme.of(context).textTheme.bodyText1,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                children: [
                  TextSpan(
                    text: 'Technical Specifications: ',
                  ),
                  TextSpan(
                    text: techSpec,
                    style: Theme.of(context).textTheme.bodyText1,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                children: [
                  TextSpan(
                    text: 'Terms of Delivery: ',
                  ),
                  TextSpan(
                    text: tod,
                    style: Theme.of(context).textTheme.bodyText1,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                children: [
                  TextSpan(
                    text: 'Payment Terms: ',
                  ),
                  TextSpan(
                    text: paymentTerms,
                    style: Theme.of(context).textTheme.bodyText1,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                children: [
                  TextSpan(
                    text: 'Additional Message: ',
                  ),
                  TextSpan(
                    text: msg,
                    style: Theme.of(context).textTheme.bodyText1,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                Text(
                  'Call Our Executive: ',
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Expanded(
                  child: SizedBox(),
                ),
                Icon(
                  coe ? Icons.done : Icons.clear,
                  color: coe ? Colors.green : Colors.red,
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                Text(
                  'Reports QC Stand: ',
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Expanded(
                  child: SizedBox(),
                ),
                Icon(
                  coe ? Icons.done : Icons.clear,
                  color: coe ? Colors.green : Colors.red,
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                children: [
                  TextSpan(
                    text: 'Status: ',
                  ),
                  TextSpan(
                    text: status == 0
                        ? 'Order Created'
                        : status == 1 ? 'Order Processing' : 'Order Completed',
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.7),
                        ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => OrderDetailsScreen(id),
          ),
        );
      },
    );
  }
}
