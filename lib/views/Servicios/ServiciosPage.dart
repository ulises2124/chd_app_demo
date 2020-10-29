import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/HomePage/BalanceMonederoBar.dart';
import 'package:chd_app_demo/views/HomePage/CarouselHomeBanner.dart';
import 'package:chd_app_demo/views/HomePage/DeliveryMethodSelectionBar.dart';
import 'package:chd_app_demo/views/LoginPage/LoginPage.dart';
import 'package:chd_app_demo/views/Servicios/MyServices.dart';
import 'package:chd_app_demo/views/Servicios/PaymentHistory.dart';
import 'package:chd_app_demo/views/Servicios/ServiceActionButtons.dart';
import 'package:chd_app_demo/views/Servicios/ServiceCards.dart';
import 'package:chd_app_demo/views/Servicios/ServiceCarousel.dart';
import 'package:chd_app_demo/views/Servicios/ServiciosAvailable.dart';
import 'package:chd_app_demo/views/Servicios/SliderServicios.dart';
import 'package:chd_app_demo/views/Servicios/Util.dart';
import 'package:chd_app_demo/views/Servicios/ViewUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sticky_headers/sticky_headers/widget.dart';

class PagoServicios extends StatefulWidget {
  final String servicesUrl = "https://us-central1-chedraui-bill-pay.cloudfunctions.net/services";

  PagoServicios({Key key}) : super(key: key);

  @override
  _PagoServiciosState createState() => _PagoServiciosState();
}

class _PagoServiciosState extends State<PagoServicios> {
  final formatter = NumberFormat("###,###,###,##0.00");
  SharedPreferences prefs;
  bool _isLoggedIn = false;
  bool hasFavServices = false;
  double saldoMonedero = 0;
  String email;
  bool isLoading = true;
  List<ServiceCard> services = new List<ServiceCard>();
  List<ServiceCard> favServices = new List<ServiceCard>();
  List categories = [];
  List historyResponse;
  var textData = [
    {
      'title': ['Ahora puedes pagar tus servicios', 'con el saldo de tu monedero', 'Mi Chedraui'],
      'subTitle': ['No hagas filas y aprovecha el saldo de tu', 'monedero para pagar tus recibos de luz,', 'agua, internet y recargas telefónicas. ', '¡Fácil y sencillo!'],
      'image': 'assets/pagoDeServicios.png',
    },
    {
      'title': ['Seguro y sin complicaciones'],
      'subTitle': ['En línea, pero 100% seguro, para que no te ', ' preocupes de nada y sigas con tu día.'],
      'image': 'assets/lock.png'
    },
    {
      'title': ['¡Empieza ahora!'],
      'subTitle': ['Sin desplazarte, desde donde quieras,', '¡aprovecha tu tiempo y no hagas fila!'],
      'image': 'assets/cel.png',
    }
  ];

  int _current = 0;

  var currentImage = 'assets/pagoDeServicios.png';

  Widget currentWidget = Center(
    child: Column(
      children: <Widget>[
        Text(
          "Ahora puedes pagar tus servicios",
          textAlign: TextAlign.center,
          style: TextStyle(color: DataUI.chedrauiBlueColor, fontSize: 20.0, fontWeight: FontWeight.bold, fontFamily: 'Archivo'),
        ),
        Text(
          "con el saldo de tu monedero",
          textAlign: TextAlign.center,
          style: TextStyle(color: DataUI.chedrauiBlueColor, fontSize: 20.0, fontWeight: FontWeight.bold, fontFamily: 'Archivo'),
        ),
        Text(
          "Mi Chedraui",
          textAlign: TextAlign.center,
          style: TextStyle(color: DataUI.chedrauiBlueColor, fontSize: 20.0, fontWeight: FontWeight.bold, fontFamily: 'Archivo'),
        ),
      ],
    ),
  );

  bool toLogin = false;
  @override
  void initState() {
    if (mounted) {
      getPreferences().then((x) {
        setState(() {
          saldoMonedero = prefs.getDouble('saldoMonedero') ?? 0.0;
          _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
          email = prefs.getString('email');
          getMyServices();
          getHistory();
          getServices();
        });
      });
    }
    super.initState();
  }

