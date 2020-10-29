import 'package:chd_app_demo/utils/NetworkData.dart';
import 'package:chd_app_demo/utils/singinUserData.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chd_app_demo/utils/HttpHelper.dart';

class CuponesServices {
// asociarCupon
  static Future getCupones() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String codCliente = prefs.getString('monedero') ?? '';

    Map data = {
      'monedero': codCliente,
    };
    Map<String, String> headersSetAddress = {
      "Content-Type": "application/json",
    };
    final response = await HttpHelper.post(
      NetworkData.consultarCuponesPorMonedero,
      headers: headersSetAddress,
      body: utf8.encode(json.encode(data)),
    )
    .timeout(NetworkData.timeout);
    
    print(response);
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      // printJsonPretty(resBody);
      return resBody;
    } else {
      throw Exception('Failed get coupons');
    }
  }

  static Future getCuponesId(String codCupon) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String codCliente = prefs.getString('codCliente');
    final String idWallet = prefs.getString('idWallet');

    final body = {
      'codCliente': codCliente,
      'idWallet': idWallet,
      'codCupon': codCupon,
    };

    final response = await HttpHelper.post(
      NetworkData.consultarCupones,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: body,
    )
    .timeout(NetworkData.timeout);

    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      // printJsonPretty(resBody);
      return resBody;
    } else {
      throw Exception('Failed get coupons');
    }
  }

  static Future asociarCupon(String codCupon, String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String codCliente = prefs.getString('codCliente') ?? '';
    final String idWallet = prefs.getString('idWallet') ?? '';

    final body = {
      'codCliente': codCliente,
      'idWallet': idWallet,
      'codCupon': codCupon,
      'token': token,
    };

    final response = await HttpHelper.post(
      NetworkData.asociarCupon,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: body,
    )
    .timeout(NetworkData.timeout);

    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      // printJsonPretty(resBody);
      return resBody;
    } else {
      throw Exception('Failed get coupons');
    }
  }
}
