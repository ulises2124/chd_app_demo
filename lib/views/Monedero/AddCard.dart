// import 'dart:io';

// import 'package:chedraui_flutter/utils/FormatCreditCard.dart';
// import 'package:chedraui_flutter/utils/HexValueConverter.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:chedraui_flutter/utils/DataUI.dart';
// import 'package:barcode_scan/barcode_scan.dart';
// import 'package:flutter/services.dart';
// import 'package:chedraui_flutter/services/MonederoServices.dart';
// import 'package:chedraui_flutter/utils/payment_card.dart' as UtilsPayment;
// import 'package:chedraui_flutter/utils/CardUtils.dart' as UtilsCard;
// import 'package:chedraui_flutter/utils/input_formatters.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:chedraui_flutter/views/Monedero/CardData.dart';
// import 'package:chedraui_flutter/views/Monedero/MonederoPage.dart';
// import 'package:chedraui_flutter/widgets/termCondWidget.dart';
// import 'package:flutter_card_io/flutter_card_io.dart';
// import 'package:chedraui_flutter/views/MasterPage/MasterPage.dart';
// import 'package:chedraui_flutter/views/MasterPage/MenuScreen.dart';

// class AddCard extends StatefulWidget {
//   AddCard({
//     Key key,
//   }) : super(key: key);
//   @override
//   _AddCardState createState() => _AddCardState();
// }

// class _AddCardState extends State<AddCard> {
//   SharedPreferences prefs;
//   String idWallet;

//   @override
//   void initState() {
//     super.initState();
//     getPreferences().then((x) {
//       setState(() {
//         idWallet = prefs.getString('idWallet') == null
//             ? ''
//             : prefs.getString('idWallet');
//       });
//     });
//   }

//   Future getPreferences() async {
//     prefs = await SharedPreferences.getInstance();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 1,
//           title: Text(
//             //"Agregar Tarjeta o Monedero",
//             "Agregar Tarjeta",
//             style: TextStyle(
//                 fontFamily: "Rubik",
//                 color: HexColor("#212B36"),
//                 fontSize: 17,
//                 fontWeight: FontWeight.normal),
//           ),
//           centerTitle: true,
//         ),
//         body: GestureDetector(
//           onTap: () {
//             FocusScope.of(context).requestFocus(new FocusNode());
//           },
//           child: SingleChildScrollView(
//             child: Column(
//               children: <Widget>[
//                 ToggleView(
//                   idWallet: this.idWallet,
//                 )
//               ],
//             ),
//           ),
//         ));
//   }
// }

// class ToggleView extends StatefulWidget {
//   final String idWallet;
//   ToggleView({Key key, this.idWallet}) : super(key: key);

//   _ToggleViewState createState() => _ToggleViewState();
// }

// class _ToggleViewState extends State<ToggleView> {
//   UtilsPayment.PaymentCard _paymentCard = new UtilsPayment.PaymentCard();

//   final _formKey = GlobalKey<FormState>();

//   String card;

//   bool _obscureText = true;

//   bool changeView = false;

//   bool buttonDisabled = false;

//   bool hiddenPassword = true;

//   String barcode = "";

//   var txtBarcode = new TextEditingController();

//   var txtContrasenia = new TextEditingController();

//   var txtMensajeResponse = new TextEditingController();

//   final FocusNode _name = FocusNode();
//   final FocusNode _date = FocusNode();
//   final FocusNode _cvv = FocusNode();
//   final FocusNode _alias = FocusNode();

//   final FocusNode _number = FocusNode();
//   final FocusNode _password = FocusNode();

//   String mensaje = "";

//   bool loading = false;

//   var _scaffoldKey = new GlobalKey<ScaffoldState>();
//   var numberController = new TextEditingController();
//   CardData cardData = new CardData();

//   @override
//   void initState() {
//     super.initState();
//     numberController.addListener(_getCardTypeFrmNumber);
//     _paymentCard.type = UtilsPayment.CardType.Others;
//   }

