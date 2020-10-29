import 'dart:async';
import 'dart:convert';

import 'package:chd_app_demo/services/CarritoServices.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/utils/NetworkData.dart';
import 'package:chd_app_demo/utils/input_formatters.dart';
import 'package:chd_app_demo/utils/payment_card.dart' as UtilsPayment;
import 'package:chd_app_demo/utils/CardUtils.dart' as UtilsCard;
import 'package:chd_app_demo/utils/payment_card.dart';
import 'package:chd_app_demo/views/Checkout/NewCreditCard.dart';
import 'package:chd_app_demo/views/Servicios/KenticoServices.dart';
import 'package:chd_app_demo/views/Errors/NetworkErrorPage/NetworkErrorPage.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';
import 'package:chd_app_demo/widgets/modalbottomsheet.dart';
import 'package:chd_app_demo/widgets/overlayContainer.dart';
import 'package:chd_app_demo/widgets/termCondWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/views/Checkout/PaymentMethod.dart';
import 'package:barcode_flutter/barcode_flutter.dart';
import 'package:chd_app_demo/services/MonederoServices.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:chd_app_demo/services/BovedaService.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:http/http.dart' as http;
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:chd_app_demo/widgets/deliveryInformation.dart';
import 'package:chd_app_demo/services/MediosPagoService.dart';
import 'package:chd_app_demo/services/PaymentServices.dart';
import 'package:translator/translator.dart';

import 'CardData.dart';

class MonederoDetails extends StatelessWidget {
  final string;
  final idMonedero;
  MonederoDetails({Key key, this.string, this.idMonedero}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WidgetContainer(
      Scaffold(
        appBar: GradientAppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop('reload');
                },
              );
            },
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              HexColor('#F56D00'),
              HexColor('#F56D00'),
              HexColor('#F78E00'),
            ],
          ),
          // leading: Builder(
          //   builder: (BuildContext context) {
          //     return IconButton(
          //         icon: Icon(Icons.arrow_back),
          //         onPressed: () {
          //           Navigator.of(context).pushAndRemoveUntil(
          //             MaterialPageRoute(
          //               builder: (BuildContext context) => MasterPage(
          //                 initialWidget: MenuItem(
          //                   id: 'monedero',
          //                   title: 'Monedero Mi Chedraui',
          //                   screen: MonederoPage(),
          //                   color: DataUI.chedrauiColor2,
          //                   textColor: DataUI.primaryText,
          //                 ),
          //               ),
          //             ),
          //             (Route<dynamic> route) => false,
          //           );
          //         });
          //   },
          // ),
          elevation: 0,
          title: Text(
            "Monedero Mi Chedraui",
            style: TextStyle(color: Colors.white, fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 19),
          ),
          centerTitle: true,
          // toolbarOpacity: 0.0,
        ),
        // body: SafeArea(
        //   child: Theme(
        //     data: ThemeData(canvasColor: Colors.transparent),
        //     child: SingleChildScrollView(
        //       child: MonederoOptions(idMonedero: this.idMonedero),
        //     ),
        //   ),
        // ),
        body: MonederoOptions(idMonedero: this.idMonedero),
      ),
    );
  }
}

class MonederoBardCode extends StatefulWidget {
  final idMonedero;
  MonederoBardCode({Key key, this.idMonedero}) : super(key: key);

  _MonederoBardCodeState createState() => _MonederoBardCodeState(idMonedero);
}

String getBarcodeCheckSum(String barcodeData) {
  barcodeData = barcodeData.substring(4, barcodeData.length);
  int checksum = 0;
  List reverse = barcodeData.split('').reversed.toList();
  for (int index = 0; index < reverse.length; index++) {
    checksum += int.parse(reverse[index]) * (3 - 2 * (index % 2));
  }
  int controlDigit = ((10 - (checksum % 10)) % 10);
  print('controlDigit $controlDigit');
  return barcodeData + controlDigit.toString();
}

String getFormattedWalletString(String idMonedero) {
  List quarter = [];
  for (int i = 0; i < idMonedero.length; i += 4) {
    quarter.add(idMonedero.substring(i, i + 4));
  }
  return quarter.join(' ');
}

class _MonederoBardCodeState extends State<MonederoBardCode> {
  _MonederoBardCodeState(this.idMonedero);
  final String idMonedero;
  double saldo;
  final formatter = new NumberFormat("###,###,###,##0.00");
  String _timeString;
  DateTime _lastUpdate, _currentTime;
  Future monederoResponse;
  @override
  void initState() {
    startTimer();
    super.initState();
    getSaldo();
  }

  void startTimer() {
    _timeString = _formatDateTime(DateTime.now());
    _lastUpdate = DateTime.now();
    Timer.periodic(Duration(minutes: 1), (Timer t) => _getTime());
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    if (mounted) {
      setState(() {
        _timeString = formattedDateTime;
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    _currentTime = dateTime;
    return DateFormat('MM/dd/yyyy hh:mm:ss').format(dateTime);
  }

  getSaldo() async {
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
      monederoResponse = MonederoServices.getSaldoMonederoRCS(idMonedero);
      var saldoResult = await monederoResponse;
      if (saldoResult != null && saldoResult["CodigoRes"] == "200" && saldoResult["DatosRCS"] != null) {
        setState(() {
          saldo = double.parse(saldoResult["DatosRCS"]["Monto"]);
        });
      } else {
        throw new Exception("Not a valid object");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: monederoResponse,
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
              return Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            saldo == null ? "" : " \$${formatter.format(saldo)}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: HexColor("#0D47A1"),
                              fontFamily: "Archivo",
                              fontSize: 65,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _currentTime.difference(_lastUpdate).inMinutes == 0 ? 'Actualizado hace un momento' : 'Actualizado ' + timeago.format(_currentTime.subtract(new Duration(minutes: _currentTime.difference(_lastUpdate).inMinutes)), locale: 'es'),
                          style: TextStyle(
                              fontFamily: "Archivo",
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: HexColor(
                                "#919EAB",
                              )),
                        ),
                        IconButton(
                          onPressed: () {
                            _lastUpdate = DateTime.now();
                            this.getSaldo();
                          },
                          splashColor: Colors.white,
                          color: HexColor("#0D47A1"),
                          icon: Icon(
                            Icons.refresh,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    Stack(
                      overflow: Overflow.visible,
                      children: <Widget>[
                        Center(
                          child: Container(
                            height: 162,
                            width: double.infinity,
                            decoration: BoxDecoration(color: Colors.white),
                            margin: EdgeInsets.only(top: 210),
/*               color: Colors.red, */
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                BarCodeImage(
                                  padding: EdgeInsets.all(0),
                                  data: getBarcodeCheckSum(this.idMonedero),
                                  codeType: BarCodeType.CodeEAN13, // Code type (required)
                                  lineWidth: 2.0, // width for a single black/white bar (default: 2.0)
                                  barHeight: 90.0, // height for the entire widget (default: 100.0)
                                  hasText: false, // Render with text label or not (default: false)
                                  onError: (error) {
                                    // Error handler
                                    print('error = $error');
                                  },
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 5),
                                  child: Text(
                                    getFormattedWalletString(this.idMonedero),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: "Rubik",
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      letterSpacing: 2,
                                      color: HexColor("#454F5B"),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: -15,
                          child: Image.asset(
                            "assets/monedero_azul.png",
                            scale: 7.5,
                            width: MediaQuery.of(context).size.width,
                            height: 260,
                          ),
                        ),
                      ],
                    ),
                  ],
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
    );
  }
}

class MonederoOptions extends StatefulWidget {
  final idMonedero;
  final bool pagoDeServicios;
  final dynamic monederoNumber;
  final dynamic saldoMonedero;
  final bool saldoSuficiente;
  final bool pagodeServiciosFlatButton;
  final Function updateSaldoPagoDeServicios;
  MonederoOptions({
    Key key,
    this.idMonedero,
    this.pagoDeServicios,
    this.monederoNumber,
    this.saldoMonedero,
    this.saldoSuficiente,
    this.pagodeServiciosFlatButton,
    this.updateSaldoPagoDeServicios,
  }) : super(key: key);

  _MonederoOptionsState createState() => _MonederoOptionsState(idMonedero);
}

class _MonederoOptionsState extends State<MonederoOptions> {
  bool loading = false;

  double saldo;

  var title;

  var body;

  var bodyError;

  var titleError;

  bool btnStatus = true;

  String btnStatusString = 'Confirmar';

  var isOpen = false;

  CardItem _showCardSelected;

  bool toggleView = true;

  bool loadingCards = false;

  FocusNode _focusNodeCurrent;

  _MonederoOptionsState(this.idMonedero);

  NewPaymentMethod newPaymentMethod = NewPaymentMethod.card;
  TextEditingController numberController = new TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  UtilsPayment.PaymentCard _paymentCard = new UtilsPayment.PaymentCard();
  SharedPreferences prefs;
  CardData cardData = new CardData();
  bool enabledButtons = true;
  final Map<String, FocusNode> _focusForm = {
    "numeroTarjeta": FocusNode(),
    "expiraTarjeta": FocusNode(),
    "cvvTarjeta": FocusNode(),
    "nombreTarjeta": FocusNode(),
    "aliasTarjeta": FocusNode(),
  };

  final String idMonedero;
  MoneyMaskedTextController _montoController = MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',', leftSymbol: '\$');
  final webview = FlutterWebviewPlugin();
  String currentType;
  String _idWallet;
  String _cardSelected;
  List tarjetasRaw;
  List montosRaw;
  List tarjetasDec = [];
  List montosDec = [];
  List tarjetasData;
  List montosData;
  List<CardItem> tarjetasDropDown = [];
  //List<custom.DropdownMenuItem<String>> montosRecargaMonederoDropDown = [];
  //List<String> montosRecargaMonederoDropDownValues = [];

  GlobalKey<_MonederoBardCodeState> globalKeyMonederoBarCode;
  NumberFormat moneda = new NumberFormat.currency(locale: 'es_MX', symbol: "\$");

  @override
  initState() {
    // setState(() {
    //   loadingCards = true;
    // });
    super.initState();
    // if (widget.pagodeServiciosFlatButton == null && !widget.pagodeServiciosFlatButton){
    //    this.getPreferences(null);
    // }

    getSaldo();
    //this.getPreferencesMontosMonedero();
    this.getDeviceID();
    globalKeyMonederoBarCode = GlobalKey();
    KenticoServices.getMessageError().then((onValue) {
      titleError = onValue['title'];
      bodyError = onValue['body'];
    });
    KenticoServices.getMessageSuccess().then((onValue) {
      title = onValue['title'];
      body = onValue['body'];
    });
  }

  _showResponseDialog(msg, e, id) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Resultado"),
            content: Text(msg),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  updateCards(id);
                  FocusScope.of(context).requestFocus(FocusNode());
                  //updateToggle(e, !toggleView);
                },
                child: Text(
                  "Cerrar",
                  style: TextStyle(
                    color: DataUI.chedrauiBlueColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        });
  }

  Future<bool> addPaymentMethod(e) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        enabledButtons = false;
      });
      updateLoaderTarjetas(e, false);

