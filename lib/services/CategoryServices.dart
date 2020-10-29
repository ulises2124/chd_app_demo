import 'dart:convert';
import 'dart:async';
import 'package:chd_app_demo/utils/NetworkData.dart';

import 'package:chd_app_demo/utils/HttpHelper.dart';

class CategoryServices {
  static Future getApartments() async {
    final String url = NetworkData.urlNewCategoryNode;
    final response = await HttpHelper.get(url);
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody['subcategories'];
    } else {
      throw Exception('Failed to load hybris subcategorys.');
    }
  }

  static Future getAllSubCategorys(aparmentId) async {
    final String url = NetworkData.urlNewCategoryNode;
    final response = await HttpHelper.get(url);

    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      var result = searchByCode(resBody, aparmentId);
      return result;
    } else {
      return ('Failed to load hybris subcategorys.');
    }
  }

  static searchByCode(resBody, code) {
    var result;
    Map<String, dynamic> data = resBody;
    data.forEach((f, e) {
      switch (f) {
        case 'categoryCode':
          if (e == code) {
            result = resBody;
          }
          break;
        case 'subcategories':
          var arr = List.from(e);
          arr.forEach((item) {
            var localResult = searchByCode(item, code);
            if (localResult != null) result = localResult;
          });
          break;
        default:
      }
    });
    return result;
  }
}
