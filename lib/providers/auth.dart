import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:maptai_shopping/utils/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  String _username;

  String baseUrl = "https://api.maptai.com/";

  bool get isAuth {
    return token != null;
  }

  String get token {
    return _token;
  }

  String get username {
    return _username;
  }

  Future<void> register(Map<String, dynamic> registerData) async {
    try {
      print('>>>>>>>>>>>>>>register');
      final url = baseUrl + 'user/create/';
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(registerData),
      );
      print(response.statusCode);
      if (response.statusCode >= 200 && response.statusCode <= 299) {
      } else if (response.statusCode == 400) {
        throw HttpException('User exists');
      } else {
        throw HttpException('Error');
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> createBuyer(Map<String, dynamic> buyerData) async {
    try {
      print('>>>>>>>>>>>>>>createBuyer');
      final url = baseUrl + 'business/buyer/create/';
      print(_token);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': _token,
        },
        body: json.encode(buyerData),
      );
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 201) {
        _token = null;
        notifyListeners();
      } else if (response.statusCode == 400) {
        throw HttpException('Repeated Phone');
      } else if (response.statusCode == 500) {
        throw HttpException('Server Overload');
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> login(Map<String, dynamic> loginData) async {
    try {
      print('>>>>>>>>>>>>>>login');
      final url = baseUrl + 'user/api/token/buyer/';
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(loginData),
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        _token = 'JWT ' + responseBody['access'];
        final prefs = await SharedPreferences.getInstance();
        final _data = json.encode({
          'token': _token,
        });
        await prefs.setString('userData', _data);
        final url2 = baseUrl + 'business/buyer/create/';
        final response2 = await http.get(
          url2,
          headers: {
            'Authorization': _token,
          },
        );
        print(response2.statusCode);
        print(response2.body);
        if (response2.statusCode == 200) {
          final resBody = json.decode(response2.body);
          print(resBody);
        } else if (response2.statusCode == 403) {
          throw HttpException('Not a buyer');
        }
      } else if (response.statusCode == 202) {
        final responseBody = json.decode(response.body);
        _token = 'JWT ' + responseBody['access'];
        final prefs = await SharedPreferences.getInstance();
        final _data = json.encode({
          'token': _token,
        });
        await prefs.setString('userData', _data);
        final url2 = baseUrl + 'business/buyer/create/';
        final response2 = await http.get(
          url2,
          headers: {
            'Authorization': _token,
          },
        );
        print(response2.statusCode);
        print(response2.body);
        if (response2.statusCode == 200) {
          final resBody = json.decode(response2.body);
          print(resBody);
          throw HttpException('Complete Profile');
        } else if (response2.statusCode == 403) {
          throw HttpException('Not a buyer');
        }
      } else if (response.statusCode == 401) {
        throw HttpException('Invalid Cred');
      } else if (response.statusCode == 412) {
        throw HttpException('User Blocked');
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> regLogin(Map<String, dynamic> loginData) async {
    try {
      print('>>>>>>>>>>>>>>login');
      final url = baseUrl + 'user/api/token/buyer/';
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(loginData),
      );
      print(response.statusCode);

      if (response.statusCode == 200 || response.statusCode == 202) {
        final responseBody = json.decode(response.body);
        _token = 'JWT ' + responseBody['access'];
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    _token = extractedUserData['token'];
    // notifyListeners();
    return true;
  }

  Future<void> deleteUser() async {
    final url = baseUrl + 'user/delete/';
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': _token,
        },
      );
      print(response.statusCode);
    } catch (e) {}
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
  }
}
