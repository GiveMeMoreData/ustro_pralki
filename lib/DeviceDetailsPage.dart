import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ustropralki/Widgets/Dialogs.dart';
import 'package:ustropralki/Widgets/Texts.dart';
import 'package:ustropralki/Widgets/Tile.dart';
import 'package:ustropralki/templates/AppBar.dart';
import 'package:ustropralki/templates/localization.dart';
import 'package:flutter/services.dart';

class DeviceDetailsArguments{
  final String deviceId;
  final String deviceName;
  DeviceDetailsArguments(this.deviceId, this.deviceName);

}


class DeviceDetailsPage extends StatefulWidget {

  final String? deviceId;
  final String? deviceName;
  static const routeName = '/home/device_details';

  const DeviceDetailsPage({
    Key? key,
    this.deviceId,
    this.deviceName
  }) : super(key: key);
  @override
  _DeviceDetailsPageState createState() => _DeviceDetailsPageState();
}

class _DeviceDetailsPageState extends State<DeviceDetailsPage> {

  late TextEditingController _controller;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<DocumentSnapshot> deviceDataFuture;
  bool deviceNameChangeEnabled = false;


  Future<void> _changeDeviceState(isDeviceEnabled) async {
    await _firestore.collection('devices').doc(widget.deviceId).set({"enabled": !isDeviceEnabled},SetOptions(merge: true));
    setState((){
      deviceDataFuture = getDeviceDetails(widget.deviceId!);
    });
}

  Future<void> _updateDeviceName() async {
    if(_controller.text == widget.deviceName){
      return;
    }
    await _firestore.collection('devices').doc(widget.deviceId).set({"name": _controller.text},SetOptions(merge: true));
    deviceDataFuture = getDeviceDetails(widget.deviceId!);
  }

  Future<DocumentSnapshot> getDeviceDetails(String deviceId) async {
    return _firestore.collection('devices').doc(deviceId).get();
  }

