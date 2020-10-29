import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class PaypalPage extends StatefulWidget {
  @override
  _PaypalPageState createState() => _PaypalPageState();
}

class _PaypalPageState extends State<PaypalPage> {

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
          url: "https://chedraui-pre.firebaseapp.com/paypal/index.html?total=1.00",
          appBar: new GradientAppBar(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            HexColor('#F56D00'),
            HexColor('#F56D00'),
            HexColor('#F78E00'),
          ],
        ),
            title: new Text("Widget webview", style: TextStyle(color: Colors.white, fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 19)),
          ),
        );
  }
}