//   void _getCardTypeFrmNumber() {
//     String input =
//         UtilsPayment.CardUtils.getCleanedNumber(numberController.text);
//     UtilsPayment.CardType cardTypeCT =
//         UtilsPayment.CardUtils.getCardTypeFrmNumber(input);
//     String cartTypeS = UtilsCard.CardUtils.getCardTypeFrmNumber(input);
//     setState(() {
//       _paymentCard.type = cardTypeCT;
//       cardData.tipoTarjeta = cartTypeS;
//     });
//   }

//   _showResponseDialog(msg) {
//     return showDialog(
//         barrierDismissible: false,
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Resultado"),
//             content: Text(msg),
//             actions: <Widget>[
//               FlatButton(
//                 onPressed: () {
//                       Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                         builder: (context) => MonederoPage(),
//                         ),
//                     );
//                   // Navigator.of(context).pushAndRemoveUntil(
//                   //   MaterialPageRoute(
//                   //     builder: (BuildContext context) => MasterPage(
//                   //       initialWidget: MenuItem(
//                   //         id: 'monedero',
//                   //         title: 'Monedero Mi Chedraui',
//                   //         screen: MonederoPage(),
//                   //         color: DataUI.chedrauiColor2,
//                   //         textColor: DataUI.primaryText,
//                   //       ),
//                   //     ),
//                   //   ),
//                   //   (Route<dynamic> route) => false,
//                   // );
//                 },
//                 child: Text(
//                   "Cerrar",
//                   style: TextStyle(
//                     color: DataUI.chedrauiBlueColor,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ],
//           );
//         });
//   }

//   Future<String> submitForm() async {
//     if (_formKey.currentState.validate()) {
//       setState(() {
//         loading = true;
//         this.cardData.idWallet = widget.idWallet;
//       });
//       _formKey.currentState.save();
//       const platform = const MethodChannel('com.cheadrui.com/decypher');

//       String deviceSessionId;
//       const platformId = const MethodChannel('com.cheadrui.com/paymethods');
//       deviceSessionId = await platformId.invokeMethod('getID');

//       CardData cardToSave = new CardData();
//       cardToSave.idWallet = await cardData.idWallet;
//       cardToSave.numTarjeta = await platform
//           .invokeMethod('encrypter', {"text": cardData.numTarjeta});
//       cardToSave.tipoTarjeta = await platform
//           .invokeMethod('encrypter', {"text": cardData.tipoTarjeta});
//       cardToSave.bancoEmisor = await platform
//           .invokeMethod('encrypter', {"text": cardData.bancoEmisor});
//       cardToSave.aliasTarjeta = await platform
//           .invokeMethod('encrypter', {"text": cardData.aliasTarjeta});
//       cardToSave.nomTitularTarj = await platform
//           .invokeMethod('encrypter', {"text": cardData.nomTitularTarj});
//       cardToSave.cvv =
//           await platform.invokeMethod('encrypter', {"text": cardData.cvv});
//       cardToSave.fecExpira = await platform
//           .invokeMethod('encrypter', {"text": cardData.fecExpira});
//       cardToSave.deviceSessionId = deviceSessionId;

//       var result = await MonederoServices.addCard(cardToSave);

//       if (result != null) {
//         num code = int.parse(result["statusOperation"]["code"].toString());
//         switch (code) {
//           case 0:
//             _showResponseDialog(result["statusOperation"]["description"]);
//             setState(() {
//               loading = false;
//             });
//             break;
//           case 1:
//             _showResponseDialog(result["statusOperation"]["description"]);
//             setState(() {
//               loading = false;
//             });
//             break;
//           case 2:
//             _showResponseDialog(result["statusOperation"]["description"]);
//             setState(() {
//               loading = false;
//             });
//             break;
//           default:
//             _showResponseDialog(result["statusOperation"]["description"]);
//             setState(() {
//               loading = false;
//             });
//             break;
//         }
//       }
//     }
//   }

