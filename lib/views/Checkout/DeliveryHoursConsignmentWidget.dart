import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/DataUI.dart';

class DeliveryHourConsignmentItem extends StatefulWidget {
  final String title;
  final int index;
  final bool isSelected;
  final String consignmentCode;
  final Function(String, int) selectDeliveryHour;

  DeliveryHourConsignmentItem(
    this.selectDeliveryHour, {
    Key key,
    this.title,
    this.index,
    this.isSelected,
    this.consignmentCode
  }) : super(key: key);

  _DeliveryHourConsignmentItemState createState() => _DeliveryHourConsignmentItemState();
}

class _DeliveryHourConsignmentItemState extends State<DeliveryHourConsignmentItem> {
  @override
  Widget build(BuildContext context) {
    return widget.isSelected
        ? RaisedButton(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 2),
            color: HexColor('#0D47A1'),
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0),
              side: BorderSide(
                width: 3,
                color: DataUI.chedrauiBlueSoftColor
              ),
            ),
            onPressed: () {
              widget.selectDeliveryHour(widget.consignmentCode, widget.index);
            },
            child: Text(
              "${widget.title}",
              textAlign: TextAlign.center,
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
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            onPressed: () {
              widget.selectDeliveryHour(widget.consignmentCode, widget.index);
            },
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0),
            ),
            borderSide: BorderSide(color: HexColor('#C4CDD5'), width: 3.0),
          );
  }
}
