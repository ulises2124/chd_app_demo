import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:flutter/material.dart';

class DeliveryDayItem extends StatefulWidget {
  final String title;
  final int index;
  final bool isSelected;
  final DateTime linkedDate;
  final Function(int, DateTime) selectDeliveryDay;

  DeliveryDayItem(
    this.selectDeliveryDay, {
    Key key,
    this.title,
    this.index,
    this.isSelected,
    this.linkedDate,
  }) : super(key: key);

  _DeliveryDayItemState createState() => _DeliveryDayItemState();
}

class _DeliveryDayItemState extends State<DeliveryDayItem> {
  @override
  Widget build(BuildContext context) {
    return widget.isSelected
        ? RaisedButton(
            color: HexColor('#0D47A1'),
            onPressed: () {
              widget.selectDeliveryDay(widget.index, widget.linkedDate);
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
            child: new Text(
              "${widget.title}",
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            onPressed: () {
              widget.selectDeliveryDay(widget.index, widget.linkedDate);
            },
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(2.0),
            ),
            borderSide: BorderSide(color: HexColor('#C4CDD5'), width: 1.0),
          );
  }
}