  Future getPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  void setLoading(bool loading) {
    setState(() {
      isLoading = loading;
    });
  }

  getHistory() async {
    http.Response result = await http.get('${widget.servicesUrl}/logs/history/$email', headers: {"Content-Type": "application/json"});
    print('${widget.servicesUrl}/logs/history/$email');
    if (result.statusCode == 200) {
      Map<String, dynamic> map = json.decode(result.body);
      setState(() {
        historyResponse = map["logs"];
      });
    }
  }

  Future getServices() async {
    try {
      setLoading(true);
      http.Response result = await http.get('https://deliver.kenticocloud.com/a38e9287-f45b-00de-6ce8-23adabd3c0e5/items?system.type=servicios', headers: {"Content-Type": "application/json"});
      if (result.statusCode == 200) {
        Map<String, dynamic> map = json.decode(result.body);
        List<dynamic> response = map["items"];
        response.forEach((f) {
          for (var e in f['elements']['informacion_general_de_servicios__categoria']['value']) {
            categories.add(e['name']);
          }
        });
        categories = categories.toSet().toList();
        setState(() {
          services = mapServices(response, saldoMonedero, email);
        });
        print(services);
      }
    } catch (error) {
      print(error);
      showErrorMessage(context, "Error en servicios", "Ocurrio un error al obtener la lista de servicios", false);
    } finally {
      setLoading(false);
    }
  }

  Future getMyServices() async {
    try {
      http.Response result = await http.get('${widget.servicesUrl}/user/$email/services', headers: {"Content-Type": "application/json"});
      print('${widget.servicesUrl}/user/$email/services');
      if (result.statusCode == 200) {
        Map<String, dynamic> map = json.decode(result.body);
        List<dynamic> response = map["services"];
        setState(() {
          
          favServices = mapFavoriteServices(response, saldoMonedero, email, () => {}, false);
          print(favServices);
          hasFavServices = true;
        });
      } else if (result.statusCode == 404) {
        setState(() {
          hasFavServices = true;
        });
      }
    } catch (error) {
      setState(() {
        hasFavServices = true;
      });
      print(error);
      //showErrorMessage(context, "Error en mis servicios", "Ha ocurrido un error al cargar los servicios", false);
    }
  }

  callBackFuncion(int index, reason) {
    setState(
      () {
        _current = index;
      },
    );
  }

