import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:chd_app_demo/services/AuthServices.dart';
import 'package:chd_app_demo/services/FireBaseServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/utils/input_formatters.dart';
// import 'package:chedraui_flutter/views/ContactanosPage/EnviarEmail.dart';
import 'package:chd_app_demo/views/DeliveryMethod/DeliveryMethodPage.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flushbar/flushbar.dart';
// import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/services.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:zendesk/zendesk.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:chedraui_flutter/services/AuthServices.dart';
import 'package:package_info/package_info.dart';


const ZendeskAccountKey = 'xZ4SDhJjAVslap6kEHoJmdAPZhz68t61';

class Contactanos extends StatefulWidget {
  Contactanos({Key key}) : super(key: key);

  _ContactanosState createState() => _ContactanosState();
}

class _ContactanosState extends State<Contactanos> {
  bool loadingChat = false;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _focusEmail = FocusNode();
  final _focusNombre = FocusNode();
  bool editing = false;
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  var userInfo;
  bool _isLoading = false;
  var token;

  bool isLogged;

  var telefono;

  var nombre = '';
  String email;

  bool enabled;
  var zendesk = const MethodChannel('com.cheadrui.com/zendesk');

  String version;

  versionCheck() async {
    //Get Latest version info from firebase config
    final RemoteConfig remoteConfig = await RemoteConfig.instance;
    //print('object');
    try {
      // Using default duration to force fetching from remote server.
      await remoteConfig.fetch(expiration: const Duration(seconds: 0));
      await remoteConfig.activateFetched();
      setState(() {
        enabled = true;
      });
      //print(enabled);
    } on FetchThrottledException catch (exception) {
      // Fetch throttled.
      //print(exception);
    } catch (exception) {
      // print('Unable to fetch remote config. Cached or default values will be '
      //     'used');
    }
  }

