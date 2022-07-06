import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ustropralki/templates/DevicesSingleton.dart';
import 'package:ustropralki/templates/localization.dart';



void showDeviceDialog(BuildContext context, Widget deviceDialog){
  final CapturedThemes themes = InheritedTheme.capture(
    from: context,
    to: Navigator.of(
      context,
      rootNavigator: true,
    ).context,
  );
  showGeneralDialog(
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return themes.wrap(Builder(
          builder: (context) => deviceDialog,
        ));
      },
      barrierDismissible: true,
      barrierColor: Colors.white.withOpacity(0.1),
      barrierLabel: '',
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedValue = Curves.easeInOut.transform(anim1.value)- 1.0;
        return Transform(
          transform: Matrix4.translationValues(0, curvedValue*200, 0),
          child: Opacity(
            opacity: anim1.value,
            child: deviceDialog,
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 400)
  );

}


class CannotFindDeviceDialog extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                AppLocalizations.of(context)!.translate('qr_search_fail')!,
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
    );
  }

}

class DeviceDisabledDialog extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                AppLocalizations.of(context)!.translate('qr_search_disabled')!,
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
    );
  }

}


class StartUsingDeviceDialog extends StatefulWidget{

  StartUsingDeviceDialog(this.deviceId, this.devices, this.setStateCallback);
  final String deviceId;
  final DevicesInfoBase devices;
  final Function setStateCallback;

  @override
  State<StatefulWidget> createState() => _StartUsingDeviceDialogState();

}

class _StartUsingDeviceDialogState extends State<StartUsingDeviceDialog>{

  TimeOfDay _endTime = TimeOfDay(hour: 1, minute: 0);


