import 'package:chd_app_demo/services/CarritoServices.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/utils/input_formatters.dart';
import 'package:chd_app_demo/views/Checkout/TextInputsFormatters.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chd_app_demo/views/Checkout/PersonalInformationData.dart';
import 'package:chd_app_demo/views/DeliveryMethod/Estados.dart';
import 'package:chd_app_demo/widgets/customDropdown.dart' as dropdown;
import 'package:chd_app_demo/services/UserProfileServices.dart';
import 'package:chd_app_demo/views/Checkout/AddDeliveryNotes.dart';

class PersonalInfo extends StatefulWidget {
  final bool isLoggedIn;
  final bool isPickUp;
  final Function callback;
  final Function callbackNotas;
  PersonalInfo({
    Key key,
    this.isLoggedIn,
    this.isPickUp,
    this.callback,
    this.callbackNotas
  }) : super(key: key);

  _PersonalInfoState createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  List<Estados> estados = [];
  final _focusPaterno = FocusNode();
  final _focusMaterno = FocusNode();
  final _focusDireccion = FocusNode();
  final _focusNumeroInterior = FocusNode();
  final _focusColonia = FocusNode();
  final _focusEstado = FocusNode();
  final _focusCodigoPostal = FocusNode();
  final _focusApt = FocusNode();
  final _focusDatosEntrega = FocusNode();
  final _focusTelefono = FocusNode();
  final _focusCorreo = FocusNode();
  var infoEntrega;
  var dept;
  SharedPreferences prefs;
  final _mobileFormatter = NumberTextInputFormatter();
  final _formKey = [GlobalKey<FormState>(), GlobalKey<FormState>()];
  var token;
  var cart;
  List cartItems;
  List<String> cartItemsImages = [];
  bool _autoValidateFirstForm = false;
  bool sharedPrefs = false;
  bool editing = true;
  bool isLoggedIn = false;
  bool isPickUp = false;

  List<dropdown.DropdownMenuItem<String>> otrasDirecciones = [];
  List<dynamic> otrasDireccionesRaw = [];
  String _direccionId;

  void _showSnackBar(BuildContext context, String text) {
    Scaffold.of(context).showSnackBar(SnackBar(content: new Text(text)));
  }

  String _randomString() {
    int p1L = 6;
    int p2L = 6;
    int p3L = 3;
    var rand = new Random();
    var codeUnitsP1 = new List.generate(p1L, (index) {
      return rand.nextInt(25) + 65;
    });
    var codeUnitsP2 = new List.generate(p2L, (index) {
      return rand.nextInt(25) + 97;
    });
    var codeUnitsP3 = new List.generate(p3L, (index) {
      return rand.nextInt(9) + 48;
    });

    String p1 = new String.fromCharCodes(codeUnitsP1);
    String p2 = new String.fromCharCodes(codeUnitsP2);
    String p3 = new String.fromCharCodes(codeUnitsP3);
    return p1 + p2 + p3;
  }

  _showResponseDialog(String title, String msg) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
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

  PersonalInformationData personalData = new PersonalInformationData();
  var tiendaPickUpData = {};

  Future<void> submitFirstFormDelivery() async {
    if (_formKey[0].currentState.validate()) {
      _formKey[0].currentState.save();
      setState(() {
        editing = false;
      });

      prefs.setString('delivery-userName', personalData.nombre);
      prefs.setString('delivery-userLastName', personalData.paterno);
      prefs.setString('delivery-userSecondLastName', personalData.materno);
      prefs.setString('delivery-direccion', personalData.direccion);
      prefs.setString('delivery-numInterior', personalData.numInterior);
      prefs.setString('delivery-sublocality', personalData.colonia);
      prefs.setString('delivery-codigoPostal', personalData.cpostal);
      prefs.setString('delivery-estado', personalData.estado);
      prefs.setString('delivery-telefono', personalData.telefono);
      if (!isLoggedIn) prefs.setString('email', personalData.email);
      print('Printing the login data.');
      print('nombre: ${personalData.nombre}');
      print('paterno: ${personalData.paterno}');
      print('materno: ${personalData.materno}');
      print('direccion: ${personalData.direccion}');
      print('numInterior: ${personalData.numInterior}');
      print('colonia: ${personalData.colonia}');
      print('estado: ${personalData.estado}');
      print('cpostal: ${personalData.cpostal}');
      print('email: ${personalData.email}');
      print('telefono: ${personalData.telefono}');
      widget.callback(true, personalData);
    }
  }

  Future<void> submitFirstFormickUp() async {
    if (_formKey[1].currentState.validate()) {
      _formKey[1].currentState.save();
      setState(() {
        editing = false;
      });
      print('Printing the login data.');
      print('email: ${personalData.email}');
      widget.callback(true, personalData);
    }
  }

