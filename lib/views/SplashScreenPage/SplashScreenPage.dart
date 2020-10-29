import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/DataUI.dart';

class SplashScreenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('SplashScreenPage'),
            FlatButton(
              child: Text("Go to Login"),
              onPressed: () {
                // Navigator.pop(context);
                Navigator.pushReplacementNamed(context, DataUI.loginRoute);
              },
            )
          ],
        ),
      ),
    );
  }
}
