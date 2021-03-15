import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ustropralki/HomePage.dart';
import 'package:ustropralki/LoginPage.dart';
import 'package:ustropralki/ProfilePage.dart';
import 'package:ustropralki/Widgets/SelectableTile.dart';
import 'package:ustropralki/Widgets/Tile.dart';
import 'package:ustropralki/templates/AppBar.dart';
import 'package:ustropralki/templates/DevicesSingleton.dart';
import 'package:ustropralki/templates/UserSingleton.dart';
import 'package:ustropralki/templates/localization.dart';

import 'Widgets/Texts.dart';

class AdminPage extends StatefulWidget{
  static const routeName = '/admin';

  @override
  State<StatefulWidget> createState() => _AdminPageState();
}


class _AdminPageState extends State<AdminPage>{

  final UstroUserBase _user = UstroUserState();
  final DevicesInfoBase devices = DevicesInfoState();
  final FirebaseAuth _auth = FirebaseAuth.instance;


  void onAddDevice(){
    Navigator.of(context).pushNamed(AddDevicePage.routeName);
  }

  void onAddAdmin(){
    Navigator.of(context).pushNamed(AddAdminPage.routeName);

  }

  void onMyPrivileges(){
    Navigator.of(context).pushNamed(MyPrivilegesPage.routeName);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar("Ustro Pralki", elevation: 10.0, callback: setState,),
        body: Container(
          color: Theme.of(context).backgroundColor,
          alignment: AlignmentDirectional.center,
          child: Column(
            children: <Widget>[

              // header
              Padding(
                padding: const EdgeInsets.fromLTRB(25,25,25,15),
                child: NormalText(
                  AppLocalizations.of(context).translate("admin"),
                  fontSize: 24,
                  color: Colors.grey,
                  fontWeight: FontWeight.w300,
                ),
              ),

              Tile(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    NormalText(
                      AppLocalizations.of(context).translate("all_admins"),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    NormalText(
                      _user.user.email,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    )
                  ],
                ),
              ),
              Tile(
                callback: onAddDevice,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        NormalText(
                            AppLocalizations.of(context).translate("add_device")
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          size: 24,
                          color: Theme.of(context).accentColor,
                        )
                      ],
                    )
                  ],
                ),
              ),
              Tile(
                callback: onAddAdmin,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        NormalText(
                            AppLocalizations.of(context).translate("add_admin")
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          size: 24,
                          color: Theme.of(context).accentColor,
                        )
                      ],
                    )
                  ],
                ),
              ),
              Tile(
                callback: onMyPrivileges,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        NormalText(
                            AppLocalizations.of(context).translate("privileges")
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          size: 24,
                          color: Theme.of(context).accentColor,
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        )
    );
  }
}



class AddDevicePage extends StatefulWidget{
  static const routeName = '/admin/add_device';

  @override
  State<StatefulWidget> createState() => _AddDevicePageState();
}


class _AddDevicePageState extends State<AddDevicePage> {

  final TextEditingController _controller = TextEditingController();
  final UstroUserBase _user = UstroUserState();
  final DevicesInfoBase _devices = DevicesInfoState();

  String _newDeviceName = "";