//   toggleButton() {
//     return Container(
//       margin: EdgeInsets.only(top: 15, right: 30, left: 30, bottom: 30),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         mainAxisSize: MainAxisSize.max,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           FlatButton(
//             onPressed: () {
//               setState(() {
//                 changeView = false;
//               });
//             },
//             color:
//                 changeView == false ? HexColor("#454F5B") : HexColor("#F4F6F8"),
//             child: Text(
//               "Tarjeta Bancaria",
//               style: TextStyle(
//                 fontFamily: "Rubik",
//                 fontSize: 14,
//                 fontWeight: FontWeight.normal,
//                 color: changeView == false
//                     ? HexColor("#F9FAFB")
//                     : HexColor("#454F5B"),
//               ),
//             ),
//           ),
//           /*
//           FlatButton(
//             onPressed: () {
//               setState(() {
//                 changeView = true;
//               });
//             },
//             color:
//                 changeView == true ? HexColor("#454F5B") : HexColor("#F4F6F8"),
//             child: Text(
//               "Asociar Monedero",
//               style: TextStyle(
//                 fontFamily: "Rubik",
//                 fontSize: 14,
//                 fontWeight: FontWeight.normal,
//                 color: changeView == true
//                     ? HexColor("#F9FAFB")
//                     : HexColor("#454F5B"),
//               ),
//             ),
//           )
//           */
//         ],
//       ),
//     );
//   }

