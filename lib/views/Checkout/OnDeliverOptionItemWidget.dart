import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:flutter/material.dart';

class OnDeliverOptionItem extends StatefulWidget {
  final int index;
  final bool isSelected;
  final Function(int) selectOnDeliverPayMethod;

  OnDeliverOptionItem(
    this.selectOnDeliverPayMethod, {
    Key key,
    this.index,
    this.isSelected,
  }) : super(key: key);

  _OnDeliverOptionItemState createState() => _OnDeliverOptionItemState();
}

class _OnDeliverOptionItemState extends State<OnDeliverOptionItem> {
  @override
  Widget build(BuildContext context) {
    List<Widget> onDeliveryPaymentMethod = [
      CardVisa(59, 109, widget.isSelected),
      CardMasterCard(59, 109, widget.isSelected),
      CardAmex(59, 109, widget.isSelected),
      CardCash(59, 109, widget.isSelected),
      CardEcoupon(59, 109, widget.isSelected),
    ];
    return InkWell(
      child: onDeliveryPaymentMethod[widget.index],
      onTap: () {
        widget.selectOnDeliverPayMethod(widget.index);
      },
    );
  }
}
