import 'package:chd_app_demo/services/UserProfileServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/utils/addressData.dart';
import 'package:chd_app_demo/utils/input_formatters.dart';
import 'package:chd_app_demo/views/DeliveryMethod/Estados.dart';
import 'package:chd_app_demo/views/DeliveryMethod/SelectedLocation.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

class ConfirmAddressPage extends StatefulWidget {
  final SelectedLocation completeAddress;
  ConfirmAddressPage({
    Key key,
    this.completeAddress,
  }) : super(key: key);

  _ConfirmAddressPageState createState() => _ConfirmAddressPageState();
}

class _ConfirmAddressPageState extends State<ConfirmAddressPage> {
  SharedPreferences prefs;
  List<Estados> estados = [];
  String mergeAddress;
  // Estados confirmacionEstado;

  final addresFormKey = GlobalKey<FormState>();
  bool _autoValidateAddressForm = false;
  SelectedLocation confirmAddress;

  final _focusPaterno = FocusNode();
  final _focusMaterno = FocusNode();
  final _focusDireccion = FocusNode();
  final _focusNumeroInterior = FocusNode();
  final _focusColonia = FocusNode();
  final _focusEstado = FocusNode();
  final _focusCodigoPostal = FocusNode();
  final _focusDatosEntrega = FocusNode();
  final _focusTelefono = FocusNode();

  bool _isLoggedIn = false;
  bool _isLoading = false;

  @override
  void initState() {
    _initializeEstados();
    confirmAddress = widget.completeAddress;
    mergeAddress = confirmAddress.route.length > 0 ? confirmAddress.route + ' ' : '';
    mergeAddress += confirmAddress.streetNumber.length > 0 ? confirmAddress.streetNumber + ' ' : '';
    //mergeAddress += (confirmAddress.sublocality.length > 0 ? confirmAddress.sublocality : '');
    super.initState();
    getPreferences();
  }