//   addCard() {
//     return Container(
//       padding: EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 15),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         mainAxisSize: MainAxisSize.max,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Text(
//             "Ingresa los datos de tu tarjeta de crédito o débito para poder agregarla a tu cuenta.",
//             textAlign: TextAlign.left,
//             style: TextStyle(
//               fontFamily: "Rubik",
//               color: HexColor("#454F5B"),
//               fontSize: 14,
//               fontWeight: FontWeight.normal,
//             ),
//           ),
//           Container(
//             margin: EdgeInsets.symmetric(vertical: 15),
//             child: Text(
//               "* Campos requeridos",
//               style: TextStyle(
//                 fontFamily: "Rubik",
//                 color: HexColor("#919EAB"),
//                 fontSize: 10,
//                 fontWeight: FontWeight.normal,
//               ),
//             ),
//           ),
//           Container(
//             margin: EdgeInsets.only(top: 5),
//             child: Theme(
//               data: new ThemeData(
//                   primaryColor: DataUI.chedrauiBlueColor,
//                   hintColor: DataUI.textOpaque,
//                   disabledColor: DataUI.chedrauiBlueColor),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     Container(
//                       margin: EdgeInsets.only(bottom: 5),
//                       child: Text(
//                         "* Número de Tarjeta",
//                         style: TextStyle(
//                           fontFamily: "Rubik",
//                           color: HexColor("#454F5B"),
//                           fontSize: 12,
//                           fontWeight: FontWeight.normal,
//                         ),
//                       ),
//                     ),
//                     Container(
//                       margin: EdgeInsets.only(top: 5),
//                       decoration: new BoxDecoration(
//                         border: new Border.all(
//                           color: Colors.black.withOpacity(0.1),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.max,
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: <Widget>[
//                           Flexible(
//                             child: TextFormField(
//                               keyboardType: TextInputType.number,
//                               controller: numberController,
//                               inputFormatters: [
//                                 WhitelistingTextInputFormatter.digitsOnly,
//                                 new LengthLimitingTextInputFormatter(16),
//                                 new CardNumberInputFormatter(),
//                               ],
//                               decoration: InputDecoration(
//                                 contentPadding: EdgeInsets.all(15),
//                                 border: OutlineInputBorder(),
//                                 suffixIcon: IconButton(
//                                   icon: Icon(Icons.camera_alt),
//                                   onPressed: () {
//                                     _scanCard();
//                                   },
//                                 ),
//                                 fillColor: HexColor("#F4F6F8"),
//                                 filled: true,
//                                 prefixIcon: Padding(
//                                   padding: EdgeInsets.only(left: 5, right: 5),
//                                   child: UtilsPayment.CardUtils.getCardIcon(
//                                       _paymentCard.type),
//                                 ),
//                                 hintText: 'XXXX XXXX XXXX XXXX',
//                                 hintStyle: TextStyle(
//                                   fontSize: 14.0,
//                                   color: HexColor("#454F5B"),
//                                 ),
//                               ),
//                               onSaved: (input) {
//                                 cardData.numTarjeta =
//                                     UtilsPayment.CardUtils.getCleanedNumber(
//                                         input);
//                               },
//                               onFieldSubmitted: (v) {
//                                 FocusScope.of(context).requestFocus(_name);
//                               },
//                               textInputAction: TextInputAction.next,
//                               validator: UtilsPayment.CardUtils.validateCardNum,
//                               autocorrect: true,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       margin: EdgeInsets.only(bottom: 5, top: 15),
//                       child: Text(
//                         "* Nombre del Tarjeta habiente",
//                         style: TextStyle(
//                           fontFamily: "Rubik",
//                           color: HexColor("#454F5B"),
//                           fontSize: 12,
//                           fontWeight: FontWeight.normal,
//                         ),
//                       ),
//                     ),
//                     TextFormField(
//                       inputFormatters: [
//                         new LengthLimitingTextInputFormatter(60),
//                         WhitelistingTextInputFormatter(
//                           RegExp("[a-zA-Z ]|[à-ú]|[À-Ú]"),
//                         ),
//                       ],
//                       focusNode: _name,
//                       decoration: InputDecoration(
//                         contentPadding: EdgeInsets.all(15),
//                         border: OutlineInputBorder(),
//                         fillColor: HexColor("#F4F6F8"),
//                         filled: true,
//                         hintText: 'Nombre Apellido',
//                         hintStyle: TextStyle(
//                           fontSize: 14.0,
//                           color: HexColor("#454F5B"),
//                         ),
//                       ),
//                       onSaved: (input) {
//                         cardData.nomTitularTarj = input;
//                       },
//                       onFieldSubmitted: (x) {
//                         FocusScope.of(context).requestFocus(_date);
//                       },
//                       textInputAction: TextInputAction.next,
//                       validator: (value) {
//                         if (value.isEmpty) {
//                           return 'Por favor rellene este campo';
//                         }
//                       },
//                     ),
//                     Container(
//                       margin: EdgeInsets.only(bottom: 5, top: 15),
//                       child: Text(
//                         "* Fecha de expiración",
//                         style: TextStyle(
//                           fontFamily: "Rubik",
//                           color: HexColor("#454F5B"),
//                           fontSize: 12,
//                           fontWeight: FontWeight.normal,
//                         ),
//                       ),
//                     ),
//                     TextFormField(
//                       focusNode: _date,
//                       keyboardType: TextInputType.datetime,
//                       inputFormatters: [
//                         WhitelistingTextInputFormatter.digitsOnly,
//                         new LengthLimitingTextInputFormatter(4),
//                         new CardMonthInputFormatter()
//                       ],
//                       decoration: InputDecoration(
//                         contentPadding: EdgeInsets.all(15),
//                         border: OutlineInputBorder(),
//                         fillColor: HexColor("#F4F6F8"),
//                         filled: true,
//                         hintText: 'MM/YY',
//                         hintStyle: TextStyle(
//                           fontSize: 14.0,
//                           color: HexColor("#454F5B"),
//                         ),
//                       ),
//                       onFieldSubmitted: (x) {
//                         FocusScope.of(context).requestFocus(_cvv);
//                       },
//                       textInputAction: TextInputAction.next,
//                       onSaved: (input) {
//                         cardData.fecExpira = input;
//                       },
//                       //validator:
//                       validator: UtilsPayment.CardUtils.validateDate,
//                       // /**(value) {
//                       //     if (value.isEmpty) {
//                       //     return 'Por favor rellene este campo';
//                       //     }
//                       //     },***/
//                     ),
//                     Container(
//                       margin: EdgeInsets.only(bottom: 5, top: 15),
//                       child: Text(
//                         "*CVV",
//                         style: TextStyle(
//                           fontFamily: "Rubik",
//                           color: HexColor("#454F5B"),
//                           fontSize: 12,
//                           fontWeight: FontWeight.normal,
//                         ),
//                       ),
//                     ),
//                     TextFormField(
//                       focusNode: _cvv,
//                       keyboardType: TextInputType.number,
//                       inputFormatters: [
//                         WhitelistingTextInputFormatter.digitsOnly,
//                         new LengthLimitingTextInputFormatter(4),
//                       ],
//                       decoration: InputDecoration(
//                         contentPadding: EdgeInsets.all(15),
//                         border: OutlineInputBorder(),
//                         fillColor: HexColor("#F4F6F8"),
//                         filled: true,
//                         hintText: 'CVV',
//                         hintStyle: TextStyle(
//                           fontSize: 14.0,
//                           color: HexColor("#454F5B"),
//                         ),
//                       ),
//                       onFieldSubmitted: (x) {
//                         FocusScope.of(context).requestFocus(_alias);
//                       },
//                       textInputAction: TextInputAction.next,
//                       onSaved: (input) {
//                         cardData.cvv = input;
//                       },
//                       validator: (value) {
//                         if (value.isEmpty) {
//                           return 'Por favor rellene este campo';
//                         }
//                       },
//                     ),
//                     Container(
//                       margin: EdgeInsets.only(bottom: 5, top: 15),
//                       child: Text(
//                         "*Alias de la tarjeta",
//                         style: TextStyle(
//                           fontFamily: "Rubik",
//                           color: HexColor("#454F5B"),
//                           fontSize: 12,
//                           fontWeight: FontWeight.normal,
//                         ),
//                       ),
//                     ),
//                     TextFormField(
//                       focusNode: _alias,
//                       inputFormatters: [
//                         new LengthLimitingTextInputFormatter(50),
//                         WhitelistingTextInputFormatter(
//                           RegExp("[a-zA-Z ]|[à-ú]|[À-Ú]"),
//                         ),
//                       ],
//                       decoration: InputDecoration(
//                         contentPadding: EdgeInsets.all(15),
//                         border: OutlineInputBorder(),
//                         fillColor: HexColor("#F4F6F8"),
//                         filled: true,
//                         hintText: '“Compras frecuentes”',
//                         hintStyle: TextStyle(
//                           fontSize: 14.0,
//                           color: HexColor("#454F5B"),
//                         ),
//                       ),
//                       onSaved: (input) {
//                         cardData.aliasTarjeta = input;
//                       },
//                       onFieldSubmitted: (x) {
//                         _alias.unfocus();
//                       },
//                       textInputAction: TextInputAction.done,
//                       validator: (value) {
//                         if (value.isEmpty) {
//                           return 'Por favor rellene este campo';
//                         }
//                       },
//                     ),
//                     TermCondWidget(),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 14, right: 14),
//                       child: loading == false
//                           ? SizedBox(
//                               width: double.infinity,
//                               child: RaisedButton(
//                                 color: DataUI.chedrauiColor,
//                                 onPressed: loading == false ? submitForm : null,
//                                 child: Text(
//                                   "Agregar Tarjeta Bancaria",
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               ),
//                             )
//                           : SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(),
//                             ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Center(
//             child: loading == false
//                 ? Container(
//                     margin: EdgeInsets.only(top: 15),
//                     child: InkWell(
//                       onTap: () {
//                         Navigator.pop(context);
//                       },
//                       child: Text(
//                         "Cancelar registro de tarjeta bancaria",
//                         style: TextStyle(
//                             color: HexColor("#0D47A1"),
//                             fontFamily: "Rubik",
//                             fontSize: 14),
//                       ),
//                     ),
//                   )
//                 : SizedBox(
//                     height: 20,
//                     width: 20,
//                   ),
//           )
//         ],
//       ),
//     );
//   }

