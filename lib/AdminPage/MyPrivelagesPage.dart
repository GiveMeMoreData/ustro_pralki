import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ustropralki/Widgets/Tile.dart';
import 'package:ustropralki/templates/AppBar.dart';
import 'package:ustropralki/templates/localization.dart';
import '../Widgets/Texts.dart';

class MyPrivilegesPage extends StatefulWidget{
  static const routeName = '/admin/privileges';

  @override
  State<StatefulWidget> createState() => _MyPrivilegesPageState();
}


class _MyPrivilegesPageState extends State<MyPrivilegesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar("Ustro Pralki", elevation: 10.0, callback: setState,),
        body: SingleChildScrollView(
          child: Container(
            color: Theme.of(context).backgroundColor,
            alignment: AlignmentDirectional.center,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Tile(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      NormalText(
                        AppLocalizations.of(context).translate("privilege_add_device"),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      NormalText(
                        AppLocalizations.of(context).translate("privilege_add_device_text"),
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      )
                    ],
                  ),
                ),
                Tile(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      NormalText(
                        AppLocalizations.of(context).translate("privilege_edit_device"),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      NormalText(
                        AppLocalizations.of(context).translate("privilege_edit_device_text"),
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      )
                    ],
                  ),
                ),
                Tile(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      NormalText(
                        AppLocalizations.of(context).translate("privilege_add_admin"),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      NormalText(
                        AppLocalizations.of(context).translate("privilege_add_admin_text"),
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      )
                    ],
                  ),
                ),
                Tile(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      NormalText(
                        AppLocalizations.of(context).translate("privilege_improvement"),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      NormalText(
                        AppLocalizations.of(context).translate("privilege_improvement_text"),
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }

}