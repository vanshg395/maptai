import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:maptai_shopping/providers/auth.dart';
import 'package:provider/provider.dart';
import 'package:websafe_svg/websafe_svg.dart';

import './login_screen.dart';
import '../widgets/common_field.dart';
import '../widgets/common_button.dart';
import '../widgets/common_dropdown.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();

  final Address address;

  RegisterScreen(this.address);
}

class _RegisterScreenState extends State<RegisterScreen> {
  GlobalKey<FormState> _formKey = GlobalKey();
  GlobalKey<FormState> _formKey2 = GlobalKey();
  final _compController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  var baseUrl = "https://api.maptai.com/";
  bool _isPassVisible = false;
  bool _isConPassVisible = false;

  Map<String, String> _data = {
    "email": "",
    "password": "",
    "first_name": "",
    "last_name": ""
  };
  Map<String, String> _buyerData = {
    "postal_state": "",
    "postal_city": "",
    "postal_country": "",
    "postal_code": "",
    "postal_address1": "",
    "postal_landmark": "",
    "brought_from": "",
    "company": "",
    "mobile": "",
    "department": "",
    "administrativeArea": "",
    "isoCountryCode": "",
    "phone_verified": "true",
    "first_term_acceptance": "true",
    "second_term_acceptance": "true"
  };
  bool _isLoading = false;
  int _currentPart = 1;
  String _departmentChoice;
  String _sourcingChoice;
  List<dynamic> _depts = [];

  @override
  void initState() {
    super.initState();
    getDepartments();
  }

