import 'package:flutter/material.dart';

class SelectableTile extends StatefulWidget{

  SelectableTile({this.selected, this.onTap, this.leading, this.trailing = const Spacer()});


  bool? selected;

  Function? onTap;
  Widget? leading;
  Widget trailing;

  @override
  State<StatefulWidget> createState() => _SelectableListTileState();

}

class _SelectableListTileState extends State<SelectableTile>{


  void _tileAction(){
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Material(
        color: widget.selected!? Theme.of(context).accentColor : Colors.transparent,
        borderRadius: BorderRadius.circular(22.5),
        elevation: 5,
        shadowColor: Color(0x2a989898),
        child: InkWell(
          splashColor: widget.selected!? Colors.white : Theme.of(context).accentColor ,
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(22.5),
          onTap: (){
            _tileAction();
          },
          child: Padding(
            padding: const EdgeInsets.all(2.5),
            child: Container(
              width: MediaQuery.of(context).size.width*0.9,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF989898).withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(2, 2), // changes position of shadow
                    )
                  ]
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 19),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.leading!,
                    widget.trailing
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}