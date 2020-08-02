import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:maptai_shopping/providers/auth.dart';
import 'package:provider/provider.dart';

import '../widgets/common_field.dart';
import '../widgets/common_dropdown.dart';
import '../widgets/common_button.dart';
import 'package:http/http.dart' as http;

class BulkInquiryScreen extends StatefulWidget {
  @override
  _BulkInquiryScreenState createState() => _BulkInquiryScreenState();

  final String productName;
  final String id;
  final String description;
  final String price;
  final String url;

  BulkInquiryScreen(
      this.productName, this.id, this.description, this.price, this.url);
}

class _BulkInquiryScreenState extends State<BulkInquiryScreen> {
  GlobalKey<FormState> _formKey = GlobalKey();
  String _userTypeChoice;
  String _deliveryTermsChoice;
  String _paymentTermsChoice;
  bool _callOurExec = false;
  bool _reportsQCStand = false;
  bool _isLoading = false;
  FlutterToast flutterToast;
  var baseUrl = "https://api.maptai.com/";
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    flutterToast = FlutterToast(context);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    _data['product'] = widget.id;
    try {
      final url = baseUrl + 'query/add/';
      final response = await http.post(
        url,
        headers: {
          'Authorization': Provider.of<Auth>(context, listen: false).token,
          'Content-Type': 'application/json'
        },
        body: json.encode(_data),
      );
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
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
      } else {
        showDialog(
          context: context,
          child: AlertDialog(
            title: Text('Error'),
            content: Text('Something went wrong. Please try again later.'),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
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
        title: Text('Bulk Order Inquiry'),
      ),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                PopularProductCard(
                  widget.productName,
                  widget.description,
                  widget.price,
                  widget.url,
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Type of User',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: MultilineDropdownButtonFormField(
                    value: _userTypeChoice,
                    onChanged: (value) {
                      setState(() {
                        _userTypeChoice = value;
                      });
                    },
                    items: [
                      DropdownMenuItem(
                        child: Text(
                          'Importer',
                          style: TextStyle(fontSize: 18),
                        ),
                        value: 'Importer',
                      ),
                      DropdownMenuItem(
                        child: Text(
                          'Wholesaler',
                          style: TextStyle(fontSize: 18),
                        ),
                        value: 'Wholeseller',
                      ),
                      DropdownMenuItem(
                        child: Text(
                          'Distributor',
                          style: TextStyle(fontSize: 18),
                        ),
                        value: 'Distributor',
                      ),
                      DropdownMenuItem(
                        child: Text(
                          'Own Brand',
                          style: TextStyle(fontSize: 18),
                        ),
                        value: 'Own Brand',
                      ),
                    ],
                    iconSize: 40,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 0,
                          color: Colors.grey,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 0,
                          color: Colors.grey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 0,
                          color: Colors.grey,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 0,
                          color: Colors.grey,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 0,
                          color: Colors.grey,
                        ),
                      ),
                      errorStyle: TextStyle(color: Colors.red[200]),
                      alignLabelWithHint: true,
                      hintText: '',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w300,
                      ),
                      suffixStyle: TextStyle(fontSize: 16),
                      contentPadding: EdgeInsets.only(
                        left: 30,
                        top: 10,
                      ),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'This field is required.';
                      }
                    },
                    onSaved: (value) {
                      _data['type_of_user'] = value;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Quantity',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: CommonField(
                    bgColor: Colors.white,
                    borderColor: Colors.grey,
                    borderRadius: 10,
                    placeholder: 'XX',
                    keyboardType: TextInputType.numberWithOptions(
                      signed: false,
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == '') {
                        return 'This field is required.';
                      }
                    },
                    onSaved: (value) {
                      _data['quantity'] = value;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Technical Specification',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: CommonField(
                    bgColor: Colors.white,
                    borderColor: Colors.grey,
                    borderRadius: 10,
                    maxLines: 5,
                    topPadding: 30,
                    placeholder: 'Some Specifications',
                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      if (value == '') {
                        return 'This field is required.';
                      }
                    },
                    onSaved: (value) {
                      _data['technical_specifications'] = value;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Terms of Delivery',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: MultilineDropdownButtonFormField(
                    value: _deliveryTermsChoice,
                    onChanged: (value) {
                      setState(() {
                        _deliveryTermsChoice = value;
                      });
                    },
                    items: [
                      DropdownMenuItem(
                        child: Text(
                          'EX-FACTORY',
                          style: TextStyle(fontSize: 18),
                        ),
                        value: 'EX-FACTORY',
                      ),
                      DropdownMenuItem(
                        child: Text(
                          'FOB',
                          style: TextStyle(fontSize: 18),
                        ),
                        value: 'FOB',
                      ),
                      DropdownMenuItem(
                        child: Text(
                          'CNF',
                          style: TextStyle(fontSize: 18),
                        ),
                        value: 'CNF',
                      ),
                      DropdownMenuItem(
                        child: Text(
                          'OTHER',
                          style: TextStyle(fontSize: 18),
                        ),
                        value: 'OTHER',
                      ),
                    ],
                    iconSize: 40,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 0,
                          color: Colors.grey,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 0,
                          color: Colors.grey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 0,
                          color: Colors.grey,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 0,
                          color: Colors.grey,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 0,
                          color: Colors.grey,
                        ),
                      ),
                      errorStyle: TextStyle(color: Colors.red[200]),
                      alignLabelWithHint: true,
                      hintText: '',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w300,
                      ),
                      suffixStyle: TextStyle(fontSize: 16),
                      contentPadding: EdgeInsets.only(
                        left: 30,
                        top: 10,
                      ),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'This field is required.';
                      }
                    },
                    onSaved: (value) {
                      _data['terms_of_delivery'] = value;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Payment Terms',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: MultilineDropdownButtonFormField(
                    value: _paymentTermsChoice,
                    onChanged: (value) {
                      setState(() {
                        _paymentTermsChoice = value;
                      });
                    },
                    items: [
                      DropdownMenuItem(
                        child: Text(
                          'LC at Site',
                          style: TextStyle(fontSize: 18),
                        ),
                        value: 'LC at Site',
                      ),
                      DropdownMenuItem(
                        child: Text(
                          'LC 30 days',
                          style: TextStyle(fontSize: 18),
                        ),
                        value: 'LC 30 days',
                      ),
                      DropdownMenuItem(
                        child: Text(
                          'LC 90 days',
                          style: TextStyle(fontSize: 18),
                        ),
                        value: 'LC 90 days',
                      ),
                      DropdownMenuItem(
                        child: Text(
                          'LC 120 days',
                          style: TextStyle(fontSize: 18),
                        ),
                        value: 'LC 120 days',
                      ),
                      DropdownMenuItem(
                        child: Text(
                          'TT',
                          style: TextStyle(fontSize: 18),
                        ),
                        value: 'TT',
                      ),
                    ],
                    iconSize: 40,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 0,
                          color: Colors.grey,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 0,
                          color: Colors.grey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 0,
                          color: Colors.grey,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 0,
                          color: Colors.grey,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 0,
                          color: Colors.grey,
                        ),
                      ),
                      errorStyle: TextStyle(color: Colors.red[200]),
                      alignLabelWithHint: true,
                      hintText: '',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w300,
                      ),
                      suffixStyle: TextStyle(fontSize: 16),
                      contentPadding: EdgeInsets.only(
                        left: 30,
                        top: 10,
                      ),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'This field is required.';
                      }
                    },
                    onSaved: (value) {
                      _data['payment_terms'] = value;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Additional Message',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: CommonField(
                    bgColor: Colors.white,
                    borderColor: Colors.grey,
                    borderRadius: 10,
                    maxLines: 5,
                    topPadding: 30,
                    placeholder: 'Some Message',
                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      if (value == '') {
                        return 'This field is required.';
                      }
                    },
                    onSaved: (value) {
                      _data['additional_message'] = value;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: <Widget>[
                      Checkbox(
                        value: _callOurExec,
                        onChanged: (value) {
                          setState(() {
                            _callOurExec = value;
                            _data['call_our_excutive'] = value;
                          });
                        },
                      ),
                      Text(
                        'Call our Executive',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: <Widget>[
                      Checkbox(
                        value: _reportsQCStand,
                        onChanged: (value) {
                          setState(() {
                            _reportsQCStand = value;

                            _data['reports_qc_stands'] = value;
                          });
                        },
                      ),
                      Text(
                        'Reports QC Stand',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Our team will contact you soon for further procedures.',
                    style: Theme.of(context).textTheme.bodyText1,
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
                          onPressed: _submit,
                          borderRadius: 10,
                          fontSize: 18,
                          bgColor: Theme.of(context).primaryColor,
                          borderColor: Theme.of(context).primaryColor,
                        ),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PopularProductCard extends StatelessWidget {
  final String productName;
  final String description;
  final String price;
  final String url;

  PopularProductCard(
    this.productName,
    this.description,
    this.price,
    this.url,
  );
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              width: 120,
              decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(url),
                    fit: BoxFit.cover,
                  )),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      productName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.subtitle1.copyWith(),
                    ),
                    Text(
                      description ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.subtitle2.copyWith(),
                    ),
                    Text(
                      '€ $price' ?? '',
                      style: Theme.of(context).textTheme.subtitle2.copyWith(
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
    );
  }
}
