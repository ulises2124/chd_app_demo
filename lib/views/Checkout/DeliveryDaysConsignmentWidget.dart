import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/DataUI.dart';

class DeliveryDayConsignmentItem extends StatefulWidget {
  final String title;
  final int index;
  final bool isSelected;
  final DateTime linkedDate;
  final String consignmentCode;
  final Function(String, int, DateTime) selectDeliveryDay;

  DeliveryDayConsignmentItem(
    this.selectDeliveryDay, {
    Key key,
    this.consignmentCode,
    this.title,
    this.index,
    this.isSelected,
    this.linkedDate,
  }) : super(key: key);

  _DeliveryDayConsignmentItemState createState() => _DeliveryDayConsignmentItemState();
}

class _DeliveryDayConsignmentItemState extends State<DeliveryDayConsignmentItem> {
  @override
  Widget build(BuildContext context) {
    return widget.isSelected
        ? RaisedButton(
            color: HexColor('#0D47A0'),
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0),
              side: BorderSide(
                width: 3,
                color: DataUI.chedrauiBlueSoftColor
              ),
            ),
            onPressed: () {
              widget.selectDeliveryDay(widget.consignmentCode, widget.index, widget.linkedDate);
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
              widget.selectDeliveryDay(widget.consignmentCode, widget.index, widget.linkedDate);
            },
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0),
            ),
            borderSide: BorderSide(color: HexColor('#C4CDD5'), width: 3.0),
          );
  }
}
