import 'dart:convert';
import 'dart:async';
import 'package:chd_app_demo/utils/NetworkData.dart';
import 'package:chd_app_demo/services/CarritoServices.dart';

import 'package:chd_app_demo/utils/HttpHelper.dart';

class ArticulosServices {
  static Future getProducts() {
    return HttpHelper.get(NetworkData.articulosServices);
     return HttpHelper.get(NetworkData.articulosServices);
  }

  static Future getProductsHybrisSearch(String url) async {
    Map<String, dynamic> session = await CarritoServices.getSessionVars();
    bool isLocationSet = session['isLocationSet'];
    bool isPickUp = session['isPickUp'];
    String zipCode = session['zipCode'];
    String tienda = session['tienda'];
    Map<String, String> headers = {};
    if (isLocationSet) {
      if (!isPickUp) {
        headers['zipCode'] = zipCode;
      } else {
        headers['posName'] = tienda;
      }
    }
    String urlProductsHybris = NetworkData.hybrisProductsSearch + url;
    print(urlProductsHybris);
    print(headers);
    final response = await HttpHelper.get(urlProductsHybris, headers: isLocationSet ? headers : null);

    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody;
    } else {
      print('Failed to load hybris single product.');
      // throw Exception('Failed to load hybris single product.');
      return null;
    }
  }

  static Future getProductHybrisSearch(String productCode) async {
    // print("search->" + NetworkData.hybrisProductSearch + productCode);
    try {
      final String urlProductHybris = NetworkData.hybrisProductSearch + productCode + "?fields=FULL";
      final response = await HttpHelper.get(urlProductHybris);
      
      if (response.statusCode == 200) {
        final resBody = json.decode(utf8.decode(response.bodyBytes));
        return resBody;
      } else {
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sub Category Products
  static Future getProductsFromHybris() async {
    String urlArticulosHybris = NetworkData.hybrisProductSearch + 'search/?fields=FULL&pageSize=100';

    final response = await HttpHelper.get(urlArticulosHybris);
    
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody['products'];
    } else {
      throw Exception('Failed to load hybris products.');
    }
  }

  // Category Products
  static Future getCategoryProductsFromHybris(String url) async {
    String urlArticulosHybrisCategorias;

    urlArticulosHybrisCategorias = NetworkData.hybrisProductsSearch + url;
    print(url);
    final response = await HttpHelper.get(urlArticulosHybrisCategorias);
    
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody;
    } else {
      throw Exception('Failed to load hybris single product.');
    }
  }
}
