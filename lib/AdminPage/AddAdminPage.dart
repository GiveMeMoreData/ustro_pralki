import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ustropralki/HomePage.dart';
import 'package:ustropralki/Widgets/Tile.dart';
import 'package:ustropralki/templates/AppBar.dart';
import 'package:ustropralki/templates/UserSingleton.dart';
import 'package:ustropralki/templates/localization.dart';
import '../Widgets/Texts.dart';

class AddAdminPage extends StatefulWidget{
  static const routeName = '/admin/add_admin';

  @override
  State<StatefulWidget> createState() => _AddAdminPageState();
}


class _AddAdminPageState extends State<AddAdminPage> {

  TextEditingController _controller = TextEditingController();
  String _newAdminEmail = "";


  Future<void> addNewAdmin() async {

    final String processedEmail = _newAdminEmail.trim();

    final QuerySnapshot users = await FirebaseFirestore.instance.collection('users').where('mail', isEqualTo: processedEmail).get();
    print("Users found: ${users.size}");
    print("Users: ${users.docs}");
    try {
      final DocumentSnapshot user = users.docs.single;
      print("User found: ${user.id}");
      final UstroUserBase ustroUser = UstroUserState();
      await ustroUser.checkIfAdmin();
      if(!ustroUser.user.isAdmin){
        // display that user is not an admin of this location
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            AppLocalizations.of(context)!.translate('add_admin_not_admin')!,),
        ));
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).pushReplacementNamed(MyHomePage.routeName);
        return;
      }

      //get current admins
      final DocumentSnapshot location = await FirebaseFirestore.instance.collection('locations').doc(ustroUser.user.locationId).get();
      List? currentAdmins = location.get('admin_user_id');
      if (currentAdmins == null){
        currentAdmins = [];
      }
      if(currentAdmins.contains(user.id)){
        // info user is admin
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            AppLocalizations.of(context)!.translate('add_admin_exists')!,),
        ));
        _controller.clear();
        return;
      }
      currentAdmins.add(user.id);

      // add user id to location admins
      try{
        await FirebaseFirestore.instance.collection('locations').doc(ustroUser.user.locationId).update({"admin_user_id": currentAdmins});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            AppLocalizations.of(context)!.translate('add_admin_added')!,),
        ));
      } on Exception {
        //  propagate the information to user
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            AppLocalizations.of(context)!.translate('add_admin_failed')!,),
        ));
      }
      Navigator.of(context).pop();
    } on StateError {
      // snack bar user not found
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          AppLocalizations.of(context)!.translate('add_admin_not_found')!,),
      ));
      _controller.clear();

    }

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
                              fontSize: 18,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w300,
                            )
                        ),
                        style: TextStyle(
                          fontSize: 18,
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