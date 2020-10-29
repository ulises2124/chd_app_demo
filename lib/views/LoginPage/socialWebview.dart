import 'dart:async';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/utils/NetworkData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  final String redSocial;

  LoginScreen({
    this.redSocial,
    Key key,
  }) : super(key: key);
  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final flutterWebviewPlugin = new FlutterWebviewPlugin();

  StreamSubscription _onDestroy;
  StreamSubscription<String> _onUrlChanged;
  StreamSubscription<WebViewStateChanged> _onStateChanged;

  String token;

  String socialToken;

  var canGoBack = true;

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    _onDestroy.cancel();
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    flutterWebviewPlugin.cleanCookies();

    flutterWebviewPlugin.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    flutterWebviewPlugin.close();

    // Add a listener to on destroy WebView, so you can make came actions.
    _onDestroy = flutterWebviewPlugin.onDestroy.listen((_) {
      print("destroy");
    });
    flutterWebviewPlugin.cleanCookies();
    _onStateChanged = flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      switch (state.type) {
        case WebViewState.shouldStart:
          if (state.url != 'about:blank') flutterWebviewPlugin.hide();

          break;
        case WebViewState.startLoad:
          flutterWebviewPlugin.hide();

          break;

        case WebViewState.finishLoad:
          print(state.url);
          if (state.url.contains('app_id=') || state.url.contains('api_key=')) {
            setState(() {
              canGoBack = false;
            });
          } else {
            setState(() {
              canGoBack = true;
            });
          }
          if (state.url.contains("${NetworkData.urlCurrentEnv}/?code=") || state.url.contains("${NetworkData.urlCurrentEnv}/?code=") || state.url.contains('?code=')) {
            var currentType = state.url.split('code=');
            currentType = currentType[1].split('#_=_');
            print(currentType[0]);
            // await webview.close();
            // webview.dispose();
            socialToken = currentType[0];
            print(socialToken);
            Navigator.pop(context, socialToken);
            // await prefs.setString('socialToken', socialToken);
          } else if (state.url.contains('error_reason=user_denied')) {
            socialToken = 'denied';
            Navigator.pop(context, socialToken);
          } else if (state.url.contains("${NetworkData.urlCurrentEnv}/?error=true#_=_")) {
            // await webview.close();
            // webview.dispose();
            socialToken = 'error';
            Navigator.pop(context, socialToken);
            // await prefs.setString('socialToken', socialToken);
          }
          Future.delayed(const Duration(milliseconds: 1000), () {
            flutterWebviewPlugin.show();
          });

          break;
        default:
      }
    });
    // Add a listener to on url changed
    _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) async {});
  }

  @override
  Widget build(BuildContext context) {
    String loginUrl = NetworkData.urlLoginFacebook;

    return new WebviewScaffold(
      url: loginUrl,
      clearCache: true,
      clearCookies: true,
      appCacheEnabled: false,
      withJavascript: true,
      withZoom: false,
      initialChild: Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      appBar: AppBar(
        backgroundColor: HexColor('#385898'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => canGoBack
                  ? flutterWebviewPlugin.goBack().then((onValue) {
                      print(onValue);
                    })
                  : Navigator.pop(context),
            );
          },
        ),
        // gradient: DataUI.appbarGradient,
        // title: Text(
        //   'Centro de ayuda',
        //   style: DataUI.appbarTitleStyle,
        // ),
      ),
    );
  }
}
//HexColor('#385898')