  Future<void> addNewDevice() async {
    await _devices.createDevice(_newDeviceName, _user.user.locationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar("Ustro Pralki", elevation: 10.0, callback: setState,),
        body: Container(
          color: Theme.of(context).backgroundColor,
          alignment: AlignmentDirectional.center,
          child: Stack(
            alignment: Alignment.center,
            children: [

              // header
              Positioned(
                top: 25,
                child: NormalText(
                  AppLocalizations.of(context).translate("add_device"),
                  fontSize: 24,
                  color: Colors.grey,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Tile(
                    child: Center(
                      child: TextField(
                        controller: _controller,
                        onChanged: (change) => {
                          setState((){
                            _newDeviceName = change;
                          })
                        },
                        textAlign: TextAlign.center,
                        decoration: InputDecoration.collapsed(
                          hintText: AppLocalizations.of(context).translate("device_name"),
                          hintStyle: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w300,
                          )
                        ),
                        style: TextStyle(
                          fontSize: 20,
                          color: const Color(0xFF484848),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Positioned(
                bottom: 20,
                child: Material(
                  borderRadius: BorderRadius.circular(40),
                  animationDuration: Duration(milliseconds: 500),
                  color: _newDeviceName.isEmpty? Theme.of(context).disabledColor : Theme.of(context).accentColor,
                  elevation: _newDeviceName.isEmpty? 0 : 10,
                  shadowColor: Color(0xAAFF6600),
                  child: InkWell(
                    onTap: () async {
                      await addNewDevice();
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(40),
                    splashColor: Colors.black,
                    child: Container(
                      alignment: AlignmentDirectional.center,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                      child: Text(
                        AppLocalizations.of(context).translate('create'),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        )
    );
  }

}


class AddAdminPage extends StatefulWidget{
  static const routeName = '/admin/add_admin';

  @override
  State<StatefulWidget> createState() => _AddAdminPageState();
}


class _AddAdminPageState extends State<AddAdminPage> {

  final TextEditingController _controller = TextEditingController();
  String _newAdminEmail = "";

  Future<void> addNewAdmin(){

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar("Ustro Pralki", elevation: 10.0, callback: setState,),
        body: Container(
          color: Theme.of(context).backgroundColor,
          alignment: AlignmentDirectional.center,
          child: Stack(
            alignment: Alignment.center,
            children: [

              // header
              Positioned(
                top: 25,
                child: NormalText(
                  AppLocalizations.of(context).translate("add_admin"),
                  fontSize: 24,
                  color: Colors.grey,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Tile(
                    child: Center(
                      child: TextField(
                        controller: _controller,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (change) => {
                          setState((){
                            _newAdminEmail = change;
                          })
                        },
                        textAlign: TextAlign.center,
                        decoration: InputDecoration.collapsed(
                            hintText: AppLocalizations.of(context).translate("users_email"),
                            hintStyle: TextStyle(
                              fontSize: 20,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w300,
                            )
                        ),
                        style: TextStyle(
                          fontSize: 20,
                          color: const Color(0xFF484848),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  )
                ],
              ),

              Positioned(
                bottom: 20,
                child: Material(
                  borderRadius: BorderRadius.circular(40),
                  animationDuration: Duration(milliseconds: 500),
                  color: _newAdminEmail.isEmpty? Theme.of(context).disabledColor : Theme.of(context).accentColor,
                  elevation: _newAdminEmail.isEmpty? 0 : 10,
                  shadowColor: Color(0xAAFF6600),
                  child: InkWell(
                    onTap: addNewAdmin,
                    borderRadius: BorderRadius.circular(40),
                    splashColor: Colors.black,
                    child: Container(
                      alignment: AlignmentDirectional.center,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                      child: Text(
                        AppLocalizations.of(context).translate('add'),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        )
    );
  }

}


class MyPrivilegesPage extends StatefulWidget{
  static const routeName = '/admin/privileges';

  @override
  State<StatefulWidget> createState() => _MyPrivilegesPageState();
}


class _MyPrivilegesPageState extends State<MyPrivilegesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar("Ustro Pralki", elevation: 10.0, callback: setState,),
        body: SingleChildScrollView(
          child: Container(
            color: Theme.of(context).backgroundColor,
            alignment: AlignmentDirectional.center,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Tile(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      NormalText(
                        AppLocalizations.of(context).translate("privilege_add_device"),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      NormalText(
                        AppLocalizations.of(context).translate("privilege_add_device_text"),
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      )
                    ],
                  ),
                ),
                Tile(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      NormalText(
                        AppLocalizations.of(context).translate("privilege_edit_device"),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      NormalText(
                        AppLocalizations.of(context).translate("privilege_edit_device_text"),
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      )
                    ],
                  ),
                ),
                Tile(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      NormalText(
                        AppLocalizations.of(context).translate("privilege_add_admin"),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      NormalText(
                        AppLocalizations.of(context).translate("privilege_add_admin_text"),
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      )
                    ],
                  ),
                ),
                Tile(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      NormalText(
                        AppLocalizations.of(context).translate("privilege_improvement"),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      NormalText(
                        AppLocalizations.of(context).translate("privilege_improvement_text"),
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }

}