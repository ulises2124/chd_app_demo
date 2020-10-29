import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/CuentaPage/EditAddressPage.dart';
import 'package:chd_app_demo/utils/addressData.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chd_app_demo/services/UserProfileServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/views/Checkout/AddDeliveryNotes.dart';
import 'package:chd_app_demo/views/DeliveryMethod/DeliveryMethodPage.dart';
import 'package:chd_app_demo/views/DeliveryMethod/Estados.dart';
import 'package:chd_app_demo/views/Checkout/TextInputsFormatters.dart';
import 'package:chd_app_demo/utils/input_formatters.dart';
import 'package:flutter/services.dart';
import 'package:chd_app_demo/views/Checkout/PersonalInformationData.dart';

class AddressesRegistredUserWidget extends StatefulWidget {
  final Function callback;
  final Function callbackForm;
  final Function callbackNotas;
  AddressesRegistredUserWidget({Key key, this.callback, this.callbackForm, this.callbackNotas}) : super(key: key);

  _AddressesRegistredUserState createState() => _AddressesRegistredUserState();
}

class _AddressesRegistredUserState extends State<AddressesRegistredUserWidget> {
  SharedPreferences prefs;
  Future<dynamic> dataAddresses;
  List addresses;
  List shownAddresses;
  String currentAddressId;
  num totalAdress;
  num totalDisplay = 3;
  num remaining;
  bool addressChanged = false;

  final _formKey = GlobalKey<FormState>();
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
  final _mobileFormatter = NumberTextInputFormatter();
  var token;
  var cart;
  List cartItems;
  List<String> cartItemsImages = [];
  bool _autoValidateFirstForm = false;
  bool sharedPrefs = false;
  bool editing = true;
  PersonalInformationData personalData = new PersonalInformationData();
  String selectedAddressId;

  TextEditingController textFormControllerNombre = new TextEditingController();
  TextEditingController textFormControllerPaterno = new TextEditingController();
  TextEditingController textFormControllerMaterno = new TextEditingController();
  TextEditingController textFormControllerDireccion = new TextEditingController();
  TextEditingController textFormControllerNumInterior = new TextEditingController();
  TextEditingController textFormControllerColonia = new TextEditingController();
  TextEditingController textFormControllerCodigoPostal = new TextEditingController();
  TextEditingController textFormControllerTelefono = new TextEditingController();

  bool loadingAddressToHybris = false;

  bool hideForm = false;

  Future<void> loadWidget({num pastTotalDisplay}) async {
    prefs = await SharedPreferences.getInstance();
    dataAddresses = UserProfileServices.hybrisGetUserAddress().then((data) {
      setState(() {
        addresses = data['addresses'];
        totalDisplay = pastTotalDisplay ?? 
        (addresses.length < totalDisplay ? addresses.length : totalDisplay);
        currentAddressId = prefs.getString('delivery-address-id') ?? null;
        totalAdress = addresses.length;
        if (totalAdress > 3) {
          remaining = totalAdress - totalDisplay;
          if(currentAddressId != null){
            int selectedIndex = addresses.indexOf(addresses.firstWhere((item) => item['id'] == currentAddressId));
            if(selectedIndex == 0){
              shownAddresses = addresses.sublist(0,3);
            } else if(selectedIndex == addresses.length -1){
              shownAddresses = addresses.sublist(addresses.length -3,addresses.length);
            } else {
              shownAddresses = addresses.sublist(selectedIndex - 1, selectedIndex + 2);
            }
          } else {
            shownAddresses = addresses.sublist(0,3);
          }
        } else {
          remaining = pastTotalDisplay != null ? totalAdress - pastTotalDisplay : 0 ;
          shownAddresses = addresses;
        }
      });
      if(currentAddressId != null){
        hideForm = true;
        widget.callbackForm(true);
        try{
          var cuurAddr = addresses.firstWhere((a){
            return a['id'] == currentAddressId;
          });
          setNewAddressOnForm(currentAddressId);
          widget.callback(cuurAddr, continueActive: true);
        } catch(e){
          print(e);
          widget.callback(null);
        }
      } else {
        widget.callback(null);
      }
    });
  }

