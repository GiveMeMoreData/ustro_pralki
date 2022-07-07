import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ustropralki/HomePage.dart';
import 'package:ustropralki/LoginPage.dart';
import 'package:ustropralki/ProfilePage/DormSelection.dart';
import 'package:ustropralki/ProfilePage/LanguageSelection.dart';
import 'package:ustropralki/Widgets/Tile.dart';
import 'package:ustropralki/templates/AppBar.dart';
import 'package:ustropralki/templates/DevicesSingleton.dart';
import 'package:ustropralki/templates/UserSingleton.dart';
import 'package:ustropralki/templates/localization.dart';

import '../Widgets/Texts.dart';

class ProfilePage extends StatefulWidget{
  static const routeName = '/profile';

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}


class _ProfilePageState extends State<ProfilePage>{

  final UstroUserBase _user = UstroUserState();
  final DevicesInfoBase devices = DevicesInfoState();

  void onChangeDorm() {
    Navigator.of(context).pushNamed(DormSelection.routeName, arguments:
    SelectionArguments(
        AppLocalizations.of(context)!.translate("save")!,
      (locationId) async {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) {
              return Dialog(
                elevation: 0,
                insetPadding: EdgeInsets.all(10),
                backgroundColor: Colors.transparent,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 40,
                        height: 40,
                        child: CircularProgressIndicator()
                    ),
                  ],
                ),
              );
            }
        );
        devices.restart();
        await _user.updateLocation(locationId);
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).pushReplacementNamed(MyHomePage.routeName);
        Navigator.of(context).pushNamed(ProfilePage.routeName);
      },
      selectionArgument: _user.user.locationId!
    ));
  }

 void onChangeLanguage() {
   Navigator.of(context).pushNamed(LanguageSelection.routeName, arguments:
   SelectionArguments(
       AppLocalizations.of(context)!.translate("save")!,
           (language) => {
         _user.updateLanguage(language, context),
             Navigator.of(context).popUntil((route) => route.isFirst),
             Navigator.of(context).pushReplacementNamed(MyHomePage.routeName),
             Navigator.of(context).pushNamed(ProfilePage.routeName)
       },
       selectionArgument: _user.user.language!
   ));
 }


 void onLogOut(){
   Navigator.of(context).popUntil((route) => route.isFirst);
   FirebaseAuth.instance.signOut();
   _user.restart();
   Navigator.of(context).pushReplacementNamed(GoogleLogin.routeName);
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
                  AppLocalizations.of(context)!.translate("account_settings")!,
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
                      AppLocalizations.of(context)!.translate("your_account")!,
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    NormalText(
                        _user.user.email!,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    )
                  ],
                ),
              ),
              Tile(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        NormalText(
                            AppLocalizations.of(context)!.translate("account_type")!
                        ),
                        NormalText(
                          _user.user.isAdmin? AppLocalizations.of(context)!.translate("admin_role")! : AppLocalizations.of(context)!.translate("inhabitant_role")!,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        )
                      ],
                    )
                  ],
                ),
              ),
              Tile(
                callback: onChangeLanguage,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        NormalText(
                            AppLocalizations.of(context)!.translate("change_lang")!
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
                callback: onChangeDorm,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        NormalText(
                            AppLocalizations.of(context)!.translate("change_dorm")!
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
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        NormalText(
                            AppLocalizations.of(context)!.translate("change_notifications")!
                        ),
                        Container(
                          height: 20,
                          child: Switch.adaptive(
                              value: _user.user.FCMToken!=null,
                              onChanged: (_value) => setState((){
                                _user.updateNotifications(_value);
                              }),
                            activeColor: Theme.of(context).accentColor,
                            inactiveTrackColor: Theme.of(context).accentColor.withOpacity(0.5),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Tile(
                callback: onLogOut,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        NormalText(
                            AppLocalizations.of(context)!.translate("logout")!
                        ),
                        Icon(
                          Icons.power_settings_new,
                          size: 24,
                          color: Theme.of(context).accentColor,
                        )
                      ],
                    )
                  ],
                ),
              )


            ],
          ),
        )
    );
  }
}


class SelectionArguments{

  final String bottomButtonText;
  final Function callback;
  final String? selectionArgument;

  SelectionArguments(this.bottomButtonText, this.callback, {this.selectionArgument});

}

