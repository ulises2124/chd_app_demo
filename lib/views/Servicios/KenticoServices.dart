import 'dart:convert';
import 'dart:async';
import 'package:chd_app_demo/utils/NetworkData.dart';
import 'package:chd_app_demo/views/Servicios/Util.dart';
import 'package:http/http.dart' as http;
import 'package:chd_app_demo/services/TimberService.dart';

class KenticoServices {
  static Future getMessageErrorPDS() async {
    String url = 'https://deliver.kenticocloud.com/a38e9287-f45b-00de-6ce8-23adabd3c0e5/items?system.type=mensajes_de_error';
    final response = await http.get(url);
    var e;
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      await Future.forEach(resBody['items'], (action) {
        if (action['system']['codename'] == 'pago_de_servicio___error') {
          e = action;
        }
      });
      var data = {
        'title': e['elements']['encabezado']['value'],
        'body': parseHtmlString(e['elements']['contenido']['value']),
      };
      return data;
    } else {
      return null;
    }
  }

    static Future getMessageSuccessPDS() async {
    String url = 'https://deliver.kenticocloud.com/a38e9287-f45b-00de-6ce8-23adabd3c0e5/items?system.type=mensajes_de_error';
    final response = await http.get(url);
    var e;
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      await Future.forEach(resBody['items'], (action) {
        if (action['system']['codename'] == 'pago_de_servicios___todo_bien') {
          e = action;
        }
      });
      var data = {
        'title': e['elements']['encabezado']['value'],
        'body': parseHtmlString(e['elements']['contenido']['value']),
      };
      return data;
    } else {
      return null;
    }
  }
  static Future getMessageError() async {
    String url = 'https://deliver.kenticocloud.com/a38e9287-f45b-00de-6ce8-23adabd3c0e5/items?system.type=mensajes_de_error';
    final response = await http.get(url);
    var e;
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      await Future.forEach(resBody['items'], (action) {
        if (action['system']['codename'] == 'recarga_con_monedero___error') {
          e = action;
        }
      });
      var data = {
        'title': e['elements']['encabezado']['value'],
        'body': parseHtmlString(e['elements']['contenido']['value']),
      };
      return data;
    } else {
      return null;
    }
  }

    static Future getMessageSuccess() async {
    String url = 'https://deliver.kenticocloud.com/a38e9287-f45b-00de-6ce8-23adabd3c0e5/items?system.type=mensajes_de_error';
    final response = await http.get(url);
    var e;
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      await Future.forEach(resBody['items'], (action) {
        if (action['system']['codename'] == 'recarga_con_monedero___todo_bien') {
          e = action;
        }
      });
      var data = {
        'title': e['elements']['encabezado']['value'],
        'body': parseHtmlString(e['elements']['contenido']['value']),
      };
      return data;
    } else {
      return null;
    }
  }

  static Future<List> getTextCheckout() async {
    String url = 'https://deliver.kenticocloud.com/29390711-11c7-0062-a2b1-d875d6bda227/items?system.type=textos_de_checkout';
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      List items = resBody['items'];
      if (items.length > 0) {
        return items;
      }
    } else {
      return null;
    }
  }
}
