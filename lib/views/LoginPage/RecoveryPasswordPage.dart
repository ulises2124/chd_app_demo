import 'package:chd_app_demo/services/AuthServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';
import 'package:flutter/material.dart';

class RecoveryPasswordPage extends StatefulWidget {
  final bool button;
  RecoveryPasswordPage({Key key, this.button}) : super(key: key);

  _RecoveryPasswordPageState createState() => _RecoveryPasswordPageState();
}

class _RecoveryPasswordPageState extends State<RecoveryPasswordPage> {
  final GlobalKey<FormState> _recoveryFormKey = GlobalKey<FormState>();
  String _recoveryEmail, _recoveryNewPass;
  final myController = TextEditingController();
  bool _autoValidateRecoveryForm = false;
  bool emilaok = false;
  var _recoveryResponse;
  bool _isLoading = false;
  String _recoveryResult;

  bool success = false;

  @override
  void dispose() {
    // Limpia el controlador cuando el widget se elimine del árbol de widgets
    // Esto también elimina el listener _printLatestValue
    myController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    myController.addListener(_printLatestValue);
  }

  _printLatestValue() async {
    var result = _validateEmail(myController.text);
    if (result == null) {
      setState(() {
        emilaok = true;
      });
    } else {
      setState(() {
        emilaok = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WidgetContainer(
      Scaffold(
        resizeToAvoidBottomPadding: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(
                  Icons.arrow_back,
                ),
                onPressed: () => Navigator.pop(context),
              );
            },
          ),
          backgroundColor: Colors.white,
          title: Text(
            '',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 30),
                        child: LogoSvgLogin(),
                      ),
                      !success
                          ? Form(
                              autovalidate: _autoValidateRecoveryForm,
                              key: _recoveryFormKey,
                              child: Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    // Padding(
                                    //   padding: const EdgeInsets.only(top: 0, bottom: 30),
                                    //   child: LogoSvgLogin(),
                                    // ),
                                    Text(
                                      'Recuperar contraseña',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Archivo',
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: HexColor('#0D47A1'),
                                      ),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 10,
                                          child: Container(
                                            margin: EdgeInsets.only(top: 7),
                                            child: Text(
                                              'Por favor ingresa tu dirección de correo electrónico. Recibirás las instrucciones para restablecer tu contraseña.',
                                              style: TextStyle(fontSize: 14, color: HexColor('#454F5B'), fontFamily: 'Rubik'),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: SizedBox(),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 28, bottom: 8),
                                      child: TextFormField(
                                        controller: myController,
                                        style: TextStyle(color: HexColor('#0D47A1'), fontSize: 14, fontFamily: 'Archivo'),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: HexColor('#F0EFF4'),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          contentPadding: const EdgeInsets.only(
                                              top: 15,
                                              bottom: 15,
                                              left: 10, //todo
                                              right: 6 //todo
                                              ),
                                        ),
                                        onSaved: (input) {
                                          _recoveryEmail = input;
                                        },
                                        onFieldSubmitted: (v) {
                                          _submitRecovery();
                                        },
                                        textInputAction: TextInputAction.next,
                                        validator: _validateEmail,
                                        // autofocus: true,
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
                                                        borderRadius: BorderRadius.circular(5.0),
                                                      ),
                                                      padding: EdgeInsets.only(left: 0, right: 0, bottom: 15, top: 15),
                                                      color: DataUI.btnbuy,
                                                      child: Text(
                                                        'Restablecer la Contraseña',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      onPressed: emilaok ? _submitRecovery : null),
                                                ),
                                              ],
                                            ),
                                          ),
                                    Column(
                                      children: <Widget>[
                                        _recoveryResult != null
                                            ? Text(
                                                _recoveryResult,
                                                textAlign: TextAlign.center,
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
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                // Padding(
                                //   padding: const EdgeInsets.only(top: 0, bottom: 30),
                                //   child: LogoSvgLogin(),
                                // ),
                                Text(
                                  'Recuperar contraseña',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Archivo',
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: HexColor('#0D47A1'),
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 10,
                                      child: Container(
                                        margin: EdgeInsets.only(top: 7),
                                        child: Text(
                                          'Se han enviado instrucciones para restablecer su contraseña a la dirección de correo electrónico proporcionada.',
                                          style: TextStyle(fontSize: 14, color: HexColor('#454F5B'), fontFamily: 'Rubik'),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: SizedBox(),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 0, right: 0, bottom: 20, top: 20),
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: FlatButton(
                                            disabledColor: DataUI.chedrauiColorDisabled,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5.0),
                                            ),
                                            padding: EdgeInsets.only(left: 0, right: 0, bottom: 15, top: 15),
                                            color: DataUI.btnbuy,
                                            child: Text(
                                              widget.button == null ? 'Iniciar Sesión' : 'Volver',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                            onPressed: () => Navigator.pop(context)),
                                      ),
                                    ],
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

  Future<void> _submitRecovery() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _autoValidateRecoveryForm = true;
    });
    if (_recoveryFormKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      _recoveryFormKey.currentState.save();
      print('Printing the recovery data.');
      print('_email: ${_recoveryEmail}');
      try {
        _recoveryResponse = await AuthServices.postGcloudRecoverPassword(_recoveryEmail);
        setState(() {
          _isLoading = false;
        });
        if (_recoveryResponse['code'] != null) {
          if (_recoveryResponse['code'] == 0) {
            setState(() {
              success = true;
            });
          }
          if (_recoveryResponse['description'] != null)
            setState(() {
              _recoveryResult = _recoveryResponse['description'];
            });
          else if (_recoveryResponse['error'] != null)
            setState(() {
              _recoveryResult = _recoveryResponse['error'];
            });
          print('_recoveryResult');
        } else {
          setState(() {
            _recoveryResult = null;
          });
          print(_recoveryResponse);
        }
      } catch (e) {
        _recoveryResult = 'Error de conexión favor de intentar mas tarde';
        _isLoading = false;
        print(e.message);
      }
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
