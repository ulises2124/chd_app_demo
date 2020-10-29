import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:chd_app_demo/services/MonederoServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/MasterPage/MasterPage.dart';
import 'package:chd_app_demo/views/MasterPage/MenuScreen.dart';
import 'package:chd_app_demo/views/Servicios/CFEInformation.dart';
import 'package:chd_app_demo/views/Servicios/DefaultInformation.dart';
import 'package:chd_app_demo/views/Servicios/PaymentReceipt.dart';
import 'package:chd_app_demo/views/Servicios/ReferenceValidation.dart';
import 'package:chd_app_demo/views/Servicios/TelmexInformation.dart';
import 'package:chd_app_demo/views/Servicios/Util.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentInfo extends StatefulWidget {
  final String serviceName;
  final Widget serviceLogo;
  final String serviceSku;
  final String serviceSkuComision;
  final double saldoMonedero;
  final String userEmail;
  final bool isSavedService;
  final String savedReference;
  final String serviceID;
  PaymentInfo({
    Key key,
    this.serviceSku,
    this.serviceID,
    this.serviceSkuComision,
    this.serviceName,
    this.serviceLogo,
    this.saldoMonedero,
    this.userEmail,
    this.isSavedService = false,
    this.savedReference = "",
  }) : super(key: key);

  _PaymentInfoState createState() => _PaymentInfoState();
}

class _PaymentInfoState extends State<PaymentInfo> {
  final formatter = NumberFormat("###,###,###,##0.00");
  final _formKey = GlobalKey<FormState>();
  TextEditingController _referenceController = TextEditingController();
  TextEditingController _montoController = TextEditingController();
  TextEditingController _dvController = TextEditingController();
  String _message, _reference, _serviceStatus, _serviceTransaction, _paymentDate, _expirationDate;
  bool _isLoading2 = false;
  bool _isLoading = false, _sufficientFunds = false;
  int _serviceResponse = 0;
  Function _requestBalance = null, _payService = null;
  double _serviceBalance, _serviceCommission, _serviceTotal;
  String _referenceInfo, dv, _serviceTransactionNumber;
  String _monederoNumber;
  String servicesUrl = "https://us-central1-chedraui-bill-pay.cloudfunctions.net/services";

  @override
  void initState() {
    super.initState();
    _montoController.addListener(_updateBalance);
    _referenceController.text = widget.savedReference;
    getIdMonedero();
  }

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  void _updateBalance() {
    setState(() {
      _serviceBalance = double.parse(_montoController.text) ?? "";
      _serviceTotal = _serviceBalance + _serviceCommission;
    });
  }