//   _scanCard() async {
//     if (Platform.isAndroid) {
//       const platform = const MethodChannel('com.cheadrui.com/scanCard');
//       await platform.invokeMethod('scanCard').then((onValue) {
//         print('///////////////');
//         print(onValue);
//         print('///////////////');
//         setState(() {
//           card = onValue;
//           numberController = new TextEditingController(text: card);
//         });

//         _getCardTypeFrmNumber();
//       }).catchError((onError) {
//         print(onError);
//       });
//     } else if (Platform.isIOS) {
//       _scanCardIOS();
//     }
//   }

//   _scanCardIOS() async {
//     // Platform messages may fail, so we use a try/catch PlatformException.
//     FlutterCardIo.scanCard({
//       "requireExpiry": false,
//       "scanExpiry": false,
//       "requireCVV": false,
//       "requirePostalCode": false,
//       "restrictPostalCodeToNumericOnly": false,
//       "requireCardHolderName": false,
//       "usePayPalActionbarIcon": false,
//     }).then((onValue) {
//       print('///////////////');
//       print(onValue);
//       print('///////////////');
//       setState(() {
//         card = onValue['cardNumber'];
//         numberController = new TextEditingController(text: card);
//       });

//       _getCardTypeFrmNumber();
//     }).catchError((onError) {
//       print(onError);
//     });
//   }

