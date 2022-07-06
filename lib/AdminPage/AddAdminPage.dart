import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ustropralki/Widgets/Tile.dart';
import 'package:ustropralki/templates/AppBar.dart';
import 'package:ustropralki/templates/localization.dart';
import '../Widgets/Texts.dart';

class AddAdminPage extends StatefulWidget{
  static const routeName = '/admin/add_admin';

  @override
  State<StatefulWidget> createState() => _AddAdminPageState();
}


class _AddAdminPageState extends State<AddAdminPage> {

  final TextEditingController _controller = TextEditingController();
  String _newAdminEmail = "";

  Future<void> addNewAdmin(){
    return Future.value(null);
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
                  AppLocalizations.of(context)!.translate("add_admin")!,
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
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (change) => {
                          setState((){
                            _newAdminEmail = change;
                          })
                        },
                        textAlign: TextAlign.center,
                        decoration: InputDecoration.collapsed(
                            hintText: AppLocalizations.of(context)!.translate("users_email"),
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
                  )
                ],
              ),

              Positioned(
                bottom: MediaQuery.of(context).viewPadding.bottom + 20,
                child: Material(
                  borderRadius: BorderRadius.circular(40),
                  animationDuration: Duration(milliseconds: 500),
                  color: _newAdminEmail.isEmpty? Theme.of(context).disabledColor : Theme.of(context).accentColor,
                  elevation: _newAdminEmail.isEmpty? 0 : 10,
                  shadowColor: Color(0xAAFF6600),
                  child: InkWell(
                    onTap: addNewAdmin,
                    borderRadius: BorderRadius.circular(40),
                    splashColor: Colors.black,
                    child: Container(
                      alignment: AlignmentDirectional.center,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                      child: Text(
                        AppLocalizations.of(context)!.translate('add')!,
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