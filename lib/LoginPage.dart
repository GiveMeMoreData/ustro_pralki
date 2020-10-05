
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ustropralki/templates/localization.dart';
import 'package:auto_size_text/auto_size_text.dart';


class GoogleLogin extends StatefulWidget{
  static const routeName = '/login/google';

  @override
  State<StatefulWidget> createState() => _GoogleLoginState();
}

class _GoogleLoginState extends State<GoogleLogin>{

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> checkIfUserInDatabase(User user) async {

    // check if document with user id exists in database
    final DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();

    if(userData.data() != null){
      // document exists no action is necessary
      return;
    }

    // get user FCM token
    SharedPreferences prefs = await SharedPreferences.getInstance();


    final addData = {
      'language': 'pl',
      'location_id': 'SGzpuhHAIrTPWJJdRnli',
      'tokens' : [prefs.get('FCM_token')]
    };

    // add user document to database
    // key has to be unique because user id is unique
    _firestore.collection('users').doc(user.uid).set(addData);


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
      await checkIfUserInDatabase(currentUser);

      print("Signed in ${currentUser.displayName}, userId: ${currentUser.uid}");
      Navigator.pushReplacementNamed(context, "/");

    } catch (e) {
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


      // body: Material(
      //   color: Theme.of(context).backgroundColor,
      //   child: InkWell(
      //     onTap: _signInWithGoogle,
      //     splashColor: Theme.of(context).primaryColor,
      //     child: Container(
      //       color: Colors.transparent,
      //       alignment: AlignmentDirectional.center,
      //       child: Stack(
      //         alignment: AlignmentDirectional.center,
      //         children: <Widget>[
      //           Align(
      //             alignment: AlignmentDirectional.bottomCenter,
      //             child: AutoSizeText(
      //               "Zaloguj",
      //               textAlign: TextAlign.center,
      //               maxLines: 1,
      //               style: TextStyle(
      //                 fontWeight: FontWeight.w900,
      //                 fontSize: 200,
      //                 height: 1.5,
      //                 color: Colors.white,
      //               ),
      //             ),
      //           ),
      //           Container(
      //             width: 60,
      //             height: 60,
      //             decoration: BoxDecoration(
      //               image: DecorationImage(
      //                 image: AssetImage("res/google_logo.png")
      //               )
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
    );
  }


}

