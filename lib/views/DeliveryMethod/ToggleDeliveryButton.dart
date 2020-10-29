import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:flutter/material.dart';

class ToggleDelivery extends StatefulWidget {
  final Widget child;
  final bool isPickup;
  final Function(bool) onPressedToggleDelivery;

  ToggleDelivery(
    this.onPressedToggleDelivery, {
    Key key,
    this.child,
    this.isPickup,
  }) : super(key: key);

  _ToggleDeliveryState createState() => _ToggleDeliveryState();
}

class _ToggleDeliveryState extends State<ToggleDelivery> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 30),
      color: Colors.white,
      child: Stack(
        children: <Widget>[
          Container(
            height: 2,
            margin: EdgeInsets.only(
              top: 15,
            ),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: HexColor('#D8D8D8'), width: 1.0),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Container(
                      height: 2,
                      margin: EdgeInsets.only(top: 6),
                      width: 77,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: widget.isPickup ? HexColor('#F57C00') : Colors.transparent, width: 6.0),
                        ),
                      ),
                    ),
                    FlatButton(
                      padding: EdgeInsets.all(5),
                      onPressed: () {
                        widget.onPressedToggleDelivery(true);
                      },
                      child: Text(
                        'Recoger en',
                        style: TextStyle(color: HexColor('#212B36')),
                      ),
                      color: Colors.transparent,
                    ),
                  ],
                ),
                 Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Container(
                      height: 2,
                      margin: EdgeInsets.only(top: 6),
                      width: 77,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: !widget.isPickup ? HexColor('#F57C00') : Colors.transparent, width: 6.0),
                        ),
                      ),
                    ),
                    FlatButton(
                  onPressed: () {
                    widget.onPressedToggleDelivery(false);
                  },
                  child: Text(
                    'Enviar a',
                    style: TextStyle(color: HexColor('#212B36')),
                  ),
                  color: Colors.transparent,
                ),
                  ],
                ),
                
              ],
            ),
          ),
        ],
      ),
    );
  }
}
