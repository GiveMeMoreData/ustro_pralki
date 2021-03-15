import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ustropralki/Widgets/Texts.dart';
import 'package:ustropralki/Widgets/Tile.dart';
import 'package:ustropralki/templates/AppBar.dart';
import 'package:ustropralki/templates/localization.dart';
import 'package:flutter/services.dart';

class DeviceDetailsArguments{
  final String deviceId;
  DeviceDetailsArguments(this.deviceId);

}


class DeviceDetailsPage extends StatefulWidget {
  static const routeName = '/home/device_details';
  @override
  _DeviceDetailsPageState createState() => _DeviceDetailsPageState();
}

class _DeviceDetailsPageState extends State<DeviceDetailsPage> {

  DeviceDetailsArguments args;
  bool _deviceLoaded = false;
  DocumentSnapshot deviceData;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot> loadDetails(String deviceId) async {
    if(_deviceLoaded){
      return deviceData;
    }

    //loading data
    listenToDataChange(deviceId);
    return deviceData;
  }

  Future<void> _showDeleteDialog() async {
    showGeneralDialog(
        context: context,
        pageBuilder: (context, anim1, anim2) {return;},
        barrierDismissible: false,
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
                        padding: const EdgeInsets.symmetric(horizontal: 35),
                        child: Text(
                          "Usuwanie urządzenia",
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
                          "Tej operacji nie da się cofnąć. Czy jesteś pewny, że chcesz usunąć urządzenie?",
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
                          color: Colors.red.shade300,
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
                                "Tak",
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
                                "Nie",
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
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 400)
    );
  }

  Future<void> _deleteDevice() async {
    await _firestore.collection('devices').doc(deviceData.id).delete();
  }

  Future<void> _changeDeviceState() async {
    await _firestore.collection('devices').doc(deviceData.id).set({"enabled": !deviceData.get("enabled")},SetOptions(merge: true));
}

  void listenToDataChange(String deviceId) async {
    final _dataStream = _firestore.collection('devices').doc(deviceId).snapshots();
    _dataStream.listen((data) {
      setState(() {
        _deviceLoaded = true;
        print("[INFO] Device details data loaded");
        deviceData = data;
      });
    });
  }

  void loadArgs() {
    if(args != null) {
      return;
    }
    args = ModalRoute.of(context).settings.arguments;
  }

  @override
  Widget build(BuildContext context) {
    loadArgs();
    return Scaffold(
      appBar: CustomAppBar("Ustro Pralki", elevation: 10.0, callback: setState,),
      body: Container(
        color: Theme.of(context).backgroundColor,
        alignment: AlignmentDirectional.center,
        child: FutureBuilder(
          future: loadDetails(args.deviceId),
          builder: (builder, future) {

            // If device does not exist
            if (future.connectionState == ConnectionState.none) {
              return Container();
            } else

            // If there is no device data
            if (future.connectionState == ConnectionState.done && future.data == null) {
              return Container();
            } else

            if (future.connectionState == ConnectionState.done && future.data != null) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Column(
                  children: [


                    Container(
                      alignment: AlignmentDirectional.center,
                      child: Container(
                        width: MediaQuery.of(context).size.width*0.8,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: new BorderRadius.circular(20.0),
                          color: deviceData.get('enabled')? deviceData.get('available')? Colors.green : Colors.red : Colors.grey,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28.0),
                      child: Stack(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            alignment: Alignment.center,
                            child: NormalText(
                              deviceData.get('name'),
                              fontSize: 26,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Positioned(
                            right: 40,
                            child: Icon(
                              Icons.edit_outlined,
                              size: 30,
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        ],
                      ),
                    ),
                    Tile(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              NormalText(
                                "ID",
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              NormalText(
                                deviceData.id,
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                              )
                            ],
                          ),
                          GestureDetector(
                              onTap: () async {
                                await Clipboard.setData(new ClipboardData(text: deviceData.id));
                                Scaffold.of(context).showSnackBar(const SnackBar(content: Text("Skopiowano")));
                                },
                            child: Icon(
                              Icons.copy_outlined,
                              color: Theme.of(context).primaryColor,
                              size: 26,
                            ),
                          )

                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _changeDeviceState,
                      child: Tile(
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                NormalText(
                                    AppLocalizations.of(context).translate("enabled")
                                ),
                                NormalText(
                                  AppLocalizations.of(context).translate(deviceData.get('enabled').toString()),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Tile(
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              NormalText(
                                  AppLocalizations.of(context).translate("available")
                              ),
                              NormalText(
                                AppLocalizations.of(context).translate(deviceData.get('available').toString()),
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), 
                      child: InkWell(
                        onTap: _showDeleteDialog,
                        child: Container(
                          width: MediaQuery.of(context).size.width*0.9,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.red.shade300,
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
                            child: Center(
                              child: AutoSizeText(
                                "Usuń urządzenie", // TODO change
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            }

            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
