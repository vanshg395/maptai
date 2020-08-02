import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:maptai_shopping/screens/address_screen.dart';
import 'package:maptai_shopping/screens/bulk_inquiry_status_screen.dart';
import 'package:maptai_shopping/screens/orders_screen.dart';
import 'package:maptai_shopping/screens/tnc_screen.dart';
import 'package:maptai_shopping/screens/wishlist_screen.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import './login_screen.dart';
import './register_screen.dart';
import './cart_screen.dart';
import './edit_profile_screen.dart';
import '../widgets/common_button.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';
import 'package:http/http.dart' as http;

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String baseUrl = "https://api.maptai.com/";
  Map<String, String> _data = {};
  String image = '';
  bool _isLoading = false;
  Map<String, dynamic> _profileData = {};

  @override
  void initState() {
    super.initState();
    profile();
  }

  Future<void> profile() async {
    if (!Provider.of<Auth>(context, listen: false).isAuth) return;
    final url = baseUrl + 'business/buyer/create/';
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': Provider.of<Auth>(context, listen: false).token,
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 202) {
        final responseBody = json.decode(response.body);
        print(responseBody);
        setState(() {
          _data = {
            "name": responseBody["payload"][0]["user"]["first_name"] +
                " " +
                responseBody["payload"][0]["user"]["last_name"],
            "email": responseBody["payload"][0]["user"]["email"],
            "mobile": responseBody["payload"][0]["mobile"],
            "company": responseBody["payload"][0]["company"],
            "image": responseBody["profile_picture"].length == 0
                ? ''
                : responseBody["profile_picture"][0]['profile_image']
          };
        });
        _profileData = responseBody;
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
          'Account',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Provider.of<Auth>(context, listen: false).isAuth
                  ? Container(
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: Container(
                                height: 150,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.circle,
                                  image: _data['image'] == ''
                                      ? null
                                      : DecorationImage(
                                          image: CachedNetworkImageProvider(
                                            _data['image'],
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                child: _data['image'] == ''
                                    ? Icon(
                                        Icons.account_circle,
                                        color: Colors.white,
                                        size: 150,
                                      )
                                    : null,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: Text(
                                "${_data['name']}",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5
                                    .copyWith(
                                        color: Theme.of(context).primaryColor),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Container(
                                height: 1,
                                width: 100,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Text(
                                "${_data['email']}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(
                                        color: Theme.of(context).primaryColor),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Center(
                              child: Text(
                                "${_data['mobile']}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(
                                        color: Theme.of(context).primaryColor),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                  children: [
                                    TextSpan(
                                      text: "Company: ",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .copyWith(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    TextSpan(
                                      text: "${_data['company']}",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(
                              thickness: 2,
                              indent: 30,
                              endIndent: 30,
                              color: Theme.of(context).primaryColor,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    GestureDetector(
                                      child: Container(
                                        height: 60,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.pink,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.shopping_cart,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (ctx) => CartScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text('Cart'),
                                  ],
                                ),
                                GestureDetector(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Container(
                                        height: 60,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.credit_card,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text('My Orders'),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => OrdersScreen(),
                                      ),
                                    );
                                  },
                                ),
                                GestureDetector(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Container(
                                        height: 60,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.favorite,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text('Wishlist'),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => WishlistScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            GestureDetector(
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 50,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                      color: Colors.black.withOpacity(0.1),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 30),
                                  leading: Icon(
                                    Icons.settings,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  title: Text(
                                    'Edit Profile',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(
                                      MaterialPageRoute(
                                        builder: (ctx) =>
                                            EditProfileScreen(_profileData),
                                      ),
                                    )
                                        .then((value) {
                                      if (value != null) {
                                        profile();
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 50,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                      color: Colors.black.withOpacity(0.1),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 30),
                                  leading: Icon(
                                    Icons.account_balance_wallet,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  title: Text(
                                    'Bulk Inquiry Status',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) =>
                                            BulkInquiryStatusScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 50,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                      color: Colors.black.withOpacity(0.1),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 30),
                                  leading: Icon(
                                    Icons.map,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  title: Text(
                                    'Shipping Address',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => AddressScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 50,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                      color: Colors.black.withOpacity(0.1),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 30),
                                  leading: Icon(
                                    Icons.people,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  title: Text(
                                    'Invite Friends',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                  onTap: () async {
                                    await Share.share(
                                      'https://play.google.com/store/apps/details?id=com.maptai.shopping',
                                      subject: 'Invite Friends',
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 50,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                      color: Colors.black.withOpacity(0.1),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 30),
                                  leading: Icon(
                                    Icons.feedback,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  title: Text(
                                    'Feedback',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                  onTap: () async {
                                    const url =
                                        'mailto:feedback@onlala.com?subject=%20=%20';
                                    if (await canLaunch(url)) {
                                      await launch(url);
                                    } else {
                                      throw 'Could not launch $url';
                                    }
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 50,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                      color: Colors.black.withOpacity(0.1),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 30),
                                  leading: Icon(
                                    Icons.info,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  title: Text(
                                    'Terms and Conditions',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => TNCScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 50,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                      color: Colors.black.withOpacity(0.1),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 30),
                                  leading: Icon(
                                    Icons.exit_to_app,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  title: Text(
                                    'Logout',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                  onTap: () async {
                                    bool _isConfirmed = false;
                                    await showDialog(
                                      context: context,
                                      child: AlertDialog(
                                        title: Text('Confirm?'),
                                        content: Text(
                                            'Are you sure, you want to log out?'),
                                        actions: <Widget>[
                                          FlatButton(
                                            child: Text('Yes'),
                                            onPressed: () {
                                              _isConfirmed = true;
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          FlatButton(
                                            child: Text('No'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                    if (!_isConfirmed) {
                                      return;
                                    }
                                    await Provider.of<Auth>(context,
                                            listen: false)
                                        .logout();
                                    Provider.of<Cart>(context, listen: false)
                                        .clearLocalCart();
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
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
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.2),
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
                                  profile();
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
                            height: 50,
                            width: 200,
                            fontSize: 16,
                            bgColor: Theme.of(context).accentColor,
                            borderColor: Theme.of(context).accentColor,
                            onPressed: () async {
                              Location location = new Location();

                              bool _serviceEnabled;
                              PermissionStatus _permissionGranted;
                              LocationData _locationData;

                              _serviceEnabled = await location.serviceEnabled();
                              if (!_serviceEnabled) {
                                _serviceEnabled =
                                    await location.requestService();
                                if (!_serviceEnabled) {
                                  return;
                                }
                              }

                              _permissionGranted =
                                  await location.hasPermission();
                              if (_permissionGranted ==
                                  PermissionStatus.denied) {
                                _permissionGranted =
                                    await location.requestPermission();
                                if (_permissionGranted !=
                                    PermissionStatus.granted) {
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                  builder: (ctx) =>
                                      RegisterScreen(address.first),
                                ),
                              );
                            },
                            borderRadius: 10,
                            title: 'SIGN UP',
                          ),
                        ],
                      ),
                    ),
            ),
    );
  }
}
