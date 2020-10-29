import 'package:chd_app_demo/services/CarritoServices.dart';
import 'package:chd_app_demo/services/PedidosServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/renewTokenIfNeeded.dart';
import 'package:chd_app_demo/views/Errors/GenericErrorPage/GenericErrorPage.dart';
import 'package:chd_app_demo/views/Errors/NetworkErrorPage/NetworkErrorPage.dart';
import 'package:chd_app_demo/views/Pedidos/PedidoEnvioDTO.dart' as prefix0;
import 'package:chd_app_demo/views/Pedidos/PedidosStatus.dart';
import 'package:chd_app_demo/views/Pedidos/PedidosDTO.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';

class PedidosPage extends StatefulWidget {
  PedidosPage({Key key}) : super(key: key);

  _PedidosPageState createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  String _token;
  Future<bool> _hasOrders;
  Future<List<OrderDTO>> _orders;
  List<OrderDTO> orders;
  bool toggle = true;
  bool loading;

  String sort;

  void _initServices() async {
    final session = await CarritoServices.getSessionVars();
    final String token = session['accessToken'];

    if (mounted) {
      setState(() {
        _orders = PedidosServices.getOrderList(token);

        print(_orders);
      });
    }
  }

  //  Future<bool> hasOrders(_orders) async{
  //   if (_orders!=null ) {
  //          return
  //          loading=false;
  //       } else {
  //        return
  //        loading=true;
  //       }
  // }

