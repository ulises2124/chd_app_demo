import 'dart:convert';

import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/Servicios/HistoryCard.dart';
import 'package:chd_app_demo/views/Servicios/ServicesList.dart';
import 'package:chd_app_demo/views/Servicios/ViewUtils.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PaymentHistory extends StatefulWidget {
  final String servicesUrl = "https://us-central1-chedraui-bill-pay.cloudfunctions.net/services";
  final email;
  PaymentHistory({
    Key key,
    this.email,
  }) : super(key: key);

  @override
  PaymentHistoryState createState() => PaymentHistoryState();
}

class PaymentHistoryState extends State<PaymentHistory> {
  List<HistoryCard> payments;
  List<HistoryCard> paymentsfilter;
  bool isLoading = true;

  String sort = 'alphabetical ascending';

  @override
  void initState() {
    payments = new List<HistoryCard>();
    getHistory(null, null);
    super.initState();
  }

  getHistory(sorting, order) async {
    setState(() {
      isLoading = true;
    });
    if (sorting != null && order != null) {
      try {
        http.Response result = await http.get('${widget.servicesUrl}/logs/history/${widget.email}?sort=$sorting&order=$order', headers: {"Content-Type": "application/json"});
        print('${widget.servicesUrl}/logs/history/${widget.email}?sort=$sorting&order=$order');
        if (result.statusCode == 200) {
          Map<String, dynamic> map = json.decode(result.body);
          List<dynamic> response = map["logs"];
          setState(() {
            payments = mapPayments(response);
          });
        } else {
          showErrorMessage(context, "Error al cargar historial", "Ha ocurrido al cargar el historial de pagos", true);
        }
      } catch (error) {
        print(error);
        showErrorMessage(context, "Error al cargar historial", "Ha ocurrido al cargar el historial de pagos", true);
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      try {
        http.Response result = await http.get('${widget.servicesUrl}/logs/history/${widget.email}', headers: {"Content-Type": "application/json"});
        print('${widget.servicesUrl}/logs/history/${widget.email}');
        if (result.statusCode == 200) {
          Map<String, dynamic> map = json.decode(result.body);
          List<dynamic> response = map["logs"];
          setState(() {
            payments = mapPayments(response);
          });
        } else {
          showErrorMessage(context, "Error al cargar historial", "Ha ocurrido al cargar el historial de pagos", true);
        }
      } catch (error) {
        print(error);
        showErrorMessage(context, "Error al cargar historial", "Ha ocurrido al cargar el historial de pagos", true);
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  downloadPDF(String logId) async {
    try {
      launch('${widget.servicesUrl}/logs/$logId/download');
    } catch (error) {
      print(error);
      showErrorMessage(context, "Error en PDF", "Ocurrio un problema al descargar el documento PDF", false);
    }
  }

  List<HistoryCard> mapPayments(List<dynamic> response) {
    return response
        .map(
          (log) => HistoryCard(
            logId: log["_id"].toString(),
            logo: getLogo(log["logo"].toString()),
            reference: log["referenciaDes"].toString(),
            description: log["servicio"].toString() == "CFE" ? "Comisión Federal de Electricidad" : log["servicio"].toString(),
            paymentDate: log["fechaLocal"].toString(),
            totalPaid: double.parse(log["monto"].toString()) + double.parse(log["comision"].toString()),
            downloadPDF: downloadPDF,
            categories: log['categorias'],
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      backgroundColor: DataUI.backgroundColor,
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
          'Historial de transacciones',
          style: DataUI.appbarTitleStyle,
        ),
      ),
      body: SingleChildScrollView(
        child: isLoading
            ? Center(
                child: Container(
                  margin: const EdgeInsets.all(50.0),
                  child: CircularProgressIndicator(value: null),
                ),
              )
            : Container(
                margin: const EdgeInsets.only(top: 10.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                            margin: EdgeInsets.only(right: 10, left: 20, top: 15),
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            width: (sort.length * 10).toDouble(),
                            height: 30,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.white),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(right: 7),
                                  child: FilterIcon(),
                                ),
                                Container(
                                  margin: EdgeInsets.only(right: 7),
                                  child: Text(
                                    'Ordenar:',
                                    style: TextStyle(color: HexColor('#212B36'), fontSize: 12, fontFamily: 'Archivo'),
                                  ),
                                ),
                                DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    elevation: 8,
                                    iconEnabledColor: Colors.transparent,
                                    style: TextStyle(color: HexColor('#212B36'), fontSize: 12, fontFamily: 'Archivo'),
                                    isDense: true,
                                    items: [
                                      DropdownMenuItem(
                                        value: "alphabetical ascending",
                                        child: Text(
                                          "Nombre asc (A-z)",
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: "alphabetical descending",
                                        child: Text(
                                          "Nombre desc (Z-a)",
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: "chronological ascending",
                                        child: Text(
                                          "Más reciente",
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: "chronological descending",
                                        child: Text(
                                          "Más antiguo",
                                        ),
                                      ),
                                    ],
                                    onChanged: (value) async {
                                      setState(() {
                                        sort = value;
                                      });
                                      var e = sort.split(' ');
                                      var sorting = e[0];
                                      var order = e[1];
                                      await getHistory(sorting, order);
                                    },
                                    value: sort,
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
                    Column(
                      children: payments,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
