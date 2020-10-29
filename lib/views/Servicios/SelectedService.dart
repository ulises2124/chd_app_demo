import 'dart:convert';
import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:chd_app_demo/services/MonederoServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/MasterPage/MasterPage.dart';
import 'package:chd_app_demo/views/MasterPage/MenuScreen.dart';
import 'package:chd_app_demo/views/Monedero/MonederoDetails.dart';
import 'package:chd_app_demo/views/Servicios/CFEInformation.dart';
import 'package:chd_app_demo/views/Servicios/DefaultInformation.dart';
import 'package:chd_app_demo/views/Servicios/KenticoServices.dart';
import 'package:chd_app_demo/views/Servicios/KenticoToolTip.dart';
import 'package:chd_app_demo/views/Servicios/PaymentReceipt.dart';
import 'package:chd_app_demo/views/Servicios/ReferenceValidation.dart';
import 'package:chd_app_demo/views/Servicios/TelmexInformation.dart';
import 'package:chd_app_demo/views/Servicios/Util.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chd_app_demo/utils/input_formatters.dart';

class SelectedService extends StatefulWidget {
  final String serviceName;
  final Widget serviceLogo;
  final String serviceSku;
  final String serviceSkuComision;
  final double saldoMonedero;
  final String userEmail;
  final bool isSavedService;
  final String savedReference;
  final String serviceID;
  final dynamic telefonia;
  final String messageToUser;
  final String toolTipDescription;
  Widget toolTip;
  String tipoPago;
  String status;
  String montoMinimo;
  String montoMaximo;
  SelectedService({
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
    this.telefonia,
    this.messageToUser,
    this.toolTip,
    this.toolTipDescription,
    this.tipoPago,
    this.status,
    this.montoMaximo,
    this.montoMinimo,
  }) : super(key: key);

  _SelectedServiceState createState() => _SelectedServiceState();
}

