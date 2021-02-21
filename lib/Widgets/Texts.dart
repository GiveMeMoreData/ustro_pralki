import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class NormalText extends StatelessWidget{

  NormalText(this.text,{this.fontSize = 18, this.color = const Color(0xFF484848), this.fontWeight = FontWeight.normal, Key key}) : super(key: key);

  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
      ),
    );
  }


}