import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/utils/payment_card.dart' as UtilsPayment;
import 'package:chd_app_demo/utils/CardUtils.dart' as UtilsCard;
import 'package:chd_app_demo/utils/input_formatters.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chd_app_demo/views/Monedero/CardData.dart';
import 'package:chd_app_demo/services/MonederoServices.dart';
import 'package:chd_app_demo/widgets/termCondWidget.dart';
import 'dart:io';
// import 'package:flutter_card_io/flutter_card_io.dart';
import 'package:chd_app_demo/views/MasterPage/MasterPage.dart';
import 'package:chd_app_demo/views/MasterPage/MenuScreen.dart';
import 'package:chd_app_demo/views/Monedero/MonederoPage.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';

enum NewPaymentMethod { card }

class NewCreditCard extends StatefulWidget {
  final bool fromMonedero;
  NewCreditCard({Key key, this.fromMonedero}) : super(key: key);

  @override
  _NewCreditCardState createState() => _NewCreditCardState();
}

class _NewCreditCardState extends State<NewCreditCard> {
  ScrollController _scrollController = new ScrollController();
  NewPaymentMethod newPaymentMethod = NewPaymentMethod.card;
  TextEditingController numberController = new TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  UtilsPayment.PaymentCard _paymentCard = new UtilsPayment.PaymentCard();
  SharedPreferences prefs;
  CardData cardData = new CardData();
  bool enabledButtons = true;
  String idWallet;

  final Map<String, FocusNode> _focusForm = {
    "numeroTarjeta": FocusNode(),
    "expiraTarjeta": FocusNode(),
    "cvvTarjeta": FocusNode(),
    "nombreTarjeta": FocusNode(),
    "aliasTarjeta": FocusNode(),
  };

  // String _validateNotEmpty(String value) {
  //   if (value.isEmpty) {
  //     return 'Requerido';
  //   }
  //   return null;
  // }

