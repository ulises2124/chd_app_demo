import 'dart:async';
import 'dart:io';

import 'package:chd_app_demo/services/FireBaseServices.dart';
import 'package:chd_app_demo/utils/input_formatters.dart';
import 'package:chd_app_demo/views/LoginPage/socialWebview.dart';
import 'package:chd_app_demo/views/MasterPage/MasterPage.dart';
import 'package:chd_app_demo/views/MasterPage/MenuScreen.dart';
import 'package:chd_app_demo/views/Servicios/ServiciosPage.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chd_app_demo/redux/models/AppState.dart';
import 'package:chd_app_demo/services/AuthServices.dart';
import 'package:chd_app_demo/services/BovedaService.dart';
import 'package:chd_app_demo/services/ListasServices.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/utils/singinUserData.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chd_app_demo/services/CarritoServices.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:chd_app_demo/redux/actions/SessionActions.dart';
// import 'package:flutter_twitter_login/flutter_twitter_login.dart';

class LoginPage extends StatefulWidget {
  final Widget child;
  final bool login;
  final String tokenFacebook;
  final String route;

  final bool logout;
  LoginPage({
    Key key,
    this.child,
    this.login,
    this.route,
    this.tokenFacebook,
    this.logout,
  }) : super(key: key);

  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // static final TwitterLogin twitterLogin = new TwitterLogin(
  //   consumerKey: 'TO5gXncVOdCzGe8LJScufJvla',
  //   consumerSecret: 'MRykfIa29DsfrGunp59ZUEpHic0As6FEQUYDsXcf21ATP0g8bO',
  // );
  FlutterWebviewPlugin webview;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  SharedPreferences prefs;

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _signinFormKey = GlobalKey<FormState>();
  TextEditingController _userController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _newMailController = TextEditingController();

  String _loginMethod = 'correo';
  String _signUpMethod = 'correo';

  String _email, _password;
  bool _autoValidateLoginForm = false;
  bool _autoValidateSigninForm = false;
  bool _obscureText = true;
  bool _isLogin = true;
  final _focusLoginPassword = FocusNode();
  final _focusPassword = FocusNode();

  SinginUserData singinUserData = SinginUserData();
  SinginUserDataSocial singinUserDataSocial = SinginUserDataSocial();
  final _focusLastname = FocusNode();
  final _focusSLastname = FocusNode();
  final _focusEmail = FocusNode();
  final _focusTelefono = FocusNode();
  final _focusCodigoPostal = FocusNode();

  bool _isLoading = false;
  var _loginResponse;
  String _loginResult;

  var _signInResponse;
  String _signInResult;

  var misListas;

  int ctrAttemps = 0;
  int maxAttemps = 5;

  @override
  void initState() {
    if (widget.login != null && widget.login) {
      setState(() {
        _isLogin = !_isLogin;
      });
    }
    getPreferences();
    super.initState();
  }

  Future getPreferences() async {
    prefs = await SharedPreferences.getInstance();
    if (widget.logout != null && widget.logout) {
      await prefs.clear();
      final store = StoreProvider.of<AppState>(context);
      store.dispatch(LogOut());
      showDialogNoListedProducts();
    }
  }

