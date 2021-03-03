import 'package:flutter/material.dart';
import 'package:ustropralki/templates/AppBar.dart';

class DeviceDetailsPage extends StatefulWidget {
  static const routeName = '/home/device_details';
  @override
  _DeviceDetailsPageState createState() => _DeviceDetailsPageState();
}

class _DeviceDetailsPageState extends State<DeviceDetailsPage> {

  Future<void> loadDetails(){

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar("Ustro Pralki", elevation: 10.0, callback: setState,),
      body: Container(
        color: Theme.of(context).backgroundColor,
        alignment: AlignmentDirectional.center,
      ),
    );
  }
}