  _showResponseDialog(msg) {
    if (widget.fromMonedero == true) {
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
                    Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
                    Navigator.pushNamed(context, DataUI.monederoRoute);
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
    } else {
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
  }

  void _getCardTypeFrmNumber() {
    String input = UtilsPayment.CardUtils.getCleanedNumber(numberController.text);
    UtilsPayment.CardType cardTypeCT = UtilsPayment.CardUtils.getCardTypeFrmNumber(input);
    String cartTypeS = UtilsCard.CardUtils.getCardTypeFrmNumber(input);
    setState(() {
      _paymentCard.type = cardTypeCT;
      cardData.tipoTarjeta = cartTypeS;
    });
  }

  Future<bool> addPaymentMethod() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        enabledButtons = false;
      });

      const platform = const MethodChannel('com.cheadrui.com/decypher');
      String deviceSessionId;
      var platformId;
      try {
        platformId = const MethodChannel('com.cheadrui.com/paymethods');

        deviceSessionId = await platformId.invokeMethod('getID');
    } on Exception catch (exception) {
        print(exception);
        _showResponseDialog("Ocurrió un error al registrar su método de pago.");
    } catch (error) {
        print(error);
        _showResponseDialog("Ocurrió un error al registrar su método de pago.");
    }




      CardData cardToSave = new CardData();
      cardToSave.idWallet = await idWallet;
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
        switch (code) {
          case 0:
            if (widget.fromMonedero == true) {
              _showResponseDialog(result["statusOperation"]["description"]);
            } else {
              Navigator.pop(context, true);
            }

            break;
          case 1:
          case 2:
            _showResponseDialog(result["statusOperation"]["description"]);
            break;
          default:
            _showResponseDialog("Ocurrió un error al registrar su método de pago.");
            break;
        }
      }

      setState(() {
        enabledButtons = true;
      });
    }
  }

  Future<void> startView() async {
    prefs = await SharedPreferences.getInstance();
    idWallet = prefs.getString('idWallet');
  }

  @override
  void initState() {
    startView();
    _paymentCard.type = UtilsPayment.CardType.Others;
    cardData.tipoTarjeta = "";
    numberController.addListener(_getCardTypeFrmNumber);
    super.initState();
  }

  _scanCard() async {
    //FocusScope.of(context).requestFocus(new FocusNode());
    if (Platform.isAndroid) {
      //FocusScope.of(context).requestFocus(new FocusNode());
      const platform = const MethodChannel('com.cheadrui.com/scanCard');
      await platform.invokeMethod('scanCard').then((onValue) {
        print('///////////////');
        print(onValue);
        print('///////////////');
        setState(() {
          numberController.clear();
          numberController = new TextEditingController(text: onValue);
        });

        _getCardTypeFrmNumber();
      }).catchError((onError) {
        print(onError);
      });
    } else if (Platform.isIOS) {
      _scanCardIOS();
    }
  }

  _scanCardIOS() async {
    // numberController.clear();
    // _focusForm['numeroTarjeta'].unfocus();
    //Platform messages may fail, so we use a try/catch PlatformException.
    //FocusScope.of(context).requestFocus(new FocusNode());
    const platform = const MethodChannel('com.cheadrui.com/NativeCall');
    await platform.invokeMethod("scanCard").then((onValue) {
      setState(() {
        numberController.clear();
        numberController = new TextEditingController(text: onValue['cardNumber']);
      });
      print('///////////////');
      print(onValue['cardNumber']);
      print('///////////////');

      _getCardTypeFrmNumber();
    }).catchError((onError) {
      print(onError);
    });
    //FocusScope.of(context).requestFocus(new FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return WidgetContainer(Scaffold(
      backgroundColor: DataUI.backgroundColor,
      appBar: GradientAppBar(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            HexColor('#F56D00'),
            HexColor('#F56D00'),
            HexColor('#F78E00'),
          ],
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context, false);
                });
          },
        ),
        elevation: 0,
        centerTitle: true,
        title: Text('Agregar Tarjeta', style: TextStyle(color: Colors.white, fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 19)),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Theme(
                data: ThemeData(
                  primaryColor: DataUI.chedrauiColor,
                  hintColor: HexColor('#C4CDD5'),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 15, top: 20),
                      child: Text(
                        'Información de tarjeta',
                        style: TextStyle(color: HexColor('#212B36'), fontFamily: 'Archivo', fontSize: 16),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Text(
                            'Tarjeta de Crédito o Débito',
                            style: TextStyle(color: HexColor('#212B36'), fontFamily: 'Archivo', fontSize: 14),
                          ),
                          Row(
                            children: <Widget>[
                              VisaSVG(),
                              MasterCardSVG(),
                              AmexSVG(),
                              SizedBox(
                                width: 30,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          Form(
                            autovalidate: true,
                            key: _formKey,
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(bottom: 5),
                                          child: Text(
                                            'Número de Tarjeta',
                                            style: TextStyle(color: HexColor('#212B36'), fontFamily: 'Archivo', fontSize: 12),
                                          ),
                                        ),
                                        Row(
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
                                                  border: OutlineInputBorder(),
                                                  contentPadding: const EdgeInsets.only(
                                                      top: 5,
                                                      bottom: 5,
                                                      left: 6, //todo
                                                      right: 6 //todo
                                                      ),
                                                  hintText: '**** **** **** 1203',
                                                  hintStyle: TextStyle(color: HexColor('#212B36').withOpacity(0.3), fontFamily: 'Archivo', fontSize: 14),
                                                ),
                                                controller: numberController,
                                                keyboardType: TextInputType.number,
                                                textInputAction: TextInputAction.next,
                                                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16), CardNumberInputFormatter()],
                                                focusNode: _focusForm['numeroTarjeta'],
                                                onFieldSubmitted: (String input) {
                                                  FocusScope.of(context).requestFocus(_focusForm['expiraTarjeta']);
                                                },
                                                onSaved: (input) {
                                                  _paymentCard.number = UtilsPayment.CardUtils.getCleanedNumber(input);
                                                  cardData.numTarjeta = UtilsCard.CardUtils.getCleanedNumber(input);
                                                },
                                                validator: UtilsPayment.CardUtils.validateCardNum,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.camera_alt),
                                              onPressed: () {
                                                _scanCard();
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: 10),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                            flex: 15,
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
                                                      border: OutlineInputBorder(),
                                                      contentPadding: const EdgeInsets.only(
                                                          top: 12,
                                                          bottom: 12,
                                                          left: 6, //todo
                                                          right: 6 //todo
                                                          ),
                                                      hintText: '12 /21',
                                                      hintStyle: TextStyle(color: HexColor('#212B36').withOpacity(0.3), fontFamily: 'Archivo', fontSize: 14),
                                                    ),
                                                    keyboardType: TextInputType.number,
                                                    textInputAction: TextInputAction.next,
                                                    inputFormatters: [WhitelistingTextInputFormatter.digitsOnly, new LengthLimitingTextInputFormatter(4), new CardMonthInputFormatter()],
                                                    focusNode: _focusForm['expiraTarjeta'],
                                                    onFieldSubmitted: (String input) {
                                                      FocusScope.of(context).requestFocus(_focusForm['cvvTarjeta']);
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
                                            flex: 15,
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
                                                        border: OutlineInputBorder(),
                                                        contentPadding: const EdgeInsets.only(
                                                            top: 12,
                                                            bottom: 12,
                                                            left: 6, //todo
                                                            right: 6 //todo
                                                            ),
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
                                                        FocusScope.of(context).requestFocus(_focusForm['nombreTarjeta']);
                                                      },
                                                      onSaved: (input) {
                                                        _paymentCard.cvv = int.parse(input);
                                                        cardData.cvv = input;
                                                      },
                                                      validator: _paymentCard.type == UtilsPayment.CardType.AmericanExpress ? UtilsPayment.CardUtils.validateCVVAmex : UtilsPayment.CardUtils.validateCVV),
                                                ],
                                              ),
                                            )),
                                        // Expanded(
                                        //     flex: 3,
                                        //     child: SizedBox(
                                        //       width: 10,
                                        //     )),
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
                                          border: OutlineInputBorder(),
                                          contentPadding: const EdgeInsets.only(
                                              top: 12,
                                              bottom: 12,
                                              left: 6, //todo
                                              right: 6 //todo
                                              ),
                                          hintText: 'Samuel Davis',
                                          hintStyle: TextStyle(color: HexColor('#212B36').withOpacity(0.3), fontFamily: 'Archivo', fontSize: 14),
                                        ),
                                        textInputAction: TextInputAction.next,
                                        focusNode: _focusForm['nombreTarjeta'],
                                        onFieldSubmitted: (String input) {
                                          FocusScope.of(context).requestFocus(_focusForm['aliasTarjeta']);
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
                                      margin: EdgeInsets.symmetric(vertical: 20),
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
                                              border: OutlineInputBorder(),
                                              contentPadding: const EdgeInsets.only(
                                                  top: 12,
                                                  bottom: 12,
                                                  left: 6, //todo
                                                  right: 6 //todo
                                                  ),
                                              hintText: '“Compras frecuentes”',
                                              hintStyle: TextStyle(color: HexColor('#212B36').withOpacity(0.3), fontFamily: 'Archivo', fontSize: 14),
                                            ),
                                            textInputAction: TextInputAction.done,
                                            focusNode: _focusForm['aliasTarjeta'],
                                            onSaved: (input) {
                                              cardData.aliasTarjeta = input;
                                            },
                                            validator: FormsTextValidators.validateTextWithoutEmoji,
                                          ),
                                        ],
                                      )),
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: 20),
                                    child: TermCondWidget(),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(left: 0, right: 0, bottom: 15, top: 0),
                                    padding: const EdgeInsets.only(left: 0, right: 0, bottom: 5, top: 0),
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(),
                                    child: Column(
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
                                                    'Agregar tarjeta bancaria',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  onPressed: enabledButtons ? addPaymentMethod : null),
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
                                                            Navigator.pop(context, null);
                                                          }
                                                        : null),
                                              ),
                                            ),
                                          ],
                                        ),
                                        !enabledButtons
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
                                            : SizedBox(
                                                height: 0,
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
            ),
          ),
        ),
      ),
    ));
  }
}
