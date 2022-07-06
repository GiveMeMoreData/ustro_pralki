import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ustropralki/ProfilePage/ProfilePage.dart';
import 'package:ustropralki/Widgets/SelectableTile.dart';
import 'package:ustropralki/templates/AppBar.dart';
import 'package:ustropralki/templates/localization.dart';
import '../Widgets/Texts.dart';

class DormSelection extends StatefulWidget{
  static const routeName ="/login/dorm";

  @override
  State<StatefulWidget> createState() => _DormSelectionState();

}


class _DormSelectionState extends State<DormSelection>{


  SelectionArguments? args;
  int selected = -1;
  List<QueryDocumentSnapshot>? locations;

  Future<void> getLocations() async {
    if(locations == null){
      final _locations = await FirebaseFirestore.instance.collection('locations').get();

      locations =_locations.docs;
      if(args != null && args!.selectionArgument != null){
        selected = locations!.indexWhere((doc) => doc.id == args!.selectionArgument);
      }

      setState(() {});
    }
  }

  void loadArgs() {
    if(args != null) {
      return;
    }
    args = ModalRoute.of(context)!.settings.arguments as SelectionArguments;
  }

  @override
  void initState() {
    super.initState();
    getLocations();
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

              Builder(
                builder: (context){
                  if(locations != null){
                    return ListView(
                      children: [

                        ///
                        /// header
                        ///
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0,30,0,22),
                            child: NormalText(
                              AppLocalizations.of(context)!.translate("select_dorm")!,
                              fontSize: 24,
                              color: Colors.grey,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),

                        ListView.builder(
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: locations!.length+1,
                          itemBuilder: (context, index){

                            ///
                            /// footer
                            ///
                            if(index==locations!.length){
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
                                leading:
                                NormalText(
                                  locations![index].get('name'),
                                ),
                                onTap: (){
                                  setState(() {
                                    index == selected? selected = -1 : selected = index;
                                  });
                                },
                                trailing: SizedBox(
                                  height: 28,
                                  child: Visibility(
                                    visible: selected==index,
                                    child: SvgPicture.asset(
                                      "res/check.svg",
                                      height: 28,
                                    ),
                                  ),
                                ),
                              );
                          },
                        )
                      ],
                    );

                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
              Positioned(
                bottom: navbarHeight + 20,
                child: Material(
                  borderRadius: BorderRadius.circular(40),
                  color: selected == -1? Theme.of(context).disabledColor : Theme.of(context).colorScheme.secondary,
                  elevation: selected == -1? 0 : 10,
                  shadowColor: Color(0xAAFF6600),
                  animationDuration: Duration(milliseconds: 700),
                  child: InkWell(
                    onTap: () {
                      if( selected != -1){
                        args!.callback(locations![selected].id);
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