import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';

class NetworkErrorPage extends StatelessWidget {
  final String errorMessage;
  final bool showGoHomeButton;

  const NetworkErrorPage({
    Key key,
    this.errorMessage,
    @required this.showGoHomeButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        //margin: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 79.0),
              child: StateConnectivitySVG(),
            ),
            Text(
              'Oops...',
              textAlign: TextAlign.center,
              style: TextStyle(
                letterSpacing: 0.75,
                fontSize: 24,
                color: HexColor('#0D47A1'),
                fontFamily: 'Archivo Black',
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              errorMessage != null ? errorMessage : 'Has perdido la conexión a internet',
              textAlign: TextAlign.center,
              style: TextStyle(
                letterSpacing: 0.25,
                fontSize: 14,
                color: HexColor('#212B36'),
                fontFamily: 'Archivo Regular',
              ),
            ),
            // showGoHomeButton
            //     ? Row(
            //         children: <Widget>[
            //           Expanded(
            //             flex: 1,
            //             child: Padding(
            //               padding: const EdgeInsets.only(top: 16),
            //               child: RaisedButton(
            //                 color: DataUI.btnbuy,
            //                 child: Text(
            //                   'Recargar',
            //                   style: TextStyle(
            //                     color: Colors.white,
            //                   ),
            //                 ),
            //                 onPressed: () {
            //                   Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
            //                 },
            //               ),
            //             ),
            //           ),
            //         ],
            //       )
            //     : SizedBox(
            //         height: 0,
            //       ),
          ],
        ),
      ),
    );
  }
}
