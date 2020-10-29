import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/MasterPage/MasterPage.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:flutter/services.dart';
import 'package:chd_app_demo/services/MonederoServices.dart';
import 'package:chd_app_demo/utils/CardUtils.dart';
import 'package:chd_app_demo/utils/input_formatters.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chd_app_demo/views/Monedero/CardData.dart';
import 'package:chd_app_demo/views/Monedero/MonederoPage.dart';
import 'package:flutter/gestures.dart';
import 'package:chd_app_demo/views/MasterPage/MenuScreen.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class EditCard extends StatefulWidget {
  final card;

  EditCard({Key key, this.card}) : super(key: key);
  @override
  _EditCardState createState() => _EditCardState();
}

class _EditCardState extends State<EditCard> {
  SharedPreferences prefs;
  String idWallet;
  CardData cardData = new CardData();
  final _formKey = GlobalKey<FormState>();
  dynamic jsonResponse;
  final FocusNode _alias = FocusNode();

  bool canModify = false;

  @override
  void initState() {
    super.initState();
    getPreferences().then((x) {
      setState(() {
        idWallet = prefs.getString('idWallet') == null ? '' : prefs.getString('idWallet');
      });
    });
    loadTermCond();
  }

  Future getPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  bool loading = false;

  Future<String> _loadTermCond() async {
    return await rootBundle.loadString('assets/thcd.json');
  }

  Future loadTermCond() async {
    String jsonString = await _loadTermCond();
    jsonResponse = json.decode(jsonString);
    jsonResponse = jsonResponse;
  }

