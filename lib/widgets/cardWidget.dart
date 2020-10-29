import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/utils/payment_card.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/views/Monedero/EditCard.dart';
import 'package:chd_app_demo/views/Monedero/AddCard.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:chd_app_demo/views/Checkout/NewCreditCard.dart';

class CardWidget extends StatefulWidget {
  final cardInfo;
  final Function overrideTap;
  final bool isSelected;
  CardWidget({Key key, this.cardInfo, this.overrideTap, this.isSelected}) : super(key: key);
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  Widget build(BuildContext context) {
    final card = widget.cardInfo;
    final bool isSelected = widget.isSelected ?? false;
    if (card == "newCard") {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              settings: RouteSettings(name: DataUI.addCardRoute),
              builder: (context) => NewCreditCard(
                fromMonedero: true,
              ),
            ),
          );
        },
        child: DottedBorder(
          borderType: BorderType.Rect,
          dashPattern: [8, 4],
          color: HexColor('#C4CDD5'),
          strokeWidth: 1.5,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.add,
                  color: HexColor("#919EAB"),
                  size: 25,
                ),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Text(
                    "Agregar Tarjeta",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: HexColor("#919EAB"),
                      fontFamily: "Rubik",
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          if (widget.overrideTap == null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                settings: RouteSettings(name: DataUI.editCardRoute),
                builder: (context) => EditCard(
                  card: card,
                ),
              ),
            );
          } else
            widget.overrideTap();
        },
        child: Card(
          elevation: 1.5,
          shape: isSelected
              ? RoundedRectangleBorder(
                  side: BorderSide(width: 1.0),
                  borderRadius: BorderRadius.circular(5.0),
                )
              : null,
          child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 8),
                    child: Text(
                      card["aliasTarjeta"] == null ? "" : (card["aliasTarjeta"].toString().length > 20 ? card["aliasTarjeta"].toString().substring(0, 20) + "..." : card["aliasTarjeta"].toString()),
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 16, color: HexColor("#919EAB"), fontFamily: "Rubik"),
                    ),
                  ),
                  Container(
                    child: Text(
                      "**** **** " + (card["numTarjeta"] == null ? "" : card["numTarjeta"]),
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 14.0, letterSpacing: 1, color: HexColor("#454F5B"), fontFamily: "Rubik"),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 5),
                    child: Text(
                      card["fecExpira"] == null ? "" : card["fecExpira"],
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 12.0, color: HexColor("#454F5B"), letterSpacing: 1, fontFamily: "Rubik"),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 8,
                        child: Text(
                          card["nomTitularTarj"] == null ? "" : card["nomTitularTarj"].toString(),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          softWrap: true,
                          style: TextStyle(fontSize: 12, color: HexColor("#454F5B"), fontWeight: FontWeight.w200, fontFamily: "Rubik"),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: CardUtils.getCardIcon(() {
                          switch (card['tipoTarjeta'].toLowerCase()) {
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
                      )
                    ],
                  )
                ],
              )),
        ),
      );
    }
  }
}