  launchAVP() async {
    const url = 'https://www.chedraui.com.mx/privacy';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Flushbar(
        message: "Ha ocurrido un error, por favor intente de nuevo.",
        backgroundColor: HexColor('#FD5339'),
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.FLOATING,
        margin: EdgeInsets.all(8),
        borderRadius: 8,
        icon: Icon(
          Icons.highlight_off,
          size: 28.0,
          color: Colors.white,
        ),
      );
    }
  }

  launchTerminosYCondiciones() async {
    const url = 'https://www.chedraui.com.mx/terminos-y-condiciones';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Flushbar(
        message: "Ha ocurrido un error, por favor intente de nuevo.",
        backgroundColor: HexColor('#FD5339'),
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.FLOATING,
        margin: EdgeInsets.all(8),
        borderRadius: 8,
        icon: Icon(
          Icons.highlight_off,
          size: 28.0,
          color: Colors.white,
        ),
      );
    }
  }

  launchChat(String viewId) async {
    FireBaseEventController.setCurrentScreen(DataUI.chatContactRoute).then((ok) {});
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      isLogged = prefs.getBool('isLoggedIn') ?? false;
      if (isLogged) {
        email = prefs.getString('email');
        userInfo = await AuthServices.getHybrisUserInfo();
        nombre = userInfo['cliente']['nombre'] + " " + userInfo['cliente']['apellidoPaterno'] + " " + userInfo['cliente']['apellidoMaterno'];
        print("************************************** email: $email");
        print("************************************** token: $nombre");
        launchZendesk();
      } else {
        setState(() {
          editing = !editing;
        });
      }
    } catch (e) {
      Flushbar(
        message: "Ha ocurrido un error, por favor intente de nuevo.",
        backgroundColor: HexColor('#FD5339'),
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.FLOATING,
        margin: EdgeInsets.all(8),
        borderRadius: 8,
        icon: Icon(
          Icons.highlight_off,
          size: 28.0,
          color: Colors.white,
        ),
      );
    }
  }

  launchZendesk() async {
    await zendesk.invokeMethod("setVisitorInfo", {
      'name': nombre ?? '',
      'email': email ?? '',
    }).then((onValue) {
      print('-------------');
      print(onValue);
      print('-------------');
      setState(() {
        _isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        _isLoading = false;
      });
      print('-------------');
      print(e);
      print('-------------');
    });

    await zendesk.invokeMethod("startChat").then((onValue) {
      print(onValue);
    }).catchError((e) {
      print('error $e');
    });
  }

  submitForm() {
    if (_loginFormKey.currentState.validate()) {
      _loginFormKey.currentState.save();
      setState(() {
        _isLoading = true;
      });
      launchZendesk();
    }
  }

  launchFacebook() async {
    const url = 'https://www.facebook.com/CHEDRAUIOFICIAL/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Flushbar(
        message: "Ha ocurrido un error, por favor intente de nuevo.",
        backgroundColor: HexColor('#FD5339'),
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.FLOATING,
        margin: EdgeInsets.all(8),
        borderRadius: 8,
        icon: Icon(
          Icons.highlight_off,
          size: 28.0,
          color: Colors.white,
        ),
      );
    }
  }

  launchTW() async {
    const url = 'https://twitter.com/Chedrauioficial';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Flushbar(
        message: "Ha ocurrido un error, por favor intente de nuevo.",
        backgroundColor: HexColor('#FD5339'),
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.FLOATING,
        margin: EdgeInsets.all(8),
        borderRadius: 8,
        icon: Icon(
          Icons.highlight_off,
          size: 28.0,
          color: Colors.white,
        ),
      );
    }
  }

  launchYT() async {
    const url = 'https://www.youtube.com/channel/UC4hyPwzC3rGRi7pCyZhDn1Q';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Flushbar(
        message: "Ha ocurrido un error, por favor intente de nuevo.",
        backgroundColor: HexColor('#FD5339'),
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.FLOATING,
        margin: EdgeInsets.all(8),
        borderRadius: 8,
        icon: Icon(
          Icons.highlight_off,
          size: 28.0,
          color: Colors.white,
        ),
      );
    }
  }

  _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Flushbar(
        message: "Ha ocurrido un error, por favor intente de nuevo.",
        backgroundColor: HexColor('#FD5339'),
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.FLOATING,
        margin: EdgeInsets.all(8),
        borderRadius: 8,
        icon: Icon(
          Icons.highlight_off,
          size: 28.0,
          color: Colors.white,
        ),
      );
    }
  }

  // dynamic jsonResponse;

  // Future<String> _loadTermCond() async {
  //   return await rootBundle.loadString('assets/thcd.json');
  // }

  // Future loadTermCond() async {
  //   String jsonString = await _loadTermCond();
  //   jsonResponse = json.decode(jsonString);
  //   print(jsonResponse);
  //   jsonResponse = jsonResponse;
  // }

  @override
  void initState() {
    initZendesk();
    super.initState();
    // loadTermCond();
    versionCheck();
    _getversionApp();
  }

  Future<void> initZendesk() async {
    // const f = const MethodChannel('com.cheadrui.com/zendesk');
    await zendesk.invokeMethod("init").then((onValue) {
      print('-------------');
      print(onValue);
      print('-------------');
    }).catchError((e) {
      print('-------------');
      print(e);
      print('-------------');
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    // But we aren't calling setState, so the above point is rather moot now.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: HexColor('#F4F6F8'),
        // appBar: AppBar(
        //   elevation: 0,
        //   backgroundColor: Colors.white,
        //   title: Text(
        //     'Contáctanos',
        //     style: TextStyle(
        //       fontFamily: 'Rubik',
        //       fontSize: 16,
        //       fontWeight: FontWeight.w400,
        //     ),
        //   ),
        // ),
        appBar: GradientAppBar(
          iconTheme: IconThemeData(
            color: DataUI.primaryText, //change your color here
          ),
          title: Text(
            'Contáctanos',
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
        body: enabled != null
            ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      color: Colors.white,
                      margin: EdgeInsets.all(15),
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: CallSVG(),
                          ),
                          FlatButton(
                            onPressed: () {
                              _makePhoneCall('tel:018005632222');
                            },
                            child: Text(
                              'Compras: 01800-563-2222',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Archivo',
                                fontSize: 14,
                                letterSpacing: 0.25,
                                fontWeight: FontWeight.w600,
                                color: HexColor('#0D47A1'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    enabled
                        ? Container(
                            color: Colors.white,
                            margin: EdgeInsets.all(15),
                            child: AnimatedCrossFade(
                              sizeCurve: Curves.easeInOut,
                              duration: const Duration(milliseconds: 280),
                              firstChild: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(top: 15, right: 15, left: 15, bottom: 0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            'Chatear en línea',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: 'Archivo',
                                              fontSize: 20,
                                              // letterSpacing: 0.25,
                                              fontWeight: FontWeight.w500,
                                              color: DataUI.textOpaqueStrong,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            'Chatea con un representante de \nservicio al cliente en línea.',
                                            textAlign: TextAlign.left,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontFamily: 'Archivo',
                                              fontSize: 14,
                                              // letterSpacing: 0.25,
                                              fontWeight: FontWeight.w400,
                                              color: DataUI.textOpaqueMedium,
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: OutlineButton(
                                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                                            borderSide: BorderSide(
                                              width: 2,
                                              color: HexColor('#0D47A1'),
                                            ),
                                            color: HexColor('#0D47A1'),
                                            onPressed: () {
                                              if (!loadingChat) {
                                                launchChat('openCrispChat');
                                              }
                                            },
                                            child: Text(
                                              'Chatear en línea',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: 'Archivo',
                                                fontSize: 14,
                                                letterSpacing: 0.25,
                                                color: HexColor('#0D47A1'),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: FamilySVG(),
                                  ),
                                ],
                              ),
                              secondChild: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Form(
                                  key: _loginFormKey,
                                  autovalidate: true,
                                  child: Center(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Text(
                                          'Nombre',
                                          style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 8, bottom: 8),
                                          child: TextFormField(
                                            // controller: _passwordController,
                                            style: TextStyle(color: HexColor('#0D47A1'), fontSize: 14, fontFamily: 'Archivo'),
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
                                              setState(() {
                                                nombre = input;
                                              });
                                              FocusScope.of(context).requestFocus(_focusEmail);
                                            },
                                            validator: FormsTextValidators.validateEmptyName,
                                            inputFormatters: <TextInputFormatter>[
                                              LengthLimitingTextInputFormatter(100),
                                            ],
                                            onFieldSubmitted: (input) {},
                                            textInputAction: TextInputAction.go,
                                            focusNode: _focusNombre,
                                          ),
                                        ),
                                        Text(
                                          'Correo Electrónico',
                                          style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 5, bottom: 8),
                                          child: TextFormField(
                                            // controller: _userController,
                                            focusNode: _focusEmail,
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
                                              setState(() {
                                                email = input.trim().toLowerCase();
                                              });
                                            },
                                            onFieldSubmitted: (v) {
                                              v.trim().toLowerCase();
                                              submitForm();
                                            },
                                            textInputAction: TextInputAction.done,
                                            validator: FormsTextValidators.validateEmail,
                                            inputFormatters: <TextInputFormatter>[
                                              LengthLimitingTextInputFormatter(100),
                                            ],
                                          ),
                                        ),
                                        _isLoading
                                            ? Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(14.0),
                                                  child: CircularProgressIndicator(value: null),
                                                ),
                                              )
                                            : Center(
                                                child: OutlineButton(
                                                  shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                                                  borderSide: BorderSide(
                                                    width: 2,
                                                    color: HexColor('#0D47A1'),
                                                  ),
                                                  color: HexColor('#0D47A1'),
                                                  onPressed: () {
                                                    submitForm();
                                                  },
                                                  child: Text(
                                                    'Chatear en línea',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily: 'Archivo',
                                                      fontSize: 14,
                                                      letterSpacing: 0.25,
                                                      color: HexColor('#0D47A1'),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              crossFadeState: editing ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                            ),
                          )
                        : SizedBox(),
                    Container(
                      padding: EdgeInsets.only(top: 15, right: 50, left: 50, bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          InkResponse(
                            containedInkWell: true,
                            enableFeedback: true,
                            splashColor: DataUI.chedrauiColor,
                            child: GestureDetector(
                              onTap: () {
                                launchFacebook();
                              },
                              child: FacebookIconSVG(),
                            ),
                          ),
                          InkResponse(
                            containedInkWell: true,
                            enableFeedback: true,
                            splashColor: DataUI.chedrauiColor,
                            child: GestureDetector(
                              onTap: () {
                                launchTW();
                              },
                              child: TwitterIconSVG(),
                            ),
                          ),
                          InkResponse(
                            containedInkWell: true,
                            enableFeedback: true,
                            splashColor: DataUI.chedrauiColor,
                            child: GestureDetector(
                              onTap: () {
                                launchYT();
                              },
                              child: YoutubeIconSVG(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      margin: EdgeInsets.all(15),
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                           Container(
                            margin: EdgeInsets.symmetric(vertical: 7),
                            child:
                            Text('App Chedraui $version' ,
                            
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: 'Archivo',
                                fontSize: 16,
                                color: HexColor('#212B36'),
                              ),
                              )
                           ),
                          
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 7),
                            child: InkWell(
                              onTap: () {
                                launchTerminosYCondiciones();
                              },
                              // onTap: () async {
                              //   if (jsonResponse['terminoschd'] == null) {
                              //     loadTermCond();
                              //   }
                              //   ;
                              //   if (jsonResponse['terminoschd'] != null) {
                              //     showDialog(
                              //       context: context,
                              //       builder: (BuildContext context) {
                              //         return AlertDialog(
                              //           content: SingleChildScrollView(
                              //             physics: ClampingScrollPhysics(),
                              //             child: Html(
                              //               data: jsonResponse['terminoschd'],
                              //             ),
                              //           ),
                              //           actions: s<Widget>[
                              //             FlatButton(
                              //               child: Text('Ok'),
                              //               onPressed: () {
                              //                 Navigator.of(context).pop();
                              //               },
                              //             ),
                              //           ],
                              //         );
                              //       },
                              //     );
                              //   }
                              // },
                              child: Text(
                                'Términos y condiciones',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: 'Archivo',
                                  fontSize: 14,
                                  letterSpacing: 0.25,
                                  color: HexColor('#0D47A1'),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 7),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    settings: RouteSettings(name: DataUI.deliveryMethodRoute),
                                    builder: (context) => DeliveryMethodPage(
                                      showStores: true,
                                      showConfirmationForm: false,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'Ubica tu Tienda',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: 'Archivo',
                                  fontSize: 14,
                                  letterSpacing: 0.25,
                                  color: HexColor('#0D47A1'),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 7),
                            child: InkWell(
                              onTap: () {
                                launchAVP();
                              },
                              child: Text(
                                'Aviso de privacidad',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: 'Archivo',
                                  fontSize: 14,
                                  letterSpacing: 0.25,
                                  color: HexColor('#0D47A1'),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 7),
                            child: InkWell(
                              onTap: () {
                                if (Theme.of(context).platform == TargetPlatform.iOS) {
                                  Share.share('!Te invito a descargar la aplicación de Chedraui! https://itunes.apple.com/mx/app/chedraui/id1239945600?mt=8');
                                } else {
                                  Share.share('¡Te invito a descargar la aplicación de Chedraui! https://play.google.com/store/apps/details?id=com.planetmedia.paymentsloyalty.chedraui');
                                }
                              },
                              child: Text(
                                'Compartir app',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: 'Archivo',
                                  fontSize: 14,
                                  letterSpacing: 0.25,
                                  color: HexColor('#0D47A1'),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Container(
                    //   margin: EdgeInsets.all(15),
                    //   padding: EdgeInsets.all(15),
                    //   child: Row(
                    //     children: <Widget>[
                    //       FlatButton(
                    //         child: Text('Ubica tu tienda'),
                    //         onPressed: () {
                    //           Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //               builder: (context) => DeliveryMethodPage(
                    //                     showStores: true,
                    //                     showConfirmationForm: false,
                    //                   ),
                    //             ),
                    //           );
                    //         },
                    //       ),
                    //       FlatButton(
                    //         child: Text('Legal'),
                    //         onPressed: () {
                    //           // Navigator.of(context).pop();
                    //         },
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Container(
                    //   color: Colors.white,
                    //   margin: EdgeInsets.all(15),
                    //   padding: EdgeInsets.all(15),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     mainAxisAlignment: MainAxisAlignment.start,
                    //     children: <Widget>[
                    //       Container(
                    //         margin: EdgeInsets.symmetric(vertical: 7),
                    //         child: Text(
                    //           'Contáctenos en línea',
                    //           textAlign: TextAlign.left,
                    //           style: TextStyle(
                    //             fontFamily: 'Archivo',
                    //             fontSize: 16,
                    //             color: HexColor('#212B36'),
                    //           ),
                    //         ),
                    //       ),
                    //       Container(
                    //         margin: EdgeInsets.symmetric(vertical: 7),
                    //         child: Text(
                    //           'Si tiene alguna pregunta o sugerencia, no dude en llamarnos.',
                    //           textAlign: TextAlign.left,
                    //           style: TextStyle(
                    //             fontFamily: 'Archivo',
                    //             fontSize: 14,
                    //             letterSpacing: 0.25,
                    //             color: HexColor('#637381'),
                    //           ),
                    //         ),
                    //       ),
                    //       Container(
                    //         width: double.infinity,
                    //         margin: EdgeInsets.symmetric(vertical: 7),
                    //         child: RaisedButton(
                    //           shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                    //           onPressed: () {
                    //             Navigator.push(
                    //               context,
                    //               MaterialPageRoute(
                    //                 builder: (context) => EnviarEmail(),
                    //               ),
                    //             );
                    //           },
                    //           color: HexColor('#F57C00'),
                    //           child: Text(
                    //             'Contacto en línea',
                    //             textAlign: TextAlign.left,
                    //             style: TextStyle(
                    //               fontFamily: 'Archivo',
                    //               fontSize: 14,
                    //               letterSpacing: 0.25,
                    //               color: HexColor('#FFFFFF'),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //       Container(
                    //         margin: EdgeInsets.symmetric(vertical: 9),
                    //         child: Text(
                    //           'Opciones de contacto adicionales',
                    //           textAlign: TextAlign.left,
                    //           style: TextStyle(
                    //             fontFamily: 'Archivo',
                    //             fontSize: 14,
                    //             letterSpacing: 0.25,
                    //             color: HexColor('#637381'),
                    //           ),
                    //         ),
                    //       ),
                    //       Container(
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //           mainAxisSize: MainAxisSize.max,
                    //           children: <Widget>[
                    //             Expanded(
                    //               flex: 6,
                    //               child: OutlineButton(
                    //                 borderSide: BorderSide(
                    //                   width: 2,
                    //                   color: HexColor('#0D47A1'),
                    //                 ),
                    //                 color: HexColor('#0D47A1'),
                    //                 onPressed: () {
                    //                   launchChat();
                    //                 },
                    //                 child: Text(
                    //                   'Chatear en línea',
                    //                   textAlign: TextAlign.center,
                    //                   style: TextStyle(
                    //                     fontFamily: 'Archivo',
                    //                     fontSize: 14,
                    //                     letterSpacing: 0.25,
                    //                     color: HexColor('#0D47A1'),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //             Expanded(
                    //               flex: 6,
                    //               child: OutlineButton(
                    //                 borderSide: BorderSide(
                    //                   width: 2,
                    //                   color: HexColor('#0D47A1'),
                    //                 ),
                    //                 color: HexColor('#0D47A1'),
                    //                 onPressed: () {
                    //                   _makePhoneCall('tel:018005632222');
                    //                 },
                    //                 child: Text(
                    //                   'Llamar Call Center',
                    //                   textAlign: TextAlign.center,
                    //                   style: TextStyle(
                    //                     fontFamily: 'Archivo',
                    //                     fontSize: 14,
                    //                     letterSpacing: 0.25,
                    //                     color: HexColor('#0D47A1'),
                    //                   ),
                    //                 ),
                    //               ),
                    //             )
                    //           ],
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Container(
                    //   color: Colors.white,
                    //   margin: EdgeInsets.all(15),
                    //   padding: EdgeInsets.all(15),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     mainAxisAlignment: MainAxisAlignment.start,
                    //     children: <Widget>[
                    //       Container(
                    //         margin: EdgeInsets.symmetric(vertical: 7),
                    //         child: Text(
                    //           'Social',
                    //           textAlign: TextAlign.left,
                    //           style: TextStyle(
                    //             fontFamily: 'Archivo',
                    //             fontSize: 16,
                    //             color: HexColor('#212B36'),
                    //           ),
                    //         ),
                    //       ),
                    //       Container(
                    //         margin: EdgeInsets.symmetric(vertical: 7),
                    //         child: Text(
                    //           'Síguenos en las redes sociales para conocer las últimas noticias y promociones.',
                    //           textAlign: TextAlign.left,
                    //           style: TextStyle(
                    //             fontFamily: 'Archivo',
                    //             fontSize: 14,
                    //             letterSpacing: 0.25,
                    //             color: HexColor('#637381'),
                    //           ),
                    //         ),
                    //       ),
                    //       Container(
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.start,
                    //           mainAxisSize: MainAxisSize.max,
                    //           children: <Widget>[
                    //             IconButton(
                    //               color: HexColor('#0D47A1'),
                    //               onPressed: () {
                    //                 launchFacebook();
                    //               },
                    //               icon: Icon(FontAwesomeIcons.facebook),
                    //             ),
                    //             IconButton(
                    //               color: HexColor('#0D47A1'),
                    //               onPressed: () {
                    //                 launchTW();
                    //               },
                    //               icon: Icon(FontAwesomeIcons.twitter),
                    //             ),
                    //             IconButton(
                    //               color: HexColor('#0D47A1'),
                    //               onPressed: () {
                    //                 launchYT();
                    //               },
                    //               icon: Icon(FontAwesomeIcons.youtube),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ));

    
  }

  _getversionApp(){
       PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
     setState(() {
       version =  packageInfo.version;
     });
     

});


    }
}
