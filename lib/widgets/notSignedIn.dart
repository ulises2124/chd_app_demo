import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:flutter/material.dart';

class NotSignedInWidget extends StatelessWidget {
  final String message;
  const NotSignedInWidget({
    Key key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Entra con tu cuenta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  color: DataUI.textOpaqueStrong,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 12,
                  color: DataUI.textOpaque,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: RaisedButton(
                      disabledColor: DataUI.chedrauiColorDisabled,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      padding: EdgeInsets.only(left: 0, right: 0, bottom: 15, top: 15),
                      color: DataUI.btnbuy,
                      child: Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, DataUI.loginRoute);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      )
    );
  }
}
