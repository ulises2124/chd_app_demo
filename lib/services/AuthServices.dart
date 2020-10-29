import 'package:chd_app_demo/utils/NetworkData.dart';
import 'package:chd_app_demo/utils/singinUserData.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:chd_app_demo/utils/HttpHelper.dart';

import 'package:http/http.dart' as http;

class AuthServices {
  static Future postGCloudLogin(String user, String pass) async {
    print(user);
    print(pass);
    String url = NetworkData.urlLogin;
    var headers = {"Content-Type": "application/json"};
    Map data = user != null && pass != null ? {'username': user, 'password': pass} : {};
    var response = await HttpHelper.post(
      url,
      headers: headers,
      body: utf8.encode(json.encode(data)),
    );

    // print(response.body.toString());

    if (response.statusCode != null) {
      final resBody = json.decode(response.body);
      return resBody;
    } else {
      throw Exception('Failed gcloud login');
    }
  }

  static Future postSocialUserLogin(String token, String redSocial) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> headers = {"Content-Type": "application/x-www-form-urlencoded"};
    Map<String, dynamic> body = {};
    if (redSocial == 'facebook') {
      body = {
        "client_id": "occ-chedraui",
        "client_secret": "Ch3dr@u1!",
        "grant_type": "facebook",
        "code": token,
      };
    } else {
      body = {
        "client_id": "occ-chedraui",
        "client_secret": "Ch3dr@u1!",
        "grant_type": "google",
        "code": token,
      };
    }
    var url = NetworkData.hybrisLogin;
    final response = await HttpHelper.post(url, headers: headers, body: body).timeout(NetworkData.timeout);
    print(response);
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      prefs.setString('accessToken', resBody['access_token']);
      prefs.setDouble('loginTime', DateTime.now().millisecondsSinceEpoch / 1000);
      prefs.setInt('expiresIn', resBody['expires_in']);
      return resBody['access_token'];
    } else {
      print(response);
      return null;
    }
  }

  static Future postSocialUserToken(String redSocial) async {
    FlutterWebviewPlugin webview = new FlutterWebviewPlugin();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String socialToken;
    String loginUrl = NetworkData.urlLoginFacebook;
    await webview.launch(loginUrl, withJavascript: true, clearCache: true);
    var e = webview.onUrlChanged.listen((String url) async {
      print(url);
      if (url.contains("${NetworkData.urlCurrentEnv}/?code=") || url.contains("${NetworkData.urlCurrentEnv}/?code=") || url.contains('?code=')) {
        var currentType = url.split('code=');
        currentType = currentType[1].split('#_=_');
        print(currentType[0]);
        await webview.close();
        webview.dispose();
        socialToken = currentType[0];
        await prefs.setString('socialToken', socialToken);
      } else if (url.contains("${NetworkData.urlCurrentEnv}/?error=true#_=_") || url.contains('error_reason=user_denied')) {
        await webview.close();
        webview.dispose();
        socialToken = null;
        await prefs.setString('socialToken', socialToken);
      }
    }).asFuture();
    await e.then((onValue) {
      return socialToken;
    }).catchError((onError) {
      return onError;
    });
    webview.onDestroy.listen((data) {
      print('WEBVIEW DESTROYED');
    }, onError: (err) {
      print('WEBVIEW DESTROYED ON ERROR');
      print(err);
    }, onDone: () {
      print('WEBVIEW DESTROYED ON DONE');
    });
  }

  static Future postGCloudSignIn(SinginUserData singinUserData) async {
    String url = NetworkData.gCloudSignIn;
    var headers = {"Content-Type": "application/json"};
    Map data = {'nombre': singinUserData.nombre, 'apPaterno': singinUserData.paterno, 'apMaterno': singinUserData.materno != null ? (singinUserData.materno.length > 1 ? singinUserData.materno : "--") : "--", 'correo': singinUserData.email, 'contrasenia': singinUserData.password, 'celular': singinUserData.celular, 'cp': singinUserData.cpostal};
    var response = await HttpHelper.post(
      url,
      headers: headers,
      body: utf8.encode(json.encode(data)),
    );

    if (response.statusCode != null) {
      final resBody = json.decode(response.body);
      return resBody;
    } else {
      throw Exception('Failed gcloud signin');
    }
  }

  static Future postGcloudRecoverPassword(String recoverEmail) async {
    String url = NetworkData.gCloudRecoverPassword;

    var headers = {
      "Content-Type": "application/json",
    };

    Map data = {
      'userId': recoverEmail,
    };

    var response = await HttpHelper.post(
      url,
      headers: headers,
      body: utf8.encode(json.encode(data)),
    );

    if (response.statusCode != null) {
      final resBody = json.decode(response.body);
      return resBody;
    } else {
      throw Exception('Failed hybris recovery');
    }
  }

  static Future getUserToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user = prefs.getString('email') ?? null;
    final String pass = prefs.getString('password') ?? null;
    final resultLogin = await AuthServices.postGCloudLogin(user, pass);
    prefs.setString('accessToken', resultLogin['accessToken']);
    prefs.setDouble('loginTime', DateTime.now().millisecondsSinceEpoch / 1000);
    prefs.setInt('expiresIn', resultLogin['expiresIn']);
    return resultLogin['accessToken'];
  }

  static Future getHybrisUserInfo() async {
    // final token = await getUserToken();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user = prefs.getString('email');
    // var headers = {
    //   "Content-Type": "application/json",
    //   "Authorization": "Bearer $token",
    // };
    String url = NetworkData.hybrisGetUserInfo + '?atributoBusqueda=correo&valor=' + user;

    final response = await HttpHelper.get(
      url,
      // headers: headers
    );

    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      // print(resBody.toString());
      return resBody;
    } else {
      throw Exception('Failed get shopping cart');
    }
  }

  static Future<bool> getHybrisUser(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = NetworkData.hybrisUser;
    Map<String, String> headers = {'Authorization': 'Bearer $token'};
    final response = await HttpHelper.get(url, headers: headers);

    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      final userPhones = resBody['phoneNumbers'];
      prefs.setString('email', resBody['uid']);
      prefs.setString('delivery-userName', resBody['firstName']);
      prefs.setString('delivery-userLastName', resBody['lastName']);
      prefs.setString('delivery-userSecondLastName', resBody['secondLastName']);
      prefs.setString('account-userName', resBody['firstName']);
      if (userPhones != null && userPhones.length > 0) {
        if (userPhones[0]['number'] != null) {
          final String phone = userPhones[0]['number'];
          if (phone.startsWith('521'))
            prefs.setString('delivery-telefono', phone.substring(3));
          else
            prefs.setString('delivery-telefono', phone);
        }
      }
      return true;
    } else {
      return false;
    }
  }

  static Future deviceData(deviceID, name, email, platform, version, tokenFirebase) async {
    String url = NetworkData.urlDeviceID;

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Basic YWR2bmNkOk4zZVpxUFsjd0R1XiljdXg",
    };

    Map data = {'deviceId': deviceID, 'name': name, 'email': email, 'platform': platform, 'version': version, 'tokenFirebase': tokenFirebase};

    var response = await http.post(
      url,
      headers: headers,
      body: utf8.encode(json.encode(data)),
    ).timeout(Duration(seconds: 5));

    // print(response);
    if (response.statusCode == 202 || response.statusCode == 201) {
      final resBody = json.decode(response.body);
      return resBody;
    } else {
      return null;
    }
  }

  static Future getSessionStatus() async {
    String url = NetworkData.urlSessionStatus;

    var response = await http.get(
      url,
    ).timeout(Duration(seconds: 30));

    // print(response);
    if (response.statusCode == 200) {
      final resBody = json.decode(response.body);
      return resBody;
    } else {
      // throw Exception('Session Check Failed');
    }
  }
}
