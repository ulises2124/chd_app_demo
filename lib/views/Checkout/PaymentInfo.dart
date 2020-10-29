import 'dart:convert';

import 'package:chd_app_demo/services/AuthServices.dart';
import 'package:chd_app_demo/services/CarritoServices.dart';
import 'package:chd_app_demo/services/MediosPagoService.dart';
import 'package:chd_app_demo/services/MonederoServices.dart';
import 'package:chd_app_demo/services/PaymentServices.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/utils/NetworkData.dart';
import 'package:chd_app_demo/utils/input_formatters.dart';
import 'package:chd_app_demo/utils/payment_card.dart';
import 'package:chd_app_demo/views/Checkout/CheckoutConfirmationPage.dart';
import 'package:chd_app_demo/views/Checkout/CheckoutPage.dart';
import 'package:chd_app_demo/views/Checkout/ConsigmentWidget.dart';
import 'package:chd_app_demo/views/Checkout/Consignment.dart';
import 'package:chd_app_demo/views/Checkout/OnDeliverOptionItemWidget.dart';
import 'package:chd_app_demo/views/Checkout/PaymentMethod.dart';
import 'package:chd_app_demo/views/Checkout/PaypalPage.dart';
import 'package:chd_app_demo/views/Checkout/PersonalInfo.dart';
import 'package:chd_app_demo/views/Checkout/TextInputsFormatters.dart';
//import 'package:chd_app_demo/views/LoginPage/LoginPage.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:chd_app_demo/widgets/deliveryInformation.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chd_app_demo/utils/singinUserData.dart';

class PaymentInfo extends StatefulWidget {
  PaymentInfo({Key key}) : super(key: key);

  _PaymentInfoState createState() => _PaymentInfoState();
}

class _PaymentInfoState extends State<PaymentInfo> {
  bool paymentInfoSave = false;

  PaymentMethod payMethod = PaymentMethod.card;
  var numberController = new TextEditingController();
  var _paymentCard = PaymentCard();
  var _card = new PaymentCard();
  bool _autoValidateFirstForm = false;
  bool _autoValidateSecondtForm = false;
  List installmentList = [];
  List installmentPromoids = [];
  List installmentNames = [];
  int _selectedOnDeliverPayMethod = 0;
  // int _selectedAssociatedStore = 4;
  String paymethodOnDelivery;
  int itemsCount;
  String cardN, cardNombre, cardFecha;
  String idWallet;
  int msiSelected;
  bool loadingOrder = false;
  PaymentIformationData paymentData = new PaymentIformationData();

  final _formKey2 = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();

  ScrollController _scrollController = new ScrollController();
  static var now = DateTime.now();
  static List<DateTime> todays = [
    now,
    DateTime(now.year, now.month, now.day + 1),
    DateTime(now.year, now.month, now.day + 2),
  ];

  List<String> deliveryDays = [
    DateFormat("MMMM d").format(todays[0]).toString(),
    DateFormat("MMMM d").format(todays[1]).toString(),
    DateFormat("MMMM d").format(todays[2]).toString(),
  ];
  bool notNull(Object o) => o != null;
  List<String> deliveryHours = [
    '8am - 10am',
    '10am - 12pm',
    '12pm - 2pm',
    '2pm - 4pm',
    '4pm - 6pm',
    '6pm - 8pm',
    '8pm - 10pm',
  ];

  List<DeliveryStore> tiendasEntrega = [];

  List establecimientosAsociados;

  List<PayPalProduct> listPayPalProduct = new List<PayPalProduct>();

  final webview = FlutterWebviewPlugin();

  String currentType;

  var slotsEntrega = null; // Slots de entrega para crear slots de tiempo
  var _slotsEntrega = null; // Slots de entrega para crear puntos de envio
  var _currentCart = null; // Información de carrito para crear puntos de envio

  List _consignmentsList = [];

  NumberFormat moneda =
      new NumberFormat.currency(locale: 'es_MX', symbol: "\$");

  String tokenOpenPay;
  bool hasPromotions = false;
  bool loadingInstallments = false;

  getTimeSlots() async {
    var resultTimeslots = await CarritoServices.getCurrentCartTimeSlots();
    setState(() {
      _slotsEntrega = resultTimeslots;
    });
    var resultCarrito = await CarritoServices.getCart();
    setState(() {
      _currentCart = resultCarrito;
      itemsCount = resultCarrito['entries'].length;
      cartCode = resultCarrito['code'];
      total = resultCarrito['totalPrice']['value'];
    });
    var stores =
        await PaymentServices.getAssociatedStores(resultCarrito['code']);
    setState(() {
      establecimientosAsociados = stores;
    });
  }

  final couponTextfieldController = TextEditingController();
  String _couponToValidate = '';
  bool _couponValid;
  var _couponResultColor;
  String _couponResultText = '';

  // List<Widget> onDeliveryPaymentMethod = [
  //   CardVisa(59, 109, false),
  //   CardMasterCard(59, 109, false),
  //   CardAmex(59, 109, false),
  //   CardCash(59, 109, false),
  //   CardEcoupon(59, 109, false),
  // ];

  // List<String> associatedStores = [
  //   'Waldos',
  //   'Keymart',
  //   '7 Eleven',
  //   'Farmacias Benavides',
  //   'Extra',
  //   'Farmacia Guadalajara',
  //   'Farmacias del Ahorro',
  // ];

  bool deliveryMethod = true;
  String paymentStatus;

  dynamic cartCode;
  dynamic total;
  dynamic subTotal;
  dynamic deliveryCost;
  dynamic totalDiscounts;

  String shippingAddress;

  int currStep = 0;

  List<dynamic> paymentMethods;

  bool _isButtonDisabled = true;
  bool card = false;
  bool payPayPal = false;
  bool payOnDelivery = false;
  bool payInStore = false;
  bool payInAssociatedStore = false;
  bool monedero = false;

  List<dynamic> payOnDeliveryMethods;
  bool cash = true;
  bool visaMastercard = false;
  bool visa = false;
  bool masterCard = false;
  bool amex = false;
  bool vales = false;

