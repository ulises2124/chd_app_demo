import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/Checkout/NewCreditCard.dart';
//import 'package:chd_app_demo/views/CuponesPage/CuponesPage.dart';
import 'package:chd_app_demo/views/Errors/GenericErrorPage/GenericErrorPage.dart';
import 'package:chd_app_demo/views/Errors/NetworkErrorPage/NetworkErrorPage.dart';
import 'package:chd_app_demo/views/Monedero/MonederoDetails.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/services/BovedaService.dart';
import 'package:flutter/services.dart';
import 'package:chd_app_demo/services/MonederoServices.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chd_app_demo/widgets/cardWidget.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:chd_app_demo/views/MasterPage/MasterPage.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:chd_app_demo/views/MasterPage/MenuScreen.dart';

class MonederoPage extends StatefulWidget {
  MonederoPage({
    Key key,
  }) : super(key: key);

  _MonederoPage createState() => _MonederoPage();
}

class _MonederoPage extends State<MonederoPage> {
  GlobalKey<_AdditionalCardsState> globalKeyProductSearchResults;
  String _idWallet;
  SharedPreferences prefs;
  String _idMonedero;
  //Future<dynamic> monederoResponse;
  Future response;

  Future monederoResponse() async {
    await getPreferences();
    response = MonederoServices.getIdMonedero(_idWallet);
    return response;
  }

  @override
  void initState() {
    setState(() {
      globalKeyProductSearchResults = GlobalKey();
    });
    startMonederoPage();
    super.initState();
  }

  Future<void> startMonederoPage() async {
    await getPreferences();
    await getIdMonedero();
  }

  Future getPreferences() async {
    prefs = await SharedPreferences.getInstance();
    _idWallet = prefs.getString("idWallet");
  }

  getIdMonedero() async {
    if (_idWallet != null)
      monederoResponse().then((monedero) async {
        print('getIdMonedero');
        print(monedero);
        _idMonedero = await monedero[0]["monedero"];
        print(_idMonedero);
      });
  }

