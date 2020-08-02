import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

class BulkInquiryStatusScreen extends StatefulWidget {
  @override
  _BulkInquiryStatusScreenState createState() =>
      _BulkInquiryStatusScreenState();
}

class _BulkInquiryStatusScreenState extends State<BulkInquiryStatusScreen> {
  List<dynamic> _queries = [];
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
    final url = 'https://api.maptai.com/query/add/';
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
          _queries = resBody['payload'];
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
          'Bulk Inquiry Status',
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
                    ..._queries
                        .map(
                          (query) => BulkInquiryStatusCard(
                            query['created'],
                            query['quantity'].toString(),
                            query['terms_of_delivery'],
                            query['type_of_user'],
                            query['technical_specifications'],
                            query['payment_terms'],
                            query['additional_message'],
                            query['call_our_excutive'],
                            query['reports_qc_stand'],
                            query['admin_approval'],
                            query['seller_approval'],
                            query['admin_review'],
                            query['manufacturer_review'],
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

class BulkInquiryStatusCard extends StatelessWidget {
  final String timestamp;
  final String tou;
  final String quantity;
  final String tod;
  final String techSpec;
  final String paymentTerms;
  final String msg;
  final bool coe;
  final bool rqcs;
  final bool aa;
  final bool sa;
  final bool ar;
  final bool mr;

  BulkInquiryStatusCard(
    this.timestamp,
    this.quantity,
    this.tod,
    this.tou,
    this.techSpec,
    this.paymentTerms,
    this.msg,
    this.coe,
    this.rqcs,
    this.aa,
    this.sa,
    this.ar,
    this.mr,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(20),
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
                  text: 'Created on: ',
                ),
                TextSpan(
                  text: DateFormat('MMM dd, y')
                          .format(DateTime.parse(timestamp)) +
                      ' | ' +
                      TimeOfDay.fromDateTime(DateTime.parse(timestamp))
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
                  text: 'Type of User: ',
                ),
                TextSpan(
                  text: tou,
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
                  text: 'Quantity: ',
                ),
                TextSpan(
                  text: quantity,
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
                  text: 'Technical Specification: ',
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Call our Executive: ',
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Reports QC Stand: ',
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Icon(
                rqcs ? Icons.done : Icons.clear,
                color: coe ? Colors.green : Colors.red,
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Admin Approval: ',
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Icon(
                aa ? Icons.done : Icons.clear,
                color: coe ? Colors.green : Colors.red,
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Seller Approval: ',
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Icon(
                sa ? Icons.done : Icons.clear,
                color: coe ? Colors.green : Colors.red,
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Admin Review: ',
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Icon(
                ar ? Icons.done : Icons.clear,
                color: coe ? Colors.green : Colors.red,
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Manufacturer Review: ',
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Icon(
                mr ? Icons.done : Icons.clear,
                color: coe ? Colors.green : Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
