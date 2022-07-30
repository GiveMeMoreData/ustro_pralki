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
import 'package:ustropralki/ProfilePage/DormSelection.dart';
import 'package:ustropralki/ProfilePage/LanguageSelection.dart';
import 'package:ustropralki/ProfilePage/ProfilePage.dart';
import 'package:ustropralki/QRScanPage.dart';
import 'package:ustropralki/templates/DevicesSingleton.dart';
import 'package:ustropralki/templates/UserSingleton.dart';
import 'package:ustropralki/templates/localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'HomePage.dart';


import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
        // colorScheme: ColorScheme(
        //   brightness: Brightness.dark,
        //   primary: Color(0xFFE55900),
        //   onPrimary: Color(0xFFE55900),
        //   secondary: Color(0xFFE55900),
        //   onSecondary: Color(0xFFE55900),
        //   background: Color(0xFFFFFFFF),
        //   onBackground: Color(0xFFF9F3EE),
        //   error: Colors.red,
        //   onError: Colors.red,
        //   surface: Color(0xFFE55900),
        //   onSurface: Color(0xFFE55900),
        //
        // ),
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
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      initialRoute: "/",
      routes: {
        "/" : (context) => LoadingPage(),
        "/home": (context) => MyHomePage(),
        "/home/scan": (context) => QRSCanPage(),
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



  final FirebaseOptions firebaseOptions = const FirebaseOptions(
    appId: '1:663108879257:android:7a9fe7e855ed915f700908',
    apiKey: 'AIzaSyAHDFi5BG8qIIi44SAa1Uo6Jkp04CEpHGk',
    projectId: 'ustropralki-fd26a',
    messagingSenderId: '663108879257',
  );

  static const String firebaseAppName = 'ustropralki';

  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future<void> initializeApp(BuildContext context) async {
    if (_initialized){
      return;
    }
    _initialized = true;
    await initializeDefault(context);

    // await checkVersion(context);

    await checkIfLogged(context);
    await configureFCM(context);
  }

  Future<void> setFCMToken() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? currentToken = await prefs.getString("FCM_token");
      if (currentToken == null){
        // notifications disabled
        return;
      }

      // update notifications
      FirebaseMessaging.instance.getToken().then((token) {
        prefs.setString("FCM_token", token!);
        final String? userId = FirebaseAuth.instance.currentUser?.uid;
        FirebaseFirestore.instance.collection('users').doc(userId!).set({"token": token}, SetOptions(merge: true));
        print("device FCM token: $token");
      });
  }

  Future<void> configureFCM(context) async {

    await setFCMToken();
    await FirebaseMessaging.instance.subscribeToTopic('all');

    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );


    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: 'launch_background',
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      Navigator.pushReplacementNamed(
        context,
        '/home',
      );
    });


    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);



    // FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

  }

  Future<void> _onBackgroundMessage(RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    // await Firebase.initializeApp( name: firebaseAppName, options:  firebaseOptions);
    print('onBackgroundMessage called');
  }

  Future<void> checkIfLogged(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null){
      Navigator.pushReplacementNamed(context, GoogleLogin.routeName);
    } else {
      // User known to firebase
      // Check if has data in Firestore database

      final DocumentSnapshot? user = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      if(user?.data() == null){
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacementNamed(context, GoogleLogin.routeName);
      } else {
        ustroUser.restart();
        await ustroUser.loadUserFromFirebaseAuthUser(currentUser);
        await ustroUser.checkIfAdmin();
        loadData(context);
      }
    }
  }

  Future<void> initializeDefault(context) async {
    // Change default UI colors
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Theme.of(context).accentColor,
      statusBarIconBrightness: Brightness.dark,
    ));


    FirebaseApp app = await Firebase.initializeApp( name: firebaseAppName, options:  firebaseOptions);
    assert(app != null);
    print('Initialized default app $app');
  }
  // TODO in next version
  // Future<void> checkVersion(context) async {
  //   final devicesList = await FirebaseFirestore.instance.collection('versions').doc('latest').get();
  //
  //   // compare to local version
  //
  //   // if different show snack bar and require update
  //
  // }


  Future<void> loadData(BuildContext context) async {
    if (_dataLoaded) {
      return;
    }

    // Prevents double loading of data, app builds this widget twice
    _dataLoaded = true;

    //Load last used language
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('language')) {
      AppLocalizations.of(context)!.loadNewLocale(Locale(prefs.getString('language').toString(), ''));
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
