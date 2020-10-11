
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_countdown_timer/countdown_timer.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:ustropralki/templates/localization.dart';

import 'templates/AppBar.dart';
import 'templates/Drawer.dart';
import 'templates/DevicesSingleton.dart';

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final User _user = FirebaseAuth.instance.currentUser;

  final DevicesInfoBase devices = DevicesInfoState();
  TimeOfDay _endTime = TimeOfDay(hour: 1, minute: 0);

  void useDevice(String deviceId, Timestamp endTime){
    setState(() {
      devices.useDevice(deviceId, _user.uid, endTime);
    });
  }
  void freeDevice(String deviceId){
    setState(() {
      devices.freeDevice(deviceId, _user.uid);
    });
  }


  void listenForFirebaseChange() async {
    FirebaseFirestore.instance.collection('devices').snapshots().listen((data) {
      devices.updateDevicesFromChangesList(data.docChanges);
      if(mounted){
        setState(() {
          print("[INFO] Database changed, update");
        });
      }
    });
  }

  void createReport(String deviceId){
    FirebaseFirestore.instance.collection('reports').add({
      "device_id": deviceId,
      "user_id": _user.uid,
    });
  }

  void checkQRCode(String scanResult){
    if(devices.deviceMap.containsKey(scanResult)){
      if(!devices.deviceMap[scanResult].enabled){
        deviceDisabled();
      } else {
        if(devices.deviceMap[scanResult].available){
          startUsingDeviceDialog(scanResult);
        } else {
          deviceOccupiedDialog(scanResult);
        }
      }
    } else {
      cannotFindDevice();
    }
  }

  void cannotFindDevice(){
    showGeneralDialog(
        context: context,
        pageBuilder: (context, anim1, anim2) {},
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
                      Icon(
                        Icons.sentiment_dissatisfied,
                        size: 42,
                        color: Theme.of(context).primaryColor,
                      )
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

  void deviceDisabled(){
    showGeneralDialog(
        context: context,
        pageBuilder: (context, anim1, anim2) {},
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
                          AppLocalizations.of(context).translate('qr_search_disabled'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 22,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.sentiment_dissatisfied,
                        size: 42,
                        color: Theme.of(context).primaryColor,
                      )
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

  void startUsingDeviceDialog(String deviceId){
    showGeneralDialog(
        context: context,
        pageBuilder: (context, anim1, anim2) {},
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
                backgroundColor: Colors.white,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical : 25.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(35,0,35,25),
                        child: Text(
                          AppLocalizations.of(context).translate('make_laundry'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 25,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          AppLocalizations.of(context).translate('wash_time'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final _newTime = await showTimePicker(
                              context: context,
                              initialTime: _endTime,
                          );
                          if(_newTime != null){
                            setState(() {
                              _endTime = _newTime;
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          child: Text(
                            _endTime.hour!=null? _endTime.minute!=null? "${_endTime.hour}h ${_endTime.minute}m"  : "${_endTime.hour}h 00m" : "${_endTime.minute}m",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        child: Material(
                          borderRadius: BorderRadius.circular(40),
                          color: Theme.of(context).accentColor,
                          elevation: 8,
                          shadowColor: Color(0xAAFF6600),
                          child: InkWell(
                            onTap: (){
                              final _finalEndTime = Timestamp.fromMillisecondsSinceEpoch(DateTime.now().add(Duration(hours: _endTime.hour, minutes: _endTime.minute)).millisecondsSinceEpoch);
                              useDevice(deviceId, _finalEndTime);
                              Navigator.of(context).pop();
                            },
                            borderRadius: BorderRadius.circular(40),
                            splashColor: Colors.black,
                            child: Container(
                              alignment: AlignmentDirectional.center,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                              child: Text(
                                AppLocalizations.of(context).translate('begin'),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          reportBrokenDeviceDialog(deviceId);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          child: Text(
                            AppLocalizations.of(context).translate('report_broken_device'),
                            maxLines: 1,
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              decoration: TextDecoration.underline,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
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

  void freeDeviceDialog(String deviceId){
    showGeneralDialog(
        context: context,
        pageBuilder: (context, anim1, anim2) {},
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
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height*0.45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 25),
                        child: Text(
                          AppLocalizations.of(context).translate('free_device'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 25,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Text(
                          AppLocalizations.of(context).translate('free_device_info'),
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Material(
                              borderRadius: BorderRadius.circular(40),
                              color: Theme.of(context).backgroundColor,
                              elevation: 0,
                              child: InkWell(
                                splashColor: Colors.transparent,
                                onTap: (){
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  alignment: AlignmentDirectional.center,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                                  child: Text(
                                    AppLocalizations.of(context).translate('no'),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).accentColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Icon(null, size: 15),
                            Material(
                              borderRadius: BorderRadius.circular(40),
                              color: Theme.of(context).accentColor,
                              elevation: 8,
                              shadowColor: Color(0xAAFF6600),
                              child: InkWell(
                                onTap: (){
                                  freeDevice(deviceId);
                                  Navigator.of(context).pop();
                                  afterDeviceFreed(deviceId);
                                },
                                borderRadius: BorderRadius.circular(40),
                                splashColor: Colors.black,
                                child: Container(
                                  alignment: AlignmentDirectional.center,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                                  child: Text(
                                    AppLocalizations.of(context).translate('yes'),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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

  void afterDeviceFreed(String deviceId){
    showGeneralDialog(
        context: context,
        pageBuilder: (context, anim1, anim2) {},
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
                backgroundColor: Colors.white,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        child: AutoSizeText(
                          AppLocalizations.of(context).translate('device_freed'),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 25,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                        child: AutoSizeText(
                          AppLocalizations.of(context).translate('device_freed_info'),
                          maxLines: 3,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Material(
                              borderRadius: BorderRadius.circular(40),
                              color: Theme.of(context).backgroundColor,
                              elevation: 0,
                              child: InkWell(
                                splashColor: Colors.transparent,
                                onTap: (){
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  alignment: AlignmentDirectional.center,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                  child: AutoSizeText(
                                    AppLocalizations.of(context).translate('back'),
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).accentColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Icon(null, size: 15),
                            Material(
                              borderRadius: BorderRadius.circular(40),
                              color: Theme.of(context).accentColor,
                              elevation: 8,
                              shadowColor: Color(0xAAFF6600),
                              child: InkWell(
                                onTap: (){
                                  Navigator.of(context).pop();
                                  startUsingDeviceDialog(deviceId);
                                },
                                borderRadius: BorderRadius.circular(40),
                                splashColor: Colors.black,
                                child: Container(
                                  alignment: AlignmentDirectional.center,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                  child: AutoSizeText(
                                    AppLocalizations.of(context).translate('laundry'),
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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

  void deviceOccupiedDialog(String deviceId){
    showGeneralDialog(
        context: context,
        pageBuilder: (context, anim1, anim2) {},
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
                backgroundColor: Colors.white,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20,0,20,15),
                        child: AutoSizeText(
                          AppLocalizations.of(context).translate('qr_search_occupied'),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 25,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                        child: AutoSizeText(
                          AppLocalizations.of(context).translate('qr_search_occupied_info'),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        child: Material(
                          borderRadius: BorderRadius.circular(40),
                          color: Theme.of(context).accentColor,
                          elevation: 8,
                          shadowColor: Color(0xAAFF6600),
                          child: InkWell(
                            onTap: (){
                              Navigator.of(context).pop();
                            },
                            borderRadius: BorderRadius.circular(40),
                            splashColor: Colors.black,
                            child: Container(
                              alignment: AlignmentDirectional.center,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                              child: AutoSizeText(
                                AppLocalizations.of(context).translate('ok'),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.of(context).pop();
                          freeDeviceDialog(deviceId);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: AutoSizeText(
                            AppLocalizations.of(context).translate('report_as_free'),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              decoration: TextDecoration.underline,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
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

  void reportBrokenDeviceDialog(String deviceId){
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
                backgroundColor: Colors.white,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 25),
                        child: Text(
                          AppLocalizations.of(context).translate('report_broken'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 25,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Material(
                              borderRadius: BorderRadius.circular(40),
                              color: Theme.of(context).backgroundColor,
                              elevation: 0,
                              child: InkWell(
                                splashColor: Colors.transparent,
                                onTap: (){
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  alignment: AlignmentDirectional.center,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                                  child: Text(
                                    AppLocalizations.of(context).translate('no'),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).accentColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Icon(null, size: 15),
                            Material(
                              borderRadius: BorderRadius.circular(40),
                              color: Theme.of(context).accentColor,
                              elevation: 8,
                              shadowColor: Color(0xAAFF6600),
                              child: InkWell(
                                onTap: (){
                                  createReport(deviceId);
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                                borderRadius: BorderRadius.circular(40),
                                splashColor: Colors.black,
                                child: Container(
                                  alignment: AlignmentDirectional.center,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                                  child: Text(
                                    AppLocalizations.of(context).translate('yes'),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
  void initState() {
    super.initState();
    listenForFirebaseChange();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xFFF9F3EE),
    ));
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
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: <Widget>[
              ListView.builder(
                padding: const EdgeInsets.all(25),
                itemCount: devices.deviceMap.length,
                itemBuilder: (context, int index){
                  return DeviceListTile(device: devices.deviceMap.values.toList()[index],);
                },
              ),

              // QR code scanner
              Positioned(
                bottom: 20,
                child: Material(
                  borderRadius: BorderRadius.circular(40),
                  color: Theme.of(context).accentColor,
                  elevation: 8,
                  shadowColor: Color(0xAAFF6600),
                  child: InkWell(
                    onTap: () async {
                      String cameraScanResult = await scanner.scan();

                      if(cameraScanResult == null){
                        return;
                      }

                      checkQRCode(cameraScanResult);
                    },
                    borderRadius: BorderRadius.circular(40),
                    splashColor: Colors.black,
                    child: Container(
                      alignment: AlignmentDirectional.center,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                      child: Text(
                        AppLocalizations.of(context).translate('scan'),
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
    );
  }
}


class DeviceListTile extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _DeviceListTileState(device);

  final Device device;

  DeviceListTile({this.device});
}


class _DeviceListTileState extends State<DeviceListTile>{

  _DeviceListTileState(this.device);
  final Device device;
  Duration timeDiff;

  @override
  Widget build(BuildContext context) {
    if(device.endTime != null){
      timeDiff = device.endTime.toDate().difference(DateTime.now());
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 5,
        shadowColor: Color(0x2a989898),
        child: InkWell(
          splashColor: Theme.of(context).accentColor,
          borderRadius: BorderRadius.circular(20),
          onTap: (){
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.circular(20.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  alignment: AlignmentDirectional.center,
                  width: 60,
                  child: Container(
                    width: 15,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: new BorderRadius.circular(20.0),
                      color: device.enabled? device.available? Colors.green : Colors.red : Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          device.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 22,
                            color: Color(0xFF484848),
                          ),
                        ),
                        Icon(null, size: 10,),

                        if(device.available)
                          Text(
                          device.enabled?
                            AppLocalizations.of(context).translate("device_ready"):
                          AppLocalizations.of(context).translate('device_disabled'),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 18,
                            color: Color(0xFF484848),
                          ),
                          )
                        else
                          Row(
                            children: <Widget>[
                              Text(
                                AppLocalizations.of(context).translate('device_active'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 18,
                                  color: Color(0xFF484848),
                                ),
                              ),
                              CountdownTimer(
                                endTime: device.endTime.millisecondsSinceEpoch,

                                hoursTextStyle: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  color: Color(0xFF484848),
                                  fontSize: device.endTime.toDate().difference(DateTime.now()).inHours>0? 18: 0,
                                ),
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 18,
                                  color: Color(0xFF484848),
                                ),

                                hoursSymbol: device.endTime.toDate().difference(DateTime.now()).inHours>0? "h " : "",
                                minSymbol: "m ",
                                secSymbol: "s ",

                                onEnd: (){
                                  setState(() {
                                    device.available = true;
                                    device.endTime = null;
                                  });
                                },
                              ),
                            ],
                          ),



                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

}