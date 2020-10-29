import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chd_app_demo/services/AuthServices.dart';
import 'package:chd_app_demo/services/FireBaseServices.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactanosWebAndroid extends StatefulWidget {
  @override
  _ContactanosWebAndroidState createState() => _ContactanosWebAndroidState();
}

class _ContactanosWebAndroidState extends State<ContactanosWebAndroid> {
  final flutterWebviewPlugin = new FlutterWebviewPlugin();
  StreamSubscription _onDestroy;
  StreamSubscription<String> _onUrlChanged;
  StreamSubscription<WebViewStateChanged> _onStateChanged;
  bool isLogged;
  String email;
  var userInfo;
  var nombre = '';
  String identifyScript = '';
  String setNameScript = '';
  String setEmailScript = '';
  String setUserDataScript = '';
  bool loading = true;
  int stackToView = 1;

  bool canGoBack = true;
  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    _onDestroy.cancel();
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    flutterWebviewPlugin.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    flutterWebviewPlugin.close();
    _getIdentity();

    _onDestroy = flutterWebviewPlugin.onDestroy.listen((_) {
      print("destroy");
    });

    _onStateChanged = flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) async {
      print("onStateChanged: ${state.type} ${state.url}");
      switch (state.type) {
        case WebViewState.shouldStart:
          if (state.url != 'about:blank') flutterWebviewPlugin.hide();

          break;
        case WebViewState.startLoad:
          flutterWebviewPlugin.hide();

          break;
        case WebViewState.finishLoad:
          executeJS().then((onValue) async {
            if (state.url.contains('https://ayuda.chedraui.com.mx')) {
              if (state.url == 'https://ayuda.chedraui.com.mx/hc/es-419' || state.url == 'https://ayuda.chedraui.com.mx/') {
                setState(() {
                  canGoBack = false;
                });
              }
              // else if (state.url == "tel:800%20563%202222" || state.url == "tel:800 563 2222") {
              //   if (await canLaunch("tel: 800 563 2222")) {
              //     flutterWebviewPlugin.goBack();
              //     await launch("tel: 800 563 2222");
              //   }
              // } else if (state.url == "mailto:ayuda@chedraui.com.mx") {
              //   if (await canLaunch("mailto:ayuda@chedraui.com.mx")) {
              //     flutterWebviewPlugin.goBack();
              //     await launch("mailto:ayuda@chedraui.com.mx");
              //   }
              // }
              else {
                setState(() {
                  canGoBack = true;
                });
              }
            } else {
              if (await canLaunch(state.url)) {
                flutterWebviewPlugin.goBack();
                await launch(state.url);
              }
              // setState(() {
              //     canGoBack = false;
              //   });
            }
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (onValue) flutterWebviewPlugin.show();
            });
          });

          break;
        default:
      }
    });

    // Add a listener to on url changed
    _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen(
      (String url) async {},
    );
  }

  _getIdentity() async {
    FireBaseEventController.setCurrentScreen(DataUI.chatContactRoute).then((ok) {});
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      isLogged = prefs.getBool('isLoggedIn') ?? false;
      if (isLogged) {
        email = prefs.getString('email');
        userInfo = await AuthServices.getHybrisUserInfo();
        nombre = userInfo['cliente']['nombre'] + " " + userInfo['cliente']['apellidoPaterno'] + " " + userInfo['cliente']['apellidoMaterno'];
        print("************************************** email: $email");
        print("************************************** token: $nombre");
        setState(() {
          identifyScript = "zE('webWidget', 'identify', {name: $nombre ,email: $email ,organization: 'Chedraui'});";
          setNameScript = "\$zopim.livechat.setName(\'$nombre\');";
          setEmailScript = "\$zopim.livechat.setEmail(\'$email\');";
          setUserDataScript = "\$zopim(function(){\n\t$setNameScript\n\t$setEmailScript\n});";
        });
        print(setUserDataScript);
      }
    } catch (e) {
      print('No fue posible obtener dato');
    }
  }

  Future<bool> _exitApp(BuildContext context) async {
    Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
  }

  Future<bool> executeJS() async {
    bool done = false;
    await flutterWebviewPlugin.evalJavascript("document.getElementsByClassName('header')[0].style.display='none';");
    await flutterWebviewPlugin.evalJavascript("document.getElementsByClassName('footer')[0].style.display='none';");
    await flutterWebviewPlugin.evalJavascript("document.getElementsByClassName('sub-nav')[0].style.display='none';");
    await flutterWebviewPlugin.evalJavascript("document.getElementsByClassName('home-footer')[0].style.display='none';");

    await flutterWebviewPlugin.evalJavascript(identifyScript);
    //await flutterWebviewPlugin.evalJavascript(setNameScript);
    //await flutterWebviewPlugin.evalJavascript(setEmailScript);
    await flutterWebviewPlugin.evalJavascript(setUserDataScript);
    done = true;
    return done;
  }

  void _moveToSignInScreen(BuildContext context) {
    canGoBack ? flutterWebviewPlugin.goBack() : Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    String loginUrl = "https://ayuda.chedraui.com.mx";

    return WillPopScope(
      child: WidgetContainer(
        WebviewScaffold(
          resizeToAvoidBottomInset: true,
          url: loginUrl,
          appBar: GradientAppBar(
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () => canGoBack ? flutterWebviewPlugin.goBack() : Navigator.pop(context),
                );
              },
            ),
            gradient: DataUI.appbarGradient,
            title: Text(
              'Centro de ayuda',
              style: DataUI.appbarTitleStyle,
            ),
          ),
          withJavascript: true,
          clearCache: true,
          clearCookies: true,
          appCacheEnabled: false,
          withZoom: false,
          initialChild: Container(
            color: Colors.white,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
      onWillPop: () {
        _moveToSignInScreen(context);
      },
    );
  }
}
