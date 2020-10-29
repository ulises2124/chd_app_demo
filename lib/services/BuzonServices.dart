import 'dart:convert';
import 'dart:async';
import 'package:chd_app_demo/utils/NetworkData.dart';

import 'package:chd_app_demo/utils/HttpHelper.dart';

class BuzonServices {
  static Future getBuzon(idWallet) async {
    String url = NetworkData.urlBuzonConsultar.replaceAll('{{idWallet}}', idWallet);
    final response = await HttpHelper.get(url);
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody['mensaje'];
    } else {
      return "";
    }
  }

  static Future getBuzonKentico() async {
    String url = NetworkData.urlKenticoApp + '?system.type=notificacion_push';
    final response = await HttpHelper.get(url);
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody;
    } else {
      return null;
    }
  }

  static Future markAsRead(idWallet, idMessage) async {
    String url = NetworkData.urlBuzonLeido.replaceAll('{{idWallet}}', idWallet).replaceAll('{{idMessage}}', idMessage);
    print(url);
    final response = await HttpHelper.get(url);
    print(response.statusCode);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  // static Future login() async {
  //   String accessToken;
  //   final response = await HttpHelper.post(
  //     'https://us-central1-chedraui-pre.cloudfunctions.net/seguridad/login',
  //     body: {
  //       'username': 'daniel_test@advncdmanknd.com',
  //       'password': 'asdfQWERTY92'
  //     },
  //   );
  //   final resBody = json.decode(utf8.decode(response.bodyBytes));
  //   return resBody['accessToken'];
  // }
}
