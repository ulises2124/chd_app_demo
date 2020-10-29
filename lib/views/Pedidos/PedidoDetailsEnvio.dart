import 'package:chd_app_demo/services/CarritoServices.dart';
import 'package:chd_app_demo/services/PedidosServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/utils/renewTokenIfNeeded.dart';
import 'package:chd_app_demo/views/Pedidos/PedidosController.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';

class DeliveryOrderDetails extends StatefulWidget {
  final String orderCode;
  DeliveryOrderDetails({Key key, this.orderCode}) : super(key: key);

  _DeliveryOrderDetailsState createState() => _DeliveryOrderDetailsState();
}

class _DeliveryOrderDetailsState extends State<DeliveryOrderDetails> {
  var _orders;
  bool reloading = false;
  String lastUpdateStr = "Hace un momento";
  DateTime lastUpdate = DateTime.now();
  @override
  void initState() {
    super.initState();
    _orders = _orderDetails(widget.orderCode);
    new Timer.periodic(Duration(seconds: 5), (Timer t) {
      if (mounted) _checkLastUpdate();
    });
  }

  _orderDetails(String _orderCode) async {
    final session = await CarritoServices.getSessionVars();
    final String token = session['accessToken'];
    var result = await PedidosServices.getOrderDetails(token, _orderCode);
    setState(() {
      reloading = false;
      lastUpdate = DateTime.now();
    });
    _checkLastUpdate();
    return result;
  }

  _checkLastUpdate() {
    DateTime newDate = DateTime.now();
    Duration diff = newDate.difference(lastUpdate);
    setState(() {
      if (diff < Duration(seconds: 10)) {
        lastUpdateStr = "Hace un momento";
      } else if (diff >= Duration(seconds: 10) && diff < Duration(minutes: 1)) {
        lastUpdateStr = "Hace unos segundos";
      } else if (diff >= Duration(minutes: 1) && diff < Duration(minutes: 2)) {
        lastUpdateStr = "Hace un minuto";
      } else {
        lastUpdateStr = "Hace ${diff.inMinutes.toString()} minutos";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WidgetContainer(
        Scaffold(
        resizeToAvoidBottomPadding: true,
        backgroundColor: DataUI.backgroundColor,
        appBar: GradientAppBar(
            centerTitle: true,
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
              'Pedido #${widget.orderCode}',
              style: TextStyle(color: Colors.white, fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 19),
            ),
            leading: Builder(builder: (BuildContext context) {
              return IconButton(
                  icon: Icon(Icons.arrow_back),
                  color: DataUI.whiteText,
                  onPressed: () {
                    Navigator.pop(context);
                  });
            })),
        body: FutureBuilder(
          future: _orders,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
            } else if (snapshot.data is List) {
              return SafeArea(
                  child: SingleChildScrollView(
                      child: Theme(
                          data: ThemeData(
                            primaryColor: DataUI.textOpaqueMedium,
                            hintColor: DataUI.opaqueBorder,
                          ),
                          child: Center(
                            child: Container(
                              margin: EdgeInsets.all(15),
                              child: Text(
                                'No se encontró el detalle del pedido, intente mas tarde.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ))));
            } else {
              return SafeArea(
                child: SingleChildScrollView(
                  child: Theme(
                    data: ThemeData(
                      primaryColor: DataUI.textOpaqueMedium,
                      hintColor: DataUI.opaqueBorder,
                    ),
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          PedidosController.orderDetails(context, snapshot.data),
                          ListView.builder(
                            physics: ClampingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.data.consignments.length,
                            itemBuilder: (BuildContext context, int i) {
                              return Container(
                                margin: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      offset: Offset(2.0, 1.0),
                                      blurRadius: 5.0,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(17.0, 15.0, 17.0, 0.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        /* boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: Color.fromRGBO(13, 19, 15, 0.15),
                                          offset: Offset(0.0, 2.0),
                                          blurRadius: 5.0,
                                        ),
                                      ], */
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(2.0), topRight: Radius.circular(2.0)),
                                      ),
                                      child: PedidosController.consignmentStatus(snapshot.data.consignments, i),
                                    ),
                                    Container(
                                      height: 1.0,
                                      color: Colors.grey[200],
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(17.0, 15.0, 17.0, 15.0),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            /* boxShadow: <BoxShadow>[
                                            BoxShadow(
                                              color: Color.fromRGBO(
                                                  13, 19, 15, 0.15),
                                              offset: Offset(0.0, 2.0),
                                              blurRadius: 5.0,
                                            ),
                                          ], */
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              PedidosController.deliveryDetails(snapshot.data, i),
                                            ],
                                          ),
                                        ),
                                        snapshot.data.consignments[i].status == 'CANCELLED' || snapshot.data.consignments[i].status == 'DELIVERY_COMPLETED' || snapshot.data.consignments[i].status == 'PICKUP_COMPLETE'
                                            ? SizedBox(height: 0)
                                            : Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  /* boxShadow: <BoxShadow>[
                                            BoxShadow(
                                              color: Color.fromRGBO(
                                                  13, 19, 15, 0.15),
                                              offset: Offset(0.0, 2.0),
                                              blurRadius: 5.0,
                                            ),
                                          ], */
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Container(
                                                      height: 1.0,
                                                      color: Colors.grey[200],
                                                    ),
                                                    PedidosController.trackingMap(context, snapshot.data, i),
                                                    //PedidosController.pickerInfo(context, snapshot.data, i),
                                                  ],
                                                ),
                                              ),
                                        Container(
                                          height: 1.0,
                                          color: Colors.grey[200],
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            /* boxShadow: <BoxShadow>[
                                            BoxShadow(
                                              color: Color.fromRGBO(
                                                  13, 19, 15, 0.15),
                                              offset: Offset(0.0, 2.0),
                                              blurRadius: 5.0,
                                            ),
                                          ], */
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Expanded(flex: 6, child: Container(padding: EdgeInsets.only(right: 5, left: 5), child: Text("Última actualización: $lastUpdateStr", style: TextStyle(color: DataUI.textOpaqueMedium, fontSize: 10)))),
                                                  Expanded(
                                                      flex: 1,
                                                      child: !reloading
                                                          ? IconButton(
                                                              onPressed: () async {
                                                                setState(() {
                                                                  reloading = true;
                                                                  print('Orders set to null');
                                                                });
                                                                setState(() {
                                                                  _orders = _orderDetails(widget.orderCode);
                                                                  print('Orders details done');
                                                                });
                                                              },
                                                              splashColor: Colors.white,
                                                              color: HexColor("#0D47A1"),
                                                              icon: Icon(Icons.refresh),
                                                            )
                                                          : Container(
                                                              height: 20,
                                                              width: 20,
                                                              child: CircularProgressIndicator(),
                                                            )),
                                                  Expanded(
                                                    flex: 5,
                                                    child: snapshot.data.consignments[i].status == 'CANCELLED' || snapshot.data.consignments[i].status == 'DELIVERY_COMPLETED' || snapshot.data.consignments[i].status == 'PICKUP_COMPLETE' ? SizedBox(height: 0) : PedidosController.chatWindow(snapshot.data, i),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 1.0,
                                      color: Colors.grey[200],
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        /* boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: Color.fromRGBO(13, 19, 15, 0.15),
                                          offset: Offset(0.0, 2.0),
                                          blurRadius: 5.0,
                                        ),
                                      ], */
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(2.0),
                                          bottomRight: Radius.circular(2.0),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          PedidosController.pedidos(snapshot.data, i),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        ),
      )
    );
  }
}
