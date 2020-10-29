import 'package:flutter/material.dart';


class BannerChedraui extends StatefulWidget {
  final Widget child;

  BannerChedraui({Key key, this.child}) : super(key: key);

  _BannerChedrauiState createState() => _BannerChedrauiState();
}

class _BannerChedrauiState extends State<BannerChedraui> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 15, left: 15, bottom: 15),
      child: Container(
        padding: EdgeInsets.only(right: 33, left: 33),
        child: Container(
          width: 270,
          child: Column(
            children: <Widget>[
              Container(
                child: Text(
                  "Precios, promociones y disponibilidad son en base a inventario local de cada tienda Chedraui.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Rubik",
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                height: 53,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/marketing.png"),
                    fit: BoxFit.fill,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
