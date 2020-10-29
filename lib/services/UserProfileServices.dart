import 'package:chd_app_demo/services/AuthServices.dart';
import 'package:chd_app_demo/services/CarritoServices.dart';
import 'package:chd_app_demo/utils/NetworkData.dart';
import 'package:chd_app_demo/utils/addressData.dart';
import 'package:chd_app_demo/utils/renewTokenIfNeeded.dart';
import 'package:chd_app_demo/utils/userData.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:chd_app_demo/utils/HttpHelper.dart';

class UserProfileServices {
  static Future clientescrmEditUserInfo(UserProfile updateUserData) async {
    var formattedDate;
    if (updateUserData.fechaNacimiento != null) {
      formattedDate = DateFormat('yyyy/MM/dd').format(updateUserData.fechaNacimiento);
    } else {
      formattedDate = updateUserData.fechaNacimiento;
    }
    print(formattedDate.toString());
    var headers = {"Content-Type": "application/json"};
    Map data = {
      'cliente': {
        'clienteId': updateUserData.clienteID,
        'nombre': updateUserData.nombre,
        'apellidoPaterno': updateUserData.apellidoPaterno,
        'apellidoMaterno': updateUserData.apellidoMaterno,
        'fechaNacimiento': formattedDate,
        'genero': updateUserData.genero,
        'telefonoCelular': updateUserData.telefonoCelular,
        'telefonoCasa': updateUserData.telefonoCasa,
      }
    };

    var response = await HttpHelper.post(
      NetworkData.postClientescrmEditUserInfo,
      headers: headers,
      body: utf8.encode(json.encode(data)),
    ).timeout(NetworkData.timeout);

    if (response.statusCode != null) {
      final resBody = json.decode(response.body);
      return resBody;
    } else {
      throw Exception('Failed edit data');
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  static Future getUserInterests() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user = prefs.getString('email');
    String url = NetworkData.getClientescrmUserInterest + '?correo=' + user;

    final response = await HttpHelper.get(
      url,
    ).timeout(NetworkData.timeout);

    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      // print(resBody.toString());
      return resBody;
    } else {
      throw Exception('Failed get shopping cart');
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  static Future clientescrmEditUserInterest(var updateUserData, String clienteID) async {
    var headers = {"Content-Type": "application/json"};
    Map data = {
      'cliente': {
        'clienteId': clienteID,
        'clubes': updateUserData,
      }
    };

    // print(utf8.encode(json.encode(data).toString()));
    var response = await HttpHelper.post(
      NetworkData.postClientescrmEditUserInfo,
      headers: headers,
      body: utf8.encode(json.encode(data)),
    ).timeout(NetworkData.timeout);

    if (response.statusCode != null) {
      final resBody = json.decode(response.body);
      // print(resBody.toString());
      return resBody;
    } else {
      throw Exception('Failed edit interest');
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  static Future hybrisGetUserAddress() async {
    try {
      final session = await CarritoServices.getSessionVars();

      final String user = session['email'];
      final String token = session['accessToken'];

      final url = NetworkData.getAddress.replaceAll("{{userId}}", user) + '?fields=FULL';
      var headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      final response = await HttpHelper.get(
        url,
        headers: headers,
      ).timeout(NetworkData.timeout);

      if (response.statusCode == 200) {
        final resBody = json.decode(utf8.decode(response.bodyBytes));
        return resBody;
      } else {
        print('failed');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  static Future hybrisDeletetUserAddress(String addressId) async {
    final session = await CarritoServices.getSessionVars();
    final String user = session['email'];
    final String token = session['accessToken'];
    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };

    String url = NetworkData.getAddress.replaceAll("{{userId}}", user) + '/' + addressId;
    final response = await HttpHelper.delete(
      url,
      headers: headers,
    ).timeout(NetworkData.timeout);

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed address delete');
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  static Future hybrisEditUserAddress(Address updateUserAddress) async {
    final session = await CarritoServices.getSessionVars();
    final String user = session['email'];
    final String token = session['accessToken'];
    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
    Map data = {
      'country': {"isocode": updateUserAddress.countryisocode, "name": updateUserAddress.countryname},
      "email": updateUserAddress.email,
      "firstName": updateUserAddress.firstName,
      "formattedAddress": updateUserAddress.formattedAddress,
      "id": updateUserAddress.id,
      "lastName": updateUserAddress.lastName,
      "secondLastName": updateUserAddress.secondLastName,
      "line1": updateUserAddress.line1,
      "phone": updateUserAddress.phone,
      "postalCode": updateUserAddress.postalCode,
      "region": {"countryIso": updateUserAddress.regioncountryIso, "isocode": updateUserAddress.regionisocode, "isocodeShort": updateUserAddress.regionisocodeShort, "name": updateUserAddress.regionname},
      "shippingAddress": updateUserAddress.shippingAddress,
      "town": updateUserAddress.town,
    };

    String url = NetworkData.getAddress.replaceAll("{{userId}}", user) + '/' + updateUserAddress.id;
    // print(utf8.encode(json.encode(data)).toString());
    var response = await HttpHelper.put(
      url,
      headers: headers,
      body: utf8.encode(json.encode(data)),
    ).timeout(NetworkData.timeout);

    if (response.statusCode == 200 || response.statusCode == 400) {
      return response;
    } else {
      throw Exception('Failed edit address');
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  static Future hybrisAddUserAddress(Map newUserAddress) async {
    final session = await CarritoServices.getSessionVars();
    final String user = session['email'];
    final String token = session['accessToken'];
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final Map addressObject = newUserAddress;
    addressObject["visibleInAddressBook"] = newUserAddress['newUserAddress'] ?? true;
    addressObject["shippingAddress"] = newUserAddress['shippingAddress'] ?? true;
    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };

    String url = NetworkData.getAddress.replaceAll("{{userId}}", user);
    var response = await HttpHelper.post(
      url,
      headers: headers,
      body: utf8.encode(json.encode(addressObject)),
    ).timeout(NetworkData.timeout);

    if (response.statusCode == 201 || response.statusCode == 400) {
      if (response.statusCode == 201) {
        final resBody = json.decode(utf8.decode(response.bodyBytes));
        prefs.setString('delivery-address-id', resBody['id']);
      }
      return response;
    } else {
      throw Exception('Failed edit address');
    }
  }
}
