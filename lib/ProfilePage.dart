import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ustropralki/HomePage.dart';
import 'package:ustropralki/LoginPage.dart';
import 'package:ustropralki/Widgets/SelectableTile.dart';
import 'package:ustropralki/Widgets/Tile.dart';
import 'package:ustropralki/templates/AppBar.dart';
import 'package:ustropralki/templates/DevicesSingleton.dart';
import 'package:ustropralki/templates/UserSingleton.dart';
import 'package:ustropralki/templates/localization.dart';

import 'Widgets/Texts.dart';

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
        AppLocalizations.of(context).translate("save"),
      (locationId) => {
        devices.restart(),
        _user.updateLocation(locationId),
        Navigator.of(context).popUntil((route) => route.isFirst),
        Navigator.of(context).pushReplacementNamed(MyHomePage.routeName),
        Navigator.of(context).pushNamed(ProfilePage.routeName)
      },
      selectionArgument: _user.user.locationId
    ));
  }

 void onChangeLanguage() {
   Navigator.of(context).pushNamed(LanguageSelection.routeName, arguments:
   SelectionArguments(
       AppLocalizations.of(context).translate("save"),
           (language) => {
         _user.updateLanguage(language, context),
             Navigator.of(context).popUntil((route) => route.isFirst),
             Navigator.of(context).pushReplacementNamed(MyHomePage.routeName),
             Navigator.of(context).pushNamed(ProfilePage.routeName)
       },
       selectionArgument: _user.user.language
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
                  AppLocalizations.of(context).translate("account_settings"),
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
                      AppLocalizations.of(context).translate("your_account"),
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
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        NormalText(
                            AppLocalizations.of(context).translate("account_type")
                        ),
                        NormalText(
                          _user.user.isAdmin? AppLocalizations.of(context).translate("admin_role") : AppLocalizations.of(context).translate("inhabitant_role"),
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
                            AppLocalizations.of(context).translate("change_lang")
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
                            AppLocalizations.of(context).translate("change_dorm")
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
                            AppLocalizations.of(context).translate("change_notifications")
                        ),
                        Container(
                          height: 20,
                          child: Switch.adaptive(
                              value: _user.user.FCMToken!=null,
                              onChanged: (_value) => setState((){
                                // _user.updateNotifications(_value); # TODO
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
                            AppLocalizations.of(context).translate("logout")
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
  final String selectionArgument;

  SelectionArguments(this.bottomButtonText, this.callback, {this.selectionArgument});

}

class DormSelection extends StatefulWidget{
  static const routeName ="/login/dorm";

  @override
  State<StatefulWidget> createState() => _DormSelectionState();

}


class _DormSelectionState extends State<DormSelection>{


  SelectionArguments args;
  int selected = -1;
  List<QueryDocumentSnapshot> locations;

  Future<void> getLocations() async {
    if(locations == null){
      final _locations = await FirebaseFirestore.instance.collection('locations').get();

      locations =_locations.docs;
      if(args != null && args.selectionArgument != null){
        selected = locations.indexWhere((doc) => doc.id == args.selectionArgument);
      }

      setState(() {});
    }
  }

  void loadArgs() {
    if(args != null) {
      return;
    }
    args = ModalRoute.of(context).settings.arguments;
  }

  @override
  void initState() {
    super.initState();
    getLocations();
  }

  @override
  Widget build(BuildContext context) {
    loadArgs();
    return Scaffold(
      appBar: CustomAppBar(
          "UstroPralki"
      ),
      body: SizedBox.expand(
        child: Container(
          color: Theme.of(context).backgroundColor,
          alignment: AlignmentDirectional.center,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [

              Builder(
                builder: (context){
                  if(locations != null){
                    return ListView(
                      children: [

                        ///
                        /// header
                        ///
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0,30,0,22),
                            child: NormalText(
                              AppLocalizations.of(context).translate("select_dorm"),
                              fontSize: 24,
                              color: Colors.grey,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),

                        ListView.builder(
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: locations.length+1,
                          itemBuilder: (context, index){

                            ///
                            /// footer
                            ///
                            if(index==locations.length){
                              return SizedBox(
                                height: 90,
                              );
                            }
                            ///
                            /// list element
                            ///
                            return
                              SelectableTile(
                                selected: index == selected,
                                leading:
                                NormalText(
                                  locations[index].get('name'),
                                ),
                                onTap: (){
                                  setState(() {
                                    index == selected? selected = -1 : selected = index;
                                  });
                                },
                                trailing: SizedBox(
                                  height: 28,
                                  child: Visibility(
                                    visible: selected==index,
                                    child: SvgPicture.asset(
                                      "res/check.svg",
                                      height: 28,
                                    ),
                                  ),
                                ),
                              );
                          },
                        )
                      ],
                    );

                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
              Positioned(
                bottom: 20,
                child: Material(
                  borderRadius: BorderRadius.circular(40),
                  color: selected == -1? Theme.of(context).disabledColor : Theme.of(context).colorScheme.secondary,
                  elevation: selected == -1? 0 : 10,
                  shadowColor: Color(0xAAFF6600),
                  animationDuration: Duration(milliseconds: 700),
                  child: InkWell(
                    onTap: () {
                      if( selected != -1){
                        args.callback(locations[selected].id);
                      }
                    },
                    borderRadius: BorderRadius.circular(40),
                    splashColor: Colors.black,
                    child: Container(
                      alignment: AlignmentDirectional.center,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                      child: Text(
                        args.bottomButtonText,
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
        ),
      ),
    );
  }

}

class LanguageSelection extends StatefulWidget{
  static const routeName = "/login/language";

  @override
  State<StatefulWidget> createState() => _LanguageSelectionState();
}


class _LanguageSelectionState extends State<LanguageSelection>{

  int selected = -1;

  Map<String, String> _languages = {
    "pl": "Polski",
    "en": "English",
  };

  SelectionArguments args;

  void loadArgs() {
    if(args != null) {
      return;
    }
    args = ModalRoute.of(context).settings.arguments;

    if(args != null && args.selectionArgument != null){
      selected = _languages.keys.toList().indexWhere((lang) => lang == args.selectionArgument);
    }
  }

  @override
  Widget build(BuildContext context) {
    loadArgs();
    return Scaffold(
      appBar: CustomAppBar(
          "UstroPralki"
      ),
      body: SizedBox.expand(
        child: Container(
          color: Theme.of(context).backgroundColor,
          alignment: AlignmentDirectional.center,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [

              ListView(
                children: [

                  ///
                  /// header
                  ///
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0,30,0,22),
                      child: NormalText(
                        AppLocalizations.of(context).translate("select_lang"),
                        fontSize: 24,
                        color: Colors.grey,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),

                  ListView.builder(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _languages.length+1,
                    itemBuilder: (context, index){

                      ///
                      /// footer
                      ///
                      if(index==_languages.length){
                        return SizedBox(
                          height: 90,
                        );
                      }
                      ///
                      /// list element
                      ///
                      return
                        SelectableTile(
                          selected: index == selected,
                          leading: NormalText(
                            _languages.values.toList()[index],
                          ),
                          onTap: (){
                            setState(() {
                              index == selected? selected = -1 : selected = index;
                            });
                          },
                        );
                    },
                  )
                ],
              ),
              Positioned(
                bottom: 20,
                child: Material(
                  borderRadius: BorderRadius.circular(40),
                  animationDuration: Duration(milliseconds: 500),
                  color: selected == -1? Theme.of(context).disabledColor : Theme.of(context).accentColor,
                  elevation: selected == -1? 0 : 10,
                  shadowColor: Color(0xAAFF6600),
                  child: InkWell(
                    onTap: () {
                      if(selected != -1){
                        args.callback(_languages.keys.toList()[selected]);
                      }
                    },
                    borderRadius: BorderRadius.circular(40),
                    splashColor: Colors.black,
                    child: Container(
                      alignment: AlignmentDirectional.center,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                      child: Text(
                        args.bottomButtonText,
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
        ),
      ),
    );

  }

}