class _SelectedServiceState extends State<SelectedService> {
  final formatter = NumberFormat("###,###,###,##0.00");
  final _formKey = GlobalKey<FormState>();
  final formMonto = GlobalKey<FormState>();
  TextEditingController _referenceController = TextEditingController();
  MoneyMaskedTextController _montoController = MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',', leftSymbol: '\$');
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

  String status = 'Pago de servicios';

  double saldo;

  bool statusok = false;

  NumberFormat moneda = new NumberFormat.currency(locale: 'es_MX', symbol: "\$");

  var selectedRadioTile;

  bool _serviceBalanceBool = true;

  var selectedRadioTelefonia;

  var titleError;
  var bodyError;
  var title;
  var body;
  bool _hasCameraAccess;
  PermissionStatus _permissionsStatus;
  double _originalSaldo;

  bool btnStatus = true;
  String btnStatusString = 'Confirmar';
  double montoMaximo;
  double montoMinimo;
  bool acceptedTyC = false;

  String name = '';

  Widget monederoWidget;
  @override
  void initState() {
    super.initState();
    //_montoController.addListener(_updateBalance);
    setState(() {
      saldo = widget.saldoMonedero;
      _referenceController.text = widget.savedReference;
      if (_referenceController.text.length > 0) {
        statusok = true;
      }
      if (widget.montoMinimo != 'null' && widget.montoMinimo != null) montoMinimo = double.parse(widget.montoMinimo) ?? null;
      if (widget.montoMaximo != 'null' && widget.montoMaximo != null) montoMaximo = double.parse(widget.montoMaximo) ?? null;
    });

    getSaldo();
    _referenceController.addListener(_printLatestValue);
    print(widget.messageToUser);
    KenticoServices.getMessageErrorPDS().then((onValue) {
      titleError = onValue['title'];
      bodyError = onValue['body'];
    });
    KenticoServices.getMessageSuccessPDS().then((onValue) {
      title = onValue['title'];
      body = onValue['body'];
    });
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  _printLatestValue() async {
    var result = validateReferenceCfe(_referenceController.text);
    if (result == null) {
      setState(() {
        statusok = true;
      });
    } else {
      setState(() {
        statusok = false;
      });
    }
  }

  void _updateBalance() {
    setState(() {
      monederoWidget = CircularProgressIndicator();
    });
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      //_montoController.text = moneda.format(double.parse(_montoController.text));
      _serviceBalance = _montoController.numberValue ?? "";
      _serviceTotal = _serviceBalance + _serviceCommission;
      if (saldo > _serviceTotal) {
        _sufficientFunds = true;
        _payService = () => _paymentReceipt(context);
      }
      monederoWidget = MonederoOptions(
        pagoDeServicios: true,
        monederoNumber: _monederoNumber,
        saldoMonedero: saldo,
        saldoSuficiente: _sufficientFunds,
        pagodeServiciosFlatButton: false,
        updateSaldoPagoDeServicios: getSaldo,
      );
    });
  }

  // Future<void> scan() async {

  // }

  Future<void> scan(BuildContext context) async {
    await _listenForPermissionStatus();
  }

  _listenForPermissionStatus() {
    PermissionHandler().checkPermissionStatus(PermissionGroup.camera).then(_updatePermissions);
  }

  _askCameraPermission() {
    PermissionHandler().requestPermissions([PermissionGroup.camera]).then((result) {
      print(result[PermissionGroup.camera]);
      if (result[PermissionGroup.camera] == PermissionStatus.denied) {
        print(result[PermissionGroup.camera]);
        _showCameraDialog();
      } else {
        _onPermissionStatusRequested(result);
      }
    }).catchError((onError) {
      print(onError);
    });
  }

  void _onPermissionStatusRequested(Map<PermissionGroup, PermissionStatus> statuses) {
    final status = statuses[PermissionGroup.camera];
    if (status != PermissionStatus.granted) {
      if (Platform.isIOS) {
        _showCameraDialog();
      }
    } else {
      _updatePermissions(status);
    }
  }

  _showCameraDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Icon(
              Icons.camera_alt,
              size: 52,
              color: DataUI.chedrauiColor,
            ),
          ),
          content: Text(
            'Por favor habilita tu cámara para ofrecerte la mejor experiencia',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: DataUI.textOpaque,
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  PermissionHandler().openAppSettings().then((bool hasOpened) {
                    debugPrint('App Settings opened: ' + hasOpened.toString());
                  });
                },
                child: Text(
                  "Habilitar",
                  style: TextStyle(
                    color: DataUI.chedrauiBlueColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future _updatePermissions(PermissionStatus status) async {
    if (mounted) {
      setState(() {
        _permissionsStatus = status;
        _hasCameraAccess = _permissionsStatus == PermissionStatus.granted ? true : false;
      });
      if (!_hasCameraAccess) {
        _askCameraPermission();
        print('s');
      } else {
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
    }
  }

  launchAVP() async {
    const url = 'https://www.chedraui.com.mx/privacy';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showErrorMessage(context, null, "No se ha podido abrir el link. Intente de nuevo");
    }
  }

  Future<void> showErrorMessage(BuildContext context, title, String errorMessage) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
          title: Text(title != null ? title : 'Lamentamos comunicarte'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(errorMessage),
              Container(
                margin: EdgeInsets.only(top: 15),
                child: Row(
                  children: <Widget>[
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
                              'Continuar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> showCancelConfirmation(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(30, 15, 30, 0),
          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
          content: Container(
            margin: EdgeInsets.symmetric(vertical: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '¿Estás seguro de cancelar esta operación?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  height: 120,
                  margin: EdgeInsets.only(top: 15),
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 6,
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 7.5),
                          child: FlatButton(
                              color: DataUI.chedrauiColor,
                              disabledColor: DataUI.chedrauiColorDisabled,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(14),
                                child: Text(
                                  'No',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context)),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          width: double.infinity,
                          //margin: EdgeInsets.only(right: 7.5),
                          child: FlatButton(
                              color: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              // borderSide: BorderSide(
                              //   width: 2,
                              //   color: HexColor('#0D47A1'),
                              // ),
                              child: Container(
                                margin: const EdgeInsets.all(14),
                                child: Text(
                                  'Si',
                                  style: TextStyle(
                                    color: HexColor('#0D47A1'),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
    var _body;
    if (selectedRadioTelefonia != null && widget.telefonia != null) {
      _body = {
        "name": name,
        "idPos": "1",
        "idCajero": "1",
        "sku": "${selectedRadioTelefonia['sku']}",
        "skuComision": "${widget.serviceSkuComision}",
        "tipoPago": "MELE",
        "referencia": _referenceController.text,
        //"monto": "${selectedRadioTelefonia['monto']}",
        "monto": double.parse(selectedRadioTelefonia['monto']),
        "comision": _serviceCommission,
        //"email": 'alerodriguez162@gmail.com',
        "email": widget.userEmail,
        //"phone": '5583723886',
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
    } else {
      _body = {
        "name": name,
        "idPos": "1",
        "idCajero": "1",
        "sku": "${widget.serviceSku}",
        "skuComision": "${widget.serviceSkuComision}",
        "tipoPago": "MELE",
        "referencia": _referenceController.text,
        "monto": _serviceBalance,
        "comision": _serviceCommission,
        //"email": 'alerodriguez162@gmail.com',
        "email": widget.userEmail,
        //"phone": '5583723886',
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
    }

    print(json.encode(_body));

    String _servicesInfoUrl = 'https://us-central1-chedraui-bill-pay.cloudfunctions.net/services/payment/execute';
    return await http.post(_servicesInfoUrl, headers: _headers, body: utf8.encode(json.encode(_body)));
  }

  void _paymentReceipt(BuildContext context) async {
    // http.Response response = await executePayment(context);
    // Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(
    //     builder: (BuildContext context) => PaymentReceipt(
    //       serviceID: widget.serviceID,
    //       balance: 0.0,
    //       comision: 0.0,
    //       referencia: _referenceController.text,
    //       autorizacion: '',
    //       serviceTransaction: _serviceTransaction,
    //       paymentDate: _paymentDate ?? DateFormat.yMMMd().format(DateTime.now()),
    //       expirationDate: _expirationDate,
    //       serviceName: widget.serviceName,
    //       userEmail: widget.userEmail,
    //       isServiceFavorite: widget.isSavedService,
    //       logo: widget.serviceLogo,
    //     ),
    //   ),
    //   (Route<dynamic> route) => false,
    // );
    try {
      setState(() {
        _isLoading2 = true;
        status = 'Procesando pago';
      });
      http.Response response = await executePayment(context);
      List items = json.decode(response.body);
      final int statusCode = response.statusCode;
      if (statusCode == 200) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) => PaymentReceipt(
              serviceID: widget.serviceID,
              balance: double.parse(getValue(items, "MONTO") ?? "0.0"),
              comision: double.parse(getValue(items, "COMISION") ?? "0.0"),
              referencia: _referenceController.text,
              autorizacion: getValue(items, "AUTORIZACION"),
              serviceTransaction: getValue(items, "REFERENCIA"),
              paymentDate: _paymentDate ?? DateFormat.yMMMd().format(DateTime.now()),
              expirationDate: _expirationDate,
              serviceName: widget.serviceName,
              userEmail: widget.userEmail,
              isServiceFavorite: widget.isSavedService,
              logo: widget.serviceLogo,
              logID: getValue(items, "ID"),
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
        showErrorMessage(context, null, 'Ha ocurrido un problema al realizar el pago: $message');
      } else {
        String message = errorMessageFromResponse(response.body);
        showErrorMessage(context, null, 'Ha ocurrido un problema al realizar el pago: $message');
        throw new Exception("Error while fetching data");
      }
    } catch (error) {
      print(error);
      showErrorMessage(context, titleError, bodyError);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading2 = false;
        });
      }
    }
  }

  String _validateMonto(String value) {
    var monto = _montoController.numberValue;
    if (montoMinimo != null) {
      if (monto < montoMinimo) {
        return 'Monto minimo \n${moneda.format(montoMinimo)}';
      }
    }
    if (montoMaximo != null) {
      if (monto > montoMaximo) {
        return 'Monto máximo \n${moneda.format(montoMaximo)}';
      }
    }
    return null;
  }

  getSaldo() async {
    await getIdMonedero();
    setState(() {
      monederoWidget = CircularProgressIndicator();
    });
    /*
    if (this.idMonedero != null)
      MonederoServices.getSaldoMonedero(this.idMonedero).then((x) {
        if (x != null && x["resultado"] != null && x["resultado"]["saldo"] != null) {
          setState(() {
            saldo = double.parse(x["resultado"]["saldo"].toString());
          });
        }
      });
    return "Success!";
    */
    try {
      var saldoResult = await MonederoServices.getSaldoMonederoRCS(_monederoNumber);
      if (saldoResult != null && saldoResult["CodigoRes"] == "200" && saldoResult["DatosRCS"] != null) {
        setState(() {
          saldo = double.parse(saldoResult["DatosRCS"]["Monto"]);
          if (status == 'Revisar transacción') {
            if (widget.telefonia != null && selectedRadioTelefonia != null) {
              if (saldo > _serviceTotal) {
                _sufficientFunds = true;
                _payService = () => _paymentReceipt(context);
              }
            } else {
              if (saldo > _serviceTotal) {
                _sufficientFunds = true;
                _payService = () => _paymentReceipt(context);
              }
            }

            monederoWidget = MonederoOptions(
              pagoDeServicios: true,
              monederoNumber: _monederoNumber,
              saldoMonedero: saldo,
              saldoSuficiente: _sufficientFunds,
              pagodeServiciosFlatButton: false,
              updateSaldoPagoDeServicios: getSaldo,
            );
          }
        });
      } else {
        throw new Exception("Not a valid object");
      }
    } catch (e) {
      print(e);
    }
  }

  getIdMonedero() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String idWallet = prefs.getString("idWallet");
    setState(() {
      name = prefs.getString("delivery-userName");
    });

    if (idWallet != null) {
      await MonederoServices.getIdMonedero(idWallet).then((monedero) {
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
    print(_body);
    if (_formKey.currentState.validate()) {
      setState(() {
        status = 'Verificación';
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
            status = 'Revisar transacción';
            _serviceResponse = 1;
            _isLoading = false;
            _referenceInfo = getValue(_serviceData, "REFERENCIA");
            _originalSaldo = getValue(_serviceData, "SALDO") != null ? double.parse(getValue(_serviceData, "SALDO")) : 0.0;
            _serviceCommission = getValue(_serviceData, "COMISION") != null ? double.parse(getValue(_serviceData, "COMISION")) : 0.0;
            if (_originalSaldo != 0){
               _serviceBalance = _originalSaldo - _serviceCommission;
            }else{
               _serviceBalance = _originalSaldo;
            }
            _serviceTransactionNumber = getValue(_serviceData, "TRANSACCION") != null ? getValue(_serviceData, "TRANSACCION") : null;
            _montoController.text = _serviceBalance.toString();
            _serviceTotal = _serviceBalance + _serviceCommission;
            if (_serviceBalance != null && _serviceBalance > 0) {
              setState(() {
                _serviceBalanceBool = true;
              });
            } else {
              setState(() {
                _serviceBalanceBool = false;
              });
            }
            // setState(() {
            //   _serviceBalanceBool = false;
            // });
            if (widget.telefonia == null) {
              if (saldo > _serviceTotal) {
                _sufficientFunds = true;
                _payService = () => _paymentReceipt(context);
              }
            } else {
              setState(() {
                selectedRadioTelefonia = widget.telefonia[0];
                _serviceBalance = double.parse(selectedRadioTelefonia['monto']);
                _serviceTotal = _serviceBalance + _serviceCommission;
                if (saldo > _serviceTotal) {
                  _sufficientFunds = true;
                  _payService = () => _paymentReceipt(context);
                }
              });
            }
            if (widget.serviceName == "CFE") {
              _serviceStatus = titleCase(getValue(_serviceData, "ESTADO SERVICIO")) ?? null;
              _serviceTransaction = getValue(_serviceData, "TRANSACCION CFE") ?? null;
              _paymentDate = DateFormat.yMMMd().format(DateTime.parse(getValue(_serviceData, "FECHA PAGO"))) ?? null;
              _expirationDate = DateFormat.yMMMd().format(DateTime.parse(getValue(_serviceData, "FECHA VENCIMIENTO"))) ?? null;
            } else if (widget.serviceName == "Telmex") {
              dv = getValue(_serviceData, "DV") ?? null;
            }
            monederoWidget = MonederoOptions(
              pagoDeServicios: true,
              monederoNumber: _monederoNumber,
              saldoMonedero: saldo,
              saldoSuficiente: _sufficientFunds,
              pagodeServiciosFlatButton: false,
              updateSaldoPagoDeServicios: getSaldo,
            );
          });
        } else if (statusCode == 400) {
          String message = errorMessageFromResponse(response.body);
          showErrorMessage(context, null, message);
        } else {
          String message = errorMessageFromResponse(response.body);
          showErrorMessage(context, null, message);
        }
      } catch (e) {
        print(e);
        setState(() {
          _serviceResponse = null;
        });
        String message = 'Ha ocurrido un error, por favor intente de nuevo.';
        showErrorMessage(context, titleError, bodyError);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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

  openTyC() async {
    const url = 'https://www.chedraui.com.mx/terminos-y-condiciones';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Flushbar(
        message: "Ha ocurrido un error, por favor intente de nuevo.",
        backgroundColor: HexColor('#FD5339'),
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.FLOATING,
        margin: EdgeInsets.all(8),
        borderRadius: 8,
        icon: Icon(
          Icons.highlight_off,
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
      return Container(
        child: Container(
            width: double.infinity,
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.circular(5.0),
            //   color: Colors.white,
            //   boxShadow: [
            //     new BoxShadow(
            //       color: Colors.grey,
            //       blurRadius: 5.0,
            //     ),
            //   ],
            // ),
            //margin: const EdgeInsets.all(30.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  //padding: const EdgeInsets.only(top: 52.0, bottom: 30.0),
                  height: 200.0,
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        color: Colors.white,
                        padding: const EdgeInsets.only(top: 52.0, bottom: 30.0),
                        height: 170.0,
                        child: widget.serviceLogo,
                      ),
                      Container(
                        child: Text(
                          widget.serviceName.toString(),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Archivo'),
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: LinearProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(HexColor('#FBC02D')),
                          backgroundColor: HexColor('#CFCED5'),
                        ),
                      ),
                    ),
                  ],
                ),
                Center(
                  //widthFactor: 0.3,
                  child: Container(
                      width: 230,
                      margin: EdgeInsets.only(top: 52, bottom: 52),
                      //padding: EdgeInsets.symmetric(horizontal: 15),
                      //padding: EdgeInsets.only(top: 25, left:64, right: 64),
                      child: Text(
                        'Estamos validando tu información. Espera un momento por favor',
                        // maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: HexColor('#212B36'), fontFamily: 'Archivo', fontSize: 14),
                      )),
                ),
                Container(
                  width: 210,
                  child: Image.asset('assets/loading1.gif'),
                )
              ],
            )),
      );
    } else if (_isLoading2) {
      return Container(
        child: Container(
            width: double.infinity,
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.circular(5.0),
            //   color: Colors.white,
            //   boxShadow: [
            //     new BoxShadow(
            //       color: Colors.grey,
            //       blurRadius: 5.0,
            //     ),
            //   ],
            // ),
            //margin: const EdgeInsets.all(30.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  //padding: const EdgeInsets.only(top: 52.0, bottom: 30.0),
                  height: 200.0,
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        color: Colors.white,
                        padding: const EdgeInsets.only(top: 52.0, bottom: 30.0),
                        height: 170.0,
                        child: widget.serviceLogo,
                      ),
                      Container(
                        child: Text(
                          widget.serviceName.toString(),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Archivo'),
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: LinearProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(HexColor('#FBC02D')),
                          backgroundColor: HexColor('#CFCED5'),
                        ),
                      ),
                    ),
                  ],
                ),
                Center(
                  //widthFactor: 0.3,
                  child: Container(
                      width: 230,
                      margin: EdgeInsets.only(top: 52, bottom: 52),
                      //padding: EdgeInsets.symmetric(horizontal: 15),
                      //padding: EdgeInsets.only(top: 25, left:64, right: 64),
                      child: Text(
                        'Estamos procesando tu transacción enseguida te confirmamos.',
                        // maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: HexColor('#212B36'), fontFamily: 'Archivo', fontSize: 14),
                      )),
                ),
                Container(
                  width: 210,
                  child: Image.asset('assets/loading2.gif'),
                )
              ],
            )),
      );
    } else {
      switch (_serviceResponse) {
        case 1:
          setState(() {
            status = 'Revisar transacción';
          });
          return SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 30),
                  child: Column(
                    children: <Widget>[
                      _monederoNumber != 'null' ? monederoWidget : SizedBox(),
                      Container(
                        margin: const EdgeInsets.only(bottom: 15.0, left: 15, right: 15, top: 30),
                        child: Row(
                          children: <Widget>[
                            Text(
                              'Recibo a pagar',
                              style: TextStyle(fontSize: 16, color: HexColor('#0D47A1'), fontFamily: 'Archivo', letterSpacing: 0.5, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: Colors.white,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Color(0xcc000000).withOpacity(0.2),
                                offset: Offset(5.0, 5.0),
                                blurRadius: 5.0,
                              ),
                            ],
                          ),
                          margin: const EdgeInsets.only(bottom: 0.0),
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                widget.serviceName,
                                style: TextStyle(fontFamily: 'Archivo', fontSize: 16.0, fontWeight: FontWeight.bold),
                              ),
                              Divider(
                                color: HexColor('#DFE3E8'),
                              ),
                              widget.telefonia != null
                                  ? Container(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.symmetric(vertical: 15),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  margin: EdgeInsets.only(right: 10),
                                                  child: Text(
                                                    'Celular',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: HexColor('#212B36'),
                                                      fontFamily: 'Archivo',
                                                      letterSpacing: 0.25,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  _referenceController.text,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: HexColor('#212B36'),
                                                    fontFamily: 'Archivo',
                                                    letterSpacing: 0.25,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            'Selecciona el monto de tu recarga:',
                                            style: TextStyle(fontFamily: 'Archivo', fontSize: 16.0, fontWeight: FontWeight.bold),
                                          ),
                                          Container(
                                            margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                                            child: GridView.builder(
                                              physics: ClampingScrollPhysics(),
                                              shrinkWrap: true,
                                              primary: true,
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3, childAspectRatio: 2.5,
                                                crossAxisSpacing: 20,
                                                mainAxisSpacing: 20,
                                                // childAspectRatio: constraints.maxWidth < 350 ? 22 / 32 : 22 / 32,
                                              ),
                                              itemCount: widget.telefonia == null ? 0 : widget.telefonia.length,
                                              itemBuilder: (context, index) {
                                                return selectedRadioTelefonia != widget.telefonia[index]
                                                    ? OutlineButton(
                                                        shape: new RoundedRectangleBorder(
                                                          borderRadius: new BorderRadius.circular(6.0),
                                                        ),
                                                        color: HexColor('#919EAB'),
                                                        onPressed: () {
                                                          setState(() {
                                                            selectedRadioTelefonia = widget.telefonia[index];
                                                            _serviceBalance = double.parse(selectedRadioTelefonia['monto']);
                                                            _serviceTotal = _serviceBalance + _serviceCommission;
                                                            if (saldo > _serviceTotal) {
                                                              _sufficientFunds = true;
                                                            } else {
                                                              _sufficientFunds = false;
                                                            }
                                                          });
                                                        },
                                                        child: Text(
                                                          '${moneda.format(double.parse(widget.telefonia[index]['monto']))}',
                                                          style: TextStyle(color: HexColor('#444444'), fontSize: 12, fontWeight: FontWeight.normal),
                                                        ),
                                                      )
                                                    : FlatButton(
                                                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                                                        color: HexColor('#0D47A1'),
                                                        onPressed: () {
                                                          setState(() {
                                                            selectedRadioTelefonia = widget.telefonia[index];
                                                            _serviceBalance = double.parse(selectedRadioTelefonia['monto']);
                                                            _serviceTotal = _serviceBalance + _serviceCommission;
                                                            if (saldo > _serviceTotal) {
                                                              _sufficientFunds = true;
                                                            } else {
                                                              _sufficientFunds = false;
                                                            }
                                                          });
                                                        },
                                                        child: Text(
                                                          '${moneda.format(double.parse(widget.telefonia[index]['monto']))}',
                                                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.normal),
                                                        ),
                                                      );
                                                // return RadioListTile(
                                                //   activeColor: HexColor("#212B36"),
                                                //   title: Text(
                                                //     '${moneda.format(double.parse(widget.telefonia[index]['monto']))}',
                                                //     style: TextStyle(
                                                //       fontSize: 14,
                                                //       color: HexColor('#212B36'),
                                                //       fontFamily: 'Archivo',
                                                //       letterSpacing: 0.25,
                                                //     ),
                                                //   ),
                                                //   value: widget.telefonia[index],
                                                //   groupValue: selectedRadioTelefonia,
                                                //   onChanged: (value) {
                                                //     setState(() {
                                                //       selectedRadioTelefonia = value;
                                                //       _serviceBalance = double.parse(selectedRadioTelefonia['monto']);
                                                //       _serviceTotal = _serviceBalance + _serviceCommission;
                                                //     });
                                                //   },
                                                // );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.symmetric(vertical: 3),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  'Número de referencia',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: HexColor('#212B36'),
                                                    fontFamily: 'Archivo',
                                                    letterSpacing: 0.25,
                                                  ),
                                                ),
                                                Text(
                                                  _referenceController.text,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: HexColor('#212B36'),
                                                    fontFamily: 'Archivo',
                                                    letterSpacing: 0.25,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          _expirationDate != null
                                              ? Container(
                                                  margin: EdgeInsets.symmetric(vertical: 3),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                        'Fecha de vencimiento',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: HexColor('#212B36'),
                                                          fontFamily: 'Archivo',
                                                          letterSpacing: 0.25,
                                                        ),
                                                      ),
                                                      Text(
                                                        _expirationDate,
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
                                              : Container(),
                                          _serviceBalanceBool
                                              ? Container(
                                                  margin: EdgeInsets.symmetric(vertical: 15),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                        'Saldo a pagar',
                                                        style: TextStyle(fontSize: 16, color: HexColor('#212B36'), fontFamily: 'Archivo', letterSpacing: 0.5, fontWeight: FontWeight.bold),
                                                      ),
                                                      Text(
                                                        moneda.format(_serviceBalance),
                                                        style: TextStyle(fontSize: 16, color: HexColor('#212B36'), fontFamily: 'Archivo', letterSpacing: 0.5, fontWeight: FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Container(),
                                          Container(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                _serviceBalanceBool
                                                    ? RadioListTile(
                                                        activeColor: HexColor("#212B36"),
                                                        title: Text(
                                                          'Pagar Monto Total',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: HexColor('#212B36'),
                                                            fontFamily: 'Archivo',
                                                            letterSpacing: 0.25,
                                                          ),
                                                        ),
                                                        value: 'montoTotal',
                                                        groupValue: selectedRadioTile,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _serviceBalance = _originalSaldo - _serviceCommission;
                                                            _serviceTotal = _originalSaldo;
                                                            selectedRadioTile = value;
                                                          });
                                                        },
                                                      )
                                                    : SizedBox(),
                                                _serviceBalanceBool
                                                    ? Divider(
                                                        color: HexColor('#DFE3E8'),
                                                      )
                                                    : Container(
                                                        margin: EdgeInsets.only(top: 7, bottom: 10, right: 0, left: 0),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: <Widget>[
                                                            Container(
                                                              margin: EdgeInsets.only(left: 5),
                                                              child: Text(
                                                                'Importante:',
                                                                style: TextStyle(fontSize: 12, fontFamily: 'Archivo Bold', color: HexColor('#FD5339'), fontWeight: FontWeight.bold),
                                                              ),
                                                            ),
                                                            Container(
                                                              width: double.infinity,
                                                              decoration: BoxDecoration(
                                                                border: Border.all(color: HexColor('#FD5339')),
                                                                borderRadius: BorderRadius.circular(5.0),
                                                              ),
                                                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                              child: Text(
                                                                widget.messageToUser != null && widget.messageToUser != '' ? widget.messageToUser : 'Debe pagar lo correspondiente al saldo total como indica su recibo, de lo contrario no podrá continuar con el proceso',
                                                                textAlign: TextAlign.left,
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontFamily: 'Archivo',
                                                                  color: HexColor('#FD5339'),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                _serviceBalanceBool
                                                    ? RadioListTile(
                                                        activeColor: HexColor("#212B36"),
                                                        title: Text(
                                                          'Otra Cantidad',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: HexColor('#212B36'),
                                                            fontFamily: 'Archivo',
                                                            letterSpacing: 0.25,
                                                          ),
                                                        ),
                                                        value: 'anotherMonto',
                                                        groupValue: selectedRadioTile,
                                                        onChanged: widget.tipoPago != null && widget.tipoPago == 'total'
                                                            ? null
                                                            : (value) {
                                                                setState(() {
                                                                  selectedRadioTile = value;
                                                                });
                                                              },
                                                      )
                                                    : Text(
                                                        'Monto a pagar',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: HexColor('#212B36'),
                                                          fontFamily: 'Archivo',
                                                          letterSpacing: 0.25,
                                                        ),
                                                      ),
                                                selectedRadioTile == 'anotherMonto' || !_serviceBalanceBool
                                                    ? SizedBox(
                                                        height: 66,
                                                        child: Container(
                                                          //  height: 58,
                                                          margin: !_serviceBalanceBool ? EdgeInsets.only(left: 0) : EdgeInsets.only(left: 30),
                                                          child: Row(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget>[
                                                              Expanded(
                                                                flex: 4,
                                                                child: Theme(
                                                                  data: ThemeData(
                                                                    primaryColor: HexColor('#C4CDD5'),
                                                                    hintColor: HexColor('#C4CDD5'),
                                                                  ),
                                                                  child: Container(
                                                                    margin: EdgeInsets.only(right: 7, top: 6),
                                                                    child: Form(
                                                                      key: formMonto,
                                                                      autovalidate: true,
                                                                      child: TextFormField(
                                                                        style: TextStyle(
                                                                          fontSize: 14,
                                                                          fontFamily: 'Archivo',
                                                                          letterSpacing: 0.25,
                                                                          color: DataUI.chedrauiBlueColor,
                                                                        ),
                                                                        enabled: btnStatus,
                                                                        controller: _montoController,
                                                                        decoration: InputDecoration(
                                                                          helperText: ' ',
                                                                          filled: true,
                                                                          border: OutlineInputBorder(
                                                                            borderRadius: BorderRadius.circular(5.0),
                                                                          ),
                                                                          contentPadding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 6),
                                                                          fillColor: HexColor('#F4F6F8'),
                                                                        ),
                                                                        keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
                                                                        inputFormatters: [
                                                                          WhitelistingTextInputFormatter.digitsOnly,
                                                                        ],
                                                                        validator: _validateMonto,
                                                                        onSaved: (input) => _reference = input,
                                                                        textInputAction: TextInputAction.done,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 4,
                                                                child: FlatButton(
                                                                  padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 6),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(4.0),
                                                                  ),
                                                                  color: DataUI.chedrauiBlueColor,
                                                                  // borderSide: BorderSide(color: DataUI.chedrauiBlueColor),
                                                                  child: Text(
                                                                    btnStatusString,
                                                                    style: TextStyle(fontFamily: 'Archivo', fontSize: 16, color: Colors.white, letterSpacing: 0.5),
                                                                  ),
                                                                  onPressed: () {
                                                                    if (btnStatus) {
                                                                      if (formMonto.currentState.validate()) {
                                                                        setState(() {
                                                                          btnStatusString = 'Editar';
                                                                          btnStatus = !btnStatus;
                                                                          _updateBalance();
                                                                        });
                                                                      }
                                                                    } else {
                                                                      setState(() {
                                                                        btnStatusString = 'Confirmar';
                                                                        btnStatus = !btnStatus;
                                                                      });
                                                                    }

                                                                    //_updateBalance();
                                                                  },
                                                                ),
                                                              ),
                                                              Expanded(flex: 4, child: Container()),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : Container()
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                            ],
                          )),
                      //MonederoOptions(),
                      Container(
                        margin: const EdgeInsets.only(bottom: 15.0, left: 15, right: 15, top: 30),
                        child: Row(
                          children: <Widget>[
                            Text(
                              'Resumen de transacción',
                              style: TextStyle(fontSize: 16, color: HexColor('#0D47A1'), fontFamily: 'Archivo', letterSpacing: 0.5, fontWeight: FontWeight.bold),
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
                              'Monto a pagar',
                              style: TextStyle(
                                fontSize: 14,
                                color: HexColor('#212B36'),
                                fontFamily: 'Archivo',
                                letterSpacing: 0.25,
                              ),
                            ),
                            Text(
                              '\$ ${formatter.format(_serviceBalance)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: HexColor('#212B36'),
                                fontFamily: 'Archivo',
                                letterSpacing: 0.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 15.0, left: 15, right: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Comisión',
                              style: TextStyle(
                                fontSize: 14,
                                color: HexColor('#212B36'),
                                fontFamily: 'Archivo',
                                letterSpacing: 0.25,
                              ),
                            ),
                            Text(
                              '\$ ${formatter.format(_serviceCommission)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: HexColor('#212B36'),
                                fontFamily: 'Archivo',
                                letterSpacing: 0.25,
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
                                          'Total',
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
                                    margin: const EdgeInsets.only(bottom: 15.0, left: 15, right: 15),
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: 'Tu transacción ',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: HexColor('#212B36'),
                                              fontFamily: 'Archivo',
                                              letterSpacing: 0.25,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'no puede ser realizada',
                                            style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo', letterSpacing: 0.25, fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text: ', el saldo de tu monedero no cubre el monto a pagar, es necesario incrementar tu saldo disponible.',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: HexColor('#212B36'),
                                              fontFamily: 'Archivo',
                                              letterSpacing: 0.25,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.all(15),
                                    child: MonederoOptions(
                                      monederoNumber: _monederoNumber,
                                      pagodeServiciosFlatButton: true,
                                      updateSaldoPagoDeServicios: getSaldo,
                                    ),
                                    // child: OutlineButton(
                                    //   shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                    //   padding: EdgeInsets.all(15),
                                    //   borderSide: BorderSide(
                                    //     color: DataUI.chedrauiBlueColor,
                                    //     style: BorderStyle.solid, //Style of the border
                                    //     width: 2.0, //width of the border
                                    //   ),
                                    //   child: Text(
                                    //     'Recarga tu Monedero en el Wallet',
                                    //     style: TextStyle(color: DataUI.chedrauiBlueColor, fontSize: 14.0),
                                    //   ),
                                    //   onPressed: () {
                                    //     Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
                                    //     Navigator.pushNamed(context, DataUI.monederoRoute);
                                    //     // Navigator.push(
                                    //     //     context,
                                    //     //     MaterialPageRoute(
                                    //     //     builder: (context) => MonederoPage(),
                                    //     //     ),
                                    //     // );
                                    //     // Navigator.of(context)
                                    //     //     .pushAndRemoveUntil(
                                    //     //   MaterialPageRoute(
                                    //     //     builder: (BuildContext context) =>
                                    //     //         MasterPage(
                                    //     //           initialWidget: MenuItem(
                                    //     //             id: 'monedero',
                                    //     //             title: 'Mi Monedero',
                                    //     //             screen: MonederoPage(),
                                    //     //             color: DataUI.chedrauiColor2,
                                    //     //             textColor: DataUI.primaryText,
                                    //     //           ),
                                    //     //         ),
                                    //     //   ),
                                    //     //   (Route<dynamic> route) => false,
                                    //     // );
                                    //   },
                                    // ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(),
                      _sufficientFunds
                          ? Center(
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Checkbox(
                                    activeColor: DataUI.chedrauiBlueColor,
                                    value: acceptedTyC,
                                    onChanged: (bool value) {
                                      setState(() {
                                        acceptedTyC = !acceptedTyC;
                                      });
                                    },
                                  ),
                                  Text("Acepto Términos y Condiciones",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                      )),
                                ],
                              ),
                            )
                          : SizedBox(),
                      _sufficientFunds
                          ? Container(
                              margin: EdgeInsets.symmetric(horizontal: 15),
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
                                          'Pagar ahora con mi saldo',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      onPressed: widget.telefonia == null ? _sufficientFunds && _serviceBalance > 0 && acceptedTyC && (selectedRadioTile != null ? true : true) ? _payService : null : _sufficientFunds && _serviceBalance > 0 && acceptedTyC ? _payService : null,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(),
                      Container(
                        child: FlatButton(
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              color: DataUI.chedrauiBlueColor,
                            ),
                          ),
                          onPressed: () async {
                            await showCancelConfirmation(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        default:
          setState(() {
            status = 'Pago de servicios';
          });
          return SafeArea(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Container(
                  //margin: EdgeInsets.symmetric(horizontal: 15),
                  child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          color: Colors.white,
                          //padding: const EdgeInsets.only(top: 52.0, bottom: 30.0),
                          height: 200.0,
                          child: Column(
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                color: Colors.white,
                                padding: const EdgeInsets.only(top: 52.0, bottom: 30.0),
                                height: 170.0,
                                child: widget.serviceLogo,
                              ),
                              Container(
                                child: Text(
                                  widget.serviceName.toString(),
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Archivo'),
                                ),
                              )
                            ],
                          ),
                        ),
                        widget.serviceName != 'Telmex'
                            ? Container(
                                margin: EdgeInsets.symmetric(horizontal: 15),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10.0, top: 15),
                                  child: Text(
                                    'Puedes ingresar el número de referencia o escanear con la cámara de tu cámara el código de barras',
                                    style: TextStyle(
                                      color: HexColor('#212B36'),
                                      fontFamily: 'Archivo',
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                        widget.serviceName == 'Telmex'
                            ? Container(
                                margin: EdgeInsets.symmetric(horizontal: 15),
                                child: Stack(
                                  // mainAxisSize: MainAxisSize.min,
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  // mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.only(bottom: 0.0, top: 15.5),
                                      child: Text(
                                        'Ingresa el número de servicio o escanea el',
                                        style: TextStyle(
                                          color: HexColor('#212B36'),
                                          fontFamily: 'Archivo',
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(top: 15),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            margin: const EdgeInsets.only(bottom: 0.0, top: 0),
                                            child: Text(
                                              'código de barras (30 digitos)',
                                              style: TextStyle(
                                                color: HexColor('#212B36'),
                                                fontFamily: 'Archivo',
                                                fontSize: 12.0,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            child: IconButton(
                                              iconSize: 18.0,
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
                                  ],
                                ),
                              )
                            : Container(
                                margin: EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 10.0, top: 6.5),
                                      child: Text(
                                        'Número de referencia',
                                        style: TextStyle(
                                          color: HexColor('#212B36'),
                                          fontFamily: 'Archivo',
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: IconButton(
                                        iconSize: 18.0,
                                        alignment: Alignment.centerLeft,
                                        icon: Icon(
                                          Icons.info_outline,
                                          color: Color.fromRGBO(57, 62, 67, 0.75),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              settings: RouteSettings(name: DataUI.selectedPagoServiciosRoute),
                                              builder: (BuildContext context) => KenticoToolTip(toolTip: widget.toolTip, toolTipDescription: widget.toolTipDescription),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 15.0, left: 15, right: 15),
                          child: Form(
                            key: _formKey,
                            autovalidate: true,
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
                                      //keyboardType: TextInputType.numberWithOptions(),
                                      controller: _referenceController,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                        ),
                                        contentPadding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 6),
                                        hintStyle: TextStyle(color: HexColor('#0D47A1'), fontSize: 12),
                                        suffixIcon: IconButton(
                                          icon: ScanSVG(),
                                          onPressed: () => scan(context),
                                        ),
                                      ),
                                      validator: widget.telefonia != null ? validatePhone : validateReferenceCfe,
                                      onSaved: (input) => _reference = input,
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (input) {
                                        _submitForm();
                                      },
                                      inputFormatters: [
                                        // WhitelistingTextInputFormatter(
                                        //   RegExp("[a-zA-Z0-9]"),
                                        // ),
                                        LengthLimitingTextInputFormatter(30),
                                      ],
                                    ),
                                  ),
                                  widget.serviceName == 'Telmex'
                                      ? Column(
                                          children: <Widget>[
                                            Container(
                                              //margin: EdgeInsets.symmetric(horizontal: 15),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Container(
                                                    margin: const EdgeInsets.only(bottom: 10.0, top: 6.5),
                                                    child: Text(
                                                      'Ingresa el dígito verificador',
                                                      style: TextStyle(
                                                        color: HexColor('#212B36'),
                                                        fontFamily: 'Archivo',
                                                        fontSize: 12.0,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: IconButton(
                                                      iconSize: 18.0,
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
                                                                'Ingresa el dígito verificador',
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
                                              margin: const EdgeInsets.only(bottom: 10.0),
                                              child: TextFormField(
                                                keyboardType: TextInputType.numberWithOptions(),
                                                controller: _dvController,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                  ),
                                                  contentPadding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 6),
                                                  hintStyle: TextStyle(color: HexColor('#0D47A1'), fontSize: 12),
                                                ),
                                                validator: validateNotEmpty,
                                                onSaved: (input) => _dvController.text = input,
                                                textInputAction: TextInputAction.done,
                                                inputFormatters: [
                                                  WhitelistingTextInputFormatter(
                                                    RegExp("[0-9]"),
                                                  ),
                                                  // LengthLimitingTextInputFormatter(30),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : SizedBox(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: <Widget>[
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
                                      'Continuar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  onPressed: statusok ? _submitForm : null,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                        ),
                      ],
                    )
                  ],
                ),
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
                  ),
            ),
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
                onPressed: () => status == 'Pago de servicios' ? Navigator.pop(context) : showCancelConfirmation(context));
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
          status,
          style: DataUI.appbarTitleStyle,
        ),
      ),
      body: GestureDetector(
        child: _toggleResponse(),
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
      ),
    );
  }
}
