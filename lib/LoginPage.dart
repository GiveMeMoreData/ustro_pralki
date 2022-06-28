
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ustropralki/ProfilePage.dart';
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


  Future<bool> checkIfUserInDatabase(User user) async {

    // check if document with user id exists in database
    final DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();

    // get user FCM token
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(userData.data() != null){
      // check if current token is valid
      if(userData.get('token') == prefs.get('FCM_token')){ // TODO check is this works
        // document exists with valid token. no action is necessary
        return true;
      }
      // updating token to match currently used device
      _firestore.collection('users').doc(user.uid).update({"token": prefs.get('FCM_token')});
      return true;
    }

    return false;
  }

  void createNewAccount(User user) async {

    String _newUserLocation;
    String _newUserLanguage;

    // get user FCM token
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // New user
    await Navigator.of(context).pushNamed(DormSelection.routeName, arguments:
    SelectionArguments(
        "Dalej",
            (locationId) => {
              _newUserLocation = locationId
        }));

    if(_newUserLocation == null){
      return;
    }

    await Navigator.of(context).pushNamed(LanguageSelection.routeName, arguments:
    SelectionArguments("Dalej", (language) => {
      _newUserLanguage = language,
    }));

    if(_newUserLanguage == null){
      return;
    }

    Navigator.of(context).popUntil((route) => route.settings.name == GoogleLogin.routeName);
    addUserIfPossible(user.uid, _newUserLocation, _newUserLanguage, prefs.get('FCM_token'));
  }

  void addUserIfPossible(String userId, String locationId, String language, String token){

    if(locationId == null || locationId ==""){
      print("Missing locationId data. User could not be added");
    }
    if(language == null || language ==""){
      print("Missing language data. User could not be added");
    }


    final addData = {
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
      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
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
      final User firebaseUser = userCredential.user;
      final User currentUser = FirebaseAuth.instance.currentUser;
      assert(firebaseUser.uid == currentUser.uid);

      // after logged in sing out from google sign in
      googleSignIn.disconnect();
      googleSignIn.signOut();


      // check if user exists in database
      if(await checkIfUserInDatabase(currentUser)){
        print("Signed in ${currentUser.displayName}, userId: ${currentUser.uid}");
        devices.restart();
        Navigator.pushReplacementNamed(context, "/");
      } else {
        // New user

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
                      AppLocalizations.of(context).translate('login_text'),
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
                      AppLocalizations.of(context).translate('login_text_info'),
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
                                  AppLocalizations.of(context).translate('login_with_google'),
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