  goToMyServices() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: DataUI.misServiciosRoute),
        builder: (BuildContext context) => MyServices(
          saldoMonedero: saldoMonedero,
          email: email,
        ),
      ),
    );
    if (result == null) {
      getMyServices();
    }
  }

  goToServices() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: DataUI.serviciosDisponibles),
        builder: (BuildContext context) => ServiciosAvailable(),
      ),
    );
  }

  goToPaymentHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: DataUI.historialPagosServiciosRoute),
        builder: (BuildContext context) => PaymentHistory(
          email: email,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoggedIn
        ? SafeArea(
            child: CustomScrollView(
              physics: NeverScrollableScrollPhysics(),
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildListDelegate([
                    StickyHeader(
                      header: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(color: HexColor('#FD9924')),
                        child: Flex(
                          direction: Axis.vertical,
                          children: <Widget>[
                            Stack(
                              overflow: Overflow.visible,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(bottom: 15),
                                  child: Column(
                                    children: <Widget>[
                                      //DeliveryMethodSelection(),
                                      BalanceMonederoBar()
                                    ],
                                  ),
                                ),
                                // _isLoggedIn ? BalanceMonederoBar() : Container(),
                              ],
                            )
                          ],
                        ),
                      ),
                      content: Container(
                        height: MediaQuery.of(context).size.height * 0.9,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Stack(
                              children: <Widget>[
                                isLoading
                                    ? SizedBox()
                                    : Positioned(
                                        bottom: 0,
                                        left: 60,
                                        child: Image.asset(
                                          'assets/pagoDeServicios.png',
                                          width: 300,
                                        ),
                                      ),
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.745,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      isLoading
                                          ? Center(
                                              child: Container(
                                                margin: const EdgeInsets.all(50.0),
                                                child: CircularProgressIndicator(value: null),
                                              ),
                                            )
                                          : Column(
                                              children: <Widget>[
                                                historyResponse != null && historyResponse.length > 0
                                                    ? Container(
                                                        margin: EdgeInsets.symmetric(horizontal: 15),
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: <Widget>[
                                                            Container(
                                                              child: InkWell(
                                                                onTap: goToPaymentHistory,
                                                                child: Text(
                                                                  'Historial de transacciones',
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(
                                                                    fontFamily: 'Archivo',
                                                                    fontSize: 16,
                                                                    color: DataUI.chedrauiBlueColor,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Icon(
                                                              Icons.update,
                                                              color: HexColor('#F56D11'),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    : SizedBox(),
                                                Container(
                                                  margin: EdgeInsets.only(top: 15, bottom: 15),
                                                  child: Center(
                                                    child: Text(
                                                      'Selecciona el servicio que deseas pagar',
                                                      style: TextStyle(color: HexColor('#454F5B'), fontFamily: 'Archivo', fontSize: 14, letterSpacing: 0.25),
                                                    ),
                                                  ),
                                                ),
                                                hasFavServices ? ServiceCarousel(
                                                  title: "Tus servicios",
                                                  services: favServices,
                                                  seeMore: goToMyServices,
                                                  heightCarousel: 220,
                                                ) : Center( 
                                                  child: CircularProgressIndicator(),
                                                ),
                                                services != null && services.length > 0
                                                    ? SizedBox(
                                                        width: double.infinity,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: <Widget>[
                                                            Container(
                                                              width: 45,
                                                              height: 5,
                                                              margin: EdgeInsets.only(left: 20.0, top: 20.0),
                                                              decoration: BoxDecoration(
                                                                border: Border(
                                                                  bottom: BorderSide(width: 5.0, color: HexColor('#FBC02D')),
                                                                ),
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: <Widget>[
                                                                Container(
                                                                  margin: EdgeInsets.only(left: 20.0, top: 8.0, bottom: 10.0),
                                                                  child: Text(
                                                                    "Servicios disponibles",
                                                                    style: TextStyle(color: DataUI.chedrauiBlueColor, fontSize: 20.0, fontWeight: FontWeight.w600),
                                                                  ),
                                                                ),
                                                                Container(
                                                                    margin: EdgeInsets.only(left: 20.0, top: 8.0, bottom: 10.0, right: 20.0),
                                                                    child: InkWell(
                                                                      onTap: goToServices,
                                                                      child: Text(
                                                                        "Ver todos",
                                                                        style: TextStyle(color: DataUI.chedrauiBlueColor, fontSize: 15.0, fontWeight: FontWeight.w400),
                                                                      ),
                                                                    ))
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              width: MediaQuery.of(context).size.width,
                                                              height: 110,
                                                              child: ListView.builder(
                                                                  physics: ClampingScrollPhysics(),
                                                                  shrinkWrap: true,
                                                                  scrollDirection: Axis.horizontal,
                                                                  itemCount: services.length,
                                                                  itemBuilder: (context, index) {
                                                                    return ServiceCard(
                                                                      extendedCard: services[index].extendedCard,
                                                                      savedReference: services[index].savedReference,
                                                                      serviceID: services[index].serviceID,
                                                                      cardBackground: services[index].cardBackground,
                                                                      categories: services[index].categories,
                                                                      saldoMonedero: services[index].saldoMonedero,
                                                                      serviceDescription: services[index].serviceDescription,
                                                                      serviceLogo: services[index].serviceLogo,
                                                                      serviceName: services[index].serviceName,
                                                                      sku: services[index].sku,
                                                                      skuComision: services[index].skuComision,
                                                                      userEmail: services[index].userEmail,
                                                                      montosSkus: services[index].montosSkus,
                                                                      messageToUser: services[index].messageToUser,
                                                                      toolTip: services[index].toolTip,
                                                                      toolTipDescription: services[index].toolTipDescription,
                                                                      tipoPago: services[index].tipoPago,
                                                                      status: services[index].status,
                                                                      montoMinimo: services[index].montoMinimo,
                                                                      montoMaximo: services[index].montoMaximo,
                                                                    );
                                                                  }),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    : Center(
                                                        child: CircularProgressIndicator(),
                                                      ),

                                                // ServiceCarousel(title: "Electricidad", services: getServicesByCategory(services, "Electricidad")),
                                                // ServiceCarousel(title: "Telefonía", services: getServicesByCategory(services, "Telefonia")),
                                                // ServiceCarousel(title: "Internet", services: getServicesByCategory(services, "Internet")),
                                                // ServiceCarousel(title: "Telecable", services: getServicesByCategory(services, "Telecable")),
                                                // ServiceCarousel(title: "Gas", services: getServicesByCategory(services, "Gas")),
                                                // ServiceCarousel(title: "Gobierno CDMX", services: getServicesByCategory(services, "Gobierno CDMX")),
                                                // ServiceCarousel(title: "Gobierno EdoMex", services: getServicesByCategory(services, "Gobierno EdoMex")),
                                                // ServiceCarousel(title: "Tiempo Aire", services: getServicesByCategory(services, "Tiempo Aire")),
                                                // ServiceCarousel(title: "Peaje", services: getServicesByCategory(services, "Peaje")),
                                              ],
                                            ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ]),
                )
              ],
            ),
          )
        : SafeArea(
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 25),
                  child: CarouselSlider.builder(
                    options: CarouselOptions(
                      onPageChanged: callBackFuncion,
                      height: 520,
                      autoPlay: false,
                      aspectRatio: 16 / 9,
                      viewportFraction: 1.0,
                    ),
                    itemCount: textData != null ? textData.length : 0,
                    itemBuilder: (BuildContext context, int itemIndex) => SliderServicios(
                      slider: textData[itemIndex],
                    ),
                  ),
                ),
                Container(
                  height: 5,
                  margin: EdgeInsets.only(top: 15),
                  child: ListView.builder(
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: textData.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: _current == index ? 17 : 8.0,
                          height: 5.0,
                          // padding: EdgeInsets.only(top: 20),
                          margin: EdgeInsets.symmetric(horizontal: 2.0),
                          decoration: BoxDecoration(
                            shape: _current == index ? BoxShape.rectangle : BoxShape.circle,
                            borderRadius: _current == index ? BorderRadius.circular(10) : null,
                            color: _current == index ? HexColor("#F57C00") : HexColor("#F57C00").withOpacity(0.5),
                          ),
                        );
                      }),
                ),
                Container(
                  margin: EdgeInsets.only(left: 15, right: 15, top: 51),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        flex: 6,
                        child: FlatButton(
                          color: DataUI.chedrauiColor,
                          disabledColor: DataUI.chedrauiColorDisabled,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 15.0),
                            child: Text(
                              'Ingresar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          onPressed: () async {
                            if (!toLogin) {
                              setState(() {
                                toLogin = true;
                              });
                              var e = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  settings: RouteSettings(name: DataUI.loginRoute),
                                  builder: (BuildContext context) => LoginPage(
                                    route: DataUI.pagoServiciosRoute,
                                  ),
                                ),
                              );
                              setState(() {
                                toLogin = false;
                              });
                            } else {
                              print('open');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 15),
                  child: RichText(
                    text: TextSpan(
                      text: '¿Aún no tienes cuenta? ',
                      style: TextStyle(
                        fontFamily: "Rubik",
                        fontSize: 12,
                        color: HexColor("#637381"),
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          recognizer: new TapGestureRecognizer()
                            ..onTap = () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      settings: RouteSettings(name: DataUI.loginRoute),
                                      builder: (BuildContext context) => LoginPage(
                                        login: true,
                                      ),
                                    ),
                                  )
                                },
                          text: 'Registrate',
                          style: TextStyle(fontFamily: "Rubik", fontSize: 12, fontWeight: FontWeight.normal, color: HexColor("#0D47A1")),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
