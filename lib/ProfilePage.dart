


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ustropralki/templates/AppBar.dart';
import 'package:ustropralki/templates/Drawer.dart';
import 'package:ustropralki/templates/localization.dart';

class ProfilePage extends StatefulWidget{
  static const routeName = '/profile';

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}


class _ProfilePageState extends State<ProfilePage>{


 void showChangeLanguageDialog() {
   showGeneralDialog(
       context: context,
       pageBuilder: (context, anim1, anim2) {return;},
       barrierDismissible: true,
       barrierColor: Colors.white.withOpacity(0.1),
       barrierLabel: '',
       transitionBuilder: (context, anim1, anim2, child) {
         final curvedValue = Curves.easeInOut.transform(anim1.value)- 1.0;
         return Transform(
           transform: Matrix4.translationValues(0, curvedValue*200, 0),
           child: Opacity(
             opacity: anim1.value,
             child: Dialog(
               elevation: 30,
               backgroundColor: Colors.transparent,
               shape: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(25),
                 borderSide: BorderSide.none,
               ),
               child: Container(
                 alignment: AlignmentDirectional.center,
                 width: MediaQuery.of(context).size.width*0.9,
                 height: MediaQuery.of(context).size.height*0.25,
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(25),
                   color: Colors.white,
                 ),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.center,
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: <Widget>[
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                       child: Text(
                         AppLocalizations.of(context).translate('qr_search_fail'),
                         textAlign: TextAlign.center,
                         style: TextStyle(
                           fontWeight: FontWeight.w300,
                           fontSize: 22,
                           color: Colors.black87,
                         ),
                       ),
                     ),
                   ],
                 ),
               ),
             ),
           ),
         );
       },
       transitionDuration: Duration(milliseconds: 400)
   );
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: CustomDrawer(),
        drawerScrimColor: Colors.black26,
        drawerEdgeDragWidth: 100,
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
                  "Ustawienia konta:", // TODO
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
                      "Twoje konto:",
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    NormalText(
                        "asas@asasas",
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
                          "Typ konta:"
                        ),
                        NormalText(
                          "Mieszkaniec",
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        )
                      ],
                    )
                  ],
                ),
              ),
              Tile(
                callback: showChangeLanguageDialog,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        NormalText(
                            "Zmień język",
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
                            "Powiadomienia"
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
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
                            "Wyloguj się"
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



class Tile extends StatelessWidget{

  const Tile({ this.child, this.callback, Key key}) : super(key: key);
  final Function callback;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: InkWell(
        onTap: callback,
        child: Container(
          width: MediaQuery.of(context).size.width*0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0xFF989898).withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 10,
                offset: Offset(0, 5), // changes position of shadow
              )
            ]
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: child,
          ),
        ),
      ),
    );
  }
}



class NormalText extends StatelessWidget{

  NormalText(this.text,{this.fontSize = 18, this.color = const Color(0xFF484848), this.fontWeight = FontWeight.normal, Key key}) : super(key: key);

  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
      ),
    );
  }


}