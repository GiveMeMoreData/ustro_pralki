import 'package:flutter/material.dart';
import 'package:ustropralki/QRScan.dart';

import 'HomePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ustro Pralki',
      theme: ThemeData(
        primaryColor: Color(0xFFE55900),
        primarySwatch: Colors.red,
        backgroundColor: Color(0xFFF9F3EE),
        accentColor: Color(0xFFE55900),
        textTheme: TextTheme( headline1: TextStyle(
          color: Color(0x484848),
          fontSize: 24,
        )),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: "/",
      routes: {
        "/" : (context) => MyHomePage(),
        "/scan" : (context) => QRScan(),
      },
    );
  }
}