  void _useDevice(Timestamp endTime){
    setState(() {
      widget.devices.useDevice(widget.deviceId, FirebaseAuth.instance.currentUser!.uid, endTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                AppLocalizations.of(context)!.translate('make_laundry')!,
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
                AppLocalizations.of(context)!.translate('wash_time')!,
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
                    _useDevice(_finalEndTime);
                    Navigator.of(context).pop();
                  },
                  // onTap: (){
                  //   final _finalEndTime = Timestamp.fromMillisecondsSinceEpoch(DateTime.now().add(Duration(hours: _endTime.hour, minutes: _endTime.minute)).millisecondsSinceEpoch);
                  //   useDevice(deviceId, _finalEndTime);
                  //   Navigator.of(context).pop();
                  // },
                  borderRadius: BorderRadius.circular(40),
                  splashColor: Colors.black,
                  child: Container(
                    alignment: AlignmentDirectional.center,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    child: Text(
                      AppLocalizations.of(context)!.translate('begin')!,
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
                showDeviceDialog(context, ReportBrokenDeviceDialog(widget.deviceId, widget.devices, widget.setStateCallback));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Text(
                  AppLocalizations.of(context)!.translate('report_broken_device')!,
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
    );
  }

}

class FreeDeviceDialog extends StatelessWidget{
  FreeDeviceDialog(this.deviceId, this.devices, this.setStateCallback);
  final String deviceId;
  final DevicesInfoBase devices;
  final Function setStateCallback;


  void _freeDevice(){
    devices.freeDevice(deviceId, FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                AppLocalizations.of(context)!.translate('free_device')!,
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
                AppLocalizations.of(context)!.translate('free_device_info')!,
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
                        showDeviceDialog(context, DeviceOccupiedDialog(deviceId, devices, setStateCallback));
                      },
                      child: Container(
                        alignment: AlignmentDirectional.center,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                        child: Text(
                          AppLocalizations.of(context)!.translate('no')!,
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
                      onTap: () => {
                        _freeDevice(),
                        Navigator.of(context).pop(),
                        showDeviceDialog(context, AfterDeviceFreedDialog(deviceId, devices, setStateCallback)),
                      },
                      borderRadius: BorderRadius.circular(40),
                      splashColor: Colors.black,
                      child: Container(
                        alignment: AlignmentDirectional.center,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                        child: Text(
                          AppLocalizations.of(context)!.translate('yes')!,
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
    );
  }

}

class AfterDeviceFreedDialog extends StatelessWidget{
  AfterDeviceFreedDialog(this.deviceId, this.devices, this.setStateCallback);
  final String deviceId;
  final DevicesInfoBase devices;
  final Function setStateCallback;
  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                AppLocalizations.of(context)!.translate('device_freed')!,
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
                AppLocalizations.of(context)!.translate('device_freed_info')!,
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
                          AppLocalizations.of(context)!.translate('back')!,
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
                        showDeviceDialog(context, StartUsingDeviceDialog(deviceId, devices, setStateCallback));
                      },
                      borderRadius: BorderRadius.circular(40),
                      splashColor: Colors.black,
                      child: Container(
                        alignment: AlignmentDirectional.center,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        child: AutoSizeText(
                          AppLocalizations.of(context)!.translate('laundry')!,
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
    );
  }

}

class DeviceOccupiedDialog extends StatelessWidget{
  DeviceOccupiedDialog(this.deviceId, this.devices, this.setStateCallback);
  final String deviceId;
  final DevicesInfoBase devices;
  final Function setStateCallback;

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                AppLocalizations.of(context)!.translate('qr_search_occupied')!,
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
                AppLocalizations.of(context)!.translate('qr_search_occupied_info')!,
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
                      AppLocalizations.of(context)!.translate('ok')!,
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
                showDeviceDialog(context, FreeDeviceDialog(deviceId, devices, setStateCallback));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: AutoSizeText(
                  AppLocalizations.of(context)!.translate('report_as_free')!,
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
    );
  }

}

class ReportBrokenDeviceDialog extends StatelessWidget{

  ReportBrokenDeviceDialog(this.deviceId, this.devices, this.setStateCallback);
  final String deviceId;
  final DevicesInfoBase devices;
  final Function setStateCallback;

  void _createReport(String deviceId){
    FirebaseFirestore.instance.collection('reports').add({
      "device_id": deviceId,
      "user_id": FirebaseAuth.instance.currentUser!.uid,
      "time": Timestamp.now()
    });
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                AppLocalizations.of(context)!.translate('report_broken')!,
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
                          AppLocalizations.of(context)!.translate('no')!,
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
                        _createReport(deviceId);
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      borderRadius: BorderRadius.circular(40),
                      splashColor: Colors.black,
                      child: Container(
                        alignment: AlignmentDirectional.center,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                        child: Text(
                          AppLocalizations.of(context)!.translate('yes')!,
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
    );
  }

}


class DeleteDeviceDialog extends StatelessWidget{
  DeleteDeviceDialog(this.deviceId, this.devices, this.setStateCallback);
  final String deviceId;
  final DevicesInfoBase? devices;
  final Function setStateCallback;


  Future<void> _deleteDevice() async {
    await FirebaseFirestore.instance.collection('devices').doc(deviceId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Text(
                "Usuwanie urządzenia", //TODO localization
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 25,
                  color: Colors.black87,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 30),
              child: Text(
                "Tej operacji nie da się cofnąć. Czy jesteś pewny, że chcesz usunąć urządzenie?", //TODO localization
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
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Material(
                borderRadius: BorderRadius.circular(40),
                color: Colors.red.shade700,
                elevation: 8,
                shadowColor: Color(0xAAd66060),
                child: InkWell(
                  onTap: () async {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    _deleteDevice();
                  },
                  borderRadius: BorderRadius.circular(40),
                  splashColor: Colors.black,
                  child: Container(
                    alignment: AlignmentDirectional.center,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    child: Text(
                      "Tak", //TODO localization
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
            SizedBox(height: 15,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Material(
                borderRadius: BorderRadius.circular(40),
                color: Colors.grey[400],
                elevation: 8,
                shadowColor: Color(0xAABDBDBD),
                child: InkWell(
                  onTap: Navigator.of(context).pop,
                  borderRadius: BorderRadius.circular(40),
                  splashColor: Colors.black,
                  child: Container(
                    alignment: AlignmentDirectional.center,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    child: Text(
                      "Nie", //TODO localization
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
          ],
        ),
      ),
    );
  }

}
