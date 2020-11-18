import 'dart:convert';
import 'dart:async';
//import 'dart:io';
import 'package:chd_app_demo/utils/NavigationService.dart';
import 'package:chd_app_demo/utils/NetworkData.dart';
import 'package:chd_app_demo/utils/locator.dart';
import 'package:chd_app_demo/utils/renewTokenIfNeeded.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chd_app_demo/services/AuthServices.dart';

import 'package:chd_app_demo/utils/HttpHelper.dart';

class CarritoServices {
  /*
  static Future getCartById(token) async {
    String cartID = 'current';
    final response = await HttpHelper.get(
      NetworkData.hybrisGetCartByID + cartID,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      // printJsonPretty(resBody);
      return resBody;
    } else {
      throw Exception('Failed get shopping cart');
    }
  }
  */

  /*
  static Future getCurrentCart(_token) async {
    final response = await HttpHelper.get(
      NetworkData.urlCarritoActualDescriptor,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Bearer $_token",
      },
    );
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody;
    } else {
      throw Exception('Failed get shopping cart');
    }
  }
  */

  static Future setEmailToAnonymousCart(String email, String phone, String name) async {
    Map<String, dynamic> session = await getSessionVars();
    final String guid = session['guid'];
    final String userToken = session['accessToken'];
    print(NetworkData.urlCarritoAnonimoGuid.replaceAll("{{guid}}", guid) + "/email");
    final responsEmail = await HttpHelper.put(NetworkData.urlCarritoAnonimoGuid.replaceAll("{{guid}}", guid) + "/email", headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Bearer $userToken",
    }, body: {
      "email": email
    });
    if (responsEmail.statusCode == 200 || responsEmail.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  static Future setDataForUserInStore(String email, String name, String phone) async {
    Map<String, dynamic> session = await getSessionVars();
    final bool isLoggedIn = session['isLoggedIn'];
    final String guid = session['guid'];
    final String userToken = session['accessToken'];
    //final List validValues = [200, 201, 202];
    if (isLoggedIn) {
      String url = NetworkData.urlCarritoInStoreRecipient + '?recipientName=$name' + '&phoneNumber=$phone';
      String urlEncoded = Uri.encodeFull(url);
      Map<String, String> headers = {
        "Authorization": "Bearer $userToken",
      };
      print('setDataForUserInStore');
      print(url);
      print(headers);
      final responseRecipient = await HttpHelper.put(urlEncoded, headers: headers, body: {});
      if (responseRecipient.statusCode == 200 || responseRecipient.statusCode == 201) {
        return {};
      } else {
        final resBody = json.decode(responseRecipient.body);
        print(resBody);
        return resBody;
      }
    } else {
      String urlConvert = NetworkData.urlCarritoInStoreRecipientAnonimous.replaceAll("{{guid}}", guid) + '?email=$email' + '&recipientName=$name' + '&phoneNumber=$phone';
      String urlConvertEncoded = Uri.encodeFull(urlConvert);
      String urlUpdate = NetworkData.urlCarritoInStoreRecipientAnonimousUpdate.replaceAll("{{guid}}", guid) + '?email=$email' + '&recipientName=$name' + '&phoneNumber=$phone';
      String urlUpdateEncoded = Uri.encodeFull(urlUpdate);
      Map<String, String> headers = {
        "Authorization": "Bearer $userToken",
      };
      print('setDataForUserInStore');
      print(urlConvertEncoded);
      print(headers);
      final responseRecipient = await HttpHelper.put(urlConvertEncoded, headers: headers, body: {});
      if (responseRecipient.statusCode != 200 && responseRecipient.statusCode != 201) {
        print('setDataForUserInStoreUpdate');
        print(urlConvertEncoded);
        print(headers);
        final responseRecipientUpdate = await HttpHelper.put(urlUpdateEncoded, headers: headers, body: {});
        print(responseRecipientUpdate.statusCode);
        if (responseRecipientUpdate.statusCode != 200 && responseRecipientUpdate.statusCode != 201) {
          final resBodyUpdate = json.decode(responseRecipientUpdate.body);
          print(resBodyUpdate);
          return resBodyUpdate;
        } else {
          return {};
        }
      } else {
        return {};
      }
    }
  }

  static Future setAddress() async {
    Map<String, dynamic> session = await getSessionVars();
    final bool isLoggedIn = session['isLoggedIn'];
    final String guid = session['guid'];
    final String userToken = session['accessToken'];
    //final bool isLocationSet = session['isLocationSet'];
    final bool isPickUp = session['isPickUp'];
    // final String zipCode = session['zipCode'];
    // final String tienda = session['tienda'];
    final String email = session['email'];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String deliveryAddressId = prefs.getString('delivery-address-id');
    String newDeliveryAddressId;

    if (isLoggedIn) {
      if (!isPickUp) {
        if (deliveryAddressId == null) {
          String secondLastName = prefs.getString('delivery-userSecondLastName').trim() != "" ? prefs.getString('delivery-userSecondLastName') : "Sin información";
          Map addressObject = {
            "country": {"isocode": "MX"},
            "country.isocode": "MX",
            "firstName": prefs.getString('delivery-userName'),
            "lastName": prefs.getString('delivery-userLastName'),
            "secondLastName": secondLastName,
            "line1": prefs.getString('delivery-direccion') != null ? prefs.getString('delivery-direccion') : "${prefs.getString('delivery-route')} ${prefs.getString('delivery-streetNumber')}",
            "line2": prefs.getString('delivery-numInterior') != "" ? prefs.getString('delivery-numInterior') : "N/A",
            "postalCode": prefs.getString('delivery-codigoPostal'),
            "region": {"isocode": prefs.getString('delivery-isocode')},
            //"titleCode": "",
            //"town": prefs.getString('delivery-deliveryNote'),
            "town": prefs.getString('delivery-sublocality'),
            "phone": prefs.getString('delivery-telefono'),
          };
          String urlSaveAddress = NetworkData.saveAddress.replaceAll("{{userId}}", "current");
          Map<String, String> headersSaveAddress = {
            "Content-Type": "application/json",
            "Authorization": "Bearer $userToken",
          };
          final responseSaveAddress = await HttpHelper.post(
            urlSaveAddress,
            headers: headersSaveAddress,
            body: utf8.encode(json.encode(addressObject)),
          ).timeout(NetworkData.timeout);
          Map mapRes = json.decode(responseSaveAddress.body);
          if (mapRes['errors'] != null) {
            return mapRes;
          }
          prefs.setString("delivery-address-id", mapRes["id"]);
          newDeliveryAddressId = mapRes["id"];
        }
        final addressId = deliveryAddressId ?? newDeliveryAddressId;
        String urlSetAddress = NetworkData.setAddressToCar;
        Map<String, String> headersSetAddress = {"Authorization": "Bearer $userToken"};
        Map<String, dynamic> bodySetAddress = {'addressId': addressId};
        final responseSetAddress = await HttpHelper.put(
          urlSetAddress,
          headers: headersSetAddress,
          body: bodySetAddress,
        ).timeout(NetworkData.timeout);
        print("response ADDRESS---->" + responseSetAddress.statusCode.toString());
        print("response ADDRESS---->" + responseSetAddress.body);
        switch (responseSetAddress.statusCode) {
          case 200:
          case 201:
            return null;
            break;
          case 400:
          case 401:
            var resBody = json.decode(utf8.decode(responseSetAddress.bodyBytes));
            return resBody;
            break;
          default:
            throw Exception(responseSetAddress.statusCode.toString());
        }
      } else {
        String name = '${prefs.getString('delivery-userName')} ${prefs.getString('delivery-userLastName')}';
        String phone = prefs.getString('delivery-telefono');
        final setRecipientResult = await setDataForUserInStore(email, name, phone);
        return setRecipientResult;
      }
    } else {
      if (guid != null) {
        if (!isPickUp) {
          //await setEmailToAnonymousCart(email);
          String name = '${prefs.getString('delivery-userName')} ${prefs.getString('delivery-userLastName')}';
          String phone = prefs.getString('delivery-telefono');
          await setDataForUserInStore(email, name, phone);
          String secondLastName = prefs.getString('delivery-userSecondLastName').trim() != "" ? prefs.getString('delivery-userSecondLastName') : "Sin información";
          Map addressObject = {
            "country": {"isocode": "MX"},
            "country.isocode": "MX",
            "firstName": prefs.getString('delivery-userName'),
            "lastName": prefs.getString('delivery-userLastName'),
            "secondLastName": secondLastName,
            "line1": prefs.getString('delivery-direccion') != null ? prefs.getString('delivery-direccion') : "${prefs.getString('delivery-route')} ${prefs.getString('delivery-streetNumber')}",
            "line2": prefs.getString('delivery-numInterior') != "" ? prefs.getString('delivery-numInterior') : "N/A",
            "postalCode": prefs.getString('delivery-codigoPostal'),
            "region": {"isocode": prefs.getString('delivery-isocode')},
            //"titleCode": "",
            //"town": prefs.getString('delivery-deliveryNote'),
            "town": prefs.getString('delivery-sublocality'),
            "phone": prefs.getString('delivery-telefono'),
          };
          String urlSetAddress = NetworkData.setAddressToCarAnonymous.replaceAll("{{cartId}}", guid);
          Map<String, String> headersSetAddress = {
            "Content-Type": "application/json",
            "Authorization": "Bearer $userToken",
          };
          var responseSetAddress = await HttpHelper.post(
            urlSetAddress,
            headers: headersSetAddress,
            body: utf8.encode(json.encode(addressObject)),
          ).timeout(NetworkData.timeout);
          print("response ADDRESS---->" + responseSetAddress.statusCode.toString());
          print("response ADDRESS---->" + responseSetAddress.body);
          switch (responseSetAddress.statusCode) {
            case 200:
            case 201:
              return null;
              break;
            case 400:
            case 401:
              var resBody = json.decode(utf8.decode(responseSetAddress.bodyBytes));
              return resBody;
              break;
            default:
              throw Exception(responseSetAddress.statusCode.toString());
          }
        } else {
          String name = '${prefs.getString('delivery-userName')} ${prefs.getString('delivery-userLastName')}';
          String phone = prefs.getString('delivery-telefono');
          final setRecipientResult = await setDataForUserInStore(email, name, phone);
          return setRecipientResult;
        }
      }
    }
  }

  static Future getCurrentCartTimeSlots() async {
    Map<String, dynamic> session = await getSessionVars();
    final bool isLoggedIn = session['isLoggedIn'];
    final String guid = session['guid'];
    final String userToken = session['accessToken'];
    // final bool isLocationSet = session['isLocationSet'];
    // final bool isPickUp = session['isPickUp'];
    // final String zipCode = session['zipCode'];
    // final String tienda = session['tienda'];
    // final String email = session['email'];

    if (isLoggedIn) {
      String urlTimeSlots = NetworkData.urlCarritoActualTimeSlots;
      Map<String, String> headers = {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Bearer $userToken",
      };
      final responseTimeSlots = await HttpHelper.get(
        urlTimeSlots,
        headers: headers,
      ).timeout(NetworkData.extendedTimeout);
      print(responseTimeSlots.statusCode);
      print(responseTimeSlots.body);
      if (responseTimeSlots.statusCode == 200 || responseTimeSlots.statusCode == 400) {
        final resBody = json.decode(utf8.decode(responseTimeSlots.bodyBytes));
        return resBody;
      } else {
        throw Exception('Failed get time slots cart');
      }
    } else {
      if (guid != null) {
        String urlTimeSlots = NetworkData.urlCarritoActualTimeSlotsAnonimo.replaceAll("{{cartId}}", guid);
        Map<String, String> headers = {
          "Authorization": "Bearer $userToken",
        };
        final responseTimeSlots = await HttpHelper.get(
          urlTimeSlots,
          headers: headers,
        ).timeout(NetworkData.extendedTimeout);
        print(responseTimeSlots.body);
        if (responseTimeSlots.statusCode == 200 || responseTimeSlots.statusCode == 400) {
          final resBody = json.decode(utf8.decode(responseTimeSlots.bodyBytes));
          return resBody;
        } else {
          throw Exception('Failed get time slots cart');
        }
      }
    }
  }

  static Future setCartTimeSlots(timeSlots) async {
    Map<String, dynamic> session = await getSessionVars();
    final bool isLoggedIn = session['isLoggedIn'];
    final String guid = session['guid'];
    final String userToken = session['accessToken'];
    List responses = [];
    if (isLoggedIn) {
      String urlTimeSlots = NetworkData.urlCarritoActualTimeSlots;
      for (var ts in timeSlots) {
        var headers = {
          "Content-Type": "application/json",
          "Authorization": "Bearer $userToken",
        };
        var body = json.encode(ts);
        var responseTimeSlots = await HttpHelper.post(
          urlTimeSlots,
          headers: headers,
          body: body,
        ).timeout(NetworkData.timeout);

        if (responseTimeSlots.statusCode == 200) {
          var resBody = json.decode(utf8.decode(responseTimeSlots.bodyBytes));
          responses.add(resBody['result'].toString() == "true");
        } else {
          responses.add(false);
        }
      }
      return responses;
    } else {
      if (guid != null) {
        String urlTimeSlots = NetworkData.urlCarritoActualTimeSlotsAnonimo.replaceAll('{{cartId}}', guid);
        print(urlTimeSlots);
        for (var ts in timeSlots) {
          var headers = {
            "Content-Type": "application/json",
            "Authorization": "Bearer $userToken",
          };
          var body = json.encode(ts);
          var responseTimeSlots = await HttpHelper.post(
            urlTimeSlots,
            headers: headers,
            body: body,
          );
          if (responseTimeSlots.statusCode == 200) {
            var resBody = json.decode(utf8.decode(responseTimeSlots.bodyBytes));
            responses.add(resBody['result'].toString() == "true");
          } else {
            responses.add(false);
          }
        }
        return responses;
      }
    }
  }

  /*
  static Future postHybrisLogin() async {
    var headers = {
      "Content-Type": "application/x-www-form-urlencoded",
    };

    var body = {
      // 'username': 'daniel_test@advncdmanknd.com',
      // 'password': 'asdfQWERTY92',
      'username': 'carls127.jc@gmail.com',
      'password': 'Carls_129',
      'client_id': 'occ-chedraui',
      'client_secret': 'Ch3dr@u1!',
      'grant_type': 'password',
    };

    var response = await HttpHelper.post(
      NetworkData.hybrisLogin,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody;
    } else {
      throw Exception('Failed hybris login');
    }
  }
  */

  /*
  static printJsonPretty(json) {
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String prettyprint = encoder.convert(json);
    print(prettyprint);
  }
  */

  /*
  static Future cleanCarritoLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final carritoVacio = {
      "type": "cartWsDTO",
      "code": "LOCAL",
      "entries": [],
      "guid": "",
      "totalItems": 0,
      "totalPrice": {"currencyIso": "MXN", "value": 0},
      "totalPriceWithTax": {"currencyIso": "MXN", "value": 0}
    };
    prefs.setString('carrito', json.encode(carritoVacio));
    return carritoVacio;
  }

  static Future loadCarritoLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final carritoRaw = prefs.getString('carrito');
    if (carritoRaw != null && carritoRaw != "") {
      final carrito = json.decode(carritoRaw);
      return carrito;
    } else {
      final carrito = await cleanCarritoLocal();
      return carrito;
    }
  }

  static Future<void> addToCarritoLocal(
      var productInfo, int quantity, String zipCode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var carritoRaw = prefs.getString('carrito');
    if (carritoRaw == null || carritoRaw == "") {
      carritoRaw = await cleanCarritoLocal();
    }
    var carrito = json.decode(carritoRaw);
    List entries = carrito['entries'];
    bool inCarrito = false;
    int index = 0;
    double sum = 0;
    double sumTax = 0;
    entries.forEach((item) {
      sum += item['totalPrice']['value'];
      sumTax += item['totalPrice']['value'];
      if (!inCarrito) {
        if (item['product']['code'] == productInfo['code']) {
          print('Updating: ${productInfo['code']}');
          entries[index] = {
            "decimalQty": quantity,
            "entryNumber": index,
            "product": {
              "availableForPickup": productInfo['availableForPickup'],
              "code": productInfo['code'],
              "maxOrderQuantity": productInfo['maxOrderQuantity'],
              "name": productInfo['name'],
              "purchasable": productInfo['purchasable'],
              "restricted": productInfo['restricted'],
              "sapEAN": productInfo['sapEAN'],
              "stock": {"stockLevel": "stockLevel"},
              "unit": {
                "code": productInfo['unit']['code'],
                "conversion": productInfo['unit']['conversion'],
                "name": productInfo['unit']['name']
              },
              "price": {
                "currencyIso": productInfo['price']['currencyIso'],
                "value": productInfo['price']['value']
              },
              "url": productInfo['url']
            },
            "totalPrice": {
              "currencyIso": "MXN",
              "value": productInfo['price']['value'] * quantity
            },
            "zipCode": zipCode
          };
          inCarrito = true;
        }
      }
      index++;
    });
    if (!inCarrito) {
      print("New item: $productInfo");
      entries.add({
        "decimalQty": quantity,
        "entryNumber": entries.length,
        "product": {
          "availableForPickup": productInfo['availableForPickup'],
          "code": productInfo['code'],
          "maxOrderQuantity": productInfo['maxOrderQuantity'],
          "name": productInfo['name'],
          "purchasable": productInfo['purchasable'],
          "restricted": productInfo['restricted'],
          "sapEAN": productInfo['sapEAN'],
          "stock": {"stockLevel": productInfo['stockLevel']},
          "unit": {
            "code": productInfo['unit']['code'],
            "conversion": productInfo['unit']['conversion'],
            "name": productInfo['unit']['name']
          },
          "price": {
            "currencyIso": productInfo['price']['currencyIso'],
            "value": productInfo['price']['value']
          },
          "url": productInfo['url']
        },
        "totalPrice": {
          "currencyIso": "MXN",
          "value": productInfo['price']['value'] * quantity
        },
        "zipCode": zipCode
      });
      sum += productInfo['price']['value'] * quantity;
      sumTax += productInfo['price']['value'] * quantity;
    }
    carrito['entries'] = entries;
    carrito['totalPrice']['value'] = sum;
    carrito['totalPriceWithTax']['value'] = sumTax;
    carrito['totalItems'] = entries.length;
    final String carritoStr = json.encode(carrito);
    prefs.setString('carrito', carritoStr);
  }

  static Future modifyAmountCarritoLocal(int indexM, int newAmount) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var carritoRaw = prefs.getString('carrito');
    var carrito = json.decode(carritoRaw);
    List entries = carrito['entries'];
    int index = 0;
    double sum = 0;
    double sumTax = 0;
    entries.forEach((item) {
      if (index == indexM) {
        entries[index]['decimalQty'] = newAmount;
        entries[index]['totalPrice']['value'] =
            entries[index]['product']['price']['value'] * newAmount;
      }
      sum += item['totalPrice']['value'];
      sumTax += item['totalPrice']['value'];
      index++;
    });
    carrito['entries'] = entries;
    carrito['totalPrice']['value'] = sum;
    carrito['totalPriceWithTax']['value'] = sumTax;
    carrito['totalItems'] = entries.length;
    final String carritoStr = json.encode(carrito);
    prefs.setString('carrito', carritoStr);
  }

  static Future deleteFromCarritoLocal(int indexD) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var carritoRaw = prefs.getString('carrito');
    var carrito = json.decode(carritoRaw);
    List entries = carrito['entries'];
    entries.removeAt(indexD);
    double sum = 0;
    double sumTax = 0;
    entries.forEach((item) {
      sum += item['totalPrice']['value'];
      sumTax += item['totalPrice']['value'];
    });
    carrito['entries'] = entries;
    carrito['totalPrice']['value'] = sum;
    carrito['totalPriceWithTax']['value'] = sumTax;
    carrito['totalItems'] = entries.length;
    final String carritoStr = json.encode(carrito);
    prefs.setString('carrito', carritoStr);
  }
  */

  static Future createNewAnonymousCart() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String url = NetworkData.urlCarritoAnonimo;
    var response = await HttpHelper.post(
      url,
      body: {},
    );
    if (response.statusCode == 201) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      prefs.setString('carrito_guid', resBody['guid']);
      return resBody;
    } else {
      throw Exception('Failed to create anonymous shopping cart');
    }
  }

  static Future getUserToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      final String user = prefs.getString('email');
      final String pass = prefs.getString('password');
      final resultLogin = await AuthServices.postGCloudLogin(user, pass);
      return resultLogin['accessToken'];
    } else {
      final resultLogin = await AuthServices.postGCloudLogin(null, null);
      return resultLogin['accessToken'];
    }
  }

  static Future<Map<String, dynamic>> getSessionVars() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final String guid = prefs.getString('carrito_guid');
    final String user = prefs.getString('email');
    final String pass = prefs.getString('password');
    final bool isLocationSet = prefs.getBool('isLocationSet') ?? false;
    final bool isPickUp = prefs.getBool('isPickUp') ?? false;
    final String zipCode = prefs.getString('delivery-codigoPostal');
    final String tienda = prefs.getString('store-name');
    final String idWallet = prefs.getString('idWallet');
    final String firstName = prefs.getString('delivery-userName');
    final String lastName = prefs.getString('delivery-userLastName');
    final String phone = prefs.getString('delivery-telefono');
    //final resultLogin = await AuthServices.postGCloudLogin(user, pass);
    final Map<String, dynamic> response = {
      "isLoggedIn": isLoggedIn,
      "accessToken": await RenewToken.renewTokenIfNeed(),
      "email": user,
      "guid": guid,
      "isLocationSet": isLocationSet,
      "isPickUp": isPickUp,
      "zipCode": zipCode,
      "tienda": tienda,
      "idWallet": idWallet,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
    };

    /*
    print('*****************SESION VARS**************');
    response.forEach(
      (key, value) {
        print("$key: ${value.toString()}");
      }
    );
    print('**************END SESION VARS**************');
    */

    if (response['accessToken'] == null) {
      locator<NavigationService>().navigateTo('login');

      // return response;
    } else {
      print(response);
      return response;
    }
  }

  static Future getCart() async {
    Map<String, dynamic> session = await getSessionVars();
    final bool isLoggedIn = session['isLoggedIn'];
    final String guid = session['guid'];
    final String userToken = session['accessToken'];

    if (isLoggedIn) {
      final String bearer = "Bearer $userToken";
      final String url = NetworkData.urlCarritoActualDescriptor + "?fields=FULL";
      Map<String, String> headers = {'Authorization': bearer};
      var response = await HttpHelper.get(url, headers: headers);
      if (response.statusCode == 200) {
        final resBody = json.decode(utf8.decode(response.bodyBytes));
        return resBody;
      } else {
        throw Exception('Failed to get current shopping cart');
      }
    } else {
      if (guid != null) {
        var url = NetworkData.urlCarritoAnonimoGuid.replaceAll('{{guid}}', guid) + "?fields=FULL";
        var response = await HttpHelper.get(url);
        if (response.statusCode == 200) {
          final resBody = json.decode(utf8.decode(response.bodyBytes));
          return resBody;
        } else {
          final cart = await createNewAnonymousCart();
          return cart;
        }
      } else {
        final cart = await createNewAnonymousCart();
        return cart;
      }
    }
  }

  static Future addEntryToCart(String productCode, num decimalQty, bool isRestricted) async {
    Map<String, dynamic> session = await getSessionVars();
    final bool isLoggedIn = session['isLoggedIn'];
    final String guid = session['guid'];
    final String userToken = session['accessToken'];
    final bool isLocationSet = session['isLocationSet'];
    final bool isPickUp = session['isPickUp'];
    final String zipCode = session['zipCode'];
    final String tienda = session['tienda'];
    var body;
    if (isLocationSet) {
      if (isPickUp) {
        body = {
          "orderEntries": [
            {
              "product": {"code": productCode},
              "posName": tienda,
              "decimalQty": decimalQty
            }
          ]
        };
      } else {
        body = {
          "orderEntries": [
            {
              "product": {"code": productCode},
              "zipCode": zipCode,
              "decimalQty": decimalQty
            }
          ]
        };
      }
    } else if (!isRestricted) {
      body = {
        "orderEntries": [
          {
            "product": {"code": productCode},
            "decimalQty": decimalQty
          }
        ]
      };
    } else {
      return {"err": "NO_LOCATION_IS_SET"};
    }
    if (body != null) {
      if (isLoggedIn) {
        final String bearer = "Bearer $userToken";
        final String url = NetworkData.urlCarritoActualDescriptorEntries;
        Map<String, String> headers = {
          'Authorization': bearer,
          "Content-Type": "application/json",
          //'salesChannel': 'app'
        };
        var response = await HttpHelper.post(url, headers: headers, body: json.encode(body));
        if (response.statusCode == 200) {
          final resBody = json.decode(utf8.decode(response.bodyBytes));
          return resBody;
        } else {
          //throw Exception('Failed to put item in current shopping cart');
          return null;
        }
      } else {
        if (guid != null) {
          String url = NetworkData.urlCarritoAnonimoEntries.replaceAll('{{guid}}', guid);
          Map<String, String> headers = {"Content-Type": "application/json"};
          var response = await HttpHelper.post(url, headers: headers, body: json.encode(body)).timeout(NetworkData.timeout);
          print(response.body.toString());
          if (response.statusCode == 200) {
            final resBody = json.decode(utf8.decode(response.bodyBytes));
            return resBody;
          } else {
            //throw Exception('Failed to put item in anonymous shopping cart');
            print(response.statusCode);
            print(response.body);
            return null;
          }
        }
      }
    }
  }

  static Future addEntryToCartComparator(data) async {
    Map<String, dynamic> session = await getSessionVars();
    final bool isLoggedIn = session['isLoggedIn'];
    final String guid = session['guid'];
    final String userToken = session['accessToken'];
    final bool isLocationSet = session['isLocationSet'];
    final bool isPickUp = session['isPickUp'];
    final String zipCode = session['zipCode'];
    final String tienda = session['tienda'];

    var body;
    if (isLocationSet) {
      if (isPickUp) {
        body = {
          "orderEntries": [
            {
              "product": {"code": data['upc']},
              "specialPrice": {"price": data['price'], "fromDate": data['date'] + " 00:00:01", "endDate": data['date'] + " 23:59:59", "maxQty": "10"},
              "posName": tienda,
              "decimalQty": 1
            }
          ]
        };
      } else {
        body = {
          "orderEntries": [
            {
              "product": {"code": data['upc']},
              "specialPrice": {"price": data['price'], "fromDate": data['date'] + " 00:00:01", "endDate": data['date'] + " 23:59:59", "maxQty": "10"},
              "zipCode": zipCode,
              "decimalQty": 1
            }
          ]
        };
      }
    } else {
      return {"err": "NO_LOCATION_IS_SET"};
    }

    print(body);

    if (body != null) {
      if (isLoggedIn) {
        final String bearer = "Bearer $userToken";
        final String url = NetworkData.urlCarritoActualDescriptorEntries;
        Map<String, String> headers = {'Authorization': bearer, "Content-Type": "application/json"};
        var response = await HttpHelper.post(url, headers: headers, body: json.encode(body));
        if (response.statusCode == 200) {
          final resBody = json.decode(utf8.decode(response.bodyBytes));
          return resBody;
        } else {
          //throw Exception('Failed to put item in current shopping cart');
          return null;
        }
      } else {
        if (guid != null) {
          String url = NetworkData.urlCarritoAnonimoEntries.replaceAll('{{guid}}', guid);
          Map<String, String> headers = {"Content-Type": "application/json"};
          var response = await HttpHelper.post(url, headers: headers, body: json.encode(body)).timeout(NetworkData.timeout);
          print(response.body.toString());
          if (response.statusCode == 200) {
            final resBody = json.decode(utf8.decode(response.bodyBytes));
            return resBody;
          } else {
            //throw Exception('Failed to put item in anonymous shopping cart');
            return null;
          }
        }
      }
    }
  }

  static Future updateEntryCart(int position, num decimalQty) async {
    Map<String, dynamic> session = await getSessionVars();
    final bool isLoggedIn = session['isLoggedIn'];
    final String guid = session['guid'];
    final String userToken = session['accessToken'];

    if (isLoggedIn) {
      final String bearer = "Bearer $userToken";
      var response = await HttpHelper.put(NetworkData.urlCarritoActualDescriptorEntryUpdate.replaceAll('{{pos}}', position.toString()).replaceAll('{{qty}}', decimalQty.toString()), headers: {
        'Authorization': bearer,
      }, body: {}).timeout(NetworkData.timeout);
      print(response.statusCode);
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody;
    } else {
      if (guid != null) {
        var response = await HttpHelper.put(NetworkData.urlCarritoAnonimoEntryUpdate.replaceAll('{{guid}}', guid).replaceAll('{{pos}}', position.toString()).replaceAll('{{qty}}', decimalQty.toString()), body: {}).timeout(NetworkData.timeout);
        final resBody = json.decode(utf8.decode(response.bodyBytes));
        return resBody;
      }
    }
  }

  static Future clearCart() async {
    Map<String, dynamic> session = await getSessionVars();
    final bool isLoggedIn = session['isLoggedIn'];
    final String guid = session['guid'];
    final String userToken = session['accessToken'];

    if (isLoggedIn) {
      final String bearer = "Bearer $userToken";
      String url = NetworkData.urlCarritoActualDescriptorEntries;
      Map<String, String> headers = {
        'Authorization': bearer,
      };
      var response = await HttpHelper.delete(url, headers: headers);
      if (response.statusCode == 200 || response.statusCode == 202) {
        return true;
      } else {
        throw Exception('Failed to clear current shopping cart');
      }
    } else {
      if (guid != null) {
        String url = NetworkData.urlCarritoAnonimoEntries.replaceAll('{{guid}}', guid);
        var response = await HttpHelper.delete(url);
        if (response.statusCode == 200 || response.statusCode == 202) {
          return true;
        } else {
          throw Exception('Failed to clear anonymous shopping cart');
        }
      }
    }
  }

  static Future<bool> deleteEntryCart(int position) async {
    Map<String, dynamic> session = await getSessionVars();
    final bool isLoggedIn = session['isLoggedIn'];
    final String guid = session['guid'];
    final String userToken = session['accessToken'];

    if (isLoggedIn) {
      final String bearer = "Bearer $userToken";
      String url = NetworkData.urlCarritoActualDescriptorEntry.replaceAll('{{pos}}', position.toString());
      Map<String, String> headers = {
        'Authorization': bearer,
      };
      var response = await HttpHelper.delete(url, headers: headers);
      if (response.statusCode == 200 || response.statusCode == 202) {
        return true;
      } else {
        return false;
      }
    } else {
      if (guid != null) {
        print(guid);
        print(position);
        String url = NetworkData.urlCarritoAnonimoEntry.replaceAll('{{guid}}', guid).replaceAll('{{pos}}', position.toString());
        var response = await HttpHelper.delete(url);
        if (response.statusCode == 200 || response.statusCode == 202) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    }
  }

  /*
  static Future manualMerge(String guidAnonimo, String auth) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final isLocationSet = prefs.getBool('isLocationSet');
    final isPickUp = prefs.getBool('isPickUp');
    final zipCode = prefs.getString('delivery-codigoPostal');
    final tienda = prefs.getString('store-name');

    print("\n\n *Searching store name* \n\n");

    print('****************** Inicial merge manual');

    var carritoAnonimo;
    var responseCarritoAnonimo = await HttpHelper.get(
        NetworkData.urlCarritoAnonimoGuid.replaceAll('{{guid}}', guidAnonimo));
    if (responseCarritoAnonimo.statusCode == 200) {
      carritoAnonimo =
          json.decode(utf8.decode(responseCarritoAnonimo.bodyBytes));
    } else {
      throw Exception('manualMerge: Error obteniendo carrito anonimo.');
    }
    List anonymousEntries = carritoAnonimo['entries'];
    List entriesToCurrent = [];
    print(
        '****************** anonymousEntries length: ${anonymousEntries.length}');
    anonymousEntries.forEach((entry) {
      var newEntry;
      if (isLocationSet != null && isLocationSet) {
        if (isPickUp != null && isPickUp) {
          newEntry = {
            "product": {"code": entry['product']['code']},
            "posName": tienda,
            "decimalQty": entry['decimalQty']
          };
        } else {
          newEntry = {
            "product": {"code": entry['product']['code']},
            "zipCode": zipCode,
            "decimalQty": entry['decimalQty']
          };
        }
      } else {
        return;
      }
      entriesToCurrent.add(newEntry);
    });
    var body = {"orderEntries": entriesToCurrent};
    print(body);
    var responseAddToCurrentCart = await HttpHelper.post(
        NetworkData.urlCarritoActualDescriptorEntries,
        headers: {'Authorization': auth, "Content-Type": "application/json"},
        body: json.encode(body));
    if (responseAddToCurrentCart.statusCode == 200) {
      final addedToCart =
          json.decode(utf8.decode(responseAddToCurrentCart.bodyBytes));
      var responseDeleteAnonymousCart = await HttpHelper.delete(NetworkData
          .urlCarritoAnonimoGuid
          .replaceAll('{{guid}}', guidAnonimo));
      print('????????????????????????????????');
      print(NetworkData.urlCarritoAnonimoGuid
          .replaceAll('{{guid}}', guidAnonimo));
      print(responseDeleteAnonymousCart.statusCode);
      print('????????????????????????????????');
      if (responseDeleteAnonymousCart.statusCode == 200 ||
          responseDeleteAnonymousCart.statusCode == 202) {
        return addedToCart;
      } else {
        throw Exception(
            'manualMerge: Failed to delete anonymous shopping cart');
      }
    } else {
      throw Exception(
          'manualMerge: Failed to put item in current shopping cart');
    }
  }

  static Future mergeCarts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final guidAnonimo = prefs.getString('carrito_guid');
    final accessToken = prefs.getString('accessToken');
    final auth = 'Bearer $accessToken';
    print('===============');
    print(auth);
    print('===============');
    if (guidAnonimo != null) {
      var responseGetCarritoActual = await HttpHelper.get(
          NetworkData.urlCarritoActualDescriptor,
          headers: {'Authorization': auth});
      if (responseGetCarritoActual.statusCode == 200) {
        final carritoActual =
            json.decode(utf8.decode(responseGetCarritoActual.bodyBytes));
        final guidRegistrado = carritoActual['guid'];
        print('////////////////////////////////');
        print(guidAnonimo);
        print(guidRegistrado);
        print('////////////////////////////////');
        var responseMerge = await HttpHelper
            .post(NetworkData.urlCarritosActualesDescriptor, headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': auth
        }, body: {
          'oldCartId': guidAnonimo,
          'toMergeCartGuid': guidRegistrado
        });
        if (responseMerge.statusCode == 201) {
          prefs.remove('guid_carrito');
          var carritoAfterMerge =
              json.decode(utf8.decode(responseMerge.bodyBytes));
          return carritoAfterMerge;
        } else if (responseMerge.statusCode == 400) {
          var manualMergeResult = await manualMerge(guidAnonimo, auth);
          prefs.remove('guid_carrito');
          print('pppppppppppppppppppppppppp');
          print(manualMergeResult);
          print('pppppppppppppppppppppppppp');
          /*
          var carritoAfterMerge =
              json.decode(utf8.decode(responseMerge.bodyBytes));
          if (carritoAfterMerge != null &&
              carritoAfterMerge['errors'].length > 0 &&
              carritoAfterMerge['errors'][0]['message'] ==
                  "No session stores for restricted product.") {
            return carritoAfterMerge;
          } else {
            print(carritoAfterMerge);
            throw Exception('Failed to merge the carts.');
          }
          */
        } else {
          print(responseMerge);
          throw Exception('Failed to merge the carts.');
        }
      } else {
        print(responseGetCarritoActual);
        throw Exception('Failed to get the cart from registred user.');
      }
    } else {
      throw Exception('No anonymous cart found stored.');
    }
  }
  */

  static Future deleteCurrentAnonymousCart() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final guid = prefs.getString('carrito_guid');
    if (guid != null) {
      await HttpHelper.delete(NetworkData.urlCarritoAnonimoGuid.replaceAll('{{guid}}', guid)).timeout(NetworkData.timeout);
      prefs.remove('carrito_guid');
      return null;
    }
  }

  static Future<dynamic> setDeliveryModeCart() async {
    Map<String, dynamic> session = await getSessionVars();
    final bool isLoggedIn = session['isLoggedIn'];
    final String guid = session['guid'];
    final String userToken = session['accessToken'];
    final bool isPickUp = session['isPickUp'];
    final String zipCode = session['zipCode'];
    final String tienda = session['tienda'];

    if (isLoggedIn) {
      String url = NetworkData.urlCartDeliveryMode;
      final String bearer = "Bearer $userToken";
      dynamic body;

      if (isPickUp && tienda != null) {
        body = {
          "selectedDelivery": tienda,
        };
      } else if (!isPickUp && zipCode != null) {
        body = {"selectedDelivery": "ENVIO", "zipCode": zipCode};
      } else {
        return null;
      }

      final response = await HttpHelper.put(url,
              headers: {
                'Authorization': bearer,
                "Content-Type": "application/x-www-form-urlencoded",
              },
              body: body)
          .timeout(NetworkData.timeout);
      var resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody;
    } else {
      if (guid != null) {
        String url = NetworkData.urlCartDeliveryModeAnonymous.replaceAll("{{cartId}}", guid);
        final String bearer = "Bearer $userToken";
        dynamic body;

        if (isPickUp && tienda != null) {
          body = {
            "selectedDelivery": tienda,
          };
        } else if (!isPickUp && zipCode != null) {
          body = {"selectedDelivery": "ENVIO", "zipCode": zipCode};
        } else {
          return null;
        }

        final response = await HttpHelper.put(url, headers: {'Authorization': bearer, "Content-Type": "application/x-www-form-urlencoded"}, body: body).timeout(NetworkData.timeout);
        var resBody = json.decode(utf8.decode(response.bodyBytes));
        return resBody;
      }
    }
  }

  static Future<dynamic> addCouponWithTokenToCart(String voucherId, String voucherToken) async {
    Map<String, dynamic> session = await getSessionVars();
    final bool isLoggedIn = session['isLoggedIn'];
    final String guid = session['guid'];
    final String userToken = session['accessToken'];

    if (isLoggedIn) {
      String url = NetworkData.urlCarritoActualAgregarCupon;
      final String bearer = "Bearer $userToken";

      Map body = {'voucherId': voucherId, 'token': voucherToken};

      Map<String, String> headers = {'Authorization': bearer, "Content-Type": "application/x-www-form-urlencoded"};

      final response = await HttpHelper.post(url, headers: headers, body: body).timeout(NetworkData.timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 422) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        return null;
      }
    } else if (guid != null) {
      String url = NetworkData.urlCarritoAnonimoAgregarCupon;
      final String bearer = "Bearer $userToken";

      Map body = {'voucherId': voucherId, 'token': voucherToken};

      Map<String, String> headers = {'Authorization': bearer, "Content-Type": "application/x-www-form-urlencoded"};

      final response = await HttpHelper.post(url, headers: headers, body: body).timeout(NetworkData.timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 422) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        return null;
      }
    }
  }

  static Future<bool> addCommentToCart(String comment) async {
    Map<String, dynamic> session = await getSessionVars();
    final bool isLoggedIn = session['isLoggedIn'];
    final String guid = session['guid'];
    final String userToken = session['accessToken'];

    if (isLoggedIn) {
      String url = NetworkData.urlCarritoActualComment;
      final String bearer = "Bearer $userToken";

      Map body = {'comment': comment};

      Map<String, String> headers = {'Authorization': bearer, "Content-Type": "application/x-www-form-urlencoded"};

      final response = await HttpHelper.post(url, headers: headers, body: body).timeout(NetworkData.timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } else {
      if (guid != null) {
        String url = NetworkData.urlCarritoAnonimoComment.replaceAll("{{cartId}}", guid);
        final String bearer = "Bearer $userToken";

        Map body = {'comment': comment};

        Map<String, String> headers = {'Authorization': bearer, "Content-Type": "application/x-www-form-urlencoded"};

        final response = await HttpHelper.post(url, headers: headers, body: body).timeout(NetworkData.timeout);

        if (response.statusCode == 200 || response.statusCode == 201) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    }
  }
}