  Future getPreferences() async {
    prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WidgetContainer(
      Scaffold(
        resizeToAvoidBottomPadding: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            'Agregar Dirección',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 28,
              color: DataUI.textOpaqueStrong,
            ),
          ),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Theme(
              data: ThemeData(
                primaryColor: Colors.transparent,
                hintColor: Colors.transparent,
              ),
              child: SingleChildScrollView(
                child: Form(
                  autovalidate: _autoValidateAddressForm,
                  key: addresFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 8, bottom: 8),
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
                              style: TextStyle(color: DataUI.chedrauiBlueColor, fontSize: 14, fontFamily: 'Archivo'),
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
                              onFieldSubmitted: (v) {
                                FocusScope.of(context).requestFocus(_focusPaterno);
                              },
                              textInputAction: TextInputAction.next,
                              validator: FormsTextValidators.validateEmptyName,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(100),
                                WhitelistingTextInputFormatter(
                                  FormsTextValidators.commonPersonName,
                                ),
                              ],
                              onSaved: (input) {
                                confirmAddress.userName = input;
                              },
                              // initialValue: widget.address.firstName,
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
                                style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                              ),
                            ),
                            TextFormField(
                              style: TextStyle(color: DataUI.chedrauiBlueColor, fontSize: 14, fontFamily: 'Archivo'),
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
                              validator: FormsTextValidators.validateEmptyName,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(100),
                                WhitelistingTextInputFormatter(
                                  FormsTextValidators.commonPersonName,
                                ),
                              ],
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (v) {
                                FocusScope.of(context).requestFocus(_focusMaterno);
                              },
                              onSaved: (input) {
                                confirmAddress.userLastName = input;
                              },
                              // initialValue: widget.address.lastName,
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
                              style: TextStyle(color: DataUI.chedrauiBlueColor, fontSize: 14, fontFamily: 'Archivo'),
                              decoration: InputDecoration(
                                //hintText: '(Opcional)',
                                //hintStyle: TextStyle(fontWeight: FontWeight.w300, color: HexColor('#212B36').withOpacity(0.5)),
                                contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                                filled: true,
                                fillColor: HexColor('#F0EFF4'),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                // hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                              ),
                              onSaved: (input) {
                                confirmAddress.userSecondLastName = input;
                              },
                              // initialValue: widget.address.secondLastName,
                              validator: FormsTextValidators.validateEmptyName,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(100),
                                WhitelistingTextInputFormatter(
                                  FormsTextValidators.commonPersonName,
                                ),
                              ],
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (v) {
                                FocusScope.of(context).requestFocus(_focusDireccion);
                              },
                              focusNode: _focusMaterno,
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
                              style: TextStyle(color: DataUI.chedrauiBlueColor, fontSize: 14, fontFamily: 'Archivo'),
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
                              onSaved: (input) {
                                confirmAddress.direccion = input;
                              },
                              initialValue: mergeAddress,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (v) {
                                FocusScope.of(context).requestFocus(_focusDatosEntrega);
                              },
                              focusNode: _focusDireccion,
                              validator: FormsTextValidators.validateDeliveryAddress,
                              inputFormatters: <TextInputFormatter>[
                                LengthLimitingTextInputFormatter(120),
                              ],
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
                                    initialValue: confirmAddress.numInterior,
                                    style: TextStyle(color: DataUI.chedrauiBlueColor, fontSize: 14, fontFamily: 'Archivo'),
                                    decoration: InputDecoration(
                                      counterText: "",
                                      contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                                      filled: true,
                                      fillColor: HexColor('#F0EFF4'),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                      hintText: '(Opcional)',
                                      hintStyle: TextStyle(fontWeight: FontWeight.w300, color: HexColor('#212B36').withOpacity(0.5)),
                                    ),
                                    onSaved: (input) {
                                      confirmAddress.numInterior = input;
                                    },
                                    // validator: _validateNotEmpty,
                                    onFieldSubmitted: (v) {
                                      FocusScope.of(context).requestFocus(_focusColonia);
                                    },
                                    textInputAction: TextInputAction.next,
                                    focusNode: _focusDatosEntrega,
                                    inputFormatters: <TextInputFormatter>[
                                      LengthLimitingTextInputFormatter(100),
                                      WhitelistingTextInputFormatter(
                                        FormsTextValidators.lettersAndNumbers,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                                    initialValue: confirmAddress.sublocality,
                                    style: TextStyle(color: DataUI.chedrauiBlueColor, fontSize: 14, fontFamily: 'Archivo'),
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
                                    onSaved: (input) {
                                      confirmAddress.sublocality = input;
                                    },
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (v) {
                                      FocusScope.of(context).requestFocus(_focusCodigoPostal);
                                    },
                                    focusNode: _focusColonia,
                                    validator: FormsTextValidators.validateNotEmpty,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(40),
                                      WhitelistingTextInputFormatter(
                                        FormsTextValidators.commonPersonName,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 6,
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
                                          value: confirmAddress.estado.length > 0 ? confirmAddress.estado : null,
                                          items: estados.map((val) {
                                            return DropdownMenuItem(
                                              value: val.estado,
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 1, right: 1),
                                                child: Text(
                                                  val.estado,
                                                  style: TextStyle(color: HexColor('#0D47A1'), fontSize: 14, fontFamily: 'Archivo'),
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
                                              confirmAddress.estado = val;
                                            });
                                            setState(() {
                                              Estados selected = estados.firstWhere((estado) => estado.estado == val);
                                              print(selected.isocode);
                                              // confirmAddress.estado = selected.isocode;
                                            });
                                          },
                                          onSaved: (val) {
                                            Estados selected = estados.firstWhere((estado) => estado.estado == val);
                                            print(selected.isocode);
                                            confirmAddress.isocode = selected.isocode;
                                          },
                                        ),
                                      )),
                                ),
                                // Container(
                                //   height: 20,
                                // ),
                              ],
                            ),
                          ),
                          // Spacer(), // Defaults to a flex of one.
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
                                    initialValue: confirmAddress.codigoPostal,
                                    enabled: true,
                                    style: TextStyle(color: DataUI.chedrauiBlueColor, fontSize: 14, fontFamily: 'Archivo'),
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
                                    validator: FormsTextValidators.validatePostalCode,
                                    inputFormatters: <TextInputFormatter>[
                                      WhitelistingTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(5),
                                    ],
                                    onSaved: (input) {
                                      confirmAddress.codigoPostal = input;
                                    },
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (v) {
                                      FocusScope.of(context).requestFocus(_focusTelefono);
                                    },
                                    focusNode: _focusCodigoPostal,
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
                              // initialValue: widget.address.phone,
                              style: TextStyle(color: DataUI.chedrauiBlueColor, fontSize: 14, fontFamily: 'Archivo'),
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
                              validator: FormsTextValidators.validatePhone,
                              inputFormatters: <TextInputFormatter>[
                                WhitelistingTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              onSaved: (input) {
                                confirmAddress.telefono = input;
                              },
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              focusNode: _focusTelefono,
                              onFieldSubmitted: (input) {
                                _submitAddressForm();
                              },
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 30),
                              child: FlatButton(
                                disabledColor: HexColor('#F57C00').withOpacity(0.5),
                                padding: EdgeInsets.symmetric(vertical: 5),
                                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                                color: DataUI.btnbuy,
                                child: !_isLoading
                                    ? Text(
                                        'Confirmar dirección de envío',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      )
                                    : CircularProgressIndicator(),
                                onPressed: !_isLoading
                                    ? () {
                                        _submitAddressForm();
                                      }
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitAddressForm() async {
    setState(() {
      _autoValidateAddressForm = true;
    });
    if (addresFormKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      addresFormKey.currentState.save();
      setState(() {
        _isLoading = true;
      });
      if (_isLoggedIn) {
        await _storeDeliveryData();
        await _addNewAddress();
      } else {
        await _storeDeliveryData();
        _showConfirmationDialog();
      }
      // print('Printing needed.');
      // print(confirmAddress.userName);
      // print(confirmAddress.userLastName);
      // print(confirmAddress.userSecondLastName);
      // print(confirmAddress.direccion);
      // print(confirmAddress.streetNumber);
      // print(confirmAddress.estado);
      // print(confirmAddress.locality);
      // print(confirmAddress.codigoPostal);
      // print(confirmAddress.deliveryNote);
      // print('Printing extra data');
      // print(confirmAddress.route);
      // print(confirmAddress.name);
    }
  }

  Future<void> _addNewAddress() async {
    try {
      String numInterior = confirmAddress.numInterior.length > 0 ? confirmAddress.numInterior + ', ' : '';
      String mergeAddress = numInterior + confirmAddress.direccion + ', ' + confirmAddress.sublocality + ', ' + confirmAddress.codigoPostal + ', ' + confirmAddress.estado;
      prefs.setBool('isLocationSet', true);
      prefs.setBool('isPickUp', false);

      Map addressObject = {
        "country": {"isocode": "MX"},
        "country.isocode": "MX",
        "firstName": confirmAddress.userName,
        "lastName": confirmAddress.userLastName,
        "secondLastName": confirmAddress.userSecondLastName,
        "formattedAddress": mergeAddress,
        "line1": confirmAddress.direccion,
        "line2": "$numInterior ${confirmAddress.deliveryNote}",
        "postalCode": confirmAddress.codigoPostal,
        "region": {
          "countryIso": "MX",
          "isocode": confirmAddress.isocode,
          "isocodeShort": confirmAddress.codigoPostal.replaceAll('MX-', ''),
          "name": confirmAddress.estado,
        },
        "town": confirmAddress.sublocality,
        "phone": confirmAddress.telefono,
        "shippingAddress": true,
        "visibleInAddressBook": true,
      };

      await UserProfileServices.hybrisAddUserAddress(addressObject).then((response) {
        if (response.statusCode == 201) {
          final resBody = json.decode(utf8.decode(response.bodyBytes));
          prefs.setBool('isLocationSet', true);
          prefs.setBool('isPickUp', false);
          prefs.setString('delivery-codigoPostal', confirmAddress.codigoPostal);
          prefs.setString("delivery-address-id", resBody["id"]);
          prefs.setString("delivery-formatted_address", mergeAddress);
          print('test :' + prefs.getString('delivery-address-id'));
          print('test :' + prefs.getString('delivery-codigoPostal'));
          print('test :' + prefs.getString('delivery-formatted_address'));
          _showConfirmationDialog();
        } else {
          _showValidationDialog();
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _storeDeliveryData() async {
    try {
      String numInterior = confirmAddress.numInterior.length > 0 ? confirmAddress.numInterior + ', ' : '';
      String mergeAddress = numInterior + confirmAddress.direccion + ', ' + confirmAddress.locality + ', ' + confirmAddress.codigoPostal + ', ' + confirmAddress.estado;
      prefs.setBool('isLocationSet', true);
      prefs.setBool('isPickUp', false);

      prefs.setString('delivery-userName', confirmAddress.userName);
      prefs.setString('delivery-userLastName', confirmAddress.userLastName);
      prefs.setString('delivery-userSecondLastName', confirmAddress.userSecondLastName);
      prefs.setString('delivery-direccion', confirmAddress.direccion);
      prefs.setString('delivery-streetNumber', confirmAddress.streetNumber);
      prefs.setString('delivery-numInterior', confirmAddress.numInterior);
      prefs.setString('delivery-estado', confirmAddress.estado);
      prefs.setString('delivery-isocode', confirmAddress.isocode);
      prefs.setString('delivery-locality', confirmAddress.locality);
      prefs.setString('delivery-codigoPostal', confirmAddress.codigoPostal);
      prefs.setString('delivery-deliveryNote', confirmAddress.deliveryNote);
      prefs.setString('delivery-telefono', confirmAddress.telefono);
      prefs.setString('delivery-route', confirmAddress.route);
      prefs.setString('delivery-locationName', confirmAddress.name);
      prefs.setString('delivery-formatted_address', mergeAddress);
      prefs.setDouble('delivery-lat', confirmAddress.lat);
      prefs.setDouble('delivery-lng', confirmAddress.lng);
      prefs.remove('delivery-address-id');

      print('stored data: ');
      print('test :' + prefs.getBool('isLocationSet').toString());
      print('test :' + prefs.getString('delivery-userName'));
      print('test :' + prefs.getString('delivery-userLastName'));
      print('test :' + prefs.getString('delivery-userSecondLastName'));
      print('test :' + prefs.getString('delivery-direccion'));
      print('test :' + prefs.getString('delivery-streetNumber'));
      print('test :' + prefs.getString('delivery-numInterior'));
      print('test :' + prefs.getString('delivery-estado'));
      print('test :' + prefs.getString('delivery-isocode'));
      print('test :' + prefs.getString('delivery-locality'));
      print('test :' + prefs.getString('delivery-codigoPostal'));
      print('test :' + prefs.getString('delivery-deliveryNote'));
      print('test :' + prefs.getString('delivery-route'));
      print('test :' + prefs.getString('delivery-locationName'));
      print('test :' + prefs.getString('delivery-codigoPostal'));
      print('test :' + prefs.getString('delivery-formatted_address'));
      print('test :' + prefs.getDouble('delivery-lat').toString());
      print('test :' + prefs.getDouble('delivery-lng').toString());

      //_showConfirmationDialog();
    } catch (e) {
      print(e.toString());
    }
  }

  void _showConfirmationDialog() {
    setState(() {
      _isLoading = false;
    });
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Listo!"),
          content: Text(
            'Dirección configurada correctamente',
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
                  Navigator.pop(context);
                  Navigator.of(context).pop('direcciones');
                  // Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
                },
                child: Text(
                  "Continuar",
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

  void _showValidationDialog() {
    setState(() {
      _isLoading = false;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Información Inválida'),
          content: Text(
            'Por favor verificar que los datos sean correctos',
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
            ),
          ],
        );
      },
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

    // for (var estado in estados) {
    //   print(estado.estado);
    // }
  }
}
