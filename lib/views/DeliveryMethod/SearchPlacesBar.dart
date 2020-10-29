import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SearchPlacesBar extends StatefulWidget {
  final Function(bool) isSearching;
  final Function isSearchingManual;
  final Function onPressedCurrentLocation;
  final TextEditingController searchBoxController;

  SearchPlacesBar(
    this.isSearching,
    this.isSearchingManual,
    this.onPressedCurrentLocation, {
    this.searchBoxController,
    Key key,
  }) : super(key: key);

  @override
  SearchPlacesBarState createState() => SearchPlacesBarState();
}

class SearchPlacesBarState extends State<SearchPlacesBar> {
  bool _switchIcons = false;
  bool locationSet = true;

  Timer timer = new Timer(Duration(milliseconds: 500),(){}); 

  unSetLocation() {
    setState(() {
      locationSet = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 55, left: 15, right: 15, bottom: 10),
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0xcc000000).withOpacity(0.2),
            offset: Offset(0.0, 5.0),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: _switchIcons ? Icon(Icons.close ,color:HexColor('#0D47A1') ,) : Icon(Icons.search, color: HexColor('#0D47A1') ,),
                onPressed: () {
                  widget.isSearchingManual();
                  setState(() {
                    _switchIcons = !_switchIcons;
                    widget.searchBoxController.text = '';
                  });
                },
              ),
            ],
          ),
          Flexible(
            child: TextField(
              textInputAction: TextInputAction.search,
              controller: widget.searchBoxController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Ingresa la Dirección',
                hintStyle: TextStyle(color: Colors.black ,fontFamily: 'Archivo',),
              ),
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                widget.isSearching(true);
              },
              onChanged: (value) {
                /*
                if (value.length > 3) {
                  timer.cancel();
                  timer = new Timer(Duration(milliseconds: 500),(){
                    setState(() {
                      _switchIcons = true;
                    });
                    widget.isSearching(true);
                  });
                } else {
                  setState(() {
                    _switchIcons = false;
                  });
                  widget.isSearching(false);
                }
                */
              },
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _switchIcons
                  ? SizedBox(
                      height: 0,
                    )
                  : IconButton(
                      icon: locationSet ? Icon(Icons.near_me, color: HexColor('#0D47A1'),) : Icon(Icons.near_me , color: HexColor('#0D47A1'),),
                      onPressed: () {
                        widget.onPressedCurrentLocation().then((res) {
                          setState(() {
                            locationSet = res;
                          });
                        });
                      },
                    ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  // void _showToast(BuildContext context, String message) {
  //   final scaffold = Scaffold.of(context);
  //   scaffold.showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       action: SnackBarAction(label: 'Ok', onPressed: scaffold.hideCurrentSnackBar),
  //     ),
  //   );
  // }
}