  @override
  Widget build(BuildContext context) {
    _showResponseDialog(msg) {
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
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //     builder: (context) => MonederoPage(),
                    //     ),
                    // );
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
    }

    void submitForm() async {
      if (_formKey.currentState.validate()) {
        setState(() {
          loading = true;
          this.cardData.idWallet = idWallet;
        });
        _formKey.currentState.save();
        const platform = const MethodChannel('com.cheadrui.com/decypher');

        print('Printing the login data.');
        print('nomTitularTarj: ${widget.card["idWallet"]}');

        print('nomTitularTarj: ${widget.card["nomTitularTarj"]}');
        print('numTarjeta: ${widget.card["numTarjeta"]}');
        print('fecExpira: ${widget.card["fecExpira"]}');
        print('cvv: ${widget.card["cvv"]}');
        print('tipoTarjeta: ${widget.card["tipoTarjeta]"]}');
        print('aliasTarjeta: ${widget.card["aliasTarjeta"]}');
        print('identificador: ${widget.card["identificador"].toString()}');
        CardData cardToSave = new CardData();
        cardToSave.idWallet = await widget.card["idWallet"];
        cardToSave.numTarjeta = await widget.card['identificador'].toString();
        cardToSave.aliasTarjeta = await platform.invokeMethod('encrypter', {"text": cardData.aliasTarjeta});

        print('Printing the cardToSave login data.');
        print('idWallet: ${cardToSave.idWallet}');
        print('numTarjeta: ${cardToSave.numTarjeta}');
        print('aliasTarjeta: ${cardToSave.aliasTarjeta}');

        var result = await MonederoServices.editCard(cardToSave);

        if (result != null) {
          print(result.toString());
          print("resultado--->" + result["statusOperation"]["code"].toString());

          num code = int.parse(result["statusOperation"]["code"].toString());
          switch (code) {
            case 0:
              _showResponseDialog(result["statusOperation"]["description"]);
              setState(() {
                loading = false;
              });
              break;
            case 1:
              _showResponseDialog(result["statusOperation"]["description"]);
              setState(() {
                loading = false;
              });
              break;
            case 2:
              _showResponseDialog(result["statusOperation"]["description"]);
              setState(() {
                loading = false;
              });
              break;
            default:
              break;
          }
        }
      }
    }

    submitDeleteForm() async {
      if (_formKey.currentState.validate()) {
        setState(() {
          loading = true;
          this.cardData.idWallet = idWallet;
        });
        _formKey.currentState.save();

        CardData cardToDelete = new CardData();
        cardToDelete.idWallet = await widget.card["idWallet"];
        cardToDelete.numTarjeta = await widget.card['identificador'].toString();

        var result = await MonederoServices.deleteCard(cardToDelete);

        if (result != null) {
          num code = int.parse(result["statusOperation"]["code"].toString());
          switch (code) {
            case 0:
              _showResponseDialog(result["statusOperation"]["description"]);
              setState(() {
                loading = false;
              });
              break;
            case 1:
              _showResponseDialog(result["statusOperation"]["description"]);
              setState(() {
                loading = false;
              });
              break;
            case 2:
              _showResponseDialog(result["statusOperation"]["description"]);
              setState(() {
                loading = false;
              });
              break;
            default:
              break;
          }
        }
      }
    }

    return WidgetContainer(
      Scaffold(
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
          elevation: 1,
          title: Text("Editar Tarjeta", style: TextStyle(color: Colors.white, fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 19)),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context, 'reload'),
              );
            },
          ),
          centerTitle: true,
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Modificar alias de tarjeta.",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: "Rubik",
                      color: HexColor("#454F5B"),
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      "* Campos requeridos",
                      style: TextStyle(
                        fontFamily: "Rubik",
                        color: HexColor("#919EAB"),
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Theme(
                      data: new ThemeData(primaryColor: DataUI.chedrauiBlueColor, hintColor: DataUI.textOpaque, disabledColor: DataUI.chedrauiBlueColor),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(bottom: 5),
                              child: Text(
                                "* Número de Tarjeta",
                                style: TextStyle(
                                  fontFamily: "Rubik",
                                  color: HexColor("#454F5B"),
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              enabled: false,
                              initialValue: '**** **** **** ' + widget.card["numTarjeta"],
                              inputFormatters: [
                                WhitelistingTextInputFormatter.digitsOnly,
                                new LengthLimitingTextInputFormatter(16),
                                new CardNumberInputFormatter(),
                              ],
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(15),
                                border: OutlineInputBorder(),
                                fillColor: HexColor("#F4F6F8"),
                                filled: true,
                                prefixIcon: Icon(
                                  Icons.credit_card,
                                  color: HexColor("#454F5B"),
                                ),
                                hintText: 'XXXX XXXX XXXX XXXX',
                                hintStyle: TextStyle(
                                  fontSize: 14.0,
                                  color: HexColor("#454F5B"),
                                ),
                              ),
                              onSaved: (input) {
                                cardData.numTarjeta = input;
                              },
                              //validator: CardUtils.validateCardNum,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Por favor rellene este campo';
                                }
                              },
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 5, top: 15),
                              child: Text(
                                "* Nombre del Tarjetahabiente",
                                style: TextStyle(
                                  fontFamily: "Rubik",
                                  color: HexColor("#454F5B"),
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            TextFormField(
                              inputFormatters: [
                                new LengthLimitingTextInputFormatter(50),
                                WhitelistingTextInputFormatter(
                                  RegExp("[a-zA-Z ]|[à-ú]|[À-Ú]|[0-9]"),
                                ),
                              ],
                              enabled: false,
                              initialValue: widget.card["nomTitularTarj"],
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(15),
                                border: OutlineInputBorder(),
                                fillColor: HexColor("#F4F6F8"),
                                filled: true,
                                hintText: 'Nombre Apellido',
                                hintStyle: TextStyle(
                                  fontSize: 14.0,
                                  color: HexColor("#454F5B"),
                                ),
                              ),
                              onSaved: (input) {
                                cardData.nomTitularTarj = input;
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Por favor rellene este campo';
                                }
                              },
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 5, top: 15),
                              child: Text(
                                "* Fecha de expiración",
                                style: TextStyle(
                                  fontFamily: "Rubik",
                                  color: HexColor("#454F5B"),
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            TextFormField(
                              keyboardType: TextInputType.datetime,
                              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly, new LengthLimitingTextInputFormatter(4), new CardMonthInputFormatter()],
                              enabled: false,
                              initialValue: widget.card["fecExpira"],
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(15),
                                border: OutlineInputBorder(),
                                fillColor: HexColor("#F4F6F8"),
                                filled: true,
                                hintText: 'MM/YY',
                                hintStyle: TextStyle(
                                  fontSize: 14.0,
                                  color: HexColor("#454F5B"),
                                ),
                              ),
                              onSaved: (input) {
                                cardData.fecExpira = input;
                              },
                              //validator:
                              //validator: CardUtils.validateDate,
                            ),
                            /*
                          Container(
                            margin: EdgeInsets.only(bottom: 5, top: 15),
                            child: Text(
                              "*CVV",
                              style: TextStyle(
                                fontFamily: "Rubik",
                                color: HexColor("#454F5B"),
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              WhitelistingTextInputFormatter.digitsOnly,
                              new LengthLimitingTextInputFormatter(4),
                            ],
                            enabled: false,
                            initialValue: widget.card["cvv"],
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(15),
                              border: OutlineInputBorder(),
                              fillColor: HexColor("#F4F6F8"),
                              filled: true,
                              hintText: 'CVV',
                              hintStyle: TextStyle(
                                fontSize: 14.0,
                                color: HexColor("#454F5B"),
                              ),
                            ),
                            onSaved: (input) {
                              cardData.cvv = input;
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Por favor rellene este campo';
                              }
                            },
                          ),******/
                            Container(
                              margin: EdgeInsets.only(bottom: 5, top: 15),
                              child: Text(
                                "*Alias de la tarjeta",
                                style: TextStyle(
                                  fontFamily: "Rubik",
                                  color: HexColor("#454F5B"),
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            TextFormField(
                              inputFormatters: [
                                new LengthLimitingTextInputFormatter(50),
                                WhitelistingTextInputFormatter(
                                  RegExp("[a-zA-Z ]|[à-ú]|[À-Ú]"),
                                ),
                              ],
                              autofocus: true,
                              focusNode: _alias,
                              initialValue: widget.card["aliasTarjeta"],
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(15),
                                border: OutlineInputBorder(),
                                fillColor: HexColor("#F4F6F8"),
                                filled: true,
                                hintStyle: TextStyle(
                                  fontSize: 14.0,
                                  color: HexColor("#454F5B"),
                                ),
                              ),
                              onChanged: (input) {
                                setState(() {
                                  canModify = input.trim().length > 0 && input != widget.card["aliasTarjeta"];
                                });
                              },
                              onSaved: (input) {
                                cardData.aliasTarjeta = input;
                              },
                              onFieldSubmitted: (x) {
                                _alias.unfocus();
                              },
                              textInputAction: TextInputAction.done,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Por favor rellene este campo';
                                }
                              },
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 30, bottom: 15),
                              child: RichText(
                                text: TextSpan(
                                  text: 'Al modificar mi tarjeta de crédito o débito, acepto los ',
                                  style: TextStyle(
                                    fontFamily: "Rubik",
                                    fontSize: 12,
                                    color: HexColor("#637381"),
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      recognizer: new TapGestureRecognizer()
                                        ..onTap = () => {
                                              if (jsonResponse['terminoschd'] == null)
                                                {
                                                  jsonResponse = loadTermCond(),
                                                },
                                              if (jsonResponse['terminoschd'] != null)
                                                {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        content: SingleChildScrollView(
                                                          physics: ClampingScrollPhysics(),
                                                          child: Html(
                                                            data: jsonResponse['terminoschd'],
                                                          ),
                                                        ),
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
                                                  ),
                                                }
                                            },
                                      text: 'Términos y condiciones ',
                                      style: TextStyle(fontFamily: "Rubik", fontSize: 12, fontWeight: FontWeight.normal, color: HexColor("#0D47A1")),
                                    ),
                                    TextSpan(text: "del servicio que ofrece esta aplicación. ")
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 14, right: 14),
                              child: loading == false
                                  ? SizedBox(
                                      width: double.infinity,
                                      child: RaisedButton(
                                        color: DataUI.chedrauiColor,
                                        disabledColor: DataUI.chedrauiColor.withOpacity(0.5),
                                        onPressed: canModify ? (loading == false ? submitForm : null) : null,
                                        child: Text(
                                          "Modificar Tarjeta",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 14, right: 14),
                              child: loading == false
                                  ? SizedBox(
                                      width: double.infinity,
                                      child: RaisedButton(
                                        color: DataUI.chedrauiColor,
                                        onPressed: loading == false ? submitDeleteForm : null,
                                        child: Text(
                                          "Eliminar Tarjeta",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox(
                                      height: 20,
                                      width: 20,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
