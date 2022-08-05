

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ustropralki/AdminPage/AdminPage.dart';
import 'package:ustropralki/HomePage.dart';
import 'package:ustropralki/LoginPage.dart';
import 'package:ustropralki/ProfilePage/ProfilePage.dart';
import 'package:ustropralki/templates/UserSingleton.dart';
import 'package:ustropralki/templates/localization.dart';


class CustomDrawer extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _CustomDrawerState();

}



class _CustomDrawerState extends State<CustomDrawer>{

  final UstroUserBase user = UstroUserState();

  static const double? iconSize = 28;
  static const double? iconFontSize = 22;

  Widget adminPanelWidget(bool isAdmin){
    if (!isAdmin) {
      // draw nothing
      return Container();
    }

    return GestureDetector(
      onTap: (){
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).popAndPushNamed(AdminPage.routeName);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                width: 60,
                alignment: Alignment.center,
                child: Icon(Icons.build_outlined, size: iconSize, color: Theme.of(context).accentColor,)
            ),
            SizedBox(
              width: 20,
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: AutoSizeText(
                  AppLocalizations.of(context)!.translate('admin_page')!,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: iconFontSize,
                    fontWeight: FontWeight.w300,
                    color: Colors.black ,
                  )
              ),
            ),
          ],
        ),
      ),
    );

  }


  @override
  Widget build(BuildContext context) {

    return Drawer(
      child: Column(
        children: <Widget>[

          // drawer header
          Material(
            elevation: 5,
            child: Container(
              color: Colors.white,
              height: kToolbarHeight + MediaQuery.of(context).padding.top,
              alignment: AlignmentDirectional.bottomStart,
              child: Padding(
                padding: const EdgeInsets.symmetric( vertical: 10, horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: Navigator.of(context).pop,
                        child: Icon(
                          Icons.arrow_back,
                          color: Theme.of(context).accentColor,
                          size: 30,
                        )
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    AutoSizeText(
                      "Menu",
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          // spacer
          SizedBox(
            height: 40,
          ),


          // user's profile
          GestureDetector(
            onTap: (){
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).popAndPushNamed(ProfilePage.routeName);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 60,
                    alignment: Alignment.center,
                    child: Icon(Icons.person_outline_rounded , size: (iconSize! + 4), color: Theme.of(context).accentColor,)
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: AutoSizeText(
                        AppLocalizations.of(context)!.translate('profile')!,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: iconFontSize,
                          fontWeight: FontWeight.w300,
                          color: Colors.black ,
                        )
                    ),
                  ),
                ],
              ),
            ),
          ),

          if(user.user.isAdmin)
            SizedBox(
              height: 20,
            ),


          adminPanelWidget(user.user.isAdmin),

          // spacer
          SizedBox(
            height: 20,
          ),

          // log out button
          GestureDetector(
            onTap: (){
              Navigator.of(context).popUntil((route) => route.isFirst);
              FirebaseAuth.instance.signOut();
              user.restart();
              Navigator.of(context).pushReplacementNamed(GoogleLogin.routeName);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 60,
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      "res/logout.svg",
                      height: iconSize,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    alignment: AlignmentDirectional.centerStart,
                    child: AutoSizeText(
                        AppLocalizations.of(context)!.translate('logout')!,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: iconFontSize,
                          fontWeight: FontWeight.w300,
                          color: Colors.black ,
                        )
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

}