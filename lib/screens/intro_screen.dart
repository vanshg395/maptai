import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:maptai_shopping/screens/department_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './register_screen.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();

  static Future<bool> isFirstUse() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('isFirstLogin')) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}

class _IntroScreenState extends State<IntroScreen> {
  final List<PageViewModel> pages = [
    PageViewModel(
      title: "",
      body: "ATTAIN CREDIBILITY WITH  A POTENTIAL SUPPLIER",
      image: Center(
        child: Image.asset(
          "assets/img/one.png",
          width: 300,
          fit: BoxFit.cover,
        ),
      ),
      decoration: const PageDecoration(
        pageColor: Colors.white,
        imageFlex: 2,
      ),
    ),
    PageViewModel(
      title: "",
      body: "BUYERS ARE SATISFIED WITH MAPTAI SUPPLIER WORK",
      image: Center(
        child: Image.asset(
          "assets/img/two.png",
          width: 300,
          fit: BoxFit.cover,
        ),
      ),
      decoration: const PageDecoration(
        pageColor: Colors.white,
        imageFlex: 2,
      ),
    ),
    PageViewModel(
      title: "",
      body:
          "SYSTEMATICALLY AND CONSIDER MANY DIFFERENT FACTORS WHEN YOU WORK WITH MAPTAI",
      image: Center(
        child: Image.asset(
          "assets/img/three.png",
          width: 300,
          fit: BoxFit.cover,
        ),
      ),
      decoration: const PageDecoration(
        pageColor: Colors.white,
        imageFlex: 2,
      ),
    ),
    PageViewModel(
      title: "",
      body: "WHERE TO GO FROM MAPTAI",
      image: Center(
        child: Image.asset(
          "assets/img/four.png",
          width: 300,
          fit: BoxFit.cover,
        ),
      ),
      decoration: const PageDecoration(
        pageColor: Colors.white,
        imageFlex: 2,
        imagePadding: EdgeInsets.zero,
      ),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: pages,
      onDone: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (ctx) => DepartmentSelectScreen(),
          ),
        );
      },
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Text('Next', style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
