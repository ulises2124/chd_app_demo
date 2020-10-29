import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/DataUI.dart';

class GradientButton extends StatelessWidget {
  final GestureTapCallback onPressed;
  final String text;

  GradientButton({@required this.onPressed, @required this.text});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10.0,
      // color: Colors.transparent,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onPressed,
        splashColor: DataUI.btnSplashColor,
        child: Ink(
          height: 50.0,
          decoration: ShapeDecoration(
              shape: const StadiumBorder(),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: DataUI.btnGradient,
              )),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 30.0),
            ),
          ),
        ),
      ),
    );
  }
}
