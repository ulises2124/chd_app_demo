import 'dart:async';
import 'dart:convert';

import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/HomePage/BalanceMonederoBar.dart';
import 'package:chd_app_demo/views/HomePage/DeliveryMethodSelectionBar.dart';
import 'package:chd_app_demo/views/Servicios/MyServices.dart';
import 'package:chd_app_demo/views/Servicios/PaymentHistory.dart';
import 'package:chd_app_demo/views/Servicios/ServiceActionButtons.dart';
import 'package:chd_app_demo/views/Servicios/ServiceCards.dart';
import 'package:chd_app_demo/views/Servicios/ServiceCarousel.dart';
import 'package:chd_app_demo/views/Servicios/Util.dart';
import 'package:chd_app_demo/views/Servicios/ViewUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sticky_headers/sticky_headers/widget.dart';

class ServiciosAvailable extends StatefulWidget {
  final String servicesUrl = "https://us-central1-chedraui-bill-pay.cloudfunctions.net/services";

  ServiciosAvailable({Key key}) : super(key: key);

  @override
  _ServiciosAvailableState createState() => _ServiciosAvailableState();
}

class _ServiciosAvailableState extends State<ServiciosAvailable> {
  final formatter = NumberFormat("###,###,###,##0.00");
  SharedPreferences prefs;
  bool _isLoggedIn = false;
  bool hasFavServices = false;
  double saldoMonedero = 0;
  String selected = 'Todos';
  String email;
  bool isLoading = true;
  List<ServiceCard> services = new List<ServiceCard>();
  List<ServiceCard> favServices = new List<ServiceCard>();
  List categories = [];

  List<ServiceCard> servicesAll;
  @override
  void initState() {
    if (mounted) {
      getPreferences().then((x) {
        setState(() {
          saldoMonedero = prefs.getDouble('saldoMonedero') ?? 0.0;
          _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
          email = prefs.getString('email');
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

  Future getServices() async {
    try {
      setLoading(true);
      http.Response result = await http.get('https://deliver.kenticocloud.com/a38e9287-f45b-00de-6ce8-23adabd3c0e5/items?system.type=servicios', headers: {"Content-Type": "application/json"});
      if (result.statusCode == 200) {
        Map<String, dynamic> map = json.decode(result.body);
        List<dynamic> response = map["items"];
        categories.add('Todos');
        response.forEach((f) {
          for (var e in f['elements']['informacion_general_de_servicios__categoria']['value']) {
            categories.add(
              e['name'],
            );
          }
        });

        categories = categories.toSet().toList();
        setState(() {
          services = mapServices(response, saldoMonedero, email);
          servicesAll = mapServices(response, saldoMonedero, email);
        });
      }
    } catch (error) {
      print(error);
      showErrorMessage(context, "Error en servicios", "Ocurrio un error al obtener la lista de servicios", false);
    } finally {
      setLoading(false);
    }
  }

  goToMyServices() {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: DataUI.misServiciosRoute),
        builder: (BuildContext context) => MyServices(
          saldoMonedero: saldoMonedero,
          email: email,
        ),
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
    return Scaffold(
      backgroundColor: HexColor('#F4F6F8'),
      appBar: GradientAppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            );
          },
        ),
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
          'Servicios disponibles',
          style: DataUI.appbarTitleStyle,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Container(
            child: Column(
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
                          Container(
                            margin: EdgeInsets.all(15),
                            height: 40,
                            width: MediaQuery.of(context).size.width,
                            child: ListView.builder(
                                physics: ClampingScrollPhysics(),
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  return Row(
                                    children: <Widget>[
                                      categories[index] != null
                                          ? Container(
                                              margin: EdgeInsets.only(left: 5.0, right: 5.0),
                                              child: InputChip(
                                                clipBehavior: Clip.none,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                                                backgroundColor: selected == categories[index] ? HexColor("#0D47A1") : HexColor("#0d47a1").withOpacity(0.1),
                                                onPressed: () {
                                                  setState(() {
                                                    selected = categories[index];
                                                    if (categories[index] == 'Todos') {
                                                      services = servicesAll;
                                                    } else {
                                                      services = getServicesByCategory(servicesAll, categories[index]);
                                                      print(services);
                                                    }
                                                  });
                                                },
                                                label: Text(
                                                  categories[index].toString(),
                                                  style: TextStyle(color: selected == categories[index] ? HexColor("#FFFFFF") : HexColor("#0D47A1"), fontFamily: "Archivo", fontWeight: FontWeight.bold, fontSize: 16),
                                                ),
                                              ),
                                            )
                                          : Container()
                                    ],
                                  );
                                }),

                            // return ServiceCarousel(title: categories[index], services: getServicesByCategory(services, categories[index]));
                          ),
                          // Container(
                          //                         margin: EdgeInsets.only(top: 15, bottom: 15),
                          //                         child: Center(
                          //                           child: Text(
                          //                             'Aquí encontrarás los servicios que has guardado como frecuentes',
                          //                             textAlign: TextAlign.center,
                          //                             style: TextStyle(color: HexColor('#454F5B'), fontFamily: 'Archivo', fontSize: 14, letterSpacing: 0.25),
                          //                           ),
                          //                         ),
                          //                       ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 15),
                            width: MediaQuery.of(context).size.width,
                            // height: 110,
                            child: ListView.builder(
                                physics: ClampingScrollPhysics(),
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: services.length,
                                itemBuilder: (context, index) {
                                  return ServiceCardAvailable(
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
        ),
      ),
    );
  }
}
