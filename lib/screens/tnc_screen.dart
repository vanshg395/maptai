import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TNCScreen extends StatefulWidget {
  @override
  _TNCScreenState createState() => _TNCScreenState();
}

class _TNCScreenState extends State<TNCScreen> {
  String _title = '';
  String _tnc = 'No Terms and Conditions Found';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getTnc();
  }

  Future<void> getTnc() async {
    setState(() {
      _isLoading = true;
    });
    final url = 'https://api.maptai.com/business/termsAndConditions/';
    try {
      final response = await http.get(url);
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final resBody = json.decode(response.body);
        setState(() {
          _title = resBody['payload'][0]['title'];
          _tnc = resBody['payload'][0]['description'];
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
          'Terms and Conditions',
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
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.symmetric(horizontal: 20),
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
                          if (_title != '')
                            Text(
                              _title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          if (_title != '')
                            SizedBox(
                              height: 10,
                            ),
                          Text(
                            _tnc,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