      const platform = const MethodChannel('com.cheadrui.com/decypher');

      String deviceSessionId;
      const platformId = const MethodChannel('com.cheadrui.com/paymethods');
      deviceSessionId = await platformId.invokeMethod('getID');

      CardData cardToSave = new CardData();
      cardToSave.idWallet = _idWallet;
      cardToSave.numTarjeta = await platform.invokeMethod('encrypter', {"text": cardData.numTarjeta});
      cardToSave.tipoTarjeta = await platform.invokeMethod('encrypter', {"text": cardData.tipoTarjeta});
      cardToSave.bancoEmisor = await platform.invokeMethod('encrypter', {"text": cardData.bancoEmisor});
      cardToSave.aliasTarjeta = await platform.invokeMethod('encrypter', {"text": cardData.aliasTarjeta});
      cardToSave.nomTitularTarj = await platform.invokeMethod('encrypter', {"text": cardData.nomTitularTarj});
      cardToSave.cvv = await platform.invokeMethod('encrypter', {"text": cardData.cvv});
      cardToSave.fecExpira = await platform.invokeMethod('encrypter', {"text": cardData.fecExpira});
      cardToSave.deviceSessionId = deviceSessionId;

      var result = await MonederoServices.addCard(cardToSave);

      if (result != null) {
        num code = int.parse(result["statusOperation"]["code"].toString());
        var identificador = result['tarjetas'][0]['identificador'];
        print(identificador);
        switch (code) {
          case 0:
            _showResponseDialog(result["statusOperation"]["description"], e, identificador);
            break;
          case 1:
          case 2:
            _showResponseDialog(result["statusOperation"]["description"], e, identificador);
            break;
          default:
            _showResponseDialog("Ocurrió un error al registrar su método de pago.", e, identificador);
            break;
        }
      }

