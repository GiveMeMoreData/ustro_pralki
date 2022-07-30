
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ustropralki/DeviceDetailsPage.dart';
import 'package:ustropralki/QRScanPage.dart';
import 'package:ustropralki/Widgets/Dialogs.dart';
import 'package:ustropralki/templates/UserSingleton.dart';
import 'package:ustropralki/templates/localization.dart';

import 'templates/AppBar.dart';
import 'templates/Drawer.dart';
import 'templates/DevicesSingleton.dart';

class MyHomePage extends StatefulWidget {

  static const routeName = "/home";

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final User? _user = FirebaseAuth.instance.currentUser;

  final UstroUserBase user = UstroUserState();

  final DevicesInfoBase devices = DevicesInfoState();

  void listenForFirebaseChange() async {
    FirebaseFirestore.instance.collection('devices').where("location", isEqualTo: user.user.locationId).orderBy('name', descending: false).snapshots().listen((data) {
      devices.updateDevicesFromChangesList(data.docChanges);
      if(mounted){
        setState(() {
          print("[INFO] Database changed, update");
        });
      }
    });
  }


  void checkQRCode(String scanResult){
    if(devices.deviceMap.containsKey(scanResult)){
      if(!devices.deviceMap[scanResult]!.enabled){
        showDeviceDialog(context, DeviceDisabledDialog());
      } else {
        if(devices.deviceMap[scanResult]!.available){
          showDeviceDialog(context, StartUsingDeviceDialog(scanResult, devices, setState));
        } else {
          showDeviceDialog(context, DeviceOccupiedDialog(scanResult, devices, setState));
        }
      }
    } else {
      showDeviceDialog(context, CannotFindDeviceDialog());
    }
  }

  @override
  void initState() {
    super.initState();
    listenForFirebaseChange();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemStatusBarContrastEnforced: true,
        systemNavigationBarColor: Color(0xFFF9F3EE).withOpacity(0.5),
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark
    ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [SystemUiOverlay.top]);

  }


  @override
  Widget build(BuildContext context) {
    final navbarHeight = MediaQuery.of(context).viewPadding.bottom;
    return Scaffold(
      drawer: CustomDrawer(),
      drawerScrimColor: Colors.black26,
      drawerEdgeDragWidth: 100,
      // extendBody: true,
      appBar: CustomAppBar("Ustro Pralki", elevation: 5.0, callback: setState,),
      body: Container(
          color: Theme.of(context).backgroundColor,
          alignment: AlignmentDirectional.center,
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: <Widget>[
              ListView.builder(
                padding:  EdgeInsets.fromLTRB(25,25,25, navbarHeight + 20 + 40 + 20),
                itemCount: devices.deviceMap.length,
                itemBuilder: (context, int index){
                  return DeviceListTile(device: devices.getDevices()[index],);
                },
              ),

              // QR code scanner
              Positioned(
                bottom: navbarHeight+ 20,
                child: Material(
                  borderRadius: BorderRadius.circular(40),
                  color: Theme.of(context).accentColor,
                  elevation: 8,
                  shadowColor: Color(0xAAFF6600),
                  child: InkWell(
                    onTap: () async {

                      var status = await Permission.camera.status;
                      if(status.isPermanentlyDenied){
                        // TODO show info
                        return;
                      }
                      if(status.isDenied){
                        var newStatus = await Permission.camera.request();
                        if(!newStatus.isGranted){
                          return;
                        }
                      }
                      Navigator.of(context).pushNamed(
                          QRSCanPage.routeName,
                          arguments: QRScanPageArguments(checkQRCode)
                      );
                    },
                    borderRadius: BorderRadius.circular(40),
                    splashColor: Colors.black,
                    child: Container(
                      alignment: AlignmentDirectional.center,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                      child: Text(
                        AppLocalizations.of(context)!.translate('scan')!,
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

  DeviceListTile({required this.device});
}


class _DeviceListTileState extends State<DeviceListTile>{


  void onDeviceEnd(){
      setState(() {
        device.available = true;
        device.endTime = null;
      });
  }

  _DeviceListTileState(this.device);
  final Device device;
  late Duration timeDiff;
  int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 30;
  CountdownTimerController? controller;

  Widget endWidget = Text(
    "End", // todo localization
    style: TextStyle(
    fontWeight: FontWeight.w300,
    color: Color(0xFF484848),
    fontSize: 18,
    ),
  );

  TextStyle timeStyle = TextStyle(
    fontWeight: FontWeight.w300,
    color: Color(0xFF484848),
    fontSize: 18,
  );

  @override
  Widget build(BuildContext context) {
    if(device.endTime != null){
      timeDiff = device.endTime!.toDate().difference(DateTime.now());
      // controller = CountdownTimerController(endTime: timeDiff.inMilliseconds, onEnd: onDeviceEnd);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 5,
        shadowColor: Color(0x2a989898),
        child: InkWell(
          splashColor: Theme.of(context).accentColor.withOpacity(0.5),
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          onLongPress: (){
            Navigator.of(context).pushNamed(DeviceDetailsPage.routeName, arguments: DeviceDetailsArguments(device.id, device.name));
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
                            AppLocalizations.of(context)!.translate("device_ready")!:
                          AppLocalizations.of(context)!.translate('device_disabled')!,
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
                                AppLocalizations.of(context)!.translate('device_active')!,
                                style: timeStyle,
                              ),
                              CountdownTimer(
                                endTime: device.endTime!.millisecondsSinceEpoch,
                                onEnd: (){
                                  setState(() {
                                    device.available = true;
                                    device.endTime = Timestamp(0,0);
                                  });
                                },
                                widgetBuilder: (BuildContext context, CurrentRemainingTime? time) {
                                  if (time == null) {
                                    return endWidget;
                                  }

                                  List<Widget> list = [];

                                  if (time.hours != null) {
                                    list.add(
                                      Text(time.hours.toString() + "h ", style: timeStyle),
                                    );
                                  }

                                  if (time.min != null) {
                                    list.add(
                                      Text(time.min.toString() + "m ", style: timeStyle),
                                    );
                                  }

                                  if (time.sec != null) {
                                    list.add(
                                      Text(time.sec.toString() + "s", style: timeStyle,),
                                    );
                                  }
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: list,
                                  );
                                },
                                endWidget: endWidget,
                                textStyle: timeStyle,
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