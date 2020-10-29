import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:flutter/material.dart';

class DeliveryHourItem extends StatefulWidget {
  final String title;
  final int index;
  final bool isSelected;
  final DateTime linkedDate;
  final Function(int, DateTime) selectDeliveryHour;

  DeliveryHourItem(
    this.selectDeliveryHour, {
    Key key,
    this.title,
    this.index,
    this.isSelected,
    this.linkedDate,
  }) : super(key: key);

  _DeliveryHourItemState createState() => _DeliveryHourItemState();
}

class _DeliveryHourItemState extends State<DeliveryHourItem> {
  @override
  Widget build(BuildContext context) {
    return widget.isSelected
        ? RaisedButton(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 2),
            color: HexColor('#0D47A1'),
            onPressed: () {
              widget.selectDeliveryHour(widget.index, widget.linkedDate);
            },
            child: Text(
              "${widget.title}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          )
        : OutlineButton(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 2),
            child: new Text(
              "${widget.title}",
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            onPressed: () {
              widget.selectDeliveryHour(widget.index, widget.linkedDate);
            },
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(2.0),
            ),
            borderSide: BorderSide(color: HexColor('#C4CDD5'), width: 1.0),
          );
  }
}