  _getStoredPersonalData() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs != null) {
      setState(() {
        sharedPrefs = true;
      });
      /*
      print(prefs.getString('delivery-userName'));
      print(prefs.getString('delivery-userSecondLastName'));
      print(prefs.getString('delivery-route'));
      print(prefs.getString('delivery-streetNumber'));
      print(prefs.getString('delivery-sublocality'));
      print(prefs.getString('delivery-estado'));
      print(prefs.getString('delivery-codigoPostal'));
      print(prefs.getString('delivery-telefono'));
      print(prefs.getString('store-id'));
      print(prefs.getString('store-displayName'));
      print(prefs.getString('store-formattedAddress'));
      print(prefs.getString('store-name'));
      print(prefs.getDouble('store-lat'));
      print(prefs.getDouble('store-lng'));
      */
      setState(() {
        isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
        isPickUp = prefs.getBool('isPickUp') ?? false;
        editing = true;
      });
      if (isLoggedIn) {
        var direcciones = await UserProfileServices.hybrisGetUserAddress();
        List<dropdown.DropdownMenuItem<String>> otrasDireccionesAux = [];
        for (var d in direcciones['addresses']) {
          otrasDireccionesAux.add(dropdown.DropdownMenuItem(child: Text(d['formattedAddress'], overflow: TextOverflow.ellipsis), value: d['id']));
        }
        setState(() {
          otrasDireccionesRaw = direcciones['addresses'];
          otrasDirecciones = otrasDireccionesAux;
          if (direcciones['addresses'].length > 0) {
            _direccionId = direcciones['addresses'][0]['id'];
          }
        });
      }
      setState(() {
        personalData.nombre = prefs.getString('delivery-userName');
        personalData.paterno = prefs.getString('delivery-userLastName');
        personalData.materno = prefs.getString('delivery-userSecondLastName');
        personalData.direccion = prefs.getString('delivery-direccion') ?? "${prefs.getString('delivery-route') ?? ""} ${prefs.getString('delivery-streetNumber') ?? ""}";
        personalData.numInterior = prefs.getString('delivery-numInterior');
        personalData.colonia = prefs.getString('delivery-sublocality');
        personalData.cpostal = prefs.getString('delivery-codigoPostal');
        personalData.estado = prefs.getString('delivery-estado');
        personalData.telefono = prefs.getString('delivery-telefono');
        personalData.email = prefs.getString('email');
        tiendaPickUpData = {"id": prefs.getString('store-id'), "displayName": prefs.getString('store-displayName'), "formattedAddress": prefs.getString('store-formattedAddress'), "name": prefs.getString('store-name'), "latitude": prefs.getDouble('store-lat'), "longitude": prefs.getDouble('store-lng')};
        print(tiendaPickUpData);
      });
    }
  }

  String _validateNotEmpty(String value) {
    if (value.isEmpty) {
      return 'Requerido';
    }
    return null;
  }

  String _validateEmail(String value) {
    String errorMessage = 'Correo no válido';
    Pattern pattern = r'^(([^<>()[\]\\.,+\{\};:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return errorMessage;
    } else {
      if (containsEmoji(value))
        return errorMessage;
      else
        return null;
    }
  }
  bool containsEmoji(String value) {
    RegExp regex = new RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');
    if (regex.hasMatch(value))
      return true;
    else
      return false;
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

  String _validateZipCode(String value) {
    Pattern pattern = r'[0-9]*';
    RegExp regex = new RegExp(pattern);
    if (value.isEmpty) {
      return 'Requerido';
    } else if (!regex.hasMatch(value) || value.length != 5) {
      return "No válido";
    } else {
      return null;
    }
  }

  String _validatePhoneLength(String value) {
    if (value.length != 10) {
      return 'El teléfono debe tener 10 dígitos';
    } else {
      return null;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _getStoredPersonalData();
    _initializeEstados();
    super.initState();
  }

  submitForm() async {
    if (isPickUp) {
      await submitFirstFormickUp();
    } else {
      await submitFirstFormDelivery();
    }
  }

  Widget editingDelivery() {
    return Column(children: <Widget>[
      Form(
        key: _formKey[0],
        autovalidate: false,
        child: Theme(
          data: ThemeData(
            primaryColor: Colors.transparent,
            hintColor: Colors.transparent, // p
          ),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 5),
                      child: Text(
                        'Nombre',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                      ),
                    ),
                    TextFormField(
                      style: TextStyle(
                        color: HexColor('#0D47A1'),
                        fontSize: 14,
                        fontFamily: 'Archivo'
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: HexColor('#F0EFF4'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                        hintStyle: TextStyle(color: HexColor('#0D47A1'), fontSize: 12),
                      ),
                      onFieldSubmitted: (v) {
                        FocusScope.of(context).requestFocus(_focusPaterno);
                      },
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        
                        WhitelistingTextInputFormatter(FormsTextFormatters.regexNames()),
                      ],
                      maxLength: 25,
                      initialValue: prefs.getString('delivery-userName') != null ? prefs.getString('delivery-userName') : '',
                      onSaved: (input) {
                        personalData.nombre = input;
                      },
                      validator: FormsTextValidators.validateTextWithoutEmoji,                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 5),
                      child: Text(
                        'Apellido Paterno',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                      ),
                    ),
                    TextFormField(
                      style: TextStyle(
                        color: HexColor('#0D47A1'),
                        fontSize: 14,
                        fontFamily: 'Archivo'
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: HexColor('#F0EFF4'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                        hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                      initialValue: prefs.getString('delivery-userLastName') != null ? prefs.getString('delivery-userLastName') : '',
                      inputFormatters: [
                        WhitelistingTextInputFormatter(FormsTextFormatters.regexNames()),
                      ],
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (v) {
                        FocusScope.of(context).requestFocus(_focusMaterno);
                      },
                      maxLength: 25,
                      onSaved: (input) {
                        personalData.paterno = input;
                      },
                      validator: FormsTextValidators.validateTextWithoutEmoji,
                      focusNode: _focusPaterno,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 5),
                      child: Text(
                        'Apellido Materno',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                      ),
                    ),
                    TextFormField(
                      style: TextStyle(
                        color: HexColor('#0D47A1'),
                        fontSize: 14,
                        fontFamily: 'Archivo'
                      ),
                      maxLength: 25,
                      decoration: InputDecoration(
                        filled: true,
                        //hintText: '(Opcional)',
                        //hintStyle: TextStyle(fontWeight: FontWeight.w300, color: HexColor('#212B36').withOpacity(0.5)),
                        fillColor: HexColor('#F0EFF4'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                        // hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                      initialValue: prefs.getString('delivery-userSecondLastName') != null ? prefs.getString('delivery-userSecondLastName') : '',
                      onSaved: (input) {
                        personalData.materno = input;
                      },
                      inputFormatters: [
                        WhitelistingTextInputFormatter(FormsTextFormatters.regexNames()),
                      ],
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (v) {
                        FocusScope.of(context).requestFocus(_focusDireccion);
                      },
                      focusNode: _focusMaterno,
                      validator: FormsTextValidators.validateTextWithoutEmoji,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 5),
                      child: Text(
                        'Dirección',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                      ),
                    ),
                    TextFormField(
                      style: TextStyle(
                        color: HexColor('#0D47A1'),
                        fontSize: 14,
                        fontFamily: 'Archivo'
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: HexColor('#F0EFF4'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                        hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                      initialValue: (prefs.getString('delivery-direccion') != null ? prefs.getString('delivery-direccion') : ''),
                      onSaved: (input) {
                        personalData.direccion = input;
                      },
                      inputFormatters: [
                        WhitelistingTextInputFormatter(FormsTextFormatters.regexAddressElements()),
                      ],
                      validator: _validateNotEmpty,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (v) {
                        FocusScope.of(context).requestFocus(_focusNumeroInterior);
                      },
                      focusNode: _focusDireccion,
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(bottom: 5),
                            child: Text(
                              'Número Interior',
                              textAlign: TextAlign.left,
                              style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                            ),
                          ),
                          TextFormField(
                            style: TextStyle(
                        color: HexColor('#0D47A1'),
                        fontSize: 14,
                        fontFamily: 'Archivo'
                      ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: HexColor('#F0EFF4'),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                              hintText: '(Opcional)',
                              hintStyle: TextStyle(fontWeight: FontWeight.w300, color: HexColor('#212B36').withOpacity(0.5)),
                            ),
                            initialValue: prefs.getString('delivery-numInterior') != null ? prefs.getString('delivery-numInterior') : '',
                            onSaved: (input) {
                              personalData.numInterior = input;
                            },
                            inputFormatters: [
                              WhitelistingTextInputFormatter(FormsTextFormatters.regexAddressElements()),
                            ],
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (v) {
                              FocusScope.of(context).requestFocus(_focusColonia);
                            },
                            // validator: _validateNotEmpty,
                            focusNode: _focusNumeroInterior,
                            // validator: _validateNotEmpty,
                          ),
                        ],
                      ),
                    ),
                  ),
                  //Spacer(), // Defaults to a flex of one.
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 8, left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(bottom: 5),
                            child: Text(
                              'Colonia',
                              textAlign: TextAlign.left,
                              style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                            ),
                          ),
                          TextFormField(
                            style: TextStyle(
                        color: HexColor('#0D47A1'),
                        fontSize: 14,
                        fontFamily: 'Archivo'
                      ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: HexColor('#F0EFF4'),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                              hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                            ),
                            initialValue: prefs.getString('delivery-sublocality') != null ? prefs.getString('delivery-sublocality') : '',
                            onSaved: (input) {
                              personalData.colonia = input;
                            },
                            inputFormatters: [
                              WhitelistingTextInputFormatter(FormsTextFormatters.regexAddressElements()),
                            ],
                            validator: FormsTextValidators.validateTextWithoutEmoji,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (v) {
                              FocusScope.of(context).requestFocus(_focusCodigoPostal);
                            },
                            focusNode: _focusColonia,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      flex: 7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(bottom: 5),
                            child: Text(
                              'Estado',
                              textAlign: TextAlign.left,
                              style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 2, bottom: 2, left: 0, right: 10),
                            child: Container(
                                padding: EdgeInsets.only(
                                    top: 0,
                                    bottom: 0,
                                    left: 6, //todo
                                    right: 6 //todo
                                    ),
                                decoration: BoxDecoration(
                                  color: HexColor('#F0EFF4'),
                                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                  // border: Border.all(
                                  //   color: HexColor('#F0EFF4')
                                  // ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButtonFormField(
                                    decoration: InputDecoration.collapsed(hintText: ''),
                                    value: personalData.estado,
                                    items: estados.map((val) {
                                      return DropdownMenuItem(
                                        value: val.estado,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 1, right: 1),
                                          child: Text(
                                            val.estado,
                                            style: TextStyle(
                        color: HexColor('#0D47A1'),
                        fontSize: 14,
                        fontFamily: 'Archivo'
                      ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    validator: (value) {
                                      if (value == null) {
                                        return "Requerido";
                                      }
                                    },
                                    onChanged: (val) {
                                      setState(() {
                                        Estados selected = estados.firstWhere((estado) => estado.estado == val);
                                        print(selected.isocode);
                                        personalData.estado = selected.estado;
                                        // widget.address.estado = selected.isocode;
                                      });
                                    },
                                    onSaved: (val) {
                                      Estados selected = estados.firstWhere((estado) => estado.estado == val);
                                      personalData.estado = selected.estado;
                                      print(personalData.estado);
                                    },
                                  ),
                                )),
                          ),
                          Container(
                            height: 20,
                          )
                        ],
                      )),
                  //Spacer(), // Defaults to a flex of one.
                  /* Row(
                  children: <Widget>[
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 8, bottom: 8),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin:
                                  EdgeInsets.only(bottom: 5),
                              child: Text(
                                '* Estado',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        HexColor('#212B36')),
                              ),
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    HexColor('#F4F6F8'),
                                border: OutlineInputBorder(),
                                contentPadding:
                                    const EdgeInsets.only(
                                        top: 12,
                                        bottom: 12,
                                        left: 6, //todo
                                        right: 6 //todo
                                        ),
                              ),
                              initialValue: prefs.getString(
                                          'delivery-estado') !=
                                      null
                                  ? prefs.getString(
                                      'delivery-estado')
                                  : '',
                              onSaved: (input) {
                                personalData.estado = input;
                              },
                              validator: _validateNotEmpty,
                              textInputAction:
                                  TextInputAction.next,
                              onFieldSubmitted: (v) {
                                FocusScope.of(context)
                                    .requestFocus(
                                        _focusCodigoPostal);
                              },
                              focusNode: _focusEstado,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Spacer(), // Defaults to a flex of one. */
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(bottom: 5),
                            child: Text(
                              'Código Postal',
                              textAlign: TextAlign.left,
                              style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                            ),
                          ),
                          TextFormField(
                            style: TextStyle(
                        color: HexColor('#0D47A1'),
                        fontSize: 14,
                        fontFamily: 'Archivo'
                      ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: HexColor('#F0EFF4'),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                              hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                            ),
                            initialValue: prefs.getString('delivery-codigoPostal') != null ? prefs.getString('delivery-codigoPostal') : '',
                            onSaved: (input) {
                              personalData.cpostal = input;
                            },
                            inputFormatters: [
                              WhitelistingTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(5),
                            ],
                            validator: _validateZipCode,
                            keyboardType: TextInputType.number,
                            maxLength: 5,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (v) {
                              FocusScope.of(context).requestFocus(_focusCorreo);
                            },
                            focusNode: _focusCodigoPostal,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            //  Row(
            //     children: <Widget>[
            //       Expanded(
            //         flex: 2,
            //         child: Padding(
            //           padding: EdgeInsets.only(top: 0, bottom: 8),
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: <Widget>[
            //               Container(
            //                 margin: EdgeInsets.only(bottom: 5),
            //                 child: Text(
            //                   'Apt/Suite',
            //                   textAlign: TextAlign.left,
            //                   style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
            //                 ),
            //               ),
            //               TextFormField(
            //                 style: TextStyle(
            //             color: HexColor('#0D47A1'),
            //             fontSize: 14,
            //             fontFamily: 'Archivo'
            //           ),
            //                 decoration: InputDecoration(
            //                   filled: true,
            //                   fillColor: HexColor('#F0EFF4'),
            //                   border: OutlineInputBorder(
            //                     borderRadius: new BorderRadius.only(
            //                       bottomLeft: const Radius.circular(4.0),
            //           bottomRight: const Radius.circular(0.0),
            //           topLeft: const Radius.circular(4.0),
            //           topRight: const Radius.circular(0.0)),
            //                   ),
            //                   contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
            //                   hintStyle: TextStyle(color: Colors.black, fontSize: 12),
            //                 ),
                            
            //                 onSaved: (input) {
            //                    dept = input;
            //                 },
            //                 inputFormatters: [
            //                   WhitelistingTextInputFormatter(FormsTextFormatters.regexAddressElements()),
            //                 ],
            //                 keyboardType: TextInputType.number,
            //                 textInputAction: TextInputAction.next,
            //                 onFieldSubmitted: (v) {
            //                   FocusScope.of(context).requestFocus(_focusDatosEntrega);
            //                 },
            //                 // validator: _validateNotEmpty,
            //                 focusNode: _focusApt,
            //                 // validator: _validateNotEmpty,
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //       //Spacer(), // Defaults to a flex of one.
            //       // Container(
            //       //   width: 2,
            //       //    height: 35,
            //       //    margin: EdgeInsets.only(top: 8, bottom: 0),
            //       //   // margin: EdgeInsets.only(left: 15),
            //       //   decoration: BoxDecoration(
            //       //     // border: Border(
            //       //     //   top: BorderSide(width: 5.0, color: HexColor('#FBC02D')),
            //       //     // ),
            //       //     color: Colors.red
            //       //   ),
            //       // ),
            //       Expanded(
            //         flex: 8,
            //         child: Padding(
            //           padding: EdgeInsets.only(top: 0, bottom: 8),
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: <Widget>[
            //               Container(
            //                 margin: EdgeInsets.only(bottom: 5),
            //                 child: Text(
            //                   'Detalles adicionales - (opcional)',
            //                   textAlign: TextAlign.left,
            //                   style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
            //                 ),
            //               ),
            //               TextFormField(
            //                 style: TextStyle(
            //             color: HexColor('#0D47A1'),
            //             fontSize: 14,
            //             fontFamily: 'Archivo'
            //           ),
            //                 decoration: InputDecoration(
            //                   filled: true,
            //                   fillColor: HexColor('#F0EFF4'),
            //                   border: OutlineInputBorder(
            //                     borderRadius: new BorderRadius.only(
            //                       bottomLeft: const Radius.circular(0.0),
            //           bottomRight: const Radius.circular(4.0),
            //           topLeft: const Radius.circular(0.0),
            //           topRight: const Radius.circular(4.0)),
            //                   ),
            //                   contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
            //                   hintStyle: TextStyle(color: Colors.black, fontSize: 12),
            //                 ),
            //                 // initialValue: prefs.getString('delivery-sublocality') != null ? prefs.getString('delivery-sublocality') : '',
            //                 onSaved: (input) {
            //                   infoEntrega = input;
            //                 },
            //                 inputFormatters: [
                        
            //             WhitelistingTextInputFormatter(FormsTextFormatters.regexNames()),
            //           ],
            //                 // validator: FormsTextValidators.validateTextWithoutEmoji,
            //                 textInputAction: TextInputAction.next,
            //                 onFieldSubmitted: (v) {
            //                   FocusScope.of(context).requestFocus(_focusCorreo);
            //                 },
            //                 focusNode: _focusDatosEntrega,
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 5),
                      child: Text(
                        'Correo Electrónico',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                      ),
                    ),
                    TextFormField(
                      style: TextStyle(
                        color: HexColor('#0D47A1'),
                        fontSize: 14,
                        fontFamily: 'Archivo'
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                        filled: true,
                        fillColor: HexColor('#F0EFF4'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                      initialValue: prefs.getString('email') ?? '',
                      onSaved: (input) {
                        personalData.email = input;
                      },
                      inputFormatters: [
                        // WhitelistingTextInputFormatter(
                        //   RegExp("[a-z]|[0-9]|[\@]|[\.]"),
                        // ),
                        LengthLimitingTextInputFormatter(100),
                      ],
                      enabled: !isLoggedIn,
                      enableInteractiveSelection: !isLoggedIn,
                      validator: _validateEmail,
                      textInputAction: TextInputAction.next,
                      focusNode: _focusCorreo,
                      keyboardType: TextInputType.emailAddress,
                      onFieldSubmitted: (v) {
                        FocusScope.of(context).requestFocus(_focusTelefono);
                      },
                    ),
                  ],
                ),
              ),
               Padding(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 5),
                      child: Text(
                        'Teléfono Móvil',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                      ),
                    ),
                    TextFormField(
                      style: TextStyle(
                        color: HexColor('#0D47A1'),
                        fontSize: 14,
                        fontFamily: 'Archivo'
                      ),
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
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      onSaved: (input) {
                        personalData.telefono = input;
                      },
                      initialValue: prefs.getString('delivery-telefono') != null ? prefs.getString('delivery-telefono') : '',
                      validator: _validatePhoneLength,
                      
                      textInputAction: !isLoggedIn ? TextInputAction.done : TextInputAction.next,
                      focusNode: _focusTelefono,
                    ),
                  ],
                ),
              ),
              FlatButton(
                textColor: DataUI.chedrauiBlueColor,
                onPressed: () async {
                  var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: RouteSettings(name: DataUI.deliveryMethodRoute),
                      builder: (context) => AddDeliveryNotes(),
                    ),
                  );
                  if(result != null){
                    widget.callbackNotas(result);
                  }
                },
                child: Text("Agregar notas de entrega"),
              )
            ],
          ),
        ),
      ),
      confirmarDatos(),
      elegirOtraDir()
    ]);
  }

  Widget savigDelivery() {
    return Column(children: <Widget>[
      /*
        Container(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              'Información Personal para entrega',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16,
                color: HexColor("#212B36"),
              ),
            ),
          ),
        ),
        */
      Container(
        alignment: Alignment.centerLeft,
        child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                /*
                Text(
                  "Nombre: ${personalData.nombre ?? ""} ${personalData.paterno ?? ""} ${personalData.materno ?? ""}",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 10,
                    color: HexColor("#212B36"),
                  ),
                ),
                Text(
                  "Dirección de entrega: ${personalData.direccion ?? "N/A"}, ${personalData.numInterior == null || personalData.numInterior.trim().length == 0 ? "" : "Int. " + personalData.numInterior+","} ${personalData.colonia ?? ""} ${personalData.cpostal ?? ""}, ${personalData.estado ?? ""}",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 10,
                    color: HexColor("#212B36"),
                  ),
                ),
                Text(
                  "Teléfono: ${personalData.telefono ?? "N/A"}",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 10,
                    color: HexColor("#212B36"),
                  ),
                ),
                Text(
                  "Email: ${personalData.email ?? ""}",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 10,
                    color: HexColor("#212B36"),
                  ),
                ),
                */
                FlatButton(
                  onPressed: () {
                    setState(() {
                      editing = true;
                    });
                    widget.callback(false, null);
                  },
                  child: Text(
                    "Editar",
                    style: TextStyle(
                      color: DataUI.chedrauiBlueColor
                    ),
                  ),
                )
              ],
            )),
      )
    ]);
  }

  Widget editingPickUp() {
    return Column(children: <Widget>[
      Form(
        key: _formKey[1],
        autovalidate: false,
        child: Theme(
          data: ThemeData(
            primaryColor: Colors.transparent,
            hintColor: Colors.transparent, // p
          ),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 5),
                      child: Text(
                        'Nombre',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 12, color: HexColor('#212B36')),
                      ),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: HexColor('#F0EFF4'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                        hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                      onFieldSubmitted: (v) {
                        FocusScope.of(context).requestFocus(_focusPaterno);
                      },
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        WhitelistingTextInputFormatter(FormsTextFormatters.regexNames()),
                      ],
                      maxLength: 25,
                      initialValue: prefs.getString('delivery-userName') != null ? prefs.getString('delivery-userName') : '',
                      onSaved: (input) {
                        personalData.nombre = input;
                      },
                      validator: _validateNotEmptyMinLength,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 5),
                      child: Text(
                        'Apellido Paterno',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 12, color: HexColor('#212B36')),
                      ),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: HexColor('#F0EFF4'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                        hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                      initialValue: prefs.getString('delivery-userLastName') != null ? prefs.getString('delivery-userLastName') : '',
                      inputFormatters: [
                        WhitelistingTextInputFormatter(FormsTextFormatters.regexNames()),
                      ],
                      maxLength: 25,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (v) {
                        FocusScope.of(context).requestFocus(_focusMaterno);
                      },
                      onSaved: (input) {
                        personalData.paterno = input;
                      },
                      validator: _validateNotEmptyMinLength,
                      focusNode: _focusPaterno,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 5),
                      child: Text(
                        'Apellido Materno',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 12, color: HexColor('#212B36')),
                      ),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: HexColor('#F0EFF4'),
                        //hintText: '(Opcional)',
                        //hintStyle: TextStyle(fontWeight: FontWeight.w300, color: HexColor('#212B36').withOpacity(0.5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                        // hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                      initialValue: prefs.getString('delivery-userSecondLastName') != null ? prefs.getString('delivery-userSecondLastName') : '',
                      onSaved: (input) {
                        personalData.materno = input;
                      },
                      maxLength: 25,
                      inputFormatters: [
                        WhitelistingTextInputFormatter(FormsTextFormatters.regexNames()),
                      ],
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (v) {
                        FocusScope.of(context).requestFocus(_focusTelefono);
                      },
                      focusNode: _focusMaterno,
                      validator: _validateNotEmpty,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 5),
                      child: Text(
                        'Teléfono Móvil',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 12, color: HexColor('#212B36')),
                      ),
                    ),
                    TextFormField(
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
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      onSaved: (input) {
                        personalData.telefono = input;
                      },
                      initialValue: prefs.getString('delivery-telefono') != null ? prefs.getString('delivery-telefono') : '',
                      validator: _validatePhoneLength,
                      onFieldSubmitted: (v) {
                        if(!isLoggedIn){
                          FocusScope.of(context).requestFocus(_focusCorreo);
                        }
                      },
                      textInputAction: isLoggedIn ? TextInputAction.done : TextInputAction.next,
                      focusNode: _focusTelefono,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 5),
                      child: Text(
                        'Correo Electrónico',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 12, color: HexColor('#212B36')),
                      ),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: HexColor('#F0EFF4'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                        hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                      style: isLoggedIn ? Theme.of(context).textTheme.subhead.copyWith(
                        color: DataUI.textDisabled,
                      ) : null,
                      onSaved: (input) {
                        personalData.email = input;
                      },
                      inputFormatters: [
                        // WhitelistingTextInputFormatter(
                        //   RegExp("[a-z]|[0-9]|[\@]|[\.]"),
                        // ),

                        LengthLimitingTextInputFormatter(100),
                      ],
                      initialValue: prefs.getString('email') ?? '',
                      enabled: !isLoggedIn,
                      enableInteractiveSelection: !isLoggedIn,
                      validator: _validateEmail,
                      textInputAction: TextInputAction.done,
                      focusNode: _focusCorreo,
                      keyboardType: TextInputType.emailAddress,
                      onFieldSubmitted: (input) {},
                    ),
                  ],
                ),
              ),
              FlatButton(
                textColor: DataUI.chedrauiBlueColor,
                onPressed: () async {
                  var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: RouteSettings(name: DataUI.deliveryMethodRoute),
                      builder: (context) => AddDeliveryNotes(),
                    ),
                  );
                  if(result != null){
                    widget.callbackNotas(result);
                  }
                },
                child: Text("Agregar notas de entrega"),
              )
            ],
          ),
        ),
      ),
      confirmarDatos()
    ]);
  }

  Widget savingPickUp() {
    return Row(
      children: <Widget>[
        Flexible(
          flex: 5,
          child: Column(children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      /*
                      Text(
                        "Nombre: ${personalData.nombre ?? ""} ${personalData.paterno ?? ""} ${personalData.materno ?? ""}",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 10,
                          color: HexColor("#212B36"),
                        ),
                      ),
                      Text(
                        "Teléfono: ${personalData.telefono ?? "N/A"}",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 10,
                          color: HexColor("#212B36"),
                        ),
                      ),
                      Text(
                        "Email: ${personalData.email ?? "N/A"}",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 10,
                          color: HexColor("#212B36"),
                        ),
                      ),
                      */
                    ],
                  )),
            )
          ]),
        ),
        Flexible(
          flex: 2,
          child: FlatButton(
            onPressed: () {
              setState(() {
                editing = true;
              });
              widget.callback(false, null);
            },
            child: Text(
              "Cambiar",
              style: TextStyle(
                color: DataUI.chedrauiBlueColor
              ),
            ),
          ),
        )
      ]
    );
  }

  Widget confirmarDatos() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 7),
      child: RaisedButton(
        disabledColor: HexColor('#F57C00').withOpacity(0.5),
        padding: EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
        onPressed: () {
          submitForm();
        },
        color: HexColor('#F57C00'),
        child: Text(
          'Confirmar datos personales',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: 'Archivo',
            fontSize: 14,
            letterSpacing: 0.25,
            color: HexColor('#FFFFFF'),
          ),
        ),
      ),
    );
  }

  Widget elegirOtraDir() {
    return isLoggedIn
        ? Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 7),
            child: otrasDirecciones != null
                ? Column(
                    children: <Widget>[
                      Text("O elegir otra dirección"),
                      dropdown.DropdownButtonFormField(
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
                        items: this.otrasDirecciones,
                        onChanged: (value) async {
                          try {
                            var address = otrasDireccionesRaw.firstWhere((d) => value == d['id']);
                            prefs.setBool('isLocationSet', true);
                            prefs.setBool('isPickUp', false);
                            prefs.setString('delivery-userName', address['firstName']);
                            prefs.setString('delivery-userLastName', address['lastName']);
                            prefs.setString('delivery-direccion', address['line1']);
                            prefs.setString('delivery-numInterior', address['line2']);
                            prefs.setString('delivery-sublocality', address['town']);
                            prefs.setString('delivery-codigoPostal', address['postalCode']);
                            prefs.setString('delivery-estado', address['region'] != null ? address['region']['name'] : "");
                            prefs.setString("delivery-telefono", address["phone"]);
                            prefs.setString("delivery-formatted_address", address["formattedAddress"]);
                            prefs.setString("delivery-address-id", address["id"]);
                            setState(() {
                              _direccionId = value;
                            });
                            await CarritoServices.setDeliveryModeCart();
                            await _getStoredPersonalData();
                          } catch (e) {
                            print('NO ADDRESS FOUND: $value');
                          }
                        },
                        value: _direccionId,
                      ),
                    ],
                  )
                : SizedBox(height: 0))
        : SizedBox(height: 0);
  }

  @override
  Widget build(BuildContext context) {
    return sharedPrefs == false || personalData == null
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Color(0xcc000000).withOpacity(0.1),
                  offset: Offset(0.0, 5.0),
                  blurRadius: 10.0,
                ),
              ],
            ),
            margin: EdgeInsets.all(0),
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Color(0xcc000000).withOpacity(0.1),
                      offset: Offset(0.0, 5.0),
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: isPickUp ? (editing ? editingPickUp() : savingPickUp()) : (editing ? editingDelivery() : savigDelivery()),
              ),
            ),
          );
  }

  void _initializeEstados() {
    setState(() {
      estados.add(Estados(estado: "Aguascalientes", isocode: "MX-AGU"));
      estados.add(Estados(estado: "Baja California", isocode: "MX-BCN"));
      estados.add(Estados(estado: "Baja California Sur", isocode: "MX-BCS"));
      estados.add(Estados(estado: "Campeche", isocode: "MX-CAM"));
      estados.add(Estados(estado: "Chiapas", isocode: "MX-CHP"));
      estados.add(Estados(estado: "Chihuahua", isocode: "MX-CHH"));
      estados.add(Estados(estado: "Coahuila", isocode: "MX-COA"));
      estados.add(Estados(estado: "Colima", isocode: "MX-COL"));
      estados.add(Estados(estado: "Ciudad de México", isocode: "MX-CMX"));
      estados.add(Estados(estado: "Durango", isocode: "MX-DUR"));
      estados.add(Estados(estado: "Guanajuato", isocode: "MX-GUA"));
      estados.add(Estados(estado: "Guerrero", isocode: "MX-GRO"));
      estados.add(Estados(estado: "Hidalgo", isocode: "MX-HID"));
      estados.add(Estados(estado: "Jalisco", isocode: "MX-JAL"));
      estados.add(Estados(estado: "Estado de México", isocode: "MX-MEX"));
      estados.add(Estados(estado: "Michoacán", isocode: "MX-MIC"));
      estados.add(Estados(estado: "Morelos", isocode: "MX-MOR"));
      estados.add(Estados(estado: "Nayarit", isocode: "MX-NAY"));
      estados.add(Estados(estado: "Nuevo León", isocode: "MX-NLE"));
      estados.add(Estados(estado: "Oaxaca", isocode: "MX-OAX"));
      estados.add(Estados(estado: "Puebla", isocode: "MX-PUE"));
      estados.add(Estados(estado: "Querétaro", isocode: "MX-QUE"));
      estados.add(Estados(estado: "Quintana Roo", isocode: "MX-ROO"));
      estados.add(Estados(estado: "San Luis Potosí", isocode: "MX-SLP"));
      estados.add(Estados(estado: "Sinaloa", isocode: "MX-SIN"));
      estados.add(Estados(estado: "Sonora", isocode: "MX-SON"));
      estados.add(Estados(estado: "Tabasco", isocode: "MX-TAB"));
      estados.add(Estados(estado: "Tamaulipas", isocode: "MX-TAM"));
      estados.add(Estados(estado: "Tlaxcala", isocode: "MX-TLA"));
      estados.add(Estados(estado: "Veracruz", isocode: "MX-VER"));
      estados.add(Estados(estado: "Yucatán", isocode: "MX-YUC"));
      estados.add(Estados(estado: "Zacatecas", isocode: "MX-ZAC"));
    });
  }
}