  @override
  void initState() {
    _initServices();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetContainer(Scaffold(
      resizeToAvoidBottomPadding: true,
      backgroundColor: DataUI.backgroundColor,
      appBar: GradientAppBar(
        iconTheme: IconThemeData(
          color: DataUI.primaryText, //change your color here
        ),
        title: Text(
          'Mis Pedidos',
          style: TextStyle(color: Colors.white, fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 19),
        ),
        centerTitle: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            HexColor('#F56D00'),
            HexColor('#F56D00'),
            HexColor('#F78E00'),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 15.0),
                child: Column(
                  children: <Widget>[
                    FutureBuilder(
                      future: _orders,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        orders = snapshot.data;
                        if (snapshot.data == null || snapshot.data.length == 0) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 15.0, left: 15.0, right: 15.0),
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Image.asset('assets/misPedidos.png'),
                                  Container(
                                    padding: const EdgeInsets.all(37.0),
                                    child: Text(
                                      '''¡Aún no tienes pedidos! Realiza tu primera compra en línea.''',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: HexColor('#637381'),
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Theme(
                            data: ThemeData(
                              primaryColor: DataUI.textOpaqueMedium,
                              hintColor: DataUI.opaqueBorder,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.only(bottom: 20),
                                  child: Stack(
                                    children: <Widget>[
                                      Container(
                                        height: 2,
                                        margin: EdgeInsets.only(
                                          top: 15,
                                        ),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(color: HexColor('#D8D8D8'), width: 1.0),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 10),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Stack(
                                              alignment: Alignment.topCenter,
                                              children: <Widget>[
                                                Container(
                                                  height: 2,
                                                  margin: EdgeInsets.only(top: 6),
                                                  width: 77,
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      top: BorderSide(color: toggle ? HexColor('#F57C00') : Colors.transparent, width: 6.0),
                                                    ),
                                                  ),
                                                ),
                                                FlatButton(
                                                  padding: EdgeInsets.all(5),
                                                  onPressed: () {
                                                    setState(() {
                                                      toggle = true;
                                                    });
                                                  },
                                                  child: Text(
                                                    'En proceso',
                                                    style: TextStyle(
                                                      color: toggle ? HexColor('#212B36') : HexColor('#212B36').withOpacity(0.5),
                                                      fontFamily: 'Archivo',
                                                      fontSize: 14.0,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 0.25,
                                                    ),
                                                  ),
                                                  color: Colors.transparent,
                                                ),
                                              ],
                                            ),
                                            Stack(
                                              alignment: Alignment.topCenter,
                                              children: <Widget>[
                                                Container(
                                                  height: 2,
                                                  margin: EdgeInsets.only(top: 6),
                                                  width: 77,
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      top: BorderSide(color: !toggle ? HexColor('#F57C00') : Colors.transparent, width: 6.0),
                                                    ),
                                                  ),
                                                ),
                                                FlatButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      toggle = false;
                                                    });
                                                  },
                                                  child: Text(
                                                    'Anteriores',
                                                    style: TextStyle(
                                                      color: !toggle ? HexColor('#212B36') : HexColor('#212B36').withOpacity(0.5),
                                                      fontFamily: 'Archivo',
                                                      fontSize: 14.0,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 0.25,
                                                    ),
                                                  ),
                                                  color: Colors.transparent,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 15, bottom: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(
                                          right: 7,
                                        ),
                                        child: Text(
                                          'Ordenar:',
                                          style: TextStyle(color: HexColor('#0D47A1'), fontSize: 14, fontFamily: 'Archivo'),
                                        ),
                                      ),
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          elevation: 8,
                                          iconEnabledColor: Colors.transparent,
                                          style: TextStyle(color: HexColor('#0D47A1'), fontSize: 14, fontFamily: 'Archivo'),
                                          isDense: true,
                                          items: [
                                            // DropdownMenuItem(
                                            //   value: ":relevance",
                                            //   child: Text(
                                            //     "Relevancia",
                                            //   ),
                                            // ),
                                            // DropdownMenuItem(
                                            //   value: ":topRated",
                                            //   child: Text(
                                            //     "Mejores Valorados",
                                            //   ),
                                            // ),
                                            DropdownMenuItem(
                                              value: "ascending",
                                              child: Text(
                                                "Fecha asc",
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: "descending",
                                              child: Text(
                                                "Fecha desc",
                                              ),
                                            ),
                                            // DropdownMenuItem(
                                            //   value: ":price-asc",
                                            //   child: Text(
                                            //     "Precio (Menor-Mayor)",
                                            //   ),
                                            // ),
                                            // DropdownMenuItem(
                                            //   value: ":price-desc",
                                            //   child: Text(
                                            //     "Precio (Mayor-Menor)",
                                            //   ),
                                            // ),
                                            // DropdownMenuItem(
                                            //   value: ":mostSold",
                                            //   child: Text(
                                            //     "Más Vendidos",
                                            //   ),
                                            // ),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              sort = value;
                                            });
                                            switch (sort) {
                                              case 'descending':
                                                orders.sort((a, b) {
                                                  return b.placed.toLowerCase().compareTo(a.placed.toLowerCase());
                                                });
                                                break;
                                              case 'ascending':
                                                orders.sort((a, b) {
                                                  return a.placed.toLowerCase().compareTo(b.placed.toLowerCase());
                                                });
                                                break;
                                              default:
                                                _orders = PedidosServices.getOrderList(_token);
                                            }
                                          },
                                          value: sort,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedCrossFade(
                                  sizeCurve: Curves.easeInOut,
                                  duration: const Duration(milliseconds: 280),
                                  firstChild: ListView.builder(
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    itemCount: orders.length,
                                    itemBuilder: (context, index) {
                                      if (orders[index].statusDisplay == 'En proceso' || orders[index].statusDisplay == 'Pago pendiente') {
                                        return Order(order: orders[index]);
                                      } else {
                                        return SizedBox();
                                      }
                                    },
                                  ),
                                  secondChild: ListView.builder(
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    itemCount: snapshot.data.length,
                                    itemBuilder: (context, index) {
                                      if (orders[index].statusDisplay == 'Completado' || orders[index].statusDisplay == 'Cancelado' || orders[index].statusDisplay == 'Cancelar Pendiente') //FT197
                                      {
                                        return Order(order: orders[index]);
                                      } else {
                                        return SizedBox();
                                      }
                                    },
                                  ),
                                  crossFadeState: toggle ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}