  Future getPaymentsMethod() async {
    PaymentServices.getPayments().then((response) {
      print(response);
      setState(() {
        paymentMethods = response['paymentMethods'];
        Future.forEach(paymentMethods, (method) {
          switch (method) {
            case 'CARD':
              card = true;
              break;
            case 'PAYPAL':
              payPayPal = true;
              break;
            case 'PAYONDELIVERY':
              payOnDelivery = true;
              break;
            case 'PAYINSTORE':
              payInStore = true;
              break;
            case 'PAYINASSOCIATEDSTORE':
              payInAssociatedStore = true;
              break;
            case 'MONEDERO':
              monedero = true;
              break;
            default:
          }
        });
        if (response['payOnDeliveryPaymentTypes'] != null) {
          payOnDeliveryMethods = response['payOnDeliveryPaymentTypes'];
          Future.forEach(payOnDeliveryMethods, (method) {
            switch (method) {
              case 'CASH':
                cash = true;
                break;
              case 'VISAMASTERCARD':
                visaMastercard = true;
                break;
              case 'VISA':
                visa = true;
                break;
              case 'MASTERCARD':
                masterCard = true;
                break;
              case 'AMEX':
                amex = true;
                break;
              case 'VALES':
                vales = true;
                break;
              default:
            }
          });
        }
      });
    });
  }

  static const platform = const MethodChannel('com.cheadrui.com/paymethods');

  generarVista() async {
    var value1 = _slotsEntrega;
    var value2 = _currentCart;

    if (value2['deliveryCost'] != null) {
      deliveryCost = value2['deliveryCost']['value'];
    }
    if (value2['totalDiscounts'] != null) {
      totalDiscounts = value2['totalDiscounts']['value'];
    }
    if (value2['totalPrice']['value'] != null) {
      subTotal = value2['totalPrice']['value'];
    }
    if (value2['totalPriceWithTax']['value'] != null) {
      total = value2['totalPriceWithTax']['value'];
    }
    if (value2['code'] != null) {
      cartCode = value2['code'];
    }

    for (var slot in value1['slots']) {
      for (var consignment in value2['consignments']) {
        if (consignment['code'] == slot['consignmentCode']) {
          List entries = consignment['entries'];
          int quantity = 0;

          for (var entry in entries) {
            quantity++;
            double number =
                double.parse(entry['orderEntry']['decimalQty'].toString());
            String nombreProducto =
                entry['orderEntry']['product']['name'].toString();
            double totalPrice = double.parse(
                entry['orderEntry']['totalPrice']['value'].toString());
            String code =
                entry['orderEntry']['product']['unit']['code'].toString();

            double pricePerUnit = totalPrice / number.round();

            String descriptor = "";
            if (code == 'PCE') {
              descriptor =
                  '${number.round()} × ${moneda.format(pricePerUnit)}}';
            } else {
              pricePerUnit = double.parse(
                      entry['orderEntry']['totalPrice']['value'].toString()) /
                  number;
              pricePerUnit = double.parse(pricePerUnit.toStringAsFixed(2));
              descriptor =
                  '${number.toString()} kg × ${moneda.format(pricePerUnit)} / kg';
            }

            PayPalProduct payPalProduct = new PayPalProduct();
            payPalProduct
                .setSku(entry['orderEntry']['product']['code'].toString());
            payPalProduct.setName(nombreProducto);
            payPalProduct.setDescription(nombreProducto);
            payPalProduct.setQuantity(number.round());
            payPalProduct.setPrice(pricePerUnit);

            listPayPalProduct.add(payPalProduct);
          }
        }
      }
    }

    getVista().then((message) {
      print(message);
    });
  }

