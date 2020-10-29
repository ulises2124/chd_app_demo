import 'dart:async';
import 'package:chd_app_demo/redux/actions/LocationActions.dart';
import 'package:chd_app_demo/redux/actions/SessionActions.dart';
import 'package:chd_app_demo/redux/models/AppState.dart';
import 'package:chd_app_demo/services/UserProfileServices.dart';
import 'package:chd_app_demo/services/AuthServices.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/utils/addressData.dart';
import 'package:chd_app_demo/utils/input_formatters.dart';
import 'package:chd_app_demo/utils/userData.dart';
import 'package:chd_app_demo/views/CuentaPage/EditAddressPage.dart';
import 'package:chd_app_demo/views/CuentaPage/SelectInterest.dart';
import 'package:chd_app_demo/views/DeliveryMethod/DeliveryMethodPage.dart';
import 'package:chd_app_demo/views/DeliveryMethod/SelectedLocation.dart';
import 'package:chd_app_demo/views/Errors/GenericErrorPage/GenericErrorPage.dart';
import 'package:chd_app_demo/views/Errors/NetworkErrorPage/NetworkErrorPage.dart';
import 'package:chd_app_demo/views/LoginPage/RecoveryPasswordPage.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class CuentaPage extends StatefulWidget {
  final int selectedTab;
  CuentaPage({
    Key key,
    this.selectedTab,
  }) : super(key: key);

  _CuentaPageState createState() => _CuentaPageState();
}

class _CuentaPageState extends State<CuentaPage> {
  List addresses;
  bool _isUpdatingAddresses = false;
  Address editAddress = Address();

  SharedPreferences prefs;
  final userDataFormKey = GlobalKey<FormState>();
  ScrollController _scrollController = ScrollController();

  final _correoField = TextEditingController();
  final _nombreField = TextEditingController();
  final _apellidoPaternoField = TextEditingController();
  final _apellidoMaternoField = TextEditingController();
  final _telefonoCelularField = TextEditingController();
  final _telefonoCasaField = TextEditingController();

  final _nombreFieldFocus = FocusNode();
  final _apellidoPaternoFieldFocus = FocusNode();
  final _apellidoMaternoFieldFocus = FocusNode();
  final _telefonoCelularFieldFocus = FocusNode();
  final _telefonoCasaFieldFocus = FocusNode();

  bool _isUpdatinfg = false;
  bool _autoValidateForm = false;
  bool _isEditingBirthday = false;
  bool _isEditingFields = false;
  bool _isEditingGender = false;
  bool _reverseScroll = false;
  bool _isBirthdaySet = false;
  bool _isGenderSet = false;
  bool _isMale = true;
  int _selectedTab = 1;
  String _formatterDate = '';
  UserProfile _userInfo = UserProfile();
  DateTime _updateBirthday;

  Future<dynamic> data;

  Future addressesResponse;

  @override
  void initState() {
    getAddressBoook();
    getPreferences();
    if (widget.selectedTab != null) {
      setState(() {
        _selectedTab = widget.selectedTab;
      });
    }
    data = AuthServices.getHybrisUserInfo().then((userInfo) async {
      _userInfo = UserProfile();
      _userInfo.clienteID = userInfo['cliente']['clienteId'] ?? '';
      _userInfo.nombre = userInfo['cliente']['nombre'] ?? '';
      _userInfo.apellidoPaterno = userInfo['cliente']['apellidoPaterno'] ?? '';
      _userInfo.apellidoMaterno = userInfo['cliente']['apellidoMaterno'] ?? '';
      _userInfo.telefonoCelular = userInfo['cliente']['telefonoCelular'] ?? '';
      _userInfo.telefonoCasa = userInfo['cliente']['telefonoCasa'] ?? '';

      _userInfo.genero = userInfo['cliente']['genero'] ?? null;
      _isGenderSet = _userInfo.genero != null ? true : false;
      if (_isGenderSet) {
        _isMale = _userInfo.genero.toString() == 'M' ? true : false;
      } else {
        _isMale = true;
      }

      _userInfo.fechaNacimiento = userInfo['cliente']['fechaNacimiento'] != null ? DateTime.parse(userInfo['cliente']['fechaNacimiento'].replaceAll('/', '-')) : null;
      _updateBirthday = _userInfo.fechaNacimiento != null ? _userInfo.fechaNacimiento : DateTime.now();
      _isBirthdaySet = _updateBirthday.difference(DateTime.now()).inDays == 0 ? false : true;
      _formatterDate = DateFormat('dd/MM/yyyy').format(_updateBirthday);

      prefs = await SharedPreferences.getInstance();
      _userInfo.correo = prefs.getString('email') ?? '';
      // _userInfo.correo = userInfo['cliente']['correos'][0]['direccion'].toString().toLowerCase() ?? '';

      _correoField.text = _userInfo.correo;
      _nombreField.text = _userInfo.nombre.toLowerCase();
      _apellidoPaternoField.text = _userInfo.apellidoPaterno.toLowerCase();
      _apellidoMaternoField.text = _userInfo.apellidoMaterno.toLowerCase();
      _telefonoCelularField.text = _userInfo.telefonoCelular;
      _telefonoCasaField.text = _userInfo.telefonoCasa;

      // _printUserValues();
      return userInfo;
    });
    super.initState();
  }