  @override
  Widget build(BuildContext context) {
    return WidgetContainer(
      Scaffold(
        backgroundColor: DataUI.backgroundColor,
        appBar: GradientAppBar(
          iconTheme: IconThemeData(
            color: DataUI.primaryText, //change your color here
          ),
          title: Text(
            'Mis Tarjetas',
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
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
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
            ),
          ],
        ),
        // appBar: AppBar(
        //   leading: Builder(
        //       builder: (BuildContext context) {
        //             return IconButton(
        //             icon: Icon(Icons.close),
        //               onPressed: () {
        //                 Navigator.of(context).pop();
        //                 Navigator.pushNamed(context, '/Master');
        //               },
        //             );
        //         },
        //     ),
        //   actions: <Widget>[
        //     Column(
        //       mainAxisSize: MainAxisSize.max,
        //       children: <Widget>[
        //         IconButton(
        //           icon: Icon(Icons.add),
        //           onPressed: () {
        //             Navigator.push(
        //               context,
        //               MaterialPageRoute(
        //                 builder: (context) => AddCard(),
        //               ),
        //             );
        //           },
        //         ),
        //       ],
        //     ),
        //   ],
        //   centerTitle: true,
        //   elevation: 1,
        //   backgroundColor: DataUI.backgroundColor,
        //   title: Text(
        //     'Monedero Mi Chedraui',
        //     style: TextStyle(
        //       fontFamily: 'Rubik',
        //       fontSize: 17,
        //       fontWeight: FontWeight.w400,
        //     ),
        //   ),
        // ),
        body: FutureBuilder(
          future: monederoResponse(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
                break;
              case ConnectionState.active:
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
                break;
              case ConnectionState.none:
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
                break;
              case ConnectionState.done:
                if (snapshot.hasError) {
                  if (snapshot.error.toString().contains('No Internet connection')) {
                          return NetworkErrorPage(
                            showGoHomeButton: false,
                          );
                        } else {
                          return NetworkErrorPage(
                            errorMessage: 'Ha ocurrido un error, por favor inténtalo más tarde',
                            showGoHomeButton: true,
                          );
                        }
                } else if (snapshot.hasData && snapshot.data != null) {
                  return SafeArea(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(top: 0, bottom: 0, right: 0, left: 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          MonederoMiChedraui(idWallet: _idWallet),
                          Divider(),
                          AdditionalCards(idWallet: _idWallet),
                          Divider(),
                          Container(
                            margin: EdgeInsets.all(30),
                            child: Center(
                              child: InkWell(
                                child: Text(
                                  'Ver Mis Cupones',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(fontFamily: "Rubik", fontSize: 16, color: HexColor("#0D47A1")),
                                ),
                                onTap: () {
                                  Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
                                  Navigator.pushNamed(context, DataUI.cuponesRoute);
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //     builder: (context) => CuponesPage(),
                                  //     ),
                                  // );
                                  // Navigator.of(context).pushAndRemoveUntil(
                                  //   MaterialPageRoute(
                                  //     builder: (BuildContext context) => MasterPage(
                                  //       initialWidget: MenuItem(
                                  //         id: 'misCupones',
                                  //         title: 'Mis Cupones',
                                  //         screen: CuponesPage(),
                                  //         color: DataUI.chedrauiColor2,
                                  //         textColor: DataUI.primaryText,
                                  //       ),
                                  //     ),
                                  //   ),
                                  //   (Route<dynamic> route) => false,
                                  // );
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                } else {
                  return NetworkErrorPage(
                    errorMessage: 'Ha ocurrido un error, por favor inténtalo más tarde',
                    showGoHomeButton: true,
                  );
                }
                break;
              default:
                return Container();
            }
          },
        ),
      ),
    );
  }
}

class MonederoMiChedraui extends StatefulWidget {
  final String idWallet;
  GlobalKey<_AdditionalCardsState> keyCards;
  MonederoMiChedraui({Key key, this.idWallet, this.keyCards}) : super(key: key);
  @override
  _MonederoMiChedrauiState createState() => _MonederoMiChedrauiState();
}

class _MonederoMiChedrauiState extends State<MonederoMiChedraui> {
  String _idMonedero;
  String _idWallet;
  double saldo;
  final formatter = new NumberFormat("###,###,###,##0.00");
  SharedPreferences prefs;

  Future<void> startMonedero() async {
    await getPreferences();
    setState(() {
      _idWallet = prefs.getString('idWallet') == null ? '' : prefs.getString('idWallet');
    });
    await getIdMonedero();
    await getSaldo();
  }

  @override
  void initState() {
    startMonedero();
    super.initState();
  }

  Future<void> getPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> getIdMonedero() async {
    if (_idWallet != null) {
      var monedero = await MonederoServices.getIdMonedero(_idWallet);
      if (mounted) {
        setState(() {
          if (monedero != null && monedero.length > 0 && monedero[0] != null && monedero[0]["monedero"] != null) _idMonedero = monedero[0]["monedero"];
        });
      }
    }
  }

  Future<void> getSaldo() async {
    /*
    if (_idMonedero != null) {
      var x = await MonederoServices.getSaldoMonedero(_idMonedero);
      if (x != null && x["resultado"] != null && x["resultado"]["saldo"] != null) {
        if (mounted) {
          setState(() {
            saldo = double.parse(x["resultado"]["saldo"].toString());
          });
        }
      }
    }
    */
    try {
      var saldoResult = await MonederoServices.getSaldoMonederoRCS(_idMonedero);
      if (saldoResult != null && saldoResult["CodigoRes"] == "200" && saldoResult["DatosRCS"] != null) {
        setState(() {
          saldo = double.parse(saldoResult["DatosRCS"]["Monto"]);
          prefs.setDouble("saldoMonedero", saldo);
        });
      } else {
        throw new Exception("Not a valid object");
      }
    } catch (e) {
      print(e);
    }
  }

  /* @override
  void initState() {
    super.initState();
    this.getIdMonedero();
    this.getSaldo();
    super.initState();
  }*/

  @override
  Widget build(BuildContext context) {
    return saldo == null
        ? new Container()
        : LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                margin: EdgeInsets.only(top: 15.0, left: 15, right: 15, bottom: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        text: 'Monedero Mi Chedraui ',
                        style: TextStyle(
                          fontFamily: "Rubik",
                          fontSize: 14,
                          color: HexColor("#454F5B"),
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: _idMonedero,
                            style: TextStyle(fontFamily: "Rubik", fontSize: 14, fontWeight: FontWeight.bold, color: HexColor("#454F5B")),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(right: 2),
                                child: Text(
                                  "\$ " + formatter.format(saldo),
                                  style: TextStyle(fontFamily: "Rubik", fontSize: 24, fontWeight: FontWeight.w500, letterSpacing: 1),
                                ),
                              ),
                              Center(
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
                                    Navigator.pushNamed(context, DataUI.monederoRoute);
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //     builder: (context) => MonederoPage(),
                                    //     ),
                                    // );
                                    // Navigator.of(context).pushAndRemoveUntil(
                                    //   MaterialPageRoute(
                                    //     builder: (BuildContext context) => MasterPage(
                                    //       initialWidget: MenuItem(
                                    //         id: 'monedero',
                                    //         title: 'Monedero Mi Chedraui',
                                    //         screen: MonederoPage(),
                                    //         color: DataUI.chedrauiColor2,
                                    //         textColor: DataUI.primaryText,
                                    //       ),
                                    //     ),
                                    //   ),
                                    //   (Route<dynamic> route) => false,
                                    // );
                                  },
                                  splashColor: Colors.white,
                                  color: HexColor("#0D47A1"),
                                  icon: Icon(Icons.refresh),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(right: 5),
                              child: BarcodeMonedero(),
                            ),
                            InkWell(
                              child: Text(
                                'Detalles',
                                textAlign: TextAlign.end,
                                style: TextStyle(fontFamily: "Rubik", fontSize: 16, color: HexColor("#0D47A1")),
                              ),
                              onTap: () async {
                                var result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    settings: RouteSettings(name: DataUI.monederoDetailsRoute),
                                    builder: (context) => MonederoDetails(idMonedero: this._idMonedero),
                                  ),
                                );
                                getSaldo();
                                if (result == 'reload') {
                                  widget.keyCards.currentState.getCartera();
                                }
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                    Center(
                      child: Image.asset(
                        'assets/monedero_azul.png',
                        scale: 0.05,
                      ),
                    )
                  ],
                ),
              );
            },
          );
  }
}