//   addMonedero() {
//     return Container(
//       padding: EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 15),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         mainAxisSize: MainAxisSize.max,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Text(
//             "Ingresa el número de tu monedero y su contraseña para asociarlo a tu cuenta.",
//             textAlign: TextAlign.left,
//             style: TextStyle(
//               fontFamily: "Rubik",
//               color: HexColor("#454F5B"),
//               fontSize: 14,
//               fontWeight: FontWeight.normal,
//             ),
//           ),
//           Container(
//             margin: EdgeInsets.symmetric(vertical: 15),
//             child: Text(
//               "* Campos requeridos",
//               style: TextStyle(
//                 fontFamily: "Rubik",
//                 color: HexColor("#919EAB"),
//                 fontSize: 10,
//                 fontWeight: FontWeight.normal,
//               ),
//             ),
//           ),
//           Container(
//             margin: EdgeInsets.only(top: 5),
//             child: Theme(
//               data: new ThemeData(
//                   primaryColor: HexColor("#C4CDD5"), fontFamily: "Rubik"),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     Container(
//                       margin: EdgeInsets.only(bottom: 5),
//                       child: Text(
//                         "* Número de Monedero",
//                         style: TextStyle(
//                           fontFamily: "Rubik",
//                           color: HexColor("#454F5B"),
//                           fontSize: 12,
//                           fontWeight: FontWeight.normal,
//                         ),
//                       ),
//                     ),
//                     Container(
//                       margin: EdgeInsets.only(top: 5),
//                       decoration: new BoxDecoration(
//                         border: new Border.all(
//                           color: Colors.black.withOpacity(0.2),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.max,
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: <Widget>[
//                           Flexible(
//                             child: TextFormField(
//                               keyboardType: TextInputType.number,
//                               controller: txtBarcode,
//                               enabled: false,
//                               autofocus: true,
//                               focusNode: _number,
//                               inputFormatters: [
//                                 FormatCreditCard(
//                                   mask: 'xxxxxxxxxxxxxxxx',
//                                   separator: ' ',
//                                 ),
//                               ],
//                               decoration: InputDecoration(
//                                 contentPadding: EdgeInsets.all(15),
//                                 border: OutlineInputBorder(),
//                                 fillColor: HexColor("#F4F6F8"),
//                                 filled: true,
//                                 hintText: 'XXXXXXXXXXXXXXXX',
//                                 hintStyle: TextStyle(
//                                   fontSize: 14.0,
//                                   color: HexColor("#454F5B"),
//                                 ),
//                               ),
//                               onFieldSubmitted: (x) {
//                                 FocusScope.of(context).requestFocus(_password);
//                               },
//                               textInputAction: TextInputAction.next,
//                               validator: (value) {
//                                 if (value.isEmpty) {
//                                   return 'Por favor rellene este campo';
//                                 }
//                               },
//                             ),
//                           ),
//                           Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: <Widget>[
//                               IconButton(
//                                 icon: Icon(Icons.camera_alt),
//                                 onPressed: () {
//                                   scan();
//                                 },
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       margin: EdgeInsets.only(bottom: 5, top: 15),
//                       child: Text(
//                         "* Contraseña",
//                         style: TextStyle(
//                           fontFamily: "Rubik",
//                           color: HexColor("#454F5B"),
//                           fontSize: 12,
//                           fontWeight: FontWeight.normal,
//                         ),
//                       ),
//                     ),
//                     TextFormField(
//                       focusNode: _password,
//                       controller: txtContrasenia,
//                       obscureText:
//                           _obscureText, //This will obscure text dynamically
//                       decoration: InputDecoration(
//                         contentPadding: EdgeInsets.all(15),
//                         border: OutlineInputBorder(),
//                         fillColor: HexColor("#F4F6F8"),
//                         hintText: '••••••••',
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscureText
//                                 ? Icons.visibility
//                                 : Icons.visibility_off,
//                             color: Theme.of(context).primaryColorDark,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _obscureText = !_obscureText;
//                             });
//                           },
//                         ),
//                         hintStyle: TextStyle(
//                           fontSize: 14.0,
//                           color: HexColor("#454F5B"),
//                         ),
//                       ),
//                       onFieldSubmitted: (x) {
//                         _password.unfocus();
//                       },
//                       textInputAction: TextInputAction.done,
//                       validator: (value) {
//                         if (value.isEmpty) {
//                           return 'Por favor rellene este campo';
//                         }
//                       },
//                     ),
//                     TermCondWidget(),
//                     Padding(
//                       padding:
//                           const EdgeInsets.only(top: 15, left: 14, right: 14),
//                       child: loading == false
//                           ? SizedBox(
//                               width: double.infinity,
//                               child: RaisedButton(
//                                 color: DataUI.chedrauiColor,
//                                 onPressed: () {
//                                   if (_formKey.currentState.validate()) {
//                                     vincularMonedero(context);
//                                   }
//                                 },
//                                 child: Text(
//                                   "Asociar Monedero Mi Chedraui",
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               ),
//                             )
//                           : Container(
//                               margin: EdgeInsets.only(left: 15, right: 7.5),
//                               height: 233.0,
//                               child: Center(
//                                 child: CircularProgressIndicator(value: null),
//                               ),
//                             ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Center(
//             child: loading == false
//                 ? Container(
//                     margin: EdgeInsets.only(top: 15),
//                     child: InkWell(
//                       onTap: () {
//                         Navigator.pop(context);
//                       },
//                       child: Text(
//                         "Cancelar asociación de monedero",
//                         style: TextStyle(
//                             color: HexColor("#0D47A1"),
//                             fontFamily: "Rubik",
//                             fontSize: 14),
//                       ),
//                     ),
//                   )
//                 : null,
//           )
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scrollbar(
//       child: SingleChildScrollView(
//         child: Column(
//           children: <Widget>[
//             toggleButton(),
//             changeView == false ? addCard() : addMonedero()
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> scan() async {
//     try {
//       print("Entro scan");
//       String barcode = await BarcodeScanner.scan();
//       setState(() => //this.barcode = barcode;
//           this.txtBarcode.text = barcode);

//       if (txtBarcode.text.length > 12) {
//         txtBarcode.text = txtBarcode.text.substring(0, 12);
//       }

//       if (txtBarcode.text.startsWith("91")) {
//         txtBarcode.text = ("6670" + txtBarcode.text);
//       } else {
//         return showDialog<void>(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text('Vincular monedero'),
//               content: Text(
//                   "Este monedero ya no es válido, intenta con otro monedero."),
//               actions: <Widget>[
//                 FlatButton(
//                   child: Text('Ok'),
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       }
//     } on PlatformException catch (e) {
//       if (e.code == BarcodeScanner.CameraAccessDenied) {
//         setState(() {
//           this.barcode = 'The user did not grant the camera permission!';
//         });
//       } else {
//         setState(() => this.barcode = 'Unknown error: $e');
//       }
//     } on FormatException {
//       setState(() => this.barcode =
//           'null (User returned using the "back"-button before scanning anything. Result)');
//     } catch (e) {
//       setState(() => this.barcode = 'Unknown error: $e');
//     }
//   }

//   Future<void> vincularMonedero(BuildContext context) {
//     String wallet = widget.idWallet;
//     String monedero = this.txtBarcode.text;
//     String contrasenia = this.txtContrasenia.text;

//     print("wallet: $wallet");
//     print("monedero: $monedero");
//     print("contrasenia: $contrasenia");
//     if (_formKey.currentState.validate()) {
//       setState(() {
//         loading = true;
//       });
//     }

//     if (monedero.startsWith("6664")) {
//       return showDialog<void>(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Vincular monedero'),
//             content: Text(
//                 "Este monedero ya no es válido, intenta con otro monedero."),
//             actions: <Widget>[
//               FlatButton(
//                 child: Text('Ok'),
//                 onPressed: () {
//                       Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                         builder: (context) => MonederoPage(),
//                         ),
//                     );
//                   // Navigator.of(context).pushAndRemoveUntil(
//                   //   MaterialPageRoute(
//                   //     builder: (BuildContext context) => MasterPage(
//                   //       initialWidget: MenuItem(
//                   //         id: 'monedero',
//                   //         title: 'Monedero Mi Chedraui',
//                   //         screen: MonederoPage(),
//                   //         color: DataUI.chedrauiColor2,
//                   //         textColor: DataUI.primaryText,
//                   //       ),
//                   //     ),
//                   //   ),
//                   //   (Route<dynamic> route) => false,
//                   // );
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }

