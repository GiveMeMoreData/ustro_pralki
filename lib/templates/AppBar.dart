
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ustropralki/templates/localization.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget{

  final String title;
  final double elevation;
  final double height;
  final bool languageWidgetEnabled;
  Function? callback;

  CustomAppBar(this.title, {this.elevation = 2, this.height = kToolbarHeight, this.callback, this.languageWidgetEnabled = false});

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      brightness: Brightness.light,
      title: Text(
        title,
        style: TextStyle(
          color: Color(0xFFE55900),
          fontSize: 25,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: <Widget>[
        Visibility(
          visible: languageWidgetEnabled,
          child: LanguageWidget(callback: callback,),
        ),
      ],
      backgroundColor: Colors.white,
      titleSpacing: 10,
      iconTheme: IconThemeData( color: Color(0xDDE55900)),
      elevation: elevation,
    );
  }
}



class LanguageWidget extends StatefulWidget{
  final callback;

  LanguageWidget({this.callback});

  @override
  State<StatefulWidget> createState() => _LanguageWidgetState();
}

class _LanguageWidgetState extends State<LanguageWidget>{

  bool _polishLanguageSelected = true;
  late SharedPreferences prefs;

  void checkLanguage() async {
    prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey('language')){
      _polishLanguageSelected = prefs.getString('language') == 'pl';
    }
  }

  @override
  void initState() {
    super.initState();
    checkLanguage();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        alignment: AlignmentDirectional.center,
        child: GestureDetector(
          onTap: () async {
            if(!_polishLanguageSelected){
              await AppLocalizations.of(context)!.loadNewLocale(Locale('pl',''));
              prefs.setString('language', 'pl');
            } else {
              await AppLocalizations.of(context)!.loadNewLocale(Locale('en',''));
              prefs.setString('language', 'en');
            }
            _polishLanguageSelected = !_polishLanguageSelected;
            widget.callback((){});
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 30,
                    alignment: Alignment.center,
                    child: AutoSizeText(
                      "PL",
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: _polishLanguageSelected? Theme.of(context).primaryColor : Color(0xFF484848),
                        fontSize: 16
                      ),
                    ),
                  ),
                  Container(
                    width: 45,
                    alignment: Alignment.center,
                    child: AutoSizeText(
                      "ENG",
                      maxLines: 1,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: _polishLanguageSelected? Color(0xFF484848) : Theme.of(context).primaryColor,
                          fontSize: 16
                      ),
                    ),
                  )
                ],
              ),
              AnimatedContainer(
                width: 75,
                alignment: _polishLanguageSelected? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
                child: AnimatedContainer(
                  width: _polishLanguageSelected? 30 : 45,
                  height: 2.5,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOutCubic,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}