
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ustropralki/ProfilePage/DormSelection.dart';
import 'package:ustropralki/ProfilePage/LanguageSelection.dart';
import 'package:ustropralki/ProfilePage/ProfilePage.dart';
import 'package:ustropralki/templates/DevicesSingleton.dart';
import 'package:ustropralki/templates/localization.dart';
import 'package:auto_size_text/auto_size_text.dart';



class GoogleLogin extends StatefulWidget{
  static const routeName = '/login/google';

  @override
  State<StatefulWidget> createState() => _GoogleLoginState();
}

class _GoogleLoginState extends State<GoogleLogin>{

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DevicesInfoBase devices = DevicesInfoState();


  bool isUserInDatabase(DocumentSnapshot userData) {
    return userData.data() != null;
  }

  Future<bool> validateNotificationToken(DocumentSnapshot userData, User user) async {
    // get user FCM token
    final currentToken = await FirebaseMessaging.instance.getToken();

    try {
      final String? dbToken = userData.get('token');
      // check if current mail is stored in database
      if(dbToken != currentToken){
        try {
          // updating token to match currently used device
          _firestore.collection('users').doc(user.uid).update({"token": currentToken});
        } on Exception {
          return false;
        }
      }
    } on StateError {
      // no 'token' field for this user
      _firestore.collection('users').doc(user.uid).update({"token": currentToken});
    }
    return true;
  }

  Future<bool> validateLocation(DocumentSnapshot userData, User user) async {

    final QuerySnapshot querySnapshot = await _firestore.collection('locations').get();
    final List locations = querySnapshot.docs.map((doc) => doc.id).toList();


    try {
      final String? dbLocationId = userData.get('location_id');
      // check if current location_id is in database
      if(!locations.contains(dbLocationId)){
        try {
          // updating location_id to match any currently valid
          _firestore.collection('users').doc(user.uid).update({"location_id": locations[0]});
        } on Exception {
          return false;
        }
      }
    } on StateError {
      // no 'location_id' field for this user
      _firestore.collection('users').doc(user.uid).update({"location_id": locations[0]});
    }

    return true;
  }

  Future<bool> validateMail(DocumentSnapshot userData, User user) async {
    try {
      final String? dbMail = userData.get('mail');
      // check if current token is stored in database
      if(dbMail != user.email){
        try {
          // updating mail to match currently used device
          _firestore.collection('users').doc(user.uid).update({"mail": user.email});
        } on Exception {
          return false;
        }
      }
    } on StateError {
      // no 'mail' field for this user
      _firestore.collection('users').doc(user.uid).update({"mail": user.email});
    }
    return true;
  }

  Future<bool> validateAndCorrectUserData(DocumentSnapshot userData, User user) async {

    if (!await validateNotificationToken(userData, user)){
      return false;
    }

    if (!await validateLocation(userData, user)){
      return false;
    }

    if (!await validateMail(userData, user)){
      return false;
    }

    return true;

  }

  void createNewAccount(User user) async {

    String? _newUserLocation;
    String? _newUserLanguage;

    // get user FCM token
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // New user
    await Navigator.of(context).pushNamed(DormSelection.routeName, arguments:
    SelectionArguments(
        "Dalej",
            (locationId) => {
              _newUserLocation = locationId,
              Navigator.of(context).pop()
        }));

    if(_newUserLocation == null){
      return;
    }

    await Navigator.of(context).pushNamed(LanguageSelection.routeName, arguments:
    SelectionArguments("Dalej", (language) => {
      _newUserLanguage = language,
      Navigator.of(context).pop()
    }));

    if(_newUserLanguage == null){
      return;
    }

    final String? usersFCMToken = await FirebaseMessaging.instance.getToken();
    prefs.setString("FCM_token", usersFCMToken!);

    addUserIfPossible(user.uid, user.email, _newUserLocation!, _newUserLanguage!, usersFCMToken);
    Navigator.of(context).popUntil((route) => route.settings.name == GoogleLogin.routeName);
  }

  void addUserIfPossible(String userId, String? mail, String? locationId, String? language, String? token){

    if(locationId == null || locationId ==""){
      print("Missing locationId data. User could not be added");
    }
    if(language == null || language ==""){
      print("Missing language data. User could not be added");
    }


    final addData = {
      'mail': mail,
      'language': language,
      'location_id': locationId,
      'token' : token
    };

    // add user document to database
    // key has to be unique because user id is unique
    _firestore.collection('users').doc(userId).set(addData);

  }

  Future<void> _signInWithGoogle() async {

    final GoogleSignIn googleSignIn = GoogleSignIn();

    // get user account
    try{
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount == null){

        return;
      }

      final GoogleSignInAuthentication gsa = await googleSignInAccount.authentication;

      // get credentials necessary for logging in
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: gsa.idToken,
        accessToken: gsa.accessToken,
      );

      // log in to firebase auth
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;
      final User? currentUser = FirebaseAuth.instance.currentUser;
      assert(firebaseUser!.uid == currentUser!.uid);

      // after logged in sing out from google sign in
      googleSignIn.disconnect();
      googleSignIn.signOut();



      // check if document with user id exists in database
      final DocumentSnapshot userData = await _firestore.collection('users').doc(currentUser!.uid).get();

      // check if user exists in database
      if(isUserInDatabase(userData)){

        if(!await validateAndCorrectUserData(userData, currentUser)){
          print("User data in database incorrect and could not be corrected");
          return;
        }

        print("Signed in ${currentUser.displayName}, userId: ${currentUser.uid}");
        devices.restart();
        Navigator.pushReplacementNamed(context, "/");

      } else {

        // New user
        createNewAccount(currentUser);
      }


    } catch (e) {
      FirebaseAuth.instance.signOut();
      print(e);
    }
  }


  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xFFF9F3EE),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).backgroundColor,
        alignment: AlignmentDirectional.center,
        child: Container(
          width: MediaQuery.of(context).size.width*0.9,
          child: Material(
            elevation: 30,
            color: Colors.white,
            shadowColor: Theme.of(context).backgroundColor,
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: AutoSizeText(
                      AppLocalizations.of(context)!.translate('login_text')!,
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 25,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                    child: AutoSizeText(
                      AppLocalizations.of(context)!.translate('login_text_info')!,
                      maxLines: 4,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric( horizontal: 20.0, vertical: 25),
                    child: Material(
                      borderRadius: BorderRadius.circular(40),
                      color: Theme.of(context).accentColor,
                      elevation: 8,
                      shadowColor: Theme.of(context).backgroundColor,
                      child: InkWell(
                        onTap: _signInWithGoogle,
                        borderRadius: BorderRadius.circular(40),
                        splashColor: Colors.black,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: 30,
                                child: Image(
                                  image: AssetImage("res/logo_g.png"),
                                ),
                              ),
                              Container(
                                alignment: AlignmentDirectional.center,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                child: AutoSizeText(
                                  AppLocalizations.of(context)!.translate('login_with_google')!,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
