import 'dart:convert';
import 'dart:async';
import 'package:chd_app_demo/utils/NetworkData.dart';

import 'package:chd_app_demo/utils/HttpHelper.dart';

class BovedaService {
  static Future getWalletByEmail(String email) async {
    String url = NetworkData.urlGetWalletByEmail.replaceAll('{{email}}', email);
    final response = await HttpHelper.get(url).timeout(NetworkData.timeout);
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      String wallet = "";
      try {
        if (resBody[0]['tblWallets'].length > 0) {
          wallet = resBody[0]['tblWallets'][0]['idWallet'];
        } else {
          wallet = resBody[0]['token'];
        }
      } catch (err) {
        wallet = null;
      }
      return wallet;
    } else {
      return null;
    }
  }

  static Future getCartera(String idWallet) async {
    String url = NetworkData.urlBovedaCartera;
    Map<String, String> headers = {
      "Content-Type": "application/json",
      'Accept': 'application/json',
    };
    Map body = {
      "tarjetas": [
        {"idWallet": idWallet}
      ]
    };
    final response = await HttpHelper.post(url, headers: headers, body: json.encode(body), timeout: 'extended');

    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      final List cardsResponse = resBody['tarjetas'];

      List cardsFiltered = [];
      cardsResponse.forEach((l) {
        var cardsFilteredAux;
        try {
          cardsFilteredAux = cardsFiltered.firstWhere((a) {
            return a['identificador'] == l['identificador'];
          });
        } catch (e) {} finally {
          if (cardsFilteredAux == null) {
            cardsFiltered.add(l);
          }
        }
      });

      return cardsFiltered;
    } else {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      print(resBody);
      return null;
    }
  }

  static Future createCard(var cardData) async {
    String url = NetworkData.urlAddCard;
    Map<String, String> headers = {"Content-Type": "application/json"};

    final response = await HttpHelper.post(url, headers: headers, body: cardData);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody['tarjetas'];
    } else {}
  }

  static Future getTarjeta(cardData) async {
    String url = NetworkData.urlBuscarTarjeta;
    Map<String, String> headers = {'Content-Type': 'application/json'};
    final response = await HttpHelper.post(url, headers: headers, body: cardData, timeout: 'extended');

    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody['tarjetas'] != null && resBody['tarjetas'].length > 0 ? resBody['tarjetas'][0] : null;
    } else {
      return null;
    }
  }

  static Future getTarjetaForOpenPay(cardData) async {
    String url = NetworkData.urlGetTarjeta;
    Map<String, String> headers = {'Content-Type': 'application/json'};
    final response = await HttpHelper.post(url, headers: headers, body: cardData);

    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody['tarjetas'] != null && resBody['tarjetas'].length > 0 ? resBody['tarjetas'][0] : null;
    } else {
      return null;
    }
  }

  static Future getInfoTarjeta(cardData) async {
    String url = NetworkData.urlGetInfoTarjeta;
    Map<String, String> headers = {'Content-Type': 'application/json'};
    final response = await HttpHelper.post(url, headers: headers, body: cardData);

    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody;
    } else {
      return null;
    }
  }
}