      updateLoaderTarjetas(e, true);
    }
  }

  Future<String> getVista() async {
    String value;
    double costoEnvio = 0;

    String mode = NetworkData.paypalMode;
    String transactionDescription = "Descripcion de la transaccion";
    String intent = "sale";
    double discount = 0;
    double shipping = costoEnvio;
    double subtotal = this.payPalAmount;
    double tax = 0;
    double total = this.payPalAmount;

    List<dynamic> items = new List<dynamic>();

    List<PayPalProduct> listPayPalProduct = [];

    /*for (PayPalProduct elem in listPayPalProduct) {
      items.add(elem.toJson());
    }*/

    PayPalProduct item = new PayPalProduct();
    item.setSku("0001");
    item.setQuantity(1);
    item.setDescription("Recarga de monedero chedraui");
    item.setName("Recarga de monedero chedraui");
    item.setTax(0);
    item.setPrice(this.payPalAmount);

    items.add(item);

    print(items);

    var medioPagoResponse = await MediosPagoService.payment_with_paypal(mode, transactionDescription, intent, items, discount, shipping, subtotal, tax, total);

    print(medioPagoResponse);

    if (medioPagoResponse != null) {
      if (medioPagoResponse["statusOperation"]["code"] == 0) {
        String paypalUrl = medioPagoResponse["data"]["url"];

        webview.launch(paypalUrl, withJavascript: true);

        webview.onUrlChanged.listen((String url) {
          if (mounted) {
            setState(() {
              print("**************************************URL changed: $url");
              checkUrlType(url);
              doByType(url);
            });
          }
        });
      }
    }
    return value;
  }

  checkUrlType(String url) async {
    if (url == null) {
      currentType = "NONE";
    } else if (url.contains("error")) {
      currentType = "ERROR";
    } else if (url.contains("confirmar_pago") || url.contains("confirm_payment")) {
      currentType = "CONFIRMACION_PAGO";
    } else if (url.contains("conf")) {
      currentType = "CONFIRMACION_EN_PROCESO";
    } else if (url.contains("about:blank")) {
      currentType = "BLANK";
    } else {
      currentType = "NONE";
    }
    print("Url: $url");
    print("Tipo Url: $currentType");
  }

  doByType(String url) async {
    checkUrlType(url);
    switch (this.currentType) {
      case "NONE":
        return;
      case "BLANK":
        return;
      case "ERROR":
        cancel();
        return;
      case "CONFIRMACION_PAGO":
        print("doByType - CONFIRMACION_PAGO: $url");
        verifyAuthorization(url);
        return;
      default:
        return;
    }
  }

  verifyAuthorization(String url) async {
    if (url == null) return;
    Map<String, dynamic> authParams = await getParametersFromUrl(url);

    print("authParams: $authParams");

    if (authParams != null) {
      print("verifyAuthorization: todo OK");
      finalizaActividad(authParams);
    } else {
      print("La url de confirmacion no presenta parametros.");
    }
  }

  finalizaActividad(Map<String, dynamic> authParams) async {
    print("entro finalizaActividad()");

    var setPaymentResult = await PaymentServices.setPaymentMethodPayPalWallet(authParams, this.codeRecarga, this.idMonedero);

    print(setPaymentResult);
    print("=================> setPaymentResult: $setPaymentResult");
    webview.close();
    print("despues close()");

    if (setPaymentResult['errors'] != null)
      _showDialogPaypal("Error: ${setPaymentResult['errors'][0]['message']}");
    else
      _showDialogPaypal("Transacción realizada :\n$setPaymentResult");

    setState(() {
      ;
    });
  }

  Future<Map<String, dynamic>> getParametersFromUrl(String url) async {
    Map<String, dynamic> paramValues = new Map<String, dynamic>();

    if (url == "about:blank") {
      print("Proceso terminado ir a la siguiente pantalla");
    } else if (url.contains("payerID") || url.contains("token") && url.contains("email")) {
      var urlSeparated = url.split("?");
      print(urlSeparated);
      var params = urlSeparated[1].split("&");

      paramValues.putIfAbsent("paymentMethod", () => "PAYPAL");
      paramValues.putIfAbsent("amount", () => this.payPalAmount);

      for (String val in params) {
        var values = val.split("=");
        if (values[0].startsWith("token")) {
          paramValues.putIfAbsent("token", () => values[1]);
        }

        if (values[0].startsWith("payerID")) {
          paramValues.putIfAbsent("paypalId", () => values[1]);
        }
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String user = prefs.getString('email');

      paramValues.putIfAbsent("paypalAccount", () => user);
    }
    return paramValues;
  }

  cancel() async {
    webview.close();
  }

  Future<Null> open(StateSetter updateState, e) async {
    updateState(() {
      isOpen = !isOpen;
    });
  }

  Future getPreferences(idCard) async {
    prefs = await SharedPreferences.getInstance();
    _idWallet = prefs.getString('idWallet') == null ? '' : prefs.getString('idWallet');
    tarjetasDropDown.add(CardItem(
      numTarjeta: '',
      selected: false,
    ));
    await BovedaService.getCartera(this._idWallet).then((cards) async {
      if (cards != null) {
        tarjetasRaw = cards;
        if (tarjetasRaw.length > 0) {
          tarjetasDropDown = [];
          const platform = const MethodChannel('com.cheadrui.com/decypher');
          for (var i = 0; i < tarjetasRaw.length; i++) {
            String data;
            try {
              print(tarjetasRaw[i]['identificador'].toString());
              String numTarjeta = await platform.invokeMethod('decypher', {"text": tarjetasRaw[i]['numTarjeta']});
              tarjetasDec.add({
                "idWallet": tarjetasRaw[i]['idWallet'],
                "numTarjeta": numTarjeta,
                "tipoTarjeta": tarjetasRaw[i]['tipoTarjeta'],
                "bancoEmisor": await platform.invokeMethod('decypher', {"text": tarjetasRaw[i]['bancoEmisor']}),
                "aliasTarjeta": await platform.invokeMethod('decypher', {"text": tarjetasRaw[i]['aliasTarjeta']}),
                "nomTitularTarj": await platform.invokeMethod('decypher', {"text": tarjetasRaw[i]['nomTitularTarj']}),
                "cvv": "",
                "fecExpira": await await platform.invokeMethod('decypher', {"text": tarjetasRaw[i]['fecExpira']}),
                "bin": await await platform.invokeMethod('decypher', {"text": tarjetasRaw[i]['bin']}),
                "identificador": tarjetasRaw[i]['identificador']
              });

              tarjetasDropDown.add(CardItem(
                numTarjeta: numTarjeta,
                tipoTarjeta: tarjetasRaw[i]['tipoTarjeta'],
                selected: false,
                identificador: tarjetasRaw[i]['identificador'],
              ));
            } on PlatformException catch (e) {
              data = "Failed to get decoded values: '${e.message}'.";
              print(data);
            }
          }
        } else {
          tarjetasDropDown = [];
        }
        tarjetasDropDown.add(CardItem(
          numTarjeta: 'new',
          tipoTarjeta: '',
          selected: false,
          identificador: null,
        ));

        //if (idCard != null) {
        if (_selectedRegistredCardId > 0) {
          setState(() {
            //_value = idCard;
            _value = _selectedRegistredCardId;
            _showCardSelected = tarjetasDropDown.firstWhere((t) => t.identificador == _value);
            _selectedRegistredCard = tarjetasDropDown.indexOf(_showCardSelected);
            tarjetasData = tarjetasDec;
          });
        } else {
          setState(() {
            _value = tarjetasDropDown[0].identificador;
            tarjetasDropDown.first.selected = true;
            _showCardSelected = tarjetasDropDown.first;
            tarjetasData = tarjetasDec;
            loadingCards = false;
          });
        }
      }
    });

    return "Success!";
  }

  // Future getPreferencesMontosMonedero() async {
  //   prefs = await SharedPreferences.getInstance();

  //   print('********** getPreferencesMontosMonedero');

  //   montosRecargaMonederoDropDown.add(custom.DropdownMenuItem(child: Text("No hay montos disponibles."), value: ''));
  //   montosRecargaMonederoDropDownValues.add('');

  //   //Montos Monedero
  //   PaymentServices.getRechargeOptionsMonedero().then((montos) async {
  //     if (montos != null) {
  //       montosRaw = montos;
  //       if (montosRaw.length > 0) {
  //         montosRecargaMonederoDropDown = [];
  //         montosRecargaMonederoDropDownValues = [];
  //       }

  //       for (var i = 0; i < montosRaw.length; i++) {
  //         String data;

  //         try {
  //           print(montosRaw[i]['code'].toString());
  //           String code = montosRaw[i]['code'];
  //           double amount = montosRaw[i]['amount'];
  //           double benefit = montosRaw[i]['benefit'];
  //           montosDec.add({"code": code, "amount": amount, "benefit": benefit});

  //           montosRecargaMonederoDropDown.add(custom.DropdownMenuItem(child: Text("Recarga \$" + amount.toString() + " recibe \$" + benefit.toString() + " de regalo"), value: code));
  //           montosRecargaMonederoDropDownValues.add(code);
  //         } on PlatformException catch (e) {
  //           data = "Failed to get decoded values: '${e.message}'.";
  //           print(data);
  //         }
  //       }
  //       //print("Tarjeta desencriptada->"+tarjetasDec[0].toString());
  //       setState(() {
  //         _valueMonto = montosRecargaMonederoDropDownValues.first;
  //         montosData = montosDec;
  //       });
  //     }
  //   });

  //   return "Success!";
  // }

  @override
  bool _value1 = false;
  final secondFormKey = GlobalKey<FormState>();
  List<String> _colors = <String>['', '**** **** **** 4242', '**** **** **** 3737', '**** **** **** 3737'];
  String _color = '';

  String nombre, paterno, materno, direccion, numInterior, colonia, estado, cpostal, email, telefono;

  dynamic _value;
  String _monto = "100";

  String _valueMonto;

  PaymentMethod payMethod = PaymentMethod.card;
  String dropdownValue = 'One';

  List _cards;
  int _selectedRegistredCard = 0;
  int _selectedRegistredCardId = 0;

  bool update = false;
  double payPalAmount;
  String codeRecarga;

  int _tipoTarjeta;
  String tokenOpenPay;
  String customerIdOpenPay;
  String _cvv;

  bool _validateCvv;

  String messageErrorOpenPay = "";

  bool operationWasCanceled = false;

  String monederoStatusCode = "";
  String monederoStatusDescription = "";

  bool loadingDetailsMonedero = true;

  void _onChanged1(bool value) => setState(() => _value1 = value);

  String _validateMonto(String value) {
    var monto = _montoController.numberValue;
    if (monto > 0) {
      return null;
    } else {
      return "Ingrese una cantidad mayor a 0";
    }
  }

  Future<Null> updateToggle(StateSetter updateState, e) async {
    updateState(() {
      toggleView = e;
    });
  }

  Future<Null> updateLoaderTarjetas(StateSetter updateState, e) async {
    updateState(() {
      enabledButtons = e;
    });
  }

  Future<Null> updateTextField(StateSetter updateState, e) async {
    updateState(() {
      btnStatus = e;
    });
  }

  Future<Null> updateBtn(StateSetter updateState, e) async {
    updateState(() {
      btnStatusString = e;
    });
  }

  Future<Null> updated(StateSetter updateState, pMethod) async {
    updateState(() {
      print(pMethod);
      payMethod = pMethod;
    });
  }

  Future<Null> updateLoader(StateSetter updateState, e) async {
    updateState(() {
      print(e);
      loading = e;
    });
  }

  Future<Null> updatedCard(StateSetter updateState, id) async {
    updateState(() {
      _value = id;
      _showCardSelected = tarjetasDropDown.firstWhere((t) => t.identificador == _value);
      _selectedRegistredCard = tarjetasDropDown.indexOf(_showCardSelected);
    });
  }

  Future<Null> updatedMontoMonedero(StateSetter updateState, montoMonedero) async {
    updateState(() {
      _valueMonto = montoMonedero;
    });
  }

  TextEditingController paypalAmountTextController = new TextEditingController();

  TextEditingController cardAmountTextController = new TextEditingController();

  void _showDialogPaypal(String message) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Pago con PayPal"),
          content: new Text(message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDialogCard(String title, message) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(message.toString()),
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

  updateCards(id) async {
    Navigator.pop(context);
    setState(() {
      toggleView = true;
      loadingCards = true;
    });
    _selectedRegistredCardId = id;
    var e = await getPreferences(id);
    if (e != null) {
      await Future.delayed(const Duration(milliseconds: 1500), () {
        setState(() {
          loadingCards = false;
        });
        rechargeMonederoModal(context);
      });
    }
  }

  // setPaymentForCard(String cartCode) async {
  //   var paymentArgs = {"paymentMethod": "card", "token": tokenOpenPay, "deviceSessionId": deviceSessionID};
  //   var setPaymentResult = await PaymentServices.setPaymentMethodMonedero(paymentArgs, cartCode);
  //   if (setPaymentResult['accountHolderName'] != null) {
  //     _showDialogCard(titleError, bodyError);
  //   } else {
  //     _showDialogCard(titleError, bodyError);
  //   }
  //   print(setPaymentResult);
  // }

  String deviceSessionID;
  getDeviceID() {
    getID().then((message) {
      print("#############################");
      deviceSessionID = message.split('-')[1];
      print("#############################");
    });
  }

  getSaldo() async {
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
      //final translator = new GoogleTranslator();
      var saldoResult = await MonederoServices.getSaldoMonederoRCS(widget.monederoNumber ?? this.idMonedero);
      if (saldoResult != null && saldoResult["CodigoRes"] == "200" && saldoResult["DatosRCS"] != null) {
        prefs = await SharedPreferences.getInstance();
        //String message = await translator.translate(saldoResult["DatosRCS"]["Descripcion"], to: 'es');
        setState(() {
          saldo = double.parse(saldoResult["DatosRCS"]["Monto"]);
          monederoStatusCode = saldoResult["DatosRCS"]["Codigo"];
          monederoStatusDescription = saldoResult["DatosRCS"]["Descripcion"];
          prefs.setDouble('saldoMonedero', saldo);
          loadingDetailsMonedero = false;
        });
      } else {
        throw new Exception("Not a valid object");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String> getID() async {
    String value;
    const platform = const MethodChannel('com.cheadrui.com/paymethods');
    value = await platform.invokeMethod('getID');
    return value;
  }

  _changeFocus(BuildContext context, FocusNode focusNodeCurrent, FocusNode focusNodeNext) {
    if (focusNodeNext != null) {
      focusNodeCurrent.unfocus();
      focusNodeNext.requestFocus();
    } else {
      focusNodeCurrent.unfocus();
    }
  }

  Widget addNewCard(StateSetter updateState) {
    if (mounted) {
      numberController.addListener(() {
        String input = UtilsPayment.CardUtils.getCleanedNumber(numberController.text);
        UtilsPayment.CardType cardTypeCT = UtilsPayment.CardUtils.getCardTypeFrmNumber(input);
        String cartTypeS = UtilsCard.CardUtils.getCardTypeFrmNumber(input);
        updateState(() {
          _paymentCard.type = cardTypeCT;
          cardData.tipoTarjeta = cartTypeS;
        });
      });
    }
    return Container(
      child: Theme(
        data: ThemeData(
          primaryColor: Colors.transparent,
          hintColor: Colors.transparent, // primaryColor: HexColor('#C4CDD5'),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: HexColor('#DFE3E8'),
                  ),
                  Form(
                    autovalidate: false,
                    key: _formKey,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(bottom: 5, top: 15),
                                  child: Text(
                                    'Número de Tarjeta',
                                    style: TextStyle(color: HexColor('#212B36'), fontFamily: 'Archivo', fontSize: 12),
                                  ),
                                ),
                                SizedBox(
                                  height: 66,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                            prefixIcon: Padding(
                                              padding: EdgeInsets.only(left: 5, right: 5),
                                              child: UtilsPayment.CardUtils.getCardIcon(_paymentCard.type),
                                            ),
                                            hintText: '**** **** **** 1203',
                                            filled: true,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5.0),
                                            ),
                                            contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                                            fillColor: HexColor('#F4F6F8'),
                                          ),
                                          controller: numberController,
                                          keyboardType: TextInputType.number,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: [WhitelistingTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16), CardNumberInputFormatter()],
                                          focusNode: _focusForm['numeroTarjeta'],
                                          onFieldSubmitted: (String input) {
                                            _changeFocus(
                                              context,
                                              _focusForm['numeroTarjeta'],
                                              _focusForm['expiraTarjeta'],
                                            );
                                          },
                                          onSaved: (input) {
                                            _paymentCard.number = UtilsPayment.CardUtils.getCleanedNumber(input);
                                            cardData.numTarjeta = UtilsCard.CardUtils.getCleanedNumber(input);
                                          },
                                          validator: UtilsPayment.CardUtils.validateCardNum,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    flex: 3,
                                    child: Container(
                                      margin: EdgeInsets.only(right: 5),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(bottom: 5),
                                            child: Text(
                                              'Fecha de expiración',
                                              style: TextStyle(color: HexColor('#212B36'), fontFamily: 'Archivo', fontSize: 12),
                                            ),
                                          ),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              filled: true,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(5.0),
                                              ),
                                              contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                                              fillColor: HexColor('#F4F6F8'),
                                              hintText: '12 /21',
                                              hintStyle: TextStyle(color: HexColor('#212B36').withOpacity(0.3), fontFamily: 'Archivo', fontSize: 14),
                                            ),
                                            keyboardType: TextInputType.number,
                                            textInputAction: TextInputAction.next,
                                            inputFormatters: [WhitelistingTextInputFormatter.digitsOnly, new LengthLimitingTextInputFormatter(4), new CardMonthInputFormatter()],
                                            focusNode: _focusForm['expiraTarjeta'],
                                            onFieldSubmitted: (String input) {
                                              _changeFocus(
                                                context,
                                                _focusForm['expiraTarjeta'],
                                                _focusForm['cvvTarjeta'],
                                              );
                                            },
                                            onSaved: (input) {
                                              List<int> expiryDate = UtilsPayment.CardUtils.getExpiryDate(input);
                                              _paymentCard.month = expiryDate[0];
                                              _paymentCard.year = expiryDate[1];
                                              cardData.fecExpira = input;
                                            },
                                            validator: UtilsPayment.CardUtils.validateDate,
                                          ),
                                        ],
                                      ),
                                    )),
                                Expanded(
                                    flex: 3,
                                    child: Container(
                                      margin: EdgeInsets.only(left: 5),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(bottom: 5),
                                            child: Text(
                                              'CVV',
                                              style: TextStyle(color: HexColor('#212B36'), fontFamily: 'Archivo', fontSize: 12),
                                            ),
                                          ),
                                          TextFormField(
                                              decoration: InputDecoration(
                                                filled: true,
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                ),
                                                contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                                                fillColor: HexColor('#F4F6F8'),
                                                hintText: '354',
                                                hintStyle: TextStyle(color: HexColor('#212B36').withOpacity(0.3), fontFamily: 'Archivo', fontSize: 14),
                                              ),
                                              keyboardType: TextInputType.number,
                                              textInputAction: TextInputAction.next,
                                              inputFormatters: <TextInputFormatter>[
                                                _paymentCard.type == UtilsPayment.CardType.AmericanExpress ? LengthLimitingTextInputFormatter(4) : LengthLimitingTextInputFormatter(3),
                                                WhitelistingTextInputFormatter.digitsOnly,
                                              ],
                                              focusNode: _focusForm['cvvTarjeta'],
                                              onFieldSubmitted: (String input) {
                                                _changeFocus(
                                                  context,
                                                  _focusForm['cvvTarjeta'],
                                                  _focusForm['nombreTarjeta'],
                                                );
                                              },
                                              onSaved: (input) {
                                                _paymentCard.cvv = int.parse(input);
                                                cardData.cvv = input;
                                              },
                                              validator: _paymentCard.type == UtilsPayment.CardType.AmericanExpress ? UtilsPayment.CardUtils.validateCVVAmex : UtilsPayment.CardUtils.validateCVV),
                                        ],
                                      ),
                                    )),
                                Expanded(
                                    flex: 3,
                                    child: SizedBox(
                                        // width: 10,
                                        )),
                              ],
                            ),
                          ),
                          Container(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(bottom: 5),
                                child: Text(
                                  'Titular de la tarjeta',
                                  style: TextStyle(color: HexColor('#212B36'), fontFamily: 'Archivo', fontSize: 12),
                                ),
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                                  fillColor: HexColor('#F4F6F8'),
                                  hintText: 'Samuel Davis',
                                  hintStyle: TextStyle(color: HexColor('#212B36').withOpacity(0.3), fontFamily: 'Archivo', fontSize: 14),
                                ),
                                textInputAction: TextInputAction.next,
                                focusNode: _focusForm['nombreTarjeta'],
                                onFieldSubmitted: (String input) {
                                  _changeFocus(
                                    context,
                                    _focusForm['nombreTarjeta'],
                                    _focusForm['aliasTarjeta'],
                                  );
                                },
                                onSaved: (input) {
                                  _paymentCard.name = input;
                                  cardData.nomTitularTarj = input;
                                },
                                validator: FormsTextValidators.validateTextWithoutEmoji,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(100),
                                  WhitelistingTextInputFormatter(
                                    FormsTextValidators.commonPersonName,
                                  ),
                                ],
                              ),
                            ],
                          )),
                          Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(bottom: 5),
                                    child: Text(
                                      'Alias de la tarjeta',
                                      style: TextStyle(color: HexColor('#212B36'), fontFamily: 'Archivo', fontSize: 12),
                                    ),
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                      contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                                      fillColor: HexColor('#F4F6F8'),
                                      hintText: '“Compras frecuentes”',
                                      hintStyle: TextStyle(color: HexColor('#212B36').withOpacity(0.3), fontFamily: 'Archivo', fontSize: 14),
                                    ),
                                    textInputAction: TextInputAction.done,
                                    focusNode: _focusForm['aliasTarjeta'],
                                    onSaved: (input) {
                                      _changeFocus(context, _focusForm['nombreTarjeta'], null);
                                      cardData.aliasTarjeta = input;
                                    },
                                    validator: FormsTextValidators.validateTextWithoutEmoji,
                                  ),
                                ],
                              )),
                          Container(
                            margin: EdgeInsets.only(bottom: 15),
                            child: TermCondWidget(),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 0, right: 0, bottom: 15, top: 0),
                            padding: const EdgeInsets.only(left: 0, right: 0, bottom: 5, top: 0),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(),
                            child: enabledButtons
                                ? Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            flex: 1,
                                            child: RaisedButton(
                                                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                                                padding: EdgeInsets.all(15),
                                                color: DataUI.btnbuy,
                                                disabledColor: DataUI.btnbuy.withOpacity(0.5),
                                                child: Text(
                                                  'Agregar',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Archivo',
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                onPressed: enabledButtons
                                                    ? () {
                                                        //FocusScope.of(context).requestFocus(FocusNode());
                                                        addPaymentMethod(updateState);
                                                      }
                                                    : null),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 5),
                                              child: FlatButton(
                                                  disabledTextColor: DataUI.chedrauiBlueColor.withOpacity(0.5),
                                                  child: Text(
                                                    'Cancelar',
                                                    style: TextStyle(
                                                      fontFamily: 'Archivo',
                                                      fontSize: 14,
                                                      color: HexColor('#0D47A1'),
                                                    ),
                                                  ),
                                                  onPressed: enabledButtons
                                                      ? () {
                                                          updateToggle(updateState, !toggleView);
                                                        }
                                                      : null),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 5),
                                          child: LinearProgressIndicator(),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
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

  Future<void> rechargeMonederoModal(context) async {
    if (!(monederoStatusCode == "00" || monederoStatusCode == "K5")) {
      _showDialogCard("No es posible realizar la recarga", "Su monedero tiene un problema: \"$monederoStatusDescription\"");
      return;
    }
    setState(() {
      loadingCards = true;
      operationWasCanceled = false;
    });
    await this.getPreferences(null);
    setState(() {
      loadingCards = false;
    });
    var onClose = await showModalBottomSheet<dynamic>(
      isScrollControlled: true,
      context: context,
      isDismissible: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, state) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  if (isOpen) {
                    open(state, true);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(15, 15, 15, 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            toggleView ? 'Recargar monedero' : 'Agregar Tarjeta',
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
                    toggleView
                        ? ListTileTheme(
                            contentPadding: const EdgeInsets.all(0.0),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  height: 1,
                                  width: double.infinity,
                                  color: HexColor('#DFE3E8'),
                                ),
                                Container(
                                  margin: EdgeInsets.all(15),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        //margin: EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          "Monto a recargar",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontFamily: "Archivo",
                                            color: HexColor("#212B36"),
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 66,
                                        width: double.infinity,
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 4,
                                              child: Theme(
                                                data: ThemeData(
                                                  primaryColor: Colors.transparent,
                                                  hintColor: Colors.transparent,
                                                ),
                                                child: Form(
                                                    key: secondFormKey,
                                                    autovalidate: false,
                                                    child: Container(
                                                      margin: EdgeInsets.only(top: 6),
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
                                                          contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                                                          fillColor: HexColor('#F4F6F8'),
                                                        ),
                                                        keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
                                                        inputFormatters: [
                                                          WhitelistingTextInputFormatter.digitsOnly,
                                                        ],
                                                        validator: _validateMonto,
                                                        onFieldSubmitted: (input) {
                                                          if (secondFormKey.currentState.validate()) {
                                                            updateBtn(state, 'Editar');
                                                            updateTextField(state, !btnStatus);
                                                            // setState(() {
                                                            //   btnStatusString = 'Editar';
                                                            //   btnStatus = !btnStatus;
                                                            //   // _updateBalance();
                                                            // });
                                                          }
                                                          setState(() {
                                                            _valueMonto = input;
                                                          });
                                                        },
                                                        textInputAction: TextInputAction.done,
                                                      ),
                                                    )),
                                              ),
                                            ),
                                            // Expanded(
                                            //   flex: 1,
                                            //   child: SizedBox()
                                            // ),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                margin: EdgeInsets.only(left: 7, bottom: 16),
                                                child: FlatButton(
                                                  padding: EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 6),
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
                                                      if (secondFormKey.currentState.validate()) {
                                                        updateBtn(state, 'Editar');
                                                        updateTextField(state, !btnStatus);
                                                        // setState(() {
                                                        //   btnStatusString = 'Editar';
                                                        //   btnStatus = !btnStatus;
                                                        //   // _updateBalance();
                                                        // });
                                                      }
                                                    } else {
                                                      updateBtn(state, 'Confirmar');
                                                      updateTextField(state, !btnStatus);
                                                    }

                                                    //_updateBalance();
                                                  },
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                  height: 1,
                                  width: double.infinity,
                                  color: HexColor('#DFE3E8'),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 5, right: 15),
                                  child: RadioListTile<PaymentMethod>(
                                    activeColor: HexColor("#212B36"),
                                    secondary: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        VisaSVG(),
                                        MasterCardSVG(),
                                        AmexSVG(),
                                      ],
                                    ),
                                    selected: true,
                                    title: const Text(
                                      'Tarjeta de Crédito o Débito',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Archivo',
                                        letterSpacing: 0.25,
                                      ),
                                    ),
                                    value: PaymentMethod.card,
                                    groupValue: payMethod,
                                    onChanged: (PaymentMethod value) {
                                      updated(state, value);
                                      // setState(() {
                                      //   payMethod = value;
                                      //   print(payMethod);
                                      // });
                                    },
                                  ),
                                ),

                                payMethod != PaymentMethod.card
                                    ? SizedBox(
                                        height: 0,
                                      )
                                    : Column(
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.fromLTRB(62, 0, 15, 15),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  margin: EdgeInsets.only(bottom: 5),
                                                  child: Text(
                                                    "Selecciona una tarjeta",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      fontFamily: "Archivo",
                                                      color: HexColor("#212B36"),
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.normal,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: double.infinity,
                                                    child: Column(
                                                      children: <Widget>[
                                                        OverlayContainer(
                                                          show: isOpen,
                                                          asWideAsParent: true,
                                                          // Let's position this overlay to the right of the button.
                                                          position: OverlayContainerPosition(
                                                              // Left position.
                                                              0,
                                                              // Bottom position.
                                                              0),
                                                          // The content inside the overlay.
                                                          child: Container(
                                                            constraints: BoxConstraints(maxHeight: 150.0, maxWidth: 319.0, minWidth: 319.0, minHeight: 36.0),
                                                            padding: EdgeInsets.all(0),
                                                            margin: EdgeInsets.all(0),
                                                            // decoration: BoxDecoration(
                                                            //   borderRadius: BorderRadius.circular(5.0),
                                                            //   color: Colors.white,
                                                            //   boxShadow: <BoxShadow>[
                                                            //     BoxShadow(
                                                            //       color: Color(0xcc000000).withOpacity(0.2),
                                                            //       offset: Offset(0.0, 5.0),
                                                            //       blurRadius: 1.0,
                                                            //     ),
                                                            //   ],
                                                            // ),

                                                            child: ListView.separated(
                                                              padding: EdgeInsets.all(0),
                                                              physics: ClampingScrollPhysics(),
                                                              shrinkWrap: true,
                                                              scrollDirection: Axis.vertical,
                                                              separatorBuilder: (context, index) {
                                                                return Container(
                                                                  color: HexColor('#CFCFCF'),
                                                                  height: 1,
                                                                  width: double.infinity,
                                                                );
                                                              },
                                                              itemCount: tarjetasDropDown != null ? tarjetasDropDown.length : 0,
                                                              itemBuilder: (context, index) {
                                                                return CardItem(
                                                                  selectCard: (value) async {
                                                                    open(state, true);
                                                                    FocusScope.of(context).requestFocus(FocusNode());
                                                                    if (value == "NEW") {
                                                                      updateToggle(state, !toggleView);
                                                                      // var resultAddNewCard = await Navigator.push(
                                                                      //   context,
                                                                      //   MaterialPageRoute(
                                                                      //     builder: (context) => NewCreditCard(),
                                                                      //   ),
                                                                      // );
                                                                      // bool res = resultAddNewCard ?? false;
                                                                      // if (res) {
                                                                      //   updateCards(context);
                                                                      // }
                                                                    } else {
                                                                      updatedCard(state, value);
                                                                    }
                                                                  },
                                                                  numTarjeta: tarjetasDropDown[index].numTarjeta ?? '',
                                                                  tipoTarjeta: tarjetasDropDown[index].tipoTarjeta.toLowerCase() ?? '',
                                                                  selected: _value == tarjetasDropDown[index].identificador ? true : false,
                                                                  identificador: tarjetasDropDown[index].identificador ?? '',
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            _showCardSelected.numTarjeta != 'new' ? open(state, true) : updateToggle(state, !toggleView);
                                                          },
                                                          child: _showCardSelected.numTarjeta != 'new'
                                                              ? Container(
                                                                  decoration: BoxDecoration(color: HexColor('#F0EFF4'), borderRadius: BorderRadius.circular(5.0)),
                                                                  padding: EdgeInsets.all(10),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: <Widget>[
                                                                      Row(
                                                                        children: <Widget>[
                                                                          CardUtils.getCardIcon(() {
                                                                            switch (_showCardSelected.tipoTarjeta.toLowerCase()) {
                                                                              case "visa":
                                                                                return CardType.Visa;
                                                                                break;
                                                                              case "mastercard":
                                                                                return CardType.Master;
                                                                                break;
                                                                              case "american express":
                                                                                return CardType.AmericanExpress;
                                                                                break;
                                                                              default:
                                                                                return CardType.Others;
                                                                            }
                                                                          }()),
                                                                          Container(
                                                                            child: Text(
                                                                              "**** **** **** " + _showCardSelected.numTarjeta,
                                                                              style: TextStyle(
                                                                                fontFamily: 'Rubik',
                                                                                fontSize: 14,
                                                                                color: DataUI.chedrauiBlueColor,
                                                                              ),
                                                                            ),
                                                                            margin: EdgeInsets.only(left: 5),
                                                                          )
                                                                        ],
                                                                      ),
                                                                      Icon(Icons.keyboard_arrow_down)
                                                                    ],
                                                                  ),
                                                                )
                                                              : Container(
                                                                  decoration: BoxDecoration(color: HexColor('#F0EFF4'), borderRadius: BorderRadius.circular(5.0)),
                                                                  padding: EdgeInsets.all(10),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: <Widget>[
                                                                      Text(
                                                                        "+ Añadir tarjeta",
                                                                        style: TextStyle(
                                                                          fontFamily: 'Archivo',
                                                                          fontSize: 14,
                                                                          color: DataUI.chedrauiBlueColor,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                        )
                                                      ],
                                                    )),
                                              ],
                                            ),
                                          ),
                                          // Container(
                                          //   margin: EdgeInsets.symmetric(vertical: 20),
                                          //   child: TermCondWidget(),
                                          // ),
                                        ],
                                      ),

                                Container(
                                  height: 1,
                                  width: double.infinity,
                                  color: HexColor('#DFE3E8'),
                                  margin: EdgeInsets.only(bottom: 20),
                                ),
                                // RadioListTile<PaymentMethod>(
                                //   activeColor: HexColor("#212B36"),
                                //   title: Row(
                                //     mainAxisSize: MainAxisSize.min,
                                //     children: <Widget>[
                                //       PayPalSVG(25),
                                //     ],
                                //   ),
                                //   value: PaymentMethod.paypal,
                                //   groupValue: payMethod,
                                //   onChanged: (PaymentMethod value) {
                                //     updated(state, value);
                                //   },
                                // ),
                                // payMethod != PaymentMethod.paypal
                                //     ? SizedBox(
                                //         height: 0,
                                //       )
                                //     : Column(
                                //         children: <Widget>[
                                //           Container(
                                //             alignment: Alignment.centerLeft,
                                //             padding: const EdgeInsets.only(top: 15, bottom: 15),
                                //             child: Text(
                                //               'Realiza tu pedido con la seguridad, simplicidad y facilidad de PayPal.',
                                //               textAlign: TextAlign.left,
                                //               style: TextStyle(
                                //                 fontSize: 12,
                                //                 // color: HexColor("#637381"),
                                //               ),
                                //             ),
                                //           ),
                                //           Container(
                                //             margin: EdgeInsets.only(top: 0, bottom: 5),
                                //             alignment: Alignment.centerLeft,
                                //             padding: const EdgeInsets.only(left: 0),
                                //             child: Text(
                                //               "Monto a recargar",
                                //               textAlign: TextAlign.left,
                                //               style: TextStyle(
                                //                 fontFamily: "Rubik",
                                //                 color: HexColor("#454F5B"),
                                //                 fontSize: 12,
                                //                 fontWeight: FontWeight.normal,
                                //               ),
                                //             ),
                                //           ),
                                //           SizedBox(
                                //             width: double.infinity,
                                //             child: Container(
                                //               child: Theme(
                                //                 data: ThemeData(canvasColor: Colors.white),
                                //                 child: custom.DropdownButtonFormField(
                                //                   decoration: InputDecoration(
                                //                     contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                                //                     filled: true,
                                //                     fillColor: HexColor("#F4F6F8"),
                                //                     border: OutlineInputBorder(
                                //                       borderSide: BorderSide(
                                //                         color: HexColor("#C4CDD5").withOpacity(0.5),
                                //                       ),
                                //                     ),
                                //                   ),
                                //                   items: this.montosRecargaMonederoDropDown,
                                //                   onChanged: (value) {
                                //                     updatedMontoMonedero(state, value);
                                //                   },
                                //                   value: _valueMonto,
                                //                 ),
                                //               ),
                                //             ),
                                //           ),
                                //           Container(
                                //             width: double.infinity,
                                //             alignment: Alignment.center,
                                //             padding: const EdgeInsets.only(top: 15, left: 30, right: 30),
                                //             // child: PayPalPaySVG(34, 172),
                                //             child: Container(
                                //               width: double.infinity,
                                //               child: RaisedButton(
                                //                 shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                                //                 padding: EdgeInsets.all(15),
                                //                 color: HexColor('#F57C00'),
                                //                 onPressed: () async {
                                //                   FocusScope.of(context).requestFocus(new FocusNode());

                                //                   try {
                                //                     var montoSeleccionadoPaypal = this.montosData.firstWhere((t) => t['code'] == _valueMonto);

                                //                     this.payPalAmount = montoSeleccionadoPaypal['amount'];
                                //                     this.codeRecarga = montoSeleccionadoPaypal['code'];

                                //                     if (this.payPalAmount > 0) {
                                //                       // _showDialogPaypal("Ready");
                                //                       await getVista().then((message) {
                                //                         print(message);
                                //                       });
                                //                       Navigator.pop(context);
                                //                     } else {
                                //                       _showDialogPaypal("Por favor ingrese una cantidad mayor a 0");
                                //                     }
                                //                   } catch (e) {
                                //                     _showDialogPaypal("Por favor rellene este campo");
                                //                   }
                                //                 },
                                //                 child: Text(
                                //                   'Completar recarga',
                                //                   style: TextStyle(
                                //                     color: Colors.white,
                                //                   ),
                                //                 ),
                                //               ),
                                //             ),
                                //           ),
                                //           Container(
                                //             margin: EdgeInsets.only(top: 15),
                                //             child: InkWell(
                                //               child: Text(
                                //                 'Cancelar',
                                //                 style: TextStyle(fontSize: 16, color: HexColor('#0D47A1')),
                                //               ),
                                //               onTap: () {
                                //                 Navigator.pop(context);
                                //               },
                                //             ),
                                //           )
                                //         ],
                                //       ),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 15),
                                  width: double.infinity,
                                  child: loading
                                      ? Row(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 5),
                                                child: LinearProgressIndicator(),
                                              ),
                                            ),
                                          ],
                                        )
                                      : FlatButton(
                                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                                          padding: EdgeInsets.all(15),
                                          color: DataUI.btnbuy,
                                          child: Text(
                                            'Transferir fondos',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Archivo',
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                          disabledColor: DataUI.btnbuy.withOpacity(0.5),
                                          onPressed: _montoController.numberValue > 0 && btnStatusString == 'Editar' && !operationWasCanceled
                                              ? () async {
                                                  setState(() {
                                                    operationWasCanceled = false;
                                                  });
                                                  if (payMethod == PaymentMethod.card) {
                                                    print('_montoController.text');
                                                    print(_montoController.text);
                                                    if (_montoController.text.isNotEmpty && _montoController.numberValue > 0) {
                                                      updateLoader(state, true);
                                                      setState(() {
                                                        loading = true;
                                                      });
                                                      FocusScope.of(context).requestFocus(FocusNode());
                                                      var tarjetaSeleccionada = tarjetasData.firstWhere((t) => t['identificador'] == _value);
                                                      _cardSelected = tarjetaSeleccionada['numTarjeta'];
                                                      //var cardData = json.encode({"idWallet": _idWallet, "idTarjeta": tarjetaSeleccionada['identificador'], "puntos": false});
                                                      //print(cardData);

                                                      if (!operationWasCanceled) {
                                                        bool resultProcessCard = await getCVVRegistredCard();
                                                        print('resultProcessCard: $resultProcessCard');
                                                        print('messageErrorOpenPay: $messageErrorOpenPay');
                                                        print('operationWasCanceled: $operationWasCanceled');

                                                        if (!resultProcessCard) {
                                                          if (operationWasCanceled) {
                                                            setState(() {
                                                              operationWasCanceled = false;
                                                              titleError = "Error procesando el método de pago";
                                                              bodyError = 'Operación abortada por el usuario';
                                                            });
                                                            await updateLoader(state, false);
                                                            _showDialogCard(titleError, bodyError);
                                                            return;
                                                          } else if (messageErrorOpenPay != null) {
                                                            setState(() {
                                                              titleError = "Error procesando el método de pago";
                                                              bodyError = messageErrorOpenPay;
                                                            });
                                                            await updateLoader(state, false);
                                                            _showDialogCard(titleError, bodyError);
                                                            return;
                                                          } else {
                                                            operationWasCanceled = false;
                                                            await updateLoader(state, false);
                                                            return;
                                                          }
                                                        }
                                                      } else {
                                                        setState(() {
                                                          operationWasCanceled = false;
                                                          titleError = "Error procesando el método de pago";
                                                          bodyError = 'Operación abortada por el usuario';
                                                        });
                                                        await updateLoader(state, false);
                                                        _showDialogCard(titleError, bodyError);
                                                        return;
                                                      }

                                                      /*
                                                        String token;
                                                        var cardOpenPay = json.encode({
                                                          'tarjetas': [
                                                            {'idWallet': _idWallet, 'numTarjeta': tarjetaSeleccionada['identificador']}
                                                          ]
                                                        });
                                                        var cardToken = await PaymentServices.getTokenOpenPayCard(cardOpenPay);

                                                        token = cardToken['tokenTarjeta'].toString();
                                                        */
                                                      String token = tokenOpenPay;
                                                      /*
                                                        if (token == null || token == 'null') {
                                                          await PaymentServices.getTokenRegistredCard(cardData).then((onValue) {
                                                            setState(() {
                                                              token = onValue['token'];
                                                            });
                                                          });
                                                          print(token);
                                                          //token = await PaymentServices.getTokenRegistredCard(cardData);
                                                        }
                                                        */
                                                      if (token != null && token != 'null') {
                                                        tokenOpenPay = token;
                                                        String monederoNumber = widget.monederoNumber ?? this.idMonedero;
                                                        Map<String, dynamic> session = await CarritoServices.getSessionVars();
                                                        final bool isLoggedIn = session['isLoggedIn'];
                                                        final String guid = session['guid'];
                                                        final String userToken = session['accessToken'];
                                                        final String email = session['email'];
                                                        final String firstName = session['firstName'];
                                                        final String lastName = session['lastName'];
                                                        final String phone = session['phone'];
                                                        final oCcy = new NumberFormat("#,##0.00", "en_US");
                                                        String formatted = oCcy.format(_montoController.numberValue);
                                                        print(formatted); // something like 94,510.60
                                                        Map<String, dynamic> e = {
                                                          "monedero": monederoNumber,
                                                          "monto": _montoController.numberValue.toStringAsFixed(2),
                                                          "deviceSessionID": deviceSessionID,
                                                          "isTokenized": (_tipoTarjeta == 2),
                                                          "tokenTarjeta": tokenOpenPay,
                                                          "customerId": customerIdOpenPay,
                                                          "email": email,
                                                          "nombre": firstName,
                                                          "apellido": lastName,
                                                          "telefono": phone,
                                                        };

                                                        print('Datos de recarga ===> $e');
                                                        if (operationWasCanceled) {
                                                          setState(() {
                                                            loading = false;
                                                          });
                                                          _showDialogCard(titleError, bodyError);
                                                          updateLoader(state, false);
                                                        } else {
                                                          try {
                                                            var onValue = await PaymentServices.rechargeMonedero(e);
                                                            titleError = "Error";
                                                            bodyError = "Error al procesar recarga de monedero";
                                                            int statusCode = onValue['statusOperation']['code'];
                                                            if (statusCode == 0) {
                                                              print('done');
                                                              setState(() {
                                                                loading = false;
                                                              });
                                                              await updateLoader(state, false);
                                                              if ((widget.pagoDeServicios != null && widget.pagoDeServicios) || widget.pagodeServiciosFlatButton != null && widget.pagodeServiciosFlatButton) {
                                                                widget.updateSaldoPagoDeServicios();
                                                              } else {
                                                                await globalKeyMonederoBarCode.currentState.getSaldo();
                                                              }
                                                              await getSaldo();
                                                              Navigator.pop(context);
                                                              _showDialogCard(title, body);
                                                            } else if (statusCode == 1) {
                                                              titleError = "Error procesando el método de pago";
                                                              bodyError = await PaymentServices.getOpenpayErrorsList(onValue['openpayErrorCode']);
                                                              setState(() {
                                                                loading = false;
                                                              });
                                                              _showDialogCard(titleError, bodyError);
                                                              updateLoader(state, false);
                                                            } else if (operationWasCanceled) {
                                                              setState(() {
                                                                loading = false;
                                                              });
                                                              _showDialogCard(titleError, bodyError);
                                                              updateLoader(state, false);
                                                            } else {
                                                              titleError = "Error agregando fondos a su monedero.";
                                                              //bodyError = "Error en el servicio de recarga de monedero";
                                                              bodyError = onValue['statusOperation']['description'];
                                                              setState(() {
                                                                loading = false;
                                                              });
                                                              _showDialogCard(titleError, bodyError);
                                                              updateLoader(state, false);
                                                            }
                                                          } catch (onError) {
                                                            print(onError);
                                                            setState(() {
                                                              loading = false;
                                                              titleError = "Error";
                                                              bodyError = "Error en servicio de recarga de monedero. Intente más tarde.";
                                                            });
                                                            updateLoader(state, false);
                                                            _showDialogCard(titleError, bodyError);
                                                          }
                                                        }
                                                      } else {
                                                        setState(() {
                                                          loading = false;
                                                        });
                                                        updateLoader(state, false);
                                                        _showDialogCard(titleError, bodyError);
                                                      }
                                                    } else {
                                                      titleError = "Error";
                                                      bodyError = "Ingrese una cantidad mayor a 0";
                                                      setState(() {
                                                        loading = false;
                                                      });
                                                      updateLoader(state, false);
                                                      _showDialogCard(titleError, bodyError);
                                                    }
                                                  } else {
                                                    titleError = "Error";
                                                    bodyError = "Seleccione un método de pago válido";
                                                    setState(() {
                                                      loading = false;
                                                    });
                                                    updateLoader(state, false);
                                                    _showDialogCard(titleError, bodyError);
                                                  }
                                                }
                                              : null,
                                        ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 15, bottom: 15),
                                  child: InkWell(
                                    child: Text(
                                      'Cancelar',
                                      style: TextStyle(fontSize: 16, color: HexColor('#0D47A1')),
                                    ),
                                    onTap: () {
                                      updateLoader(state, false);
                                      setState(() {
                                        operationWasCanceled = true;
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                )
                              ],
                            ),
                          )
                        : addNewCard(state),
                  ],
                ),
              ),
            );
          },
        );
        // return Padding(
        //   padding: MediaQuery.of(context).viewInsets,
        //   child: Container(
        //     child: Wrap(
        //       children: <Widget>[

        //       ],
        //     ),
        //   ),
        // );
      },
    );
    if (onClose == null) {
      setState(() {
        operationWasCanceled = false;
        isOpen = false;
        payMethod = null;
        numberController.clear();
        _montoController.clear();
        btnStatus = true;
        btnStatusString = 'Confirmar';
        _montoController.updateValue(0);
        payMethod = PaymentMethod.card;
        _paymentCard.type = UtilsPayment.CardType.Others;
        cardData.tipoTarjeta = "";
        titleError = '';
        bodyError = '';
        tokenOpenPay = null;
        customerIdOpenPay = null;
      });
      // numberController.dispose();
      // setState(() {
      //   numberController = new TextEditingController();
      // });
    }
  }

  // void transferMonederoModal(context) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Theme(
  //         data: ThemeData(canvasColor: Colors.white),
  //         child: StatefulBuilder(
  //           builder: (context, state) {
  //             return ClipRRect(
  //               borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
  //               child: Container(
  //                 height: 346,
  //                 padding: EdgeInsets.only(top: 15, right: 15, left: 15),
  //                 color: Colors.white,
  //                 child: Form(
  //                   key: secondFormKey,
  //                   child: ListTileTheme(
  //                     contentPadding: const EdgeInsets.all(0.0),
  //                     child: Column(
  //                       children: <Widget>[
  //                         Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           mainAxisAlignment: MainAxisAlignment.start,
  //                           children: <Widget>[
  //                             Container(
  //                               margin: EdgeInsets.only(top: 15, bottom: 30),
  //                               child: Text(
  //                                 "Información de la transferencia",
  //                                 style: TextStyle(color: HexColor("#454F5B"), fontFamily: "Rubik", fontSize: 16),
  //                               ),
  //                             ),
  //                             Container(
  //                               margin: EdgeInsets.only(bottom: 5),
  //                               child: Text(
  //                                 "Número de Tarjeta",
  //                                 textAlign: TextAlign.left,
  //                                 style: TextStyle(
  //                                   fontFamily: "Rubik",
  //                                   color: HexColor("#454F5B"),
  //                                   fontSize: 12,
  //                                   fontWeight: FontWeight.normal,
  //                                 ),
  //                               ),
  //                             ),
  //                             SizedBox(
  //                               width: double.infinity,
  //                               child: Container(
  //                                 child: Theme(
  //                                   data: ThemeData(canvasColor: Colors.white),
  //                                   child: custom.DropdownButtonFormField(
  //                                     // height: 200.0,
  //                                     value: "**** **** **** 4242",
  //                                     decoration: InputDecoration(
  //                                       contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
  //                                       filled: true,
  //                                       fillColor: HexColor("#F4F6F8"),
  //                                       border: OutlineInputBorder(
  //                                         borderSide: BorderSide(
  //                                           color: HexColor("#C4CDD5").withOpacity(0.5),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                     items: [
  //                                       custom.DropdownMenuItem(
  //                                         child: Row(
  //                                           children: <Widget>[
  //                                             MonederoSVG(18, 18),
  //                                             Text("**** **** **** 4242"),
  //                                           ],
  //                                         ),
  //                                         value: "**** **** **** 4242",
  //                                       ),
  //                                     ],
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                             Container(
  //                               margin: EdgeInsets.only(top: 15, bottom: 5),
  //                               child: Text(
  //                                 "Monto a recargar",
  //                                 textAlign: TextAlign.left,
  //                                 style: TextStyle(
  //                                   fontFamily: "Rubik",
  //                                   color: HexColor("#454F5B"),
  //                                   fontSize: 12,
  //                                   fontWeight: FontWeight.normal,
  //                                 ),
  //                               ),
  //                             ),
  //                             Theme(
  //                               data: ThemeData(canvasColor: Colors.white),
  //                               child: custom.DropdownButtonFormField(
  //                                 // height: 200.0,
  //                                 value: "**** **** **** 4242",
  //                                 decoration: InputDecoration(
  //                                   contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
  //                                   filled: true,
  //                                   fillColor: HexColor("#F4F6F8"),
  //                                   border: OutlineInputBorder(
  //                                     borderSide: BorderSide(
  //                                       color: HexColor("#C4CDD5").withOpacity(0.5),
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 items: [
  //                                   custom.DropdownMenuItem(
  //                                     child: Text("**** **** **** 4242"),
  //                                     value: "**** **** **** 4242",
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget build(BuildContext context) {
    return widget.pagodeServiciosFlatButton != null && widget.pagodeServiciosFlatButton
        ? OutlineButton(
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
            padding: EdgeInsets.all(15),
            borderSide: BorderSide(
              color: DataUI.chedrauiBlueColor,
              style: BorderStyle.solid, //Style of the border
              width: 2.0, //width of the border
            ),
            child: !loadingCards
                ? Text(
                    'Recarga tu monedero',
                    style: TextStyle(color: DataUI.chedrauiBlueColor, fontSize: 14.0),
                  )
                : CircularProgressIndicator(),
            onPressed: !loadingCards
                ? () {
                    rechargeMonederoModal(context);
                  }
                : null,
          )
        : widget.pagoDeServicios != null && widget.pagoDeServicios
            ? Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Saldo disponible',
                          style: TextStyle(fontSize: 16, color: HexColor('#0D47A1'), fontFamily: 'Archivo', letterSpacing: 0.5, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: loadingCards
                              ? null
                              : () {
                                  rechargeMonederoModal(context);
                                },
                          child: loadingCards
                              ? SizedBox(
                                  height: 8,
                                  width: 8,
                                  child: CircularProgressIndicator(),
                                )
                              : Text(
                                  'Recargar',
                                  style: TextStyle(fontSize: 14, color: HexColor('#0D47A1'), fontFamily: 'Archivo', letterSpacing: 0.25),
                                ),
                        ),
                        // MonederoOptions(idMonedero: _monederoNumber, pagoDeServicios: true,),
                      ],
                    ),
                  ),
                  Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 15),
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
                              widget.monederoNumber != null ? '**** ' + widget.monederoNumber.substring(12, 16) : ' ',
                              style: TextStyle(fontSize: 14, color: HexColor('#0D47A1'), fontFamily: 'Rubik'),
                            ),
                          ],
                        ),
                        Text(
                          saldo != null ? moneda.format(saldo) : moneda.format(widget.saldoMonedero),
                          style: TextStyle(fontSize: 14, color: widget.saldoSuficiente ? HexColor('#0D47A1') : Colors.red, fontFamily: 'Rubik'),
                        ),
                      ],
                    ),
                  )
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    MonederoBardCode(
                      idMonedero: this.idMonedero,
                      key: globalKeyMonederoBarCode,
                    ),
                    // Container(
                    //   padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     mainAxisSize: MainAxisSize.max,
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     children: <Widget>[
                    //       Icon(
                    //         Icons.credit_card,
                    //         color: HexColor("#919EAB"),
                    //       ),
                    //       Container(
                    //         margin: EdgeInsets.only(right: 90),
                    //         child: Text(
                    //           "Monedero Principal",
                    //           style: TextStyle(
                    //             fontFamily: "Rubik",
                    //             fontSize: 14,
                    //             fontWeight: FontWeight.normal,
                    //           ),
                    //         ),
                    //       ),
                    //       Switch(value: _value1, onChanged: _onChanged1)
                    //     ],
                    //   ),
                    // ),
                    Container(
                      padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(vertical: 20),
                        child: loadingCards
                            ? Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: LinearProgressIndicator(),
                                    ),
                                  ),
                                ],
                              )
                            : RaisedButton(
                                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                                color: HexColor("#F57C00"),
                                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                onPressed: loadingDetailsMonedero
                                    ? null
                                    : () {
                                        rechargeMonederoModal(context);
                                      },
                                child: Text(
                                  'Recargar Monedero',
                                  style: TextStyle(
                                    color: HexColor("#F9FAFB"),
                                    fontFamily: "Achivo",
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    // Container(
                    //   padding: EdgeInsets.all(15),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     mainAxisSize: MainAxisSize.max,
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     children: <Widget>[
                    //       RotatedBox(
                    //         quarterTurns: 1,
                    //         child: Icon(
                    //           Icons.import_export,
                    //           color: HexColor("#919EAB"),
                    //         ),
                    //       ),
                    //       Container(
                    //         margin: EdgeInsets.only(right: 193),
                    //         child: InkWell(
                    //           onTap: () {
                    //             transferMonederoModal(context);
                    //           },
                    //           child: Text(
                    //             "Transferir Balance",
                    //             style: TextStyle(
                    //               fontFamily: "Rubik",
                    //               fontSize: 14,
                    //               letterSpacing: 0.1,
                    //               color: HexColor("#0D47A1"),
                    //               fontWeight: FontWeight.normal,
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Divider(
                    //   height: 1,
                    // ),
                    // Container(
                    //   padding: EdgeInsets.all(15),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     mainAxisSize: MainAxisSize.max,
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     children: <Widget>[
                    //       RotatedBox(
                    //         quarterTurns: 1,
                    //         child: Icon(
                    //           Icons.remove_circle_outline,
                    //           color: HexColor("#919EAB"),
                    //         ),
                    //       ),
                    //       Container(
                    //         margin: EdgeInsets.only(right: 190),
                    //         child: InkWell(
                    //           onTap: () {
                    //             print("object");
                    //           },
                    //           child: Text(
                    //             "Eliminar Monedero",
                    //             style: TextStyle(
                    //               fontFamily: "Rubik",
                    //               fontSize: 14,
                    //               letterSpacing: 0.1,
                    //               color: HexColor("#0D47A1"),
                    //               fontWeight: FontWeight.normal,
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              );
  }

  Future<bool> getTokenCustomerRegisterCard() async {
    const platform = const MethodChannel('com.cheadrui.com/decypher');

    var cardData = json.encode({
      'tarjetas': [
        {'idWallet': _idWallet, 'numTarjeta': tarjetasRaw[_selectedRegistredCard]['identificador']}
      ]
    });
    var tarjeta = await BovedaService.getTarjeta(cardData);

    var tokenTarjeta = tarjeta['tokenTarjeta'] != null ? await platform.invokeMethod('decypher', {"text": tarjeta['tokenTarjeta']}) : null;
    var customerId = tarjeta['customerId'] != null ? await platform.invokeMethod('decypher', {"text": tarjeta['customerId']}) : null;

    if (tokenTarjeta != null && tokenTarjeta != "NA" && customerId != null) {
      _tipoTarjeta = 2;
      tokenOpenPay = tokenTarjeta;
      customerIdOpenPay = customerId;
    } else {
      _tipoTarjeta = 1;
      customerIdOpenPay = null;
    }

    return true;
  }

  Future<bool> getOpenPayTokenRegisterCard() async {
    try {
      const platform = const MethodChannel('com.cheadrui.com/decypher');

      var cardData = json.encode({
        'tarjetas': [
          {'idWallet': _idWallet, 'numTarjeta': tarjetasRaw[_selectedRegistredCard]['identificador']}
        ]
      });
      var tarjeta = await BovedaService.getTarjetaForOpenPay(cardData);

      var numTarjeta = await platform.invokeMethod('decypher', {"text": tarjeta['numTarjeta']});
      var nombreTitular = await platform.invokeMethod('decypher', {"text": tarjeta['nomTitularTarj']});
      var fechaExp = await platform.invokeMethod('decypher', {"text": tarjeta['fecExpira']});
      var arrfecha = fechaExp.split("/");
      var cvv = _cvv;

      var newCardData = json.encode({"card_number": numTarjeta, "holder_name": nombreTitular, "expiration_year": arrfecha[1], "expiration_month": arrfecha[0], "cvv2": cvv});
      print('newCardData');
      print(newCardData);
      var resultToken = await PaymentServices.getTokenFromOpenPay(newCardData);
      if (resultToken != null && resultToken['id'] != null) {
        tokenOpenPay = resultToken['id'];
        return true;
      } else {
        String errorCode = resultToken['error_code'].toString() ?? "1000";
        String errorMessage = await PaymentServices.getOpenpayErrorsList(errorCode);
        messageErrorOpenPay = errorMessage;
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> setRegistredCardData() async {
    bool tokenAvailable;
    await getTokenCustomerRegisterCard();
    print('_tipoTarjeta');
    print(_tipoTarjeta);

    if (_tipoTarjeta == 1) {
      tokenAvailable = await getOpenPayTokenRegisterCard();
      /*
      if(tokenAvailable){
        await getPointsFromSelectedCard();
      }
      */
    } else if (_tipoTarjeta == 2) {
      tokenAvailable = await PaymentServices.updateCvv2OnOpenpay(tokenOpenPay, customerIdOpenPay, _cvv);
      ;
      //await getPointsFromSelectedCardTokenizada();
    }

    print('tokenOpenPay');
    print(tokenOpenPay);

    return tokenAvailable;
  }

  Future<bool> getCVVRegistredCard() async {
    print('getCVVRegistredCard');
    bool resultOpenPay = false;
    var cardData = json.encode({
      'tarjetas': [
        {'idWallet': _idWallet, 'numTarjeta': tarjetasRaw[_selectedRegistredCard]['identificador']}
      ]
    });

    print('cardData');
    print(cardData);

    var tarjeta = await BovedaService.getTarjeta(cardData);

    const platform = const MethodChannel('com.cheadrui.com/decypher');

    var numTarjeta = await platform.invokeMethod('decypher', {"text": tarjeta['numTarjeta']});

    if (operationWasCanceled) {
      return false;
    }

    var resultCVVDialog = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          _cvv = "";
          _validateCvv = false;
          return AlertDialog(
            title: Text("Ingresa el cvv de tu tarjeta"),
            content: new TextField(
              decoration: new InputDecoration(labelText: "**** **** **** " + numTarjeta, errorText: _validateCvv ? 'Debe ingresar un valor' : null),
              keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
              maxLength: 4,
              onChanged: (String input) {
                try {
                  _cvv = input;
                } catch (e) {
                  _cvv = "";
                }
              },
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  setState(() {
                    loading = false;
                    operationWasCanceled = true;
                  });
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancelar",
                  style: TextStyle(
                    color: DataUI.chedrauiBlueColor,
                    fontSize: 16,
                  ),
                ),
              ),
              FlatButton(
                onPressed: () async {
                  print('cvv: $_cvv');
                  if (_cvv.trim().length > 2) {
                    setState(() {
                      _validateCvv = false;
                    });
                    Navigator.pop(context, _cvv);
                    //await registredCardData();
                  } else {
                    setState(() {
                      _validateCvv = true;
                    });
                  }
                },
                child: Text(
                  "Aceptar",
                  style: TextStyle(
                    color: DataUI.chedrauiBlueColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        });
    if (resultCVVDialog != null) {
      resultOpenPay = await setRegistredCardData();
    }
    return resultOpenPay;
  }
}
