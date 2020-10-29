import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:flutter/material.dart';

class GenericErrorPage extends StatelessWidget {
  final String errorMessage;
  final bool showGoHomeButton;

  const GenericErrorPage({
    Key key,
    this.errorMessage,
    @required this.showGoHomeButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Icon(
                Icons.error,
                size: 58,
                color: DataUI.chedrauiColor,
              ),
            ),
            Text(
              errorMessage != null ? errorMessage : 'Hubo un error con la operación solicitada, por favor inténtalo más tarde',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
            showGoHomeButton
                ? Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: RaisedButton(
                            color: DataUI.btnbuy,
                            child: Text(
                              'Volver a Inicio',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
                              // Navigator.pop(context);
                              // Navigator.pushReplacementNamed(context, '/');
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    height: 0,
                  ),
          ],
        ),
      ),
    );
  }
}
