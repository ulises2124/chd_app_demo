// import 'dart:_http';
import 'dart:convert';
import 'dart:async';
import 'package:chd_app_demo/utils/NetworkData.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chd_app_demo/utils/HttpHelper.dart';

class ComparadorServices {
  static Future consultarPrecio(upc) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String idWallet = prefs.getString('idWallet');
    final response = await HttpHelper.post(NetworkData.urlComparador, headers: {
      "Content-Type": "application/x-www-form-urlencoded"
    }, body: {
      "token": idWallet,
      "upc": upc,
      "cantidad": '1',
      "cantidadAcumulada": '1',
    }).timeout(NetworkData.timeout);
    print(response);
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody;
    } else {
      return 'error';
    }
  }
}