  showDialogNoListedProducts() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Sesión Expirada"),
            content: Text("Por favor inicie nuevamente sesión"),
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: WidgetContainer(
          Scaffold(
            key: _scaffoldKey,
            resizeToAvoidBottomPadding: true,
            backgroundColor: Colors.white,
            body: SafeArea(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Theme(
                      data: ThemeData(
                        primaryColor: Colors.transparent,
                        hintColor: Colors.transparent, // primaryColor: HexColor('#C4CDD5'),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  widget.logout != null && widget.logout ? Navigator.pushReplacementNamed(context, DataUI.initialRoute) : Navigator.pop(context);
                                },
                              ),
                              !_isLogin
                                  ? FlatButton(
                                      padding: EdgeInsets.symmetric(horizontal: 15),
                                      disabledColor: DataUI.chedrauiColorDisabled,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                      color: HexColor('#F57C00'),
                                      onPressed: () {
                                        setState(() {
                                          _isLogin = !_isLogin;
                                        });
                                      },
                                      child: Text(
                                        "Inicia sesión",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Archivo',
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                          fontSize: 14,
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0, bottom: 30),
                            child: LogoSvgLogin(),
                          ),
                          AnimatedCrossFade(
                            crossFadeState: _isLogin ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                            sizeCurve: Curves.easeInOut,
                            duration: const Duration(milliseconds: 280),
                            firstChild: Form(
                              key: _loginFormKey,
                              autovalidate: _autoValidateLoginForm,
                              child: Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      '¡Hola!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Archivo',
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: HexColor('#0D47A1'),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 7),
                                      child: Text(
                                        'Inicia sesión con tu correo y contraseña:',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 14, color: HexColor('#454F5B'), fontFamily: 'Rubik'),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      'Correo Electrónico',
                                      style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 5, bottom: 8),
                                      child: TextFormField(
                                        controller: _userController,
                                        style: TextStyle(color: HexColor('#0D47A1'), fontSize: 14, fontFamily: 'Archivo'),
                                        keyboardType: TextInputType.emailAddress,
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
                                          _email = input.trim().toLowerCase();
                                        },
                                        onFieldSubmitted: (v) {
                                          v.trim().toLowerCase();
                                          FocusScope.of(context).requestFocus(_focusLoginPassword);
                                        },
                                        textInputAction: TextInputAction.next,
                                        validator: FormsTextValidators.validateEmail,
                                        inputFormatters: <TextInputFormatter>[
                                          LengthLimitingTextInputFormatter(100),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'Contraseña',
                                      style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 8, bottom: 8),
                                      child: TextFormField(
                                        controller: _passwordController,
                                        obscureText: _obscureText, //This will obscure text dynamically
                                        style: TextStyle(color: HexColor('#0D47A1'), fontSize: 14, fontFamily: 'Archivo'),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: HexColor('#F0EFF4'),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                                          hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscureText ? Icons.visibility_off : Icons.visibility,
                                              color: HexColor('#637381'),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscureText = !_obscureText;
                                              });
                                            },
                                          ),
                                        ),
                                        onSaved: (input) {
                                          _password = input;
                                        },
                                        validator: FormsTextValidators.validateLoginPasword,
                                        inputFormatters: <TextInputFormatter>[
                                          LengthLimitingTextInputFormatter(100),
                                        ],
                                        onFieldSubmitted: (input) {
                                          _submitLogin();
                                        },
                                        textInputAction: TextInputAction.go,
                                        focusNode: _focusLoginPassword,
                                      ),
                                    ),
                                    _isLoading
                                        ? Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(14.0),
                                              child: CircularProgressIndicator(value: null),
                                            ),
                                          )
                                        : Container(
                                            margin: const EdgeInsets.only(top: 15),
                                            width: double.infinity,
                                            child: FlatButton(
                                              disabledColor: DataUI.chedrauiColorDisabled,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(4.0),
                                              ),
                                              padding: EdgeInsets.only(left: 0, right: 0, bottom: 15, top: 15),
                                              color: DataUI.btnbuy,
                                              child: Text(
                                                'Iniciar sesión',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              onPressed: () {
                                                _submitLogin();
                                              },
                                            ),
                                          ),
                                    Column(
                                      children: <Widget>[
                                        _loginResult != null
                                            ? Text(
                                                _loginResult,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.red,
                                                ),
                                              )
                                            : SizedBox(
                                                height: 0,
                                                width: 0,
                                              ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            secondChild: Form(
                              key: _signinFormKey,
                              autovalidate: _autoValidateSigninForm,
                              child: Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '¡Únete hoy!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Archivo',
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: HexColor('#0D47A1'),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 7),
                                      child: Text(
                                        'Ingresa tus datos para crear una cuenta:',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 14, color: HexColor('#454F5B'), fontFamily: 'Rubik'),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      'Nombre',
                                      style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                                      child: TextFormField(
                                        keyboardType: TextInputType.text,
                                        maxLength: 50,
                                        style: TextStyle(color: HexColor('#0D47A1'), fontSize: 14, fontFamily: 'Archivo'),
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
                                        onSaved: (input) {
                                          singinUserData.nombre = input;
                                        },
                                        onFieldSubmitted: (v) {
                                          FocusScope.of(context).requestFocus(_focusLastname);
                                        },
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(100),
                                          WhitelistingTextInputFormatter(
                                            FormsTextValidators.commonPersonName,
                                          ),
                                        ],
                                        validator: FormsTextValidators.validateEmptyName,
                                        textInputAction: TextInputAction.next,
                                      ),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 6,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                'Apellido paterno',
                                                style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(top: 8, bottom: 8),
                                                child: TextFormField(
                                                  style: TextStyle(color: HexColor('#0D47A1'), fontSize: 14, fontFamily: 'Archivo'),
                                                  keyboardType: TextInputType.text,
                                                  maxLength: 50,
                                                  decoration: InputDecoration(
                                                    counterText: "",
                                                    contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 6, right: 6),
                                                    filled: true,
                                                    fillColor: HexColor('#F0EFF4'),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(4.0),
                                                    ),
                                                    hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                                                  ),
                                                  onSaved: (input) {
                                                    singinUserData.paterno = input;
                                                  },
                                                  onFieldSubmitted: (v) {
                                                    FocusScope.of(context).requestFocus(_focusSLastname);
                                                  },
                                                  inputFormatters: [
                                                    LengthLimitingTextInputFormatter(100),
                                                    WhitelistingTextInputFormatter(
                                                      FormsTextValidators.commonPersonName,
                                                    ),
                                                  ],
                                                  validator: FormsTextValidators.validateEmptyName,
                                                  textInputAction: TextInputAction.next,
                                                  focusNode: _focusLastname,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                'Apellido Materno',
                                                style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(top: 8, bottom: 8),
                                                child: TextFormField(
                                                  style: TextStyle(color: HexColor('#0D47A1'), fontSize: 14, fontFamily: 'Archivo'),
                                                  decoration: InputDecoration(
                                                    // counterText: '(opcional)',
                                                    contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 6, right: 6),
                                                    filled: true,
                                                    //hintText: '(opcional)',
                                                    fillColor: HexColor('#F0EFF4'),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(4.0),
                                                    ),
                                                    //hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                                                  ),
                                                  onSaved: (input) {
                                                    singinUserData.materno = input;
                                                  },
                                                  inputFormatters: [
                                                    LengthLimitingTextInputFormatter(100),
                                                    WhitelistingTextInputFormatter(
                                                      FormsTextValidators.commonPersonName,
                                                    ),
                                                  ],
                                                  validator: FormsTextValidators.validateEmptyName,
                                                  onFieldSubmitted: (v) {
                                                    FocusScope.of(context).requestFocus(_focusTelefono);
                                                  },
                                                  textInputAction: TextInputAction.next,
                                                  focusNode: _focusSLastname,
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
                                          flex: 6,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                'Teléfono Móvil',
                                                style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(top: 8, bottom: 8),
                                                child: TextFormField(
                                                  style: TextStyle(color: HexColor('#0D47A1'), fontSize: 14, fontFamily: 'Archivo'),
                                                  decoration: InputDecoration(
                                                    contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 6, right: 6),
                                                    filled: true,
                                                    fillColor: HexColor('#F0EFF4'),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(4.0),
                                                    ),
                                                    hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                                                  ),
                                                  keyboardType: TextInputType.number,
                                                  validator: FormsTextValidators.validatePhone,
                                                  inputFormatters: <TextInputFormatter>[
                                                    WhitelistingTextInputFormatter.digitsOnly,
                                                    LengthLimitingTextInputFormatter(10),
                                                  ],
                                                  onSaved: (input) {
                                                    singinUserData.celular = input.replaceAll(' ', '').replaceAll('+', '');
                                                  },
                                                  textInputAction: TextInputAction.next,
                                                  focusNode: _focusTelefono,
                                                  onFieldSubmitted: (v) {
                                                    FocusScope.of(context).requestFocus(_focusCodigoPostal);
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                'Código Postal',
                                                style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(top: 8, bottom: 8),
                                                child: TextFormField(
                                                  style: TextStyle(color: HexColor('#0D47A1'), fontSize: 14, fontFamily: 'Archivo'),
                                                  decoration: InputDecoration(
                                                    contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 6, right: 6),
                                                    filled: true,
                                                    fillColor: HexColor('#F0EFF4'),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(4.0),
                                                    ),
                                                    hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                                                  ),
                                                  keyboardType: TextInputType.phone,
                                                  validator: FormsTextValidators.validatePostalCode,
                                                  inputFormatters: <TextInputFormatter>[
                                                    LengthLimitingTextInputFormatter(5),
                                                    WhitelistingTextInputFormatter.digitsOnly,
                                                  ],
                                                  onSaved: (input) {
                                                    singinUserData.cpostal = input.replaceAll(' ', '').replaceAll('+', '');
                                                  },
                                                  textInputAction: TextInputAction.next,
                                                  onFieldSubmitted: (v) {
                                                    FocusScope.of(context).requestFocus(_focusEmail);
                                                  },
                                                  focusNode: _focusCodigoPostal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    Text(
                                      'Correo Electrónico',
                                      style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 8, bottom: 8),
                                      child: TextFormField(
                                        style: TextStyle(color: HexColor('#0D47A1'), fontSize: 14, fontFamily: 'Archivo'),
                                        controller: _newMailController,
                                        keyboardType: TextInputType.emailAddress,
                                        maxLength: 50,
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
                                        inputFormatters: <TextInputFormatter>[
                                          LengthLimitingTextInputFormatter(100),
                                        ],
                                        validator: FormsTextValidators.validateEmail,
                                        onSaved: (input) {
                                          singinUserData.email = input;
                                        },
                                        onFieldSubmitted: (v) {
                                          FocusScope.of(context).requestFocus(_focusPassword);
                                        },
                                        textInputAction: TextInputAction.next,
                                        focusNode: _focusEmail,
                                        // autofocus: true,
                                      ),
                                    ),
                                    Text(
                                      'Contraseña',
                                      style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 8, bottom: 8),
                                      child: TextFormField(
                                        style: TextStyle(color: HexColor('#0D47A1'), fontSize: 14, fontFamily: 'Archivo'),
                                        obscureText: _obscureText, //This will obscure text dynamically
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                                          filled: true,
                                          fillColor: HexColor('#F0EFF4'),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscureText ? Icons.visibility_off : Icons.visibility,
                                              color: HexColor('#637381'),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscureText = !_obscureText;
                                              });
                                            },
                                          ),
                                        ),
                                        onSaved: (input) {
                                          singinUserData.password = input;
                                        },
                                        validator: FormsTextValidators.validateNewPasword,
                                        inputFormatters: <TextInputFormatter>[
                                          LengthLimitingTextInputFormatter(15),
                                          BlacklistingTextInputFormatter(RegExp("[ ]")),
                                        ],
                                        onFieldSubmitted: (input) {
                                          _submitSignin();
                                        },
                                        focusNode: _focusPassword,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15.0),
                                      child: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          text: 'Al registrar una cuenta Chedraui, acepto los ',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'Archivo',
                                            color: HexColor('#444444'),
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: 'Términos y Condiciones ',
                                              recognizer: new TapGestureRecognizer()
                                                ..onTap = () {
                                                  launch('https://www.chedraui.com.mx/terminos-y-condiciones');
                                                },
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontFamily: 'Archivo',
                                                fontWeight: FontWeight.w400,
                                                color: DataUI.chedrauiBlueColor,
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' del servicio que ofrece la aplicación, asi como su',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontFamily: 'Archivo',
                                                fontWeight: FontWeight.w400,
                                                color: HexColor('#444444'),
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' Aviso de Privacidad.',
                                              recognizer: new TapGestureRecognizer()
                                                ..onTap = () {
                                                  launch('https://www.chedraui.com.mx/privacy');
                                                },
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontFamily: 'Archivo',
                                                fontWeight: FontWeight.w400,
                                                color: DataUI.chedrauiBlueColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    _isLoading
                                        ? Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(14.0),
                                              child: CircularProgressIndicator(value: null),
                                            ),
                                          )
                                        : Container(
                                            margin: const EdgeInsets.only(left: 0, right: 0, bottom: 20, top: 20),
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 1,
                                                  child: FlatButton(
                                                    disabledColor: DataUI.chedrauiColorDisabled,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(4.0),
                                                    ),
                                                    padding: EdgeInsets.only(left: 0, right: 0, bottom: 15, top: 15),
                                                    color: DataUI.btnbuy,
                                                    child: Text(
                                                      'Regístrate',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      _submitSignin();
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                    Column(
                                      children: <Widget>[
                                        _signInResult != null
                                            ? Text(
                                                _signInResult,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.red,
                                                ),
                                              )
                                            : SizedBox(
                                                height: 0,
                                                width: 0,
                                              ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          _isLogin
                              ? Container(
                                  margin: EdgeInsets.symmetric(vertical: 15),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 6,
                                        child: Container(
                                          height: 1,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(width: 2.0, color: HexColor('#DDE5F1')),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          flex: 2,
                                          child: Center(
                                            child: Text(
                                              'o',
                                              style: TextStyle(fontFamily: 'Archivo', fontSize: 14),
                                            ),
                                          )),
                                      Expanded(
                                        flex: 6,
                                        child: Container(
                                          height: 1,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(width: 2.0, color: HexColor('#DDE5F1')),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : SizedBox(),
                          // MaterialButton(
                          //   onPressed: _isLoading ? null : _loginFacebook,
                          //   padding: EdgeInsets.all(0.0),
                          //   child: Container(
                          //     // margin: const EdgeInsets.only(top: 40),
                          //     padding: const EdgeInsets.all(5.0),
                          //     decoration: BoxDecoration(
                          //       borderRadius: new BorderRadius.circular(5.0),
                          //       color: HexColor('#4367B2'),
                          //     ),
                          //     child: Row(
                          //       mainAxisAlignment: MainAxisAlignment.start,
                          //       mainAxisSize: MainAxisSize.max,
                          //       children: <Widget>[
                          //         Padding(
                          //           padding: const EdgeInsets.only(right: 10.0),
                          //           child: FacebookSVG(),
                          //         ),
                          //         Flexible(
                          //           child: Text(
                          //             'Continúa con Facebook',
                          //             style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Archivo', fontWeight: FontWeight.bold),
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          // MaterialButton(
                          //   onPressed: () {
                          //     _loginTwitter();
                          //   },
                          //   padding: EdgeInsets.all(0.0),
                          //   child: Container(
                          //     margin: const EdgeInsets.only(top: 20),
                          //     padding: const EdgeInsets.all(6.0),
                          //     decoration: BoxDecoration(
                          //       borderRadius: new BorderRadius.circular(2.0),
                          //       color: HexColor('#00acee'),
                          //     ),
                          //     child: Row(
                          //       mainAxisAlignment: MainAxisAlignment.start,
                          //       mainAxisSize: MainAxisSize.max,
                          //       children: <Widget>[
                          //         Padding(
                          //           padding: const EdgeInsets.only(right: 10.0),
                          //           child: Icon(
                          //             FontAwesomeIcons.twitter,
                          //             color: Colors.white,
                          //             size: 42,
                          //           ),
                          //         ),
                          //         Flexible(
                          //           child: Text(
                          //             'Continúa con Twitter',
                          //             style: TextStyle(
                          //               fontSize: 16,
                          //               color: Colors.white,
                          //             ),
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          // MaterialButton(
                          //   onPressed: _isLoading ? null : _loginGoogle,
                          //   padding: EdgeInsets.all(0.0),
                          //   child: Container(
                          //     margin: const EdgeInsets.only(top: 20),
                          //     padding: const EdgeInsets.all(6.0),
                          //     decoration: BoxDecoration(
                          //       border: new Border.all(color: HexColor('#C7C7C7')),
                          //       borderRadius: new BorderRadius.circular(5.0),
                          //       color: DataUI.whiteText,
                          //     ),
                          //     child: Row(
                          //       mainAxisAlignment: MainAxisAlignment.start,
                          //       mainAxisSize: MainAxisSize.max,
                          //       children: <Widget>[
                          //         Padding(
                          //           padding: const EdgeInsets.only(right: 10.0),
                          //           child: GoogleSVG(),
                          //         ),
                          //         Flexible(
                          //           child: Text(
                          //             'Ingresa con tu cuenta Google',
                          //             style: TextStyle(
                          //               fontSize: 16,
                          //               color: HexColor('#212B36'),
                          //               fontFamily: 'Archivo',
                          //             ),
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          _isLogin
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    // Text(
                                    //   '¿No tienes una cuenta?',
                                    //   style: TextStyle(fontSize: 14, fontFamily: 'Rubik', color: HexColor('#454F5B')),
                                    // ),
                                    FlatButton(
                                      onPressed: () {
                                        setState(() {
                                          _newMailController.clear();
                                          _signinFormKey.currentState.reset();
                                          _newMailController.clear();

                                          _isLogin = !_isLogin;
                                        });
                                      },
                                      child: Text(
                                        "Crea tu cuenta con tu correo",
                                        style: TextStyle(
                                          fontFamily: 'Rubik',
                                          color: DataUI.chedrauiBlueColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox(),
                          _isLogin
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      '¿Olvidaste tu contraseña?',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Rubik',
                                        color: HexColor('#454F5B'),
                                      ),
                                    ),
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, DataUI.recoveryPasswordRoute);
                                      },
                                      child: Text(
                                        "Restablecer",
                                        style: TextStyle(
                                          fontFamily: 'Rubik',
                                          color: DataUI.chedrauiBlueColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox(),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: <Widget>[
                          //     Expanded(
                          //       child: Padding(
                          //         padding: const EdgeInsets.only(top: 40.0, bottom: 15),
                          //         child: Text(
                          //           '© 2019 Grupo Chedraui. Todos los derechos reservados',
                          //           style: TextStyle(
                          //             fontSize: 14,
                          //             color: DataUI.textOpaque,
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        onWillPop: () {
          _moveToSignInScreen(context);
        });
  }

  void _moveToSignInScreen(BuildContext context) {
    widget.logout != null && widget.logout ? Navigator.pushReplacementNamed(context, DataUI.initialRoute) : Navigator.pop(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _submitSignin() async {
    setState(() {
      _autoValidateSigninForm = true;
    });
    if (_signinFormKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      _signinFormKey.currentState.save();
      print('Printing the signin data.');
      print('nombre: ${singinUserData.nombre}');
      print('paterno: ${singinUserData.paterno}');
      print('materno: ${singinUserData.materno}');
      print('email: ${singinUserData.email}');
      print('pass: ${singinUserData.password}');
      print('telefono: ${singinUserData.celular}');
      try {
        _signInResponse = await AuthServices.postGCloudSignIn(singinUserData);
        setState(() {
          _isLoading = false;
        });
        if (_signInResponse['description'] != 'Usuario registrado correctamente') {
          setState(() {
            _signInResult = _signInResponse['description'];
            if (_signInResponse['errors'].length > 0) {
              _signInResult += '\n \n';
              _signInResult += _signInResponse['errors'][0]['error'];
            }
          });
          print('_loginResult');
        } else {
          if (_signInResponse['description'] == 'Usuario registrado correctamente') {
            setState(() {
              _signInResult = '';
              _autoValidateSigninForm = false;
            });
            FireBaseEventController.sendAnalyticsEventSignUp(_signUpMethod).then((ok) {});
            // final store = StoreProvider.of<AppState>(context);
            // store.dispatch(LogIn());
            _showResponseDialog(_signInResponse['description']);
            // _newMailController.clear();
            // _signinFormKey.currentState.reset();
          }
          print(_signInResponse);
        }
      } catch (e) {
        _signInResult = 'Error de conexión favor de intentar más tarde';
        _isLoading = false;
        print(e.message);
      }
    }
  }

  _showResponseDialog(msg) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Registro Exitoso"),
            content: Text(msg),
            actions: <Widget>[
              // FlatButton(
              //   onPressed: () {
              //     Navigator.pop(context);
              //     setState(() {
              //       _isLogin = !_isLogin;
              //     });
              //   },
              //   child: Text(
              //     "Cerrar",
              //     style: TextStyle(
              //       color: HexColor('#454F5B'),
              //       fontSize: 16,
              //     ),
              //   ),
              // ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                  "Continuar",
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

  Future<void> _submitLogin() async {
    // Timer _loginTimeout = Timer(Duration(seconds: 5), () {
    //   throw TimeoutException('Error de conexión');
    // });
    setState(() {
      _autoValidateLoginForm = true;
    });
    if (_loginFormKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      _loginFormKey.currentState.save();
      print('Printing the login data.');
      print('_email: ${_email}');
      print('_password: ${_password}');
      int attempts = 5;
      int currAttemp = 0;
      bool successLogin = false;
      try {
        // _loginTimeout;
        await Future.doWhile(() async {
          _loginResponse = await AuthServices.postGCloudLogin(_email, _password);
          if (_loginResponse['code'] > 0) {
            if (_loginResponse['code'] == 5) {
              print('$_loginResult');
              currAttemp++;
              successLogin = false;
              return currAttemp < attempts;
            } else {
              successLogin = false;
              return false;
            }
          } else {
            successLogin = true;
            ctrAttemps = 0;
            return false;
          }
        });
        if (!successLogin) {
          setState(() {
            _isLoading = false;
            _loginResult = _loginResponse['description'];
          });
        } else {
          await AuthServices.getHybrisUser(_loginResponse['accessToken']);
          await _storeLoginData(_loginResponse, _email, _password);
          setState(() {
            _isLoading = false;
            _loginResult = null;
          });
          final store = StoreProvider.of<AppState>(context);
          print(store.state.isSessionActive);
          print("Login exitosoooo!!!!!!!");

          prefs.setBool('isLoggedIn', true);
          prefs.setString('email', _email);
          store.dispatch(LogIn());
          FireBaseEventController.sendAnalyticsEventLogin(_loginMethod).then((ok) {});
         // Navigator.pop(context);
          Navigator.pushReplacementNamed(context, DataUI.initialRoute);
          //Detalle con el inicio de sesión

         /* if (widget.route != null) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                settings: RouteSettings(name: widget.route),
                builder: (BuildContext context) => MasterPage(
                  initialWidget: MenuItem(
                    id: DataUI.pagoServiciosRoute,
                    title: 'Pago de servicios',
                    screen: PagoServicios(),
                    color: DataUI.chedrauiColor2,
                  ),
                ),
              ),
              (Route<dynamic> route) => false,
            );
          } else {
            Navigator.pushReplacementNamed(context, DataUI.initialRoute);
          }*/
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _loginResult = 'Error de conexión favor de intentar más tarde';
        });
        print(e.message);
      }
    }
    // try {
    //   FirebaseUser fbUser = await FirebaseAuth.instance
    //       .signInWithEmailAndPassword(email: _email, password: _password);
    //   Navigator.of(context).pushReplacement(new MaterialPageRoute(
    //       settings: const RouteSettings(name: '/Master'),
    //       builder: (context) => new MasterPage()));
    //   // builder: (context) => new MasterPage(fbUser: fbUser)));
    // } catch (e) {
    //   print(e.message);
    // }
  }

  Future<void> _storeLoginData(var _loginResponse, String _email, String _password) async {
    try {
      print('---------------');
      print(_loginResponse);
      print('---------------');
      // final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);
      prefs.setString('email', _email);
      prefs.setString('password', _password);
      prefs.setString('idWallet', _loginResponse['token']);
      prefs.setString('accessToken', _loginResponse['accessToken']);
      prefs.setDouble('loginTime', DateTime.now().millisecondsSinceEpoch / 1000);
      prefs.setInt('expiresIn', _loginResponse['expiresIn']);
      await CarritoServices.deleteCurrentAnonymousCart();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<bool> _mergeOnLogin() async {
    try {
      // final SharedPreferences prefs = await SharedPreferences.getInstance();
      var merge = prefs.getBool('mergeOnLogin');
      if (merge != null) {
        prefs.remove('mergeOnLogin');
        return true;
      }
      return false;
    } catch (e) {
      print(e.toString());
    }
  }

  Future getListas() async {
    await ListasServices.getListas().then(
      (listas) {
        setState(
          () {
            misListas = listas;
          },
        );
      },
    );

    if (misListas != null) {
      if (misListas.length == 0) {
        await ListasServices.createList('Favoritos').then((response) async {
          if (response['errorMessage:'] != null) {
            if (response['code'] != null) {
              prefs.setString('favoriteListID', response['code']);
            }
          } else {
            await ListasServices.getListas().then(
              (listas) {
                setState(
                  () {
                    misListas = listas;
                  },
                );
              },
            );
            misListas.forEach((lista) async {
              if (lista['name'] == 'Favoritos') {
                prefs.setString('favoriteListID', lista['code']);
              }
            });
          }
        });
      } else {
        await Future.forEach(misListas, (lista) async {
          if (lista['name'] == 'Favoritos') {
            prefs.setString('favoriteListID', lista['code']);
          } else {
            await ListasServices.createList('Favoritos').then((response) async {
              if (response['errorMessage:'] != null) {
                if (response['code'] != null) {
                  prefs.setString('favoriteListID', response['code']);
                }
              } else {
                await ListasServices.getListas().then(
                  (listas) {
                    setState(
                      () {
                        misListas = listas;
                      },
                    );
                  },
                );
                misListas.forEach((lista) async {
                  if (lista['name'] == 'Favoritos') {
                    prefs.setString('favoriteListID', lista['code']);
                  }
                });
              }
            });
          }
        });
      }
    }
  }

  void _loginFacebook() async {
    //  if (await canLaunch('https://www.facebook.com/v4.0/dialog/oauth?client_id=2342219652710176&redirect_uri=https://app.chedraui.com.mx/app/?apn=com.planetmedia.paymentsloyalty.chedraui&isi=1239945600&ibi=mx.com.chedraui.chedraui&link=https://chedraui.com.mx
    //https://app.chedraui.com.mx/app/facebook
    //https://app.chedraui.com.mx/app/?link=https://chedraui.com.mx&apn=com.planetmedia.paymentsloyalty.chedraui&isi=1239945600&ibi=mx.com.chedraui.chedraui
    //https://app.chedraui.com.mx/app/facebook
    //https://app.chedraui.com.mx/app/?link=https://chedraui.com.mx&apn=com.planetmedia.paymentsloyalty.chedraui&isi=1239945600&ibi=mx.com.chedraui.chedraui
    //https://app.chedraui.com.mx/app/?apn=com.planetmedia.paymentsloyalty.chedraui&isi=1239945600&ibi=mx.com.chedraui.chedraui&link=https://chedraui.com.mx')) {

    //   await launch('https://www.facebook.com/v4.0/dialog/oauth?client_id=2342219652710176&redirect_uri=https://app.chedraui.com.mx/app/?ibi=mx.com.chedraui.chedraui&isi=1239945600&imv=2.0.35&apn=com.planetmedia.paymentsloyalty.chedraui&link=https%3A%2F%2Fchedraui.com.mx');
    //   exit(0);
    // } else {
    //   Flushbar(
    //     message: "Ha ocurrido un error, por favor intente de nuevo.",
    //     backgroundColor: HexColor('#FD5339'),
    //     flushbarPosition: FlushbarPosition.TOP,
    //     flushbarStyle: FlushbarStyle.FLOATING,
    //     margin: EdgeInsets.all(8),
    //     borderRadius: 8,
    //     icon: Icon(
    //       Icons.highlight_off,
    //       size: 28.0,
    //       color: Colors.white,
    //     ),
    //   );
    // }

    // final DynamicLinkParameters parameters = DynamicLinkParameters(
    //   uriPrefix: 'https://app.chedraui.com.mx/app',
    //   link: Uri.parse('https://chedraui.com.mx?code='),

    //   //'https://app.chedraui.com.mx/app/?apn=com.planetmedia.paymentsloyalty.chedraui&isi=1239945600&ibi=mx.com.chedraui.chedraui&link=https://chedraui.com.mx'
    //   androidParameters: AndroidParameters(
    //     packageName: 'com.planetmedia.paymentsloyalty.chedraui',
    //   ),
    //   // NOT ALL ARE REQUIRED ===== HERE AS AN EXAMPLE =====
    //   iosParameters: IosParameters(
    //     bundleId: 'mx.com.chedraui.chedraui',
    //     minimumVersion: '2.0.35',
    //     appStoreId: '1239945600',
    //   ),
    // );

    // final Uri dynamicUrl = await parameters.buildUrl();
    // print(dynamicUrl.toString());
    setState(() {
      _isLoading = true;
      _loginResult = '';
    });
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        try {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen(redSocial: 'facebook')),
          );
          print('result');
          print(result);
          if (result != 'error' && result != 'denied' && result != null) {
            var tokenHybris = await AuthServices.postSocialUserLogin(result, 'facebook');
            var status = await AuthServices.getHybrisUser(tokenHybris);
            if (status) {
              // final SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('isLoggedIn', true);
              prefs.setString('redSocial', 'facebook');
              prefs.setString('socialToken', result);
              prefs.setBool('socialUser', true);
              var token = await BovedaService.getWalletByEmail(prefs.getString('email'));
              if (token != null) prefs.setString('idWallet', token);
              await CarritoServices.deleteCurrentAnonymousCart();
              print(status);
              setState(() {
                _isLoading = false;
                _loginResult = null;
              });
              // _loginTimeout.cancel();
              final store = StoreProvider.of<AppState>(context);
              store.dispatch(LogIn());
              FireBaseEventController.sendAnalyticsEventLogin(_loginMethod).then((ok) {});
              Navigator.pop(context);
            /*  if (widget.route != null) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    settings: RouteSettings(name: widget.route),
                    builder: (BuildContext context) => MasterPage(
                      initialWidget: MenuItem(
                        id: DataUI.pagoServiciosRoute,
                        title: 'Pago de servicios',
                        screen: PagoServicios(),
                        color: DataUI.chedrauiColor2,
                      ),
                    ),
                  ),
                  (Route<dynamic> route) => false,
                );
              } else {
                Navigator.pushReplacementNamed(context, DataUI.initialRoute);
              }*/
            } else {
              setState(() {
                _isLoading = false;
                _loginResult = 'Ha ocurrido un error intente más tarde';
              });
              await prefs.clear();
            }
          } else if (result == 'denied') {
            setState(() {
              _isLoading = false;
            });
            await prefs.clear();
          } else if (result == 'error') {
            setState(() {
              _isLoading = false;
              _loginResult = 'Ha ocurrido un error intente más tarde';
            });
            await prefs.clear();
          } else if (result == null) {
            setState(() {
              _isLoading = false;
            });
            await prefs.clear();
          }
        } catch (e) {
          if (mounted) {
            print(e.toString());
            setState(() {
              _isLoading = false;
              _loginResult = 'Ha ocurrido un error intente más tarde';
            });
          }
          await prefs.clear();
        }
      }
    } on SocketException catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loginResult = 'Error de conexión favor de intentar más tarde';
        });
      }
      await prefs.clear();
    }
  }

  // _loginTwitter() async {
  //   // final TwitterLoginResult result = await twitterLogin.authorize();

  //   // switch (result.status) {
  //   //   case TwitterLoginStatus.loggedIn:
  //   //     var credential = TwitterAuthProvider.getCredential(
  //   //         authToken: result.session.token,
  //   //         authTokenSecret: result.session.secret);
  //   //     FirebaseUser firebaseUser =
  //   //         await FirebaseAuth.instance.signInWithCredential(credential);
  //   //     final password = await obtenerPassword(firebaseUser.email);
  //   //     final fullName = firebaseUser.displayName.split(' ');
  //   //     final name = fullName[0];
  //   //     final lastName = fullName[1];
  //   //     final email = firebaseUser.email;
  //   //     registroSocial(name, lastName, email, password);
  //   //     break;
  //   //   case TwitterLoginStatus.cancelledByUser:
  //   //     break;
  //   //   case TwitterLoginStatus.error:
  //   //     break;
  //   // }
  // }

  _loginGoogle() async {}

  obtenerPassword(String email) {
    email = '${email[0].toUpperCase()}${email.substring(1)}';
    email = email.substring(0, 14);
    email = '0$email';
    return email;
  }
}