  Future<void> scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => _referenceController.text = barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          _message = 'The user did not grant camera permission!';
        });
      } else {
        setState(() => _message = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => _message = 'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => _message = 'Unknown error: $e');
    }
  }

  launchAVP() async {
    const url = 'https://www.chedraui.com.mx/privacy';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showErrorMessage(context, "No se ha podido abrir el link. Intente de nuevo");
    }
  }

  Future<void> showErrorMessage(BuildContext context, String errorMessage) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error en pago del servicio'),
          content: Text(errorMessage),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<http.Response> executePayment(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime date = DateTime.now();
    var _headers = {
      "Content-Type": "application/json",
    };
    var _body = {
      "idPos": "1",
      "idCajero": "1",
      "sku": "${widget.serviceSku}",
      "skuComision": "${widget.serviceSkuComision}",
      "tipoPago": "MELE",
      "referencia": _referenceController.text,
      "monto": _serviceBalance,
      "comision": _serviceCommission,
      "email": widget.userEmail,
      "phone": prefs.getString("delivery-telefono"),
      "formaPago": 54, // Monedero
      "fechaPago": _paymentDate,
      "fechaVencimiento": _expirationDate,
      "dv": _dvController.text,
      "servicio": widget.serviceName,
      "transaccion": _serviceTransactionNumber,
      "numeroCuenta": _monederoNumber,
      "date": new DateFormat('yyyy-MM-ddTHH:mm:ss.000').format(date)
    };
    print(_body);

    String _servicesInfoUrl = 'https://us-central1-chedraui-bill-pay.cloudfunctions.net/services/payment/execute';
    return await http.post(_servicesInfoUrl, headers: _headers, body: utf8.encode(json.encode(_body)));
  }

  void _paymentReceipt(BuildContext context) async {
    try {
      setState(() {
        _isLoading2 = true;
      });
      http.Response response = await executePayment(context);
      List items = json.decode(response.body);
      final int statusCode = response.statusCode;
      if (statusCode == 200) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) => MasterPage(
              initialWidget: MenuItem(
                id: DataUI.tiendaRoute,
                title: '',
                screen: PaymentReceipt(
                  serviceID: widget.serviceID,
                  balance: double.parse(getValue(items, "MONTO") ?? "0.0"),
                  comision: double.parse(getValue(items, "COMISION") ?? "0.0"),
                  referencia: _referenceController.text,
                  autorizacion: getValue(items, "AUTORIZACION"),
                  serviceTransaction: _serviceTransaction,
                  paymentDate: _paymentDate ?? DateFormat.yMMMd().format(DateTime.now()),
                  expirationDate: _expirationDate,
                  serviceName: widget.serviceName,
                  userEmail: widget.userEmail,
                  isServiceFavorite: widget.isSavedService,
                ),
                color: DataUI.chedrauiColor2,
                textColor: DataUI.primaryText,
              ),
            ),
          ),
          (Route<dynamic> route) => false,
        );

        // Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(
        //         settings: RouteSettings(name: DataUI.reciboPagoServiciosRoute),
        //         builder: (context) => ));
      } else if (statusCode == 400 || json == null) {
        String message = errorMessageFromResponse(response.body);
        showErrorMessage(context, 'Ha ocurrido un problema al realizar el pago: $message');
      } else {
        String message = errorMessageFromResponse(response.body);
        showErrorMessage(context, 'Ha ocurrido un problema al realizar el pago: $message');
        throw new Exception("Error while fetching data");
      }
    } catch (error) {
      showErrorMessage(context, 'Ha ocurrido un problema al realizar el pago');
    } finally {
      setState(() {
        _isLoading2 = false;
      });
    }
  }

  getIdMonedero() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String idWallet = prefs.getString("idWallet");
    if (idWallet != null) {
      MonederoServices.getIdMonedero(idWallet).then((monedero) {
        _monederoNumber = monedero[0]["monedero"].toString();
      });
    }
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();
    DateTime date = DateTime.now();

    var _headers = {
      "Content-Type": "application/json",
    };
    var _body = {"idPos": "1", "idCajero": "1", "sku": "${widget.serviceSku}", "tipoPago": "MELE", "referencia": "${_referenceController.text}", "date": new DateFormat('yyyy-MM-ddTHH:mm:ss.000').format(date)};

    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      _formKey.currentState.save();
      try {
        String _servicesInfoUrl = 'https://us-central1-chedraui-bill-pay.cloudfunctions.net/services/payment/info';
        http.Response response = await http.post(_servicesInfoUrl, headers: _headers, body: utf8.encode(json.encode(_body)));

        final int statusCode = response.statusCode;
        print(response.body);
        if (statusCode == 200) {
          List _serviceData = json.decode(response.body);

          setState(() {
            _serviceResponse = 1;
            _isLoading = false;
            _referenceInfo = getValue(_serviceData, "REFERENCIA");
            _serviceBalance = double.parse(getValue(_serviceData, "MONTO"));
            _serviceCommission = double.parse(getValue(_serviceData, "COMISION"));
            _serviceTransactionNumber = getValue(_serviceData, "TRANSACCION");
            _montoController.text = _serviceBalance.toString();
            _serviceTotal = _serviceBalance + _serviceCommission;
            if (widget.saldoMonedero > _serviceTotal) {
              _sufficientFunds = true;
              _payService = () => _paymentReceipt(context);
            }
            if (widget.serviceName == "CFE") {
              _serviceStatus = titleCase(getValue(_serviceData, "ESTADO SERVICIO"));
              _serviceTransaction = getValue(_serviceData, "TRANSACCION CFE");
              _paymentDate = DateFormat.yMMMd().format(DateTime.parse(getValue(_serviceData, "FECHA PAGO")));
              _expirationDate = DateFormat.yMMMd().format(DateTime.parse(getValue(_serviceData, "FECHA VENCIMIENTO")));
            } else if (widget.serviceName == "Telmex") {
              dv = getValue(_serviceData, "DV");
            }
          });
        } else if (statusCode == 400) {
          String message = errorMessageFromResponse(response.body);
          showErrorMessage(context, 'Ha ocurrido un problema al realizar el pago: $message');
        } else {
          throw new Exception("Error while fetching data");
        }
      } catch (e) {
        print(e);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _serviceInformation() {
    switch (widget.serviceName) {
      case "CFE":
        return CFEInformation(balanceController: _montoController, serviceStatus: _serviceStatus ?? "");
      case "Telmex":
        return TelmexInformation(balanceController: _montoController, dvController: _dvController);
      default:
        return DefaultInformation(
          balanceController: _montoController,
        );
    }
  }

  terminos() async {
    const url = 'https://www.chedraui.com.mx/terminos-y-condiciones';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Flushbar(
        message: "Ha ocurrido un error, por favor intente de nuevo.",
        backgroundColor: HexColor('#39B54A'),
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.FLOATING,
        margin: EdgeInsets.all(8),
        borderRadius: 8,
        icon: Icon(
          Icons.check_circle_outline,
          size: 28.0,
          color: Colors.white,
        ),
        duration: Duration(seconds: 3),
      )..show(context);
    }
  }

  politica() async {
    const url = 'https://www.chedraui.com.mx/privacy';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Flushbar(
        message: "Ha ocurrido un error, por favor intente de nuevo.",
        backgroundColor: HexColor('#39B54A'),
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.FLOATING,
        margin: EdgeInsets.all(8),
        borderRadius: 8,
        icon: Icon(
          Icons.check_circle_outline,
          size: 28.0,
          color: Colors.white,
        ),
        duration: Duration(seconds: 3),
      )..show(context);
    }
  }

  Widget _toggleResponse() {
    if (_isLoading) {
      return Center(
        child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.white,
              boxShadow: [
                new BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5.0,
                ),
              ],
            ),
            margin: const EdgeInsets.all(30.0),
            child: Column(
              children: <Widget>[
                Center(
                  child: Padding(
                      padding: EdgeInsets.only(top: 25),
                      child: Text(
                        'Encontrar tu factura',
                        style: TextStyle(color: DataUI.chedrauiBlueColor, fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 18),
                      )),
                ),
                Image.asset('assets/loading1.gif'),
                Row(
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
              ],
            )),
      );
    } else if (_isLoading2) {
      return Center(
        child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.white,
              boxShadow: [
                new BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5.0,
                ),
              ],
            ),
            margin: const EdgeInsets.all(30.0),
            child: Column(
              children: <Widget>[
                Center(
                  child: Padding(
                      padding: EdgeInsets.only(top: 25),
                      child: Text(
                        'Procesando el pago',
                        style: TextStyle(color: DataUI.chedrauiBlueColor, fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 18),
                      )),
                ),
                Image.asset('assets/loading2.gif'),
                Row(
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
              ],
            )),
      );
    } else {
      switch (_serviceResponse) {
        case 1:
          return Column(
            children: <Widget>[
              _serviceInformation(),
              Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 15.0, left: 15, right: 15),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Detalle de pago',
                            style: TextStyle(
                              fontFamily: 'Archivo',
                              fontSize: 16.0,
                              color: DataUI.chedrauiBlueColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 5.0, left: 15, right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Balance del servicio',
                            style: TextStyle(
                              fontFamily: 'Archivo',
                              color: HexColor('#212B36'),
                              fontSize: 14.0,
                            ),
                          ),
                          Text(
                            '\$ ${formatter.format(_serviceBalance)}',
                            style: TextStyle(
                              fontFamily: 'Archivo',
                              color: HexColor('#212B36'),
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 5.0, left: 15, right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Comisión',
                            style: TextStyle(
                              fontFamily: 'Archivo',
                              color: HexColor('#212B36'),
                              fontSize: 14.0,
                            ),
                          ),
                          Text(
                            '\$ ${formatter.format(_serviceCommission)}',
                            style: TextStyle(
                              fontFamily: 'Archivo',
                              color: HexColor('#212B36'),
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20.0, left: 15, right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontFamily: 'Archivo',
                              color: HexColor('#212B36'),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$ ${formatter.format(_serviceTotal)}',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontFamily: 'Archivo',
                              color: HexColor('#212B36'),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: DataUI.chedrauiBlueColor,
                      ),
                      margin: const EdgeInsets.only(bottom: 20.0),
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: _sufficientFunds
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      child: Text(
                                        'Pagar',
                                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, fontFamily: 'Archivo', color: Colors.white),
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        '\$ ${formatter.format(_serviceTotal)}',
                                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, fontFamily: 'Archivo', color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        'Pagar',
                                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, fontFamily: 'Archivo', color: Colors.white),
                                      ),
                                      Text(
                                        '\$ ${formatter.format(_serviceTotal)}',
                                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, fontFamily: 'Archivo', color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                    !_sufficientFunds
                        ? Container(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.only(bottom: 15.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        margin: const EdgeInsets.only(right: 6.0),
                                        child: Icon(
                                          Icons.highlight_off,
                                          color: Colors.redAccent,
                                          size: 12.0,
                                        ),
                                      ),
                                      Text(
                                        'Saldo insuficiente, porfavor recargue su monedero.',
                                        style: TextStyle(fontSize: 12.0, color: Colors.redAccent, fontFamily: 'Archivo'),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.all(15),
                                  child: OutlineButton(
                                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                    padding: EdgeInsets.all(15),
                                    borderSide: BorderSide(
                                      color: DataUI.chedrauiBlueColor,
                                      style: BorderStyle.solid, //Style of the border
                                      width: 2.0, //width of the border
                                    ),
                                    child: Text(
                                      'Recarga tu Monedero en el Wallet',
                                      style: TextStyle(color: DataUI.chedrauiBlueColor, fontSize: 14.0),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
                                      Navigator.pushNamed(context, DataUI.monederoRoute);
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //     builder: (context) => MonederoPage(),
                                      //     ),
                                      // );
                                      // Navigator.of(context)
                                      //     .pushAndRemoveUntil(
                                      //   MaterialPageRoute(
                                      //     builder: (BuildContext context) =>
                                      //         MasterPage(
                                      //           initialWidget: MenuItem(
                                      //             id: 'monedero',
                                      //             title: 'Mi Monedero',
                                      //             screen: MonederoPage(),
                                      //             color: DataUI.chedrauiColor2,
                                      //             textColor: DataUI.primaryText,
                                      //           ),
                                      //         ),
                                      //   ),
                                      //   (Route<dynamic> route) => false,
                                      // );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SizedBox(),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(
                            flex: 6,
                            child: RaisedButton(
                              color: DataUI.chedrauiColor,
                              disabledColor: DataUI.chedrauiColorDisabled,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 15.0),
                                child: Text(
                                  'Pagar con saldo de monedero',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              onPressed: _sufficientFunds ? _payService : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: FlatButton(
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: DataUI.chedrauiBlueColor,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        default:
          return Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.only(bottom: 10.0, top: 6.5),
                          child: Text(
                            'Número de referencia',
                            style: TextStyle(
                              fontFamily: 'Archivo',
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                        Container(
                          height: 20.0,
                          child: IconButton(
                            iconSize: 12.0,
                            alignment: Alignment.centerLeft,
                            icon: Icon(
                              Icons.info_outline,
                              color: Color.fromRGBO(57, 62, 67, 0.75),
                            ),
                            onPressed: () {
                              return showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                                    backgroundColor: Color.fromRGBO(50, 50, 50, 1),
                                    content: Text(
                                      'Identifica tu número de referencia. Lo puedes encontrar junto al código de barras de tu recibo.',
                                      softWrap: true,
                                      style: TextStyle(color: Colors.white, fontSize: 14.0),
                                      textAlign: TextAlign.justify,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 15.0),
                    child: Form(
                      key: _formKey,
                      child: Theme(
                        data: ThemeData(
                          primaryColor: Colors.transparent,
                          hintColor: Colors.transparent,
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.only(bottom: 10.0),
                              child: TextFormField(
                                keyboardType: TextInputType.phone,
                                controller: _referenceController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: HexColor('#F0EFF4'),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                                  hintStyle: TextStyle(color: HexColor('#0D47A1'), fontSize: 12),
                                  suffixIcon: IconButton(
                                    icon: ScanSVG(),
                                    onPressed: () => scan(),
                                  ),
                                ),
                                validator: validateReferenceCfe,
                                onSaved: (input) => _reference = input,
                                textInputAction: TextInputAction.done,
                                inputFormatters: [
                                  WhitelistingTextInputFormatter(
                                    RegExp("[0-9]"),
                                  ),
                                  LengthLimitingTextInputFormatter(30),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(children: <Widget>[
                    Expanded(
                      flex: 6,
                      child: FlatButton(
                        color: DataUI.chedrauiColor,
                        disabledColor: DataUI.chedrauiColorDisabled,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(14),
                          child: Text(
                            'Solicitar Balance',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        onPressed: _submitForm,
                      ),
                    ),
                  ]),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Al buscar su cuenta, acepto los',
                            style: TextStyle(
                              fontFamily: 'Archivo',
                              fontSize: 10,
                              color: HexColor('#212B36'),
                            ),
                          ),
                          TextSpan(
                            recognizer: new TapGestureRecognizer()..onTap = () => {terminos()},
                            text: ' Términos y condiciones ',
                            style: TextStyle(
                              fontFamily: 'Archivo',
                              fontSize: 10,
                              color: DataUI.chedrauiBlueColor,
                            ),
                          ),
                          TextSpan(
                            text: 'del servicio ofrecido por la aplicación, así como su ',
                            style: TextStyle(
                              fontFamily: 'Archivo',
                              fontSize: 10,
                              color: HexColor('#212B36'),
                            ),
                          ),
                          TextSpan(
                            recognizer: new TapGestureRecognizer()..onTap = () => {politica()},
                            text: 'Aviso de privacidad.',
                            style: TextStyle(
                              fontFamily: 'Archivo',
                              fontSize: 10,
                              color: DataUI.chedrauiBlueColor,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              )
              //   child: Row(
              //     mainAxisSize: MainAxisSize.max,
              //     children: <Widget>[
              //       Expanded(
              //         flex: 6,
              //         child: RaisedButton(
              //           color: DataUI.chedrauiColor,
              //           disabledColor: DataUI.chedrauiColorDisabled,
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(6.0),
              //           ),
              //           child: Container(
              //             margin: const EdgeInsets.all(14),
              //             child: Text(
              //               'Solicitar Balance',
              //               style: TextStyle(
              //                 color: Colors.white,
              //                 fontSize: 16,
              //               ),
              //             ),
              //           ),
              //           onPressed: _requestBalance,
              //         ),
              //       ),
              //       Text(
              //         "Prueba"
              //       )
              //     ],
              //   ),
              );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
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
          '${widget.serviceName}',
          style: DataUI.appbarTitleStyle,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          // margin: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 40.0, bottom: 30.0, left: 15, right: 15),
                height: 90.0,
                child: widget.serviceLogo,
              ),
              _toggleResponse(),
            ],
          ),
        ),
      ),
    );
  }
}
