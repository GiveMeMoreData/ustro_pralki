import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ustropralki/Widgets/Tile.dart';
import 'package:ustropralki/templates/AppBar.dart';
import 'package:ustropralki/templates/DevicesSingleton.dart';
import 'package:ustropralki/templates/UserSingleton.dart';
import 'package:ustropralki/templates/localization.dart';
import '../Widgets/Texts.dart';

class AddDevicePage extends StatefulWidget{
  static const routeName = '/admin/add_device';

  @override
  State<StatefulWidget> createState() => _AddDevicePageState();
}


class _AddDevicePageState extends State<AddDevicePage> {

  final TextEditingController _controller = TextEditingController();
  final UstroUserBase _user = UstroUserState();
  final DevicesInfoBase _devices = DevicesInfoState();

  String _newDeviceName = "";


  Future<void> addNewDevice() async {
    await _devices.createDevice(_newDeviceName, _user.user.locationId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar("Ustro Pralki", elevation: 10.0, callback: setState,),
        body: Container(
          color: Theme.of(context).backgroundColor,
          alignment: AlignmentDirectional.center,
          child: Stack(
            alignment: Alignment.center,
            children: [

              // header
              Positioned(
                top: 25,
                child: NormalText(
                  AppLocalizations.of(context)!.translate("add_device")!,
                  fontSize: 24,
                  color: Colors.grey,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Tile(
                    child: Center(
                      child: TextField(
                        controller: _controller,
                        onChanged: (change) => {
                          setState((){
                            _newDeviceName = change;
                          })
                        },
                        textAlign: TextAlign.center,
                        decoration: InputDecoration.collapsed(
                            hintText: AppLocalizations.of(context)!.translate("device_name"),
                            hintStyle: TextStyle(
                              fontSize: 20,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w300,
                            )
                        ),
                        style: TextStyle(
                          fontSize: 20,
                          color: const Color(0xFF484848),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Positioned(
                bottom: MediaQuery.of(context).viewPadding.bottom + 20,
                child: Material(
                  borderRadius: BorderRadius.circular(40),
                  animationDuration: Duration(milliseconds: 500),
                  color: _newDeviceName.isEmpty? Theme.of(context).disabledColor : Theme.of(context).accentColor,
                  elevation: _newDeviceName.isEmpty? 0 : 10,
                  shadowColor: Color(0xAAFF6600),
                  child: InkWell(
                    onTap: () async {
                      await addNewDevice();
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(40),
                    splashColor: Colors.black,
                    child: Container(
                      alignment: AlignmentDirectional.center,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                      child: Text(
                        AppLocalizations.of(context)!.translate('create')!,
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
        )
    );
  }

}