import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:flutter/material.dart';

class AssociatedStoreItem extends StatefulWidget {
  final String title;
  final int index;
  final bool isSelected;
  final Function(int) selectDeliveryHour;

  AssociatedStoreItem(
    this.selectDeliveryHour, {
    Key key,
    this.title,
    this.index,
    this.isSelected,
  }) : super(key: key);

  _AssociatedStoreItemState createState() => _AssociatedStoreItemState();
}

class _AssociatedStoreItemState extends State<AssociatedStoreItem> {
  @override
  Widget build(BuildContext context) {
    return widget.isSelected
        ? RaisedButton(
            color: HexColor('#0D47A1'),
            onPressed: () {
              widget.selectDeliveryHour(widget.index);
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
              widget.selectDeliveryHour(widget.index);
            },
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(2.0),
            ),
            borderSide: BorderSide(color: Colors.black, width: 1.0),
          );
  }
}
