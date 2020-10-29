import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/utils/NetworkData.dart';
import 'package:chd_app_demo/utils/input_formatters.dart';
import 'package:chd_app_demo/views/Facturacion/FacturacionDTO.dart';
import 'package:chd_app_demo/views/Facturacion/FacturacionForm.dart';
import 'package:chd_app_demo/views/Facturacion/FacturacionFormatter.dart';
import 'package:chd_app_demo/views/Facturacion/FacturacionValidation.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:chd_app_demo/services/TimberService.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';

class FacturacionPage extends StatefulWidget {
  FacturacionPage({Key key}) : super(key: key);

  _FacturacionPageState createState() => _FacturacionPageState();
}

class _FacturacionPageState extends State<FacturacionPage> {
  final _formKey = GlobalKey<FormState>();
  final _urlFacturacion = NetworkData.urlFacturacion;
  final _urlFacturacionRegistrar = NetworkData.urlFacturacionRegistrar;
  final _focusRfc = FocusNode();
  final _focusTicket = FocusNode();
  final _focusEmail = FocusNode();
  final _focusRazon = FocusNode();
  final _focusCalle = FocusNode();
  final _focusNoExterior = FocusNode();
  final _focusNoInterior = FocusNode();
  final _focusColonia = FocusNode();
  final _focusLocalidad = FocusNode();
  final _focusDelMunicipio = FocusNode();
  final _focusCp = FocusNode();
  final _focusEstado = FocusNode();
  final _focusPais = FocusNode();
  TextEditingController _sucursalController = TextEditingController();
  TextEditingController _rfcController = TextEditingController();
  TextEditingController _ticketController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _razonController = TextEditingController();
  TextEditingController _calleController = TextEditingController();
  TextEditingController _exteriorController = TextEditingController();
  TextEditingController _interiorController = TextEditingController();
  TextEditingController _coloniaController = TextEditingController();
  TextEditingController _localidadController = TextEditingController();
  TextEditingController _delMunicipioController = TextEditingController();
  TextEditingController _cpController = TextEditingController();
  TextEditingController _estadoController = TextEditingController();
  TextEditingController _paisController = TextEditingController();
  FacturacionDTO _facturacion = FacturacionDTO();
  bool _iepsChk = false;
  bool _isLoading = false;
  int _widget = 0;
  var _facturacionResponse;
  String _facturacionError;
  String _ticket;
  Function _enableInvoicing;
  Function _enableRegister;

  void _valueChanged(bool value) => setState(() => _iepsChk = value);

  void _validateForm() {
    if (_sucursalController.text != '' && _rfcController.text != '' && _ticketController.text != '' && _emailController.text != '' && _razonController.text != '' && _calleController.text != '' && _exteriorController.text != '' && _coloniaController.text != '' && _localidadController.text != '' && _delMunicipioController.text != '' && _cpController.text != '' && _estadoController.text != '' && _paisController.text != '') {
      setState(() {
        _enableRegister = _submitRegistro;
      });
    } else if (_sucursalController.text != '' && _rfcController.text != '' && _ticketController.text != '' && _emailController.text != '') {
      setState(() {
        _enableInvoicing = _submitFacturacion;
      });
    } else {
      _enableInvoicing = null;
      _enableRegister = null;
    }
  }

  void _validateRegister() {}

