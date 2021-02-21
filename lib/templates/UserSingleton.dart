import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ustropralki/templates/localization.dart';

class UstroUser{

  @protected
  String id;
  @protected
  String email;
  @protected
  String name;
  @protected
  String language;
  @protected
  String locationId;
  @protected
  // ignore: non_constant_identifier_names
  String FCMToken;

  void setId(String newId){
    id = newId;
  }
  void setName(String newName) {
    name = newName;
  }
  void setEmail(String newEmail) {
    email = newEmail;
  }
  void setLanguage(String newLanguage) {
    language = newLanguage;
  }
  void setLocationId(String newLocationId) {
    locationId = newLocationId;
  }
  void setFCMToken(String newFCMToken){
    FCMToken = newFCMToken;
  }

  UstroUser({this.id, this.email, this.name, this.language, this.locationId, this.FCMToken});
}


abstract class UstroUserBase{

  @protected
  UstroUser user;

  @protected
  UstroUser initialUser;


  Future<void> loadUserFromFirebaseAuthUser(User _user) async {

    if(_user == null){
      return;
    }

    if(_user.uid == "" || _user.uid == null){
      return;
    }

    final DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(_user.uid).get();

    //checking if user data was successfully loaded and can be read
    if(userData == null || !userData.exists){
      print("[ERROR] Unsupported error occured while geting user data");
      return;
    }

    // Checking if user data is loaded and contains information
    if(userData.data() == null || userData.data().isEmpty){
      print("[ERROR] Unsupported error occured. There is no data stored for passed userId ${_user.uid}.uid");
      return;
    }

    //user exists and we should be able to read all necessary information
    user.setId(_user.uid);
    user.setName(_user.displayName);
    user.setEmail(_user.email);
    user.setLanguage(userData.get("language"));
    user.setFCMToken(userData.get("token"));
    user.setLocationId(userData.get("location_id"));

    print("[INFO] User loaded");
    return;
  }

  void updateNotifications(bool receiveNotifications) {
    if(receiveNotifications){
      // get new FMC token, save and send to DB
      final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
      _firebaseMessaging.getToken().then((value) => {
        updateFCMToken(value)
      });
    } else {
      // delete token from DB
      updateFCMToken(null);
    }
  }

  void updateFCMToken(var newToken){
    if(newToken == user.FCMToken){
      return;
    }
    user.setFCMToken(newToken);
    updateUserData(fieldName: "token", fieldNewValue: newToken);
  }

  void updateLocation(String newLocationId){
    if(newLocationId == user.locationId){
      return;
    }
    user.setLocationId(newLocationId);
    updateUserData(fieldName: "location_id", fieldNewValue: newLocationId);
  }
  void updateLanguage(String newLanguage, BuildContext context) async {
    if(newLanguage == user.language){
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('language', newLanguage);
    AppLocalizations.of(context).loadNewLocale(Locale(newLanguage, ''));
    user.setLanguage(newLanguage);
    updateUserData(fieldName: "language", fieldNewValue: newLanguage);

  }

  void updateUserData({Map<String, dynamic> updateData, String fieldName, dynamic fieldNewValue}){
    if(updateData != null && updateData.isNotEmpty){
      FirebaseFirestore.instance.collection('users').doc(user.id).set(updateData,SetOptions(merge: true));
    }
    if(fieldName != null){
      FirebaseFirestore.instance.collection('users').doc(user.id).set({fieldName : fieldNewValue},SetOptions(merge: true));
    } else {
      print("[ERROR] Incorrect data passed to updateDataUser. Update wasn't possible due to lack of necessary data.");
      return;
    }
    print("[INFO] Update for ${user.id} send");
  }

  void restart() {
    user = initialUser;
  }
}

class UstroUserState extends UstroUserBase {
  static final UstroUserState _instance = UstroUserState._internal();

  factory UstroUserState() {
    return _instance;
  }


  UstroUserState._internal() {
    initialUser = UstroUser();
    user = initialUser;
  }
}