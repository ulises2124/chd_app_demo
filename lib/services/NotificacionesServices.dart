import 'dart:convert';
import 'dart:async';
import 'package:chd_app_demo/utils/NetworkData.dart';

import 'package:chd_app_demo/utils/HttpHelper.dart';

class NotificacionesServices {
  static Future registroDispositivo(body) async {
    String url = NetworkData.urlNotificacionesRegistro;
    Map <String, String> headers = {
      "Content-Type": "application/json",
    };
    var finalBody = json.encode(body);
    final response = await HttpHelper.post(
      url,
      body: finalBody,
      headers: headers,
    );
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody;
    } else {
      throw Exception('Error en registro.');
    }
  }

  static Future asociacionDispositivo(body) async {
    String url = NetworkData.urlNotificacionesAsociacion;
    Map <String, String> headers = {
      "Content-Type": "application/json",
    };
    var finalBody = json.encode(body);
    final response = await HttpHelper.post(
      url,
      body: finalBody,
      headers: headers,
    )
    .timeout(NetworkData.timeout);
    print(response);
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody;
    } else {
      throw Exception('Error en registro.');
    }
  }
}
