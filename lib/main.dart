import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ustropralki/AdminPage/AddAdminPage.dart';
import 'package:ustropralki/AdminPage/AddDevicePage.dart';
import 'package:ustropralki/AdminPage/AdminPage.dart';
import 'package:ustropralki/AdminPage/MyPrivelagesPage.dart';
import 'package:ustropralki/DeviceDetailsPage.dart';
import 'package:ustropralki/LoginPage.dart';
import 'package:ustropralki/ProfilePage.dart';
import 'package:ustropralki/templates/DevicesSingleton.dart';
import 'package:ustropralki/templates/UserSingleton.dart';
import 'package:ustropralki/templates/localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        disabledColor: Color(0xFFffb080),
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
        "/profile" : (context) => ProfilePage(),
        "/admin" : (context) => AdminPage(),
        "/admin/add_device" : (context) => AddDevicePage(),
        "/admin/add_admin" : (context) => AddAdminPage(),
        "/admin/privileges" : (context) => MyPrivilegesPage(),
        "/login/google" : (context) => GoogleLogin(),
        "/login/dorm" : (context) => DormSelection(),
        "/login/language" : (context) =>LanguageSelection(),
      },
      onGenerateRoute: (settings){
        if (settings.name == DeviceDetailsPage.routeName){
          final args = settings.arguments as DeviceDetailsArguments;

          return MaterialPageRoute(
              builder: (context) {
                return DeviceDetailsPage(
                  deviceId: args.deviceId,
                  deviceName: args.deviceName,
                );
              }
          );
        }
        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
    );
  }
}

class LoadingPage extends StatelessWidget{

  bool _dataLoaded = false;
  bool _initialized = false;

  final DevicesInfoBase devices = DevicesInfoState();
  final UstroUserBase ustroUser = UstroUserState();



  Future<void> initializeApp(BuildContext context) async {
    if (_initialized){
      return;
    }
    _initialized = true;
    await initializeDefault(context);
    // await configureFCM();
    await checkIfLogged(context);
  }

  // Future<void> configureFCM() async {
  //   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  //   _firebaseMessaging.configure(
  //     onLaunch: (Map<String, dynamic> message) {
  //       print('onLaunch called');
  //       return;
  //     },
  //     onResume: (Map<String, dynamic> message) {
  //       print('onResume called');
  //       return;
  //     },
  //     onMessage: (Map<String, dynamic> message) {
  //       print('onMessage called');
  //       return;
  //     },
  //     onBackgroundMessage: _onBackgroundMessage,
  //   );
  //   _firebaseMessaging.subscribeToTopic('all');
  //   _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(
  //     sound: true,
  //     badge: true,
  //     alert: true,
  //   ));
  //   _firebaseMessaging.onIosSettingsRegistered
  //       .listen((IosNotificationSettings settings) {
  //     print('Hello');
  //   });
  //
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   _firebaseMessaging.getToken().then((token) {
  //     prefs.setString("FCM_token", token);
  //     print("device FCM token: $token");
  //   });
  // }

  static Future<void> _onBackgroundMessage(Map<String, dynamic> message) {
    print('onBackgroundMessage called');
    return Future.value(null);
  }

  Future<void> checkIfLogged(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null){
      Navigator.pushReplacementNamed(context, GoogleLogin.routeName);
    } else {
      ustroUser.restart();
      await ustroUser.loadUserFromFirebaseAuthUser(currentUser);
      await ustroUser.checkIfAdmin();
      loadData(context);
    }
  }

  Future<void> initializeDefault(context) async {
    // Change default UI colors
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Theme.of(context).accentColor,
      statusBarIconBrightness: Brightness.dark,
    ));

    final FirebaseOptions firebaseOptions = const FirebaseOptions(
      appId: '1:663108879257:android:7a9fe7e855ed915f700908',
      apiKey: 'AIzaSyAHDFi5BG8qIIi44SAa1Uo6Jkp04CEpHGk',
      projectId: 'ustropralki-fd26a',
      messagingSenderId: '663108879257',
    );

    FirebaseApp app = await Firebase.initializeApp( name: 'ustropralki', options:  firebaseOptions);
    assert(app != null);
    print('Initialized default app $app');
  }

  Future<void> loadData(BuildContext context) async {
    if (_dataLoaded) {
      return;
    }

    // Prevents double loading of data, app builds this widget twice
    _dataLoaded = true;

    //Load last used language
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('language')) {
      AppLocalizations.of(context).loadNewLocale(Locale(prefs.getString('language'), ''));
    }

    final devicesList = await FirebaseFirestore.instance.collection('devices').where("location", isEqualTo: ustroUser.user.locationId).get();
    devices.restart();
    devices.setDeviceListFromDocumentSnapshotList(devicesList.docs);
    Navigator.of(context).pushReplacementNamed("/home");
  }



  @override
  Widget build(BuildContext context) {
    initializeApp(context);
    return Container(
      alignment: AlignmentDirectional.center,
      color: Theme.of(context).accentColor,
      child: Image(
        width: 200,
        height: 200,
        image: AssetImage("res/logo_ustropralki.png"),
      ),
    );
  }

}
