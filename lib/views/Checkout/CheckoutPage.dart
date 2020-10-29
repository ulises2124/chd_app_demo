import 'package:chd_app_demo/services/PaymentServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/utils/NetworkData.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:translator/translator.dart';
import 'package:chd_app_demo/utils/input_formatters.dart';
import 'package:chd_app_demo/utils/payment_card.dart';
import 'package:chd_app_demo/views/Checkout/CheckoutConfirmationPage.dart';
import 'package:chd_app_demo/views/Checkout/OnDeliverOptionItemWidget.dart';
import 'package:chd_app_demo/views/Checkout/Installment.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:chd_app_demo/widgets/dashedLine.dart';
import 'package:chd_app_demo/utils/payment_card.dart' as UtilsPayment;
import 'package:chd_app_demo/widgets/encryptionDisclaimer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chd_app_demo/views/Checkout/PaymentMethod.dart';
import 'package:chd_app_demo/widgets/deliveryInformation.dart';
import 'package:chd_app_demo/services/CarritoServices.dart';
import 'dart:async';
import 'package:chd_app_demo/views/Checkout/ConsigmentWidget.dart';
import 'package:chd_app_demo/views/Checkout/InstallmentWidget.dart';
import 'package:chd_app_demo/views/Checkout/Consignment.dart';
import 'package:chd_app_demo/services/MediosPagoService.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:chd_app_demo/views/Checkout/PersonalInfo.dart';
import 'package:chd_app_demo/services/MonederoServices.dart';
import 'package:chd_app_demo/views/Checkout/PersonalInformationData.dart';
import 'package:chd_app_demo/services/BovedaService.dart';
import 'package:chd_app_demo/widgets/customStepper.dart' as stepper;
import 'package:chd_app_demo/widgets/customDropdown.dart' as dropdown;
import 'package:chd_app_demo/views/CuponesPage/CuponesPage.dart';
import 'package:chd_app_demo/views/Checkout/NewCreditCard.dart';
import 'package:chd_app_demo/services/FireBaseServices.dart';
import 'package:strings/strings.dart';
import 'package:chd_app_demo/views/Checkout/AddressesUserWidget.dart';
import 'package:chd_app_demo/views/Checkout/AddressesRegistredUserWidget.dart';
import 'package:chd_app_demo/utils/addressData.dart';
import 'package:chd_app_demo/views/CuentaPage/EditAddressPage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:chd_app_demo/services/UserProfileServices.dart';
import 'package:flutter/gestures.dart';
import 'package:flushbar/flushbar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chd_app_demo/views/Servicios/KenticoServices.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';

enum StatusCheckout {
  START,
  LOADING_STEP,
  IDLE,
}

class PaymentIformationData {
  String cardNumber = '';
  String cardSecurity = '';
  String cardYear = '';
  String cardMonth = '';
  String cardName = '';
  String onDeliverPayMethod = '';
  String cardLastName = '';
  String cardEmail = '';
  String cardPhone = '';
}

class CheckoutPage extends StatefulWidget {
  final token;
  final carritoID;
  CheckoutPage({Key key, this.carritoID, this.token}) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  PaymentMethod payMethod;
  var numberController = new TextEditingController();
  var _paymentCard = PaymentCard();
  var _card = new PaymentCard();
  bool _autoValidateFirstForm = false;
  bool _autoValidateSecondtForm = false;
  List installmentList = [];
  List installmentPromoids = [];
  List installmentNames = [];
  List<Installment> installmentsList = [];
  int _selectedOnDeliverPayMethod = 0;
  int _selectedRegistredCard = 0;
  // int _selectedAssociatedStore = 4;
  String paymethodOnDelivery;
  int itemsCount;
  String cardN, cardNombre, cardFecha;
  String idWallet;
  List cards;
  List<dropdown.DropdownMenuItem<String>> tarjetasDropDown = [];
  List<String> tarjetasDropDownValues = [];
  String _cardSelected;
  int msiSelected;
  bool loadingOrder = false;
  bool addressSet = false;
  bool nonRegistredAddress = true;
  String _idMonedero;
  num _saldoMonedero = 0;
  num _saldoAUtilizarMonedero = 0;
  String _cvv = "";
  bool _aceptaPuntos = false;
  bool _usarPuntos = false;
  String _pointsType = "";
  num _remainingPoints = 0;
  num _remainingMxn = 0;
  num _totalPagoMonedero = 0;
  bool _loadingMonedero = false;
  bool _pagoMonederoExitoso = false;
  String horarioEntregaText;
  String horarioEntregaTextForOrder;
  PaymentIformationData paymentData = new PaymentIformationData();
  bool errDatosContacto = false;
  List slotsList;
  int _tipoTarjeta = 0;

  bool acceptedTyC = true;
  bool isContinueActive = false;

  String _currentNotes = "";
  var saldoMonederoController = new TextEditingController();
  final monederoFocusNode = FocusNode();

  bool _flagPaypalProcess = true;

