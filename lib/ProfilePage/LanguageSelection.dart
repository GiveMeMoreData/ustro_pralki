import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ustropralki/ProfilePage/ProfilePage.dart';
import 'package:ustropralki/Widgets/SelectableTile.dart';
import 'package:ustropralki/templates/AppBar.dart';
import 'package:ustropralki/templates/localization.dart';
import '../Widgets/Texts.dart';

class LanguageSelection extends StatefulWidget{
  static const routeName = "/login/language";

  @override
  State<StatefulWidget> createState() => _LanguageSelectionState();
}


class _LanguageSelectionState extends State<LanguageSelection>{

  int selected = -1;

  Map<String, String> _languages = {
    "pl": "Polski",
    "en": "English",
  };

  SelectionArguments? args;

  void loadArgs() {
    if(args != null) {
      return;
    }
    args = ModalRoute.of(context)!.settings.arguments as SelectionArguments;

    if(args != null && args!.selectionArgument != null){
      selected = _languages.keys.toList().indexWhere((lang) => lang == args!.selectionArgument);
    }
  }

  @override
  Widget build(BuildContext context) {
    final navbarHeight = MediaQuery.of(context).viewPadding.bottom;
    loadArgs();
    return Scaffold(
      appBar: CustomAppBar(
          "UstroPralki"
      ),
      body: SizedBox.expand(
        child: Container(
          color: Theme.of(context).backgroundColor,
          alignment: AlignmentDirectional.center,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [

              ListView(
                children: [

                  ///
                  /// header
                  ///
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0,30,0,22),
                      child: NormalText(
                        AppLocalizations.of(context)!.translate("select_lang")!,
                        fontSize: 24,
                        color: Colors.grey,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),

                  ListView.builder(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _languages.length+1,
                    itemBuilder: (context, index){

                      ///
                      /// footer
                      ///
                      if(index==_languages.length){
                        return SizedBox(
                          height: 90,
                        );
                      }
                      ///
                      /// list element
                      ///
                      return
                        SelectableTile(
                          selected: index == selected,
                          leading: NormalText(
                            _languages.values.toList()[index],
                          ),
                          onTap: (){
                            setState(() {
                              index == selected? selected = -1 : selected = index;
                            });
                          },
                        );
                    },
                  )
                ],
              ),
              Positioned(
                bottom: navbarHeight + 20,
                child: Material(
                  borderRadius: BorderRadius.circular(40),
                  animationDuration: Duration(milliseconds: 500),
                  color: selected == -1? Theme.of(context).disabledColor : Theme.of(context).accentColor,
                  elevation: selected == -1? 0 : 10,
                  shadowColor: Color(0xAAFF6600),
                  child: InkWell(
                    onTap: () {
                      if(selected != -1){
                        args!.callback(_languages.keys.toList()[selected]);
                      }
                    },
                    borderRadius: BorderRadius.circular(40),
                    splashColor: Colors.black,
                    child: Container(
                      alignment: AlignmentDirectional.center,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                      child: Text(
                        args!.bottomButtonText,
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
      ),
    );

  }

}