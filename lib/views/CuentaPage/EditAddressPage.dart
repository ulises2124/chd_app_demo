import 'package:chd_app_demo/services/UserProfileServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/utils/addressData.dart';
import 'package:chd_app_demo/utils/input_formatters.dart';
import 'package:chd_app_demo/views/CuentaPage/CuentaPage.dart';
import 'package:chd_app_demo/views/DeliveryMethod/Estados.dart';
import 'package:chd_app_demo/views/DeliveryMethod/SelectedLocation.dart';
import 'package:chd_app_demo/views/MasterPage/MasterPage.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditAddressPage extends StatefulWidget {
  final Address address;
  EditAddressPage({
    Key key,
    this.address,
  }) : super(key: key);

  _EditAddressPageState createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  // SharedPreferences prefs;
  List<Estados> estados = [];
  bool _isLoading = false;
  // String mergeAddress;
  // Estados confirmacionEstado;

  final addresFormKey = GlobalKey<FormState>();
  bool _autoValidateAddressForm = false;
  // SelectedLocation confirmAddress;

  final _focusPaterno = FocusNode();
  final _focusMaterno = FocusNode();
  final _focusDireccion = FocusNode();
  final _focusNumeroInterior = FocusNode();
  final _focusColonia = FocusNode();
  final _focusEstado = FocusNode();
  final _focusCodigoPostal = FocusNode();
  final _focusDatosEntrega = FocusNode();
  final _focusTelefono = FocusNode();

  @override
  void initState() {
    _initializeEstados();
    // confirmAddress = widget.completeAddress;
    // mergeAddress = widget.address.route.length > 0 ? widget.address.route + ' ' : '';
    // mergeAddress += widget.address.streetNumber.length > 0 ? widget.address.streetNumber + ' ' : '';
    // mergeAddress += (widget.address.sublocality.length > 0 ? widget.address.sublocality : '');
    super.initState();
    // getPreferences();
  }

  // Future getPreferences() async {
  //   prefs = await SharedPreferences.getInstance();
  // }

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
            'Editar Dirección',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 28,
              color: DataUI.textOpaqueStrong,
            ),
          ),
        ),
        body: AnimatedCrossFade(
          sizeCurve: Curves.easeInOut,
          duration: const Duration(milliseconds: 280),
          crossFadeState: _isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),
          secondChild: GestureDetector(
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
                                  widget.address.firstName = input;
                                },
                                initialValue: widget.address.firstName,
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
                                  widget.address.lastName = input;
                                },
                                initialValue: widget.address.lastName,
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
                                  widget.address.secondLastName = input;
                                },
                                initialValue: widget.address.secondLastName,
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
                                  widget.address.line1 = input;
                                },
                                initialValue: widget.address.line1,
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
                                      initialValue: widget.address.line2,
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
                                        widget.address.line2 = input;
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
                                      initialValue: widget.address.town,
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
                                        widget.address.town = input;
                                      },
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (v) {
                                        FocusScope.of(context).requestFocus(_focusTelefono);
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

                        // Row(
                        //   children: <Widget>[
                        //     Expanded(
                        //       flex: 4,
                        //       child: Padding(
                        //         padding: EdgeInsets.only(top: 8, bottom: 8),
                        //         child: TextFormField(
                        //           initialValue: widget.address.numInterior,
                        //           decoration: InputDecoration(
                        //             border: OutlineInputBorder(),
                        //             contentPadding: const EdgeInsets.only(
                        //                 top: 12,
                        //                 bottom: 12,
                        //                 left: 6,
                        //                 right: 6
                        //                 ),
                        //             hintText: 'Número Interior',
                        //             hintStyle: TextStyle(
                        //               color: Colors.black,
                        //               fontSize: 12
                        //             ),
                        //           ),
                        //           onSaved: (input) {
                        //             widget.address.numInterior = input;
                        //           },
                        //           textInputAction: TextInputAction.next,
                        //           onFieldSubmitted: (v) {
                        //             FocusScope.of(context).requestFocus(_focusColonia);
                        //           },
                        //           // validator: _validateNotEmpty,
                        //           focusNode: _focusNumeroInterior,
                        //         ),
                        //       ),
                        //     ),
                        //     Spacer(), // Defaults to a flex of one.
                        //     Expanded(
                        //       // flex: 6,
                        //       child: Padding(
                        //         padding: EdgeInsets.only(top: 8, bottom: 8),
                        //         child: TextFormField(
                        //           initialValue: widget.address.locality,
                        //           decoration: InputDecoration(
                        //             border: OutlineInputBorder(),
                        //             contentPadding: const EdgeInsets.only(
                        //                 top: 12,
                        //                 bottom: 12,
                        //                 left: 6,
                        //                 right: 6
                        //                 ),
                        //             hintText: '* Colonia',
                        //             hintStyle: TextStyle(
                        //               color: Colors.black,
                        //               fontSize: 12
                        //             ),
                        //           ),
                        //           onSaved: (input) {
                        //             widget.address.locality = input;
                        //           },
                        //           validator: _validateNotEmpty,
                        //           textInputAction: TextInputAction.next,
                        //           onFieldSubmitted: (v) {
                        //             FocusScope.of(context).requestFocus(_focusCodigoPostal);
                        //           },
                        //           focusNode: _focusColonia,
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
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
                                            value: widget.address.regionname,
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
                                                widget.address.regionname = val;
                                              });
                                              setState(() {
                                                Estados selected = estados.firstWhere((estado) => estado.estado == val);
                                                print(selected.isocode);
                                                // widget.address.estado = selected.isocode;
                                              });
                                            },
                                            onSaved: (val) {
                                              Estados selected = estados.firstWhere((estado) => estado.estado == val);
                                              print(selected.isocode);
                                              widget.address.regionisocode = selected.isocode;
                                              widget.address.regionisocodeShort = selected.isocode.replaceAll('MX-', '');
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
                                      initialValue: widget.address.postalCode,
                                      enabled: false,
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
                                        widget.address.postalCode = input;
                                      },
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (v) {
                                        FocusScope.of(context).requestFocus(_focusDatosEntrega);
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
                                initialValue: widget.address.phone,
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
                                  widget.address.phone = input;
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
                                padding: const EdgeInsets.only(top: 16),
                                child: FlatButton(
                                  disabledColor: HexColor('#F57C00').withOpacity(0.5),
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                                  color: DataUI.btnbuy,
                                  child: Text(
                                    'Actualizar dirección de envío',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () {
                                    _submitAddressForm();
                                  },
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
      ),
    );
  }

  Future _submitAddressForm() async {
    setState(() {
      _autoValidateAddressForm = true;
    });
    if (addresFormKey.currentState.validate()) {
      addresFormKey.currentState.save();
      setState(() {
        _isLoading = true;
      });
      try {
        if (widget.address.id != null) {
          await UserProfileServices.hybrisEditUserAddress(widget.address).then((response) {
            if (response.statusCode == 200) {
              _showConfirmationDialog(true);
            } else {
              setState(() {
                _isLoading = false;
              });
              _showValidationDialog();
              // print(response.);
              // _showValidationDialog(response['errors'][1]['message'].toString());
            }
          });
        } else {
          await UserProfileServices.hybrisAddUserAddress(widget.address.toJSON()).then((response) {
            if (response.statusCode == 201) {
              _showConfirmationDialog(true);
            } else {
              setState(() {
                _isLoading = false;
              });
              _showValidationDialog();
              // print(response.);
              // _showValidationDialog(response['errors'][1]['message'].toString());
            }
          });
        }
      } catch (e) {
        print(e);
        _showConfirmationDialog(false);
      }
    }
  }

  void _showValidationDialog() {
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

  void _showConfirmationDialog(bool success) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            success ? 'Listo!' : 'Lo sentimos',
          ),
          content: Text(
            success ? 'La dirección se ha actualizado correctamente' : 'Por favor intentar la operación más tarde',
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
                  // Navigator.pop(context);
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (BuildContext context) => MasterPage(
                  //           initialWidget: CuentaPage(),
                  //         ),
                  //   ),
                  // );
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

  String _validateCP(String value) {
    if (value.length < 5) {
      return 'Número inválido';
    }
    return null;
  }

  String _validateLenght(String value) {
    if (value.length < 10) {
      return 'Número inválido';
    }
    return null;
  }

  String _validateNotEmpty(String value) {
    if (value.isEmpty) {
      return 'Requerido';
    }
    return null;
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