  Future<void> _submitFacturacion() async {
    var headers = {
      "Content-Type": "application/json",
    };
    if (_facturacion.ieps == null) {
      _facturacion.ieps = 'off';
    }
    if (_formKey.currentState.validate() && mounted) {
      setState(() {
        _isLoading = true;
      });
      _formKey.currentState.save();

      /*
      print('°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°');
      print('Printing invoicing data');
      print('rfc: ${_facturacion.rfc}');
      print('homoclave: ${_facturacion.homoclave}');
      print('ticket: ${_facturacion.numTicket}');
      print('email: ${_facturacion.correo}');
      print('ieps: ${_facturacion.ieps}');
      print('°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°');
      print(utf8.encode(json.encode(_facturacion.toMap())));
      print(_facturacion.toMap().toString());
      */

      try {
        _facturacionResponse = await http.post(_urlFacturacion, headers: headers, body: utf8.encode(json.encode(_facturacion.toMap()))).then((http.Response response) async {
          final int statusCode = response.statusCode;
          if (statusCode < 200 || statusCode > 400 || json == null) {
            await TimberServices.sendLog('POST $_urlFacturacion headers: ${headers.toString()} body: ${_facturacion.toString()} : ${response.statusCode.toString()} ${response.headers.toString()} ${response.body}');
            throw new Exception("Error while fetching data");
          }
          return json.decode(response.body);
        });

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (_facturacionResponse['statusOperation']['code'] == 0) {
            setState(() {
              _widget = 1;
            });
          } else {
            //print(_facturacionResponse['statusOperation']['description']);
            setState(
              () {
                switch (_facturacionResponse['statusOperation']['description']) {
                  case 'RFC no existe':
                    _widget = 2;
                    _facturacionError = '¡El RFC que ingresaste no existe en nuestros registros!';
                    break;
                  case 'El Ticket no existe.':
                    _widget = 4;
                    _facturacionError = '¡El ticket que intentas facturar no existe o no es válido!';
                    break;
                  case 'El número ticket no existe':
                    _widget = 4;
                    _facturacionError = '¡El ticket que intentas facturar no existe o no es válido!';
                    break;
                  default:
                    _widget = 4;
                    _facturacionError = _facturacionResponse['statusOperation']['description'];
                    break;
                }
              },
            );
          }
        }
      } catch (e) {
        _facturacionError = 'Error de conexión favor de intentar mas tarde';
        _isLoading = false;
        print(e.message);
      }
    }
  }

  Future<void> _submitRegistro() async {
    var headers = {
      "Content-Type": "application/json",
    };

    if (_formKey.currentState.validate() && mounted) {
      setState(() {
        _isLoading = true;
      });
      _formKey.currentState.save();

      /*
      print('°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°');
      print('Printing invoicing data');
      print('rfc: ${_facturacion.rfc}');
      print('homoclave: ${_facturacion.homoclave}');
      print('ticket: ${_facturacion.numTicket}');
      print('email: ${_facturacion.correo}');
      print('ieps: ${_facturacion.ieps}');
      print('razonSocial: ${_facturacion.razonSocial}');
      print('calle: ${_facturacion.calle}');
      print('noExterior: ${_facturacion.noExterior}');
      print('noInterior: ${_facturacion.noInterior}');
      print('colonia: ${_facturacion.colonia}');
      print('localidad: ${_facturacion.localidad}');
      print('delMunicipio: ${_facturacion.delMunicipio}');
      print('codigoPostal: ${_facturacion.codigoPostal}');
      print('estado: ${_facturacion.estado}');
      print('pais: ${_facturacion.pais}');
      print('°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°');
      print(utf8.encode(json.encode(_facturacion.toMap())));
      print(_facturacion.toMap().toString());
      */

      try {
        _facturacionResponse = await http.post(_urlFacturacionRegistrar, headers: headers, body: utf8.encode(json.encode(_facturacion.toMap()))).then((http.Response response) async {
          final int statusCode = response.statusCode;
          if (statusCode < 200 || statusCode > 400 || json == null) {
            await TimberServices.sendLog('POST $_urlFacturacionRegistrar headers: ${headers.toString()} body: ${_facturacion.toString()} : ${response.statusCode.toString()} ${response.headers.toString()} ${response.body}');
            throw new Exception("Error while fetching data");
          }
          return json.decode(response.body);
        });

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (_facturacionResponse['statusOperation']['code'] == 0) {
            setState(() {
              _widget = 1;
            });
          } else {
            //print(_facturacionResponse['statusOperation']['description']);
            setState(
              () {
                switch (_facturacionResponse['statusOperation']['description']) {
                  case 'El Ticket no existe.':
                    _widget = 5;
                    _facturacionError = '¡El ticket que intentas facturar no existe o no es válido!';
                    break;
                  case 'El número ticket no existe':
                    _widget = 5;
                    _facturacionError = '¡El ticket que intentas facturar no existe o no es válido!';
                    break;
                  default:
                    _widget = 5;
                    _facturacionError = _facturacionResponse['statusOperation']['description'];
                    break;
                }
              },
            );
          }
        }
      } catch (e) {
        _facturacionError = 'Error de conexión favor de intentar mas tarde';
        _isLoading = false;
        print(e.message);
      }
    }
  }

  Widget facturacionError(String error, String btnText, int widget) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(bottom: 30.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Icon(
                    Icons.error_outline,
                    color: DataUI.chedrauiColor,
                    size: 45,
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: Text(
                    '''$error''',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  flex: 6,
                  child: RaisedButton(
                    color: DataUI.chedrauiColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(14),
                      child: Text(
                        '$btnText',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _widget = widget;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: FlatButton(
              textColor: DataUI.chedrauiBlueColor,
              child: Text(
                'Cancelar',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> scan() async {
    if (mounted) {
      try {
        String barcode = await BarcodeScanner.scan();
        setState(() => this._ticketController.text = barcode);
      } on PlatformException catch (e) {
        if (e.code == BarcodeScanner.CameraAccessDenied) {
          setState(() {
            this._ticket = 'The user did not grant camera permission!';
          });
        } else {
          setState(() => this._ticket = 'Unknown error: $e');
        }
      } on FormatException {
        setState(() => this._ticket = 'null (User returned using the "back"-button before scanning anything. Result)');
      } catch (e) {
        setState(() => this._ticket = 'Unknown error: $e');
      }
    }
  }

  Widget facturacionForm() {
    return Column(
      children: <Widget>[
        /*Row(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              child: Text(
                '* Campos requeridos',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),*/
        Form(
          key: _formKey,
          onChanged: () => _validateForm(),
          child: Theme(
            data: ThemeData(
              primaryColor: Colors.black,
              hintColor: HexColor('#C4CDD5'),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(bottom: 5.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        '* Número de Sucursal',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    controller: _sucursalController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: const EdgeInsets.all(10.0),
                      hintText: 'XXXX',
                      hintStyle: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                    validator: validateSucursal,
                    onSaved: (input) => _facturacion.sucursal = input,
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).requestFocus(_focusRfc);
                    },
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      WhitelistingTextInputFormatter(
                        RegExp("[0-9]"),
                      ),
                      LengthLimitingTextInputFormatter(4),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 5.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'RFC',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    controller: _rfcController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: const EdgeInsets.all(10.0),
                      hintText: 'XAXX010101000',
                      hintStyle: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                    validator: validateRfc,
                    onSaved: (input) {
                      _facturacion.rfc = input.substring(0, 10);
                      _facturacion.homoclave = input.substring(10, 13);
                    },
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).requestFocus(_focusTicket);
                    },
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(13),
                      UpperCaseTextFormatter(),
                      WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9]")),
                    ],
                    focusNode: _focusRfc,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 5.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Número de Ticket (Fólio)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    keyboardType: TextInputType.phone,
                    controller: _ticketController,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: () => scan(),
                      ),
                      contentPadding: const EdgeInsets.all(10.0),
                      border: OutlineInputBorder(),
                      hintText: 'XXXX XXXX XXXX XXXX XXX',
                      hintStyle: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                    validator: validateTicket,
                    onSaved: (input) => _facturacion.numTicket = input,
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).requestFocus(_focusEmail);
                    },
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      WhitelistingTextInputFormatter(
                        RegExp("[0-9]"),
                      ),
                      LengthLimitingTextInputFormatter(19),
                    ],
                    focusNode: _focusTicket,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 5.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Correo Electrónico',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: const EdgeInsets.all(10.0),
                      hintText: 'nombre@dominio.com',
                      hintStyle: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                    validator: FormsTextValidators.validateEmail,
                    onSaved: (input) => _facturacion.correo = input,
                    textInputAction: TextInputAction.done,
                    focusNode: _focusEmail,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 7.0),
                  child: Row(
                    children: <Widget>[
                      Checkbox(
                        value: _iepsChk,
                        onChanged: (bool value) {
                          setState(() {
                            _iepsChk = !_iepsChk;
                            _iepsChk ? _facturacion.ieps = "on" : _facturacion.ieps = "off";
                          });
                        },
                      ),
                      Text(
                        'Facturar con IEPS',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                Container(
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
                            margin: const EdgeInsets.all(14),
                            child: Text(
                              'Solicitar Factura',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          onPressed: _enableInvoicing,
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
    );
  }

  Widget facturacionRegistro() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              child: Text(
                '* Campos requeridos',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
        Form(
          key: _formKey,
          onChanged: () => _validateForm(),
          child: Theme(
            data: ThemeData(
              primaryColor: Colors.black,
              hintColor: HexColor('#C4CDD5'),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(bottom: 5.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        '* Número de Sucursal',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    controller: _sucursalController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: const EdgeInsets.all(10.0),
                      hintText: 'XXXX',
                      hintStyle: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                    validator: validateSucursal,
                    onSaved: (input) => _facturacion.sucursal = input,
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).requestFocus(_focusRfc);
                    },
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      WhitelistingTextInputFormatter(
                        RegExp("[0-9]"),
                      ),
                      LengthLimitingTextInputFormatter(4),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 5.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'RFC',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    controller: _rfcController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: const EdgeInsets.all(10.0),
                      hintText: 'XAXX010101000',
                      hintStyle: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                    validator: validateRfc,
                    onSaved: (input) {
                      _facturacion.rfc = input.substring(0, 10);
                      _facturacion.homoclave = input.substring(10, 13);
                    },
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).requestFocus(_focusTicket);
                    },
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(13),
                      UpperCaseTextFormatter(),
                      WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9]")),
                    ],
                    focusNode: _focusRfc,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 5.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Número de Ticket (Fólio)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    keyboardType: TextInputType.phone,
                    controller: _ticketController,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: () => scan(),
                      ),
                      contentPadding: const EdgeInsets.all(10.0),
                      border: OutlineInputBorder(),
                      hintText: 'XXXX XXXX XXXX XXXX XXX',
                      hintStyle: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                    validator: validateTicket,
                    onSaved: (input) => _facturacion.numTicket = input,
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).requestFocus(_focusRazon);
                    },
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      WhitelistingTextInputFormatter(
                        RegExp("[0-9]"),
                      ),
                      LengthLimitingTextInputFormatter(19),
                    ],
                    focusNode: _focusTicket,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 5.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Razón Social',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _razonController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10.0),
                      border: OutlineInputBorder(),
                      hintText: 'Organización S.A. de C.V.',
                      hintStyle: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                    validator: FormsTextValidators.validateTextWithoutEmoji,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(100),
                      WhitelistingTextInputFormatter(
                        FormsTextValidators.commonPersonName,
                      ),
                    ],
                    onSaved: (input) => _facturacion.razonSocial = input.toUpperCase(),
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).requestFocus(_focusCalle);
                    },
                    textInputAction: TextInputAction.next,
                    focusNode: _focusRazon,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 5.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Dirección',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _calleController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10.0),
                      border: OutlineInputBorder(),
                      hintText: 'Escribe tu dirección',
                      hintStyle: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                    validator: FormsTextValidators.validateDeliveryAddress,
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(120),
                      WhitelistingTextInputFormatter(
                        FormsTextValidators.commonPersonName,
                      ),
                    ],
                    onSaved: (input) => _facturacion.calle = input,
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).requestFocus(_focusNoExterior);
                    },
                    textInputAction: TextInputAction.next,
                    focusNode: _focusCalle,
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(bottom: 5.0),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  'Número Exterior',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            child: TextFormField(
                              keyboardType: TextInputType.phone,
                              controller: _exteriorController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10.0),
                                border: OutlineInputBorder(),
                                hintText: 'Número',
                                hintStyle: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                              ),
                              validator: validateText,
                              onSaved: (input) => _facturacion.noExterior = input,
                              onFieldSubmitted: (v) {
                                FocusScope.of(context).requestFocus(_focusNoInterior);
                              },
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                WhitelistingTextInputFormatter(
                                  RegExp("[0-9]"),
                                ),
                              ],
                              focusNode: _focusNoExterior,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 15.0),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(bottom: 5.0),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  'Número Interior',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            child: TextFormField(
                              keyboardType: TextInputType.phone,
                              controller: _interiorController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10.0),
                                border: OutlineInputBorder(),
                                hintText: 'Número',
                                hintStyle: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                              ),
                              //validator: validateText,
                              onSaved: (input) => _facturacion.noInterior = input,
                              onFieldSubmitted: (v) {
                                FocusScope.of(context).requestFocus(_focusColonia);
                              },
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                WhitelistingTextInputFormatter(
                                  RegExp("[0-9]"),
                                ),
                              ],
                              focusNode: _focusNoInterior,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 5.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Colonia',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _coloniaController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10.0),
                      border: OutlineInputBorder(),
                      hintText: 'Colonia',
                      hintStyle: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                    validator: FormsTextValidators.validateDeliveryAddress,
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(40),
                      WhitelistingTextInputFormatter(
                        FormsTextValidators.commonPersonName,
                      ),
                    ],
                    onSaved: (input) => _facturacion.colonia = input,
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).requestFocus(_focusDelMunicipio);
                    },
                    textInputAction: TextInputAction.next,
                    focusNode: _focusColonia,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 5.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Delegación o Municipio',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _delMunicipioController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10.0),
                      border: OutlineInputBorder(),
                      hintText: 'Delegación o Municipio',
                      hintStyle: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                    validator: FormsTextValidators.validateDeliveryAddress,
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(40),
                      WhitelistingTextInputFormatter(
                        FormsTextValidators.commonPersonName,
                      ),
                    ],
                    onSaved: (input) => _facturacion.delMunicipio = input,
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).requestFocus(_focusLocalidad);
                    },
                    textInputAction: TextInputAction.next,
                    focusNode: _focusDelMunicipio,
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(bottom: 5.0),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  'Ciudad',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: _localidadController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10.0),
                                border: OutlineInputBorder(),
                                hintText: 'Ciudad',
                                hintStyle: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                              ),
                              validator: FormsTextValidators.validateDeliveryAddress,
                              inputFormatters: <TextInputFormatter>[
                                LengthLimitingTextInputFormatter(40),
                                WhitelistingTextInputFormatter(
                                  FormsTextValidators.commonPersonName,
                                ),
                              ],
                              onSaved: (input) => _facturacion.localidad = input,
                              onFieldSubmitted: (v) {
                                FocusScope.of(context).requestFocus(_focusCp);
                              },
                              textInputAction: TextInputAction.next,
                              focusNode: _focusLocalidad,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 15.0),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(bottom: 5.0),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  'Código Postal',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            child: TextFormField(
                              keyboardType: TextInputType.phone,
                              controller: _cpController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10.0),
                                border: OutlineInputBorder(),
                                hintText: 'XXXXX',
                                hintStyle: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                              ),
                              validator: validateText,
                              onSaved: (input) => _facturacion.codigoPostal = input,
                              onFieldSubmitted: (v) {
                                FocusScope.of(context).requestFocus(_focusEstado);
                              },
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                WhitelistingTextInputFormatter(
                                  RegExp("[0-9]"),
                                ),
                                LengthLimitingTextInputFormatter(5),
                              ],
                              focusNode: _focusCp,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(bottom: 5.0),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  'Estado',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: _estadoController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10.0),
                                border: OutlineInputBorder(),
                                hintText: 'Estado',
                                hintStyle: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                              ),
                              validator: FormsTextValidators.validateDeliveryAddress,
                              inputFormatters: <TextInputFormatter>[
                                LengthLimitingTextInputFormatter(40),
                                WhitelistingTextInputFormatter(
                                  FormsTextValidators.commonPersonName,
                                ),
                              ],
                              onSaved: (input) => _facturacion.estado = input,
                              onFieldSubmitted: (v) {
                                FocusScope.of(context).requestFocus(_focusPais);
                              },
                              textInputAction: TextInputAction.next,
                              focusNode: _focusEstado,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 15.0),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(bottom: 5.0),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  'País',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: _paisController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10.0),
                                border: OutlineInputBorder(),
                                hintText: 'País',
                                hintStyle: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                              ),
                              validator: FormsTextValidators.validateDeliveryAddress,
                              inputFormatters: <TextInputFormatter>[
                                LengthLimitingTextInputFormatter(40),
                                WhitelistingTextInputFormatter(
                                  FormsTextValidators.commonPersonName,
                                ),
                              ],
                              onSaved: (input) => _facturacion.pais = input,
                              textInputAction: TextInputAction.done,
                              /*inputFormatters: [
                                WhitelistingTextInputFormatter(
                                  RegExp("[a-zA-Z]"),
                                ),
                              ],*/
                              focusNode: _focusPais,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 5.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Correo Electrónico',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: const EdgeInsets.all(10.0),
                      hintText: 'nombre@dominio.com',
                      hintStyle: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                    validator: FormsTextValidators.validateEmail,
                    onSaved: (input) => _facturacion.correo = input,
                    textInputAction: TextInputAction.done,
                    focusNode: _focusEmail,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 7.0),
                  child: Row(
                    children: <Widget>[
                      Checkbox(
                        value: _iepsChk,
                        onChanged: (bool value) {
                          setState(() {
                            _iepsChk = !_iepsChk;
                            _iepsChk ? _facturacion.ieps = "on" : _facturacion.ieps = "off";
                          });
                        },
                      ),
                      Text(
                        'Facturar con IEPS',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                Container(
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
                            margin: const EdgeInsets.all(14),
                            child: Text(
                              'Solicitar Factura',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          onPressed: _enableRegister,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: FlatButton(
                    textColor: DataUI.chedrauiBlueColor,
                    child: Text(
                      'Cancelar registro',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
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
      ],
    );
  }

  Widget toggleWidget() {
    if (_isLoading) {
      return procesandoFactura();
    } else {
      switch (_widget) {
        case 3:
          {
            return facturacionForm();
          }
        case 1:
          {
            return facturacionExitosa(_facturacion.correo);
          }
        case 2:
          {
            return facturacionError(_facturacionError, 'Crear registro', 3);
          }
        case 0:
          {
            return facturacionRegistro();
          }
        case 4:
          {
            return facturacionError(_facturacionError, 'Verificar datos', 0);
          }
        case 5:
          {
            return facturacionError(_facturacionError, 'Verificar datos', 3);
          }
        default:
          return facturacionForm();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WidgetContainer(Scaffold(
      resizeToAvoidBottomPadding: true,
      backgroundColor: DataUI.backgroundColor,
      appBar: GradientAppBar(
        iconTheme: IconThemeData(
          color: DataUI.primaryText, //change your color here
        ),
        title: Text(
          'Facturación Electrónica',
          style: TextStyle(color: Colors.white, fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 19),
        ),
        centerTitle: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            HexColor('#F56D00'),
            HexColor('#F56D00'),
            HexColor('#F78E00'),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Theme(
            data: ThemeData(
              primaryColor: DataUI.textOpaqueMedium,
              hintColor: DataUI.opaqueBorder, // primaryColor: HexColor('#C4CDD5'),
            ),
            child: Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(
                    top: 15.0,
                    left: 42.0,
                    right: 42.0,
                    bottom: 30.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text('''Ingresa la siguiente información de tu ticket para obtener la factura de tu compra.''',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.justify)
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(left: 15, right: 15, bottom: 30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Color.fromRGBO(13, 19, 15, 0.15),
                              offset: Offset(0.0, 2.0),
                              blurRadius: 5.0,
                            ),
                          ],
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(15.0),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      'Información de Facturación',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  Container(
                                    height: 20.0,
                                    child: IconButton(
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
                                                'Recuerda, la factura solo podrá ser expedida durante el mismo mes de haber efectuado su compra y hasta 10 días después del siguiente mes.',
                                                softWrap: true,
                                                style: TextStyle(color: Colors.white, fontSize: 14.0),
                                                textAlign: TextAlign.justify,
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      iconSize: 12.0,
                                      alignment: Alignment.centerRight,
                                    ),
                                  ),
                                ],
                              ),
                              toggleWidget(),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 18.0, right: 18.0, bottom: 17.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 30.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
                                    child: Icon(
                                      Icons.lock_outline,
                                      size: 10.5,
                                      color: Color.fromRGBO(57, 62, 67, 0.5),
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      '''Navega seguro. Tu información se encripta con un SSL a 256 bits.''',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
    ));
  }
}
