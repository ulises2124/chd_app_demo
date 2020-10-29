import 'dart:convert';
import 'dart:async';
import 'package:chd_app_demo/utils/NetworkData.dart';
import 'package:chd_app_demo/views/Monedero/CardData.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chd_app_demo/utils/HttpHelper.dart';

class MonederoServices {
  static Future getIdMonedero(String idWallet) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = NetworkData.urlIdMonedero;
    Map<String, String> headers = {"Content-Type": "application/x-www-form-urlencoded"};
    Map<String, dynamic> body = {"idWallet": idWallet};
    print("POST id Monedero----->" + url);
    final response = await HttpHelper.post(url, headers: headers, body: body);
    print({"idWallet": idWallet});
    print("Response body id monedero" + response.body);
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      print("resBody--->>>" + resBody.toString());
      prefs.setString('monedero', resBody["monederos"][0]['monedero'] ?? '');
      return resBody["monederos"];
    } else {
      return null;
    }
  }

  static Future getSaldoMonedero(String idMonedero) async {
    if (idMonedero != null) {
      String url = NetworkData.urlSaldoMonedero.replaceAll("{{idMonedero}}", idMonedero);
      print("GET Saldo monedero----->" + url);
      final response = await HttpHelper.get(url);
      print(response.body);
      if (response.statusCode == 200) {
        final resBody = json.decode(utf8.decode(response.bodyBytes));
        return resBody;
      } else {
        return null;
      }
    }
  }

  static Future addCard(CardData cardData) async {
    String url = NetworkData.urlAddCard;
    Map<String, String> headers = {
      "Content-Type": "application/json",
      'Accept': 'application/json',
    };
    Map<String, dynamic> body = {
      "tarjetas": [
        {"idWallet": cardData.idWallet, "numTarjeta": cardData.numTarjeta, "tipoTarjeta": cardData.tipoTarjeta, "bancoEmisor": cardData.bancoEmisor, "aliasTarjeta": cardData.aliasTarjeta, "nomTitularTarj": cardData.nomTitularTarj, "cvv": cardData.cvv, "fecExpira": cardData.fecExpira, "deviceSessionId": cardData.deviceSessionId}
      ]
    };

    print("post---->" + url);

    final response = await HttpHelper.post(
      url,
      headers: headers,
      body: json.encode(body),
    );
    print(response.body);
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody;
    } else {
      return null;
    }
  }

  static Future editCard(CardData cardData) async {
    String url = NetworkData.urlEditCard;
    Map<String, String> headers = {
      "Content-Type": "application/json",
      'Accept': 'application/json',
    };
    Map<String, dynamic> body = {
      "tarjetas": [
        {"idWallet": cardData.idWallet, "numTarjeta": cardData.numTarjeta, "aliasTarjeta": cardData.aliasTarjeta}
      ]
    };
    print("post---->" + url);
    final response = await HttpHelper.post(
      url,
      headers: headers,
      body: json.encode(body),
    );
    print(response.body);
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody;
    } else {
      return null;
    }
  }

  static Future deleteCard(CardData cardData) async {
    String url = NetworkData.urlDeleteCard;
    Map<String, String> headers = {
      "Content-Type": "application/json",
      'Accept': 'application/json',
    };
    Map<String, dynamic> body = {
      "tarjetas": [
        {"idWallet": cardData.idWallet, "numTarjeta": cardData.numTarjeta}
      ]
    };
    print("post---->" + url);
    final response = await HttpHelper.post(url, headers: headers, body: json.encode(body));
    print(response.body);
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody;
    } else {
      return null;
    }
  }

  static Future vincularMonedero(String idWallet, String numeroMonedero, String contrasenia) async {
    print("Paso 1...");

    String url = NetworkData.urlMonederoVincular;
    var headers = {"Content-Type": "application/json"};
    Map data = {"idWallet": idWallet, "nroMonedero": numeroMonedero, "contrasenia": contrasenia};

    var response = await HttpHelper.post(url, headers: headers, body: utf8.encode(json.encode(data)));

    print("Paso 2...");

    print(response.body.toString());

    if (response.statusCode != null) {
      final resBody = json.decode(response.body);
      return resBody;
    } else {
      throw Exception('Failed gcloud login');
    }
  }

  static Future<dynamic> getSaldoMonederoRCS(String idMonedero) async {
    print("getSaldoMonederoRCS");
    String url = NetworkData.urlSaldoMonederoRCS.replaceAll("{{idMonedero}}", idMonedero);
    Map<String, String> headers = {"x-api-token": NetworkData.monederoRcsToken};
    try {
      final response = await HttpHelper.get(url, headers: headers).timeout(NetworkData.timeout);
      print(response.body);
      if (response.statusCode == 200) {
        final resBody = json.decode(utf8.decode(response.bodyBytes));
        return resBody;
      } else {
        return null;
      }
    } catch (e) {
      print('exception');
      print(e);
    }
  }
}
