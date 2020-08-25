
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget{

  final String title;
  final double elevation;
  final double height;

  CustomAppBar(this.title, {this.elevation = 2, this.height = kToolbarHeight});

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
        LanguageWidget(),
      ],
      backgroundColor: Colors.white,
      titleSpacing: 30,
      iconTheme: IconThemeData( color: Color(0xDDE55900) ),
      elevation: elevation,
    );
  }
}



class LanguageWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _LanguageWidgetState();
}

class _LanguageWidgetState extends State<LanguageWidget>{

  //todo load from locale properties
  bool _polishLanguageSelected = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        alignment: AlignmentDirectional.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              children: <Widget>[
                GestureDetector(
                  onTap: (){
                    if(!_polishLanguageSelected){
                      setState(() {
                        _polishLanguageSelected = !_polishLanguageSelected;
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Text(
                      "PL",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: _polishLanguageSelected? Theme.of(context).primaryColor : Colors.black87,
                        fontSize: 16
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    if(_polishLanguageSelected){
                      setState(() {
                        _polishLanguageSelected = !_polishLanguageSelected;
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Text(
                      "ENG",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: _polishLanguageSelected? Colors.black87 : Theme.of(context).primaryColor,
                          fontSize: 16
                      ),
                    ),
                  ),
                )
              ],
            ),
            AnimatedContainer(
              alignment: _polishLanguageSelected? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
              width: 82,
              child: AnimatedContainer(
                width: _polishLanguageSelected? 34 : 49,
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: Theme.of(context).primaryColor,
                ),
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
              ),
            )
          ],
        ),
      ),
    );
  }

}