  loadMore() {
    setState(() {
      remaining = 0;
      totalDisplay = addresses.length;
      shownAddresses = addresses;
    });
  }

  _getStoredPersonalData() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs != null) {
      setState(() {
        sharedPrefs = true;
        editing = true;
      });
      setState(() {
          selectedAddressId = prefs.getString('delivery-address-id');
        //if(addressId != null){
          personalData.nombre = prefs.getString('delivery-userName') ?? "";
          personalData.paterno = prefs.getString('delivery-userLastName') ?? "";
          personalData.materno = prefs.getString('delivery-userSecondLastName') ?? "";
          personalData.telefono = prefs.getString('delivery-telefono') ?? "";
          textFormControllerNombre.value = new TextEditingController.fromValue(new TextEditingValue(text: personalData.nombre)).value;
          textFormControllerPaterno.value = new TextEditingController.fromValue(new TextEditingValue(text: personalData.paterno)).value;
          textFormControllerMaterno.value = new TextEditingController.fromValue(new TextEditingValue(text: personalData.materno)).value;
          textFormControllerTelefono.value = new TextEditingController.fromValue(new TextEditingValue(text: personalData.telefono)).value;
        //}
        personalData.direccion = prefs.getString('delivery-direccion');
        personalData.numInterior = prefs.getString('delivery-numInterior');
        personalData.colonia = prefs.getString('delivery-sublocality');
        personalData.cpostal = prefs.getString('delivery-codigoPostal');
        personalData.estado = prefs.getString('delivery-estado');
        personalData.email = prefs.getString('email');
        textFormControllerDireccion.value = new TextEditingController.fromValue(new TextEditingValue(text: personalData.direccion)).value;
        textFormControllerNumInterior.value = new TextEditingController.fromValue(new TextEditingValue(text: personalData.numInterior != null ? personalData.numInterior : '')).value;
        textFormControllerColonia.value = new TextEditingController.fromValue(new TextEditingValue(text: personalData.colonia)).value;
        textFormControllerCodigoPostal.value = new TextEditingController.fromValue(new TextEditingValue(text: personalData.cpostal)).value;
      });
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        loadingAddressToHybris = true;
      });
      Address editAddress = new Address();
      editAddress.countryisocode = "MX";
      editAddress.countryname = "Mexico";
      editAddress.email = prefs.getString("email");
      editAddress.firstName = personalData.nombre;
      editAddress.lastName = personalData.paterno;
      editAddress.secondLastName = personalData.materno ?? ' Sin información';
      editAddress.line1 = personalData.direccion;
      editAddress.line2 = personalData.numInterior ?? 'N/A';
      editAddress.phone = personalData.telefono;
      editAddress.postalCode = personalData.cpostal;
      editAddress.regioncountryIso = "MX";
      editAddress.regionisocode = personalData.isocode;
      editAddress.regionname = personalData.estado;
      editAddress.shippingAddress = true;
      editAddress.town = personalData.colonia;
      editAddress.visibleInAddressBook = true;
      editAddress.updateFormattedAddress();
      editAddress.updateRegionIsocodeShort();
      var selectedAddress = {
        "firstName": editAddress.firstName,
        "lastName": editAddress.lastName,
        "secondLastName": editAddress.secondLastName,
        "line1": editAddress.line1,
        "line2": editAddress.line2,
        "region": {
          "name": editAddress.regionname,
          "isocode": editAddress.regionisocode,
          "isocodeShort": editAddress.regionisocodeShort,
          "countryIso": editAddress.regioncountryIso
        },
        "country": {
          "isocode": editAddress.countryisocode,
          "name": editAddress.countryname
        },
        "postalCode": editAddress.postalCode,
        "phone": editAddress.phone,
        "town": editAddress.town
      };
      print(selectedAddress);
      if(currentAddressId != null){
        editAddress.id = currentAddressId;
        selectedAddress['id'] = currentAddressId;
        print('SELECTING EXISTING ADDRESS');
        print(currentAddressId);
        print(selectedAddress);
        setState(() {
          editing = false;
          loadingAddressToHybris = false;
        });
        widget.callback(selectedAddress, continueActive: true);
        /*
        await UserProfileServices.hybrisEditUserAddress(editAddress).then((response) {
          if (response.statusCode == 200) {
            print("Dirección $currentAddressId actualizada");
            setState(() {
              editing = false;
            });
          } else {
            print("Error actualizando $currentAddressId: ${response.statusCode}");
          }
          setState(() {
            loadingAddressToHybris = false;
          });
          widget.callback(selectedAddress, continueActive: true);
        });
        */
      } else {
        setState(() {
          editing = false;
          loadingAddressToHybris = false;
        });
        widget.callback(selectedAddress, continueActive: true);
        /*
        print('CREATING ADDRESS');
        print(selectedAddress);
        await UserProfileServices.hybrisAddUserAddress(selectedAddress).then((response) {
          if (response.statusCode == 201) {
            print("Nueva dirección agregada");
            setState(() {
              editing = false;
            });
          } else {
            print(selectedAddress);
            print("Error agregando dirección nueva: ${response.statusCode}");
            print(response.body);
          }
          setState(() {
            loadingAddressToHybris = false;
          });
          widget.callback(selectedAddress, continueActive: true);
        });
        */
      }
    }
  }

  setNewAddressOnForm(String addressId){
    var selectedAddress = addresses.firstWhere((a){
      return a['id'] == addressId;
    });
    setState(() {
      currentAddressId = addressId;
      personalData.nombre = selectedAddress['firstName'];
      personalData.paterno = selectedAddress['lastName'];
      personalData.materno = selectedAddress['secondLastName'] ?? 'Sin información';
      personalData.direccion = selectedAddress['line1'];
      personalData.numInterior = selectedAddress['line2'] ?? 'N/A';
      personalData.estado = selectedAddress['region']['name'];
      personalData.isocode = selectedAddress['region']['isocode'];
      personalData.colonia = selectedAddress['town'];
      personalData.cpostal = selectedAddress['postalCode'];
      personalData.telefono = selectedAddress['phone'];
      textFormControllerNombre.value = new TextEditingController.fromValue(new TextEditingValue(text: personalData.nombre)).value;
      textFormControllerPaterno.value = new TextEditingController.fromValue(new TextEditingValue(text: personalData.paterno)).value;
      textFormControllerMaterno.value = new TextEditingController.fromValue(new TextEditingValue(text: personalData.materno)).value;
      textFormControllerTelefono.value = new TextEditingController.fromValue(new TextEditingValue(text: personalData.telefono)).value;
      textFormControllerDireccion.value = new TextEditingController.fromValue(new TextEditingValue(text: personalData.direccion)).value;
      textFormControllerNumInterior.value = new TextEditingController.fromValue(new TextEditingValue(text: personalData.numInterior)).value;
      textFormControllerColonia.value = new TextEditingController.fromValue(new TextEditingValue(text: personalData.colonia)).value;
      textFormControllerCodigoPostal.value = new TextEditingController.fromValue(new TextEditingValue(text: personalData.cpostal)).value;
    });
    widget.callback(selectedAddress, continueActive: true);
  }

  clearAddress(){
    currentAddressId = null;
    textFormControllerNombre.value = new TextEditingController.fromValue(new TextEditingValue(text: "")).value;
    textFormControllerPaterno.value = new TextEditingController.fromValue(new TextEditingValue(text: "")).value;
    textFormControllerMaterno.value = new TextEditingController.fromValue(new TextEditingValue(text: "")).value;
    textFormControllerTelefono.value = new TextEditingController.fromValue(new TextEditingValue(text: "")).value;
    textFormControllerDireccion.value = new TextEditingController.fromValue(new TextEditingValue(text: "")).value;
    textFormControllerNumInterior.value = new TextEditingController.fromValue(new TextEditingValue(text: "")).value;
    textFormControllerColonia.value = new TextEditingController.fromValue(new TextEditingValue(text: "")).value;
    textFormControllerCodigoPostal.value = new TextEditingController.fromValue(new TextEditingValue(text: "")).value;
    widget.callback(null, continueActive: false);
  }

  Future<void> initWidget() async{
    _initializeEstados();
    await _getStoredPersonalData();
    await loadWidget();
  }

  @override
  void initState() {
    initWidget();
    super.initState();
  }

  @override
  void dispose() {
    textFormControllerCodigoPostal.dispose();
    textFormControllerColonia.dispose();
    textFormControllerDireccion.dispose();
    textFormControllerMaterno.dispose();
    textFormControllerNombre.dispose();
    textFormControllerNumInterior.dispose();
    textFormControllerPaterno.dispose();
    textFormControllerTelefono.dispose();
    super.dispose();
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

  Widget editingDelivery() {
    return Column(children: <Widget>[
      Form(
        key: _formKey,
        autovalidate: false,
        child: Theme(
          data: ThemeData(
            primaryColor: Colors.transparent,
            hintColor: Colors.transparent,
          ),
          child: Column(
            children: <Widget>[
              Padding(
                 padding: EdgeInsets.only(top: 0, bottom: 0),
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
                      controller: textFormControllerNombre,
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
                      maxLength: 25,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        WhitelistingTextInputFormatter(FormsTextFormatters.regexNames()),
                      ],
                      //initialValue: personalData.nombre,
                      onSaved: (input) {
                        personalData.nombre = input;
                      },
                      validator: FormsTextValidators.validateTextWithoutEmoji,
                    ),
                  ],
                ),
              ),
              Padding(
                 padding: EdgeInsets.only(top: 0, bottom: 0),
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
                      controller: textFormControllerPaterno,
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
                      validator: FormsTextValidators.validateTextWithoutEmoji,
                      focusNode: _focusPaterno,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0, bottom: 0),
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
                      controller: textFormControllerMaterno,
                      style: TextStyle(
                        color: HexColor('#0D47A1'),
                        fontSize: 14,
                        fontFamily: 'Archivo'
                      ),
                      maxLength: 25,
                      decoration: InputDecoration(
                        // hintText: '(Opcional)',
                        // hintStyle: TextStyle(fontWeight: FontWeight.w300, color: HexColor('#212B36').withOpacity(0.5)),
                        filled: true,
                        fillColor: HexColor('#F0EFF4'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                        
                      ),
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
                 padding: EdgeInsets.only(top: 0, bottom: 0),
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
                      controller: textFormControllerDireccion,
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
                            controller: textFormControllerNumInterior,
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
                            controller: textFormControllerColonia,
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
                                        personalData.isocode = selected.isocode;
                                        // widget.address.estado = selected.isocode;
                                      });
                                    },
                                    onSaved: (val) {
                                      Estados selected = estados.firstWhere((estado) => estado.estado == val);
                                      personalData.estado = selected.estado;
                                      personalData.isocode = selected.isocode;
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
                            controller: textFormControllerCodigoPostal,
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
              // Padding(
              //   padding: EdgeInsets.only(top: 0, bottom: 8),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: <Widget>[
              //       Container(
              //         margin: EdgeInsets.only(bottom: 5),
              //         child: Text(
              //           'Apt/Suite  Detalles adicionales - opcional',
              //           textAlign: TextAlign.left,
              //           style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
              //         ),
              //       ),
              //       TextFormField(
              //         style: TextStyle(
              //           color: HexColor('#0D47A1'),
              //           fontSize: 14,
              //           fontFamily: 'Archivo'
              //         ),
              //         decoration: InputDecoration(
              //           filled: true,
              //           fillColor: HexColor('#F0EFF4'),
              //           border: OutlineInputBorder(
              //             borderRadius: new BorderRadius.only(
              //               bottomLeft: const Radius.circular(4.0),
              //   bottomRight: const Radius.circular(0.0),
              //   topLeft: const Radius.circular(4.0),
              //   topRight: const Radius.circular(0.0)),
              //           ),
              //           contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
              //           hintStyle: TextStyle(color: Colors.black, fontSize: 12),
              //         ),
              //         onSaved: (input) {
              //             dept = input;
              //         },
              //         inputFormatters: [
              //           WhitelistingTextInputFormatter(FormsTextFormatters.regexAddressElements()),
              //         ],
              //         keyboardType: TextInputType.number,
              //         textInputAction: TextInputAction.next,
              //         onFieldSubmitted: (v) {
              //           FocusScope.of(context).requestFocus(_focusDatosEntrega);
              //         },
              //         // validator: _validateNotEmpty,
              //         focusNode: _focusApt,
              //         // validator: _validateNotEmpty,
              //       ),
              //     ],
              //   ),
              // ),
              Padding(
                padding: EdgeInsets.only(top: 0, bottom: 0),
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
                        color: DataUI.textDisabled,
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
                      initialValue: personalData.email,
                      onSaved: (input) {
                        personalData.email = input;
                      },
                      inputFormatters: [
                        // WhitelistingTextInputFormatter(
                        //   RegExp("[a-z]|[0-9]|[\@]|[\.]"),
                        // ),
                        LengthLimitingTextInputFormatter(100),
                      ],
                      enabled: false,
                      enableInteractiveSelection: false,
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
                      controller: textFormControllerTelefono,
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
                      validator: _validatePhoneLength,
                      
                      textInputAction: TextInputAction.done,
                      focusNode: _focusTelefono,
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
          disabledColor: HexColor('#F57C00').withOpacity(0.5),
          padding: EdgeInsets.symmetric(vertical: 5),
          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
          onPressed: !loadingAddressToHybris ? () {
            submitForm();
          } : null,
          color: HexColor('#F57C00'),
          child: !loadingAddressToHybris ? Text(
            'Confirmar datos personales',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontFamily: 'Archivo',
              fontSize: 14,
              letterSpacing: 0.25,
              color: HexColor('#FFFFFF'),
            ),
          ) : CircularProgressIndicator(),
        ),
      )
    ]);
  }

  Widget savigDelivery() {
    return Column(children: <Widget>[
      Container(
        alignment: Alignment.centerRight,
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
                  onPressed: () async{
                    await loadWidget();
                    await _getStoredPersonalData();
                    setState(() {
                      editing = true;
                      hideForm = selectedAddressId != null;
                    });
                    widget.callbackForm(true);
                    //widget.callback(false, null);
                  },
                  child: Text(
                    "Editar",
                    style: TextStyle(
                      color: DataUI.chedrauiBlueColor
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            )),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: dataAddresses,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Container(child: Text("Error obteniendo las direcciones del usuario"));
            } else {
              return Container(
                padding: EdgeInsets.only(left: 0, top: 5, bottom: 5, right: 0),
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    /*
                    Container(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      child: hideForm ? Container(
                        child: FlatButton(
                          child: Text('+ Agregar nueva dirección', style:  TextStyle(color: DataUI.chedrauiBlueColor ),),
                          onPressed: (){
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Cambio de dirección"),
                                  content: Text("Si cambias tu dirección de entrega, algunos de tus productos podrían desaparecer de tu compra. ¿Deseas continuar?"),
                                  actions: <Widget>[
                                    FlatButton(
                                      onPressed: () {
                                        setState(() {
                                          hideForm = false;
                                        });
                                        clearAddress();
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
                                  ],
                                );
                              }
                            );
                          },
                        ),
                      ) : editing? editingDelivery() : 
                      savigDelivery(),
                    ),
                    */
                    !editing ? savigDelivery() :
                    editing && !hideForm ? Container(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      child:  editingDelivery()
                        //savigDelivery(),
                    ) : SizedBox(height: 0,),
                    editing && addresses.length > 0 ? Column(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 25),
                              padding: EdgeInsets.only(top: 20, bottom: 5),
                              child: Row(
                                children: <Widget>[
                                  Flexible(
                                    flex: 1,
                                    child: Text(
                                      "O selecciona una dirección guardada...",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Archivo'
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              color: Colors.grey,
                            ),
                            shownAddresses != null
                                ? ListView.separated(
                                    physics: ClampingScrollPhysics(),
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    separatorBuilder: (context, index) {
                                      return Divider(color: Colors.grey);
                                    },
                                    //itemCount: addresses != null ? totalDisplay : 0,
                                    itemCount: shownAddresses != null ? shownAddresses.length : 0,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Flexible(
                                                  flex: 4,
                                                  fit: FlexFit.tight,
                                                  child: RadioListTile<String>(
                                                    activeColor: Colors.black,
                                                    value: shownAddresses[index]['id'],
                                                    onChanged: (newValue) {
                                                      if(!addressChanged){
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return AlertDialog(
                                                              title: Text("Cambio de dirección"),
                                                              content: Text("Si cambias tu dirección de entrega, algunos de tus productos podrían desaparecer de tu compra. ¿Deseas continuar?"),
                                                              actions: <Widget>[
                                                                FlatButton(
                                                                  onPressed: () {
                                                                    widget.callbackForm(true);
                                                                    setState(() {
                                                                      addressChanged = true;
                                                                      hideForm = true;
                                                                    });
                                                                    Navigator.pop(context);
                                                                    setNewAddressOnForm(newValue);
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
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      } else {
                                                        setState(() {
                                                          hideForm = true;
                                                        });
                                                        widget.callbackForm(true);
                                                        setNewAddressOnForm(newValue);
                                                      }
                                                    },
                                                    groupValue: currentAddressId,
                                                    title: Text(
                                                      "${shownAddresses[index]['firstName']} ${shownAddresses[index]['lastName']}\n${shownAddresses[index]['formattedAddress']}",
                                                      style: TextStyle(color: HexColor('#454F5B'), fontSize: 12, fontFamily: 'Rubik', height: 1.2),
                                                    ),
                                                  )),
                                              Flexible(
                                                flex: 1,
                                                fit: FlexFit.tight,
                                                child: FlatButton(
                                                  textColor: DataUI.chedrauiBlueColor,
                                                  onPressed: () async {
                                                    Address a = Address.fromJson(shownAddresses[index]);
                                                    print(a);
                                                    final result = await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        settings: RouteSettings(name: DataUI.deliveryMethodRoute),
                                                        builder: (context) => EditAddressPage(address: a),
                                                      ),
                                                    );
                                                    if (result != null) {
                                                      setState(() {
                                                        dataAddresses = null;
                                                      });
                                                      await loadWidget(pastTotalDisplay: totalDisplay);
                                                    }
                                                  },
                                                  child: Text(
                                                    "Editar",
                                                  ),
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      );
                                    },
                                  )
                                : CircularProgressIndicator(),
                          ]
                        ),
                        Column(children: <Widget>[
                          Divider(
                            color: Colors.grey,
                          ),
                          remaining > 0
                              ? FlatButton(
                                  onPressed: loadMore,
                                  child: Text(
                                    'Cargar más Direcciones ($remaining)',
                                    style: TextStyle(fontFamily: 'Rubik', color: HexColor('#454F5B'), fontSize: 12, decoration: TextDecoration.underline),
                                  ),
                                )
                              : SizedBox(),
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
                        ])
                      ],
                    ) : SizedBox(height: 0,),
                  ],
                )
              );
            }
            break;
          default:
            return Container(
                padding: EdgeInsets.only(left: 15, top: 20, bottom: 20, right: 15),
                decoration: BoxDecoration(color: Colors.white),
                child: Center(
                  child: CircularProgressIndicator(),
                ));
            break;
        }
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
  }
}