  List<GlobalKey<FormState>> _formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>()];

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

  dynamic newTotal;
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

  FlutterWebviewPlugin webview;

  String currentType;
  PersonalInformationData personalInfo = new PersonalInformationData();

  bool sessionDataLoaded = false;
  bool isLoggedIn = false;
  bool isPickUp = false;

  var slotsEntrega = null; // Slots de entrega para crear slots de tiempo
  var _slotsEntrega = null; // Slots de entrega para crear puntos de envio
  var _currentCart = null; // Información de carrito para crear puntos de envio
  var _consignments = null;

  List _consignmentsList = [];
  List _installmentsList = [];

  String _currentPromoId = null;
  int _currentInstallment = 0;

  bool cardInvitadoIsValid = false;

  NumberFormat moneda = new NumberFormat.currency(locale: 'es_MX', symbol: "\$");

  String tokenOpenPay;
  String messageErrorOpenPay = "Error en el servicio de Openpay";
  bool errorOpenPay = false;
  String customerIdOpenPay;
  var bankPointsRaw;
  var bankPointsMXN;
  bool bankPointsSelected = false;
  bool hasPromotions = false;
  bool loadingInstallments = false;
  bool processingCard = false;

  final couponTextfieldController = TextEditingController();
  String _couponToValidate = '';
  bool _couponValid = false;
  var _couponResultColor = Colors.black;
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

  num _subTotal;
  num _subTotalWithoutDiscount;
  num _totalCouponsAmount;
  num _totalDiscounts;
  num _deliveryCost;
  num _totalPrice;
  num _totalPriceWithTax;
  num _totalTax;
  num _totalToPay;
  num _totalWithoutDiscount;
  num _numberOfInstallments;
  num _productDiscount;
  var _cardPoints;
  num _monederoAmount;

  String shippingAddress;

  int currStep = 0;

  List<dynamic> paymentMethods;

  SharedPreferences prefs;

  bool _isButtonDisabled = true;
  bool _finishEditing = false;
  bool card = false;
  bool registredCard = false;
  bool payPayPal = false;
  bool payOnDelivery = false;
  bool payInStore = false;
  bool payInAssociatedStore = false;
  bool monederoAllowed = false;
  bool monedero = false;
  bool monederoSelected = false;
  bool onlyMonederoSelected = false;

  bool _validandoCupon = false;
  String _numeroCupon = "";
  String _tokenCupon = "";
  String _cuponGuardado = "";

  bool _validateCvv = false;

  List<dynamic> payOnDeliveryMethods;
  bool cash = true;
  bool visaMastercard = false;
  bool visa = false;
  bool masterCard = false;
  bool amex = false;
  bool vales = false;

  bool containsDHL = false;

  Map cuponSaved;

  bool newAddressSelected = false;
  dynamic newAddressInfo;

  StatusCheckout currState = StatusCheckout.START;

  final Map<String, FocusNode> _focusFormCard = {
    "numeroTarjeta": FocusNode(),
    "expiraTarjeta": FocusNode(),
    "cvvTarjeta": FocusNode(),
    "nombreTarjeta": FocusNode(),
    "aliasTarjeta": FocusNode(),
  };
  String kenticoTextAsociado;
  String kenticoTextTienda;

  Future<dynamic> cart;

  Future<bool> getPaymentsMethod() async {
    var responsePayments = await PaymentServices.getPayments();
    if (responsePayments != null && responsePayments["errors"] != null) {
      final translator = new GoogleTranslator();
      List errosListPaymentMethods = responsePayments['errors'];
      List msgErrors = [];
      await Future.forEach(errosListPaymentMethods, (e) async {
        var s = await translator.translate(e['message'], to: 'es');
        msgErrors.add(s);
      });
      String msgStr = msgErrors.join("\n");
      _showResponseDialog("Error al obtener métodos de pago disponibles:\n$msgStr");
      return false;
    }
    setState(() {
      paymentMethods = responsePayments['paymentMethods'];
      Future.forEach(paymentMethods, (method) {
        switch (method) {
          case 'CARD':
            card = !isLoggedIn;
            registredCard = isLoggedIn;
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
            monederoAllowed = true;
            break;
          default:
        }
      });
      if (responsePayments['payOnDeliveryPaymentTypes'] != null) {
        payOnDeliveryMethods = responsePayments['payOnDeliveryPaymentTypes'];
        Future.forEach(payOnDeliveryMethods, (method) {
          switch (method) {
            case 'CASH':
              cash = true;
              break;
            case 'VISAMASTERCARD':
              //visaMastercard = true;
              vales = true;
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
    if (isLoggedIn) {
      await getCartera();
      await getInstallments();
    }
    return true;
  }

  Future<void> getCartera({bool setLast}) async {
    setState(() {
      cards = null;
      tarjetasDropDown.clear();
      tarjetasDropDownValues.clear();
    });
    var _cards = await BovedaService.getCartera(idWallet);
    bool getToken = false;
    List bines = await PaymentServices.getBines();
    List decCards = [];
    List<dropdown.DropdownMenuItem<String>> tarjetasDropDownAux = [];
    if (_cards != null && _cards.length > 0) {
      const platform = const MethodChannel('com.cheadrui.com/decypher');
      for (var i = 0; i < _cards.length; i++) {
        String data;
        try {
          /*
          decCards.add({
            "idWallet": _cards[i]['idWallet'],
            "numTarjeta": await platform
                .invokeMethod('decypher', {"text": _cards[i]['numTarjeta']}),
            "tipoTarjeta": _cards[i]['tipoTarjeta'],
            "bancoEmisor": await platform
                .invokeMethod('decypher', {"text": _cards[i]['bancoEmisor']}),
            "aliasTarjeta": await platform.invokeMethod(
                'decypher', {"text": _cards[i]['aliasTarjeta']}),
            "nomTitularTarj": await platform.invokeMethod(
                'decypher', {"text": _cards[i]['nomTitularTarj']}),
            "cvv": "",
            "fecExpira": await platform
                .invokeMethod('decypher', {"text": _cards[i]['fecExpira']}),
            "bin": await platform
                .invokeMethod('decypher', {"text": _cards[i]['bin']}),
            "identificador": _cards[i]['identificador']
          });
          */
          String numTarjeta = await platform.invokeMethod('decypher', {"text": _cards[i]['numTarjeta']});
          String idTarjeta = _cards[i]['identificador'].toString();
          String tipoTarjeta = _cards[i]['tipoTarjeta'];
          String bin = await platform.invokeMethod('decypher', {"text": _cards[i]['bin']});
          decCards.add({"identificador": idTarjeta, "numTarjeta": numTarjeta, "bin": bin, "tipoTarjeta": tipoTarjeta, "bankPoints": bines.contains(bin)});
          tarjetasDropDownAux.add(dropdown.DropdownMenuItem(
              child: Row(
                children: <Widget>[
                  //Text(tipoTarjeta),
                  CardUtils.getCardIcon(() {
                    switch (tipoTarjeta.toLowerCase()) {
                      case "visa":
                        return CardType.Visa;
                        break;
                      case "mastercard":
                        return CardType.Master;
                        break;
                      case "amex":
                        return CardType.AmericanExpress;
                        break;
                      case "american express":
                        return CardType.AmericanExpress;
                        break;
                      default:
                        return CardType.Others;
                    }
                  }()),
                  Text(" **** **** **** " + numTarjeta)
                ],
              ),
              value: idTarjeta));
          tarjetasDropDownValues.add(idTarjeta);
        } on PlatformException catch (e) {
          data = "Failed to get decoded values: '${e.message}'.";
          print(data);
        }
      }
      int lTDD = tarjetasDropDownValues.length;
      if (setLast != null && setLast) {
        if (lTDD < 2) {
          setState(() {
            _cardSelected = tarjetasDropDownValues.first;
            _selectedRegistredCard = 0;
          });
          getToken = true;
        } else {
          setState(() {
            _cardSelected = tarjetasDropDownValues[lTDD - 1];
            _selectedRegistredCard = lTDD - 1;
          });
          getToken = true;
        }
      } else {
        if (lTDD > 0) {
          setState(() {
            _cardSelected = tarjetasDropDownValues.first;
            _selectedRegistredCard = 0;
          });
          getToken = true;
        }
      }
    }
    if (tarjetasDropDownAux.length == 0) {
      tarjetasDropDownAux.add(dropdown.DropdownMenuItem(
          child: Row(children: <Widget>[
            CardUtils.getCardIcon(CardType.Invalid),
            Text(
              " No hay tarjetas guardadas",
              style: TextStyle(color: DataUI.blackText),
            )
          ]),
          value: 'NONE'));
      tarjetasDropDownValues.add('NONE');
      setState(() {
        _cardSelected = tarjetasDropDownValues.first;
        _selectedRegistredCard = 0;
      });
    }
    tarjetasDropDownAux.add(dropdown.DropdownMenuItem(
        child: Row(children: <Widget>[
          CardUtils.getCardIcon(CardType.Others),
          Text(
            " + Agregar forma de pago ",
            style: TextStyle(color: DataUI.chedrauiBlueColor),
          )
        ]),
        value: 'NEW'));
    tarjetasDropDownValues.add('NEW');
    print(decCards);
    setState(() {
      cards = decCards;
      tarjetasDropDown = tarjetasDropDownAux;
    });
    if (getToken) {
      //await getTokenFromSelectedCard();
    }
  }

  static const platform = const MethodChannel('com.cheadrui.com/paymethods');

  Future<bool> setPaypalData() async {
    bool paypalSet = false;
    listPayPalProduct = new List<PayPalProduct>();
    if (_slotsEntrega == null || _currentCart == null) {
      return paypalSet;
    }
    for (var slot in _slotsEntrega['slots']) {
      for (var consignment in _currentCart['consignments']) {
        if (consignment['code'] == slot['consignmentCode']) {
          List entries = consignment['entries'];
          num quantityEntry;
          double finalPrice = 0;

          for (var entry in entries) {
            quantityEntry = 1;
            double number = double.parse(entry['orderEntry']['decimalQty'].toString());
            String nombreProducto = entry['orderEntry']['product']['name'].toString();
            double totalPrice = double.parse(entry['orderEntry']['totalPrice']['value'].toString());
            String code = entry['orderEntry']['product']['unit']['code'].toString();

            double pricePerUnit = double.parse((totalPrice / number).toStringAsFixed(2));

            String descriptor = "";
            if (code == 'PCE') {
              descriptor = '${number.toString()} × ${moneda.format(pricePerUnit)}}';
              quantityEntry = number;
              finalPrice = pricePerUnit;
            } else {
              pricePerUnit = double.parse(entry['orderEntry']['totalPrice']['value'].toStringAsFixed(2)) / number;
              pricePerUnit = double.parse(pricePerUnit.toStringAsFixed(2));
              descriptor = '${number.toStringAsFixed(2)} kg × ${moneda.format(pricePerUnit)} / kg';
              finalPrice = totalPrice;
            }

            PayPalProduct payPalProduct = new PayPalProduct();
            payPalProduct.setSku(entry['orderEntry']['product']['code'].toString());
            payPalProduct.setName(nombreProducto);
            payPalProduct.setDescription(descriptor);
            payPalProduct.setQuantity(quantityEntry);
            payPalProduct.setPrice(finalPrice);

            listPayPalProduct.add(payPalProduct);
          }
        }
      }
    }

    var resultWebView = await getVista();
    paypalSet = true;
    print('resultWebView');
    print(resultWebView);

    return paypalSet;
  }

  generarVista() async {
    var value1 = _slotsEntrega;
    var value2 = _currentCart;

    listPayPalProduct.clear();

    /*
    if (value2['deliveryCost'] != null) {
      deliveryCost = value2['deliveryCost']['value'];
    }
    if (value2['totalDiscounts'] != null) {
      totalDiscounts = value2['totalDiscounts']['value'];
    }
    if (value2['totalPrice']['value'] != null) {
      subTotal = value2['totalPrice']['value'] + totalDiscounts;
    }
    if (value2['totalPriceWithTax']['value'] != null) {
      total = value2['totalPriceWithTax']['value'];
    }
    if (value2['code'] != null) {
      cartCode = value2['code'];
    }
    */

    for (var slot in value1['slots']) {
      for (var consignment in value2['consignments']) {
        if (consignment['code'] == slot['consignmentCode']) {
          List entries = consignment['entries'];
          num quantityEntry;
          double finalPrice = 0;

          for (var entry in entries) {
            quantityEntry = 1;
            double number = double.parse(entry['orderEntry']['decimalQty'].toString());
            String nombreProducto = entry['orderEntry']['product']['name'].toString();
            double totalPrice = double.parse(entry['orderEntry']['totalPrice']['value'].toString());
            String code = entry['orderEntry']['product']['unit']['code'].toString();

            double pricePerUnit = double.parse((totalPrice / number).toStringAsFixed(2));

            String descriptor = "";
            if (code == 'PCE') {
              descriptor = '${number.toString()} × ${moneda.format(pricePerUnit)}}';
              quantityEntry = number;
              finalPrice = pricePerUnit;
            } else {
              pricePerUnit = double.parse(entry['orderEntry']['totalPrice']['value'].toStringAsFixed(2)) / number;
              pricePerUnit = double.parse(pricePerUnit.toStringAsFixed(2));
              descriptor = '${number.toStringAsFixed(2)} kg × ${moneda.format(pricePerUnit)} / kg';
              finalPrice = totalPrice;
            }

            PayPalProduct payPalProduct = new PayPalProduct();
            payPalProduct.setSku(entry['orderEntry']['product']['code'].toString());
            payPalProduct.setName(nombreProducto);
            payPalProduct.setDescription(descriptor);
            payPalProduct.setQuantity(quantityEntry);
            payPalProduct.setPrice(finalPrice);

            listPayPalProduct.add(payPalProduct);
          }
        }
      }
    }

    getVista().then((message) {
      print(message);
    });
  }

  num getMonederoAmount(List paymentInfos) {
    if (paymentInfos != null && paymentInfos.length > 0) {
      num amount;
      paymentInfos.forEach((pi) {
        if (pi['cardType'] != null && pi['cardType']['code'] == 'Monedero') {
          amount = pi['amount'];
        }
      });
      return amount;
    }
    return null;
  }

  fillCartVars(resultCarrito) {
    total = resultCarrito['totalPrice']['value'];
    deliveryCost = resultCarrito['deliveryCost'] != null ? resultCarrito['deliveryCost']['value'].abs() : 0;
    totalDiscounts = resultCarrito['totalDiscounts'] != null ? double.parse(resultCarrito['totalDiscounts']['value'].abs().toStringAsFixed(2)) : 0;
    subTotal = resultCarrito['subTotal']['value'] + totalDiscounts;

    _subTotal = resultCarrito['subTotal'] != null ? resultCarrito['subTotal']['value'] : null;
    _subTotalWithoutDiscount = resultCarrito['subTotalWithoutDiscount'] != null ? resultCarrito['subTotalWithoutDiscount']['value'] : null;
    _totalCouponsAmount = resultCarrito['totalCouponsAmount'] != null ? resultCarrito['totalCouponsAmount']['value'] : null;
    _totalDiscounts = resultCarrito['totalDiscounts'] != null ? resultCarrito['totalDiscounts']['value'] : null;
    _deliveryCost = resultCarrito['deliveryCost'] != null ? resultCarrito['deliveryCost']['value'] : null;
    _totalPrice = resultCarrito['totalPrice'] != null ? resultCarrito['totalPrice']['value'] : null;
    _totalPriceWithTax = resultCarrito['totalPriceWithTax'] != null ? resultCarrito['totalPriceWithTax']['value'] : null;
    _totalTax = resultCarrito['totalTax'] != null ? resultCarrito['totalTax']['value'] : null;
    _totalToPay = resultCarrito['totalToPay'] != null ? resultCarrito['totalToPay']['value'] : null;
    _totalWithoutDiscount = resultCarrito['totalWithoutDiscount'] != null ? resultCarrito['totalWithoutDiscount']['value'] : null;
    _numberOfInstallments = resultCarrito['numberOfInstallments'];
    _productDiscount = resultCarrito['productDiscount'] != null ? resultCarrito['productDiscount']['value'] : null;
    _cardPoints = resultCarrito['cardPoints'];
    _monederoAmount = getMonederoAmount(resultCarrito['paymentInfos']);
  }

  Future<String> getVista() async {
    String value;

    String mode = NetworkData.paypalMode;
    String transactionDescription = "Descripcion de la transaccion";
    String intent = "sale";
    double discount = this.totalDiscounts ?? 0;
    double shipping = this.deliveryCost ?? 0;
    double subtotal = double.parse(((this.subTotal ?? 0) - totalDiscounts).toStringAsFixed(2));
    double tax = 0;
    double total = this.total ?? 0;

    List<dynamic> items = new List<dynamic>();

    for (PayPalProduct elem in listPayPalProduct) {
      items.add(elem.toJson());
    }

    print(items);

    var medioPagoResponse = await MediosPagoService.payment_with_paypal(mode, transactionDescription, intent, items, discount, shipping, subtotal, tax, total);

    print(medioPagoResponse);

    if (medioPagoResponse != null) {
      if (medioPagoResponse["statusOperation"]["code"] == 0) {
        String paypalUrl = medioPagoResponse["data"]["url"];

        /*final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String user = prefs.getString('email');*/

        /*value = await platform.invokeMethod(
            'getVista', {"paypalUrl": paypalUrl, "paymentMethod": paymentMethod, "amount": total, "email": user});*/

        webview = new FlutterWebviewPlugin();

        await webview.launch(paypalUrl, withJavascript: true, clearCache: true);

        webview.onUrlChanged.listen((String url) {
          if (mounted) {
            doByType(url);
          }
        });

        webview.onDestroy.listen((data) {
          print('WEBVIEW DESTROYED');
        }, onError: (err) {
          print('WEBVIEW DESTROYED ON ERROR');
          print(err);
        }, onDone: () {
          print('WEBVIEW DESTROYED ON DONE');
        });
      }
    } else {
      _showResponseDialog('Servicio no disponible');
      setState(() {
        loadingOrder = false;
        currState = StatusCheckout.IDLE;
      });
    }
    print('finish getVista');
    return value;
  }

  Future<bool> addAddressToUser(selectedAddress) async {
    var response = await UserProfileServices.hybrisAddUserAddress(selectedAddress);
    if (response.statusCode == 201) {
      return true;
    } else {
      _showResponseDialog("Hubo un problema con la dirección seleccionada.");
      return false;
    }
  }

  Future<bool> setAddressCart() async {
    setState(() {
      _slotsEntrega = null;
      errDatosContacto = false;
    });

    var resultNewAddress = await CarritoServices.setAddress();

    if (resultNewAddress != null) {
      if (resultNewAddress['errors'] != null) {
        List errorList = [];
        for (var err in resultNewAddress['errors']) {
          String typeErr = err['type'];
          if (typeErr != null) {
            switch (typeErr) {
              case 'InvalidZipCodeError':
                errorList.add('La dirección seleccionada no es válida.');
                break;
              default:
                errorList.add('Hay campos con problemas en la información de contacto: ${err['message']}');
            }
          }
        }
        setState(() {
          errDatosContacto = true;
          isContinueActive = false;
        });
        _showResponseDialog(errorList.join('\n'), title: 'Datos de contacto');
        return false;
      }
    }

    var resultDeliveryMode = await CarritoServices.setDeliveryModeCart();

    if (isLoggedIn) {
      if (resultDeliveryMode != null) {
        if (resultDeliveryMode['errors'] != null) {
          List errorList = [];
          for (var err in resultDeliveryMode['errors']) {
            String typeErr = err['type'];
            if (typeErr != null) {
              switch (typeErr) {
                case 'InvalidZipCodeError':
                  errorList.add('La dirección seleccionada no es válida.');
                  break;
                case 'AccessDeniedError':
                  errorList.add('El servicio no está disponible en este momento. Por favor intente más tarde.');
                  break;
                default:
                  errorList.add('Hay campos con problemas en la información de contacto.');
              }
            }
          }
          setState(() {
            errDatosContacto = true;
            isContinueActive = false;
          });
          _showResponseDialog(errorList.join('\n'), title: 'Datos de contacto');
          return false;
        } else if (resultDeliveryMode['cartModifications'] != null) {
          List<dynamic> cartMod = resultDeliveryMode['cartModifications'];
          List<String> articulos = [];
          cartMod.forEach((mod) {
            if (mod['statusCode'] != "success") articulos.add(mod['entry']['product']['name']);
          });
          if (articulos.length > 0) {
            //_showResponseDialog("Los siguientes artículos pudieron haber sufrido cambios debido al cambio de dirección:\n" + articulos.join('\n'), title: 'Cambio de artículos');
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Productos faltantes"),
                    content: Text("Los siguientes artículos pudieron haber sufrido cambios debido al cambio de dirección:\n" + articulos.join('\n')),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Regresar al carrito",
                          style: TextStyle(
                            color: DataUI.chedrauiBlueColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Continuar",
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
        }
      }
    }

    return true;
  }

  getTimeSlots() async {
    final translator = new GoogleTranslator();
    print('GETTIMESLOTS');
    var resultTimeslots = await CarritoServices.getCurrentCartTimeSlots();
    if (resultTimeslots['errors'] != null && resultTimeslots['result'] != 'done') {
      List errosTimeSlots = resultTimeslots['errors'];
      List msgErrors = [];
      await Future.forEach(errosTimeSlots, (e) async {
        var s = await translator.translate(e['message'], to: 'es');
        msgErrors.add(s);
      });
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Se presentaron los siguientes errores al procesar sus productos:\n\n" + msgErrors.join('\n')),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Regresar al carrito",
                    style: TextStyle(
                      color: DataUI.chedrauiBlueColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            );
          });
      return;
    }
    setState(() {
      _slotsEntrega = resultTimeslots;
    });
    var resultCarrito = await CarritoServices.getCart();
    setState(() {
      _currentCart = resultCarrito;
      itemsCount = resultCarrito['entries'].length;
      cartCode = resultCarrito['code'];

      fillCartVars(resultCarrito);
    });
    var stores = await PaymentServices.getAssociatedStores(resultCarrito['code']);
    setState(() {
      establecimientosAsociados = stores;
    });
    print('ENDGETTIMESLOTS');
    currState = StatusCheckout.IDLE;
  }

  checkUrlType(String url) async {
    if (url == null) {
      currentType = "NONE";
    } else if (url.contains("home") || url.contains("myaccount")) {
      currentType = "RETURN";
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
    print('<<<<<<<<<<<<<<<<<<<<<<<<<<');
    print("Url:");
    print(url);
    print("Tipo Url:");
    print(currentType);
    print('>>>>>>>>>>>>>>>>>>>>>>>>>>');
  }

  doByType(String url) async {
    checkUrlType(url);
    switch (this.currentType) {
      case "NONE":
        return;
      case "BLANK":
        return;
      case "RETURN":
        cancel(false);
        return;
      case "ERROR":
        cancel(true);
        return;
      case "CONFIRMACION_PAGO":
        print("doByType - CONFIRMACION_PAGO: $url");
        verifyAuthorization(url);
        return;
      default:
        return;
    }
  }

  cancel(bool error) async {
    await webview.close();
    webview.dispose();
    if (error) _showResponseDialog("Ocurrió un problema durante la ejecución de la transacción");
    setState(() {
      loadingOrder = false;
    });
  }

  verifyAuthorization(String url) async {
    if (url == null) return;
    Map<String, dynamic> authParams = await getParametersFromUrl(url);

    print("authParams: $authParams");

    if (authParams != null && authParams['token'] != null && _flagPaypalProcess) {
      _flagPaypalProcess = false;
      print("verifyAuthorization: todo OK");
      //finalizaActividad(authParams);
      finalizarActividadSetPaypal(authParams);
    } else {
      print("La url de confirmacion no presenta parametros.");
      finalizarActividadSetPaypal(null);
    }
    setState(() {
      loadingOrder = false;
    });
  }

  Future<Map<String, dynamic>> getParametersFromUrl(String url) async {
    Map<String, dynamic> paramValues = new Map<String, dynamic>();

    if (url == "about:blank") {
      print("Proceso terminado ir a la siguiente pantalla");
    } else if (url.contains("payerID") || url.contains("token") && url.contains("paymentId")) {
      var urlSeparated = url.split("?");
      print(urlSeparated);
      var params = urlSeparated[1].split("&");

      paramValues.putIfAbsent("paymentMethod", () => "paypal");
      paramValues.putIfAbsent("amount", () => total.toStringAsFixed(2));
      //paramValues.putIfAbsent("amount", () => 200.00);

      for (String val in params) {
        List<String> values = val.split("=");

        if (values[0].toLowerCase().startsWith("token")) {
          paramValues.putIfAbsent("token", () => values[1]);
          //paramValues.putIfAbsent("token", () => "EC-k25ufjasfekknmj49ztq");
        }

        if (values[0].toLowerCase().startsWith("payerid")) {
          paramValues.putIfAbsent("paypalId", () => values[1]);
          //paramValues.putIfAbsent("paypalId", () => "ZSDSFADFDA");
        }
      }

      final String user = prefs.getString('email');

      paramValues.putIfAbsent("paypalAccount", () => user);
      //paramValues.putIfAbsent("paypalAccount", () => "xyz.abc@hybris.com");
    }
    return paramValues;
  }

  finalizarActividadSetPaypal(Map<String, dynamic> authParams) async {
    if (authParams != null) {
      print("entro finalizaActividad()");
      var setPaymentResult;
      try {
        setPaymentResult = await PaymentServices.setPaymentMethod(authParams, cartCode);
        print(setPaymentResult);
        currState = StatusCheckout.IDLE;
        var resultCarrito = await CarritoServices.getCart();
        setState(() {
          fillCartVars(resultCarrito);
          _isButtonDisabled = false;
          _finishEditing = true;
        });
      } catch (e) {
        print(e);
      } finally {
        await this.webview.close();
        webview.dispose();
        print("despues close()");
        _flagPaypalProcess = true;
      }
      if (setPaymentResult == null) {
        _showResponseDialog("Error al procesar el pago con PayPal");
      }
      setState(() {
        loadingOrder = false;
      });
    } else {
      currState = StatusCheckout.IDLE;
      setState(() {
        loadingOrder = false;
      });
      _showResponseDialog("Error al procesar el pago con PayPal");
    }
  }

  finalizaActividad(Map<String, dynamic> authParams) async {
    print("entro finalizaActividad()");
    var setPaymentResult;
    var orderData;

    try {
      setPaymentResult = await PaymentServices.setPaymentMethod(authParams, cartCode);
      print(setPaymentResult);
      orderData = await PaymentServices.placeOrder(cartCode);
    } catch (e) {
      print(e);
    } finally {
      print("=================> orderData: $orderData");
      await this.webview.close();
      webview.dispose();
      //this.webview.dispose();
      print("despues close()");
      _flagPaypalProcess = true;
    }
    if (orderData != null) {
      await FireBaseEventController.sendAnalyticsEventEcommercePurchase(orderData, 'PayPal', _totalPagoMonedero, _saldoMonedero - _totalPagoMonedero);
      await Navigator.push(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: DataUI.checkoutConfirmationRoute),
          builder: (context) => CheckoutConfirmationPage(paymentMethod: PaymentMethod.paypal, orderData: orderData, shippingData: tiendasEntrega, shippingDatetime: horarioEntregaTextForOrder, monederoData: _totalPagoMonedero, additionalData: null),
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
    } else {
      _showResponseDialog("Error al procesar el pago con PayPal");
    }
    setState(() {
      loadingOrder = false;
    });
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
    try {
      final idWalletPrefs = prefs.getString('idWallet');
      idWallet = idWalletPrefs;
      if (idWallet != null) {
        List monederos = await MonederoServices.getIdMonedero(idWallet);
        if (monederos.length > 0) {
          String idMonedero = monederos[0]['monedero'];
          _idMonedero = idMonedero;
          /*
          var resultadoMonedero = await MonederoServices.getSaldoMonedero(idMonedero);
          if (resultadoMonedero != null && resultadoMonedero['resultado'] != null && resultadoMonedero['resultado']['saldo'] != null) {
            setState(() {
              monedero = true;
              _saldoMonedero = resultadoMonedero['resultado']['saldo'];
            });
          }
          */
          try {
            var saldoResult = await MonederoServices.getSaldoMonederoRCS(idMonedero);
            if (saldoResult != null && saldoResult["CodigoRes"] == "200" && saldoResult["DatosRCS"] != null) {
              setState(() {
                monedero = true;
                _saldoMonedero = double.parse(saldoResult["DatosRCS"]["Monto"]);
              });
            } else {
              throw new Exception("Not a valid object");
            }
          } catch (e) {
            print(e);
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getSessionStatus() async {
    Map<String, dynamic> session = await CarritoServices.getSessionVars();
    setState(() {
      isLoggedIn = session['isLoggedIn'];
      isPickUp = session['isPickUp'];
      idWallet = session['idWallet'];
      sessionDataLoaded = true;
    });
  }

  void hideSubtitleStep1(bool hide) {
    setState(() {
      addressSet = hide;
    });
  }

  void setNewNotes(String notes) {
    setState(() {
      _currentNotes = notes;
    });
  }

  String processPhone(String phone) {
    phone.replaceAll("+521", "");
    return phone;
  }

  void setNewDeliveryAddress(var selectedAddress, {bool continueActive = true}) async {
    _scrollController.animateTo(_scrollController.position.minScrollExtent, duration: Duration(milliseconds: 100), curve: Curves.easeIn);
    if (selectedAddress != null) {
      newAddressSelected = selectedAddress['id'] == null;
      newAddressInfo = selectedAddress;
      String addressId = selectedAddress['id'];
      if (selectedAddress['id'] != null) prefs.setString('delivery-address-id', selectedAddress['id']);
      prefs.setString('delivery-userName', selectedAddress['firstName']);
      prefs.setString('delivery-userLastName', selectedAddress['lastName']);
      prefs.setString('delivery-telefono', processPhone(selectedAddress['phone']));
      prefs.setString('delivery-direccion', selectedAddress['line1']);
      prefs.setString('delivery-numInterior', selectedAddress['line2']);
      prefs.setString('delivery-estado', selectedAddress['region']['name']);
      prefs.setString('delivery-isocode', selectedAddress['region']['isocode']);
      prefs.setString('delivery-sublocality', selectedAddress['town']);
      prefs.setString('delivery-codigoPostal', selectedAddress['postalCode']);
      prefs.setString('delivery-formatted_address', "${selectedAddress['line1']}, ${selectedAddress['line2']}, ${selectedAddress['town']} ${selectedAddress['region']['name']} ${selectedAddress['postalCode']}");
      setState(() {
        personalInfo.nombre = prefs.getString('delivery-userName');
        personalInfo.paterno = prefs.getString('delivery-userLastName');
        personalInfo.materno = prefs.getString('delivery-userSecondLastName');
        personalInfo.telefono = prefs.getString('delivery-telefono');
        personalInfo.email = prefs.getString('delivery-email');
        personalInfo.direccion = prefs.getString('delivery-direccion');
        personalInfo.numInterior = prefs.getString('delivery-numInterior');
        personalInfo.estado = prefs.getString('delivery-estado');
        personalInfo.isocode = prefs.getString('delivery-isocode');
        personalInfo.colonia = prefs.getString('delivery-sublocality');
        personalInfo.cpostal = prefs.getString('delivery-codigoPostal');
        nonRegistredAddress = addressId == null;
        isContinueActive = continueActive;
        addressSet = true;
      });
    } else {
      //prefs.remove('delivery-address-id');
      setState(() {
        nonRegistredAddress = true;
        isContinueActive = false;
        addressSet = false;
      });
    }
    currState = StatusCheckout.IDLE;
  }

  void setUserData(bool setAddress, PersonalInformationData infoPerson) async {
    _scrollController.animateTo(_scrollController.position.minScrollExtent, duration: Duration(milliseconds: 100), curve: Curves.easeIn);
    if (setAddress) {
      //if (infoPerson.nombre != null && infoPerson.paterno != null && infoPerson.materno != null && infoPerson.telefono != null && infoPerson.email != null) {
      prefs.setString('delivery-userName', infoPerson.nombre);
      prefs.setString('delivery-userLastName', infoPerson.paterno);
      prefs.setString('delivery-userSecondLastName', infoPerson.materno);
      prefs.setString('delivery-telefono', infoPerson.telefono);
      prefs.setString('email', infoPerson.email);
      //}
    }
    setState(() {
      if (infoPerson != null) {
        personalInfo.nombre = infoPerson.nombre;
        personalInfo.paterno = infoPerson.paterno;
        personalInfo.materno = infoPerson.materno;
        personalInfo.telefono = infoPerson.telefono;
        personalInfo.email = infoPerson.email;
      }
      addressSet = setAddress;
      isContinueActive = setAddress;
    });
    currState = setAddress ? StatusCheckout.IDLE : StatusCheckout.LOADING_STEP;
  }

  Future<void> getPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      personalInfo.nombre = prefs.getString('delivery-userName');
      personalInfo.paterno = prefs.getString('delivery-userLastName');
      personalInfo.materno = prefs.getString('delivery-userSecondLastName');
      personalInfo.telefono = prefs.getString('delivery-telefono');
      personalInfo.email = prefs.getString('delivery-email');
      personalInfo.direccion = prefs.getString('delivery-direccion');
      personalInfo.numInterior = prefs.getString('delivery-numInterior');
      personalInfo.estado = prefs.getString('delivery-estado');
      personalInfo.isocode = prefs.getString('delivery-isocode');
      personalInfo.colonia = prefs.getString('delivery-sublocality');
      personalInfo.cpostal = prefs.getString('delivery-codigoPostal');
    });
    currState = StatusCheckout.LOADING_STEP;
  }

  Future<void> getCurrentUserCart() async {
    cart = CarritoServices.getCart().then((resultCarrito) {
      setState(() {
        _currentCart = resultCarrito;
        _currentNotes = resultCarrito['comment'];
      });
    });
  }

  Future<void> cleanPaymentMethod() async {
    await PaymentServices.cleanPaymentMethod();
  }

  void _showSnackBar(BuildContext context, String text) {
    Flushbar(
      message: text,
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

  Future<void> initCheckout() async {
    await getPrefs();
    await getSessionStatus();
    await getDeviceID();
    await cleanPaymentMethod();
    await getCurrentUserCart();
  }

  @override
  initState() {
    _paymentCard.type = CardType.Others;
    numberController.addListener(_getCardTypeFrmNumber);
    _isButtonDisabled = true;
    initCheckout();
    super.initState();
    textCheckout();
  }

  List<stepper.Step> steps;
  List<stepper.Step> buildSteps() {
    steps = [
      stepper.Step(
          isActive: currStep == 0,
          state: currStep == 0 ? stepper.StepState.editing : (errDatosContacto ? stepper.StepState.error : stepper.StepState.complete),
          title: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: '1. Información de contacto',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                /*
                TextSpan(
                  text: currStep > 0 ? ' (Cambiar)' : '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.blue,
                  ),
                ),
                */
              ],
            ),
          ),
          subtitle: Container(
              padding: EdgeInsets.only(left: 20, top: 15, right: 0),
              alignment: Alignment.centerLeft,
              child: prefs != null
                  ? (currStep != 0 || addressSet
                      ? Row(
                          children: <Widget>[
                            Flexible(
                                flex: 5,
                                fit: FlexFit.tight,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    /*
                          Text(
                            "${prefs.getString('delivery-userName') ?? ''} ${prefs.getString('delivery-userLastName') ?? ''}",
                            style: TextStyle(fontSize: 16, color: DataUI.blackText),
                          ),
                          !isPickUp ? Text("${prefs.getString('delivery-direccion') ?? ''}") : SizedBox(height: 0),
                          !isPickUp ? Text("${prefs.getString('delivery-sublocality') ?? ''} ${prefs.getString('delivery-estado') ?? ''} ${prefs.getString('delivery-codigoPostal') ?? ''}") : SizedBox(height: 0),
                          Text("${prefs.getString('delivery-telefono') ?? ''} ${prefs.getString('email') ?? ''}"),
                          */
                                    Text(
                                      "${personalInfo.nombre ?? ''} ${personalInfo.paterno ?? ''}",
                                      style: TextStyle(fontSize: 16, color: DataUI.blackText),
                                    ),
                                    !isPickUp ? Text("${personalInfo.direccion ?? ''}") : SizedBox(height: 0),
                                    !isPickUp ? Text("${personalInfo.colonia ?? ''} ${personalInfo.estado ?? ''} ${personalInfo.cpostal ?? ''}") : SizedBox(height: 0),
                                    Text("${personalInfo.telefono ?? ''} ${prefs.getString('email') ?? ''}"),
                                    _currentNotes != null ? Text("Notas: " + _currentNotes) : SizedBox(height: 0),
                                  ],
                                )),
                            /*
                    (nonRegistredAddress && isLoggedIn) ? Flexible(
                      flex: 2,
                      fit: FlexFit.tight,
                      child: FlatButton(
                        onPressed: () async{
                          String secondLastName = prefs.getString('delivery-userSecondLastName').trim() != "" ? 
                          prefs.getString('delivery-userSecondLastName') : 
                          "Sin información";
                          Map <String, dynamic> nonRegAddress = {
                            "country": {"isocode": "MX"},
                            "firstName": prefs.getString('delivery-userName'),
                            "lastName": prefs.getString('delivery-userLastName'),
                            "secondLastName": secondLastName,
                            "line1": prefs.getString('delivery-direccion') != null ? 
                              prefs.getString('delivery-direccion') :
                              "${prefs.getString('delivery-route')} ${prefs.getString('delivery-streetNumber')}",
                            "line2": prefs.getString('delivery-numInterior') != ""
                                ? prefs.getString('delivery-numInterior')
                                : "N/A",
                            "postalCode": prefs.getString('delivery-codigoPostal'),
                            "region": {
                              "isocode": prefs.getString('delivery-isocode'),
                              "name": prefs.getString('delivery-estado')
                            },
                            "town": prefs.getString('delivery-sublocality'),
                            "phone": prefs.getString('delivery-telefono'),
                          };
                          Address a = Address.fromJson(nonRegAddress);
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              settings: RouteSettings(name: DataUI.deliveryMethodRoute),
                              builder: (context) => EditAddressPage(address: a),
                            ),
                          );
                          if(result == 'direcciones'){
                            Navigator.pop(context,'bounce');
                            //Navigator.pushNamed(context, DataUI.checkoutRoute);
                          }
                        },
                        child: Text(
                          "Editar y guardar",
                          style: TextStyle(
                            color: DataUI.chedrauiBlueColor
                          ),
                          textAlign: TextAlign.end
                        )
                      )
                    ) : SizedBox(height: 0,)
                    */
                          ],
                        )
                      : SizedBox(
                          height: 0,
                        ))
                  : SizedBox(height: 0)),
          content: sessionDataLoaded
              ? ((isLoggedIn && !isPickUp && prefs != null)
                  ? AddressesRegistredUserWidget(
                      callback: setNewDeliveryAddress,
                      callbackForm: hideSubtitleStep1,
                      callbackNotas: setNewNotes,
                    )
                  : PersonalInfo(
                      isLoggedIn: isLoggedIn,
                      isPickUp: isPickUp,
                      callback: setUserData,
                      callbackNotas: setNewNotes,
                    ))
              : Center(child: CircularProgressIndicator()),
          modify: currState != StatusCheckout.LOADING_STEP
              ? Container(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(
                    isLoggedIn ? "Modificar" : "Editar",
                    style: TextStyle(color: DataUI.chedrauiBlueColor, fontSize: 14),
                    textAlign: TextAlign.right,
                  ),
                ]))
              : SizedBox(
                  height: 0,
                )),
      stepper.Step(
          isActive: currStep == 1,
          state: currStep == 1 ? stepper.StepState.editing : currStep > 1 ? stepper.StepState.complete : stepper.StepState.indexed,
          title: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: '2. Información de Entrega',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                /*
              TextSpan(
                text: currStep > 1 ? ' (Cambiar)' : '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.blue,
                ),
              ),
              */
              ],
            ),
          ),
          subtitle: Container(
              padding: EdgeInsets.only(left: 20, top: 15, right: 60),
              alignment: Alignment.centerLeft,
              child: _slotsEntrega != null && _consignments != null && slotsList != null
                  ? ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: _slotsEntrega['slots'].length,
                      itemBuilder: (BuildContext context, int index) {
                        final int slotsNumber = _slotsEntrega['slots'][index]['slots'].length;
                        final int enviosNumber = _consignments[index]['entries'].length;
                        final String storeNameRaw = _slotsEntrega['slots'][index]['warehouseName'];
                        final List storeNameList = storeNameRaw.split(' ');
                        final String storeName = (() {
                          List capNames = [];
                          storeNameList.forEach((p) {
                            String pL = p.toString();
                            pL = pL.toLowerCase();
                            capNames.add(capitalize(pL));
                          });
                          return capNames.join(' ');
                        })();
                        String timeInterval;
                        if (slotsList.length > 0) {
                          final DateTime timeFromRaw = DateTime.parse(slotsList[0]['timeFrom'].split('+')[0] + ".000Z");
                          final DateTime timeToRaw = DateTime.parse(slotsList[0]['timeTo'].split('+')[0] + ".000Z");
                          timeInterval = () {
                            DateTime timeFromLocal = timeFromRaw.toLocal();
                            DateTime timeToLocal = timeToRaw.toLocal();
                            DateTime today = DateTime.now();
                            String toAMPM(h) {
                              if (h < 13) {
                                return "${h.toString()}am";
                              } else {
                                return "${(h - 12).toString()}pm";
                              }
                            }

                            ;
                            int hfi = timeFromLocal.hour;
                            int hti = timeToLocal.hour;
                            String hfs = toAMPM(hfi);
                            String hts = toAMPM(hti);
                            if (today.day == timeFromLocal.day) {
                              return 'Hoy $hfs-$hts';
                            } else if (today.day + 1 == timeFromLocal.day) {
                              return 'Mañana $hfs-$hts';
                            } else {
                              return '${timeFromLocal.day.toString()}/${timeFromLocal.month.toString()} $hfs-$hts';
                            }
                          }();
                        } else {
                          timeInterval = 'Entre 5 y 7 días håbiles';
                        }
                        return Container(
                          padding: EdgeInsets.only(top: 2, bottom: 2),
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              //Text(_slotsEntrega['slots'][index]['slots'].length.toString()),
                              //Text(_slotsEntrega['slots'][index]['warehouseName']),
                              //Text(_consignments[index]['entries'].length.toString()),
                              //Text(slotsList[0].toString()),
                              Row(
                                children: <Widget>[
                                  Flexible(
                                      flex: 2,
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 5),
                                        child: isPickUp
                                            ? Image.asset('assets/store.png', width: 20)
                                            : (slotsNumber > 0
                                                ? Container(
                                                    width: 30,
                                                    child: DeliverIcon(height: 15, width: 15),
                                                  )
                                                : Image.asset('assets/094711179f@3x.png', width: 30)),
                                      )),
                                  Flexible(
                                      flex: 8,
                                      fit: FlexFit.tight,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 5, right: 5),
                                        child: Text(
                                          storeName,
                                          style: TextStyle(
                                            color: DataUI.blackText,
                                            fontSize: 10,
                                          ),
                                        ),
                                      )),
                                  Flexible(
                                    flex: 4,
                                    child: Text(
                                      "${enviosNumber.toString()} Producto${enviosNumber > 1 ? 's' : ''}",
                                      style: TextStyle(color: DataUI.blackText, fontSize: 10),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Flexible(
                                    flex: 3,
                                    child: SizedBox(
                                      height: 0,
                                      width: 40,
                                    ),
                                  ),
                                  Flexible(
                                    flex: 10,
                                    child: Text(
                                      slotsNumber > 0 ? timeInterval : "Entre 5 y 7 días hábiles",
                                      style: TextStyle(color: DataUI.blackText, fontSize: 8),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : SizedBox(
                      height: 0,
                    )),
          content: Container(
            padding: const EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: Offset(2.0, 1.0),
                  blurRadius: 8.0,
                ),
              ],
            ),
            child: Column(children: <Widget>[
              Form(
                  key: _formKeys[2],
                  child: !errDatosContacto
                      ? (_currentCart != null && _currentCart['consignments'] != null && _slotsEntrega != null
                          ? ConsigmentWidget(slotsList: _slotsEntrega['slots'], carrito: _currentCart, isPickUp: isPickUp, callback: setCurrentConsigments)
                          : SizedBox(
                              height: 50,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ))
                      : Container(
                          width: double.infinity,
                          child: Text(
                            "Por favor revise la información de contacto",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ))
            ]),
          ),
          modify: currState != StatusCheckout.LOADING_STEP
              ? Container(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(
                    isLoggedIn ? "Modificar" : "Editar",
                    style: TextStyle(color: DataUI.chedrauiBlueColor, fontSize: 14),
                    textAlign: TextAlign.right,
                  ),
                ]))
              : SizedBox(
                  height: 0,
                )),
      stepper.Step(
          title: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: '3. Información de pago',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                /*
              TextSpan(
                text: _finishEditing ? ' (Cambiar)' : '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.blue,
                ),
              ),
              */
              ],
            ),
          ),
          subtitle: Container(
            padding: EdgeInsets.only(left: 20, top: 15, right: 60),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _monederoAmount != null && _monederoAmount > 0
                    ? Row(
                        children: <Widget>[
                          Flexible(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.only(left: 5, right: 15),
                                child: Image.asset("assets/monedero_azul.png", height: 22, width: 22, fit: BoxFit.contain),
                              )),
                          Flexible(
                            flex: 4,
                            child: Text(
                              //"Mi Monedero Chedraui: " + moneda.format(_totalPagoMonedero),
                              "Mi Monedero Chedraui: " + moneda.format(_monederoAmount),
                              style: TextStyle(color: DataUI.blackText, fontSize: 14),
                            ),
                          )
                        ],
                      )
                    : SizedBox(
                        height: 0,
                      ),
                payMethod == PaymentMethod.card && _paymentCard != null
                    ? Row(
                        children: <Widget>[
                          Flexible(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.only(left: 5, right: 15),
                                child: CardUtils.getCardIcon(_paymentCard.type),
                              )),
                          Flexible(
                            flex: 4,
                            child: Text(
                              _paymentCard.number != null && _paymentCard.number.length >= 12 ? "**** " + _paymentCard.number.substring(12) : '',
                              style: TextStyle(color: DataUI.blackText, fontSize: 14),
                            ),
                          )
                        ],
                      )
                    : SizedBox(
                        height: 0,
                      ),
                payMethod == PaymentMethod.registredCard && cards != null && cards.length > 0
                    ? Row(
                        children: <Widget>[
                          Flexible(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.only(left: 5, right: 15),
                                child: CardUtils.getCardIcon(() {
                                  switch (cards[_selectedRegistredCard]['tipoTarjeta'].toLowerCase()) {
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
                              )),
                          Flexible(
                            flex: 4,
                            child: Text(
                              "**** " + cards[_selectedRegistredCard]['numTarjeta'],
                              style: TextStyle(color: DataUI.blackText, fontSize: 14),
                            ),
                          )
                        ],
                      )
                    : SizedBox(
                        height: 0,
                      ),
                payMethod == PaymentMethod.paypal
                    ? Row(
                        children: <Widget>[
                          Flexible(
                              flex: 3,
                              child: Padding(
                                padding: EdgeInsets.only(left: 5, right: 15),
                                child: PayPalSVG(30),
                              )),
                          Flexible(
                            flex: 4,
                            child: Text(
                              "",
                              style: TextStyle(color: DataUI.blackText, fontSize: 14),
                            ),
                          )
                        ],
                      )
                    : SizedBox(
                        height: 0,
                      ),
                payMethod == PaymentMethod.associatedStore
                    ? Row(
                        children: <Widget>[
                          Flexible(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.only(left: 5, right: 15),
                                child: Image.asset('assets/store.png', width: 20),
                              )),
                          Flexible(
                            flex: 4,
                            child: Text(
                              "En establecimiento asociado",
                              style: TextStyle(color: DataUI.blackText, fontSize: 14),
                            ),
                          )
                        ],
                      )
                    : SizedBox(
                        height: 0,
                      ),
                payMethod == PaymentMethod.onDelivery
                    ? Row(
                        children: <Widget>[
                          Flexible(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.only(left: 5, right: 15),
                                child: (() {
                                  switch (_selectedOnDeliverPayMethod) {
                                    case 0:
                                      return CardVisa(20, 30, false);
                                      break;
                                    case 1:
                                      return CardMasterCard(20, 30, false);
                                      break;
                                    case 2:
                                      return CardAmex(20, 30, false);
                                      break;
                                    case 3:
                                      return CardCash(20, 30, false);
                                      break;
                                    case 4:
                                      return CardEcoupon(20, 30, false);
                                      break;
                                    default:
                                      return DeliverIcon();
                                  }
                                })(),
                              )),
                          Flexible(
                            flex: 4,
                            child: Text(
                              "Contra entrega (" +
                                  (() {
                                    switch (_selectedOnDeliverPayMethod) {
                                      case 0:
                                        return 'Visa';
                                        break;
                                      case 1:
                                        return 'Mastercard';
                                        break;
                                      case 2:
                                        return 'American Express';
                                        break;
                                      case 3:
                                        return 'Efectivo';
                                        break;
                                      case 4:
                                        return 'Vales';
                                        break;
                                      default:
                                        return '';
                                    }
                                  })() +
                                  ")",
                              style: TextStyle(color: DataUI.blackText, fontSize: 14),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(
                        height: 0,
                      ),
                payMethod == PaymentMethod.onStore
                    ? Row(
                        children: <Widget>[
                          Flexible(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.only(left: 5, right: 15),
                              child: Image.asset('assets/store.png', width: 20),
                            ),
                          ),
                          Flexible(
                            flex: 4,
                            child: Text(
                              "En otra tienda",
                              style: TextStyle(color: DataUI.blackText, fontSize: 14),
                            ),
                          )
                        ],
                      )
                    : SizedBox(
                        height: 0,
                      ),
              ],
            ),
          ),
          isActive: currStep == 2,
          state: currStep == 2 && !_finishEditing ? stepper.StepState.editing : _finishEditing ? stepper.StepState.complete : stepper.StepState.indexed,
          content: paymentMethods == null
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: Offset(2.0, 1.0),
                        blurRadius: 8.0,
                      ),
                    ],
                  ),
                  height: 50,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: Offset(2.0, 1.0),
                        blurRadius: 8.0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      Form(
                        autovalidate: true,
                        key: _formKeys[1],
                        child: ListTileTheme(
                          contentPadding: const EdgeInsets.all(0.0),
                          child: Column(children: <Widget>[
                            !(monedero == true && monederoAllowed == true)
                                ? SizedBox(
                                    height: 0,
                                  )
                                : CheckboxListTile(
                                    activeColor: DataUI.chedrauiColor,
                                    controlAffinity: ListTileControlAffinity.leading,
                                    title: const Text(
                                      'Usar saldo de Monedero Mi Chedraui',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    value: monederoSelected,
                                    onChanged: (bool value) {
                                      if (_saldoMonedero > 0) {
                                        if (monederoSelected && _pagoMonederoExitoso) {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text("Pago con monedero"),
                                                  content: Text("Desea retirar el saldo utilizado de su compra?"),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                      onPressed: () {
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
                                                        Navigator.pop(context);
                                                        setState(() {
                                                          _monederoAmount = 0;
                                                          _totalPagoMonedero = 0;
                                                          _loadingMonedero = true;
                                                          currState = StatusCheckout.LOADING_STEP;
                                                        });
                                                        await cleanPaymentMethod();
                                                        await getMonedero();
                                                        setState(() {
                                                          _loadingMonedero = false;
                                                          monederoSelected = !monederoSelected;
                                                          currState = StatusCheckout.IDLE;
                                                        });
                                                        /*
                                                      var resultPagoMonedero = await setPaymentMonedero();
                                                      setState(() {
                                                        _loadingMonedero = false;
                                                      });
                                                      if (resultPagoMonedero != null) {
                                                        _pagoMonederoExitoso = false;
                                                        saldoMonederoController.clear();
                                                        await getMonedero();
                                                      } else {
                                                        _showResponseDialog("Ha ocurrido un problema al aplicar el pago con monedero");
                                                      }
                                                      */
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
                                        } else {
                                          setState(() {
                                            monederoSelected = !monederoSelected;
                                            isContinueActive = (monederoSelected || paymentData != null);
                                          });
                                        }
                                      }
                                    },
                                  ),
                            monederoSelected
                                ? CheckboxListTile(
                                    activeColor: DataUI.chedrauiColor,
                                    controlAffinity: ListTileControlAffinity.leading,
                                    title: const Text(
                                      'Remover otros métodos de pago',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    value: onlyMonederoSelected,
                                    onChanged: (bool value) {
                                      setState(() {
                                        onlyMonederoSelected = value;
                                        if (value) {
                                          payMethod = null;
                                        }
                                      });
                                    },
                                  )
                                : SizedBox(
                                    height: 0,
                                  ),
                            monedero
                                ? Theme(
                                    data: ThemeData(
                                      primaryColor: Colors.black,
                                      hintColor: HexColor('#C4CDD5'),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.only(left: 40, right: 15),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 2,
                                                child: Image.asset("assets/monedero_azul.png", height: 22, width: 22, fit: BoxFit.contain),
                                              ),
                                              Expanded(
                                                flex: 7,
                                                child: Text(
                                                  "**** " + _idMonedero.substring(12),
                                                  style: TextStyle(fontSize: 12),
                                                  textAlign: TextAlign.start,
                                                ),
                                              ),
                                              /*
                                                Expanded(
                                                  flex: 6,
                                                  child: FlatButton(
                                                    onPressed: (){
                                                    },
                                                    child: Text(
                                                      "Recargar Monedero",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: DataUI.chedrauiBlueColor
                                                      ),
                                                    )
                                                  ),
                                                ),
                                                */
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 5, bottom: 10, left: 8),
                                            child: Text(
                                              "Saldo total: ${moneda.format(_saldoMonedero)}",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          _pagoMonederoExitoso
                                              ? Padding(
                                                  padding: const EdgeInsets.only(top: 5, bottom: 10, left: 8),
                                                  child: Text(
                                                    "Monto a utilizar: ${moneda.format(_totalPagoMonedero)}",
                                                    style: TextStyle(fontSize: 12),
                                                  ),
                                                )
                                              : SizedBox(
                                                  height: 0,
                                                ),
                                          _saldoMonedero > 0
                                              ? Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 8,
                                                        child: TextField(
                                                            decoration: InputDecoration(
                                                              filled: true,
                                                              hintText: "Ingresa una cantidad",
                                                              fillColor: HexColor('#F4F6F8'),
                                                              border: OutlineInputBorder(),
                                                              contentPadding: const EdgeInsets.only(
                                                                  top: 12,
                                                                  bottom: 12,
                                                                  left: 6, //todo
                                                                  right: 6 //todo
                                                                  ),
                                                            ),
                                                            keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
                                                            inputFormatters: [
                                                              TextInputFormatter.withFunction((oldV, newV) {
                                                                Pattern pattern = r'^(\d*)(\.\d{0,2})?$';
                                                                RegExp regex = new RegExp(pattern);
                                                                if (regex.hasMatch(newV.text)) {
                                                                  return TextEditingValue(text: newV.text, selection: TextSelection.collapsed(offset: newV.selection.end));
                                                                } else {
                                                                  return TextEditingValue(text: oldV.text, selection: TextSelection.collapsed(offset: oldV.selection.end));
                                                                }
                                                              })
                                                            ],
                                                            onChanged: (String input) {
                                                              try {
                                                                _saldoAUtilizarMonedero = num.parse(input);
                                                              } catch (e) {
                                                                _saldoAUtilizarMonedero = 0;
                                                              }
                                                            },
                                                            enabled: monederoSelected,
                                                            textInputAction: TextInputAction.go,
                                                            controller: saldoMonederoController,
                                                            focusNode: monederoFocusNode)),
                                                    Expanded(
                                                      flex: 6,
                                                      child: Container(
                                                        margin: const EdgeInsets.only(left: 10),
                                                        child: RaisedButton(
                                                          disabledColor: DataUI.chedrauiBlueColor.withOpacity(0.5),
                                                          padding: EdgeInsets.symmetric(vertical: 12),
                                                          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                                                          onPressed: !monederoSelected
                                                              ? null
                                                              : () async {
                                                                  FocusScope.of(context).requestFocus(new FocusNode());
                                                                  if (_saldoMonedero < _saldoAUtilizarMonedero || _saldoMonedero == 0) {
                                                                    _showResponseDialog("El saldo de monedero es insuficiente.");
                                                                  } else {
                                                                    setState(() {
                                                                      _totalPagoMonedero = _saldoAUtilizarMonedero > total ? total : _saldoAUtilizarMonedero;
                                                                      _loadingMonedero = true;
                                                                    });
                                                                    var resultPagoMonedero = await setPaymentMonedero();
                                                                    setState(() {
                                                                      _loadingMonedero = false;
                                                                    });
                                                                    if (resultPagoMonedero != null) {
                                                                      _pagoMonederoExitoso = true;
                                                                      _showResponseDialog("Se ha descontado \$$_totalPagoMonedero de su monedero", title: "Pago con monedero");
                                                                      saldoMonederoController.clear();
                                                                      await getMonedero();
                                                                    } else {
                                                                      _showResponseDialog("Ha ocurrido un problema al aplicar el pago con monedero");
                                                                    }
                                                                  }
                                                                },
                                                          color: DataUI.chedrauiBlueColor,
                                                          child: !_loadingMonedero
                                                              ? Text(
                                                                  'Aplicar',
                                                                  textAlign: TextAlign.left,
                                                                  style: TextStyle(
                                                                    fontFamily: 'Archivo',
                                                                    fontSize: 14,
                                                                    letterSpacing: 0.25,
                                                                    color: HexColor('#FFFFFF'),
                                                                  ),
                                                                )
                                                              : Container(
                                                                  height: 10,
                                                                  width: 10,
                                                                  child: CircularProgressIndicator(),
                                                                ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Container(
                                                  padding: EdgeInsets.all(15),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.withAlpha(100),
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                  child: Text("No hay saldo disponible en tu Monedero Mi Chedraui"),
                                                ),
                                        ],
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    height: 0,
                                  ),
                            Divider(
                              height: 20,
                              color: Colors.grey,
                            ),
                            Container(
                              margin: const EdgeInsets.all(0),
                              // alignment: Alignment.centerLeft,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  !isLoggedIn
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Expanded(
                                              flex: 5,
                                              child: InkWell(
                                                onTap: () {},
                                                child: Theme(
                                                  data: ThemeData(
                                                    primaryColor: _couponResultColor,
                                                    // primaryColor: HexColor('#C4CDD5'),
                                                    // hintColor: Colors.black,
                                                  ),
                                                  child: TextField(
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(),
                                                      contentPadding: const EdgeInsets.only(
                                                          top: 12,
                                                          bottom: 12,
                                                          left: 6, //todo
                                                          right: 6 //todo
                                                          ),
                                                      hintText: 'Número de Cupón',
                                                    ),
                                                    keyboardType: TextInputType.number,
                                                    inputFormatters: [LengthLimitingTextInputFormatter(50), WhitelistingTextInputFormatter.digitsOnly],
                                                    onChanged: (String input) {
                                                      _numeroCupon = input;
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 5,
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: InkWell(
                                                onTap: () {},
                                                child: Theme(
                                                  data: ThemeData(
                                                    primaryColor: _couponResultColor,
                                                  ),
                                                  child: TextField(
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(),
                                                      contentPadding: const EdgeInsets.only(
                                                          top: 12,
                                                          bottom: 12,
                                                          left: 6, //todo
                                                          right: 6 //todo
                                                          ),
                                                      hintText: 'Token',
                                                    ),
                                                    inputFormatters: [
                                                      LengthLimitingTextInputFormatter(10),
                                                      WhitelistingTextInputFormatter(
                                                        RegExp("[a-zA-Z0-9]"),
                                                      ),
                                                    ],
                                                    onChanged: (String input) {
                                                      _tokenCupon = input;
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                            /*
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8),
                                              child: RaisedButton(
                                                color: HexColor('#0D47A1'),
                                                disabledColor: HexColor('#0D47A1').withOpacity(0.5),
                                                onPressed: _numeroCupon.length > 0
                                                    ? () {
                                                        validateCoupon();
                                                      }
                                                    : null,
                                                child: !_validandoCupon
                                                    ? Text(
                                                        "Aplicar",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                        ),
                                                      )
                                                    : CircularProgressIndicator(),
                                              ),
                                            ),
                                            */
                                          ],
                                        )
                                      : Container(
                                          child: FlatButton(
                                            onPressed: () async {
                                              if (currState != StatusCheckout.LOADING_STEP) {
                                                Map cuponAux = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    settings: RouteSettings(name: DataUI.cuponesRoute),
                                                    builder: (context) => CuponesPage(accion: 'checkout'),
                                                  ),
                                                );
                                                if (cuponAux != null) {
                                                  setState(() {
                                                    cuponSaved = cuponAux;
                                                    _cuponGuardado = "Cupón seleccionado: " + cuponAux['codigoCupon'];
                                                  });
                                                  _showSnackBar(context, "Cupón ${cuponSaved['codigoCupon']} seleccionado");
                                                }
                                              }
                                            },
                                            child: Row(
                                              children: <Widget>[
                                                Flexible(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(left: 5, right: 10),
                                                    child: Image.asset(
                                                      'assets/cupon.png',
                                                      width: 25,
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                  flex: 6,
                                                  child: Text("Agregar cupón",
                                                      style: TextStyle(
                                                        color: DataUI.chedrauiBlueColor,
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w400,
                                                      )),
                                                  fit: FlexFit.tight,
                                                ),
                                                Flexible(
                                                  flex: 1,
                                                  child: Icon(
                                                    Icons.arrow_forward_ios,
                                                    size: 15,
                                                    color: HexColor('#0D47A1'),
                                                  ),
                                                  fit: FlexFit.tight,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                  isLoggedIn && _cuponGuardado != null ? Text(_cuponGuardado != null ? _cuponGuardado : '', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)) : SizedBox(height: 0),
                                  _couponResultText.length > 0
                                      ? Padding(
                                          padding: const EdgeInsets.only(left: 15, right: 15),
                                          child: Text(
                                            _couponResultText,
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: _couponResultColor),
                                          ),
                                        )
                                      : SizedBox(
                                          height: 0,
                                        ),
                                ],
                              ),
                            ),
                            Divider(height: 20, color: Colors.grey),
                            card
                                ? RadioListTile<PaymentMethod>(
                                    activeColor: Colors.black,
                                    title: const Text(
                                      'Tarjeta de Crédito o Débito',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    value: PaymentMethod.card,
                                    groupValue: payMethod,
                                    onChanged: (PaymentMethod value) {
                                      setState(() {
                                        monederoFocusNode.unfocus();
                                        onlyMonederoSelected = false;
                                        payMethod = value;
                                        isContinueActive = false;
                                      });
                                    },
                                  )
                                : SizedBox(
                                    height: 0,
                                  ),
                            payMethod != PaymentMethod.card
                                ? (card
                                    ? Divider(
                                        indent: 40,
                                        height: 1,
                                        color: Colors.grey,
                                      )
                                    : SizedBox(
                                        height: 0,
                                      ))
                                : Theme(
                                    data: ThemeData(
                                      primaryColor: Colors.transparent,
                                      hintColor: Colors.transparent, //
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.only(left: 40, right: 15),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                'Número de Tarjeta',
                                                style: TextStyle(fontSize: 12, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(top: 8, bottom: 8),
                                                child: TextFormField(
                                                  style: TextStyle(color: HexColor('#0D47A1'), fontSize: 12, fontFamily: 'Archivo'),
                                                  decoration: InputDecoration(
                                                    prefixIcon: Padding(
                                                      padding: EdgeInsets.only(left: 5, right: 5),
                                                      child: CardUtils.getCardIcon(_paymentCard.type),
                                                    ),
                                                    filled: true,
                                                    fillColor: HexColor('#F0EFF4'),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(4.0),
                                                    ),
                                                    contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                                                  ),
                                                  controller: numberController,
                                                  keyboardType: TextInputType.number,
                                                  textInputAction: TextInputAction.next,
                                                  inputFormatters: [WhitelistingTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16), CardNumberInputFormatter()],
                                                  focusNode: _focusFormCard['numeroTarjeta'],
                                                  onFieldSubmitted: (String input) {
                                                    FocusScope.of(context).requestFocus(_focusFormCard['expiraTarjeta']);
                                                  },
                                                  onChanged: (String input) {
                                                    if (input.length >= 12) {
                                                      paymentData.cardNumber = input;
                                                      _paymentCard.number = CardUtils.getCleanedNumber(input);
                                                    }
                                                  },
                                                  validator: UtilsPayment.CardUtils.validateCardNum,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 2, bottom: 2),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              mainAxisSize: MainAxisSize.max,
                                              children: <Widget>[
                                                Expanded(
                                                    flex: 15,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(right: 5),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: <Widget>[
                                                          Text(
                                                            'Fecha de exp',
                                                            style: TextStyle(fontSize: 12, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.only(top: 8, bottom: 8),
                                                            child: TextFormField(
                                                              style: TextStyle(color: HexColor('#0D47A1'), fontSize: 14, fontFamily: 'Archivo'),
                                                              decoration: InputDecoration(
                                                                filled: true,
                                                                fillColor: HexColor('#F0EFF4'),
                                                                border: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(4.0),
                                                                ),
                                                                contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                                                                hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                                                              ),
                                                              keyboardType: TextInputType.number,
                                                              textInputAction: TextInputAction.next,
                                                              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly, new LengthLimitingTextInputFormatter(4), new CardMonthInputFormatter()],
                                                              focusNode: _focusFormCard['expiraTarjeta'],
                                                              onFieldSubmitted: (String input) {
                                                                FocusScope.of(context).requestFocus(_focusFormCard['cvvTarjeta']);
                                                              },
                                                              onChanged: (String input) {
                                                                List<int> expiryDate = CardUtils.getExpiryDate(input);
                                                                paymentData.cardMonth = expiryDate[0].toString();
                                                                paymentData.cardYear = expiryDate[1].toString();
                                                              },
                                                              validator: CardUtils.validateDate,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )),
                                                // Expanded(flex:1, child: SizedBox()),
                                                Expanded(
                                                  flex: 15,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Text(
                                                        'CVV',
                                                        style: TextStyle(fontSize: 12, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.only(top: 8, bottom: 8),
                                                        child: TextFormField(
                                                          style: TextStyle(color: HexColor('#0D47A1'), fontSize: 14, fontFamily: 'Archivo'),
                                                          decoration: InputDecoration(
                                                            filled: true,
                                                            fillColor: HexColor('#F0EFF4'),
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(4.0),
                                                            ),
                                                            contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                                                            hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                                                          ),
                                                          keyboardType: TextInputType.number,
                                                          textInputAction: TextInputAction.next,
                                                          inputFormatters: <TextInputFormatter>[
                                                            _paymentCard.type == CardType.AmericanExpress ? LengthLimitingTextInputFormatter(4) : LengthLimitingTextInputFormatter(3),
                                                            WhitelistingTextInputFormatter.digitsOnly,
                                                          ],
                                                          focusNode: _focusFormCard['cvvTarjeta'],
                                                          onFieldSubmitted: (String input) {
                                                            FocusScope.of(context).requestFocus(_focusFormCard['nombreTarjeta']);
                                                          },
                                                          onChanged: (input) {
                                                            paymentData.cardSecurity = input;
                                                          },
                                                          validator: _validateCVVField,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: SizedBox(),
                                                )
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                'Nombre del Tarjetahabiente',
                                                style: TextStyle(fontSize: 12, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(top: 8, bottom: 8),
                                                child: TextFormField(
                                                  style: TextStyle(color: HexColor('#0D47A1'), fontSize: 14, fontFamily: 'Archivo'),
                                                  decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor: HexColor('#F0EFF4'),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(4.0),
                                                    ),
                                                    contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                                                    hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                                                  ),
                                                  inputFormatters: [
                                                    WhitelistingTextInputFormatter(FormsTextFormatters.regexNames()),
                                                  ],
                                                  textInputAction: TextInputAction.done,
                                                  focusNode: _focusFormCard['nombreTarjeta'],
                                                  onChanged: (input) {
                                                    paymentData.cardName = input;
                                                  },
                                                  validator: FormsTextValidators.validateTextWithoutEmoji,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.only(top: 8, bottom: 8),
                                                child: FlatButton(
                                                  shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                                  onPressed: !loadingInstallments
                                                      ? () async {
                                                          setState(() {
                                                            cardInvitadoIsValid = false;
                                                            isContinueActive = false;
                                                          });
                                                          if (_formKeys[1].currentState.validate()) {
                                                            bool resultInstallment = await getInstallments();
                                                            if (!resultInstallment) _showResponseDialog("La tarjeta ingresada no es válida");
                                                            setState(() {
                                                              cardInvitadoIsValid = resultInstallment;
                                                              isContinueActive = resultInstallment;
                                                            });
                                                          }
                                                        }
                                                      : null,
                                                  color: Theme.of(context).brightness == Brightness.dark ? HexColor('#F57C00').withOpacity(0.5) : HexColor('#F57C00'),
                                                  disabledColor: HexColor('#F57C00').withOpacity(0.5),
                                                  textColor: Colors.white,
                                                  textTheme: ButtonTextTheme.normal,
                                                  child: Text('Validar tarjeta'),
                                                ),
                                              ),
                                              Form(
                                                key: _formKeys[3],
                                                child: installmentsList != null && installmentsList.length > 0
                                                    ? InstallmentWidget(installmentList: installmentsList, callback: setCurrentInstallment)
                                                    : loadingInstallments
                                                        ? SizedBox(
                                                            height: 50,
                                                            child: Center(
                                                              child: CircularProgressIndicator(),
                                                            ),
                                                          )
                                                        : SizedBox(
                                                            height: 0,
                                                          ),
                                              )
                                            ],
                                          ),
                                          Divider(
                                            indent: 0,
                                            height: 20,
                                            color: Colors.grey,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                            registredCard
                                ? RadioListTile<PaymentMethod>(
                                    activeColor: Colors.black,
                                    title: const Text(
                                      'Tarjeta de Crédito o Débito',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    value: PaymentMethod.registredCard,
                                    groupValue: payMethod,
                                    onChanged: (PaymentMethod value) {
                                      setState(() {
                                        monederoFocusNode.unfocus();
                                        onlyMonederoSelected = false;
                                        payMethod = value;
                                        isContinueActive = true;
                                      });
                                    },
                                  )
                                : SizedBox(
                                    height: 0,
                                  ),
                            payMethod != PaymentMethod.registredCard
                                ? (registredCard
                                    ? Divider(
                                        indent: 40,
                                        height: 1,
                                        color: Colors.grey,
                                      )
                                    : SizedBox(
                                        height: 0,
                                      ))
                                : Theme(
                                    data: ThemeData(
                                      primaryColor: Colors.black,
                                      hintColor: HexColor('#C4CDD5'),
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.only(left: 35, right: 15),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Container(
                                          child: Theme(
                                            data: ThemeData(canvasColor: Colors.white),
                                            child: Column(
                                              children: <Widget>[
                                                cards != null
                                                    ? dropdown.DropdownButtonFormField(
                                                        decoration: InputDecoration(
                                                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                                                          filled: true,
                                                          fillColor: HexColor("#F4F6F8"),
                                                          border: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color: HexColor("#C4CDD5"),
                                                            ),
                                                          ),
                                                        ),
                                                        items: this.tarjetasDropDown,
                                                        onChanged: processingCard
                                                            ? null
                                                            : (value) async {
                                                                if (loadingInstallments) return;
                                                                if (value != 'NEW' && value != "NONE") {
                                                                  setState(() {
                                                                    _cardSelected = value;
                                                                    _selectedRegistredCard = tarjetasDropDownValues.indexOf(value);
                                                                  });
                                                                  await getInstallments();
                                                                  //await getTokenFromSelectedCard();
                                                                } else if (value == "NEW") {
                                                                  var resultAddNewCard = await Navigator.pushNamed(context, DataUI.addCardRoute);
                                                                  bool res = resultAddNewCard ?? false;
                                                                  if (res) {
                                                                    await getCartera(setLast: true);
                                                                    await getInstallments();
                                                                  }
                                                                }
                                                              },
                                                        value: _cardSelected,
                                                      )
                                                    : LinearProgressIndicator(),
                                                bankPointsRaw != null
                                                    ? CheckboxListTile(
                                                        controlAffinity: ListTileControlAffinity.leading,
                                                        activeColor: HexColor("#0D47A1"),
                                                        title: Text(
                                                          'Usar puntos de mi tarjeta (${moneda.format(bankPointsMXN)})',
                                                          style: TextStyle(fontSize: 14),
                                                        ),
                                                        value: bankPointsSelected,
                                                        onChanged: (bool value) {
                                                          setState(() {
                                                            bankPointsSelected = !bankPointsSelected;
                                                          });
                                                        },
                                                      )
                                                    : SizedBox(height: 0),
                                                cards != null && cards.length > 0
                                                    ? Form(
                                                        key: _formKeys[3],
                                                        child: installmentsList != null && installmentsList.length > 0
                                                            ? InstallmentWidget(installmentList: installmentsList, callback: setCurrentInstallment)
                                                            : SizedBox(
                                                                height: 50,
                                                                child: Center(
                                                                  child: CircularProgressIndicator(),
                                                                ),
                                                              ),
                                                      )
                                                    : SizedBox(
                                                        height: 0,
                                                      )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                            payPayPal == false
                                ? SizedBox(
                                    height: 0,
                                  )
                                : RadioListTile<PaymentMethod>(
                                    activeColor: Colors.black,
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
                                        monederoFocusNode.unfocus();
                                        onlyMonederoSelected = false;
                                        payMethod = value;
                                        isContinueActive = true;
                                      });
                                    },
                                  ),
                            payMethod != PaymentMethod.paypal
                                ? (payPayPal
                                    ? Divider(
                                        indent: 40,
                                        height: 1,
                                        color: Colors.grey,
                                      )
                                    : SizedBox(
                                        height: 0,
                                      ))
                                : Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.only(left: 35, top: 15, bottom: 15, right: 15),
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
                                      Divider(
                                        indent: 40,
                                        height: 1,
                                        color: Colors.grey,
                                      )
                                    ],
                                  ),
                            payOnDelivery && !containsDHL
                                ? RadioListTile<PaymentMethod>(
                                    activeColor: Colors.black,
                                    title: const Text(
                                      'Pago contra-entrega',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    value: PaymentMethod.onDelivery,
                                    groupValue: payMethod,
                                    onChanged: (PaymentMethod value) {
                                      setState(() {
                                        monederoFocusNode.unfocus();
                                        onlyMonederoSelected = false;
                                        payMethod = value;
                                        isContinueActive = true;
                                      });
                                    },
                                  )
                                : SizedBox(
                                    height: 0,
                                  ),
                            payMethod != PaymentMethod.onDelivery
                                ? (payOnDelivery && !containsDHL
                                    ? Divider(
                                        indent: 40,
                                        height: 1,
                                        color: Colors.grey,
                                      )
                                    : SizedBox(
                                        height: 0,
                                      ))
                                : Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.all(15.0),
                                          child: Text(
                                            'Selecciona la forma de pago a utilizar en contra entrega:',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        GridView.count(
                                          physics: ClampingScrollPhysics(),
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
                                                    isSelected: _selectedOnDeliverPayMethod == 0 ? true : false,
                                                  ),
                                            !masterCard
                                                ? null
                                                : OnDeliverOptionItem(
                                                    selectOnDeliverPayMethod,
                                                    index: 1,
                                                    isSelected: _selectedOnDeliverPayMethod == 1 ? true : false,
                                                  ),
                                            !amex
                                                ? null
                                                : OnDeliverOptionItem(
                                                    selectOnDeliverPayMethod,
                                                    index: 2,
                                                    isSelected: _selectedOnDeliverPayMethod == 2 ? true : false,
                                                  ),
                                            !cash
                                                ? null
                                                : OnDeliverOptionItem(
                                                    selectOnDeliverPayMethod,
                                                    index: 3,
                                                    isSelected: _selectedOnDeliverPayMethod == 3 ? true : false,
                                                  ),
                                            !vales
                                                ? null
                                                : OnDeliverOptionItem(
                                                    selectOnDeliverPayMethod,
                                                    index: 4,
                                                    isSelected: _selectedOnDeliverPayMethod == 4 ? true : false,
                                                  ),
                                          ].where(notNull).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                            payInStore == true
                                ? RadioListTile<PaymentMethod>(
                                    activeColor: Colors.black,
                                    title: const Text(
                                      'Pre-pago en Tiendas Chedraui',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    value: PaymentMethod.onStore,
                                    groupValue: payMethod,
                                    onChanged: (PaymentMethod value) {
                                      setState(() {
                                        monederoFocusNode.unfocus();
                                        onlyMonederoSelected = false;
                                        payMethod = value;
                                        isContinueActive = true;
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
                                    padding: const EdgeInsets.all(15),
                                    child: Text(
                                      kenticoTextTienda,
                                      style: TextStyle(fontSize: 14),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                            Divider(
                              indent: 40,
                              height: 1,
                              color: Colors.grey,
                            ),
                            payInAssociatedStore == true //&& isLoggedIn == true
                                ? RadioListTile<PaymentMethod>(
                                    activeColor: Colors.black,
                                    title: const Text(
                                      'Pre-pago en establecimientos asociados',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    value: PaymentMethod.associatedStore,
                                    groupValue: payMethod,
                                    onChanged: (PaymentMethod value) async {
                                      setState(() {
                                        monederoFocusNode.unfocus();
                                        onlyMonederoSelected = false;
                                        payMethod = value;
                                        isContinueActive = true;
                                      });
                                    },
                                  )
                                : SizedBox(
                                    height: 0,
                                  ),
                            payMethod != PaymentMethod.associatedStore
                                ? (payInAssociatedStore
                                    ? Divider(
                                        indent: 40,
                                        height: 1,
                                        color: Colors.grey,
                                      )
                                    : SizedBox(
                                        height: 0,
                                      ))
                                : Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.only(left: 15),
                                    padding: const EdgeInsets.all(0.0),
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.all(15.0),
                                            child: Text(
                                              kenticoTextAsociado,
                                              textAlign: TextAlign.justify,
                                              style: TextStyle(fontSize: 14),
                                            )),
                                        Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.all(15.0),
                                          child: Text(
                                            '¿Cómo realizar el pre-pago en establecimientos asociados?',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              // color: HexColor("#637381"),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(vertical: 5),
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  '1',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: 'Archivo',
                                                    fontWeight: FontWeight.bold,
                                                    color: HexColor("#212B36"),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 8,
                                                child: Text(
                                                  'A través del correo te llegará tu “orden de pago” con el código de barras.',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: 'Rubik',
                                                    color: HexColor("#454F5B"),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(vertical: 5),
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  '2',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: 'Archivo',
                                                    fontWeight: FontWeight.bold,
                                                    color: HexColor("#212B36"),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 8,
                                                child: Text(
                                                  'Imprímela o llévala en tu celular a cualquiera de los establecimientos indicados.',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: 'Rubik',
                                                    color: HexColor("#454F5B"),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(vertical: 5),
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  '3',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: 'Archivo',
                                                    fontWeight: FontWeight.bold,
                                                    color: HexColor("#212B36"),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 8,
                                                child: Text(
                                                  'Entrégala en caja y haz tu pago. Guarda el comprobante.',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: 'Rubik',
                                                    color: HexColor("#454F5B"),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(vertical: 5),
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  '4',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: 'Archivo',
                                                    fontWeight: FontWeight.bold,
                                                    color: HexColor("#212B36"),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 8,
                                                child: Text(
                                                  'El pago se registrará y enviará la confirmación a la tienda.',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: 'Rubik',
                                                    color: HexColor("#454F5B"),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.only(left: 40, right: 15, top: 15, bottom: 15),
                                          child: Column(children: <Widget>[
                                            Text(
                                              'Establecimientos asociados:',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontSize: 12,
                                                // color: HexColor("#637381"),
                                              ),
                                            ),
                                            establecimientosAsociados != null
                                                ? Container(
                                                    child: GridView.count(
                                                      physics: ClampingScrollPhysics(),
                                                      shrinkWrap: true,
                                                      primary: true,
                                                      crossAxisCount: 4,
                                                      mainAxisSpacing: 18,
                                                      children: List.generate(
                                                        establecimientosAsociados.length,
                                                        (index) {
                                                          return Image.network(
                                                            "https://prod.chedraui.com.mx" + establecimientosAsociados[index]['storeImageUrl'],
                                                            fit: BoxFit.scaleDown,
                                                            height: 65.0,
                                                            width: 65.0,
                                                            alignment: Alignment.center,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  )
                                                : SizedBox(
                                                    height: 50,
                                                    child: Center(
                                                      child: CircularProgressIndicator(),
                                                    ),
                                                  ),
                                            Divider(
                                              indent: 0,
                                              height: 20,
                                              color: Colors.grey,
                                            )
                                          ]),
                                        ),
                                      ],
                                    ),
                                  ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
          modify: currState != StatusCheckout.LOADING_STEP
              ? Container(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(
                    isLoggedIn ? "Modificar" : "Editar",
                    style: TextStyle(color: DataUI.chedrauiBlueColor, fontSize: 14),
                    textAlign: TextAlign.right,
                  ),
                ]))
              : SizedBox(
                  height: 0,
                )),
    ];
    return steps;
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

  @override
  Widget build(BuildContext context) {
    return WidgetContainer(Scaffold(
      backgroundColor: HexColor('#F0EFF4'),
      appBar: itemsCount == null
          ? GradientAppBar(
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
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
              title: Text('Checkout', style: TextStyle(color: Colors.white, fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 19)))
          : GradientAppBar(
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
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
              title: Text(itemsCount > 1 ? 'Checkout (' + itemsCount.toString() + ' artículos)' : 'Checkout (' + itemsCount.toString() + ' artículo)', style: TextStyle(color: Colors.white, fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 19)),
            ),
      body: prefs != null
          ? SafeArea(
              child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: ClampingScrollPhysics(),
                  child: Theme(
                    data: ThemeData(
                      primaryColor: Colors.orange,
                      hintColor: Colors.black,
                    ),
                    child: !loadingOrder
                        ? FutureBuilder(
                            future: cart,
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
                                  return Column(
                                    children: <Widget>[
                                      //LoginSuggestion(context),
                                      stepper.CustomStepper(
                                          physics: ClampingScrollPhysics(),
                                          steps: buildSteps(),
                                          type: stepper.StepperType.vertical,
                                          currentStep: this.currStep,
                                          onStepContinue: () async {
                                            switch (this.currStep) {
                                              case 0:
                                                if (addressSet && currState != StatusCheckout.LOADING_STEP) {
                                                  _scrollController.animateTo(_scrollController.position.minScrollExtent, duration: Duration(milliseconds: 100), curve: Curves.easeIn);
                                                  setState(() {
                                                    this.currStep++;
                                                  });
                                                  currState = StatusCheckout.LOADING_STEP;
                                                  if (newAddressSelected) {
                                                    await addAddressToUser(newAddressInfo);
                                                  }
                                                  bool a = await setAddressCart();
                                                  if (a) {
                                                    await getTimeSlots();
                                                  }
                                                  currState = StatusCheckout.IDLE;
                                                }
                                                break;
                                              case 1:
                                                if (_currentCart != null && _slotsEntrega != null && currState != StatusCheckout.LOADING_STEP) {
                                                  currState = StatusCheckout.LOADING_STEP;
                                                  payMethod = null;
                                                  _scrollController.animateTo(_scrollController.position.minScrollExtent, duration: Duration(milliseconds: 100), curve: Curves.easeIn);
                                                  setState(() {
                                                    this.currStep++;
                                                    isContinueActive = false;
                                                  });

                                                  List slotsToSave = getSlotsToSave();
                                                  setState(() {
                                                    slotsList = slotsToSave;
                                                    paymentMethods = null;
                                                  });
                                                  print(slotsList);
                                                  await confirmShippingInfo(slotsToSave);
                                                  getMonedero();
                                                  bool paymentMethodsLoaded = await getPaymentsMethod();
                                                  if (!paymentMethodsLoaded) {
                                                    setState(() {
                                                      currStep = 1;
                                                    });
                                                  }
                                                  currState = StatusCheckout.IDLE;
                                                }
                                                break;
                                              case 2:
                                                if (paymentMethods != null && currState != StatusCheckout.LOADING_STEP) {
                                                  currState = StatusCheckout.LOADING_STEP;
                                                  bool canContinue = false;
                                                  bool continueWithoutCupon = true;
                                                  setState(() {
                                                    _numberOfInstallments = null;
                                                    _isButtonDisabled = true;
                                                    _finishEditing = false;
                                                    processingCard = true;
                                                  });
                                                  if (isLoggedIn) {
                                                    if (cuponSaved != null) {
                                                      /*
                                              setState(() {
                                                _cuponGuardado = "Procesando cupón " + cuponRes['codigoCupon'] + " ...";
                                                _isButtonDisabled = true;
                                              });
                                              */
                                                      //_showSnackBar(context, "Procesando cupón ${cuponSaved['codigoCupon']}");

                                                      var resultCupon = await CarritoServices.addCouponWithTokenToCart(
                                                        cuponSaved['codigoCupon'],
                                                        cuponSaved['token'],
                                                      );
                                                      if (resultCupon != null) {
                                                        if (resultCupon == true) {
                                                          _showSnackBar(context, "Cupón " + cuponSaved['codigoCupon'] + " agregado al carrito");
                                                          _cuponGuardado = "Cupón seleccionado: " + cuponSaved['codigoCupon'] + " (Válido)";
                                                          /*
                                                  setState(() {
                                                    _currentCart = null;
                                                  });
                                                  var resultCarrito = await CarritoServices.getCart();
                                                  setState(() {
                                                    _cuponGuardado = "Cupón " + cuponSaved['codigoCupon'] + " agregado al carrito";
                                                    _isButtonDisabled = false;
                                                    _currentCart = resultCarrito;
                                                    fillCartVars(resultCarrito);
                                                  });
                                                  */
                                                        } else {
                                                          //_showSnackBar(context, resultCupon['errorMessage']);
                                                          await showDialog(
                                                              context: context,
                                                              builder: (BuildContext context) {
                                                                return AlertDialog(
                                                                  title: Text("Error con el cupón seleccioado"),
                                                                  content: Text(resultCupon['errorMessage']),
                                                                  actions: <Widget>[
                                                                    FlatButton(
                                                                      onPressed: () {
                                                                        continueWithoutCupon = true;
                                                                        Navigator.pop(context);
                                                                      },
                                                                      child: Text(
                                                                        "Continuar",
                                                                        style: TextStyle(
                                                                          color: DataUI.chedrauiBlueColor,
                                                                          fontSize: 16,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    FlatButton(
                                                                      onPressed: () {
                                                                        continueWithoutCupon = false;
                                                                        Navigator.pop(context);
                                                                      },
                                                                      child: Text(
                                                                        "Regresar",
                                                                        style: TextStyle(
                                                                          color: DataUI.chedrauiBlueColor,
                                                                          fontSize: 16,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              });
                                                          setState(() {
                                                            _cuponGuardado = "Problema al procesar cupón: " + resultCupon['errorMessage'];
                                                            //_isButtonDisabled = false;
                                                          });
                                                        }
                                                      } else {
                                                        //_showSnackBar(context, "Cupón " + cuponSaved['codigoCupon'] + " no válido");
                                                        await showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return AlertDialog(
                                                                title: Text("Error con el cupón seleccioado"),
                                                                content: Text("Cupón " + cuponSaved['codigoCupon'] + " no válido"),
                                                                actions: <Widget>[
                                                                  FlatButton(
                                                                    onPressed: () {
                                                                      continueWithoutCupon = true;
                                                                      Navigator.pop(context);
                                                                    },
                                                                    child: Text(
                                                                      "Continuar",
                                                                      style: TextStyle(
                                                                        color: DataUI.chedrauiBlueColor,
                                                                        fontSize: 16,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  FlatButton(
                                                                    onPressed: () {
                                                                      continueWithoutCupon = false;
                                                                      Navigator.pop(context);
                                                                    },
                                                                    child: Text(
                                                                      "Regresar",
                                                                      style: TextStyle(
                                                                        color: DataUI.chedrauiBlueColor,
                                                                        fontSize: 16,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            });
                                                        setState(() {
                                                          _cuponGuardado = "Cupón seleccionado: " + cuponSaved['codigoCupon'] + " (no válido)";
                                                          //_isButtonDisabled = false;
                                                        });
                                                      }
                                                    }
                                                  } else {
                                                    if (_numeroCupon.trim().length > 0 && _tokenCupon.trim().length > 0) {
                                                      var resultCupon = await CarritoServices.addCouponWithTokenToCart(_numeroCupon, _tokenCupon);
                                                      if (resultCupon != null) {
                                                        if (resultCupon == true) {
                                                          setState(() {
                                                            _couponResultColor = Colors.green;
                                                            _couponResultText = 'Cupón $_numeroCupon aplicado exitosamente.';
                                                          });
                                                        } else {
                                                          await showDialog(
                                                              context: context,
                                                              builder: (BuildContext context) {
                                                                return AlertDialog(
                                                                  title: Text("Error con el cupón seleccioado"),
                                                                  content: Text("Cupón $_numeroCupon no válido"),
                                                                  actions: <Widget>[
                                                                    FlatButton(
                                                                      onPressed: () {
                                                                        continueWithoutCupon = true;
                                                                        Navigator.pop(context);
                                                                      },
                                                                      child: Text(
                                                                        "Continuar",
                                                                        style: TextStyle(
                                                                          color: DataUI.chedrauiBlueColor,
                                                                          fontSize: 16,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    FlatButton(
                                                                      onPressed: () {
                                                                        continueWithoutCupon = false;
                                                                        Navigator.pop(context);
                                                                      },
                                                                      child: Text(
                                                                        "Regresar",
                                                                        style: TextStyle(
                                                                          color: DataUI.chedrauiBlueColor,
                                                                          fontSize: 16,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              });
                                                          setState(() {
                                                            _couponResultColor = Colors.red;
                                                            _couponResultText = resultCupon['errorMessage'];
                                                          });
                                                        }
                                                      } else {
                                                        await showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return AlertDialog(
                                                                title: Text("Error con el cupón seleccioado"),
                                                                content: Text("Cupón $_numeroCupon no válido"),
                                                                actions: <Widget>[
                                                                  FlatButton(
                                                                    onPressed: () {
                                                                      continueWithoutCupon = true;
                                                                      Navigator.pop(context);
                                                                    },
                                                                    child: Text(
                                                                      "Continuar",
                                                                      style: TextStyle(
                                                                        color: DataUI.chedrauiBlueColor,
                                                                        fontSize: 16,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  FlatButton(
                                                                    onPressed: () {
                                                                      continueWithoutCupon = false;
                                                                      Navigator.pop(context);
                                                                    },
                                                                    child: Text(
                                                                      "Regresar",
                                                                      style: TextStyle(
                                                                        color: DataUI.chedrauiBlueColor,
                                                                        fontSize: 16,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            });
                                                        setState(() {
                                                          _couponResultColor = Colors.red;
                                                          _couponResultText = 'El cupón $_numeroCupon no es válido.';
                                                        });
                                                      }
                                                    }
                                                  }
                                                  if (!continueWithoutCupon) {
                                                    setState(() {
                                                      currState = StatusCheckout.IDLE;
                                                      _isButtonDisabled = false;
                                                      _finishEditing = false;
                                                      currStep = 2;
                                                    });
                                                    return;
                                                  }
                                                  if (payMethod == PaymentMethod.card && cardInvitadoIsValid) {
                                                    bool validUnregistredCard = await setOpenPayData();
                                                    if (!validUnregistredCard) {
                                                      print(errorOpenPay);
                                                      print(messageErrorOpenPay);
                                                      _showResponseDialog(messageErrorOpenPay);
                                                    }
                                                    canContinue = validUnregistredCard;
                                                  } else if (payMethod == PaymentMethod.registredCard) {
                                                    bool validRegistredCard = await getCVVRegistredCard();
                                                    if (!validRegistredCard) {
                                                      print(errorOpenPay);
                                                      print(messageErrorOpenPay);
                                                      _showResponseDialog(messageErrorOpenPay);
                                                    }
                                                    canContinue = validRegistredCard;
                                                  } else if (payMethod == PaymentMethod.paypal) {
                                                    await setPaypalData();
                                                    //canContinue = true;
                                                  } else if (payMethod == PaymentMethod.onDelivery) {
                                                    submitSecondForm(payMethod);
                                                    var setPaymentRes = await setOnDeliveryData();
                                                    if (setPaymentRes != null && setPaymentRes['errors'] != null) {
                                                      canContinue = false;
                                                      String errors = getErrorsFromBodyResponse(setPaymentRes['errors']);
                                                      _showResponseDialog("Error asignando el método de pago:\n$errors");
                                                    } else {
                                                      canContinue = true;
                                                    }
                                                  } else if (payMethod == PaymentMethod.associatedStore) {
                                                    var setPaymentRes = await setAssociatedStoreData();
                                                    if (setPaymentRes != null && setPaymentRes['errors'] != null) {
                                                      canContinue = false;
                                                      String errors = getErrorsFromBodyResponse(setPaymentRes['errors']);
                                                      _showResponseDialog("Error asignando el método de pago:\n$errors");
                                                    } else {
                                                      canContinue = true;
                                                    }
                                                  } else if (payMethod == PaymentMethod.onStore) {
                                                    var setPaymentRes = await setOnStoreData();
                                                    if (setPaymentRes != null && setPaymentRes['errors'] != null) {
                                                      canContinue = false;
                                                      String errors = getErrorsFromBodyResponse(setPaymentRes['errors']);
                                                      _showResponseDialog("Error asignando el método de pago:\n$errors");
                                                    } else {
                                                      canContinue = true;
                                                    }
                                                  } else if (payMethod == null && _pagoMonederoExitoso) {
                                                    bool monederoCanCover = _totalPagoMonedero >= total;
                                                    if (!monederoCanCover) {
                                                      _showResponseDialog("Por favor seleccione un método de pago adicional, o agregue más fondos de su Monedero Mi Chedraui.");
                                                    }
                                                    canContinue = monederoCanCover;
                                                  }
                                                  currState = StatusCheckout.IDLE;
                                                  if (canContinue) {
                                                    var resultCarrito = await CarritoServices.getCart();
                                                    setState(() {
                                                      fillCartVars(resultCarrito);
                                                      _isButtonDisabled = false;
                                                      _finishEditing = true;
                                                      processingCard = false;
                                                    });
                                                    /*
                                            if(resultCarrito['paymentInfos'] != null && resultCarrito['paymentInfos'].length == 0){
                                              setState(() {
                                                currStep = 2;
                                                _isButtonDisabled = true;
                                              _finishEditing = false;
                                              });
                                              _showResponseDialog("Error asignando el método de pago. Por favor ingréselo nuevamente o pruebe con otro.");
                                            }
                                            */
                                                  } else {
                                                    setState(() {
                                                      currStep = 2;
                                                      _isButtonDisabled = true;
                                                      _finishEditing = false;
                                                      processingCard = false;
                                                    });
                                                  }
                                                }
                                                /*
                                        if (paymentMethods != null && currState != StatusCheckout.LOADING_STEP) {
                                          setState(() {
                                            _isButtonDisabled = true;
                                            _finishEditing = false;
                                          });
                                          currState = StatusCheckout.LOADING_STEP;
                                          if (payMethod == PaymentMethod.card && cardInvitadoIsValid) {
                                            var resultCarrito = await CarritoServices.getCart();
                                            setState(() {
                                              fillCartVars(resultCarrito);
                                              _isButtonDisabled = false;
                                              _finishEditing = true;
                                            });
                                          } else if (payMethod == PaymentMethod.registredCard) {
                                            if (_cardSelected != null && _cardSelected != 'NONE') {
                                              var resultCarrito = await CarritoServices.getCart();
                                              setState(() {
                                                fillCartVars(resultCarrito);
                                                _isButtonDisabled = false;
                                                _finishEditing = true;
                                              });
                                            }
                                          } else if (payMethod == PaymentMethod.onDelivery) {
                                            submitSecondForm(payMethod);
                                            var resultCarrito = await CarritoServices.getCart();
                                              setState(() {
                                                fillCartVars(resultCarrito);
                                              _isButtonDisabled = false;
                                              _finishEditing = true;
                                            });
                                          } else if (payMethod == null && _pagoMonederoExitoso) {
                                            var resultCarrito = await CarritoServices.getCart();
                                              setState(() {
                                                fillCartVars(resultCarrito);
                                                newTotal = total - _totalPagoMonedero;
                                              _isButtonDisabled = false;
                                              _finishEditing = true;
                                            });
                                          } else if (payMethod != null) {
                                            var resultCarrito = await CarritoServices.getCart();
                                            setState(() {
                                              fillCartVars(resultCarrito);
                                              newTotal = total - _totalPagoMonedero;
                                              _isButtonDisabled = false;
                                              _finishEditing = true;
                                            });
                                          }
                                          currState = StatusCheckout.IDLE;
                                        }
                                        */
                                                break;
                                              default:
                                            }

                                            /*
                            setState(() {
                              if (this.currStep == 0) {
                                print(addressSet);
                                if (addressSet) {
                                  this.currStep++;
                                  print(currStep);
                                  getMonedero();
                                  getPaymentsMethod();
                                }
                              } else if (this.currStep == 1) {
                                if (paymentMethods != null) {
                                  getTimeSlots();
                                  if (payMethod == PaymentMethod.card) {
                                    if (_formKeys[1].currentState.validate()) {
                                      submitSecondForm(payMethod);
                                      this.currStep++;
                                    }
                                  } else if (payMethod ==
                                      PaymentMethod.onDelivery) {
                                    submitSecondForm(payMethod);
                                    this.currStep++;
                                  } else if (payMethod == null &&
                                      _pagoMonederoExitoso) {
                                    this.currStep++;
                                  } else if (payMethod != null) {
                                    this.currStep++;
                                  }
                                }
                              } else if (this.currStep == 2) {
                                if (_currentCart != null &&
                                    _slotsEntrega != null) {
                                  _isButtonDisabled = true;
                                  _finishEditing = true;
                                  confirmShippingInfo();
                                  // _scrollController.animateTo(
                                  //   1000.0,
                                  //   curve: Curves.easeOut,
                                  //   duration: const Duration(milliseconds: 300),
                                  // );
                                }
                              }
                            });
                            */
                                          },
                                          onStepCancel: () {
                                            setState(() {
                                              if (currStep > 0) {
                                                currStep = currStep - 1;
                                                _isButtonDisabled = true;
                                                _finishEditing = false;
                                              } else {
                                                Navigator.pop(context);
                                              }
                                            });
                                          },
                                          onStepTapped: (step) async {
                                            if (currState != StatusCheckout.LOADING_STEP) {
                                              if (step <= currStep) {
                                                if (step == 2) {
                                                  await cleanPaymentMethod();
                                                }
                                                setState(() {
                                                  isContinueActive = true;
                                                  _finishEditing = false;
                                                  currStep = step;
                                                });
                                              }
                                            }
                                          },
                                          controlsBuilder: (BuildContext context, {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
                                            return Container(
                                              margin: const EdgeInsets.all(15),
                                              child: ConstrainedBox(
                                                constraints: const BoxConstraints.tightFor(height: 48.0),
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        child: FlatButton(
                                                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                                          onPressed: (isContinueActive && currState != StatusCheckout.LOADING_STEP) ? onStepContinue : null,
                                                          color: Theme.of(context).brightness == Brightness.dark ? HexColor('#F57C00').withOpacity(0.5) : HexColor('#F57C00'),
                                                          disabledColor: HexColor('#F57C00').withOpacity(0.5),
                                                          textColor: Colors.white,
                                                          textTheme: ButtonTextTheme.normal,
                                                          child: const Text('Continuar'),
                                                        ),
                                                      ),
                                                    ),
                                                    /*
                                                Container(
                                                  margin: const EdgeInsetsDirectional.only(start: 8.0),
                                                  child: FlatButton(
                                                    onPressed: onStepCancel,
                                                    color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).backgroundColor : Theme.of(context).primaryColor,
                                                    textColor: Colors.white,
                                                    textTheme: ButtonTextTheme.normal,
                                                    child: const Text('CANCELAR'),
                                                  ),
                                                ),
                                                */
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),

                                      /**
                                     * NUEVO CHECKOUT
                                     */

                                      Container(
                                        margin: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 5),
                                        padding: const EdgeInsets.all(0.0),
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(5),
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.1),
                                                offset: Offset(2.0, 1.0),
                                                blurRadius: 8.0,
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.only(top: 15, bottom: 15, left: 15, right: 15),
                                                child: Text(
                                                  "Resumen de orden",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: DataUI.chedrauiBlueColor,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                              _subTotal != null
                                                  ? Padding(
                                                      padding: EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 15),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Flexible(
                                                            flex: 1,
                                                            fit: FlexFit.tight,
                                                            child: Text(
                                                              "Subtotal:",
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            ),
                                                          ),
                                                          Flexible(
                                                            flex: 1,
                                                            fit: FlexFit.tight,
                                                            child: Text(
                                                              moneda.format(_subTotalWithoutDiscount),
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                              textAlign: TextAlign.end,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      height: 0,
                                                    ),
                                              _totalDiscounts != null
                                                  ? Padding(
                                                      padding: prefix0.EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 15),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Flexible(
                                                            flex: 2,
                                                            fit: FlexFit.tight,
                                                            child: Row(
                                                              children: <Widget>[
                                                                Flexible(
                                                                  flex: 1,
                                                                  child: Padding(
                                                                    padding: EdgeInsets.only(right: 3),
                                                                    child: Icon(
                                                                      Icons.radio_button_checked,
                                                                      size: 12,
                                                                      color: DataUI.chedrauiColor,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Flexible(
                                                                  flex: 10,
                                                                  child: Text(
                                                                    'Descuentos generales Chedraui',
                                                                    style: TextStyle(
                                                                      fontSize: 12,
                                                                      fontWeight: FontWeight.w400,
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Flexible(
                                                            flex: 1,
                                                            fit: FlexFit.tight,
                                                            child: Text(
                                                              "-${moneda.format(_totalDiscounts)}",
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.w400,
                                                              ),
                                                              textAlign: TextAlign.end,
                                                            ),
                                                          )
                                                        ],
                                                      ))
                                                  : SizedBox(
                                                      height: 0,
                                                    ),
                                              _totalCouponsAmount != null
                                                  ? Padding(
                                                      padding: prefix0.EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 15),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Flexible(
                                                            flex: 2,
                                                            fit: FlexFit.tight,
                                                            child: Row(
                                                              children: <Widget>[
                                                                Flexible(
                                                                  flex: 1,
                                                                  child: Padding(
                                                                    padding: EdgeInsets.only(right: 3),
                                                                    child: Icon(
                                                                      Icons.radio_button_checked,
                                                                      size: 12,
                                                                      color: DataUI.chedrauiColor,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Flexible(
                                                                  flex: 10,
                                                                  child: Text(
                                                                    'Descuentos cupones MiChedraui',
                                                                    style: TextStyle(
                                                                      fontSize: 12,
                                                                      fontWeight: FontWeight.w400,
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Flexible(
                                                            flex: 1,
                                                            fit: FlexFit.tight,
                                                            child: Text(
                                                              "-${moneda.format(_totalCouponsAmount)}",
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.w400,
                                                              ),
                                                              textAlign: TextAlign.end,
                                                            ),
                                                          )
                                                        ],
                                                      ))
                                                  : SizedBox(
                                                      height: 0,
                                                    ),
                                              Divider(
                                                thickness: 1.5,
                                              ),
                                              _totalPrice != null
                                                  ? Padding(
                                                      padding: EdgeInsets.only(top: 5, bottom: 10, left: 15, right: 15),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Flexible(
                                                            flex: 2,
                                                            fit: FlexFit.tight,
                                                            child: Row(
                                                              children: <Widget>[
                                                                Flexible(
                                                                  flex: 1,
                                                                  fit: FlexFit.tight,
                                                                  child: Padding(
                                                                    padding: EdgeInsets.only(right: 15),
                                                                    child: PedidosCheckoutSVG(),
                                                                  ),
                                                                ),
                                                                Flexible(
                                                                  flex: 6,
                                                                  fit: FlexFit.tight,
                                                                  child: Text(
                                                                    'Total de tu pedido:',
                                                                    style: TextStyle(
                                                                      fontSize: 16,
                                                                      fontWeight: FontWeight.w400,
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Flexible(
                                                            flex: 1,
                                                            fit: FlexFit.tight,
                                                            child: Text(
                                                              moneda.format(_subTotal),
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                              textAlign: TextAlign.end,
                                                            ),
                                                          )
                                                        ],
                                                      ))
                                                  : SizedBox(
                                                      height: 0,
                                                    ),
                                              _deliveryCost != null
                                                  ? Padding(
                                                      padding: EdgeInsets.only(top: 5, bottom: 10, left: 15, right: 15),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Flexible(
                                                            flex: 2,
                                                            fit: FlexFit.tight,
                                                            child: Row(
                                                              children: <Widget>[
                                                                Flexible(
                                                                  flex: 1,
                                                                  fit: FlexFit.tight,
                                                                  child: Padding(
                                                                    padding: EdgeInsets.only(right: 15),
                                                                    child: EnvioCheckoutSVG(),
                                                                  ),
                                                                ),
                                                                Flexible(
                                                                  flex: 6,
                                                                  fit: FlexFit.tight,
                                                                  child: Text(
                                                                    'Costo de envío:',
                                                                    style: TextStyle(
                                                                      fontSize: 16,
                                                                      fontWeight: FontWeight.w400,
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Flexible(
                                                            flex: 1,
                                                            fit: FlexFit.tight,
                                                            child: Text(
                                                              moneda.format(_deliveryCost),
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                              textAlign: TextAlign.end,
                                                            ),
                                                          )
                                                        ],
                                                      ))
                                                  : SizedBox(
                                                      height: 0,
                                                    ),
                                              _monederoAmount != null
                                                  ? Padding(
                                                      padding: EdgeInsets.only(top: 5, bottom: 10, left: 15, right: 15),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Flexible(
                                                            flex: 2,
                                                            fit: FlexFit.tight,
                                                            child: Row(
                                                              children: <Widget>[
                                                                Flexible(
                                                                  flex: 1,
                                                                  fit: FlexFit.tight,
                                                                  child: Padding(
                                                                    padding: EdgeInsets.only(right: 15),
                                                                    child: MonederoCheckoutSVG(),
                                                                  ),
                                                                ),
                                                                Flexible(
                                                                  flex: 6,
                                                                  fit: FlexFit.tight,
                                                                  child: Text(
                                                                    'Pago con Monedero',
                                                                    style: TextStyle(
                                                                      fontSize: 16,
                                                                      fontWeight: FontWeight.w400,
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Flexible(
                                                            flex: 1,
                                                            fit: FlexFit.tight,
                                                            child: Text(
                                                              "-${moneda.format(_monederoAmount)}",
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                              textAlign: TextAlign.end,
                                                            ),
                                                          )
                                                        ],
                                                      ))
                                                  : SizedBox(
                                                      height: 0,
                                                    ),
                                              _totalToPay != null
                                                  ? Container(
                                                      padding: EdgeInsets.only(top: 20, bottom: 20),
                                                      decoration: BoxDecoration(
                                                        color: DataUI.chedrauiBlueColor,
                                                      ),
                                                      child: Column(
                                                        children: <Widget>[
                                                          _cardPoints != null
                                                              ? Padding(
                                                                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                                                                  child: Row(
                                                                    children: <Widget>[
                                                                      Flexible(
                                                                        flex: 2,
                                                                        fit: FlexFit.tight,
                                                                        child: Text(
                                                                          "Canje ${_cardPoints["paidWithPointsInPoints"]} puntos ${_cardPoints["cardPointsBankName"]}",
                                                                          style: TextStyle(
                                                                            fontSize: 10,
                                                                            color: Colors.white,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Flexible(
                                                                        flex: 1,
                                                                        fit: FlexFit.tight,
                                                                        child: Text(
                                                                          moneda.format(_cardPoints["paidWithPointsInPesos"]),
                                                                          style: TextStyle(
                                                                            fontSize: 10,
                                                                            fontWeight: FontWeight.w600,
                                                                            color: Colors.white,
                                                                          ),
                                                                          textAlign: TextAlign.end,
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ))
                                                              : SizedBox(
                                                                  height: 0,
                                                                ),
                                                          Padding(
                                                              padding: EdgeInsets.only(left: 20, right: 20),
                                                              child: Row(
                                                                children: <Widget>[
                                                                  Flexible(
                                                                    flex: 1,
                                                                    fit: FlexFit.tight,
                                                                    child: Text(
                                                                      "Total a pagar:",
                                                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.white, wordSpacing: 1.5),
                                                                    ),
                                                                  ),
                                                                  Flexible(
                                                                    flex: 1,
                                                                    fit: FlexFit.tight,
                                                                    child: Text(
                                                                      moneda.format(_totalToPay),
                                                                      style: TextStyle(
                                                                        fontSize: 20,
                                                                        fontWeight: FontWeight.w800,
                                                                        color: Colors.white,
                                                                      ),
                                                                      textAlign: TextAlign.end,
                                                                    ),
                                                                  )
                                                                ],
                                                              )),
                                                        ],
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      height: 0,
                                                    ),
                                              _numberOfInstallments != null && _numberOfInstallments > 0 && _totalToPay != null
                                                  ? Container(
                                                      padding: EdgeInsets.only(top: 20, bottom: 20),
                                                      decoration: BoxDecoration(
                                                        color: DataUI.chedrauiBlueSoftColor,
                                                      ),
                                                      child: Padding(
                                                          padding: EdgeInsets.only(left: 20, right: 20),
                                                          child: Row(
                                                            children: <Widget>[
                                                              Flexible(
                                                                flex: 2,
                                                                fit: FlexFit.tight,
                                                                child: RichText(
                                                                  text: TextSpan(
                                                                    children: <TextSpan>[
                                                                      TextSpan(
                                                                          text: 'Pagos mensuales a ',
                                                                          style: TextStyle(
                                                                            color: Colors.white,
                                                                          )),
                                                                      TextSpan(
                                                                          text: '$_numberOfInstallments meses',
                                                                          style: TextStyle(
                                                                            color: Colors.yellowAccent,
                                                                          )),
                                                                      TextSpan(
                                                                          text: " sin intereses",
                                                                          style: TextStyle(
                                                                            color: Colors.white,
                                                                          ))
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Flexible(
                                                                flex: 1,
                                                                fit: FlexFit.tight,
                                                                child: Text(
                                                                  "${moneda.format(_totalToPay / _numberOfInstallments)}/mes",
                                                                  style: TextStyle(
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.w600,
                                                                    color: Colors.white,
                                                                  ),
                                                                  textAlign: TextAlign.end,
                                                                ),
                                                              )
                                                            ],
                                                          )))
                                                  : SizedBox(
                                                      height: 0,
                                                    ),
                                              _totalTax != null
                                                  ? Padding(
                                                      padding: EdgeInsets.only(top: 20, bottom: 10, left: 15, right: 15),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Flexible(
                                                            flex: 2,
                                                            fit: FlexFit.tight,
                                                            child: Text(
                                                              "Tu orden incluye ${moneda.format(_totalTax)} de impuestos.",
                                                              style: TextStyle(fontSize: 12, color: Colors.grey),
                                                            ),
                                                          ),
                                                          /*
                                                Flexible(
                                                  flex: 1,
                                                  fit: FlexFit.tight,
                                                  child: Text(
                                                    "Solicitar factura",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: DataUI.chedrauiColor
                                                    ),
                                                    textAlign: TextAlign.end,
                                                  ),
                                                )
                                                */
                                                        ],
                                                      ))
                                                  : SizedBox(
                                                      height: 0,
                                                    ),
                                              _productDiscount != null
                                                  ? Container(
                                                      padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                                                      margin: EdgeInsets.only(top: 15, left: 20, right: 20),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          width: 3.0,
                                                          color: DataUI.chedrauiColor,
                                                        ),
                                                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                                      ),
                                                      child: Padding(
                                                        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                                                        child: Row(
                                                          children: <Widget>[
                                                            Flexible(
                                                              flex: 3,
                                                              fit: FlexFit.tight,
                                                              child: Text(
                                                                "¡En Chedraui cuesta menos! Tu ahorro:",
                                                                style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: DataUI.chedrauiBlueColor,
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                            ),
                                                            Flexible(
                                                              flex: 1,
                                                              fit: FlexFit.tight,
                                                              child: Text(
                                                                moneda.format(_productDiscount),
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: DataUI.chedrauiBlueColor,
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                                textAlign: TextAlign.end,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ))
                                                  : SizedBox(
                                                      height: 0,
                                                    ),
                                              Divider(
                                                thickness: 1.5,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(left: 0),
                                                child: CheckboxListTile(
                                                  activeColor: DataUI.chedrauiBlueColor,
                                                  controlAffinity: ListTileControlAffinity.leading,
                                                  title: RichText(
                                                    text: TextSpan(children: [
                                                      TextSpan(
                                                          text: "Acepto los ",
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 12,
                                                          )),
                                                      TextSpan(
                                                        text: "Términos y Condiciones",
                                                        recognizer: new TapGestureRecognizer()..onTap = () => {openTyC()},
                                                        style: TextStyle(
                                                          color: DataUI.chedrauiBlueColor,
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                          text: " de compra",
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 12,
                                                          )),
                                                    ]),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                  value: acceptedTyC,
                                                  onChanged: (bool value) {
                                                    setState(() {
                                                      acceptedTyC = !acceptedTyC;
                                                    });
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      flex: 1,
                                                      child: Padding(
                                                          padding: const EdgeInsets.only(top: 0),
                                                          child: Container(
                                                              width: double.infinity,
                                                              height: 40.0,
                                                              decoration: BoxDecoration(
                                                                gradient: LinearGradient(
                                                                  begin: Alignment.bottomCenter,
                                                                  end: Alignment.topCenter,
                                                                  colors: !(_isButtonDisabled || !_finishEditing) && acceptedTyC
                                                                      ? [
                                                                          HexColor('#F56D00'),
                                                                          HexColor('#F78E00'),
                                                                        ]
                                                                      : [HexColor('#F56D00').withOpacity(0.5), HexColor('#F78E00').withOpacity(0.5)],
                                                                ),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors.grey[500],
                                                                    offset: Offset(0.0, 1.5),
                                                                    blurRadius: 1.5,
                                                                  ),
                                                                ],
                                                                borderRadius: BorderRadius.circular(10),
                                                              ),
                                                              child: Material(
                                                                color: Colors.transparent,
                                                                child: InkWell(
                                                                    onTap: (_isButtonDisabled || !_finishEditing) ? null : (acceptedTyC ? completeOrder : null),
                                                                    child: Center(
                                                                      child: loadingOrder
                                                                          ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator())
                                                                          : Text(
                                                                              'Proceder al pago',
                                                                              style: TextStyle(
                                                                                color: Colors.white,
                                                                              ),
                                                                            ),
                                                                    )),
                                                              ))),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: prefix0.EdgeInsets.only(top: 15, bottom: 5, left: 15, right: 15),
                                                child: Text(
                                                  "* Para confirmar tu pedido, debes aceptar los Términos y Condiciones",
                                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),

                                      /**
                                    * VIEJO CHECKOUT
                                    */

                                      /*

                                    Container(
                                      margin: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: prefix0.CrossAxisAlignment.start,
                                        children: <Widget>[
                                          total != null ? 
                                          Padding(
                                            padding: EdgeInsets.only(top: 15, bottom: 15, left: 0, right: 0),
                                            child: Text(
                                              "Resumen de orden",
                                              style: TextStyle(fontSize: 18, color: DataUI.chedrauiBlueColor, fontWeight: FontWeight.w500),
                                            ),
                                          ) : SizedBox(height: 0),
                                          (subTotal != null && subTotal > 0 && deliveryCost != null)
                                                ? Row(
                                                    children: <Widget>[
                                                      Flexible(
                                                        flex: 1,
                                                        fit: FlexFit.tight,
                                                        child: Text(
                                                          "Subtotal",
                                                          style: TextStyle(fontSize: 14),
                                                        ),
                                                      ),
                                                      Flexible(
                                                        flex: 1,
                                                        fit: FlexFit.tight,
                                                        child: Text(
                                                          moneda.format(subTotal),
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                          textAlign: TextAlign.end,
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                : SizedBox(
                                                    height: 0,
                                                  ),
                                            totalDiscounts != null &&  totalDiscounts > 0
                                                ? Row(
                                                    children: <Widget>[
                                                      Flexible(
                                                        flex: 1,
                                                        fit: FlexFit.tight,
                                                        child: Text(
                                                          "en Chedraui Ahorras",
                                                          style: TextStyle(fontSize: 14, color: DataUI.chedrauiColor),
                                                        ),
                                                      ),
                                                      Flexible(
                                                        flex: 1,
                                                        fit: FlexFit.tight,
                                                        child: Text(
                                                          '- ' + moneda.format(totalDiscounts),
                                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: DataUI.chedrauiColor),
                                                          textAlign: TextAlign.end,
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                : SizedBox(
                                                    height: 0,
                                                  ),
                                            (subTotal != null && subTotal > 0 && deliveryCost != null && totalDiscounts != null)
                                                ? Padding(
                                                    padding: EdgeInsets.only(top: 20, bottom: 5),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Flexible(
                                                          flex: 1,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            "Total de tu pedido",
                                                            style: TextStyle(fontSize: 18, color: DataUI.chedrauiBlueColor, fontWeight: FontWeight.w500),
                                                          ),
                                                        ),
                                                        Flexible(
                                                          flex: 1,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            moneda.format(subTotal - totalDiscounts),
                                                            style: TextStyle(fontSize: 18, color: DataUI.chedrauiBlueColor, fontWeight: FontWeight.w500),
                                                            textAlign: TextAlign.end,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                : SizedBox(
                                                    height: 0,
                                                  ),
                                            deliveryCost != null
                                                ? Row(
                                                    children: <Widget>[
                                                      Flexible(
                                                        flex: 1,
                                                        fit: FlexFit.tight,
                                                        child: Text(
                                                          "Costo de envío",
                                                          style: TextStyle(fontSize: 14),
                                                        ),
                                                      ),
                                                      Flexible(
                                                        flex: 1,
                                                        fit: FlexFit.tight,
                                                        child: Text(
                                                          deliveryCost > 0 ? moneda.format(deliveryCost) : "Gratis",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                          textAlign: TextAlign.end,
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                : SizedBox(
                                                    height: 0,
                                                  ),
                                            _pagoMonederoExitoso && _totalPagoMonedero != null && _totalPagoMonedero > 0
                                                ? Row(
                                                    children: <Widget>[
                                                      Flexible(
                                                        flex: 1,
                                                        fit: FlexFit.tight,
                                                        child: Text(
                                                          "Pago con Monedero",
                                                          style: TextStyle(fontSize: 14),
                                                        ),
                                                      ),
                                                      Flexible(
                                                        flex: 1,
                                                        fit: FlexFit.tight,
                                                        child: Text(
                                                          '- ' + moneda.format(_totalPagoMonedero),
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                          textAlign: TextAlign.end,
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                : SizedBox(
                                                    height: 0,
                                                  ),
                                        ],
                                      )
                                    ),
        

                                    (total != null && total > 0 && subTotal != null && subTotal > 0 && deliveryCost != null && totalDiscounts != null)
                                        ? Container(
                                            margin: EdgeInsets.only(top: 15, bottom: 15),
                                            padding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
                                            decoration: BoxDecoration(
                                              color: DataUI.chedrauiBlueColor,
                                            ),
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Flexible(
                                                      flex: 1,
                                                      fit: FlexFit.tight,
                                                      child: Text(
                                                        "Total a pagar",
                                                        style: TextStyle(fontSize: 20, color: DataUI.whiteText, fontWeight: FontWeight.w700, fontFamily: 'Archivo'),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      flex: 1,
                                                      fit: FlexFit.tight,
                                                      child: Text(
                                                        moneda.format(total - _totalPagoMonedero),
                                                        style: TextStyle(fontSize: 20, color: DataUI.whiteText, fontWeight: FontWeight.w700, fontFamily: 'Archivo'),
                                                        textAlign: TextAlign.end,
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          )
                                        : SizedBox(
                                            height: 0,
                                          ),
                                    Container(
                                        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 15, top: 0),
                                        padding: const EdgeInsets.only(left: 0, right: 0, bottom: 15, top: 0),
                                        alignment: Alignment.centerLeft,
                                        decoration: BoxDecoration(),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(left: 0),
                                              child: CheckboxListTile(
                                                activeColor: DataUI.chedrauiBlueColor,
                                                controlAffinity: ListTileControlAffinity.leading,
                                                title: const Text(
                                                  'Acepto los Términos y Condiciones de compra',
                                                  style: TextStyle(fontSize: 12),
                                                ),
                                                value: acceptedTyC,
                                                onChanged: (bool value) {
                                                  setState(() {
                                                    acceptedTyC = !acceptedTyC;
                                                  });
                                                },
                                              ),
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 0),
                                                    child: RaisedButton(
                                                        padding: EdgeInsets.all(14),
                                                        color: DataUI.btnbuy,
                                                        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                                                        disabledColor: DataUI.btnbuy.withOpacity(0.5),
                                                        child: loadingOrder
                                                            ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator())
                                                            : Text(
                                                                'Proceder al pago',
                                                                style: TextStyle(
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                        onPressed: (_isButtonDisabled || !_finishEditing) ? null : (acceptedTyC ? completeOrder : null)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      ),
                                    EncryptionDisclaimer(),

                                    */
                                    ],
                                  );
                                  break;
                              }
                            })
                        : Center(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 130),
                                  width: 246,
                                  height: 246,
                                  // height: 400,
                                  child: Image.asset('assets/BagCheckout.gif'),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 25),
                                  child: Text(
                                    'Orden en progreso',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: HexColor('#212B36'),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 269,
                                  margin: EdgeInsets.symmetric(vertical: 22),
                                  child: Text(
                                    'Tu orden está siendo procesada y puede tomar unos segundos en completarse… ',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: HexColor('#212B36'),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                  )),
            )
          : Center(child: CircularProgressIndicator()),
    ));
  }

  _showResponseDialog(msg, {title}) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title ?? "Error"),
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

  getErrorsFromBodyResponse(List errorsList) {
    List errorsMsgs = [];
    errorsList.forEach((e) {
      errorsMsgs.add(e['message']);
    });
    String errorsStr = errorsMsgs.join('\n');
    return errorsStr;
  }

  completeOrder() async {
    if (!loadingOrder) {
      setState(() {
        loadingOrder = true;
      });
      if (monederoSelected && payMethod == null) {
        //monederoSoloData();
        await placeOrder('Monedero', payMethod, needsAdditionalData: true);
      } else {
        switch (payMethod) {
          case PaymentMethod.paypal:
            //generarVista();
            await placeOrder('Paypal', payMethod);
            break;
          case PaymentMethod.associatedStore:
            //associatedStoreData();
            await placeOrder('Pago en tienda asociada', payMethod);
            break;
          case PaymentMethod.card:
            //openPayData();
            await placeOrder('Tarjeta', payMethod);
            break;
          case PaymentMethod.registredCard:
            await placeOrder('Tarjeta', payMethod);
            //registredCardData();
            break;
          case PaymentMethod.onDelivery:
            //onDeliveryData();
            await placeOrder('Contra entrega', payMethod);
            break;
          case PaymentMethod.onStore:
            //onStoreData();
            await placeOrder('En otra tienda', payMethod);
            break;
          default:
        }
      }
    }
  }

  setPaymentMonedero() async {
    var paymentArgs = {"paymentMethod": "monedero", "token": _idMonedero, "amount": _totalPagoMonedero};
    print(paymentArgs);
    var setPaymentResult = await PaymentServices.setPaymentMethod(paymentArgs, cartCode);
    if (setPaymentResult != null) {
      if (setPaymentResult['errors'] != null) {
        if (setPaymentResult['errors'][0]['type'] == "NoEnoughBalanceInMonederoError") {
          _showResponseDialog("Saldo insuficiente en el monedero");
          return null;
        } else {
          _showResponseDialog("Error al procesar pago con monedero");
          return null;
        }
      }
    }
    return setPaymentResult;
  }

  monederoSoloData() async {
    if (_pagoMonederoExitoso) {
      var orderData = await PaymentServices.placeOrder(cartCode);
      if (orderData != null) {
        print("ORDER CODE: ${orderData['code']}");
        await FireBaseEventController.sendAnalyticsEventEcommercePurchase(orderData, 'Monedero', _totalPagoMonedero, _saldoMonedero - _totalPagoMonedero);
        var paynetDetail = await PaymentServices.getPaynetPaymentDetail(orderData['code']);
        await Navigator.push(
          context,
          MaterialPageRoute(
            settings: RouteSettings(name: DataUI.checkoutConfirmationRoute),
            builder: (context) => CheckoutConfirmationPage(paymentMethod: PaymentMethod.monedero, orderData: orderData, shippingData: tiendasEntrega, shippingDatetime: horarioEntregaTextForOrder, monederoData: _totalPagoMonedero, additionalData: paynetDetail),
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
      } else {
        _showResponseDialog("No se puede generar la orden.");
      }
    } else {
      _showResponseDialog("Por favor, seleccione una forma de pago válida.");
    }
    setState(() {
      loadingOrder = false;
    });
  }

  validateCoupon() async {
    if (!_validandoCupon) {
      setState(() {
        _validandoCupon = true;
        _isButtonDisabled = true;
      });
      var resultCupon = await CarritoServices.addCouponWithTokenToCart(_numeroCupon, _tokenCupon);
      if (resultCupon != null) {
        if (resultCupon == true) {
          setState(() {
            _currentCart = null;
          });
          var resultCarrito = await CarritoServices.getCart();
          setState(() {
            _validandoCupon = false;
            _couponResultColor = Colors.green;
            _couponResultText = 'Cupón $_numeroCupon aplicado exitosamente.';
            _isButtonDisabled = false;
            _currentCart = resultCarrito;

            fillCartVars(resultCarrito);
          });
        } else {
          setState(() {
            _validandoCupon = false;
            _isButtonDisabled = false;
            _couponResultColor = Colors.red;
            _couponResultText = resultCupon['errorMessage'];
          });
        }
      } else {
        setState(() {
          _validandoCupon = false;
          _isButtonDisabled = false;
          _couponResultColor = Colors.red;
          _couponResultText = 'El cupón $_numeroCupon no es válido.';
        });
      }
    }
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
        _consignmentsList.add({"code": consigment.consignmentCode, "selectedDateIndex": consigment.selectedDateIndex, "selectedHourIndex": consigment.selectedHourIndex, "repeated": consigment.repeated});
      }
    });
  }

  setCurrentInstallment(List<Installment> installments) {
    _installmentsList.clear();
    int index = 0;
    installments.forEach((elem) {
      if (elem.selectedInstallmentIndex == index) {
        _installmentsList.add({"code": elem.promoId, "selectedInstallmentIndex": elem.selectedInstallmentIndex, "repeated": elem.repeated});

        this._currentPromoId = elem.promoId;
      }
      index++;
    });

    installmentsList.forEach((elem) {
      if (elem.promoId == this._currentPromoId) {
        this._currentInstallment = elem.installments;
      }
      index++;
    });

    print("PAso 1");
  }

  confirmShippingInfo(List slotsToSave) async {
    //List slotsToSave = getSlotsToSave();
    //print(slotsToSave);
    List setSlotsResponses = await CarritoServices.setCartTimeSlots(slotsToSave);
    print(setSlotsResponses);
    var resultCarrito = await CarritoServices.getCart();
    setState(() {
      _currentCart = resultCarrito;
      _consignments = resultCarrito['consignments'];
      itemsCount = resultCarrito['entries'].length;
      cartCode = resultCarrito['code'];

      fillCartVars(resultCarrito);
    });
  }

  List getSlotsToSave() {
    List slotsToSave = new List();
    var baseSlot = {};
    int _selectedDayPrevious;
    int _selectedHourPrevious;
    DateTime now = new DateTime.now();
    Duration offsetD = now.timeZoneOffset;
    int offsetInt = offsetD.inHours.abs();
    setState(() {
      containsDHL = false;
    });
    for (var consignment in _slotsEntrega['slots']) {
      var code = consignment['consignmentCode'];
      var slots = consignment['slots'];
      if (slots.length == 0) {
        setState(() {
          containsDHL = true;
        });
      }
      for (var infoC in _consignmentsList) {
        if (code == infoC['code'] && slots.length > 0) {
          bool repeated = infoC['repeated'] ?? false;
          int _selectedDay = !repeated ? infoC['selectedDateIndex'] : _selectedDayPrevious;
          int _selectedHour = !repeated ? infoC['selectedHourIndex'] : _selectedHourPrevious;
          _selectedDayPrevious = !repeated ? _selectedDay : _selectedDayPrevious;
          _selectedHourPrevious = !repeated ? _selectedHour : _selectedHourPrevious;
          var timeSlot = slots[_selectedDay]['value']['slots'][_selectedHour];
          List<String> tmpFecha = slots[_selectedDay]["key"].split("/");
          slotsToSave.add({"timeFrom": timeSlot['dateFrom'].toString(), "timeTo": timeSlot['dateTo'].toString(), "selectedDate": '${tmpFecha[2]}-${tmpFecha[1]}-${tmpFecha[0]}T00:00:00Z', "consignmentCode": code.toString()});
          //baseSlot = {"timeFrom": timeSlot['dateFrom'].toString(), "timeTo": timeSlot['dateTo'].toString(), "selectedDate": '${tmpFecha[2]}-${tmpFecha[1]}-${tmpFecha[0]}T00:00:00Z'};
        }
      }
    }
    /*
    if(baseSlot != null){
      for (var consignment in _slotsEntrega['slots']) {
        var code = consignment['consignmentCode'];
        var newBaseSlot = {
          ...baseSlot,
          "consignmentCode": code.toString()
        };
        slotsToSave.add(newBaseSlot);
      }
    }
    */
    if (slotsToSave.length > 0) {
      var mainSlot = slotsToSave[0];
      horarioEntregaText = "";
      horarioEntregaTextForOrder = "";
      String fechaRaw = mainSlot['selectedDate'].split('T')[0];
      List<String> componentesFecha = fechaRaw.split('-');
      componentesFecha = componentesFecha.reversed.toList();
      String textoFinalFecha = componentesFecha.join('/');
      horarioEntregaText += "Fecha: " + textoFinalFecha;
      horarioEntregaTextForOrder += textoFinalFecha + ", ";
      DateTime horaFrom = DateTime.parse(mainSlot['timeFrom']);
      horaFrom = horaFrom.subtract(Duration(hours: offsetInt));
      String horaFromText = horaFrom.toIso8601String().split('T')[1];
      DateTime horaTo = DateTime.parse(mainSlot['timeTo']);
      horaTo = horaTo.subtract(Duration(hours: offsetInt));
      String horaToText = horaTo.toIso8601String().split('T')[1];
      String textoFinalHoraFrom = horaFromText.split(':')[0];
      String textoFinalHoraTo = horaToText.split(':')[0];
      horarioEntregaText += "\nHora: Entre " + textoFinalHoraFrom + " y " + textoFinalHoraTo + " hrs";
      horarioEntregaTextForOrder += "entre " + textoFinalHoraFrom + " y " + textoFinalHoraTo + " hrs";
    } else {
      setState(() {
        horarioEntregaText = "Entre 5 y 7 días hábiles";
        horarioEntregaTextForOrder = horarioEntregaText;
      });
    }
    return slotsToSave;
  }

  void submitSecondForm(payMethod) async {
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
    } else if (_formKeys[1].currentState.validate()) {
      _formKeys[1].currentState.save();
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

  String _validateCVVField(String value) {
    if (value.isEmpty || value.length < 3) {
      return 'Requerido';
    }
    return null;
  }

  Future<bool> getOpenPayToken() async {
    var cardData = json.encode({"card_number": paymentData.cardNumber.replaceAll(' ', ''), "holder_name": paymentData.cardName, "expiration_year": paymentData.cardYear, "expiration_month": paymentData.cardMonth, "cvv2": paymentData.cardSecurity});
    print(cardData);
    var resultToken = await PaymentServices.getTokenFromOpenPay(cardData);
    if (resultToken != null && resultToken['id'] != null) {
      tokenOpenPay = resultToken['id'];
      customerIdOpenPay = resultToken['customerId'];
      await setPaymentForCard();
      return true;
    } else {
      String errorCode = resultToken['error_code'].toString() ?? "1000";
      String errorMessage = await PaymentServices.getOpenpayErrorsList(errorCode);
      errorOpenPay = true;
      messageErrorOpenPay = errorMessage;
      return false;
    }
  }

  Future<bool> getTokenCustomerRegisterCard() async {
    const platform = const MethodChannel('com.cheadrui.com/decypher');

    var cardData = json.encode({
      'tarjetas': [
        {'idWallet': idWallet, 'numTarjeta': cards[_selectedRegistredCard]['identificador']}
      ]
    });
    var tarjeta = await BovedaService.getTarjeta(cardData);

    var tokenTarjeta = tarjeta['tokenTarjeta'] != null ? await platform.invokeMethod('decypher', {"text": tarjeta['tokenTarjeta']}) : null;
    var customerId = tarjeta['customerId'] != null ? await platform.invokeMethod('decypher', {"text": tarjeta['customerId']}) : null;

    if (tokenTarjeta != null && tokenTarjeta != "NA" && customerId != null) {
      this._tipoTarjeta = 2;
      tokenOpenPay = tokenTarjeta;
      customerIdOpenPay = customerId;
    } else {
      this._tipoTarjeta = 1;
      customerIdOpenPay = null;
    }

    return true;
  }

  Future<bool> getOpenPayTokenRegisterCard() async {
    try {
      const platform = const MethodChannel('com.cheadrui.com/decypher');

      var cardData = json.encode({
        'tarjetas': [
          {'idWallet': idWallet, 'numTarjeta': cards[_selectedRegistredCard]['identificador']}
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
        errorOpenPay = false;
        tokenOpenPay = resultToken['id'];
        _aceptaPuntos = resultToken['card']['points_card'];
        return true;
      } else {
        String errorCode = resultToken['error_code'].toString() ?? "1000";
        String errorMessage = await PaymentServices.getOpenpayErrorsList(errorCode);
        errorOpenPay = true;
        messageErrorOpenPay = errorMessage;
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  setPaymentForCard() async {
    var paymentArgs;
    if (customerIdOpenPay != null) {
      paymentArgs = {"paymentMethod": "card", "token": tokenOpenPay, "deviceSessionId": deviceSessionID, "useCardPoints": this._usarPuntos, "customerId": customerIdOpenPay};
    } else {
      paymentArgs = {
        "paymentMethod": "card",
        "token": tokenOpenPay,
        "deviceSessionId": deviceSessionID,
        "useCardPoints": this._usarPuntos,
        //"customerId": " "
      };
    }
    print('=============== setPaymentForCard');
    print(paymentArgs);
    var setPaymentResult = await PaymentServices.setPaymentMethod(paymentArgs, cartCode);
    print('setPaymentResult');
    print(setPaymentResult);
    return setPaymentResult;
  }

  Future<bool> getInstallments() async {
    try {
      setState(() {
        _numberOfInstallments = null;
        if (!tarjetasDropDownValues.contains("NONE")) {
          loadingInstallments = true;
        }
        installmentsList.clear();
      });

      if ((isLoggedIn && (_cardSelected != null && _cardSelected != 'NONE' && _cardSelected != 'NEW')) || (!isLoggedIn && (paymentData.cardNumber != null && paymentData.cardName != null && paymentData.cardYear != null && paymentData.cardMonth != null && paymentData.cardSecurity != null))) {
        var installmentsCard = await PaymentServices.getInstallmetsForCard();

        var cardData;
        var tarjetaInfo;
        var bankInfo;

        if (isLoggedIn) {
          cardData = json.encode({
            'tarjetas': [
              {'idWallet': idWallet, 'numTarjeta': this._cardSelected}
            ]
          });
          tarjetaInfo = await BovedaService.getInfoTarjeta(cardData);
        } else {
          cardData = json.encode({"card_number": paymentData.cardNumber.replaceAll(' ', ''), "holder_name": paymentData.cardName, "expiration_year": paymentData.cardYear, "expiration_month": paymentData.cardMonth, "cvv2": paymentData.cardSecurity, "device_session_id": deviceSessionID});
          tarjetaInfo = await PaymentServices.getInfoCardFromOpenPay(cardData);
        }

        if (!isLoggedIn && tarjetaInfo == null) {
          throw Exception('Invalid card');
        }

        String bankCard = "aaaaaaaaaaa123";
        String bankCardOpt1 = "aaaaaaaaaaa123";
        String typeCard = "";

        if ((isLoggedIn && tarjetaInfo != null && tarjetaInfo["statusOperation"]["code"] == 0) || (!isLoggedIn && tarjetaInfo != null)) {
          bankCard = tarjetaInfo["bankName"] ?? tarjetaInfo['bank_name'];
          typeCard = tarjetaInfo["type"];

          bankCard = bankCard.toLowerCase();
          typeCard = typeCard.toLowerCase();

          if (bankCard == "bancomer") {
            bankCardOpt1 = "bbva";
          }

          if (bankCard == "american express") {
            bankCardOpt1 = " amex";
          }
        }

        Installment elem = null;
        List<Installment> installmentsListTemp = [];

        bool promotionsFound = (installmentsCard.length > 0);
        List installments = [];

        Installment def = new Installment("NO", true, repeated: false);
        def.baseAmount = 0;
        def.benefitType = "0";

        def.creditPlan = "";
        def.displayMessage = "Pago en una sola exhibición";
        def.installments = 0;
        def.limitAmount = 0;
        def.printerMessage = "";
        def.tender = 0;
        def.tlogMessage = "";
        def.type = 0;
        def.selectedInstallmentIndex = 0;

        installmentsListTemp.add(def);

        if (promotionsFound) {
          for (num i = 0; i < installmentsCard.length; i++) {
            installmentPromoids.add(installmentsCard[i]['promoId']);
            installmentNames.add(installmentsCard[i]['installments'].toString());
            String msg = '${installmentsCard[i]['installments']} meses sin intereses';
            /*
            if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('2 msi')) {
              msg = "2 meses sin intereses";
            } else if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('3 msi')) {
              msg = "3 meses sin intereses";
            } else if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('4 msi')) {
              msg = "4 meses sin intereses";
            } else if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('5 msi')) {
              msg = "5 meses sin intereses";
            } else if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('6 msi')) {
              msg = "6 meses sin intereses";
            } else if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('7 msi')) {
              msg = "7 meses sin intereses";
            } else if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('8 msi')) {
              msg = "8 meses sin intereses";
            } else if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('9 msi')) {
              msg = "9 meses sin intereses";
            } else if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('10 msi')) {
              msg = "10 meses sin intereses";
            } else if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('11 msi')) {
              msg = "11 meses sin intereses";
            } else if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('12 msi')) {
              msg = "12 meses sin intereses";
            } else if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('13 msi')) {
              msg = "13 meses sin intereses";
            } else if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('14 msi')) {
              msg = "14 meses sin intereses";
            } else if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('15 msi')) {
              msg = "15 meses sin intereses";
            } else if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('16 msi')) {
              msg = "16 meses sin intereses";
            } else if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('17 msi')) {
              msg = "17 meses sin intereses";
            } else if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('18 msi')) {
              msg = "18 meses sin intereses";
            } else if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('19 msi')) {
              msg = "19 meses sin intereses";
            } else if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('20 msi')) {
              msg = "20 meses sin intereses";
            } else if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('21 msi')) {
              msg = "21 meses sin intereses";
            } else if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('22 msi')) {
              msg = "22 meses sin intereses";
            } else if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('23 msi')) {
              msg = "23 meses sin intereses";
            } else if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('24 msi')) {
              msg = "24 meses sin intereses";
            } else if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('27 msi')) {
              msg = "27 meses sin intereses";
            } else if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('30 msi')) {
              msg = "30 meses sin intereses";
            } else if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('33 msi')) {
              msg = "33 meses sin intereses";
            } else if (installmentsCard[i]['printerMessage'].toLowerCase().startsWith('36 msi')) {
              msg = "36 meses sin intereses";
            }
            */

            installments.add(msg);

            elem = new Installment(installmentsCard[i]['promoId'], true, repeated: false);
            elem.baseAmount = installmentsCard[i]['baseAmount'];
            elem.benefitType = installmentsCard[i]['benefitType'];

            elem.creditPlan = installmentsCard[i]['creditPlan'];
            elem.displayMessage = msg;
            elem.installments = installmentsCard[i]['installments'];
            elem.limitAmount = installmentsCard[i]['limitAmount'];
            elem.printerMessage = installmentsCard[i]['printerMessage'];
            elem.tender = installmentsCard[i]['tender'];
            elem.tlogMessage = installmentsCard[i]['tlogMessage'];
            elem.type = installmentsCard[i]['type'];

            if (typeCard == 'credit') {
              if (installmentsCard[i]['tlogMessage'].toString().toLowerCase().contains(bankCard) || installmentsCard[i]['tlogMessage'].toString().toLowerCase().contains(bankCardOpt1)) {
                installmentsListTemp.add(elem);
              }
            }
          }
        }

        print(installments);
        installments.sort((a, b) {
          try {
            return int.parse(a.split(' ')[0]).compareTo(int.parse(b.split(' ')[0]));
          } catch (e) {
            return 0;
          }
        });
        installmentsListTemp.sort((a, b) => a.installments.compareTo(b.installments));

        setState(() {
          installmentList = installments;
          loadingInstallments = false;
          hasPromotions = promotionsFound;
          installmentsList = installmentsListTemp;
          installmentsList.sort((a, b) => a.installments.compareTo(b.installments));
        });
        return tarjetaInfo != null;
      }
    } catch (e) {
      setState(() {
        loadingInstallments = false;
      });
      return false;
    }
  }

  Future<void> setInstallment() async {
    if (_currentPromoId != null && _currentPromoId != "NO") {
      var selectedInstallment = {"promoId": _currentPromoId, "installments": _currentInstallment.toString()};
      await PaymentServices.setInstallmetsForCard(selectedInstallment);
    }
  }

  Future placeOrder(String orderType, PaymentMethod pm, {bool needsAdditionalData = false}) async {
    setState(() {
      loadingOrder = true;
    });
    var orderData = await PaymentServices.placeOrder(cartCode);
    if (orderData != null && orderData['errors'] == null) {
      var paynetDetail;
      if (needsAdditionalData) {
        paynetDetail = await PaymentServices.getPaynetPaymentDetail(orderData['code']);
      }
      await FireBaseEventController.sendAnalyticsEventEcommercePurchase(orderData, orderType, _totalPagoMonedero, _saldoMonedero - _totalPagoMonedero);
      setState(() {
        loadingOrder = false;
      });
      await Navigator.push(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: DataUI.checkoutConfirmationRoute),
          builder: (context) => CheckoutConfirmationPage(paymentMethod: pm, orderData: orderData, shippingData: tiendasEntrega, shippingDatetime: horarioEntregaTextForOrder, monederoData: _totalPagoMonedero, additionalData: paynetDetail),
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
    } else if (orderData != null && orderData['errors'] != null) {
      List errorsList = orderData['errors'];
      List errorMsgs = [];
      errorsList.forEach((e) {
        errorMsgs.add(e['message']);
      });
      String errorsStr = errorMsgs.join("\n");
      setState(() {
        loadingOrder = false;
      });
      _showResponseDialog("Errores detectados al procesar el pago con $orderType:\n$errorsStr");
    } else {
      setState(() {
        loadingOrder = false;
      });
      _showResponseDialog("Error al procesar el pago con $orderType.");
    }
  }

  Future<bool> setOpenPayData() async {
    bool cardIsValid = await getOpenPayToken();
    if (cardIsValid) {
      await setInstallment();
    }
    return cardIsValid;
  }

  Future<bool> getCVVRegistredCard() async {
    bool resultOpenPay = false;
    var cardData = json.encode({
      'tarjetas': [
        {'idWallet': idWallet, 'numTarjeta': this._cardSelected}
      ]
    });
    var tarjeta = await BovedaService.getTarjeta(cardData);

    const platform = const MethodChannel('com.cheadrui.com/decypher');

    var numTarjeta = await platform.invokeMethod('decypher', {"text": tarjeta['numTarjeta']});

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
              keyboardType: TextInputType.number,
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
                    loadingOrder = false;
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

  void openPayData() async {
    bool cardIsValid = tokenOpenPay != null;
    if (tokenOpenPay == null) {
      cardIsValid = await getOpenPayToken();
    }
    if (cardIsValid) {
      var orderData = await PaymentServices.placeOrder(cartCode);
      if (orderData != null) {
        await FireBaseEventController.sendAnalyticsEventEcommercePurchase(orderData, 'Tarjeta', _totalPagoMonedero, _saldoMonedero - _totalPagoMonedero);
        await Navigator.push(
          context,
          MaterialPageRoute(
            settings: RouteSettings(name: DataUI.checkoutConfirmationRoute),
            builder: (context) => CheckoutConfirmationPage(paymentMethod: PaymentMethod.card, orderData: orderData, shippingData: tiendasEntrega, shippingDatetime: horarioEntregaTextForOrder, monederoData: _totalPagoMonedero, additionalData: null),
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
      } else {
        _showResponseDialog("Error al procesar el pago con tarjeta.");
      }
    } else {
      _showResponseDialog("Error al procesar la tarjeta ingresada.");
    }
    setState(() {
      loadingOrder = false;
    });
  }

  Future<void> getTokenFromSelectedCard() async {
    setState(() {
      tokenOpenPay = null;
      bankPointsRaw = null;
      bankPointsRaw = null;
      _isButtonDisabled = true;
    });
    String cardIdentifier = cards[_selectedRegistredCard]['identificador'].toString();
    bool hasPoints = cards[_selectedRegistredCard]['bankPoints'];
    var tokenInfo;
    /*
    var cardOpenPay = json.encode({
      'tarjetas': [
        {
          'idWallet': idWallet,
          'numTarjeta': cardIdentifier
        }
      ]
    });
    */
    //tokenInfo = await PaymentServices.getTokenOpenPayCard(cardOpenPay);
    //if(tokenInfo == null || tokenInfo['tokenTarjeta'] == null){
    var cardData = json.encode({"idWallet": idWallet, "idTarjeta": cardIdentifier, "puntos": hasPoints});
    tokenInfo = await PaymentServices.getTokenRegistredCard(cardData);
    if (tokenInfo != null) {
      setState(() {
        tokenOpenPay = tokenInfo['token'];
        bankPointsRaw = tokenInfo['puntos'];
        bankPointsMXN = tokenInfo['puntosMxn'];
        _isButtonDisabled = false;
      });
    }
    //} else {
    //  setState(() {
    //    tokenOpenPay = tokenInfo['tokenTarjeta'];
    //    bankPointsRaw = tokenInfo['puntos'];
    //    bankPointsRaw = tokenInfo['puntosMxn'];
    //  });
    //}
  }

  Future<void> getTokenFromSelectedCardCvv() async {
    setState(() {
      tokenOpenPay = null;
      bankPointsRaw = null;
      bankPointsRaw = null;
      _isButtonDisabled = true;
    });
    String cardIdentifier = cards[_selectedRegistredCard]['identificador'].toString();
    bool hasPoints = cards[_selectedRegistredCard]['bankPoints'];

    var tokenInfo;
    /*
    var cardOpenPay = json.encode({
      'tarjetas': [
        {
          'idWallet': idWallet,
          'numTarjeta': cardIdentifier
        }
      ]
    });
    */
    //tokenInfo = await PaymentServices.getTokenOpenPayCard(cardOpenPay);
    //if(tokenInfo == null || tokenInfo['tokenTarjeta'] == null){

    const decypher = const MethodChannel('com.cheadrui.com/decypher');

    print('cvv2: $_cvv');

    String cvv2 = await decypher.invokeMethod('encrypter', {"text": _cvv});

    print('cvv2: $cvv2');

    var cardData = json.encode({"idWallet": idWallet, "idTarjeta": cardIdentifier, "puntos": hasPoints, "cvv2": cvv2});
    tokenInfo = await PaymentServices.getTokenRegistredCard(cardData);
    if (tokenInfo != null) {
      setState(() {
        tokenOpenPay = tokenInfo['token'];
        bankPointsRaw = tokenInfo['puntos'];
        bankPointsMXN = tokenInfo['puntosMxn'];
        _isButtonDisabled = false;
      });
    }
  }

  Future<void> getPointsFromSelectedCard() async {
    var resultPoints = await PaymentServices.getPointsFromOpenPay(this.tokenOpenPay);
    if (resultPoints != null) {
      this._pointsType = resultPoints['points_type'];
      this._remainingPoints = resultPoints['remaining_points'];
      this._remainingMxn = resultPoints['remaining_mxn'];

      return true;
    } else {
      return false;
    }
  }

  Future<void> getPointsFromSelectedCardTokenizada() async {
    var resultPoints = await PaymentServices.getPointsFromOpenPayTokenizada(this.tokenOpenPay, this.customerIdOpenPay);
    if (resultPoints != null) {
      this._pointsType = resultPoints['points_type'];
      this._remainingPoints = resultPoints['remaining_points'];
      this._remainingMxn = resultPoints['remaining_mxn'];

      return true;
    } else {
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
      if (tokenAvailable) {
        await getPointsFromSelectedCard();
      }
    } else if (_tipoTarjeta == 2) {
      tokenAvailable = await PaymentServices.updateCvv2OnOpenpay(tokenOpenPay, customerIdOpenPay, _cvv);
      await getPointsFromSelectedCardTokenizada();
    }

    print('tokenOpenPay');
    print(tokenOpenPay);

    if (tokenOpenPay != null) {
      if (this._remainingPoints != null && this._remainingPoints > 0) {
        num restante = total - this._remainingMxn;
        if (restante < 0) {
          restante = 0;
        }
        await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Pago con puntos"),
                content: new Text("Cuentas con puntos bancarios\n¿Deseas utilizarlos en tu compra?\n\nTarjeta:                    " + moneda.format(restante) + "\nPuntos:                     " + moneda.format(this._remainingMxn) + "\nTotal:                        " + moneda.format(total)),
                actions: <Widget>[
                  FlatButton(
                    color: DataUI.btnbuy,
                    onPressed: () {
                      this._usarPuntos = false;
                      Navigator.pop(context);
                    },
                    child: Text(
                      "No",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  FlatButton(
                      onPressed: () {
                        this._usarPuntos = true;
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Si",
                        style: TextStyle(color: DataUI.whiteText),
                      ),
                      color: DataUI.chedrauiBlueColor),
                ],
              );
            });
      }
      var resultSetRegistredCard = await setPaymentForCard();
      if (resultSetRegistredCard == null) {
        return false;
      }
      await setInstallment();
      return true;
    }
    return false;
  }

  Future<void> registredCardData() async {
    /*
    bool tokenAvailable = await getOpenPayTokenRegisterCard();
    if(tokenAvailable){
      await getPointsFromSelectedCard();
    }
    */

    await getTokenCustomerRegisterCard();

    if (this._tipoTarjeta == 1) {
      bool tokenAvailable = await getOpenPayTokenRegisterCard();
      if (tokenAvailable) {
        await getPointsFromSelectedCard();
      }
    } else {
      await getPointsFromSelectedCardTokenizada();
    }

    if (tokenOpenPay != null) {
      if (this._remainingPoints != null && this._remainingPoints > 0) {
        num restante = total - this._remainingMxn;

        if (restante < 0) {
          restante = 0;
        }

        await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Pago con puntos"),
                content: new Text("Cuentas con puntos bancarios\n¿Deseas utilizarlos en tu compra?\n\nTarjeta:                    " + moneda.format(restante) + "\nPuntos:                     " + moneda.format(this._remainingMxn) + "\nTotal:                        " + moneda.format(total)),
                actions: <Widget>[
                  FlatButton(
                    color: DataUI.btnbuy,
                    onPressed: () {
                      this._usarPuntos = false;
                      Navigator.pop(context);
                    },
                    child: Text(
                      "No",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  FlatButton(
                      onPressed: () {
                        this._usarPuntos = true;
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Si",
                        style: TextStyle(color: DataUI.whiteText),
                      ),
                      color: DataUI.chedrauiBlueColor),
                ],
              );
            });
      }

      await setPaymentForCard();
      await setInstallment();
      var orderData = await PaymentServices.placeOrder(cartCode);
      if (orderData != null) {
        await FireBaseEventController.sendAnalyticsEventEcommercePurchase(orderData, 'Tarjeta registrada', _totalPagoMonedero, _saldoMonedero - _totalPagoMonedero);
        await Navigator.push(
          context,
          MaterialPageRoute(
            settings: RouteSettings(name: DataUI.checkoutConfirmationRoute),
            builder: (context) => CheckoutConfirmationPage(paymentMethod: PaymentMethod.registredCard, orderData: orderData, shippingData: tiendasEntrega, shippingDatetime: horarioEntregaTextForOrder, monederoData: _totalPagoMonedero, additionalData: null),
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
      } else {
        setState(() {
          loadingOrder = false;
        });
        _showResponseDialog("Error al procesar el pago con la tarjeta seleccionada.");
      }
    } else {
      setState(() {
        loadingOrder = false;
      });
      _showResponseDialog("La tarjeta seleccionada no es válida o el CVV es incorrecto.");
    }
  }

  Future setAssociatedStoreData() async {
    var paymentArgs = {"paymentMethod": "PAYINASSOCIATEDSTORE"};
    var setPaymentResult = await PaymentServices.setPaymentMethod(paymentArgs, cartCode);
    return setPaymentResult;
  }

  void associatedStoreData() async {
    var paymentArgs = {"paymentMethod": "PAYINASSOCIATEDSTORE"};
    var setPaymentResult = await PaymentServices.setPaymentMethod(paymentArgs, cartCode);
    var orderData = await PaymentServices.placeOrder(cartCode);
    if (orderData != null) {
      print("ORDER CODE: ${orderData['code']}");
      await FireBaseEventController.sendAnalyticsEventEcommercePurchase(orderData, 'Tienda Asociada', _totalPagoMonedero, _saldoMonedero - _totalPagoMonedero);
      var paynetDetail = await PaymentServices.getPaynetPaymentDetail(orderData['code']);
      await Navigator.push(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: DataUI.checkoutConfirmationRoute),
          builder: (context) => CheckoutConfirmationPage(paymentMethod: PaymentMethod.associatedStore, orderData: orderData, shippingData: tiendasEntrega, shippingDatetime: horarioEntregaTextForOrder, monederoData: _totalPagoMonedero, additionalData: paynetDetail),
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
    } else {
      _showResponseDialog("No se puede generar la orden.");
    }
    setState(() {
      loadingOrder = false;
    });
  }

  Future setOnDeliveryData() async {
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
        paymethodOnDelivery = 'VISAMASTERCARD';
        break;
      default:
    }
    var paymentArgs = {"paymentMethod": "PAYONDELIVERY", "payOnDeliveryPaymentType": paymethodOnDelivery};
    var setPaymentResult = await PaymentServices.setPaymentMethod(paymentArgs, cartCode);
    return setPaymentResult;
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
        paymethodOnDelivery = 'VISAMASTERCARD';
        break;
      default:
    }
    var paymentArgs = {"paymentMethod": "PAYONDELIVERY", "payOnDeliveryPaymentType": paymethodOnDelivery};
    var setPaymentResult = await PaymentServices.setPaymentMethod(paymentArgs, cartCode);
    var orderData = await PaymentServices.placeOrder(cartCode);
    if (orderData != null) {
      print("ORDER CODE: ${orderData['code']}");
      await FireBaseEventController.sendAnalyticsEventEcommercePurchase(orderData, 'Contra Entrega', _totalPagoMonedero, _saldoMonedero - _totalPagoMonedero);
      await Navigator.push(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: DataUI.checkoutConfirmationRoute),
          builder: (context) => CheckoutConfirmationPage(paymentMethod: PaymentMethod.onDelivery, orderData: orderData, shippingData: tiendasEntrega, shippingDatetime: horarioEntregaTextForOrder, monederoData: _totalPagoMonedero, additionalData: null),
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
    } else {
      _showResponseDialog("No se puede generar la orden.");
    }
    setState(() {
      loadingOrder = false;
    });
  }

  Future setOnStoreData() async {
    var paymentArgs = {"paymentMethod": "PAYINSTORE"};
    var setPaymentResult = await PaymentServices.setPaymentMethod(paymentArgs, cartCode);
    return setPaymentResult;
  }

  void onStoreData() async {
    var paymentArgs = {"paymentMethod": "PAYINSTORE"};
    var setPaymentResult = await PaymentServices.setPaymentMethod(paymentArgs, cartCode);
    var orderData = await PaymentServices.placeOrder(cartCode);
    if (orderData != null) {
      print("ORDER CODE: ${orderData['code']}");
      await FireBaseEventController.sendAnalyticsEventEcommercePurchase(orderData, 'Tienda', _totalPagoMonedero, _saldoMonedero - _totalPagoMonedero);
      await Navigator.push(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: DataUI.checkoutConfirmationRoute),
          builder: (context) => CheckoutConfirmationPage(paymentMethod: PaymentMethod.onStore, orderData: orderData, shippingData: tiendasEntrega, shippingDatetime: horarioEntregaTextForOrder, monederoData: _totalPagoMonedero, additionalData: null),
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
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

  textCheckout() async {
    List body = await KenticoServices.getTextCheckout();
    String textAsociado = '';
    String textTienda = '';
    textAsociado = body.first['elements']['pre_pago_en_establecimientos_asociados']['value'];
    textTienda = body.first['elements']['pre_pago_en_tiendas_chedraui']['value'];
    setState(() {
      kenticoTextAsociado = textAsociado;
      kenticoTextTienda = textTienda;
    });
  }
}

Container LoginSuggestion(BuildContext context) {
  return Container(
    margin: const EdgeInsets.all(15.0),
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
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          '¿Tienes una cuenta Chedraui? Inicia sesión para un completar tu pedido más rápido.',
          maxLines: 3,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: RaisedButton(
                  color: DataUI.btnbuy,
                  child: Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, DataUI.loginRoute);
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
