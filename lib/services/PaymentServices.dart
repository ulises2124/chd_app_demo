// import 'dart:_http';
import 'dart:convert';
import 'dart:async';
//import 'dart:io';
import 'package:chd_app_demo/services/AuthServices.dart';
import 'package:chd_app_demo/services/CarritoServices.dart';
import 'package:chd_app_demo/utils/NetworkData.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chd_app_demo/utils/HttpHelper.dart';

class PaymentServices {
  static Future getPayments() async {
    Map<String, dynamic> session = await CarritoServices.getSessionVars();
    final bool isLoggedIn = session['isLoggedIn'];
    final String guid = session['guid'];
    final String userToken = session['accessToken'];

    if (isLoggedIn) {
      String url = NetworkData.urlPayMethods;
      Map<String, String> headers = {
        "Authorization": "Bearer $userToken",
      };
      final response = await HttpHelper.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final resBody = json.decode(utf8.decode(response.bodyBytes));
        return resBody;
      } else {
        throw Exception('Failed to load payment methods.');
      }
    } else {
      if (guid != null) {
        String url = NetworkData.urlPayMethodsAnonymous.replaceAll('{{cartId}}', guid);
        Map<String, String> headers = {
          "Authorization": "Bearer $userToken",
        };
        final response = await HttpHelper.get(
          url,
          headers: headers,
        );

        if (response.statusCode == 200) {
          final resBody = json.decode(utf8.decode(response.bodyBytes));
          return resBody;
        } else {
          throw Exception('Failed to load anonymous payment methods.');
        }
      }
    }
  }

  static Future rechargeMonedero(body) async {
    String urlRechargeMonedero = NetworkData.urlRechargeMonedero;

    Map<String, String> headers = {'Content-Type': 'application/json'};

    final response = await HttpHelper.post(urlRechargeMonedero, headers: headers, body: json.encode(body)).timeout(NetworkData.timeout);

    final resBody = json.decode(utf8.decode(response.bodyBytes));

    return resBody;
  }

  static Future sendPaymentOpenPay(newCharge) async {
    String url = NetworkData.openPayUrl;
    Map<String, String> headers = {'Content-Type': 'application/json'};
    final response = await HttpHelper.post(url, headers: headers, body: newCharge);
    print(newCharge);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      print(resBody['status']);
      return resBody;
    } else {}
  }

  static Future getTokenRegistredCard(registredCardData) async {
    String url = NetworkData.urlTokenTarjetaRegistrada;
    Map<String, String> headers = {'Content-Type': 'application/json'};
    final response = await HttpHelper.post(url, headers: headers, body: registredCardData);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~TOKEN REGISTED CARD');
      print(resBody);
      return resBody;
    } else {}
  }

  static Future getTokenOpenPayCard(registredCardData) async {
    String url = NetworkData.urlBuscarTarjeta;
    Map<String, String> headers = {'Content-Type': 'application/json'};
    final response = await HttpHelper.post(url, headers: headers, body: registredCardData);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~TOKEN REGISTED CARD OPENPAY');
      Map x = resBody['tarjetas'][0];
      x.forEach((k, v) => print('K: $k, V: $v'));
      return resBody['tarjetas'] != null && resBody['tarjetas'].length > 0 ? resBody['tarjetas'][0] : null;
    } else {
      return null;
    }
  }

  static Future getAssociatedStores(cartCode) async {
    Map<String, dynamic> session = await CarritoServices.getSessionVars();
    final bool isLoggedIn = session['isLoggedIn'];
    final String guid = session['guid'];
    final String userToken = session['accessToken'];
    final String email = session['email'];

    if (isLoggedIn) {
      String url = NetworkData.urlAssociatedStores.replaceAll('{{email}}', email).replaceAll('{{cartCode}}', cartCode);
      Map<String, String> headers = {'Authorization': 'Bearer $userToken'};
      final response = await HttpHelper.get(url, headers: headers);

      if (response.statusCode == 200) {
        final resBody = json.decode(utf8.decode(response.bodyBytes));
        return resBody['associatedStoreMedias'];
      } else {}
    } else {
      if (guid != null) {
        String url = NetworkData.urlAssociatedStores.replaceAll('{{email}}', "anonymous").replaceAll('{{cartCode}}', guid);
        print(url);
        try {
          final response = await HttpHelper.get(url);

          if (response.statusCode == 200 || response.statusCode == 201) {
            final resBody = json.decode(utf8.decode(response.bodyBytes));
            return resBody['associatedStoreMedias'];
          } else {
            final resBody = json.decode(utf8.decode(response.bodyBytes));
            print(resBody);
          }
        } catch (e) {
          print(e);
        }
      }
    }
  }

  static Future setPaymentMethod(paymentObject, String cartCode) async {
    Map<String, dynamic> session = await CarritoServices.getSessionVars();
    final bool isLoggedIn = session['isLoggedIn'];
    final String guid = session['guid'];
    final String userToken = session['accessToken'];
    final String email = session['email'];

    if (isLoggedIn) {
      final String url = NetworkData.urlSetPaymethod.replaceAll('{{email}}', email).replaceAll('{{cartCode}}', cartCode);
      Map<String, String> headers = {'Authorization': 'Bearer $userToken', 'Content-Type': 'application/json'};
      final response = await HttpHelper.post(url, headers: headers, body: json.encode(paymentObject));
      print(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final resBody = json.decode(utf8.decode(response.bodyBytes));
        return resBody;
      } else {
        final resBody = json.decode(utf8.decode(response.bodyBytes));
        print(resBody);
      }
    } else {
      if (guid != null) {
        String url = NetworkData.urlSetPaymethod.replaceAll('{{email}}', "anonymous").replaceAll('{{cartCode}}', guid);
        Map<String, String> headers = {'Authorization': 'Bearer $userToken', 'Content-Type': 'application/json'};
        final response = await HttpHelper.post(url, headers: headers, body: json.encode(paymentObject));
        print(response.statusCode);
        if (response.statusCode == 200 || response.statusCode == 201) {
          final resBody = json.decode(utf8.decode(response.bodyBytes));
          return resBody;
        } else {}
      }
    }
  }

  static Future setPaymentMethodMonedero(paymentObject, String cartCode) async {
    Map<String, dynamic> session = await CarritoServices.getSessionVars();
    final bool isLoggedIn = session['isLoggedIn'];
    final String guid = session['guid'];
    final String userToken = session['accessToken'];
    final String email = session['email'];

    if (isLoggedIn) {
      String url = NetworkData.setPaymentMethodRechargeMonederoCardUrl.replaceAll('{{ email }}', email).replaceAll('{{ code }}', cartCode);
      Map<String, String> headers = {'Authorization': 'Bearer $userToken', 'Content-Type': 'application/json'};
      final response = await HttpHelper.post(url, headers: headers, body: json.encode(paymentObject));
      print(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final resBody = json.decode(utf8.decode(response.bodyBytes));
        return resBody;
      } else {}
    } else {
      if (guid != null) {
        String url = NetworkData.urlSetPaymethod.replaceAll('{{email}}', "anonymous").replaceAll('{{cartCode}}', guid);
        Map<String, String> headers = {'Authorization': 'Bearer $userToken', 'Content-Type': 'application/json'};
        final response = await HttpHelper.post(url, headers: headers, body: json.encode(paymentObject));
        print(response.statusCode);
        if (response.statusCode == 200 || response.statusCode == 201) {
          final resBody = json.decode(utf8.decode(response.bodyBytes));
          return resBody;
        } else {}
      }
    }
  }

  static Future cleanPaymentMethod() async {
    Map<String, dynamic> session = await CarritoServices.getSessionVars();
    final bool isLoggedIn = session['isLoggedIn'];
    final String guid = session['guid'];
    final String userToken = session['accessToken'];
    final String email = session['email'];

    if (isLoggedIn) {
      final String url = NetworkData.urlSetPaymethod.replaceAll('{{email}}', email).replaceAll('{{cartCode}}', "current");
      Map<String, String> headers = {'Authorization': 'Bearer $userToken', 'Content-Type': 'application/json'};
      final response = await HttpHelper.delete(url, headers: headers);
      print(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 202) {
        return;
      } else {}
    } else {
      if (guid != null) {
        String url = NetworkData.urlSetPaymethod.replaceAll('{{email}}', "anonymous").replaceAll('{{cartCode}}', guid);
        Map<String, String> headers = {'Authorization': 'Bearer $userToken', 'Content-Type': 'application/json'};
        final response = await HttpHelper.delete(url, headers: headers);
        print(response.statusCode);
        if (response.statusCode == 200 || response.statusCode == 201) {
          return;
        } else {}
      }
    }
  }

  static Future placeOrder(cartCode) async {
    Map<String, dynamic> session = await CarritoServices.getSessionVars();
    final bool isLoggedIn = session['isLoggedIn'];
    final String guid = session['guid'];
    final String userToken = session['accessToken'];

    if (isLoggedIn) {
      String url = NetworkData.urlPlaceOrder.replaceAll('{{cartCode}}', cartCode);
      Map<String, String> headers = {'Authorization': 'Bearer $userToken'};
      final response = await HttpHelper.post(url, headers: headers, body: {});
      String status = response.statusCode.toString();
      print('placeOrder');
      print(status);

      if (status.startsWith('2')) {
        final resBody = json.decode(utf8.decode(response.bodyBytes));
        bool req3ds = resBody['requires3ds'] ?? false;
        return req3ds ? null : resBody;
      } else {
        final resBody = json.decode(utf8.decode(response.bodyBytes));
        print(resBody);
        return null;
      }
    } else {
      if (guid != null) {
        String url = NetworkData.urlPlaceOrderAnonymous.replaceAll('{{cartCode}}', guid);
        Map<String, String> headers = {'Authorization': 'Bearer $userToken'};
        final response = await HttpHelper.post(url, headers: headers, body: {});
        String status = response.statusCode.toString();

        if (status.startsWith('2')) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.remove('carrito_guid');
          final resBody = json.decode(utf8.decode(response.bodyBytes));
          return resBody;
        } else {
          return null;
        }
      }
    }
  }

  static Future getPaynetPaymentDetail(orderCode) async {
    Map<String, dynamic> session = await CarritoServices.getSessionVars();
    final String userToken = session['accessToken'];

    final response = await HttpHelper.get(NetworkData.urlGetPaynetPaymentDetail.replaceAll('{{orderCode}}', orderCode), headers: {'Authorization': 'Bearer ${userToken}'});
    if (response.statusCode == 200 || response.statusCode == 201) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody;
    } else {
      //print(response.body);
      //throw Exception('Error al obtener detalle de Paynet.');
      return null;
    }
  }

  static Future getTokenFromOpenPay(var cardData) async {
    String url = NetworkData.urlTokenOpenPay;

    Map<String, String> headers = {'Authorization': 'Basic ${NetworkData.openPayKey}', 'Content-Type': 'application/json'};

    final response = await HttpHelper.post(url, headers: headers, body: cardData);

    if (response.statusCode.toString().startsWith('2') || response.statusCode.toString().startsWith('4')) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody;
    } else {
      return null;
    }
  }

  static Future getPointsFromOpenPay(String token) async {
    String url = NetworkData.urlPointsOpenPay.replaceAll('{TOKEN_ID}', token);

    Map<String, String> headers = {'Authorization': 'Basic ${NetworkData.openPayKey}', 'Content-Type': 'application/json'};

    final response = await HttpHelper.get(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody;
    } else {}
  }

  static Future getInfoCardFromOpenPay(cardData) async {
    String url = NetworkData.urlCardsOpenPay;

    Map<String, String> headers = {'Authorization': 'Basic ${NetworkData.openPayKey}', 'Content-Type': 'application/json'};

    final response = await HttpHelper.post(url, headers: headers, body: cardData);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      final String tarjetaId = resBody['id'];
      if (tarjetaId != null) {
        await HttpHelper.delete(url + '/$tarjetaId', headers: headers);
        return resBody;
      }
    } else {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      print(resBody);
    }
  }

  static Future updateCvv2OnOpenpay(tokenId, customerId, newCvv2) async {
    String url = NetworkData.urlUpdateCvv2OpenPay;
    url = url.replaceAll("{CUSTOMER_ID}", customerId);
    url = url.replaceAll("{TOKEN_ID}", tokenId);

    Map<String, String> headers = {
      'Authorization': 'Basic ${NetworkData.openPayKey}',
      'Content-Type': 'application/json',
    };

    var body = json.encode({
      "cvv2": newCvv2,
    });

    final response = await HttpHelper.put(url, headers: headers, body: body);

    print('updateCvv2OnOpenpay');
    print(response.statusCode);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  static Future getInstallmetsForCard() async {
    Map<String, dynamic> session = await CarritoServices.getSessionVars();
    final bool isLoggedIn = session['isLoggedIn'];
    final String guid = session['guid'];
    final String userToken = session['accessToken'];

    if (isLoggedIn) {
      String url = NetworkData.urlCardInstallments + '?fields=FULL';
      Map<String, String> headers = {'Authorization': 'Bearer $userToken'};
      final response = await HttpHelper.get(url, headers: headers);

      if (response.statusCode == 200) {
        final resBody = json.decode(utf8.decode(response.bodyBytes));
        return resBody['installments'];
      } else {
        print(response.body);
        throw Exception('Error al obtener Installments.');
      }
    } else {
      if (guid != null) {
        String url = NetworkData.urlCardInstallmentsAnonymous.replaceAll('{{guid}}', guid) + '?fields=FULL';
        Map<String, String> headers = {
          'Authorization': 'Bearer $userToken',
        };
        final response = await HttpHelper.get(url, headers: headers);

        if (response.statusCode == 200) {
          final resBody = json.decode(utf8.decode(response.bodyBytes));
          return resBody['installments'];
        } else {
          print(response.body);
          throw Exception('Error al obtener Installments.');
        }
      }
    }
  }

  static Future<bool> setInstallmetsForCard(selectedInstallments) async {
    Map<String, dynamic> session = await CarritoServices.getSessionVars();
    final bool isLoggedIn = session['isLoggedIn'];
    final String guid = session['guid'];
    final String userToken = session['accessToken'];

    if (isLoggedIn) {
      String url = NetworkData.urlCardInstallments;
      Map<String, String> headers = {'Authorization': 'Bearer $userToken', "Content-Type": "application/x-www-form-urlencoded"};
      final response = await HttpHelper.post(url, headers: headers, body: selectedInstallments);

      if (response.statusCode.toString().startsWith("2")) {
        //final resBody = json.decode(utf8.decode(response.bodyBytes));
        return true;
      } else {
        print(response.body);
        throw Exception('Error al asignar installments al carrito.');
      }
    } else {
      if (guid != null) {
        String url = NetworkData.urlCardInstallmentsAnonymous.replaceAll("{{guid}}", guid);
        Map<String, String> headers = {'Authorization': 'Bearer $userToken', "Content-Type": "application/x-www-form-urlencoded"};
        final response = await HttpHelper.post(url, headers: headers, body: selectedInstallments);

        if (response.statusCode.toString().startsWith("2")) {
          //final resBody = json.decode(utf8.decode(response.bodyBytes));
          return true;
        } else {
          print(response.body);
          throw Exception('Error al asignar installments al carrito.');
        }
      }
    }
  }

  static Future setPaymentMethodPayPalWallet(paymentObject, String optionCode, String nroMonedero) async {
    Map<String, dynamic> session = await CarritoServices.getSessionVars();
    final bool isLoggedIn = session['isLoggedIn'];
    final String guid = session['guid'];
    final String userToken = session['accessToken'];
    final String email = session['email'];

    print('userToken $userToken');
    print('email $email');
    print('optionCode $optionCode');
    print('nroMonedero $nroMonedero');

    print('paymentObject');
    print(paymentObject);

    String createMonederoRechargeOperationUrl = NetworkData.createMonederoRechargeOperationUrl;
    createMonederoRechargeOperationUrl = createMonederoRechargeOperationUrl.replaceAll('{{ email }}', email);
    Map<String, String> headersCreateRecharge = {'Authorization': 'Bearer $userToken', 'Content-Type': 'application/json'};
    Map data = {"monederoNumber": nroMonedero, "optionCode": optionCode};

    print(createMonederoRechargeOperationUrl);
    final responseCreate = await HttpHelper.post(createMonederoRechargeOperationUrl, headers: headersCreateRecharge, body: json.encode(data));

    print(responseCreate.statusCode);
    var resBodyCreate;
    if (responseCreate.statusCode == 200 || responseCreate.statusCode == 201) {
      resBodyCreate = json.decode(utf8.decode(responseCreate.bodyBytes));
      if (resBodyCreate['code'] == null) return resBodyCreate;
    } else {
      return null;
    }

    String setPaymentMethodRechargeMonederoPayPalUrl = NetworkData.setPaymentMethodRechargeMonederoPayPalUrl;

    setPaymentMethodRechargeMonederoPayPalUrl = setPaymentMethodRechargeMonederoPayPalUrl.replaceAll('{{ code }}', resBodyCreate["code"]);

    Map<String, String> headersSetRecharge = {'Authorization': 'Bearer $userToken', 'Content-Type': 'application/json'};

    Map dataSet = {"paymentMethod": paymentObject['paymentMethod'], "token": paymentObject['token'], "paypalAccount": paymentObject['paypalAccount'], "paypalId": paymentObject['paypalId'], "amount": paymentObject['amount']};

    final responseSet = await HttpHelper.post(setPaymentMethodRechargeMonederoPayPalUrl, headers: headersSetRecharge, body: json.encode(dataSet));

    if (responseSet.statusCode == 200 || responseSet.statusCode == 201) {
      final resBodySet = json.decode(utf8.decode(responseSet.bodyBytes));
      return resBodySet;
    } else {}
  }

  static Future setPaymentMethodWallet(paymentObject, String optionCode, String nroMonedero) async {
    Map<String, dynamic> session = await CarritoServices.getSessionVars();
    final bool isLoggedIn = session['isLoggedIn'];
    final String guid = session['guid'];
    final String userToken = session['accessToken'];
    final String email = session['email'];

    print('userToken $userToken');
    print('email $email');
    print('optionCode $optionCode');
    print('nroMonedero $nroMonedero');

    print('paymentObject');
    print(paymentObject);

    String createMonederoRechargeOperationUrl = NetworkData.createMonederoRechargeOperationUrl;
    createMonederoRechargeOperationUrl = createMonederoRechargeOperationUrl.replaceAll('{{ email }}', email);

    Map<String, String> headers = {'Authorization': 'Bearer $userToken', 'Content-Type': 'application/json'};
    Map data = {"monederoNumber": nroMonedero, "optionCode": optionCode};

    print(createMonederoRechargeOperationUrl);
    final responseCreate = await HttpHelper.post(createMonederoRechargeOperationUrl, headers: headers, body: json.encode(data));

    print(responseCreate.statusCode);
    final resBodyCreate = json.decode(utf8.decode(responseCreate.bodyBytes));

    if (resBodyCreate['code'] == null) {
      return resBodyCreate;
    } else {}

    // String setPaymentMethodRechargeMonederoPayPalUrl = NetworkData.setPaymentMethodRechargeMonederoPayPalUrl;

    // setPaymentMethodRechargeMonederoPayPalUrl = setPaymentMethodRechargeMonederoPayPalUrl
    //     .replaceAll('{{ code }}', resBodyCreate["code"]);

    // Map dataSet = {
    //   "paymentMethod": paymentObject['paymentMethod'],
    //   "token": paymentObject['token'],
    //   "paypalAccount": paymentObject['paypalAccount'],
    //   "paypalId": paymentObject['paypalId'],
    //   "amount": paymentObject['amount']
    // };

    // final responseSet = await HttpHelper.post(
    //     setPaymentMethodRechargeMonederoPayPalUrl,
    //     headers: {
    //       'Authorization': 'Bearer $userToken',
    //       'Content-Type': 'application/json'
    //     },
    //     body: json.encode(dataSet));

    // final resBodySet = json.decode(utf8.decode(responseSet.bodyBytes));
    // return resBodySet;
  }

  static Future getRechargeOptionsMonedero() async {
    print('***************** getRechargeOptionsMonedero');

    Map<String, dynamic> session = await CarritoServices.getSessionVars();
    final bool isLoggedIn = session['isLoggedIn'];
    final String userToken = session['accessToken'];
    final String email = session['email'];

    if (isLoggedIn) {
      print('***************** paso 1');

      String url = NetworkData.getOptionsMonederoRechargeUrl.replaceAll('{{ email }}', email);
      Map<String, String> headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $userToken'};
      final response = await HttpHelper.get(url, headers: headers);

      print('***************** paso 2');
      print(response);
      if (response.statusCode == 200) {
        final resBody = json.decode(utf8.decode(response.bodyBytes));
        return resBody['rechargeOptions'];
      } else {}
      //return [{"code":"100","amount":100,"benefit":10,"message":"This is the best option for you"}];
    }
  }

  static Future getBines() async {
    Map<String, dynamic> session = await CarritoServices.getSessionVars();
    final bool isLoggedIn = session['isLoggedIn'];
    final String userToken = session['accessToken'];
    if (isLoggedIn) {
      String url = NetworkData.urlBankPoints;
      Map<String, String> headers = {'Authorization': 'Bearer $userToken', 'Content-Type': 'application/json'};
      final response = await HttpHelper.get(url, headers: headers);

      if (response.statusCode == 200) {
        final resBody = json.decode(utf8.decode(response.bodyBytes));
        return resBody['availableBanks'];
      } else {
        return [];
      }
    }
    return [];
  }

  static Future getPointsFromOpenPayTokenizada(String token, String customerId) async {
    String url = NetworkData.urlPuntosTarjetaTokenizada.replaceAll('{CUSTOMER_ID}', customerId).replaceAll('{CARD_ID}', token);

    Map<String, String> headers = {'Authorization': 'Basic ${NetworkData.openPayKey}', 'Content-Type': 'application/json'};

    final response = await HttpHelper.get(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody;
    } else {}
  }

  static Future<String> getOpenpayErrorsList(String openPayErorCode) async {
    try {
      print('getOpenpayErrorsList');
      String url = '${NetworkData.urlKenticoApp}?system.type=openpay_error_code&elements.code=$openPayErorCode';
      final response = await HttpHelper.get(url);
      final Map resBody = json.decode(utf8.decode(response.bodyBytes));
      print('resBody');
      print(resBody);
      final List items = resBody.containsKey('items') ? List.from(resBody["items"]) : new List();
      print('items');
      print(items);
      final Map errorData = items.length > 0 ? items.first : null;
      print('errorData');
      print(errorData);
      print(errorData["elements"]);
      print(errorData["elements"]["message"]);
      print(errorData["elements"]["message"]["value"]);
      return errorData["elements"]["message"]["value"];
    } catch (e) {
      return "Error desconocido de Openpay";
    }
  }
}
