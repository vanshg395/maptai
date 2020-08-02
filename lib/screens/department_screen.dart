import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:maptai_shopping/screens/tabs_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DepartmentSelectScreen extends StatefulWidget {
  @override
  _DepartmentSelectScreenState createState() => _DepartmentSelectScreenState();
}

class _DepartmentSelectScreenState extends State<DepartmentSelectScreen> {
  List<dynamic> depts;
  bool _isLoading = true;

  List<String> _selectedDepts = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  var baseUrl = "https://api.maptai.com/";

  Future<void> getData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final url = baseUrl + 'department/show/';
      final response = await http.get(url);
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final resBody = json.decode(response.body);
        setState(() {
          depts = resBody['departments'];
        });
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _toggleDept(String id) {
    setState(() {
      if (_selectedDepts.contains(id)) {
        _selectedDepts.remove(id);
      } else {
        _selectedDepts.add(id);
      }
    });
    print(_selectedDepts);
  }

  Future<void> _next() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('secondAttempt')) {
      await prefs.remove('secondAttempt');
    }
    await prefs.setString(
      'secondAttempt',
      json.encode({'departments': _selectedDepts}),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) => TabsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Choose Preferred Departments',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).primaryColor,
                ),
              ),
            )
          : Container(
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                childAspectRatio: 0.9,
                crossAxisSpacing: 10,
                mainAxisSpacing: 20,
                padding: EdgeInsets.all(15),
                children: depts
                    .map(
                      (dept) => GestureDetector(
                        child: DepartmentCard(
                            dept['image'],
                            dept['department']['name'],
                            _selectedDepts.contains(dept['department']['id'])),
                        onTap: () => _toggleDept(
                          dept['department']['id'],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
      bottomNavigationBar: _selectedDepts.length > 0
          ? GestureDetector(
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).accentColor,
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'CONTINUE',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(color: Colors.white, fontSize: 18),
                ),
              ),
              onTap: _next,
            )
          : null,
    );
  }
}

class DepartmentCard extends StatelessWidget {
  final String image;
  final String name;
  final bool isSelected;

  DepartmentCard(this.image, this.name, this.isSelected);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 3,
                    )
                  : null,
              shape: BoxShape.circle,
              image: DecorationImage(
                image: CachedNetworkImageProvider(
                  image,
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                name,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
