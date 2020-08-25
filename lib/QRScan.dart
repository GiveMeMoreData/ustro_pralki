

import 'package:flutter/material.dart';
import 'package:ustropralki/templates/AppBar.dart';

class QRScan extends StatefulWidget{
  static const routeName = '/scan';
  @override
  State<StatefulWidget> createState() => _QRScanState();

}


class _QRScanState extends State<QRScan>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        "Skan QR"
      ),
      body: Container(
        color: Colors.green,
        child: RaisedButton(
          onPressed: () async {
          },
          child: Text("Skan"),
        ),
      ),
    );
  }



}