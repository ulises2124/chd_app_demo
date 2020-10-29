import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class TermCondWidget extends StatefulWidget {
  @override
  _TermCondWidgetState createState() => _TermCondWidgetState();
}

class _TermCondWidgetState extends State<TermCondWidget> {
  dynamic jsonResponse;

  @override
  void initState() {
    super.initState();
  }

  url() async {
    const url = 'https://www.chedraui.com.mx/terminos-y-condiciones';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Flushbar(
        message: "Ha ocurrido un error, por favor intente de nuevo.",
        backgroundColor: HexColor('#FD5339'),
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.FLOATING,
        margin: EdgeInsets.all(8),
        borderRadius: 8,
        icon: Icon(
          Icons.highlight_off,
          size: 28.0,
          color: Colors.white,
        ),
        duration: Duration(seconds: 3),
      )..show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        child: RichText(
          text: TextSpan(
            text: 'Al agregar mi tarjeta de crédito, débito o monedero, acepto los ',
            style: TextStyle(
              fontFamily: "Archivo",
              fontSize: 12,
              color: HexColor("#637381"),
            ),
            children: <TextSpan>[
              TextSpan(
                recognizer: new TapGestureRecognizer()..onTap = () => {url()},
                text: 'Términos y condiciones ',
                style: TextStyle(fontFamily: "Archivo", fontSize: 12, fontWeight: FontWeight.normal, color: HexColor("#0D47A1")),
              ),
              TextSpan(text: "del servicio que ofrece esta aplicación. ")
            ],
          ),
        ),
      );
    });
  }
}
