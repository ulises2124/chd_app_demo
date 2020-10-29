import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/views/Pedidos/PedidoDetailsEnvio.dart';
import 'package:chd_app_demo/views/Pedidos/PedidosDTO.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:chd_app_demo/utils/HexValueConverter.dart';

class Order extends StatelessWidget {
  final OrderDTO order;
  Order({Key key, this.order}) : super(key: key);

  static String _lastUpdate(String placed) {
    final _placed = DateTime.parse(placed);
    final _now = DateTime.now();
    final _update = _now.difference(_placed);
    return "${timeago.format(_now.subtract(_update), locale: 'es')}";
  }

  static _orderStatus(BuildContext context, OrderDTO order) {
    switch (order.statusDisplay) {
      case "En proceso":
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: Icon(
                         FontAwesomeIcons.solidArrowAltCircleRight,
                          color: DataUI.chedrauiBlueColor,
                        ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(bottom: 2.0),
                        child: Text(
                          'Su pedido está en proceso',
                          style: TextStyle(
                            fontFamily: 'Archivo',
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.25,
                            color: HexColor('#0D47A1'),
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          'Última actualización ${_lastUpdate(order.placed)}',
                          style: TextStyle(fontSize: 10.0, fontFamily: 'Archivo', letterSpacing: 0.25, fontWeight: FontWeight.w400, color: HexColor('#637381')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            /*Container(
              margin: const EdgeInsets.only(bottom: 10.0),
              child: LinearPercentIndicator(
                width: MediaQuery.of(context).size.width * 0.85,
                lineHeight: 6.0,
                percent: 0.6,
                backgroundColor: Color.fromRGBO(196, 205, 213, 1),
                progressColor: DataUI.chedrauiBlueColor,
              ),
            ),*/
          ],
        );
      case "Completado":
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        margin: const EdgeInsets.only(left: 5.0, right: 3.0),
                        child: Icon(
                          FontAwesomeIcons.solidCheckCircle,
                          color: HexColor('#39B54A'),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      'Su pedido ha sido entregado',
                      style: TextStyle(
                        fontFamily: 'Archivo',
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.25,
                        color: HexColor('#0D47A1'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case "Pago pendiente":
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    child: Container(
                      child: Icon(Icons.error, color: DataUI.chedrauiColor,),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(bottom: 2.0),
                        child: Text(
                          'Su pago está pendiente',
                          style: TextStyle(
                            fontFamily: 'Archivo',
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.25,
                            color: HexColor('#0D47A1'),
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          'Última actualización ${_lastUpdate(order.placed)}',
                          style: TextStyle(fontSize: 10.0, fontFamily: 'Archivo', letterSpacing: 0.25, fontWeight: FontWeight.w400, color: HexColor('#637381')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10.0),
              child: LinearPercentIndicator(
                width: MediaQuery.of(context).size.width * 0.85,
                lineHeight: 6.0,
                percent: 0.1,
                backgroundColor: Color.fromRGBO(196, 205, 213, 1),
                progressColor: DataUI.chedrauiBlueColor,
              ),
            ),
          ],
        );
      case "Cancelado":
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    child: Container(
                      child: Container(
                        child: Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      'Este pedido ha sido cancelado',
                      style: TextStyle(
                        fontFamily: 'Archivo',
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.25,
                        color: HexColor('#0D47A1'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      default:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          width: 25.0,
                          height: 25.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: DataUI.chedrauiColor,
                          ),
                        ),
                        Container(
                          child: Icon(
                            Icons.cached,
                            size: 20.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(bottom: 2.0),
                        child: Text(
                          'Pedido: ${order.statusDisplay}',
                          style: TextStyle(
                            fontFamily: 'Archivo',
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.25,
                            color: HexColor('#0D47A1'),
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          'Última actualización ${_lastUpdate(order.placed)}',
                          style: TextStyle(fontSize: 10.0, fontFamily: 'Archivo', letterSpacing: 0.25, fontWeight: FontWeight.w400, color: HexColor('#637381')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10.0),
              child: LinearPercentIndicator(
                width: MediaQuery.of(context).size.width * 0.85,
                lineHeight: 6.0,
                percent: 0.6,
                backgroundColor: Color.fromRGBO(196, 205, 213, 1),
                progressColor: DataUI.chedrauiBlueColor,
              ),
            ),
          ],
        );
    }
  }

  static _getOrderDetails(BuildContext context, OrderDTO order) {
    if (order.statusDisplay != '') {
      return () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: RouteSettings(name: DataUI.pedidoDetailsRoute),
            builder: (BuildContext context) => DeliveryOrderDetails(
              orderCode: order.code,
            ),
          ),
        );
      };
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15.0, left: 15.0, right: 15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color.fromRGBO(13, 19, 15, 0.15),
            offset: Offset(0.0, 2.0),
            blurRadius: 5.0,
          ),
        ],
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      child: Container(
        margin: const EdgeInsets.only(top: 16.0, left: 15.0, right: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    'Pedido número #${order.code}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: HexColor('#637381')),
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
                    child: Placed(
                      placed: order.placed,
                    )),
              ],
            ),
            _orderStatus(context, order),
            Container(
              margin: const EdgeInsets.only(bottom: 15.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: OutlineButton(
                      color: HexColor('#0D47A1'),
                      borderSide: BorderSide(color: HexColor('#0D47A1')),
                      disabledBorderColor: DataUI.chedrauiColorDisabled,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(11.0),
                        child: Text(
                          'Detalles de pedido',
                          style: TextStyle(
                            color: HexColor('#0D47A1'),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      onPressed: _getOrderDetails(context, order),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Placed extends StatefulWidget {
  final String placed;
  Placed({Key key, this.placed}) : super(key: key);

  _PlacedState createState() => _PlacedState();
}

class _PlacedState extends State<Placed> {
  @override
  String _placed(placed) {
    final plce = DateTime.parse(placed);
    final f = new DateFormat('dd-MM-yyyy');
    final update = f.format(plce);
    return update;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _placed(widget.placed),
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: HexColor('#637381')),
    );
  }
}
