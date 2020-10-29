import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:flutter/material.dart';

class EncryptionDisclaimer extends StatelessWidget {
  const EncryptionDisclaimer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15.0),
      // padding: const EdgeInsets.all(15.0),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Icon(
              Icons.lock,
              size: 14,
              color: HexColor('#919EAB'),
            ),
          ),
          Expanded(
            flex: 8,
            child: Text(
              'Compra seguro. Tu información se encripta con un SSL a 256 bits.',
              style: TextStyle(
                fontSize: 10,
                // fontWeight: FontWeight.w500,
                color: HexColor('#212B36'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
