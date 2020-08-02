import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maptai_shopping/screens/intro_screen.dart';
import 'package:maptai_shopping/screens/tabs_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './providers/auth.dart';
import './providers/cart.dart';
import './providers/wishlist.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        ChangeNotifierProvider.value(
          value: Wishlist(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Maptai Shppping',
        theme: ThemeData(
          primaryColor: Color(0xFF32c2e3),
          accentColor: Color(0xFF00d4a2),
          primaryColorDark: Color(0xFF030708),
          cardColor: Color(0xFF3E4346),
          canvasColor: Color(0xFFF3F6F7),
          fontFamily: GoogleFonts.montserrat().fontFamily,
          textTheme: TextTheme(
              // subtitle1: TextStyle(fontSize: 20),
              // bodyText1: TextStyle(fontSize: 16),
              ),
          appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
          ),
        ),
        home: SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 2),
      () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (ctx) => MainScreen(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          child: Image.asset('assets/img/splash.png'),
        ),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Auth>(
      builder: (ctx, auth, _) => FutureBuilder(
        future: auth.tryAutoLogin(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            return FutureBuilder(
              future: () async {
                final prefs = await SharedPreferences.getInstance();
                if (prefs.containsKey('secondAttempt')) {
                  return true;
                } else {
                  return false;
                }
              }(),
              builder: (ctx, snapshot2) {
                if (snapshot2.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else {
                  if (snapshot2.data) {
                    return TabsScreen();
                  } else {
                    return IntroScreen();
                  }
                }
              },
            );
          }
        },
      ),
    );
  }
}
