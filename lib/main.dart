import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ustropralki/QRScan.dart';
import 'package:ustropralki/templates/DevicesSingleton.dart';
import 'package:ustropralki/templates/localization.dart';

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
      supportedLocales: [
        Locale('en',''),
        Locale('pl',''),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      initialRoute: "/",
      routes: {
        "/" : (context) => LoadingPage(),
        "/home": (context) => MyHomePage(),
        "/scan" : (context) => QRScan(),
      },
    );
  }
}

class LoadingPage extends StatelessWidget{

  final DevicesInfoBase devices = DevicesInfoState();

  void loadData(BuildContext context) async {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.white,
    ));
    final devicesList = await Firestore.instance.collection('devices').getDocuments();
    devices.setDeviceListFromDocumentSnapshotList(devicesList.documents);
    Navigator.of(context).pushReplacementNamed("/home");
  }

  @override
  Widget build(BuildContext context) {
    loadData(context);
    return Container(
      alignment: AlignmentDirectional.center,
      color: Colors.white,
      child: Image(
        width: 200,
        height: 200,
        image: AssetImage("res/ustro_logo.png"),
      ),
    );
  }

}