  @override
  void initState() {
    super.initState();
    deviceDataFuture = getDeviceDetails(widget.deviceId!);
    _controller = TextEditingController(text: widget.deviceName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar("Ustro Pralki", elevation: 10.0, callback: setState,),
      body: Container(
        color: Theme.of(context).backgroundColor,
        alignment: AlignmentDirectional.center,
        child: FutureBuilder(
          future: deviceDataFuture,
          builder: ( BuildContext context, AsyncSnapshot<DocumentSnapshot> deviceData){
            switch(deviceData.connectionState){
              case ConnectionState.waiting: return CircularProgressIndicator();
              default:
                if (deviceData.hasError)
                  return Text('Error while loading data');
                if (deviceData.hasData)
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
                            color: deviceData.data!.get('enabled')? deviceData.data!.get('available')? Colors.green : Colors.red : Colors.grey,
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
                              child: TextField(
                                controller: _controller,
                                enabled: deviceNameChangeEnabled,
                                onEditingComplete: _updateDeviceName,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration.collapsed(
                                    hintText: "Device name", //TODO localization
                                    hintStyle: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w300,
                                    )
                                ),
                                style: TextStyle(
                                  fontSize: 26,
                                  color: deviceNameChangeEnabled? const Color(0xFF484848) : Colors.black38,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 40,
                              child: InkWell(
                                onTap: (){
                                  setState((){
                                    deviceNameChangeEnabled=!deviceNameChangeEnabled;
                                  });
                                },
                                child: Icon(
                                  deviceNameChangeEnabled? Icons.edit_outlined : Icons.edit_off_outlined,
                                  size: 30,
                                  color: Theme.of(context).primaryColor,
                                ),
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
                                  deviceData.data!.id,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                )
                              ],
                            ),
                            GestureDetector(
                              onTap: () async {
                                await Clipboard.setData(new ClipboardData(text: deviceData.data!.id));
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Skopiowano")));
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
                        onTap: ()=>{_changeDeviceState(deviceData.data!.get('enabled'))},
                        child: Tile(
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  NormalText(
                                      AppLocalizations.of(context)!.translate("enabled")!
                                  ),
                                  NormalText(
                                    AppLocalizations.of(context)!.translate(deviceData.data!.get('enabled').toString())!,
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
                                    AppLocalizations.of(context)!.translate("available")!
                                ),
                                NormalText(
                                  AppLocalizations.of(context)!.translate(deviceData.data!.get('available').toString())!,
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
                          onTap: () => showDeviceDialog(context, DeleteDeviceDialog(deviceData.data!.id, null, setState)),
                          child: Container(
                            width: MediaQuery.of(context).size.width*0.9,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.red.shade700,
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
                return Text('No data to display');
            }
          },
          // child: Padding(
          //   padding: const EdgeInsets.symmetric(vertical: 30.0),
          //   child: Column(
          //     children: [
          //       Container(
          //         alignment: AlignmentDirectional.center,
          //         child: Container(
          //           width: MediaQuery.of(context).size.width*0.8,
          //           height: 20,
          //           decoration: BoxDecoration(
          //             borderRadius: new BorderRadius.circular(20.0),
          //             color: deviceData.get('enabled')? deviceData.get('available')? Colors.green : Colors.red : Colors.grey,
          //           ),
          //         ),
          //       ),
          //
          //       Padding(
          //         padding: const EdgeInsets.symmetric(vertical: 28.0),
          //         child: Stack(
          //           children: [
          //             Container(
          //               width: MediaQuery.of(context).size.width,
          //               alignment: Alignment.center,
          //               child: TextField(
          //                 controller: _controller,
          //                 onChanged: (change){
          //                   setState((){
          //                     newDeviceName = change;
          //                   });
          //                 },
          //                 onEditingComplete: _updateDeviceName,
          //                 textAlign: TextAlign.center,
          //                 decoration: InputDecoration.collapsed(
          //
          //                     hintText: "Device name TODO", //TODO
          //                     hintStyle: TextStyle(
          //                       fontSize: 26,
          //                       fontWeight: FontWeight.w300,
          //                     )
          //                 ),
          //                 style: TextStyle(
          //                   fontSize: 26,
          //                   color: const Color(0xFF484848),
          //                   fontWeight: FontWeight.w400,
          //                 ),
          //               ),
          //             ),
          //             Positioned(
          //               right: 40,
          //               child: Icon(
          //                 Icons.edit_outlined,
          //                 size: 30,
          //                 color: Theme.of(context).primaryColor,
          //               ),
          //             )
          //           ],
          //         ),
          //       ),
          //       Tile(
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             Column(
          //               mainAxisAlignment: MainAxisAlignment.center,
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: <Widget>[
          //                 NormalText(
          //                   "ID",
          //                 ),
          //                 SizedBox(
          //                   height: 12,
          //                 ),
          //                 NormalText(
          //                   deviceData.id,
          //                   fontSize: 16,
          //                   fontWeight: FontWeight.w300,
          //                 )
          //               ],
          //             ),
          //             GestureDetector(
          //               onTap: () async {
          //                 await Clipboard.setData(new ClipboardData(text: deviceData.id));
          //                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Skopiowano")));
          //               },
          //               child: Icon(
          //                 Icons.copy_outlined,
          //                 color: Theme.of(context).primaryColor,
          //                 size: 26,
          //               ),
          //             )
          //
          //           ],
          //         ),
          //       ),
          //       GestureDetector(
          //         onTap: _changeDeviceState,
          //         child: Tile(
          //           child: Column(
          //             children: <Widget>[
          //               Row(
          //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                 children: <Widget>[
          //                   NormalText(
          //                       AppLocalizations.of(context).translate("enabled")
          //                   ),
          //                   NormalText(
          //                     AppLocalizations.of(context).translate(deviceData.get('enabled').toString()),
          //                     fontSize: 16,
          //                     fontWeight: FontWeight.w300,
          //                   )
          //                 ],
          //               )
          //             ],
          //           ),
          //         ),
          //       ),
          //       Tile(
          //         child: Column(
          //           children: <Widget>[
          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //               children: <Widget>[
          //                 NormalText(
          //                     AppLocalizations.of(context).translate("available")
          //                 ),
          //                 NormalText(
          //                   AppLocalizations.of(context).translate(deviceData.get('available').toString()),
          //                   fontSize: 16,
          //                   fontWeight: FontWeight.w300,
          //                 )
          //               ],
          //             )
          //           ],
          //         ),
          //       ),
          //       Padding(
          //         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          //         child: InkWell(
          //           onTap: _showDeleteDialog,
          //           child: Container(
          //             width: MediaQuery.of(context).size.width*0.9,
          //             decoration: BoxDecoration(
          //                 borderRadius: BorderRadius.circular(15),
          //                 color: Colors.red.shade700,
          //                 boxShadow: [
          //                   BoxShadow(
          //                     color: Color(0xFF989898).withOpacity(0.1),
          //                     spreadRadius: 5,
          //                     blurRadius: 10,
          //                     offset: Offset(0, 5), // changes position of shadow
          //                   )
          //                 ]
          //             ),
          //             child: Padding(
          //               padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          //               child: Center(
          //                 child: AutoSizeText(
          //                   "Usuń urządzenie", // TODO change
          //                   style: TextStyle(
          //                     fontSize: 18,
          //                     color: Colors.white,
          //                     fontWeight: FontWeight.w400,
          //                   ),
          //                 ),
          //               ),
          //             ),
          //           ),
          //         ),
          //       )
          //     ],
          //   ),
          // ),
        )


        // FutureBuilder(
        //   future: loadDetails(args.deviceId),
        //   builder: (builder, future) {
        //
        //     // If device does not exist
        //     if (future.connectionState == ConnectionState.none) {
        //       return Container();
        //     } else
        //
        //     // If there is no device data
        //     if (future.connectionState == ConnectionState.done && future.data == null) {
        //       return Container();
        //     } else
        //
        //     if (future.connectionState == ConnectionState.done && future.data != null) {
        //       return Padding(
        //         padding: const EdgeInsets.symmetric(vertical: 30.0),
        //         child: Column(
        //           children: [
        //             Container(
        //               alignment: AlignmentDirectional.center,
        //               child: Container(
        //                 width: MediaQuery.of(context).size.width*0.8,
        //                 height: 20,
        //                 decoration: BoxDecoration(
        //                   borderRadius: new BorderRadius.circular(20.0),
        //                   color: deviceData.get('enabled')? deviceData.get('available')? Colors.green : Colors.red : Colors.grey,
        //                 ),
        //               ),
        //             ),
        //
        //             Padding(
        //               padding: const EdgeInsets.symmetric(vertical: 28.0),
        //               child: Stack(
        //                 children: [
        //                   Container(
        //                     width: MediaQuery.of(context).size.width,
        //                     alignment: Alignment.center,
        //                     child: TextField(
        //                       controller: _controller,
        //                       onChanged: (change){
        //                         setState((){
        //                           newDeviceName = change;
        //                         });
        //                       },
        //                       textAlign: TextAlign.center,
        //                       decoration: InputDecoration.collapsed(
        //                           hintText: deviceData.get('name'),
        //                           hintStyle: TextStyle(
        //                             fontSize: 26,
        //                             fontWeight: FontWeight.w400,
        //                           )
        //                       ),
        //                       style: TextStyle(
        //                         fontSize: 26,
        //                         color: const Color(0xFF484848),
        //                         fontWeight: FontWeight.w400,
        //                       ),
        //                     ),
        //                   ),
        //                   Positioned(
        //                     right: 40,
        //                     child: Icon(
        //                       Icons.edit_outlined,
        //                       size: 30,
        //                       color: Theme.of(context).primaryColor,
        //                     ),
        //                   )
        //                 ],
        //               ),
        //             ),
        //             Tile(
        //               child: Row(
        //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                 children: [
        //                   Column(
        //                     mainAxisAlignment: MainAxisAlignment.center,
        //                     crossAxisAlignment: CrossAxisAlignment.start,
        //                     children: <Widget>[
        //                       NormalText(
        //                         "ID",
        //                       ),
        //                       SizedBox(
        //                         height: 12,
        //                       ),
        //                       NormalText(
        //                         deviceData.id,
        //                         fontSize: 16,
        //                         fontWeight: FontWeight.w300,
        //                       )
        //                     ],
        //                   ),
        //                   GestureDetector(
        //                       onTap: () async {
        //                         await Clipboard.setData(new ClipboardData(text: deviceData.id));
        //                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Skopiowano")));
        //                         },
        //                     child: Icon(
        //                       Icons.copy_outlined,
        //                       color: Theme.of(context).primaryColor,
        //                       size: 26,
        //                     ),
        //                   )
        //
        //                 ],
        //               ),
        //             ),
        //             GestureDetector(
        //               onTap: _changeDeviceState,
        //               child: Tile(
        //                 child: Column(
        //                   children: <Widget>[
        //                     Row(
        //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                       children: <Widget>[
        //                         NormalText(
        //                             AppLocalizations.of(context).translate("enabled")
        //                         ),
        //                         NormalText(
        //                           AppLocalizations.of(context).translate(deviceData.get('enabled').toString()),
        //                           fontSize: 16,
        //                           fontWeight: FontWeight.w300,
        //                         )
        //                       ],
        //                     )
        //                   ],
        //                 ),
        //               ),
        //             ),
        //             Tile(
        //               child: Column(
        //                 children: <Widget>[
        //                   Row(
        //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                     children: <Widget>[
        //                       NormalText(
        //                           AppLocalizations.of(context).translate("available")
        //                       ),
        //                       NormalText(
        //                         AppLocalizations.of(context).translate(deviceData.get('available').toString()),
        //                         fontSize: 16,
        //                         fontWeight: FontWeight.w300,
        //                       )
        //                     ],
        //                   )
        //                 ],
        //               ),
        //             ),
        //             Padding(
        //               padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        //               child: InkWell(
        //                 onTap: _showDeleteDialog,
        //                 child: Container(
        //                   width: MediaQuery.of(context).size.width*0.9,
        //                   decoration: BoxDecoration(
        //                       borderRadius: BorderRadius.circular(15),
        //                       color: Colors.red.shade700,
        //                       boxShadow: [
        //                         BoxShadow(
        //                           color: Color(0xFF989898).withOpacity(0.1),
        //                           spreadRadius: 5,
        //                           blurRadius: 10,
        //                           offset: Offset(0, 5), // changes position of shadow
        //                         )
        //                       ]
        //                   ),
        //                   child: Padding(
        //                     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        //                     child: Center(
        //                       child: AutoSizeText(
        //                         "Usuń urządzenie", // TODO change
        //                         style: TextStyle(
        //                           fontSize: 18,
        //                           color: Colors.white,
        //                           fontWeight: FontWeight.w400,
        //                         ),
        //                       ),
        //                     ),
        //                   ),
        //                 ),
        //               ),
        //             )
        //           ],
        //         ),
        //       );
        //     }
        //
        //     return CircularProgressIndicator();
        //   },
        // ),
      ),
    );
  }
}
