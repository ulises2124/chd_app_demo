import 'dart:convert';
import 'dart:async';
import 'package:chd_app_demo/utils/NetworkData.dart';

import 'package:chd_app_demo/utils/HttpHelper.dart';

class HomeServices {
  static Future getKenticoSeccion(query) async {
    String url = NetworkData.urlKenticoApp + query;
    try {
      final response = await HttpHelper.get(url);
      if (response.statusCode == 200) {
        final resBody = json.decode(utf8.decode(response.bodyBytes));
        return resBody;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future getHome(idWallet) async {
    String id = (idWallet == '' ? "WPJ6R9TOXTPYYWVGIV27RGTW2ASV25FA" : idWallet);
    print("ID--->" + id);
    print("--->>>>" + NetworkData.gCloudHome);
    String url = NetworkData.gCloudHome.replaceAll(
      "{{idUsuario}}",
      id,
    );
    Map<String, dynamic> body = {"idUsuario": id};
    final response = await HttpHelper.post(url, body: body);
    // print(response.body.toString());
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      // print(resBody["data"]);
      return resBody;
    } else {
      print("error");
      return null;
    }
  }

  static Future getProducts() async {
    String url = NetworkData.articulosServices;
    return HttpHelper.get(url);
    // return HttpHelper.get(NetworkData.articulosServices);
  }

  static Future getProductsHybrisSearch(String query, String fields) async {
    int currentPage = 0;
    // int pageSize = 1;

    String queryProperties = query +
        '&currentPage=' +
        currentPage.toString() +
        // '&pageSize=' +
        // pageSize.toString() +
        '&fields=FULL';
    String url = NetworkData.hybrisProductsSearch + queryProperties;
    final response = await HttpHelper.get(url);
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody['products'];
    } else {
      throw Exception('Failed to load hybris single product.');
    }
  }

  static Future getProductHybrisSearch(String productCode) async {
    // print("search->"+NetworkData.hybrisProductSearch + productCode);
    String url = NetworkData.hybrisProductSearch + productCode + "?fields=FULL";
    final response = await HttpHelper.get(url);
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody;
    } else {
      return "";
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
  static Future getCategoryProductsFromHybris(String code, String level) async {
    String urlArticulosHybrisCategorias = NetworkData.hybrisProductsSearch + ':relevance:category_l_';
    String url = urlArticulosHybrisCategorias + level + ':' + code;
    final response = await HttpHelper.get(url);
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody['products'];
    } else {
      throw Exception('Failed to load hybris single product.');
    }
  }
}
