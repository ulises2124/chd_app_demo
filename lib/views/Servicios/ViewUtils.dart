  import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:flutter/material.dart';

Future showErrorMessage(BuildContext context, String title, String errorMessage, close) {
    return showDialog<void>(
      context: context,
      barrierDismissible: close ? false : true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
          title: title != null && title.length > 0 ?  Text(title)  : Text('Lamentamos comunicarte'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(errorMessage),
              Container(
                margin: EdgeInsets.only(top: 15),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 6,
                      child: FlatButton(
                          color: DataUI.chedrauiColor,
                          disabledColor: DataUI.chedrauiColorDisabled,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(14),
                            child: Text(
                              'Continuar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          onPressed: () {
                            if (close) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            } else {
                              Navigator.pop(context);
                            }
                          } ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
}