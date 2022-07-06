

import 'package:flutter/material.dart';

class Tile extends StatelessWidget{

  const Tile({this.child, this.callback, Key? key}) : super(key: key);
  final VoidCallback? callback;
  final Widget? child;

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