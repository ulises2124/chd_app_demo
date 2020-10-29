import 'dart:convert';

import 'package:chd_app_demo/services/MonederoServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/utils/input_formatters.dart';
import 'package:chd_app_demo/views/HomePage/DeliveryMethodSelectionBar.dart';
import 'package:chd_app_demo/views/MasterPage/MasterPage.dart';
import 'package:chd_app_demo/views/MasterPage/MenuScreen.dart';
import 'package:chd_app_demo/views/Servicios/ServiciosPage.dart';
import 'package:chd_app_demo/views/Servicios/Util.dart';
import 'package:chd_app_demo/views/Servicios/ViewUtils.dart';
import 'package:chd_app_demo/widgets/modalbottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentReceipt extends StatefulWidget {
  final Widget logo;
  final double balance;
  final double comision;
  final String serviceID;
  final String referencia;
  final String autorizacion;
  final String serviceTransaction;
  final String paymentDate;
  final String expirationDate;
  final String serviceName;
  final String userEmail;
  final String servicesUrl = "https://us-central1-chedraui-bill-pay.cloudfunctions.net/services";
  final bool isServiceFavorite;
  final String logID;
  const PaymentReceipt({
    Key key,
    this.balance,
    this.logo,
    this.serviceID,
    this.comision,
    this.referencia,
    this.autorizacion,
    this.serviceTransaction,
    this.paymentDate,
    this.expirationDate,
    this.serviceName,
    this.userEmail,
    this.isServiceFavorite,
    this.logID,
  }) : super(key: key);

  PaymentReceiptState createState() => PaymentReceiptState();
}

class PaymentReceiptState extends State<PaymentReceipt> {
  bool isFormDisplayed = false;
  TextEditingController aliasController;
  String saveText = "Guardar servicio";
  bool serviceSaved = false;

  bool open = false;
  var _monederoNumber;
  double saldoMonedero;
  NumberFormat moneda = new NumberFormat.currency(locale: 'es_MX', symbol: "\$");

  String saveServiceName;

  final _formKey = GlobalKey<FormState>();

  var selected = 'mensual';

