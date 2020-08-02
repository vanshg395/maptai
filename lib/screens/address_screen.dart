import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:maptai_shopping/providers/wishlist.dart';
import 'package:maptai_shopping/screens/add_address_screen.dart';
import 'package:maptai_shopping/screens/edit_address_screen.dart';
import 'package:maptai_shopping/screens/wishlist_screen.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:http/http.dart' as http;

import '../providers/auth.dart';
import '../providers/cart.dart';
import '../widgets/common_button.dart';
import './login_screen.dart';
import './register_screen.dart';
import './cart_screen.dart';

class AddressScreen extends StatefulWidget {
  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  bool _isLoading = false;
  List<dynamic> _addresses = [];

  @override
  void initState() {
    super.initState();
    getAddresses();
  }

  Future<void> getAddresses() async {
    if (!Provider.of<Auth>(context, listen: false).isAuth) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final url = 'https://api.maptai.com/business/buyer/postal_address';
    try {
      final response = await http.get(
        url,
        headers: {
          HttpHeaders.authorizationHeader:
              Provider.of<Auth>(context, listen: false).token,
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        final resBody = json.decode(response.body);
        setState(() {
          _addresses = resBody['payload'];
        });
        print(_addresses);
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
          'Shipping Addresses',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              alignment: _addresses.length == 0
                  ? Alignment.center
                  : Alignment.topCenter,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: _addresses.length == 0
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    ..._addresses
                        .map(
                          (address) => AddressCard(
                            address['id'],
                            address['postal_address1'] +
                                '  ' +
                                address['postal_address2'] +
                                '  ' +
                                address['postal_address3'],
                            address['postal_landmark'],
                            address['postal_city'],
                            address['postal_state'],
                            address['postal_country'],
                            address['postal_code'],
                            getAddresses,
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
      bottomNavigationBar: GestureDetector(
        child: Container(
          height: 60,
          color: Theme.of(context).primaryColor,
          alignment: Alignment.center,
          child: Text(
            'Add Address',
            style: Theme.of(context).textTheme.bodyText1.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                ),
          ),
        ),
        onTap: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (ctx) => AddAddressScreen(),
            ),
          )
              .then((value) {
            if (value != null) {
              getAddresses();
            }
          });
        },
      ),
    );
  }
}

class AddressCard extends StatefulWidget {
  final String id;
  final String addressLine;
  final String landmark;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final Function refresh;

  AddressCard(
    this.id,
    this.addressLine,
    this.landmark,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.refresh,
  );

  @override
  _AddressCardState createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  bool _isLoading = false;
  FlutterToast flutterToast;

  @override
  void initState() {
    super.initState();
    flutterToast = FlutterToast(context);
  }

  Future<void> deleteAddress(String id) async {
    setState(() {
      _isLoading = true;
    });
    final url = 'https://api.maptai.com/business/buyer/postal_address/delete/';
    try {
      final response = await http.post(
        url,
        headers: {
          HttpHeaders.authorizationHeader:
              Provider.of<Auth>(context, listen: false).token,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: json.encode({
          'postaldetails_id': id,
        }),
      );
      print(response.statusCode);
      if (response.statusCode == 204) {
        widget.refresh();
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
              Text("Address Deleted"),
            ],
          ),
        );

        flutterToast.showToast(
          child: toast,
          gravity: ToastGravity.BOTTOM,
          toastDuration: Duration(seconds: 2),
        );
      }
    } catch (e) {}
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
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
                        text: 'Address Line: ',
                      ),
                      TextSpan(
                        text: widget.addressLine,
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
                        text: 'Landmark: ',
                      ),
                      TextSpan(
                        text: widget.landmark,
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
                        text: 'City: ',
                      ),
                      TextSpan(
                        text: widget.city,
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
                        text: 'State: ',
                      ),
                      TextSpan(
                        text: widget.state,
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
                        text: 'Country: ',
                      ),
                      TextSpan(
                        text: widget.country,
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
                        text: 'Postal Code: ',
                      ),
                      TextSpan(
                        text: widget.postalCode,
                        style: Theme.of(context).textTheme.bodyText1,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: <Widget>[
              InkWell(
                child: Icon(
                  Icons.edit,
                  color: Theme.of(context).primaryColor,
                ),
                onTap: () {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (ctx) => EditAddressScreen(
                        widget.id,
                        widget.addressLine,
                        widget.landmark,
                        widget.city,
                        widget.state,
                        widget.country,
                        widget.postalCode,
                      ),
                    ),
                  )
                      .then((value) {
                    if (value != null) {
                      widget.refresh();
                    }
                  });
                },
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                child: Icon(
                  Icons.delete,
                  color: _isLoading ? Colors.grey : Colors.red,
                ),
                onTap: _isLoading ? () {} : () => deleteAddress(widget.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