  @override
  void dispose() {
    _compController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> getDepartments() async {
    try {
      final url = baseUrl + 'department/show/';
      final response = await http.get(url);
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final resBody = json.decode(response.body);
        setState(() {
          _depts = resBody['departments'];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _submit1() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _currentPart++;
    });
    print(_data);
    print(widget.address.countryCode);
  }

  Future<void> _submit2() async {
    _buyerData['postal_state'] = widget.address.adminArea ?? 'NA';
    _buyerData['postal_city'] =
        widget.address.subAdminArea ?? widget.address.adminArea ?? 'NA';
    _buyerData['postal_landmark'] = widget.address.subLocality ?? 'NA';
    _buyerData['postal_country'] = widget.address.countryName;
    _buyerData['postal_address1'] =
        widget.address.featureName ?? widget.address.addressLine;
    _buyerData['postal_code'] = widget.address.postalCode ?? 'NA';
    _buyerData["department"] = _departmentChoice;
    _buyerData["administrativeArea"] = widget.address.locality ??
        widget.address.adminArea ??
        widget.address.thoroughfare ??
        'NA';
    _buyerData["isoCountryCode"] = countries.firstWhere((element) =>
        element['code'] == widget.address.countryCode)['dial_code'];
    _buyerData["company_email"] = _data["email"];
    _buyerData["brought_from"] = _sourcingChoice;

    if (!_formKey2.currentState.validate()) {
      return;
    }
    _formKey2.currentState.save();
    print(_buyerData);

    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Auth>(context, listen: false).register(_data);
      await Provider.of<Auth>(context, listen: false).regLogin(
          {'username': _data['email'], 'password': _data['password']});
      await Provider.of<Auth>(context, listen: false).createBuyer(_buyerData);
      setState(() {
        _isLoading = false;
      });
      await showDialog(
        context: context,
        child: AlertDialog(
          title: Text('Success'),
          content: Text('You have been registered successfully.'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => LoginScreen(),
        ),
      );
    } catch (e) {
      print(e);
      String errorTitle = '';
      String errorMessage = '';
      if (e.toString() == 'User exists') {
        errorTitle = 'Error';
        errorMessage = 'This email is already in use. Please try again.';
      } else if (e.toString() == 'Error') {
        errorTitle = 'Error';
        errorMessage = 'Something went wrong. Please try again.';
      } else if (e.toString() == 'Error1') {
        errorTitle = 'Error';
        errorMessage = 'Something went wrong. Please try again.';
      } else if (e.toString() == 'Repeated Phone') {
        Provider.of<Auth>(context, listen: false).deleteUser();
        errorTitle = 'Error';
        errorMessage = 'This phone number is already in use. Please try again.';
      } else if (e.toString() == 'Server Overload') {
        Provider.of<Auth>(context, listen: false).deleteUser();
        errorTitle = 'Error';
        errorMessage = 'Server is under heavy load. Please try again later.';
      } else {
        errorTitle = 'Error';
        errorMessage = 'Something went wrong. Please try again.';
      }
      await showDialog(
        context: context,
        child: AlertDialog(
          title: Text(errorTitle),
          content: Text(errorMessage),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget buildPartOne() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 30,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Tell us About You!',
              style: Theme.of(context).textTheme.headline5.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'First Name',
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
              placeholder: 'John',
              controller: _firstnameController,
              validator: (value) {
                if (value == '') {
                  return 'This field is required.';
                }
              },
              onSaved: (value) {
                _data['first_name'] = _firstnameController.text;
              },
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Last Name',
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
              placeholder: 'Doe',
              controller: _lastnameController,
              validator: (value) {
                if (value == '') {
                  return 'This field is required.';
                }
              },
              onSaved: (value) {
                _data['last_name'] = _lastnameController.text;
              },
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Email Address',
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
              placeholder: 'abc@xyz.com',
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              validator: (value) {
                if (value == '') {
                  return 'This field is required.';
                }
              },
              onSaved: (value) {
                _data['email'] = _emailController.text;
              },
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Password',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            child: CommonField(
              isPassword: !_isPassVisible,
              bgColor: Colors.white,
              borderColor: Colors.grey,
              borderRadius: 10,
              placeholder: 'XXXXXXXX',
              controller: _passController,
              suffixIcon: InkWell(
                child: WebsafeSvg.asset(
                  _isPassVisible
                      ? 'assets/svg/visible.svg'
                      : 'assets/svg/obscure.svg',
                  height: 30,
                  color: Colors.grey,
                ),
                onTap: () {
                  setState(() {
                    _isPassVisible = !_isPassVisible;
                  });
                },
              ),
              validator: (value) {
                if (value == '') {
                  return 'This field is required.';
                }
              },
              onSaved: (value) {
                _data['password'] = _passController.text;
              },
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Confirm Password',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            child: CommonField(
              isPassword: !_isConPassVisible,
              bgColor: Colors.white,
              borderColor: Colors.grey,
              borderRadius: 10,
              placeholder: 'XXXXXXXX',
              suffixIcon: InkWell(
                child: WebsafeSvg.asset(
                  _isConPassVisible
                      ? 'assets/svg/visible.svg'
                      : 'assets/svg/obscure.svg',
                  height: 30,
                  color: Colors.grey,
                ),
                onTap: () {
                  setState(() {
                    _isConPassVisible = !_isConPassVisible;
                  });
                },
              ),
              validator: (value) {
                if (value == '') {
                  return 'This field is required.';
                }
                if (value != _passController.text) {
                  return 'Passwords do not match.';
                }
              },
              onSaved: (value) {
                _data['password'] = _passController.text;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPartTwo() {
    return Form(
      key: _formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 30,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Tell us about your Company!',
              style: Theme.of(context).textTheme.headline5.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Company Name',
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
              placeholder: 'ABC Inc.',
              controller: _compController,
              validator: (value) {
                if (value == '') {
                  return 'This field is required.';
                }
              },
              onSaved: (value) {
                _buyerData["company"] = _compController.text;
              },
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Mobile Number',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            child: IntlPhoneField(
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
                hintText: 'XXXXX-XXXXX',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w300,
                ),
                contentPadding: EdgeInsets.only(
                  left: 30,
                  top: 0,
                ),
              ),
              initialCountryCode: widget.address.countryCode,
              showDropdownIcon: false,
              validator: (value) {
                if (value == '') {
                  return 'This field is required.';
                }
              },
              onSaved: (value) {
                print(value.completeNumber);
                _buyerData["mobile"] = value.completeNumber;
              },
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Department',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            child: MultilineDropdownButtonFormField(
              isExpanded: true,
              items: _depts.length == 0
                  ? []
                  : _depts
                      .map(
                        (dept) => DropdownMenuItem(
                          child: Text(
                            dept['department']['name'],
                            style: TextStyle(
                              color: Theme.of(context).cardColor,
                              fontFamily: Theme.of(context)
                                  .primaryTextTheme
                                  .display1
                                  .fontFamily,
                              fontSize: 16,
                            ),
                          ),
                          value: dept['department']['name'],
                        ),
                      )
                      .toList(),
              value: _departmentChoice,
              iconSize: 40,
              onChanged: (val) {
                setState(() {
                  _departmentChoice = val;
                });
              },
              validator: (value) {
                if (_buyerData['department'] == null) {
                  return 'This field is required.';
                }
              },
              onSaved: (value) {
                _buyerData['department'] = value;
              },
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
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'You are Sourcing as',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            child: MultilineDropdownButtonFormField(
              value: _sourcingChoice,
              onChanged: (value) {
                setState(() {
                  _sourcingChoice = value;
                });
              },
              items: [
                DropdownMenuItem(
                  child: Text(
                    'Importer',
                    style: TextStyle(
                      color: Theme.of(context).cardColor,
                      fontFamily: Theme.of(context)
                          .primaryTextTheme
                          .display1
                          .fontFamily,
                      fontSize: 16,
                    ),
                  ),
                  value: 'Importer',
                ),
                DropdownMenuItem(
                  child: Text(
                    'Trader',
                    style: TextStyle(
                      color: Theme.of(context).cardColor,
                      fontFamily: Theme.of(context)
                          .primaryTextTheme
                          .display1
                          .fontFamily,
                      fontSize: 16,
                    ),
                  ),
                  value: 'Trader',
                ),
                DropdownMenuItem(
                  child: Text(
                    'Buyer',
                    style: TextStyle(
                      color: Theme.of(context).cardColor,
                      fontFamily: Theme.of(context)
                          .primaryTextTheme
                          .display1
                          .fontFamily,
                      fontSize: 16,
                    ),
                  ),
                  value: 'Buyer',
                ),
                DropdownMenuItem(
                  child: Text(
                    'Other',
                    style: TextStyle(
                      color: Theme.of(context).cardColor,
                      fontFamily: Theme.of(context)
                          .primaryTextTheme
                          .display1
                          .fontFamily,
                      fontSize: 16,
                    ),
                  ),
                  value: 'Other',
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
                if (value == '') {
                  return 'This field is required.';
                }
              },
              onSaved: (value) {},
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign Up',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (_currentPart == 1) buildPartOne() else buildPartTwo(),
                SizedBox(
                  height: 50,
                ),
                Center(
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : CommonButton(
                          title: _currentPart == 1 ? 'Next' : 'Sign Up',
                          onPressed: _currentPart == 1 ? _submit1 : _submit2,
                          fontSize: 18,
                          borderRadius: 10,
                          bgColor: Theme.of(context).accentColor,
                          borderColor: Theme.of(context).accentColor,
                        ),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: FlatButton(
                    child: Text(
                      'Login Instead',
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                            color: Theme.of(context).accentColor,
                          ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (ctx) => LoginScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
