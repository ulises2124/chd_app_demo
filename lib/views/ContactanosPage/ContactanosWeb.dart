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
import 'package:webview_flutter/webview_flutter.dart';

class ContactanosWeb extends StatefulWidget {
  @override
  _ContactanosWebState createState() => _ContactanosWebState();
}

class _ContactanosWebState extends State<ContactanosWeb> {
  // final flutterWebviewPlugin = new FlutterWebviewPlugin();
  // StreamSubscription _onDestroy;
  // StreamSubscription<String> _onUrlChanged;
  // StreamSubscription<WebViewStateChanged> _onStateChanged;
  bool isLogged;
  String email;
  var userInfo;
  var nombre = '';
  String identifyScript = '';
  String setNameScript = '';
  String setEmailScript = '';
  String setUserDataScript = '';
  bool loading = false;

  bool canGoBack = false;

  String loginUrl = "https://ayuda.chedraui.com.mx";
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  WebViewController _myController;
  // void dispose() {
  //   // Every listener should be canceled, the same should be done with this stream.
  //   _onDestroy.cancel();
  //   _onUrlChanged.cancel();
  //   _onStateChanged.cancel();
  //   flutterWebviewPlugin.dispose();
  //   super.dispose();
  // }

  @override
  void initState() {
    super.initState();

    // flutterWebviewPlugin.close();
    _getIdentity();

    // _onDestroy = flutterWebviewPlugin.onDestroy.listen((_) {
    //   print("destroy");
    // });

    // _onStateChanged = flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) async {
    //   print("onStateChanged: ${state.type} ${state.url}");
    //   switch (state.type) {
    //     case WebViewState.shouldStart:
    //       if (state.url != 'about:blank') flutterWebviewPlugin.hide();

    //       break;
    //     case WebViewState.startLoad:
    //       flutterWebviewPlugin.hide();

    //       break;
    //     case WebViewState.finishLoad:

    //       break;
    //     default:
    //   }
    // });

    // // Add a listener to on url changed
    // _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen(
    //   (String url) async {},
    // );
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
          identifyScript = "zE('webWidget', 'identify', {name: '$nombre' ,email: '$email' ,organization: 'Chedraui'});";
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

  // Future<bool> _exitApp(BuildContext context) async {
  //   Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
  // }

  // Future<bool> executeJS() async {
  //   bool done = false;
  //   await flutterWebviewPlugin.evalJavascript("document.getElementsByClassName('header')[0].style.display='none';");
  //   await flutterWebviewPlugin.evalJavascript("document.getElementsByClassName('footer')[0].style.display='none';");
  //   await flutterWebviewPlugin.evalJavascript("document.getElementsByClassName('sub-nav')[0].style.display='none';");
  //   await flutterWebviewPlugin.evalJavascript("document.getElementsByClassName('home-footer')[0].style.display='none';");

  //   await flutterWebviewPlugin.evalJavascript(identifyScript);
  //   //await flutterWebviewPlugin.evalJavascript(setNameScript);
  //   //await flutterWebviewPlugin.evalJavascript(setEmailScript);
  //   await flutterWebviewPlugin.evalJavascript(setUserDataScript);
  //   done = true;
  //   return done;
  // }

  void _moveToSignInScreen(BuildContext context) {
    _myController.canGoBack().then((onValue) {
      onValue ? _myController.goBack() : Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // return WillPopScope(
    //   child: WebviewScaffold(
    //     resizeToAvoidBottomInset: true,
    //     url: loginUrl,
    //     appBar: GradientAppBar(
    //       leading: Builder(
    //         builder: (BuildContext context) {
    //           return IconButton(
    //             icon: Icon(
    //               Icons.arrow_back,
    //               color: Colors.white,
    //             ),
    //             onPressed: () => canGoBack ? flutterWebviewPlugin.goBack() : Navigator.pop(context),
    //           );
    //         },
    //       ),
    //       gradient: DataUI.appbarGradient,
    //       title: Text(
    //         'Centro de ayuda',
    //         style: DataUI.appbarTitleStyle,
    //       ),
    //     ),
    //     withJavascript: true,
    //     clearCache: true,
    //     clearCookies: true,
    //     appCacheEnabled: false,
    //     withZoom: false,
    //     initialChild: Container(
    //       color: Colors.white,
    //       child: const Center(
    //         child: CircularProgressIndicator(),
    //       ),
    //     ),
    //   ),
    //   onWillPop: () {
    //     _moveToSignInScreen(context);
    //   },
    // );
    _launchURL(url) async {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        Flushbar(
          message: "Ha ocurrido un error $url",
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
          duration: Duration(seconds: 3),
        )..show(context);
      }
    }

    // final Completer<WebViewController> _controller = Completer<WebViewController>();
    return WidgetContainer(
      Scaffold(
        appBar: GradientAppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  _myController.canGoBack().then((onValue) {
                    onValue ? _myController.goBack() : Navigator.pop(context);
                  });
                },
              );
            },
          ),
          gradient: DataUI.appbarGradient,
          title: Text(
            'Centro de ayuda',
            style: DataUI.appbarTitleStyle,
          ),
        ),
        // body: IndexedStack(
        //   index: _stackToView,
        //   children: <Widget>[
        //     Container(child: Center(child: CircularProgressIndicator())),
        //   ],
        // ),
        body: WillPopScope(
          child: WebView(
            initialUrl: "https://ayuda.chedraui.com.mx",
            javascriptMode: JavascriptMode.unrestricted,
            navigationDelegate: (NavigationRequest request) {
              print(request.url);
              if (!request.url.contains('https://ayuda.chedraui.com.mx') && request.url != 'about:blank' && !request.url.contains('recaptcha')) {
                _launchURL(request.url);
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
// assign webviewcontroller object to mycontroller object and now we have a webpage
              _myController = webViewController;
            },
            onPageFinished: (String url) {
              print('Page finished loading: $url');
// evaluateJavascript is a method to customize the UI, here i find searchfield class name and writing a javascript query string.
              if (isLogged) {
                _myController.evaluateJavascript(identifyScript);
                //await flutterWebviewPlugin.evalJavascript(setNameScript);
                //await flutterWebviewPlugin.evalJavascript(setEmailScript);
                _myController.evaluateJavascript(setUserDataScript);
              }
              _myController.evaluateJavascript("if(document.getElementsByClassName('header')[0] != null) document.getElementsByClassName('header')[0].style.display='none';");
              _myController.evaluateJavascript("if(document.getElementsByClassName('footer')[0] != null) document.getElementsByClassName('footer')[0].style.display='none';");
              _myController.evaluateJavascript("if(document.getElementsByClassName('sub-nav')[0] != null) document.getElementsByClassName('sub-nav')[0].style.display='none';");
              _myController.evaluateJavascript("if(document.getElementsByClassName('home-footer')[0] != null) document.getElementsByClassName('home-footer')[0].style.display='none';");
            },
          ),
          onWillPop: () {
            _moveToSignInScreen(context);
          },
        ),
      ),
    );
    // return Scaffold(

    //   body: Stack(
    //     children: <Widget>[
    //       Visibility(
    //         maintainSize: true,
    //         maintainAnimation: true,
    //         maintainState: true,
    //         visible: loading,
    //         child: WebView(
    //           javascriptMode: JavascriptMode.unrestricted,
    //           onWebViewCreated: (WebViewController webViewController) {
    //             _controller.complete(webViewController);
    //             _myController = webViewController;
    //           },
    //           initialUrl: loginUrl,

    //           onPageStarted: (String url) {
    //             print(_myController);
    //             setState(() {
    //               loading = false;
    //             });
    //             print('Page started loading: $url');
    //           },
    //           onPageFinished: (String url) async {
    //             print(_myController);
    //             setState(() {
    //               loading = true;
    //             });
    //             if (isLogged) {
    //               await _myController.evaluateJavascript(identifyScript);
    //               //await flutterWebviewPlugin.evalJavascript(setNameScript);
    //               //await flutterWebviewPlugin.evalJavascript(setEmailScript);
    //               await _myController.evaluateJavascript(setUserDataScript);
    //             }
    //             await _myController.evaluateJavascript("if(document.getElementsByClassName('header')[0] != null) document.getElementsByClassName('header')[0].style.display='none';");
    //             await _myController.evaluateJavascript("if(document.getElementsByClassName('footer')[0] != null) document.getElementsByClassName('footer')[0].style.display='none';");
    //             await _myController.evaluateJavascript("if(document.getElementsByClassName('sub-nav')[0] != null) document.getElementsByClassName('sub-nav')[0].style.display='none';");
    //             await _myController.evaluateJavascript("if(document.getElementsByClassName('home-footer')[0] != null) document.getElementsByClassName('home-footer')[0].style.display='none';");
    //           },
    //           gestureNavigationEnabled: true,
    //         ),
    //       ),
    //       !loading ? Center(child: CircularProgressIndicator()) : SizedBox()
    //     ],
    //   ),
    // );
  }
}
