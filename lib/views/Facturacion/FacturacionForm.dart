import 'package:flutter/material.dart';

Widget procesandoFactura() {
  return Container(
    padding: const EdgeInsets.only(top: 15.0),
    child: Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Text(
                '''La información de tu factura está siendo procesada...''',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: LinearProgressIndicator(),
              ),
            ),
          ],
        )
      ],
    ),
  );
}

Widget facturacionExitosa(String correo) {
  return Container(
    margin: const EdgeInsets.only(bottom: 30.0),
    child: Column(
      children: <Widget>[
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 15.0, bottom: 30.0),
            child: Icon(
              Icons.check_circle_outline,
              color: Color.fromRGBO(57, 181, 74, 1.0),
              size: 45,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Text(
                '''Tu factura se ha generado exitosamente. Tu factura debe de estar en tu inbox ($correo) en unos minutos.''',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