  bool loading = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    aliasController = new TextEditingController();
    getIdMonedero();
  }

  getIdMonedero() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String idWallet = prefs.getString("idWallet");
    if (idWallet != null) {
      MonederoServices.getIdMonedero(idWallet).then((monedero) async {
        _monederoNumber = monedero[0]["monedero"].toString();
        /*
        var resultadoMonedero = await MonederoServices.getSaldoMonedero(_monederoNumber);
        if (resultadoMonedero != null && resultadoMonedero['resultado'] != null && resultadoMonedero['resultado']['saldo'] != null) {
          setState(() {
            monedero = true;
            saldoMonedero = resultadoMonedero['resultado']['saldo'];
          });
        }
        */
        try {
          var saldoResult = await MonederoServices.getSaldoMonederoRCS(_monederoNumber);
          if (saldoResult != null && saldoResult["CodigoRes"] == "200" && saldoResult["DatosRCS"] != null) {
            setState(() {
              monedero = true;
              saldoMonedero = double.parse(saldoResult["DatosRCS"]["Monto"]);
              prefs.setDouble('saldoMonedero', saldoMonedero);
            });
          } else {
            throw new Exception("Not a valid object");
          }
        } catch (e) {
          print(e);
        }
      });
    }
  }

  Future<Null> updated(StateSetter updateState, value) async {
    updateState(() {
      selected = value;
    });
  }

  Future<Null> updateLoader(StateSetter updateState, value) async {
    updateState(() {
      loading = value;
    });
  }

  void saveService(context) {
    showModalBottomSheetApp(
      dismissOnTap: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, state) {
            return Theme(
              data: ThemeData(canvasColor: Colors.transparent),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  print('object');
                },
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Color(0xcc000000).withOpacity(0.2),
                        offset: Offset(5.0, 0.0),
                        blurRadius: 12.0,
                      ),
                    ],
                    color: HexColor('#F9FAFB'),
                    borderRadius: new BorderRadius.only(topLeft: const Radius.circular(20.0), topRight: const Radius.circular(20.0)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
                    child: Container(
                      height: 550,
                      padding: EdgeInsets.only(
                        top: 15,
                      ),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 25),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Agregar a mis servicios',
                                  style: TextStyle(fontSize: 20, color: HexColor('#0D47A1'), fontFamily: 'Archivo', letterSpacing: 0.5, fontWeight: FontWeight.bold),
                                ),
                                // IconButton(
                                //   icon: Icon(Icons.close),
                                //   onPressed: () {
                                //     Navigator.pop(context);
                                //   },
                                // )
                              ],
                            ),
                          ),
                          Container(
                            height: 1,
                            color: HexColor('#D8D8D8'),
                            margin: EdgeInsets.only(top: 9),
                          ),
                          Center(
                            child: widget.logo,
                          ),
                          Container(height: 1, color: HexColor('#D8D8D8')),
                          Container(
                            margin: EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Número de referencia',
                                  style: TextStyle(fontFamily: 'Archivo', fontSize: 14, color: HexColor('#212B36')),
                                ),
                                Text(
                                  truncateString(15, widget.referencia),
                                  style: TextStyle(fontFamily: 'Archivo', fontSize: 14, color: HexColor('#212B36')),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 15, right: 15),
                            child: Form(
                              key: _formKey,
                              child: Theme(
                                data: ThemeData(
                                  primaryColor: Colors.transparent,
                                  hintColor: Colors.transparent,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          'Agregar alias (opcional) ',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(fontSize: 12, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                                        ),
                                      ),
                                      TextFormField(
                                        controller: aliasController,
                                        style: TextStyle(color: HexColor('#0D47A1'), fontSize: 14, fontFamily: 'Archivo'),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: HexColor('#F0EFF4'),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                                          hintStyle: TextStyle(color: HexColor('#0D47A1'), fontSize: 12),
                                        ),
                                        onFieldSubmitted: (v) {
                                          saveServiceName = v;
                                        },
                                        textInputAction: TextInputAction.next,
                                        inputFormatters: [
                                          WhitelistingTextInputFormatter(FormsTextFormatters.regexNames()),
                                        ],
                                        maxLength: 25,
                                        onSaved: (input) {
                                          saveServiceName = input;
                                        },
                                        validator: FormsTextValidators.validateTextWithoutEmoji,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(15, 0, 15, 15),
                            child: Text(
                              '¿Deseas que te recordemos tu próximo pago?',
                              textAlign: TextAlign.left,
                              style: TextStyle(fontSize: 12, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                            ),
                          ),
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Stack(
                                    overflow: Overflow.visible,
                                    children: <Widget>[
                                      selected == 'mensual'
                                          ? Positioned(
                                              top: -15,
                                              right: -13,
                                              child: Icon(
                                                Icons.check_circle,
                                                color: HexColor('#39B54A'),
                                              ),
                                            )
                                          : SizedBox(),
                                      OutlineButton(
                                        onPressed: () {
                                          if (selected != 'mensual') {
                                            updated(state, 'mensual');
                                          } else {
                                            updated(state, null);
                                          }
                                        },
                                        padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                        child: Column(
                                          children: <Widget>[Text("Al final de"), Text('cada mes')],
                                        ),
                                        borderSide: BorderSide(color: selected == 'mensual' ? HexColor('#39B54A') : HexColor('#DFE3E8')),
                                        shape: new RoundedRectangleBorder(
                                          borderRadius: new BorderRadius.circular(5.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Stack(
                                    overflow: Overflow.visible,
                                    children: <Widget>[
                                      selected == 'quincenal'
                                          ? Positioned(
                                              top: -15,
                                              right: -13,
                                              child: Icon(
                                                Icons.check_circle,
                                                color: HexColor('#39B54A'),
                                              ),
                                            )
                                          : SizedBox(),
                                      OutlineButton(
                                        onPressed: () {
                                          if (selected != 'quincenal') {
                                            updated(state, 'quincenal');
                                          } else {
                                            updated(state, null);
                                          }
                                        },
                                        padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                        child: Column(
                                          children: <Widget>[Text("El 15 de"), Text('cada mes')],
                                        ),
                                        borderSide: BorderSide(color: selected == 'quincenal' ? HexColor('#39B54A') : HexColor('#DFE3E8')),
                                        shape: new RoundedRectangleBorder(
                                          borderRadius: new BorderRadius.circular(5.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 15, right: 15, top: 20),
                            width: double.infinity,
                            child: FlatButton(
                              color: DataUI.chedrauiColor,
                              disabledColor: DataUI.chedrauiColorDisabled,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 15.0),
                                child: Text(
                                  'Agregar',
                                  style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Archivo'),
                                ),
                              ),
                              onPressed: () async {
                                updateLoader(state, true);
                                try {
                                  var body = {
                                    "reference": widget.referencia,
                                    "alias": aliasController.text.length > 0 ? aliasController.text : " ",
                                    "serviceKenticoId": widget.serviceID,
                                    "reminderFrequency": selected,
                                  };
                                  print('${widget.servicesUrl}/user/${widget.userEmail}/services');
                                  http.Response result = await http.post('${widget.servicesUrl}/user/${widget.userEmail}/services', headers: {"Content-Type": "application/json"}, body: utf8.encode(json.encode(body)));
                                  if (result.statusCode == 201) {
                                    showErrorMessage(context, "Servicio Guardado", "Servicio guardado exitosamente", true);
                                  } else {
                                    showErrorMessage(context, "Error al guardar", "Ha ocurrido un error al intentar guardar el servicio", false);
                                  }
                                } catch (error) {
                                  print(error);
                                  showErrorMessage(context, "Error al guardar", "Ha ocurrido un error al intentar guardar el servicio", false);
                                } finally {
                                  updateLoader(state, false);
                                }
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                            width: double.infinity,
                            child: loading
                                ? Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 5),
                                          child: LinearProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation(HexColor('#FBC02D')),
                                            backgroundColor: HexColor('#CFCED5'),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : FlatButton(
                                    color: Colors.transparent,
                                    disabledColor: DataUI.chedrauiColorDisabled,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 15.0),
                                      child: Text(
                                        'Cancelar',
                                        style: TextStyle(color: HexColor('#0D47A1'), fontSize: 14, fontFamily: 'Archivo'),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      backgroundColor: HexColor('#F4F6F8'),
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.transparent,
              ),
              onPressed: () => null,
            );
          },
        ),
        backgroundColor: HexColor('#F4F6F8'),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (BuildContext context) => MasterPage(
                    initialWidget: MenuItem(
                      id: DataUI.pagoServiciosRoute,
                      title: 'Pago de servicios',
                      screen: PagoServicios(),
                      color: DataUI.chedrauiColor2,
                    ),
                  ),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
        // gradient: LinearGradient(
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        //   colors: [
        //     HexColor('#F56D00'),
        //     HexColor('#F56D00'),
        //     HexColor('#F78E00'),
        //   ],
        // ),
        // title: Text(
        //   'Confirmación',
        //   style: DataUI.appbarTitleStyle,
        // ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                //color: Colors.white,
                padding: const EdgeInsets.only(left: 15.0, right: 15, top: 30, bottom: 24),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Center(
                            child: Image.asset(
                              'assets/checkGreen.png',
                              width: 60,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 0, top: 12),
                            child: Text(
                              'Pago exitoso',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: HexColor('#0D47A1'), fontFamily: 'Archivo Black', fontWeight: FontWeight.normal, fontSize: 24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Text(
                  'Tu pago ha sido procesado correctamente',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: HexColor('#444444'), fontFamily: 'Archivo', fontWeight: FontWeight.bold),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(),
              //   child: Text(
              //     'procesado correctamente',
              //     textAlign: TextAlign.center,
              //     style: TextStyle(fontSize: 20, color: HexColor('#444444'), fontFamily: 'Archivo', fontWeight: FontWeight.bold),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5, top: 10),
                child: Text(
                  'Hemos enviado una copia del comprobante a tu correo electrónico con los detalles de esta transacción',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: HexColor('#212B36'),
                    fontFamily: 'Rubik',
                    letterSpacing: 0.25,
                  ),
                ),
              ),
              // !widget.isServiceFavorite
              //     ? serviceSaved
              //         ? Container(
              //             margin: const EdgeInsets.only(top: 20.0, bottom: 20.0),
              //             child: Text(
              //               "Servicio guardado",
              //               textAlign: TextAlign.left,
              //               style: TextStyle(
              //                 fontFamily: 'Archivo',
              //                 fontSize: 16,
              //                 letterSpacing: 0.25,
              //                 color: HexColor('#0D47A1'),
              //               ),
              //             ),
              //           )
              //         : Center(
              //             child: SaveWithAlias(
              //             isFormDisplayed: isFormDisplayed,
              //             aliasController: aliasController,
              //             onDisplayForm: () {
              //               setState(() {
              //                 isFormDisplayed = !isFormDisplayed;
              //               });
              //             },
              //             onSaveService: () {
              //               setState(() {
              //                 isFormDisplayed = !isFormDisplayed;
              //               });
              //               saveService(context);
              //             },
              //           ))
              //     : Container(),
              Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.0), color: Colors.white),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Text(
                  'Referencia: ${truncateString(15, widget.referencia)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: HexColor('#0D47A1'), fontFamily: 'Archivo', fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    open = !open;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(15),
                  //height: 78,
                  color: HexColor('F4F6F8'),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(bottom: 6.0, left: 15, right: 15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              child: Text(
                                'Detalles de la transacción',
                                style: TextStyle(fontSize: 14.0, color: HexColor('#454F5B'), fontFamily: 'Rubik'),
                              ),
                            ),
                            RotatedBox(
                                quarterTurns: !open ? 1 : 3,
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: HexColor('#0D47A1'),
                                  size: 15,
                                ))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(height: 1, color: HexColor('#D8D8D8')),
              AnimatedContainer(
                duration: new Duration(milliseconds: 300),
                height: !open ? 0 : 170,
                color: HexColor('#F4F6F8'),
                padding: const EdgeInsets.fromLTRB(15.0, 25.0, 15.0, 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      // margin: const EdgeInsets.only(bottom: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Fecha Pago  ',
                            style: TextStyle(
                              color: HexColor('#454F5B'),
                              fontSize: 14,
                              fontFamily: 'Rubik',
                            ),
                          ),
                          _obtenerFecha()
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5, bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Transaccion ${widget.serviceName}',
                            style: TextStyle(
                              color: HexColor('#454F5B'),
                              fontSize: 14,
                              fontFamily: 'Rubik',
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              ' ${widget.serviceTransaction}',
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                color: HexColor('#212B36'),
                                fontSize: 14,
                                fontFamily: 'Rubik',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Detalle de pago',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: HexColor('#0D47A1'), letterSpacing: 0.44, fontFamily: 'Archivo Bold'),
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '${widget.serviceName}',
                            style: TextStyle(
                              color: HexColor('#212B36'),
                              fontSize: 14,
                              letterSpacing: 0.25,
                              fontFamily: 'Archivo',
                            ),
                          ),
                          Text(
                            '${moneda.format(widget.balance)}',
                            style: TextStyle(
                              color: HexColor('#212B36'),
                              fontSize: 14,
                              letterSpacing: 0.25,
                              fontFamily: 'Archivo',
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Comisión',
                            style: TextStyle(
                              color: HexColor('#212B36'),
                              fontSize: 14,
                              letterSpacing: 0.25,
                              fontFamily: 'Archivo',
                            ),
                          ),
                          Text(
                            '${moneda.format(widget.comision)}',
                            style: TextStyle(
                              color: HexColor('#212B36'),
                              fontSize: 14,
                              letterSpacing: 0.25,
                              fontFamily: 'Archivo',
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 65,
                padding: EdgeInsets.symmetric(horizontal: 15),
                color: DataUI.chedrauiBlueColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Total pagado',
                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, fontFamily: 'Archivo', color: Colors.white),
                    ),
                    Text(
                      '${moneda.format(widget.balance + widget.comision)}',
                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, fontFamily: 'Archivo', color: Colors.white),
                    )
                  ],
                ),
              ),
              saldoMonedero != null && _monederoNumber != null
                  ? Container(
                      height: 50,
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.circular(5.0),
                      //   color: Colors.white,
                      //   boxShadow: <BoxShadow>[
                      //     BoxShadow(
                      //       color: Color(0xcc000000).withOpacity(0.2),
                      //       offset: Offset(5.0, 5.0),
                      //       blurRadius: 5.0,
                      //     ),
                      //   ],
                      // ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(right: 5),
                                height: 40.0,
                                width: 40.0,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/card.png'),
                                    fit: BoxFit.fitWidth,
                                  ),
                                  // shape: BoxShape.circle,
                                ),
                              ),
                              Text(
                                _monederoNumber != null ? '**** ' + _monederoNumber.substring(12, 16) : ' ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: HexColor('#212B36'),
                                  fontFamily: 'Archivo',
                                  letterSpacing: 0.25,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Saldo actual: ${moneda.format(saldoMonedero)}",
                            style: TextStyle(
                              fontSize: 14,
                              color: HexColor('#212B36'),
                              fontFamily: 'Archivo',
                              letterSpacing: 0.25,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(),
              Container(
                margin: EdgeInsets.only(left: 15, right: 15, top: 20),
                width: double.infinity,
                child: FlatButton(
                  color: Colors.transparent,
                  disabledColor: DataUI.chedrauiColorDisabled,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Agregar a mis servicios',
                          style: TextStyle(color: HexColor('#0D47A1'), fontSize: 14, fontFamily: 'Archivo'),
                        ),
                        Icon(
                          Icons.add,
                          color: HexColor('#F56D11'),
                        )
                      ],
                    ),
                  ),
                  onPressed: () => saveService(context),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                width: double.infinity,
                child: FlatButton(
                  color: Colors.transparent,
                  disabledColor: DataUI.chedrauiColorDisabled,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Descargar PDF',
                          style: TextStyle(color: HexColor('#0D47A1'), fontSize: 14, fontFamily: 'Archivo'),
                        ),
                        Icon(
                          Icons.file_download,
                          color: HexColor('#F56D11'),
                        )
                      ],
                    ),
                  ),
                  onPressed: () {
                    try {
                      launch('${widget.servicesUrl}/logs/${widget.logID}/download');
                    } catch (error) {
                      print(error);
                      showErrorMessage(context, "Error en PDF", "Ocurrio un problema al descargar el documento PDF", false);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _obtenerFecha() {
    DateTime now = new DateTime.now();
    DateFormat formatter = new DateFormat.yMMMMd('ES');

    String paymentDate = formatter.format(now);
    print(paymentDate);

    return Container(
      child: Text(
        paymentDate,
        style: TextStyle(
          color: HexColor('#454F5B'),
          fontSize: 14,
          fontFamily: 'Rubik',
        ),
      ),
    );
  }
}
