import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

class KenticoToolTip extends StatefulWidget {
  Widget toolTip;
  String toolTipDescription;
  KenticoToolTip({
    Key key,
    this.toolTip,
    this.toolTipDescription,
  }) : super(key: key);
  @override
  _KenticoToolTipState createState() => _KenticoToolTipState();
}

class _KenticoToolTipState extends State<KenticoToolTip> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.transparent,
              ),
              onPressed: () => null,
            );
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        elevation: 0,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            HexColor('#F56D00'),
            HexColor('#F56D00'),
            HexColor('#F78E00'),
          ],
        ),
        title: Text(
          'Más información',
          style: DataUI.appbarTitleStyle,
        ),
      ),
      backgroundColor: HexColor('#F4F6F8'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
              child: Padding(
            padding: EdgeInsets.only(top: 25, left: 15, right: 15),
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  child: widget.toolTip,
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Text(
                    widget.toolTipDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: HexColor('#454F5B'),
                      fontFamily: 'Archivo',
                      letterSpacing: 0.25,
                    ),
                  ),
                )
              ],
            ),
          )),
        ),
      ),
    );
  }
}
