// import 'dart:_http';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:chd_app_demo/services/CarritoServices.dart';
import 'package:chd_app_demo/services/FireBaseServices.dart';
import 'package:chd_app_demo/utils/NetworkData.dart';
import 'package:chd_app_demo/utils/HttpHelper.dart';

class ListasServices {
  static Future getListas() async {
    Map<String, dynamic> session = await CarritoServices.getSessionVars();
    final String userToken = session['accessToken'];
    final String user = session['email'];
    String url = NetworkData.urlListas.replaceAll('{{userId}}', user);
    url = url + '?fields=FULL';
    final response = await HttpHelper.get(url, headers: {HttpHeaders.authorizationHeader : "Bearer " + userToken});
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody['shoppingLists'];
    } else {
      throw Exception('Failed to load list.');
    }
  }

  static Future getCurrentList(listID) async {
    if (listID != null) {
      Map<String, dynamic> session = await CarritoServices.getSessionVars();
      final String userToken = session['accessToken'];
      final String user = session['email'];
      String url = NetworkData.urlListas.replaceAll('{{userId}}', user);
      url = url + '/' + listID;
      final response = await HttpHelper.get(url, headers: {HttpHeaders.authorizationHeader: "Bearer " + userToken});
      if (response.statusCode == 200) {
        final resBody = json.decode(utf8.decode(response.bodyBytes));
        return resBody;
      } else {
        throw Exception('Failed to load list.');
      }
    } else {
      return null;
    }
  }

  static Future deleteProduct(listID, productID, productName) async {
    Map<String, dynamic> session = await CarritoServices.getSessionVars();
    final String userToken = session['accessToken'];

    String url = NetworkData.urlListasDeleteProduct.replaceAll('{{listID}}', listID);
    url = url + productID;
    print(url);
    final response = await HttpHelper.delete(url, headers: {HttpHeaders.authorizationHeader: "Bearer " + userToken});
    if (response.statusCode == 200) {
      FireBaseEventController.sendAnalyticsEventRemoveFromWishList(productName).then((ok) {});
      return true;
    } else {
      throw Exception('error al eliminar producto');
    }
  }

  static Future deleteList(listID) async {
    Map<String, dynamic> session = await CarritoServices.getSessionVars();
    final String userToken = session['accessToken'];
    final String user = session['email'];
    String url = NetworkData.urlListas.replaceAll('{{userId}}', user);
    url = url + '/' + listID;
    final response = await HttpHelper.delete(url, headers: {HttpHeaders.authorizationHeader: "Bearer " + userToken});
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future addProduct(listID, productID, quantity) async {
    Map<String, dynamic> session = await CarritoServices.getSessionVars();
    final String userToken = session['accessToken'];
    String url = NetworkData.urlListasDeleteProduct.replaceAll('{{listID}}', listID);
    url = url + productID + '?quantity=' + quantity;
    final response = await HttpHelper.post(url, headers: {HttpHeaders.authorizationHeader: "Bearer " + userToken});
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future createList(listName) async {
    Map<String, dynamic> session = await CarritoServices.getSessionVars();
    final String userToken = session['accessToken'];
    final String user = session['email'];
    String url = NetworkData.urlListas.replaceAll('{{userId}}', user);
    url = url + '?name=' + listName;
    final response = await HttpHelper.post(url, headers: {HttpHeaders.authorizationHeader: "Bearer " + userToken});
    if (response.statusCode == 201) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody;
    } else {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody;
    }
  }

  static Future sharedList(listID, email, int productsQuantity) async {
    FireBaseEventController.sendAnalyticsEventShareWishlistIntend(productsQuantity).then((ok) {});
    Map<String, dynamic> session = await CarritoServices.getSessionVars();
    final String userToken = session['accessToken'];

    String url = NetworkData.urlListasShared.replaceAll('{{listID}}', listID);
    url = url + '?email=' + email;
    final response = await HttpHelper.put(url, headers: {HttpHeaders.authorizationHeader: "Bearer " + userToken});
    if (response.statusCode == 202) {
      FireBaseEventController.sendAnalyticsEventShareWishlistSuccess(productsQuantity).then((ok) {});
      return true;
    } else {
      return false;
    }
  }

  static Future listToCarrito(listID, zipcode) async {
    Map<String, dynamic> session = await CarritoServices.getSessionVars();
    final String userToken = session['accessToken'];
    String url = NetworkData.urlListatoCarrito.replaceAll('{{listID}}', listID);
    url = url + zipcode;
    final response = await HttpHelper.put(url, headers: {HttpHeaders.authorizationHeader: "Bearer " + userToken});
    print(response.body);
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody;
    } else {
      return throw Exception('error al ingresar productos al carrito');
    }
  }

  static Future listToCarritoTienda(listID, posName) async {
    Map<String, dynamic> session = await CarritoServices.getSessionVars();
    final String userToken = session['accessToken'];

    String url = NetworkData.urlListatoCarritoTienda.replaceAll('{{listID}}', listID);
    url = url + posName;
    final response = await HttpHelper.put(url, headers: {HttpHeaders.authorizationHeader: "Bearer " + userToken});
    print(response.body);
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody;
    } else {
      return throw Exception('error al ingresar productos al carrito');
    }
  }

  static Future ticketToLista(ticket) async {
    Map<String, dynamic> session = await CarritoServices.getSessionVars();
    final String userToken = session['accessToken'];
    final response = await HttpHelper.get(NetworkData.urlListasTicket + ticket, headers: {HttpHeaders.authorizationHeader: "Bearer " + userToken});
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody;
    } else {
      return throw Exception('error al ingresar productos al carrito');
    }
  }
}
