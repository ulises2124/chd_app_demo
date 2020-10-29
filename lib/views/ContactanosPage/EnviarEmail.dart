import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

String selectedUrl = 'https://www.chedraui.com.mx/privacy';

class EnviarEmail extends StatelessWidget {
  const EnviarEmail({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#F4F6F8'),
      appBar: GradientAppBar(
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
          'Contáctanos',
          style: TextStyle(color: Colors.white, fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 19),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[BodyEmail()],
        ),
      ),
    );
  }
}

class BodyEmail extends StatefulWidget {
  BodyEmail({Key key}) : super(key: key);

  _BodyEmailState createState() => _BodyEmailState();
}

class _BodyEmailState extends State<BodyEmail> {
  String nombre;
  final _focusPaterno = FocusNode();
  final _focusTelefono = FocusNode();
  final _focusCorreo = FocusNode();
  final _focusMsj = FocusNode();
  final _formKey = GlobalKey<FormState>();
  String email;

  String telefono;

  String msj;

  sendData() {
    if (_formKey.currentState.validate()) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    'Contáctenos en línea',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    '*Campos requierdos',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: const EdgeInsets.only(
                          top: 12,
                          bottom: 12,
                          left: 6, //todo
                          right: 6 //todo
                          ),
                      hintText: '* Nombre',
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).requestFocus(_focusPaterno);
                    },
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      WhitelistingTextInputFormatter(
                        RegExp("[a-zA-Z ]|[à-ú]|[À-Ú]"),
                      ),
                    ],
                    onSaved: (input) {
                      nombre = input;
                    },
                    validator: _validateNotEmptyMinLength,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: const EdgeInsets.only(
                          top: 12,
                          bottom: 12,
                          left: 6, //todo
                          right: 6 //todo
                          ),
                      hintText: '* Correo Electrónico',
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                    onSaved: (input) {
                      email = input;
                    },
                    validator: _validateEmail,
                    textInputAction: TextInputAction.done,
                    focusNode: _focusCorreo,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: const EdgeInsets.only(
                          top: 12,
                          bottom: 12,
                          left: 6, //todo
                          right: 6 //todo
                          ),
                      hintText: 'Teléfono Móvil',
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    onSaved: (input) {
                      telefono = input;
                    },
                    validator: _validatePhoneLength,
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).requestFocus(_focusCorreo);
                    },
                    textInputAction: TextInputAction.next,
                    focusNode: _focusTelefono,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: const EdgeInsets.only(
                          top: 12,
                          bottom: 12,
                          left: 6, //todo
                          right: 6 //todo
                          ),
                      hintText: 'Mensaje',
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                    maxLines: 10,
                    keyboardType: TextInputType.multiline,
                    onSaved: (input) {
                      msj = input;
                    },
                    textInputAction: TextInputAction.next,
                    focusNode: _focusMsj,
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 40,
                  margin: EdgeInsets.symmetric(vertical: 7),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                    onPressed: () {
                      sendData();
                    },
                    color: HexColor('#F57C00'),
                    child: Text(
                      'Enviar mensaje',
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
            ),
          )
        ],
      ),
    );
  }

  String _validatePhoneLength(String value) {
    if (value.length > 10) {
      return 'El teléfono debe tener 10 dígitos';
    } else {
      return null;
    }
  }

  String _validateNotEmptyMinLength(String value) {
    if (value.isEmpty) {
      return 'Requerido';
    } else if (value.length < 3) {
      return 'Mínimo 3 caracteres';
    } else {
      return null;
    }
  }

  String _validateEmail(String value) {
    Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Correo no válido';
    else
      return null;
  }
}
