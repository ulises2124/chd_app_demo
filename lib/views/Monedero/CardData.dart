import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/utils/payment_card.dart';
import 'package:flutter/material.dart';

class CardData {
  String idWallet = '';
  String numTarjeta = '';
  String tipoTarjeta = '';
  String bancoEmisor = 'No identificado';
  String aliasTarjeta = '';
  String nomTitularTarj = '';
  String cvv = '';
  String fecExpira = '';
  String deviceSessionId = '';
}

class CardItem extends StatelessWidget {
  String numTarjeta;
  String tipoTarjeta;
  Function selectCard;
  Function open;
  bool selected;
  dynamic identificador;
  CardItem({
    this.numTarjeta,
    this.tipoTarjeta,
    this.open,
    this.selected,
    this.selectCard,
    this.identificador,
  });

  @override
  Widget build(BuildContext context) {
    switch (numTarjeta) {
      case 'new':
        return FlatButton(
          padding: EdgeInsets.all(0),
          onPressed: () {
            selectCard("NEW");
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Text(
                    "+ Añadir tarjeta",
                    style: TextStyle(
                      fontFamily: 'Archivo',
                      fontSize: 14,
                      color: DataUI.chedrauiBlueColor,
                    ),
                  ),
                  // margin: EdgeInsets.only(left: 5),
                )
              ],
            ),
          ),
        );
        break;
      case '':
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Icon(Icons.warning),
              Container(
                child: Text("No hay tarjetas asociadas"),
                margin: EdgeInsets.only(left: 5),
              )
            ],
          ),
        );
        break;

      default:
        return FlatButton(
          
          padding: EdgeInsets.all(0),
          onPressed: () {
           selectCard(identificador);
          },
          child: Container(
            width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                CardUtils.getCardIcon(() {
                  switch (tipoTarjeta.toLowerCase()) {
                    case "visa":
                      return CardType.Visa;
                      break;
                    case "mastercard":
                      return CardType.Master;
                      break;
                    case "american express":
                      return CardType.AmericanExpress;
                      break;
                    default:
                      return CardType.Others;
                  }
                }()),
                Container(
                  child: Text(
                    "**** **** **** " + numTarjeta,
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: selected ? DataUI.chedrauiBlueColor : HexColor('#454F5B'),
                    ),
                  ),
                  margin: EdgeInsets.only(left: 5),
                )
              ],
            ),
          ),
        );
    }
  }
}
