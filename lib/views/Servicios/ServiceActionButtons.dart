import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:flutter/material.dart';

class ServiceActionButtons extends StatelessWidget {
  final Function onMyServices;
  final Function onPaymentHistory;

  ServiceActionButtons({this.onMyServices, this.onPaymentHistory});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child:  Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              child: InkWell(
                onTap: onPaymentHistory,
                child: Text(
                  'Historial de transacciones',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Archivo',
                    fontSize: 16,
                    color: DataUI.chedrauiBlueColor,
                  ),
                ),
              ),
            ),
            Icon(Icons.update,color: HexColor('#F56D11'),)
          ],
        ),
    );
  }
}
