import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:flutter/material.dart';

class ToastPromo extends StatelessWidget {
  const ToastPromo({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15.0),
      padding: const EdgeInsets.all(15.0),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Text(
              '🎉',
              style: TextStyle(
                fontSize: 28,
              ),
            ),
          ),
          Flexible(
            child: RichText(
              text: TextSpan(
                text: 'Compra a meses sin intereses' + ' ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: DataUI.chedrauiColor,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'pagando con tarjetas Bancomer o Banamex. ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//