  void _resetFormFields() {
    setState(() {
      _correoField.text = _userInfo.correo.toLowerCase();
      // _correoField.text = 'alerodriguez162';
      _nombreField.text = _userInfo.nombre.toLowerCase();
      _apellidoPaternoField.text = _userInfo.apellidoPaterno.toLowerCase();
      _apellidoMaternoField.text = _userInfo.apellidoMaterno.toLowerCase();
      _telefonoCelularField.text = _userInfo.telefonoCelular;
      _telefonoCasaField.text = _userInfo.telefonoCasa;
      _updateBirthday = _userInfo.fechaNacimiento != null ? _userInfo.fechaNacimiento : DateTime.now();
      _isBirthdaySet = _updateBirthday.difference(DateTime.now()).inDays == 0 ? false : true;
      _formatterDate = DateFormat('dd/MM/yyyy').format(_updateBirthday);

      _isEditingFields = false;
      _isEditingBirthday = false;
      _isEditingGender = false;
    });
  }

  void _printUserValues() {
    print('_isEditingFields:                    ' + _isEditingFields.toString());
    print('_isEditingBirthday:                  ' + _isEditingBirthday.toString());
    print('_isEditingGender:                    ' + _isEditingGender.toString());
    print('----------------------------------------------');
    print('\n');
    print('clienteID:             ' + _userInfo.clienteID);
    print('nombre:                ' + _userInfo.nombre);
    print('apellidoPaterno:       ' + _userInfo.apellidoPaterno);
    print('apellidoMaterno:       ' + _userInfo.apellidoMaterno.toString());
    print('genero:                ' + _userInfo.genero.toString());
    print('correo:                ' + _userInfo.correo);
    print('telefonoCelular:       ' + _userInfo.telefonoCelular.toString());
    print('telefonoCasa:          ' + _userInfo.telefonoCasa.toString());
    print('fechaNacimiento:        ' + _userInfo.fechaNacimiento.toString());
  }

  Future _submitUserDataForm() async {
    if (_isEditingFields == true) {
      setState(() {
        _autoValidateForm = true;
      });
      if (userDataFormKey.currentState.validate()) {
        userDataFormKey.currentState.save();
        _userInfo.fechaNacimiento = _isEditingBirthday ? _updateBirthday : _userInfo.fechaNacimiento;
        if (_isEditingGender) {
          _userInfo.genero = _isMale ? 'M' : 'F';
        }
        setState(() {
          _isEditingFields = false;
          _isEditingGender = false;
        });

        await updateUserData();
      } else {
        // print('------ INVALID FIELDS-------');
      }
    } else {
      if (_isEditingBirthday && _isEditingGender) {
        _userInfo.fechaNacimiento = _updateBirthday;
        _userInfo.genero = _isMale ? 'M' : 'F';
        setState(() {
          _isEditingBirthday = false;
          _isEditingGender = false;
        });
        await updateUserData();
        // print('------_isEditingBirthday  && _isEditingGender true-------');
      } else if (_isEditingBirthday) {
        _userInfo.fechaNacimiento = _updateBirthday;
        setState(() {
          _isEditingBirthday = false;
        });
        await updateUserData();
        // print('------_isEditingBirthday  true-------');
      } else if (_isEditingGender) {
        _userInfo.genero = _isMale ? 'M' : 'F';
        setState(() {
          _isEditingGender = false;
        });
        await updateUserData();
        // print('------_isEditingGender  true-------');
      }
    }
  }

  Future updateUserData() async {
    // _printUserValues();
    setState(() {
      _isUpdatinfg = true;
    });
    var result = await UserProfileServices.clientescrmEditUserInfo(_userInfo);
    setState(() {
      _isUpdatinfg = false;
    });
    if (result != null && result['statusOperation']['code'] == 0) {
      prefs.setString('account-userName', _userInfo.nombre);
      _showConfirmationDialog(true);
    } else {
      _showConfirmationDialog(false);
    }
  }