class AdditionalCards extends StatefulWidget {
  final String idWallet;
  AdditionalCards({Key key, this.idWallet}) : super(key: key);
  @override
  _AdditionalCardsState createState() => _AdditionalCardsState();
}

class _AdditionalCardsState extends State<AdditionalCards> {
  List tarjetasRaw;
  List tarjetasDec = [];
  List tarjetasData;
  bool error = false;
  SharedPreferences prefs;
  String idWallet;

  Future<void> getCartera() async {
    setState(() {
      tarjetasData = [];
      tarjetasRaw = [];
      tarjetasDec = [];
    });
    prefs = await SharedPreferences.getInstance();
    idWallet = prefs.getString('idWallet');

    var cards = await BovedaService.getCartera(idWallet);
    if (cards != null) {
      tarjetasRaw = cards;

      const platform = const MethodChannel('com.cheadrui.com/decypher');
      for (var i = 0; i < tarjetasRaw.length; i++) {
        String data;
        try {
          print(tarjetasRaw[i]['identificador'].toString());
          tarjetasDec.add({
            "idWallet": tarjetasRaw[i]['idWallet'],
            "numTarjeta": await platform.invokeMethod('decypher', {"text": tarjetasRaw[i]['numTarjeta']}),
            "tipoTarjeta": tarjetasRaw[i]['tipoTarjeta'],
            "bancoEmisor": await platform.invokeMethod('decypher', {"text": tarjetasRaw[i]['bancoEmisor']}),
            "aliasTarjeta": await platform.invokeMethod('decypher', {"text": tarjetasRaw[i]['aliasTarjeta']}),
            "nomTitularTarj": await platform.invokeMethod('decypher', {"text": tarjetasRaw[i]['nomTitularTarj']}),
            "cvv": "",
            "fecExpira": await await platform.invokeMethod('decypher', {"text": tarjetasRaw[i]['fecExpira']}),
            "bin": await await platform.invokeMethod('decypher', {"text": tarjetasRaw[i]['bin']}),
            "identificador": tarjetasRaw[i]['identificador']
          });
        } on PlatformException catch (e) {
          data = "Failed to get decoded values: '${e.message}'.";
          print(data);
        }
      }
      //print("Tarjeta desencriptada->"+tarjetasDec[0].toString());
      if (mounted) {
        setState(() {
          tarjetasData = tarjetasDec;
          tarjetasData.add("newCard");
        });
      }
    } else {
      setState(() {
        error = true;
      });
    }
  }

  @override
  initState() {
    super.initState();
    this.getCartera();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !error
        ? Container(
            margin: EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Tarjetas Adicionales",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: "Rubik",
                    fontSize: 14,
                    color: HexColor("#637381"),
                  ),
                ),
                tarjetasData != null && tarjetasData.length > 0
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          return GridView.count(
                            physics: ClampingScrollPhysics(),
                            shrinkWrap: true,
                            primary: false,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 12,
                            crossAxisCount: 2,
                            childAspectRatio: constraints.maxWidth < 350 ? 31 / 32 : 32 / 26,
                            padding: EdgeInsets.only(top: 16, bottom: 0, right: 0, left: 0),
                            children: List.generate(
                              tarjetasData.length == 0 ? 0 : tarjetasData.length,
                              (index) {
                                return CardWidget(cardInfo: tarjetasData[index]);
                              },
                            ),
                          );
                        },
                      )
                    : Container(
                        margin: EdgeInsets.only(left: 15, right: 7.5),
                        height: 233.0,
                        child: Center(
                          child: CircularProgressIndicator(value: null),
                        ),
                      ),
              ],
            ),
          )
        : GenericErrorPage(
            showGoHomeButton: true,
          );
  }
}
