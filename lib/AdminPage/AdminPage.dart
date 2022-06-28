import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ustropralki/AdminPage/AddAdminPage.dart';
import 'package:ustropralki/AdminPage/AddDevicePage.dart';
import 'package:ustropralki/AdminPage/MyPrivelagesPage.dart';
import 'package:ustropralki/Widgets/Tile.dart';
import 'package:ustropralki/templates/AppBar.dart';
import 'package:ustropralki/templates/DevicesSingleton.dart';
import 'package:ustropralki/templates/UserSingleton.dart';
import 'package:ustropralki/templates/localization.dart';

import '../Widgets/Texts.dart';

class AdminPage extends StatefulWidget{
  static const routeName = '/admin';

  @override
  State<StatefulWidget> createState() => _AdminPageState();
}


class _AdminPageState extends State<AdminPage>{

  final UstroUserBase _user = UstroUserState();
  final DevicesInfoBase devices = DevicesInfoState();


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