  void _showConfirmationDialog(bool success) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            success ? 'Listo!' : 'Lo sentimos',
          ),
          content: Text(
            success ? 'Los datos se han actualizado correctamente' : 'Por favor intentar la operación más tarde',
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
                  Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
                  Navigator.pushNamed(context, DataUI.cuentaRoute);
                  // Navigator.pop(context);
                  // Navigator.of(context).pushAndRemoveUntil(
                  //   MaterialPageRoute(
                  //     builder: (BuildContext context) => MasterPage(
                  //       initialWidget: MenuItem(
                  //         id: 'cuenta',
                  //         title: ' ',
                  //         screen: CuentaPage(),
                  //         color: DataUI.backgroundColor2,
                  //         textColor: Colors.black,
                  //       ),
                  //     ),
                  //   ),
                  //   (Route<dynamic> route) => false,
                  // );
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

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return WidgetContainer(
      Scaffold(
        key: _scaffoldKey,
        backgroundColor: HexColor('#F4F4F4'),
        appBar: GradientAppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context, 'reload');
                },
              );
            },
          ),
          iconTheme: IconThemeData(
            color: DataUI.primaryText, //change your color here
          ),
          title: Text(
            ' ',
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
        body: FutureBuilder(
          future: data,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
                break;
              case ConnectionState.active:
                break;
              case ConnectionState.none:
                break;
              case ConnectionState.done:
                if (snapshot.hasError) {
                  if (snapshot.error.toString().contains('No Internet connection')) {
                          return NetworkErrorPage(
                            showGoHomeButton: false,
                          );
                        } else {
                          return NetworkErrorPage(
                            errorMessage: 'Ha ocurrido un error, por favor inténtalo más tarde',
                            showGoHomeButton: true,
                          );
                        }
                } else if (snapshot.hasData && snapshot.data != null) {
                  return Scrollbar(
                    child: SingleChildScrollView(
                      reverse: _reverseScroll,
                      controller: _scrollController,
                      child: AnimatedCrossFade(
                        sizeCurve: Curves.easeInOut,
                        duration: const Duration(milliseconds: 280),
                        crossFadeState: _isUpdatinfg ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                        firstChild: Container(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                        secondChild: Container(
                          // color: Colors.white,
                          child: Column(
                            children: <Widget>[
                              Container(
                                color: Colors.white,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Container(
                                      child: IconButton(
                                        onPressed: null,
                                        icon: Icon(
                                          Icons.fiber_manual_record,
                                          color: Colors.white.withAlpha(1),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Icon(
                                        Icons.person_pin,
                                        size: 80,
                                        color: DataUI.chedrauiColor,
                                      ),
                                    ),
                                    Container(
                                      color: Colors.white,
                                      child: _selectedTab == 1
                                          ? _isEditingFields
                                              ? IconButton(
                                                  onPressed: () {
                                                    _resetFormFields();
                                                  },
                                                  icon: Icon(Icons.close),
                                                )
                                              : IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _isEditingFields = true;
                                                    });
                                                  },
                                                  icon: Icon(Icons.edit),
                                                )
                                          : IconButton(
                                              onPressed: () {
                                                // setState(() {
                                                //   _isEditingFields = true;
                                                // });
                                              },
                                              icon: Icon(
                                                Icons.edit,
                                                color: Colors.transparent,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                color: Colors.white,
                                child: Column(
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.only(left: 10, right: 10, bottom: 0, top: 8),
                                          child: Text(
                                            _userInfo.nombre + ' ' + _userInfo.apellidoPaterno + ' ' + _userInfo.apellidoMaterno,
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: HexColor("#212B36"),
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        FlatButton(
                                          onPressed: () {
                                            _storeLogOut();
                                          },
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          child: Text(
                                            "Cerrar Sesión",
                                            style: TextStyle(
                                              color: DataUI.chedrauiBlueColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Column(
                                          children: <Widget>[
                                            FlatButton(
                                              onPressed: () {
                                                setState(() {
                                                  _selectedTab = 1;
                                                });
                                              },
                                              child: Text(
                                                'DETALLES',
                                                style: TextStyle(
                                                  fontFamily: 'Archivo',
                                                  fontSize: 12,
                                                  letterSpacing: 2.0,
                                                  color: _selectedTab == 1 ? DataUI.chedrauiBlueColor : DataUI.textOpaqueMedium,
                                                  fontWeight: _selectedTab == 1 ? FontWeight.w600 : FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: 2,
                                              margin: EdgeInsets.only(bottom: 7),
                                              width: 77,
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(color: _selectedTab == 1 ? DataUI.chedrauiBlueColor : Colors.transparent, width: 1.0),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: <Widget>[
                                            FlatButton(
                                              onPressed: () {
                                                setState(() {
                                                  _selectedTab = 2;
                                                });
                                              },
                                              child: Text(
                                                'DIRECCIONES',
                                                style: TextStyle(
                                                  fontFamily: 'Archivo',
                                                  fontSize: 12,
                                                  letterSpacing: 2.0,
                                                  color: _selectedTab == 2 ? DataUI.chedrauiBlueColor : DataUI.textOpaqueMedium,
                                                  fontWeight: _selectedTab == 2 ? FontWeight.w600 : FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: 2,
                                              margin: EdgeInsets.only(bottom: 7),
                                              width: 77,
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(color: _selectedTab == 2 ? DataUI.chedrauiBlueColor : Colors.transparent, width: 1.0),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: <Widget>[
                                            FlatButton(
                                              onPressed: () {
                                                setState(() {
                                                  _selectedTab = 3;
                                                });
                                              },
                                              child: Text(
                                                'INTERESES',
                                                style: TextStyle(
                                                  fontFamily: 'Archivo',
                                                  fontSize: 12,
                                                  letterSpacing: 2.0,
                                                  color: _selectedTab == 3 ? DataUI.chedrauiBlueColor : DataUI.textOpaqueMedium,
                                                  fontWeight: _selectedTab == 3 ? FontWeight.w600 : FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: 2,
                                              margin: EdgeInsets.only(bottom: 7),
                                              width: 77,
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(color: _selectedTab == 3 ? DataUI.chedrauiBlueColor : Colors.transparent, width: 1.0),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                color: HexColor('#F4F4F4'),
                                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 30),
                                child: _generateTabBody(),
                              ),
                              AnimatedCrossFade(
                                sizeCurve: Curves.easeInOut,
                                duration: const Duration(milliseconds: 280),
                                firstChild: Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: FlatButton(
                                          padding: EdgeInsets.all(15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          color: DataUI.btnbuy,
                                          child: Text(
                                            'Guardar Cambios',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          onPressed: () {
                                            _submitUserDataForm();
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                secondChild: SizedBox(height: 0),
                                crossFadeState: _isEditingFields || _isEditingGender || _isEditingBirthday ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                              ),
                              _selectedTab == 1
                                  ? Container(
                                      color: HexColor('#F4F4F4'),
                                      margin: EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 4),
                                      padding: EdgeInsets.all(10),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => RecoveryPasswordPage(
                                                button: false,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          color: HexColor('#F4F4F4'),
                                          margin: EdgeInsets.symmetric(vertical: 5),
                                          child: Text(
                                            'Recuperar Contraseña',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: DataUI.chedrauiBlueColor,
                                              fontFamily: "Archivo",
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox()
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return NetworkErrorPage(
                    errorMessage: 'Ha ocurrido un error, por favor inténtalo más tarde',
                    showGoHomeButton: true,
                  );
                }
                break;
            }
          },
        ),
      ),
    );
  }

  Widget _generateTabBody() {
    if (_selectedTab == 1) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0xcc000000).withOpacity(0.1),
              offset: Offset(0.0, 5.0),
              blurRadius: 5.0,
            ),
          ],
        ),
        child: Form(
          key: userDataFormKey,
          autovalidate: _autoValidateForm,
          child: Theme(
            data: ThemeData(
              primaryColor: Colors.transparent,
              hintColor: Colors.transparent,
              disabledColor: DataUI.chedrauiBlueColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AnimatedCrossFade(
                  sizeCurve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 280),
                  firstChild: Container(
                    margin: EdgeInsets.only(top: 15, bottom: 0, left: 15, right: 15),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: Text(
                            'Nombre',
                            style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                          ),
                        ),
                        TextFormField(
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Archivo",
                          ),
                          controller: _nombreField,
                          focusNode: _nombreFieldFocus,
                          enabled: _isEditingFields,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: HexColor('#F0EFF4'),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            counterText: "",
                            contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 6, right: 6),
                            hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(100),
                            WhitelistingTextInputFormatter(
                              FormsTextValidators.commonPersonName,
                            ),
                          ],
                          onFieldSubmitted: (v) {
                            FocusScope.of(context).requestFocus(_apellidoPaternoFieldFocus);
                          },
                          textInputAction: TextInputAction.next,
                          onSaved: (input) {
                            _userInfo.nombre = input;
                          },
                          validator: FormsTextValidators.validateEmptyName,
                        ),
                      ],
                    ),
                  ),
                  secondChild: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 4),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Email",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: DataUI.chedrauiBlueColor,
                                  fontFamily: "Archivo",
                                ),
                              ),
                              Text(
                                _correoField.text != null && _correoField.text.length > 0 ? _correoField.text : '',
                                style: TextStyle(
                                  color: HexColor("#212B36"),
                                  fontFamily: "Archivo",
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          )),
                      Divider(color: HexColor('#DFE3E8'))
                    ],
                  ),
                  crossFadeState: _isEditingFields ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                ),
                AnimatedCrossFade(
                  sizeCurve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 280),
                  firstChild: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: Text(
                            'Apellido paterno',
                            style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                          ),
                        ),
                        Container(
                          // margin: EdgeInsets.only(top: 5, bottom: 5, left: 4, right: 4),
                          child: TextFormField(
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Archivo",
                            ),
                            controller: _apellidoPaternoField,
                            focusNode: _apellidoPaternoFieldFocus,
                            enabled: _isEditingFields,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: HexColor('#F0EFF4'),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              counterText: "",
                              contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 6, right: 6),
                              hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                            ),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(100),
                              WhitelistingTextInputFormatter(
                                FormsTextValidators.commonPersonName,
                              ),
                            ],
                            onFieldSubmitted: (v) {
                              FocusScope.of(context).requestFocus(_apellidoMaternoFieldFocus);
                            },
                            textInputAction: TextInputAction.next,
                            onSaved: (input) {
                              _userInfo.apellidoPaterno = input;
                            },
                            validator: FormsTextValidators.validateEmptyName,
                          ),
                        ),
                      ],
                    ),
                  ),
                  secondChild: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 4),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Cumpleaños",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: DataUI.chedrauiBlueColor,
                                  fontFamily: "Archivo",
                                ),
                              ),
                              GestureDetector(
                                // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                // padding: EdgeInsets.all(0),
                                onTap: () {
                                  DatePicker.showDatePicker(
                                    context,
                                    locale: LocaleType.es,
                                    showTitleActions: true,
                                    minTime: DateTime(DateTime.now().year - 100, DateTime.now().month, DateTime.now().day),
                                    maxTime: DateTime(DateTime.now().year - 18, DateTime.now().month, DateTime.now().day),
                                    currentTime: _isBirthdaySet ? _updateBirthday : _userInfo.fechaNacimiento,
                                    onChanged: (date) {
                                      print('change $date');
                                    },
                                    onConfirm: (date) {
                                      // DateTime birthDate = date;
                                      // DateTime currentDate = DateTime.now();
                                      // int age = currentDate.year - birthDate.year;
                                      // int month1 = currentDate.month;
                                      // int month2 = birthDate.month;
                                      // if (month2 > month1) {
                                      //   age--;
                                      // } else if (month1 == month2) {
                                      //   int day1 = currentDate.day;
                                      //   int day2 = birthDate.day;
                                      //   if (day2 > day1) {
                                      //     age--;
                                      //   }
                                      // }
                                      // print(age.toString());

                                      // if (age >= 18) {
                                      setState(() {
                                        _reverseScroll = true;
                                        _isEditingBirthday = true;
                                        _isBirthdaySet = true;
                                        _updateBirthday = date;
                                        _formatterDate = DateFormat('dd/MM/yyyy').format(_updateBirthday);
                                      });
                                      _scrollController.animateTo(
                                        0.0,
                                        curve: Curves.easeOut,
                                        duration: const Duration(milliseconds: 300),
                                      );
                                      print('confirm $_updateBirthday.toString()');
                                      print('confirm $_formatterDate');
                                      // } else {
                                      //   return false;
                                      // }
                                    },
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  child: _isBirthdaySet
                                      ? Text(
                                          _formatterDate,
                                          style: TextStyle(
                                            color: HexColor("#212B36"),
                                            fontFamily: "Archivo",
                                            fontSize: 14,
                                          ),
                                        )
                                      : Text(
                                          'Agregar Cumpleaños',
                                          style: TextStyle(
                                            color: HexColor("#212B36"),
                                            fontFamily: "Archivo",
                                            fontSize: 14,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: HexColor('#DFE3E8'))
                      ],
                    ),
                  ),
                  crossFadeState: _isEditingFields ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                ),
                AnimatedCrossFade(
                  sizeCurve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 280),
                  firstChild: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: Text(
                            'Apellido materno',
                            style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                          ),
                        ),
                        Container(
                          // margin: EdgeInsets.only(top: 5, bottom: 5, left: 4, right: 4),
                          child: TextFormField(
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Archivo",
                            ),
                            controller: _apellidoMaternoField,
                            focusNode: _apellidoMaternoFieldFocus,
                            enabled: _isEditingFields,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: HexColor('#F0EFF4'),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              counterText: "",
                              contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 6, right: 6),
                              hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                            ),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(100),
                              WhitelistingTextInputFormatter(
                                FormsTextValidators.commonPersonName,
                              ),
                            ],
                            onFieldSubmitted: (v) {
                              FocusScope.of(context).requestFocus(_telefonoCelularFieldFocus);
                            },
                            textInputAction: TextInputAction.next,
                            onSaved: (input) {
                              _userInfo.apellidoMaterno = input;
                            },
                            validator: FormsTextValidators.validateEmptyName,
                          ),
                        ),
                      ],
                    ),
                  ),
                  secondChild: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 4),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Género",
                              style: TextStyle(
                                fontSize: 14,
                                color: DataUI.chedrauiBlueColor,
                                fontFamily: "Archivo",
                              ),
                            ),
                            _isEditingGender
                                ? Container(
                                    margin: EdgeInsets.only(top: 15),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.all(2.0),
                                              // child: RaisedButton(
                                              //   elevation: _isMale ? 1 : 0,
                                              //   onPressed: () {
                                              //     setState(() {
                                              //       _isMale = true;
                                              //     });
                                              //   },
                                              //   child: Text(
                                              //     'Masculino',
                                              //     style: _isMale ? TextStyle(color: Colors.black) : TextStyle(color: Colors.white),
                                              //   ),
                                              //   color: _isMale ? Colors.white : Colors.blueGrey.withOpacity(0.5),
                                              // ),
                                              child: OutlineButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _isMale = true;
                                                  });
                                                },
                                                padding: EdgeInsets.all(17),
                                                child: Text("Masculino"),
                                                borderSide: BorderSide(color: _isMale ? HexColor('#39B54A') : HexColor('#DFE3E8')),
                                                shape: new RoundedRectangleBorder(
                                                  borderRadius: new BorderRadius.circular(5.0),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(2.0),
                                              // child: RaisedButton(
                                              //   elevation: _isMale ? 0 : 1,
                                              //   onPressed: () {
                                              //     setState(() {
                                              //       _isMale = false;
                                              //     });
                                              //   },
                                              //   child: Text(
                                              //     'Femenino',
                                              //     style: _isMale ? TextStyle(color: Colors.white) : TextStyle(color: Colors.black),
                                              //   ),
                                              //   color: _isMale ? Colors.blueGrey.withOpacity(0.5) : Colors.white,
                                              // ),
                                              child: OutlineButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _isMale = false;
                                                  });
                                                },
                                                padding: EdgeInsets.all(17),
                                                child: Text("Femenino"),
                                                borderSide: BorderSide(color: _isMale ? HexColor('#DFE3E8') : HexColor('#39B54A')),
                                                shape: new RoundedRectangleBorder(
                                                  borderRadius: new BorderRadius.circular(5.0),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isEditingGender = true;
                                        _reverseScroll = true;
                                      });
                                      _scrollController.animateTo(
                                        0.0,
                                        curve: Curves.easeOut,
                                        duration: const Duration(milliseconds: 300),
                                      );
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(vertical: 5),
                                      child: _isGenderSet
                                          ? Text(
                                              _isMale ? 'Masculino' : 'Femenino',
                                              style: TextStyle(
                                                color: HexColor("#212B36"),
                                                fontFamily: "Archivo",
                                                fontSize: 14,
                                              ),
                                            )
                                          : Text(
                                              'Seleccionar Género',
                                              style: TextStyle(
                                                color: HexColor("#212B36"),
                                                fontFamily: "Archivo",
                                                fontSize: 14,
                                              ),
                                            ),
                                    )),
                          ],
                        ),
                      ),
                      Divider(color: HexColor('#DFE3E8'))
                    ],
                  ),
                  crossFadeState: _isEditingFields ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                ),
                AnimatedCrossFade(
                  sizeCurve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 280),
                  secondChild: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 4),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Teléfono Celular",
                              style: TextStyle(
                                fontSize: 14,
                                color: DataUI.chedrauiBlueColor,
                                fontFamily: "Archivo",
                              ),
                            ),
                            Text(
                              _telefonoCelularField.text != null && _telefonoCelularField.text.length > 0 ? _telefonoCelularField.text : '',
                              style: TextStyle(
                                color: HexColor("#212B36"),
                                fontFamily: "Archivo",
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(color: HexColor('#DFE3E8'))
                    ],
                  ),
                  firstChild: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: Text(
                                'Teléfono Celular',
                                style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                              ),
                            ),
                            Container(
                              // margin: EdgeInsets.only(top: 5, bottom: 5, left: 4, right: 4),
                              child: TextFormField(
                                keyboardType: TextInputType.phone,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Archivo",
                                ),
                                controller: _telefonoCelularField,
                                focusNode: _telefonoCelularFieldFocus,
                                enabled: _isEditingFields,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: HexColor('#F0EFF4'),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  counterText: "",
                                  contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 6, right: 6),
                                  hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                                ),
                                inputFormatters: <TextInputFormatter>[
                                  WhitelistingTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                onFieldSubmitted: (v) {
                                  FocusScope.of(context).requestFocus(_telefonoCasaFieldFocus);
                                },
                                textInputAction: TextInputAction.next,
                                onSaved: (input) {
                                  _userInfo.telefonoCelular = input;
                                },
                                validator: FormsTextValidators.validatePhone,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _isEditingFields ? SizedBox() : Divider(color: HexColor('#DFE3E8')),
                    ],
                  ),
                  crossFadeState: _isEditingFields ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                ),
                AnimatedCrossFade(
                  sizeCurve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 280),
                  secondChild: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 4),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Teléfono de Casa",
                              style: TextStyle(
                                fontSize: 14,
                                color: DataUI.chedrauiBlueColor,
                                fontFamily: "Archivo",
                              ),
                            ),
                            Text(
                              _telefonoCasaField.text != null && _telefonoCasaField.text.length > 0 ? _telefonoCasaField.text : '',
                              style: TextStyle(
                                color: HexColor("#212B36"),
                                fontFamily: "Archivo",
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  firstChild: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: Text(
                                'Teléfono de Casa',
                                style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                              ),
                            ),
                            Container(
                              // margin: EdgeInsets.only(top: 5, bottom: 5, left: 4, right: 4),
                              child: TextFormField(
                                keyboardType: TextInputType.phone,
                                controller: _telefonoCasaField,
                                focusNode: _telefonoCasaFieldFocus,
                                enabled: _isEditingFields,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: HexColor('#F0EFF4'),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  counterText: "",
                                  contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 6, right: 6),
                                  hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                                ),
                                inputFormatters: <TextInputFormatter>[
                                  WhitelistingTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                onFieldSubmitted: (v) {
                                  setState(() {
                                    _reverseScroll = true;
                                  });
                                  _scrollController.animateTo(
                                    0.0,
                                    curve: Curves.easeOut,
                                    duration: const Duration(milliseconds: 300),
                                  );
                                },
                                textInputAction: TextInputAction.done,
                                onSaved: (input) {
                                  _userInfo.telefonoCasa = input;
                                },
                                validator: FormsTextValidators.validatePhone,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _isEditingFields ? SizedBox() : Divider(color: HexColor('#DFE3E8')),
                    ],
                  ),
                  crossFadeState: _isEditingFields ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                ),
              ],
            ),
          ),
        ),
      );
    } else if (_selectedTab == 2) {
      return Container(
        margin: EdgeInsets.only(left: 12, right: 12),
        padding: EdgeInsets.only(top: 12, bottom: 12),
        // color: Colors.white,
        child: FutureBuilder(
          future: addressesResponse,
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
                if (snapshot.hasError) {
                  if (snapshot.error.toString().contains('No Internet connection')) {
                          return NetworkErrorPage(
                            showGoHomeButton: false,
                          );
                        } else {
                          return NetworkErrorPage(
                            errorMessage: 'Ha ocurrido un error, por favor inténtalo más tarde',
                            showGoHomeButton: true,
                          );
                        }
                } else if (snapshot.hasData && snapshot.data != null) {
                  return !_isUpdatingAddresses
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            AnimatedCrossFade(
                              sizeCurve: Curves.easeInOut,
                              duration: const Duration(milliseconds: 280),
                              crossFadeState: addresses == null ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                              firstChild: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              secondChild: addresses.length > 0 && addresses != null
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      physics: ClampingScrollPhysics(),
                                      itemCount: addresses == null ? 0 : addresses.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin: EdgeInsets.only(top: 8, left: 10, right: 10),
                                          padding: EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(Radius.circular(8)),
                                            // border: addresses[index]['activo']
                                            //     ? Border.all(
                                            //         color: DataUI.chedrauiColor,
                                            //         width: 3,
                                            //       )
                                            //     : Border.all(
                                            //         color: Colors.white,
                                            //         width: 0,
                                            //       ),
                                          ),
                                          child: Material(
                                            borderRadius: BorderRadius.all(Radius.circular(8)),
                                            color: Colors.transparent,
                                            child: InkResponse(
                                              containedInkWell: true,
                                              enableFeedback: true,
                                              onTap: () {
                                                _selectDeliveryAddress(addresses[index]);
                                              },
                                              splashColor: DataUI.chedrauiColor,
                                              child: Padding(
                                                padding: const EdgeInsets.all(2),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding: const EdgeInsets.only(bottom: 4.0),
                                                            child: Text(
                                                              addresses[index]["firstName"].toString() + ' ' + addresses[index]["lastName"].toString(),
                                                              style: TextStyle(
                                                                fontFamily: 'Archivo',
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            addresses[index]["formattedAddress"].toString(),
                                                            style: TextStyle(
                                                              fontFamily: 'Archivo',
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w400,
                                                              color: DataUI.textOpaque,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Column(
                                                      children: <Widget>[
                                                        IconButton(
                                                          splashColor: DataUI.chedrauiColor,
                                                          icon: Icon(
                                                            Icons.edit_location,
                                                            size: 34,
                                                            color: DataUI.chedrauiColor,
                                                          ),
                                                          onPressed: () {
                                                            _editAddress(addresses[index]);
                                                          },
                                                        ),
                                                        IconButton(
                                                          splashColor: DataUI.chedrauiColor,
                                                          icon: Icon(
                                                            Icons.delete,
                                                            size: 20,
                                                          ),
                                                          onPressed: () {
                                                            _showDeleteDialog(addresses[index]["id"]);
                                                          },
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      color: Colors.white,
                                      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                      child: Column(
                                        children: <Widget>[
                                          Center(
                                            child: NoUbicaciones(),
                                          ),
                                          Center(
                                            child: Text(
                                              'Agrega una direccion a tu cuenta presionando el boton de “Agregar Nueva Dirección."',
                                              style: TextStyle(color: HexColor('#454F5B'), fontFamily: 'Rubik', fontSize: 14),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10),
                                    child: FlatButton(
                                      padding: EdgeInsets.all(15),
                                      color: DataUI.btnbuy,
                                      child: Text(
                                        'Agregar Nueva Dirección',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            settings: RouteSettings(name: DataUI.deliveryMethodRoute),
                                            builder: (context) => DeliveryMethodPage(
                                              showStores: false,
                                              showConfirmationForm: true,
                                              fromAddressBook: true,
                                            ),
                                          ),
                                        );
                                        if (result == 'direcciones') {
                                          getAddressBoook();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                } else {
                  return NetworkErrorPage(
                    errorMessage: 'Ha ocurrido un error, por favor inténtalo más tarde',
                    showGoHomeButton: true,
                  );
                }
                break;
              default:
                return Container();
            }
          },
        ),
      );
    } else {
      return SelectInterest(clienteID: _userInfo.clienteID);
    }
  }

  Future<void> _storeLogOut() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      final store = StoreProvider.of<AppState>(context);
      store.dispatch(LogOut());
      Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
      // Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      print(e.toString());
    }
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

  void getAddressBoook() async {
    _isUpdatingAddresses = true;
    addressesResponse = UserProfileServices.hybrisGetUserAddress();
    var response = await addressesResponse;
    setState(() {
      addresses = response['addresses'];
      _isUpdatingAddresses = false;
      // for (var item in interest) {
      //   print(item['descripcion']);
      //   print(item['activo']);
      //   print('\n');
      // }
    });
  }

  Future getPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _deleteItem(String addressId) async {
    try {
      await UserProfileServices.hybrisDeletetUserAddress(addressId).then((response) {
        if (response.statusCode == 200) {
          getAddressBoook();
        } else {
          setState(() {
            _isUpdatingAddresses = false;
          });
        }
      });
    } catch (e) {
      print(e);
      Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
      Navigator.pushNamed(context, DataUI.cuentaRoute);
      // Navigator.of(context).pushAndRemoveUntil(
      //   MaterialPageRoute(
      //     builder: (BuildContext context) => MasterPage(
      //       initialWidget: MenuItem(
      //         id: 'cuenta',
      //         title: ' ',
      //         screen: CuentaPage(),
      //         color: DataUI.backgroundColor,
      //       ),
      //     ),
      //   ),
      //   (Route<dynamic> route) => false,
      // );
    }
  }

  void _selectDeliveryAddress(var address) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar Dirección'),
          content: Text(
            'Seleccionar como dirección de envio actual?',
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
                  "Cancelar",
                  style: TextStyle(
                    color: DataUI.chedrauiBlueColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: RaisedButton(
                color: DataUI.chedrauiBlueColor,
                onPressed: () async {
                  print(address);

                  SelectedLocation selectedAddress = SelectedLocation();
                  selectedAddress.isLocationSet = true;
                  selectedAddress.isPickup = false;
                  selectedAddress.userName = address['firstName'];
                  selectedAddress.userLastName = address['lastName'];
                  selectedAddress.direccion = address['line1'];
                  selectedAddress.numInterior = address['line2'];
                  selectedAddress.sublocality = address['town'];
                  selectedAddress.codigoPostal = address['postalCode'];
                  selectedAddress.estado = address['region'] != null ? address['region']['name'] : "";
                  selectedAddress.telefono = address['phone'];
                  selectedAddress.formattedAddress = address['formattedAddress'];
                  selectedAddress.addressId = address['id'];

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
                  prefs.setBool("cart-address-update", true);

                  final store = StoreProvider.of<AppState>(context);
                  store.dispatch(SetCurrentLocationAction(selectedAddress));

                  // Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
                  // Navigator.pushNamed(context, DataUI.cuentaRoute);
                  Navigator.of(context).pop();
                  Flushbar(
                    message: "Se ha cambiado la dirección de envió",
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
                  // Navigator.of(context).pushAndRemoveUntil(
                  //   MaterialPageRoute(
                  //     builder: (BuildContext context) => MasterPage(
                  //       initialWidget: MenuItem(
                  //         id: 'cuenta',
                  //         title: ' ',
                  //         screen: CuentaPage(),
                  //         color: DataUI.backgroundColor2,
                  //         textColor: Colors.black,
                  //       ),
                  //     ),
                  //   ),
                  //   (Route<dynamic> route) => false,
                  // );
                },
                child: Text(
                  "Seleccionar",
                  style: TextStyle(
                    color: DataUI.whiteText,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(String addressId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Dirección'),
          content: Text(
            'Al eliminar esta dirección ya no aparecerá en tu lista',
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
                  "Cancelar",
                  style: TextStyle(
                    color: DataUI.chedrauiBlueColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: RaisedButton(
                color: DataUI.chedrauiBlueColor,
                onPressed: () async {
                  setState(() {
                    _isUpdatingAddresses = true;
                  });
                  Navigator.of(context).pop();
                  _deleteItem(addressId);
                },
                child: Text(
                  "Eliminar",
                  style: TextStyle(
                    color: DataUI.whiteText,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _editAddress(var adressToUpdate) async {
    editAddress.countryisocode = adressToUpdate['country']['isocode'];
    editAddress.countryname = adressToUpdate['country']['name'];
    editAddress.email = adressToUpdate['email'];
    editAddress.firstName = adressToUpdate['firstName'];
    editAddress.formattedAddress = adressToUpdate['formattedAddress'];
    editAddress.id = adressToUpdate['id'];
    editAddress.lastName = adressToUpdate['lastName'];
    editAddress.secondLastName = adressToUpdate['secondLastName'] ?? '';
    editAddress.line1 = adressToUpdate['line1'];
    editAddress.line2 = adressToUpdate['line2'] ?? '';
    editAddress.phone = adressToUpdate['phone'];
    editAddress.postalCode = adressToUpdate['postalCode'];
    editAddress.regioncountryIso = adressToUpdate['region']['countryIso'];
    editAddress.regionisocode = adressToUpdate['region']['isocode'];
    editAddress.regionisocodeShort = adressToUpdate['region']['isocodeShort'];
    editAddress.regionname = adressToUpdate['region']['name'];
    editAddress.shippingAddress = adressToUpdate['shippingAddress'];
    editAddress.town = adressToUpdate['town'];
    editAddress.visibleInAddressBook = adressToUpdate['visibleInAddressBook'];

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: DataUI.editAddressRoute),
        builder: (BuildContext context) => EditAddressPage(address: editAddress),
      ),
    );
    if (result == 'direcciones') {
      getAddressBoook();
    }
    // print(editAddress.countryisocode.toString());
    // print(editAddress.countryname.toString());
    // print(editAddress.email.toString());
    // print(editAddress.firstName.toString());
    // print(editAddress.formattedAddress.toString());
    // print(editAddress.id.toString());
    // print(editAddress.lastName.toString());
    // print(editAddress.secondLastName.toString());
    // print(editAddress.line1.toString());
    // print(editAddress.phone.toString());
    // print(editAddress.postalCode.toString());
    // print(editAddress.regioncountryIso.toString());
    // print(editAddress.regionisocode.toString());
    // print(editAddress.regionisocodeShort.toString());
    // print(editAddress.regionname.toString());
    // print(editAddress.shippingAddress.toString());
    // print(editAddress.town.toString());
    // print(editAddress.visibleInAddressBook.toString());
  }
}

// class InterestMosaic {
//   final int posicion;
//   final String descripcion;
//   final String url;
//   final bool activo;

//   InterestMosaic.fromJsonMap(Map map)
//       : posicion = map['posicion'],
//         descripcion = map['descripcion'],
//         url = map['url'],
//         activo = map['activo'];
// }
