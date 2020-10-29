
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:flutter/material.dart';

class Comparador extends StatefulWidget {
  final Widget child;

  Comparador({Key key, this.child}) : super(key: key);

  _ComparadorState createState() => _ComparadorState();
}

class _ComparadorState extends State<Comparador> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
        Navigator.pushNamed(context, DataUI.comparadorPreciosRoute);
        // Navigator.of(context).pushAndRemoveUntil(
        //   MaterialPageRoute(
        //     builder: (BuildContext context) => MasterPage(
        //         initialWidget: MenuItem(
        //       id: 'comparadorPrecios',
        //       title: 'Comparador de Precios',
        //       screen: ComparadorPrecios(),
        //       color: DataUI.chedrauiColor2,
        //       textColor: DataUI.primaryText,
        //     )),
        //   ),
        //   (Route<dynamic> route) => false,
        // );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 7.5, horizontal: 15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(
          children: <Widget>[
            Container(
              width: 48,
              height: 94,
              margin: EdgeInsets.only(right: 15),
              child: ComparadorSVG(),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Comparador de Precios",
                    softWrap: true,
                    style: TextStyle(
                      fontFamily: 'Archivo',
                      color: HexColor("#0D47A1"),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Escanea tus productos y descubre que en Chedraui ¡Te cuesta menos!",
                    softWrap: true,
                    maxLines: 4,
                    style: TextStyle(fontWeight: FontWeight.w300, color: HexColor("#454F5B"), fontSize: 14, fontFamily: 'Rubik'),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
