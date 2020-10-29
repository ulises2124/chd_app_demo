import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:chd_app_demo/utils/NetworkData.dart';
import 'package:chd_app_demo/utils/renewTokenIfNeeded.dart';
import 'package:chd_app_demo/views/Pedidos/ConsignmentStatusDTO.dart';
import 'package:chd_app_demo/views/Pedidos/PedidoEnvioDTO.dart';
import 'package:chd_app_demo/views/Pedidos/PedidoRecoleccionDTO.dart';
import 'package:chd_app_demo/views/Pedidos/PedidosDTO.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chd_app_demo/services/AuthServices.dart';
import 'package:strings/strings.dart';
import 'package:chd_app_demo/services/CarritoServices.dart';

import 'package:chd_app_demo/utils/HttpHelper.dart';

class PedidosServices {
  static printJsonPretty(json) {
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String prettyprint = encoder.convert(json);
    print(prettyprint);
  }

  static String titleCase(String str) {
    var splitStr = str.toLowerCase().split(' ');
    for (var i = 0; i < splitStr.length; i++) {
      splitStr[i] = capitalize(splitStr[i]);
    }
    return splitStr.join(' ');
  }

  static Future<bool> hasOrders(String token) async {
    var _headers = {"Content-Type": "application/json", "Authorization": "Bearer $token"};
    var _response = await HttpHelper.get(NetworkData.urlUserOrders + 'current/orders?fields=FULL', headers: _headers);
    if (_response.statusCode > 200) {
      return false;
    } else {
      return true;
    }
  }

  static Future<List<OrderDTO>> getOrderList(String token) async {
    final List<OrderDTO> _orders = [];
    String url = NetworkData.urlUserOrders + 'current/orders?fields=FULL';
    var _headers = {"Content-Type": "application/json", "Authorization": "Bearer $token"};
    var _response = await HttpHelper.get(url, headers: _headers);

    if (_response.statusCode == 200 || _response.statusCode == 201) {
      var _jsonResponse = json.decode(utf8.decode(_response.bodyBytes));
      for (var e in _jsonResponse['orders']) {
        OrderDTO order = OrderDTO.fromJson(e);
        _orders.add(order);
      }
      print(_orders);
      return _orders;
    } else {
      return null;
    }
  }

  static Future<dynamic> getOrderDetails(String token, String order) async {
    print(token);
    String url = NetworkData.urlUserOrders + 'current/orders/$order?fields=FULL';
    var _headers = {"Content-Type": "application/json", "Authorization": "Bearer $token"};
    var _response = await HttpHelper.get(url, headers: _headers);
    var _jsonResponse = json.decode(utf8.decode(_response.bodyBytes));

    if (_jsonResponse['errors'] != null) {
      List<dynamic> errors = new List();
      for (var e in _jsonResponse['errors']) {
        print(e);
        errors.add(e);
      }
      return errors;
    } else if (_jsonResponse['deliveryMode']['code'] == 'pickup') {
      PedidoRecoleccionDTO _orderDetails = PedidoRecoleccionDTO.fromJson(_jsonResponse);
      return _orderDetails;
    } else {
      PedidoEnvioDTO _orderDetails = PedidoEnvioDTO.fromJson(_jsonResponse);
      return _orderDetails;
    }
  }

  static Future<dynamic> consignmentStatus(String _consignment) async {
    try {
      HttpClient client = new HttpClient();
      client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);

      String _statusUrl = NetworkData.pedidosBaseUrl + '/$_consignment/status';
      HttpClientRequest _statusRequest = await client.getUrl(Uri.parse(_statusUrl));
      HttpClientResponse _statusResponse = await _statusRequest.close();
      if (_statusResponse.statusCode != 200) {}
      var _statusJsonResponse = json.decode(await _statusResponse.transform(utf8.decoder).join());
      ConsignmentStatus _status = ConsignmentStatus.fromJson(_statusJsonResponse);
      print(_status.status);

      if (_status.status == 'OnRoute' || _status.status == 'AlmostArrived' || _status.status == 'Arrived') {
        String _positionUrl = NetworkData.pedidosBaseUrl + '/$_consignment/delivery_position';
        HttpClientRequest _positionRequest = await client.getUrl(Uri.parse(_positionUrl));
        HttpClientResponse _positionResponse = await _positionRequest.close();
        var _positionJsonResponse = json.decode(await _positionResponse.transform(utf8.decoder).join());
        ConsignmentStatus _position = ConsignmentStatus.fromJson(_positionJsonResponse);
        _status.data = _position.data;
      }

      return _status;
    } catch (e) {
      print('Error: $e');
    }
  }

  static Future lastProductsBought() async {
    // try {
    //   Map<String, dynamic> session = await CarritoServices.getSessionVars();
    //   final bool isLoggedIn = session['isLoggedIn'];
    //   final String userToken = session['accessToken'];

    //   if (isLoggedIn) {
    //     final List<OrderDTO> _orders = await getOrderList(userToken);
    //     final List<String> upcList = [];
    //     if (_orders.length > 0) {
    //       if (_orders.length <= 3) {
    //         List<OrderDTO> lastOrders = _orders;
    //         await Future.forEach(lastOrders, (list) async {
    //           var lastOrderDetails = await getOrderDetails(userToken, list.code);
    //           print(lastOrderDetails);
    //           lastOrderDetails.entries.forEach((entry) {
    //             upcList.add(entry.product.code);
    //           });
    //         });
    //       } else {
    //         List<OrderDTO> lastOrders = _orders.sublist(0, 3);
    //         print(lastOrders);
    //         await Future.forEach(lastOrders, (list) async {
    //           var lastOrderDetails = await getOrderDetails(userToken, list.code);
    //           print(lastOrderDetails);
    //           lastOrderDetails.entries.forEach((entry) {
    //             upcList.add(entry.product.code);
    //           });
    //         });
    //       }
    //     }
    //     return upcList;
    //   }
    // } catch (e) {
    //   print('Error: $e');
    // }
    Map<String, dynamic> session = await CarritoServices.getSessionVars();
    final String userToken = session['accessToken'];
    final String user = session['email'];
    String url = NetworkData.urlLastOrders.replaceAll('{{userId}}', user);
    final response = await HttpHelper.get(url, headers: {HttpHeaders.authorizationHeader: "Bearer " + userToken});
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody['mostPurchasedProducts'];
    } else {
      return null;
    }
  }
}
