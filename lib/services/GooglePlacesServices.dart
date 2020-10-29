import 'package:chd_app_demo/utils/NetworkData.dart';
import 'dart:async';
import 'dart:convert';

import 'package:chd_app_demo/utils/HttpHelper.dart';

class LocationServices {
  static String placesApiKey = "AIzaSyB1MWTQYGP-k3s_etjzVdQREZ9z_Hh-MvE";

  static Future getHybrisStores() async {
    var url = NetworkData.hybrisStores;
    try {
      var reponse =
          await HttpHelper.get(url, headers: {"Accept": "application/json"});
      if (reponse.statusCode == 200) {
        final resBody = json.decode(utf8.decode(reponse.bodyBytes));
        // printJsonPretty(resBody);
        return resBody;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static Future getHybrisNearbyStores(double lat, double lng) async {
    var geo = '&latitude=' + lat.toString() + '&longitude= ' + lng.toString();
    var url = NetworkData.hybrisStoresByText + geo;
    try {
      var reponse =
          await HttpHelper.get(url, headers: {"Accept": "application/json"});
      if (reponse.statusCode == 200) {
        final resBody = json.decode(utf8.decode(reponse.bodyBytes));
        // printJsonPretty(resBody);
        return resBody;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static Future getHybrisStoresByText(
    String query,
    double lat,
    double lng,
  ) async {
    var url = NetworkData.hybrisStoresByText + '&query=' + query;
    try {
      var reponse =
          await HttpHelper.get(url, headers: {"Accept": "application/json"});
      if (reponse.statusCode == 200) {
        final resBody = json.decode(utf8.decode(reponse.bodyBytes));
        print(resBody);
        return resBody;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static Future getReverseGeocoding(double lat, double lng) async {
    var latlng = 'latlng=' + lat.toString() + ',' + lng.toString();
    var key = '&key=' + placesApiKey;
    var url = NetworkData.reverseGeocoding + latlng + key;
    try {
      var reponse =
          await HttpHelper.get(url, headers: {"Accept": "application/json"});
      if (reponse.statusCode == 200) {
        final resBody = json.decode(reponse.body);
        // printJsonPretty(resBody);
        return resBody;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static Future getPlacesByIdSearch(String id) async {
    var placeid = 'placeid=' + id;
    var fields = '&fields=' + 'address_component,name';
    var key = '&key=' + placesApiKey;
    // var fields = '&fields=' + 'photos,formatted_address,name,rating,opening_hours,geometry';

    var url = NetworkData.getPlaceByIdUrl + placeid + fields + key;
    try {
      var reponse =
          await HttpHelper.get(url, headers: {"Accept": "application/json"});
      if (reponse.statusCode == 200) {
        final resBody = json.decode(reponse.body);
        // printJsonPretty(resBody);
        return resBody;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static Future getPlacesBySearch(String input, double lat, double lng) async {
    var inputKey = 'input=' + input;
    var inputtype = '&inputtype=' + 'textquery';
    var locationbias =
        '&locationbias=circle:2000@' + lat.toString() + ',' + lng.toString();
    var fields = '&fields=' + 'place_id,formatted_address,name,geometry';
    var key = '&key=' + placesApiKey;
    // var fields = '&fields=' + 'photos,formatted_address,name,rating,opening_hours,geometry';

    var url = NetworkData.findPlaceByTextUrl +
        inputKey +
        inputtype +
        locationbias +
        fields +
        key;
    try {
      var reponse =
          await HttpHelper.get(url, headers: {"Accept": "application/json"});
      if (reponse.statusCode == 200) {
        final resBody = json.decode(reponse.body);
        // printJsonPretty(resBody);
        return resBody;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static Future getPlacesNearby(double lat, double lng) async {
    var keyword = 'keyword=' + 'chedraui';
    var radius = '&radius=' + '5000';
    var location = '&location=' + lat.toString() + ',' + lng.toString();
    var key = '&key=' + placesApiKey;
    var url = NetworkData.findNearby + keyword + radius + location + key;
    try {
      var reponse =
          await HttpHelper.get(url, headers: {"Accept": "application/json"});
      if (reponse.statusCode == 200) {
        final resBody = json.decode(reponse.body);
        // printJsonPretty(resBody);
        return resBody;
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