//     MonederoServices.vincularMonedero(
//             wallet, monedero.replaceAll(" ", ""), contrasenia)
//         .then((response) async {
//       loading = false;

//       print(response);

//       if (response != null) {
//         var statusOperation = response['statusOperation'];

//         print(statusOperation);

//         var description = statusOperation['description'];
//         var code = statusOperation['code'];

//         print(description);

//         setState(() => this.txtMensajeResponse.text = description);

//         if (code == 0) {
//           this.txtBarcode.text = "";
//           this.txtContrasenia.text = "";
//         }

//         return showDialog<void>(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text('Vincular monedero'),
//               content: Text(description),
//               actions: <Widget>[
//                 FlatButton(
//                   child: Text('Ok'),
//                   onPressed: () {
//                         Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                         builder: (context) => MonederoPage(),
//                         ),
//                     );
//                     // Navigator.of(context).pushAndRemoveUntil(
//                     //   MaterialPageRoute(
//                     //     builder: (BuildContext context) => MasterPage(
//                     //       initialWidget: MenuItem(
//                     //         id: 'monedero',
//                     //         title: 'Monedero Mi Chedraui',
//                     //         screen: MonederoPage(),
//                     //         color: DataUI.chedrauiColor2,
//                     //         textColor: DataUI.primaryText,
//                     //       ),
//                     //     ),
//                     //   ),
//                     //   (Route<dynamic> route) => false,
//                     // );
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       }
//     });
//   }
// }