  Future<String> getVista() async {
    String value;
    double costoEnvio = 0;

    String mode = NetworkData.paypalMode;
    String transactionDescription = "Descripcion de la transaccion";
    String intent = "sale";
    double discount = (this.totalDiscounts == null) ? 0 : this.totalDiscounts;
    double shipping = costoEnvio;
    double subtotal = (this.subTotal == null) ? 0 : this.subTotal - costoEnvio;
    double tax = (((this.total == null) ? 0 : this.total) -
        ((this.subTotal == null) ? 0 : this.subTotal));
    double total = (this.total == null) ? 0 : this.total;

    List<dynamic> items = new List<dynamic>();

    for (PayPalProduct elem in listPayPalProduct) {
      items.add(elem.toJson());
    }

    print(items);

    var medioPagoResponse = await MediosPagoService.payment_with_paypal(
        mode,
        transactionDescription,
        intent,
        items,
        discount,
        shipping,
        subtotal,
        tax,
        total);

    print(medioPagoResponse);

    if (medioPagoResponse != null) {
      if (medioPagoResponse["statusOperation"]["code"] == 0) {
        String paypalUrl = medioPagoResponse["data"]["url"];

        /*final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String user = prefs.getString('email');*/

        /*value = await platform.invokeMethod(
            'getVista', {"paypalUrl": paypalUrl, "paymentMethod": paymentMethod, "amount": total, "email": user});*/

        webview.launch(paypalUrl, withJavascript: true);

        // Add a listener to on url changed
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
    } else if (url.contains("confirmar_pago")) {
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

  cancel() async {
    webview.close();
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

  Future<Map<String, dynamic>> getParametersFromUrl(String url) async {
    Map<String, dynamic> paramValues = new Map<String, dynamic>();

    if (url == "about:blank") {
      print("Proceso terminado ir a la siguiente pantalla");
    } else if (url.contains("payerID") ||
        url.contains("token") && url.contains("email")) {
      var urlSeparated = url.split("?");
      print(urlSeparated);
      var params = urlSeparated[1].split("&");

      paramValues.putIfAbsent("paymentMethod", () => "PAYPAL");
      paramValues.putIfAbsent("amount", () => total);

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

  finalizaActividad(Map<String, dynamic> authParams) async {
    print("entro finalizaActividad()");

    var setPaymentResult =
        await PaymentServices.setPaymentMethod(authParams, cartCode);
    print(setPaymentResult);

    //var orderData = await PaymentServices.placeOrder(cartCode);
    var orderData = await MediosPagoService.placeOrder(cartCode);
    print("=================> orderData: $orderData");

    this.webview.close();
    print("despues close()");

    if (orderData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: DataUI.checkoutConfirmationRoute),
          builder: (context) => CheckoutConfirmationPage(
              paymentMethod: PaymentMethod.paypal,
              orderData: orderData,
              shippingData: tiendasEntrega,
              shippingDatetime: getSlotsToSave(),
              additionalData: null),
        ),
      );
    } else {
      _showResponseDialog("Error al procesar el pago");
    }
  }

  String deviceSessionID;
  getDeviceID() {
    getID().then((message) {
      print("#############################");
      deviceSessionID = message.split('-')[1];
      print("#############################");
    });
  }

  Future<String> getID() async {
    String value;
    value = await platform.invokeMethod('getID');
    return value;
  }

  void _getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(numberController.text);
    CardType cardType = CardUtils.getCardTypeFrmNumber(input);
    setState(() {
      this._paymentCard.type = cardType;
    });
  }

  Future<void> getMonedero() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final idWalletPrefs = prefs.getString('idWallet');
    idWallet = idWalletPrefs;
    if (idWallet != null) {
      String idMonedero = await MonederoServices.getIdMonedero(idWallet);
      num saldoMonedero = await MonederoServices.getSaldoMonedero(idMonedero);
    }
  }

  initState() {
    _paymentCard.type = CardType.Others;
    numberController.addListener(_getCardTypeFrmNumber);
    _isButtonDisabled = true;
    getMonedero();
    getDeviceID();
    getTimeSlots();
    getPaymentsMethod();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        paymentMethods != null
            ? SizedBox(
                height: 50,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Container(
                margin: EdgeInsets.all(15),
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Color(0xcc000000).withOpacity(0.1),
                      offset: Offset(0.0, 5.0),
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: paymentInfoSave
                    ? Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Text(
                                '2 Información de pago',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: HexColor("#212B36"),
                                ),
                              ),
                            ),
                          ),
                          Form(
                            autovalidate: _autoValidateSecondtForm,
                            key: _formKey,
                            child: ListTileTheme(
                              contentPadding: const EdgeInsets.all(0.0),
                              child: Column(
                                children: <Widget>[
                                  card == false
                                      ? SizedBox(
                                          height: 0,
                                        )
                                      : RadioListTile<PaymentMethod>(
                                          activeColor: HexColor("#0D47A1"),
                                          secondary: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              VisaSVG(),
                                              MasterCardSVG(),
                                              AmexSVG(),
                                            ],
                                          ),
                                          title: const Text(
                                            'Tarjeta de Crédito o Débito',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          value: PaymentMethod.card,
                                          groupValue: payMethod,
                                          onChanged: (PaymentMethod value) {
                                            setState(() {
                                              payMethod = value;
                                            });
                                          },
                                        ),
                                  payMethod != PaymentMethod.card
                                      ? SizedBox(
                                          height: 0,
                                        )
                                      : Theme(
                                          data: ThemeData(
                                            primaryColor: Colors.black,
                                            hintColor: HexColor('#C4CDD5'),
                                          ),
                                          child: Column(
                                            children: <Widget>[
                                              Container(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    '* Campos requeridos',
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color:
                                                          HexColor("#637381"),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                // margin: const EdgeInsets.all(15.0),
                                                // padding: const EdgeInsets.all(3.0),
                                                decoration: new BoxDecoration(
                                                  border: new Border.all(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                  ),
                                                ),
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      flex: 6,
                                                      child: TextFormField(
                                                        decoration:
                                                            InputDecoration(
                                                          icon: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 5),
                                                            child: CardUtils
                                                                .getCardIcon(
                                                                    _paymentCard
                                                                        .type),
                                                          ),
                                                          // border:
                                                          //     OutlineInputBorder(),
                                                          contentPadding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 12,
                                                                  bottom: 12,
                                                                  left:
                                                                      0, //todo
                                                                  right:
                                                                      6 //todo
                                                                  ),
                                                          hintText:
                                                              '* Número de Tarjeta',
                                                          hintStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        controller:
                                                            numberController,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        inputFormatters: [
                                                          WhitelistingTextInputFormatter
                                                              .digitsOnly,
                                                          new LengthLimitingTextInputFormatter(
                                                              16),
                                                          new CardNumberInputFormatter()
                                                        ],
                                                        onSaved: (input) {
                                                          paymentData
                                                                  .cardNumber =
                                                              input;
                                                          _paymentCard.number =
                                                              CardUtils
                                                                  .getCleanedNumber(
                                                                      input);
                                                          print(input);
                                                        },
                                                        validator: CardUtils
                                                            .validateCardNum,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: TextFormField(
                                                        decoration:
                                                            InputDecoration(
                                                          // border:
                                                          //     OutlineInputBorder(),
                                                          contentPadding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 12,
                                                                  bottom: 12,
                                                                  left:
                                                                      6, //todo
                                                                  right:
                                                                      6 //todo
                                                                  ),
                                                          hintText: '* CVV',
                                                          hintStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        keyboardType:
                                                            TextInputType.phone,
                                                        // maxLength: 3,
                                                        inputFormatters: <
                                                            TextInputFormatter>[
                                                          _paymentCard.type ==
                                                                  CardType
                                                                      .AmericanExpress
                                                              ? LengthLimitingTextInputFormatter(
                                                                  4)
                                                              : LengthLimitingTextInputFormatter(
                                                                  3),
                                                          WhitelistingTextInputFormatter
                                                              .digitsOnly,
                                                        ],
                                                        onSaved: (input) {
                                                          paymentData
                                                                  .cardSecurity =
                                                              input;
                                                        },
                                                        validator:
                                                            _validateNotEmpty,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: TextFormField(
                                                        decoration:
                                                            InputDecoration(
                                                          // border:
                                                          //     OutlineInputBorder(),
                                                          contentPadding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 12,
                                                                  bottom: 12,
                                                                  left:
                                                                      6, //todo
                                                                  right:
                                                                      6 //todo
                                                                  ),
                                                          hintText: '* MM/AA',
                                                          hintStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        keyboardType:
                                                            TextInputType.phone,
                                                        inputFormatters: [
                                                          WhitelistingTextInputFormatter
                                                              .digitsOnly,
                                                          new LengthLimitingTextInputFormatter(
                                                              4),
                                                          new CardMonthInputFormatter()
                                                        ],
                                                        onSaved: (input) {
                                                          List<int> expiryDate =
                                                              CardUtils
                                                                  .getExpiryDate(
                                                                      input);
                                                          paymentData
                                                                  .cardMonth =
                                                              expiryDate[0]
                                                                  .toString();
                                                          paymentData.cardYear =
                                                              expiryDate[1]
                                                                  .toString();
                                                        },
                                                        validator: CardUtils
                                                            .validateDate,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: 8, bottom: 8),
                                                child: TextFormField(
                                                  decoration: InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                            top: 12,
                                                            bottom: 12,
                                                            left: 6, //todo
                                                            right: 6 //todo
                                                            ),
                                                    hintText:
                                                        '* Nombre del Tarjeta habiente',
                                                    hintStyle: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  onSaved: (input) {
                                                    paymentData.cardName =
                                                        input;
                                                  },
                                                  validator: _validateNotEmpty,
                                                ),
                                              ),
                                              Column(
                                                children: <Widget>[
                                                  /*
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                                child: Text(
                                                  'Paga con Puntos',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: HexColor("#637381"),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 6,
                                                  child: TextFormField(
                                                    decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      contentPadding:
                                                          const EdgeInsets.only(
                                                              top: 12,
                                                              bottom: 12,
                                                              left: 6, //todo
                                                              right: 6 //todo
                                                              ),
                                                      hintText: 'Puntos',
                                                      hintStyle: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    keyboardType:
                                                        TextInputType.number,
                                                    onSaved: (input) {},
                                                    validator:
                                                        _validateNotEmpty,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 4,
                                                  child: Container(
                                                    padding: EdgeInsets.only(
                                                        left: 10),
                                                    child: FlatButton(
                                                      shape: new RoundedRectangleBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                      .circular(
                                                                  5.0)),
                                                      padding:
                                                          EdgeInsets.all(12),
                                                      child: Text(
                                                        'Aplicar',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      color:
                                                          HexColor('#0D47A1'),
                                                      onPressed: () {},
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            */
                                                  /*
                                            !loadingInstallments ? Container(
                                              alignment: Alignment.centerLeft,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                                child: FlatButton(
                                                  shape: new RoundedRectangleBorder(
                                                      borderRadius:
                                                          new BorderRadius
                                                                  .circular(
                                                              5.0)),
                                                  padding:
                                                      EdgeInsets.all(12),
                                                  child: Text(
                                                    'Verificar promociones',
                                                    style: TextStyle(
                                                        color:
                                                            Colors.white),
                                                  ),
                                                  color:
                                                      HexColor('#0D47A1'),
                                                  onPressed: () {
                                                    if(
                                                      paymentData.cardNumber.isNotEmpty &&
                                                      paymentData.cardYear.isNotEmpty &&
                                                      paymentData.cardMonth.isNotEmpty &&
                                                      paymentData.cardName.isNotEmpty
                                                    ){
                                                      getInstallments();
                                                    }
                                                  },
                                                ),
                                              ),
                                            )  : FlatButton(
                                              color: HexColor("#FFFFFF"),
                                              onPressed: (){},
                                              child: CircularProgressIndicator(),
                                            ),
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                                child: Text(
                                                  loadingInstallments ? 
                                                  '' :
                                                  hasPromotions ? 
                                                  'Tu tarjeta participa en las siguientes promociones a meses sin intereses:  ':
                                                  'No se han encontrado promociones válidas para esta tarjeta',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: HexColor("#637381"),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 15),
                                              child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                return GridView.builder(
                                                  physics:
                                                      ClampingScrollPhysics(),
                                                  shrinkWrap: true,
                                                  primary: false,
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 3,
                                                          // crossAxisSpacing: 14,
                                                          // mainAxisSpacing: 14,
                                                          childAspectRatio:
                                                              constraints.maxWidth <
                                                                      350
                                                                  ? 18 / 8
                                                                  : 18 / 8,
                                                          crossAxisSpacing: 14),
                                                  itemCount:
                                                      installmentList.length == 0
                                                          ? 0
                                                          : installmentList.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return msiSelected ==
                                                        index
                                                            ? RaisedButton(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            0,
                                                                        vertical:
                                                                            2),
                                                                color: HexColor(
                                                                    '#0D47A1'),
                                                                onPressed:
                                                                    () {
                                                                      print('object');
                                                                      
                                                                    },
                                                                child: Text(
                                                                  installmentList[
                                                                      index],
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              )
                                                            : OutlineButton(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            0,
                                                                        vertical:
                                                                            2),
                                                                child: new Text(
                                                                  installmentList[
                                                                      index],
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                                onPressed:
                                                                    () {
                                                                      setState(() {
                                                                        msiSelected = index;
                                                                        setInstallment();
                                                                      });
                                                                    },
                                                                shape:
                                                                    new RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      new BorderRadius
                                                                              .circular(
                                                                          2.0),
                                                                ),
                                                                borderSide: BorderSide(
                                                                    color: HexColor(
                                                                        '#C4CDD5'),
                                                                    width: 1.0),
                                                              );
                                                  },
                                                );
                                              },
                                            ),
                                            ),
                                            */
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                  payPayPal == false
                                      ? SizedBox(
                                          height: 0,
                                        )
                                      : RadioListTile<PaymentMethod>(
                                          activeColor: HexColor("#0D47A1"),
                                          title: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              PayPalSVG(25),
                                            ],
                                          ),
                                          value: PaymentMethod.paypal,
                                          groupValue: payMethod,
                                          onChanged: (PaymentMethod value) {
                                            setState(() {
                                              payMethod = value;
                                            });
                                          },
                                        ),
                                  payMethod != PaymentMethod.paypal
                                      ? SizedBox(
                                          height: 0,
                                        )
                                      : Column(
                                          children: <Widget>[
                                            Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: Text(
                                                'Realiza tu pedido con la seguridad, simplicidad y facilidad de PayPal.',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  // color: HexColor("#637381"),
                                                ),
                                              ),
                                            ),
                                            // GestureDetector(
                                            //   onTap: () {
                                            //     // paypal();
                                            //   },
                                            //   child: PayPalPaySVG(34, 172),
                                            // )
                                          ],
                                        ),
                                  payInAssociatedStore == false
                                      ? SizedBox(
                                          height: 0,
                                        )
                                      : RadioListTile<PaymentMethod>(
                                          activeColor: HexColor("#0D47A1"),
                                          title: const Text(
                                            'Pago en Establecimiento Asociado',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          value: PaymentMethod.associatedStore,
                                          groupValue: payMethod,
                                          onChanged:
                                              (PaymentMethod value) async {
                                            setState(() {
                                              payMethod = value;
                                            });
                                          },
                                        ),
                                  payMethod != PaymentMethod.associatedStore
                                      ? SizedBox(
                                          height: 0,
                                        )
                                      : Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.all(15.0),
                                          child: Column(
                                            children: <Widget>[
                                              Container(
                                                alignment: Alignment.center,
                                                padding:
                                                    const EdgeInsets.all(15.0),
                                                child: Text(
                                                  '¿Cómo pagar en establecimientos asociados?',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    // color: HexColor("#637381"),
                                                  ),
                                                ),
                                              ),
                                              ListTile(
                                                contentPadding:
                                                    EdgeInsets.all(20.0),
                                                leading: Text(
                                                  '1',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: HexColor("#C4CDD5"),
                                                  ),
                                                ),
                                                title: Text(
                                                    'A través del correo te llegará tu “orden de pago” con el código de barras.'),
                                              ),
                                              ListTile(
                                                contentPadding:
                                                    EdgeInsets.all(20.0),
                                                leading: Text(
                                                  '2',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: HexColor("#C4CDD5"),
                                                  ),
                                                ),
                                                title: Text(
                                                    'Imprímela o llévala en tu celular a cualquiera de los establecimientos indicados.'),
                                              ),
                                              ListTile(
                                                contentPadding:
                                                    EdgeInsets.all(20.0),
                                                leading: Text(
                                                  '3',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: HexColor("#C4CDD5"),
                                                  ),
                                                ),
                                                title: Text(
                                                    'Entrégala en caja y haz tu pago. Guarda el comprobante.'),
                                              ),
                                              ListTile(
                                                contentPadding:
                                                    EdgeInsets.all(20.0),
                                                leading: Text(
                                                  '4',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: HexColor("#C4CDD5"),
                                                  ),
                                                ),
                                                title: Text(
                                                    'El pago se registrará y enviará la confirmación a la tienda.'),
                                              ),
                                              Container(
                                                alignment: Alignment.center,
                                                padding:
                                                    const EdgeInsets.all(15.0),
                                                child: Column(
                                                    children: <Widget>[
                                                      Text(
                                                        'Establecimientos asociados:',
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          // color: HexColor("#637381"),
                                                        ),
                                                      ),
                                                      establecimientosAsociados !=
                                                              null
                                                          ? Row(
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                  width: 100.0,
                                                                  child: ListView
                                                                      .builder(
                                                                    shrinkWrap:
                                                                        true,
                                                                    physics:
                                                                        ClampingScrollPhysics(),
                                                                    scrollDirection:
                                                                        Axis.vertical,
                                                                    itemCount: establecimientosAsociados ==
                                                                            null
                                                                        ? 0
                                                                        : establecimientosAsociados.length ~/
                                                                            2,
                                                                    itemBuilder:
                                                                        (BuildContext
                                                                                context,
                                                                            int index) {
                                                                      return Image
                                                                          .network(
                                                                        "https://prod.chedraui.com.mx" +
                                                                            establecimientosAsociados[index]['storeImageUrl'],
                                                                        fit: BoxFit
                                                                            .scaleDown,
                                                                        height:
                                                                            85.0,
                                                                        width:
                                                                            85.0,
                                                                        alignment:
                                                                            Alignment.center,
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: 100.0,
                                                                  child: ListView
                                                                      .builder(
                                                                    shrinkWrap:
                                                                        true,
                                                                    physics:
                                                                        ClampingScrollPhysics(),
                                                                    scrollDirection:
                                                                        Axis.vertical,
                                                                    itemCount: establecimientosAsociados ==
                                                                            null
                                                                        ? 0
                                                                        : establecimientosAsociados.length ~/
                                                                            2,
                                                                    itemBuilder:
                                                                        (BuildContext
                                                                                context,
                                                                            int index) {
                                                                      int index2 =
                                                                          index +
                                                                              (establecimientosAsociados.length ~/ 2);
                                                                      return Image
                                                                          .network(
                                                                        "https://prod.chedraui.com.mx" +
                                                                            establecimientosAsociados[index2]['storeImageUrl'],
                                                                        fit: BoxFit
                                                                            .scaleDown,
                                                                        height:
                                                                            85.0,
                                                                        width:
                                                                            85.0,
                                                                        alignment:
                                                                            Alignment.center,
                                                                      );
                                                                    },
                                                                  ),
                                                                )
                                                              ],
                                                            )
                                                          : SizedBox(
                                                              height: 50,
                                                              child: Center(
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              ),
                                                            ),
                                                    ]),
                                              ),
                                            ],
                                          ),
                                        ),
                                  payOnDelivery == false
                                      ? SizedBox(
                                          height: 0,
                                        )
                                      : RadioListTile<PaymentMethod>(
                                          activeColor: HexColor("#0D47A1"),
                                          title: const Text(
                                            'Pago Contra Entrega',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          value: PaymentMethod.onDelivery,
                                          groupValue: payMethod,
                                          onChanged: (PaymentMethod value) {
                                            setState(() {
                                              payMethod = value;
                                            });
                                          },
                                        ),
                                  payMethod != PaymentMethod.onDelivery
                                      ? SizedBox(
                                          height: 0,
                                        )
                                      : Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.all(15.0),
                                          child: Column(
                                            children: <Widget>[
                                              Container(
                                                alignment: Alignment.center,
                                                padding:
                                                    const EdgeInsets.all(15.0),
                                                child: Text(
                                                  'Selecciona la forma de pago a utilizar en contra entrega:',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              GridView.count(
                                                physics:
                                                    ClampingScrollPhysics(),
                                                shrinkWrap: true,
                                                primary: false,
                                                crossAxisSpacing: 8.0,
                                                childAspectRatio: 1.5,
                                                crossAxisCount: 2,
                                                children: <Widget>[
                                                  !visa
                                                      ? null
                                                      : OnDeliverOptionItem(
                                                          selectOnDeliverPayMethod,
                                                          index: 0,
                                                          isSelected:
                                                              _selectedOnDeliverPayMethod ==
                                                                      0
                                                                  ? true
                                                                  : false,
                                                        ),
                                                  !masterCard
                                                      ? null
                                                      : OnDeliverOptionItem(
                                                          selectOnDeliverPayMethod,
                                                          index: 1,
                                                          isSelected:
                                                              _selectedOnDeliverPayMethod ==
                                                                      1
                                                                  ? true
                                                                  : false,
                                                        ),
                                                  !amex
                                                      ? null
                                                      : OnDeliverOptionItem(
                                                          selectOnDeliverPayMethod,
                                                          index: 2,
                                                          isSelected:
                                                              _selectedOnDeliverPayMethod ==
                                                                      2
                                                                  ? true
                                                                  : false,
                                                        ),
                                                  !cash
                                                      ? null
                                                      : OnDeliverOptionItem(
                                                          selectOnDeliverPayMethod,
                                                          index: 3,
                                                          isSelected:
                                                              _selectedOnDeliverPayMethod ==
                                                                      3
                                                                  ? true
                                                                  : false,
                                                        ),
                                                  !vales
                                                      ? null
                                                      : OnDeliverOptionItem(
                                                          selectOnDeliverPayMethod,
                                                          index: 4,
                                                          isSelected:
                                                              _selectedOnDeliverPayMethod ==
                                                                      4
                                                                  ? true
                                                                  : false,
                                                        ),
                                                ].where(notNull).toList(),
                                              ),
                                            ],
                                          ),
                                        ),
                                  payInStore == true
                                      ? RadioListTile<PaymentMethod>(
                                          activeColor: HexColor("#0D47A1"),
                                          title: const Text(
                                            'Pago en Tienda',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          value: PaymentMethod.onStore,
                                          groupValue: payMethod,
                                          onChanged: (PaymentMethod value) {
                                            setState(() {
                                              payMethod = value;
                                            });
                                          },
                                        )
                                      : SizedBox(
                                          height: 0,
                                        ),
                                  payMethod != PaymentMethod.onStore
                                      ? SizedBox(
                                          height: 0,
                                        )
                                      : Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.all(15.0),
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 10,
                                                ),
                                                child: Text(
                                                    'Tu pedido incluye productos de las siguientes tiendas Chedraui: '),
                                              ),
                                              Container(
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      ClampingScrollPhysics(),
                                                  itemCount: tiendasEntrega ==
                                                          null
                                                      ? 0
                                                      : tiendasEntrega.length,
                                                  itemBuilder:
                                                      (context, position) {
                                                    return DeliveryStore(
                                                        encabezadoTiendaOrigen:
                                                            tiendasEntrega[
                                                                    position]
                                                                .getEncabezadoTiendaOrigen(),
                                                        direccionTiendaOrigen:
                                                            tiendasEntrega[
                                                                    position]
                                                                .getDireccionTiendaOrigen(),
                                                        encabezadoTiendaDestino:
                                                            tiendasEntrega[
                                                                    position]
                                                                .getEncabezadoTiendaDestino(),
                                                        direccionTiendaDestino:
                                                            tiendasEntrega[
                                                                    position]
                                                                .getDireccionTiendaDestino(),
                                                        numeroArticulosTienda:
                                                            tiendasEntrega[
                                                                    position]
                                                                .getNumeroArticulosTienda(),
                                                        listaProductos:
                                                            tiendasEntrega[
                                                                    position]
                                                                .getListaProductos());
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(vertical: 7),
                            child: RaisedButton(
                              disabledColor:
                                  HexColor('#F57C00').withOpacity(0.5),
                              padding: EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(6.0)),
                              onPressed: null,
                              color: HexColor('#F57C00'),
                              child: Text(
                                'Continuar con información de entrega',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: 'Archivo',
                                  fontSize: 14,
                                  letterSpacing: 0.25,
                                  color: HexColor('#FFFFFF'),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Text(
                                '2 Información de pago',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: HexColor("#212B36"),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            child: Row(
                              children: <Widget>[
                                VisaSVG(),
                                Container(
                                  margin: EdgeInsets.only(left: 5),
                                  child: Text(
                                    'Store Card **** 1203',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: HexColor("#212B36"),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              SizedBox(),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    paymentInfoSave = !paymentInfoSave;
                                  });
                                },
                                child: Text(
                                  'Cambiar',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: HexColor("#0D47A1"),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
              ),
        Container(
          margin: EdgeInsets.all(15),
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color(0xcc000000).withOpacity(0.1),
                offset: Offset(0.0, 5.0),
                blurRadius: 10.0,
              ),
            ],
          ),
          child: Column(children: <Widget>[
            Form(
              key: _formKey2,
              child: _currentCart != null && _slotsEntrega != null
                  ? ConsigmentWidget(
                      slotsList: _slotsEntrega['slots'],
                      carrito: _currentCart,
                      callback: setCurrentConsigments)
                  : SizedBox(
                      height: 50,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
            )
          ]),
        )
      ],
    );
  }

  testOpenPay() {
    var data = {
      "id": "trx0pxs6qodwoal8y4gw",
      "authorization": "801585",
      "operation_type": "in",
      "method": "card",
      "transaction_type": "charge",
      "card": {
        "id": "k2vjvx0zbmwcd8mpuvdl",
        "type": "debit",
        "brand": "visa",
        "address": null,
        "card_number": "411111XXXXXX1111",
        "holder_name": "Juan Perez Ramirez",
        "expiration_year": "20",
        "expiration_month": "12",
        "allows_charges": true,
        "allows_payouts": true,
        "creation_date": "2019-05-17T01:33:09-05:00",
        "bank_name": "Banamex",
        "bank_code": "002"
      },
      "status": "completed",
      "conciliated": false,
      "creation_date": "2019-05-17T01:33:09-05:00",
      "operation_date": "2019-05-17T01:33:09-05:00",
      "description": "prueba de cargo",
      "error_message": null,
      "order_id": "08832472",
      "amount": 1,
      "customer": {
        "name": "Juan Perez Ramirez",
        "last_name": "Vazquez Juarez",
        "email": "juan.vazquez@empresa.com.mx",
        "phone_number": "4423456723",
        "address": null,
        "creation_date": "2019-05-17T01:33:09-05:00",
        "external_id": null,
        "clabe": null
      },
      "fee": {"amount": 2.53, "tax": 0.4048, "currency": "MXN"},
      "currency": "MXN"
    };
    /*
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutConfirmationPage(
          paymentMethod: PaymentMethod.card,
          orderData: data,
          shippingData: tiendasEntrega,
          shippingDatetime: _selectedDateTime
        ),
      ),
    );
    */
  }

  _showResponseDialog(msg) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(msg),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
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

  completeOrder() {
    setState(() {
      loadingOrder = true;
    });
    switch (payMethod) {
      case PaymentMethod.paypal:
        generarVista();
        break;
      case PaymentMethod.associatedStore:
        associatedStoreData();
        break;
      case PaymentMethod.card:
        openPayData();
        break;
      case PaymentMethod.onDelivery:
        onDeliveryData();
        break;
      case PaymentMethod.onStore:
        onStoreData();
        break;
      default:
    }
  }

  validateCoupon() {
    setState(() {
      _couponToValidate = couponTextfieldController.text;
      _couponValid = _couponToValidate.length >= 4 ? true : false;
      print(_couponValid.toString());
    });
  }

  selectOnDeliverPayMethod(index) {
    setState(() {
      _selectedOnDeliverPayMethod = index;
    });
  }

  Future<void> saveStep(GlobalKey<FormState> formKey) async {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
    }
  }

  setCurrentConsigments(List<Consignment> consigments) {
    _consignmentsList.clear();
    consigments.forEach((consigment) {
      if (consigment.restricted) {
        _consignmentsList.add({
          "code": consigment.consignmentCode,
          "selectedDateIndex": consigment.selectedDateIndex,
          "selectedHourIndex": consigment.selectedHourIndex,
          "repeated": consigment.repeated
        });
      }
    });
  }

  confirmShippingInfo() async {
    setState(() {
      loadingOrder = true;
    });
    List slotsToSave = getSlotsToSave();
    print(slotsToSave);
    List setSlotsResponses =
        await CarritoServices.setCartTimeSlots(slotsToSave);
    print(setSlotsResponses);
    _isButtonDisabled = false;
    setState(() {
      loadingOrder = false;
    });
  }

  List getSlotsToSave() {
    List slotsToSave = new List();
    int _selectedDayPrevious;
    int _selectedHourPrevious;
    for (var consignment in _slotsEntrega['slots']) {
      var code = consignment['consignmentCode'];
      var slots = consignment['slots'];
      for (var infoC in _consignmentsList) {
        if (code == infoC['code'] && slots.length > 0) {
          bool repeated = infoC['repeated'] ?? false;
          int _selectedDay =
              !repeated ? infoC['selectedDateIndex'] : _selectedDayPrevious;
          int _selectedHour =
              !repeated ? infoC['selectedHourIndex'] : _selectedHourPrevious;
          _selectedDayPrevious =
              !repeated ? _selectedDay : _selectedDayPrevious;
          _selectedHourPrevious =
              !repeated ? _selectedHour : _selectedHourPrevious;
          var timeSlot = slots[_selectedDay]['value']['slots'][_selectedHour];
          List<String> tmpFecha = slots[_selectedDay]["key"].split("/");
          slotsToSave.add({
            "timeFrom": timeSlot['dateFrom'].toString(),
            "timeTo": timeSlot['dateTo'].toString(),
            "selectedDate":
                '${tmpFecha[2]}-${tmpFecha[1]}-${tmpFecha[0]}T00:00:00Z',
            "consignmentCode": code.toString()
          });
        }
      }
    }
    return slotsToSave;
  }

  void submitSecondForm(payMethod) {
    if (payMethod == PaymentMethod.onDelivery) {
      switch (_selectedOnDeliverPayMethod) {
        case 0:
          paymethodOnDelivery = 'VISA';
          break;
        case 1:
          paymethodOnDelivery = 'MASTERCARD';
          break;
        case 2:
          paymethodOnDelivery = 'AMEX';
          break;
        case 3:
          paymethodOnDelivery = 'CASH';
          break;
        case 4:
          paymethodOnDelivery = 'VALES';
          break;
        default:
      }
    }
    if (payMethod != PaymentMethod.card) {
      print(payMethod);
    } else if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      print('Printing the pay data.');
      print('cardName: ${paymentData.cardName}');
      print('cardDate: ${paymentData.cardMonth}${paymentData.cardYear}');
      print('cardNumber: ${paymentData.cardNumber}');
      print('cardSecurity: ${paymentData.cardSecurity}');
    }
  }

  String _validateNotEmpty(String value) {
    if (value.isEmpty) {
      return 'Requerido';
    }
    return null;
  }

  getOpenPayToken() async {
    var cardData = json.encode({
      "card_number": paymentData.cardNumber.replaceAll(' ', ''),
      "holder_name": paymentData.cardName,
      "expiration_year": paymentData.cardYear,
      "expiration_month": paymentData.cardMonth,
      "cvv2": paymentData.cardSecurity
    });
    print(cardData);
    var resultToken = await PaymentServices.getTokenFromOpenPay(cardData);
    if (resultToken['id'] != null) {
      tokenOpenPay = resultToken['id'];
      var paymentArgs = {
        "paymentMethod": "card",
        "token": tokenOpenPay,
        "deviceSessionId": deviceSessionID
      };
      var setPaymentResult =
          await PaymentServices.setPaymentMethod(paymentArgs, cartCode);
      print(setPaymentResult);
    } else {
      _showResponseDialog(
          "Error al procesar la tarjeta: ${resultToken['description']} [${resultToken['error_code']}]");
    }
  }

  void getInstallments() async {
    setState(() {
      loadingInstallments = true;
    });
    if (tokenOpenPay == null) {
      await getOpenPayToken();
    }
    var installmentsCard = await PaymentServices.getInstallmetsForCard();

    bool promotionsFound = (installmentsCard.length > 0);
    List installments = [];
    if (promotionsFound) {
      for (num i = 0; i < installmentsCard.length; i++) {
        if (total > installmentsCard[i]['baseAmount'] &&
            total < installmentsCard[i]['limitAmount']) {
          installmentPromoids.add(installmentsCard[i]['promoId']);
          installmentNames.add(installmentsCard[i]['installments'].toString());
          String msg = "";
          if (installmentsCard[i]['printerMessage'].toLowerCase() ==
              "3 msi en toda la tienda en línea, compra mínima \$300 (bancomer)") {
            msg = "3 meses sin intereses";
          } else if (installmentsCard[i]['printerMessage'].toLowerCase() ==
              "6 msi en toda la tienda en línea, compra mínima \$800 (bancomer, citibanamex, santander, scotiabank)") {
            msg = "6 meses sin intereses";
          } else if (installmentsCard[i]['printerMessage'].toLowerCase() ==
              "9 msi en toda la tienda en línea, compra mínima \$800 (amex)") {
            msg = "9 meses sin intereses";
          } else if (installmentsCard[i]['printerMessage'].contains("12 MSI")) {
            msg = "12 meses sin intereses";
          } else if (installmentsCard[i]['printerMessage'].contains("24 MSI")) {
            msg = "24 meses sin intereses";
          } else {
            msg = installmentsCard[i]['printerMessage'];
          }
          installments.add(msg);
        }
      }
    }

    setState(() {
      installmentList = installments;
      loadingInstallments = false;
      hasPromotions = promotionsFound;
    });
  }

  void setInstallment() async {
    if (msiSelected != null) {
      var selectedInstallment = {
        "promoId": installmentPromoids[msiSelected],
        "installments": installmentNames[msiSelected],
      };
      await PaymentServices.setInstallmetsForCard(selectedInstallment);
    }
  }

  void openPayData() async {
    if (tokenOpenPay == null) {
      await getOpenPayToken();
    }
    var orderData = await PaymentServices.placeOrder(cartCode);
    if (orderData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: DataUI.checkoutConfirmationRoute),
          builder: (context) => CheckoutConfirmationPage(
              paymentMethod: PaymentMethod.card,
              orderData: orderData,
              shippingData: tiendasEntrega,
              shippingDatetime: getSlotsToSave(),
              additionalData: null),
        ),
      );
    } else {
      _showResponseDialog("Error al procesar el pago");
    }
    setState(() {
      loadingOrder = false;
    });
  }

  void associatedStoreData() async {
    var paymentArgs = {"paymentMethod": "PAYINASSOCIATEDSTORE"};
    var setPaymentResult =
        await PaymentServices.setPaymentMethod(paymentArgs, cartCode);
    var orderData = await PaymentServices.placeOrder(cartCode);
    if (orderData != null) {
      print("ORDER CODE: ${orderData['code']}");
      var paynetDetail =
          await PaymentServices.getPaynetPaymentDetail(orderData['code']);
      Navigator.push(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: DataUI.checkoutConfirmationRoute),
          builder: (context) => CheckoutConfirmationPage(
              paymentMethod: PaymentMethod.associatedStore,
              orderData: orderData,
              shippingData: tiendasEntrega,
              shippingDatetime: getSlotsToSave(),
              additionalData: paynetDetail),
        ),
      );
    } else {
      _showResponseDialog("No se puede generar la orden.");
    }
    setState(() {
      loadingOrder = false;
    });
  }

  void onDeliveryData() async {
    String paymethodOnDelivery;
    switch (_selectedOnDeliverPayMethod) {
      case 0:
        paymethodOnDelivery = 'VISA';
        break;
      case 1:
        paymethodOnDelivery = 'MASTERCARD';
        break;
      case 2:
        paymethodOnDelivery = 'AMEX';
        break;
      case 3:
        paymethodOnDelivery = 'CASH';
        break;
      case 4:
        paymethodOnDelivery = 'VALES';
        break;
      default:
    }
    var paymentArgs = {
      "paymentMethod": "PAYONDELIVERY",
      "payOnDeliveryPaymentType": paymethodOnDelivery
    };
    var setPaymentResult =
        await PaymentServices.setPaymentMethod(paymentArgs, cartCode);
    var orderData = await PaymentServices.placeOrder(cartCode);
    if (orderData != null) {
      print("ORDER CODE: ${orderData['code']}");
      Navigator.push(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: DataUI.checkoutConfirmationRoute),
          builder: (context) => CheckoutConfirmationPage(
              paymentMethod: PaymentMethod.associatedStore,
              orderData: orderData,
              shippingData: tiendasEntrega,
              shippingDatetime: getSlotsToSave(),
              additionalData: null),
        ),
      );
    } else {
      _showResponseDialog("No se puede generar la orden.");
    }
    setState(() {
      loadingOrder = false;
    });
  }

  void onStoreData() async {
    var paymentArgs = {"paymentMethod": "PAYINSTORE"};
    var setPaymentResult =
        await PaymentServices.setPaymentMethod(paymentArgs, cartCode);
    var orderData = await PaymentServices.placeOrder(cartCode);
    if (orderData != null) {
      print("ORDER CODE: ${orderData['code']}");
      Navigator.push(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: DataUI.checkoutConfirmationRoute),
          builder: (context) => CheckoutConfirmationPage(
              paymentMethod: PaymentMethod.associatedStore,
              orderData: orderData,
              shippingData: tiendasEntrega,
              shippingDatetime: getSlotsToSave(),
              additionalData: null),
        ),
      );
    } else {
      _showResponseDialog("No se puede generar la orden.");
    }
    setState(() {
      loadingOrder = false;
    });
  }

  paypal() {
    Navigator.pushNamed(context, DataUI.paypalRoute);
  }

  @override
  void dispose() {
    couponTextfieldController.dispose();
    super.dispose();
  }
}
