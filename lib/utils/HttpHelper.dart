import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';
import 'package:http/http.dart' as http;

import 'package:chd_app_demo/services/LogService.dart';
/*
 * Helper Class for HTTP _request
 */
class HttpHelper {
  var url;
  var body;
  var headers;
  static Map<String, dynamic> defaultBody = {};
  static Map<String, String> defaultHeader = {};

  static const OK = 'OK';
  static const ERROR = 'ERROR';
  static const UNDEFINED = 'UNDEFINED';
  static const TIMEOUT = Duration(seconds: 60);
  static const TIMEOUT_EXTENDED = Duration(seconds: 70);

  /* HttpHelper(this.url, this.headers, this.body); */

  /* 
   * Get method for fetch data
   * @params String url, Object headers
   * @returns Object data
   */
  static get(String url, {Map<String, String> headers, String timeout}) async {
    Map<String, String> mapHeaders = headers ?? HttpHelper.defaultHeader;

    var response = await HttpHelper._request(url, type: 'get', headers: mapHeaders, timeout: timeout);

    return response;
  }

  /* 
   * Post method for data recording
   * @params String url, Object headers, Object body
   * @returns Object data
   */
  static post(String url, {Map<String, String> headers, body, String timeout}) async {
    Map<String, String> mapHeaders = headers ?? HttpHelper.defaultHeader;
    body = body ?? HttpHelper.defaultBody;

    var response = await HttpHelper._request(url, type: 'post', headers: mapHeaders, body: body, timeout: timeout);

    return response;
  }

  /*
   * Put method for update data
   * @params String url, Object headers, Object body
   * @returns Object data
   */
  static put(String url, {Map<String, String> headers, body, String timeout}) async {
    Map<String, String> mapHeaders = headers ?? HttpHelper.defaultHeader;
    body = body ?? HttpHelper.defaultBody;

    var response = await HttpHelper._request(url, type: 'put', headers: mapHeaders, body: body, timeout: timeout);

    return response;
  }

  /*
   * Delete method for delete data
   * @params String url, Object headers
   * @returns Object data 
   */
  static delete(String url, {Map<String, String> headers, String timeout}) async {
    Map<String, String> mapHeaders = headers ?? HttpHelper.defaultHeader;

    var response = await HttpHelper._request(url, type: 'delete', headers: mapHeaders, timeout: timeout);

    return response;
  }

  /*
   * _Request method for handle _request
   * @params String url, Object { String type, Object headers, Object body }
   * @returns Object response from sever
   */

  Future getPreferences() async {
    SharedPreferences prefs;
    prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  static _request(url, {String type, Map<String, String> headers, body, timeout}) async {
    ResponseXXX responseJson;
    var response;
    var startProcess = new DateTime.now();

    try {
      switch (type) {
          case 'post':
            if (headers == HttpHelper.defaultHeader) {
              response = await http.post(url, body: body).timeout(timeout == 'extended' ? HttpHelper.TIMEOUT_EXTENDED : HttpHelper.TIMEOUT);
            } else {
              response = await http.post(url, headers: headers, body: body).timeout(timeout == 'extended' ? HttpHelper.TIMEOUT_EXTENDED : HttpHelper.TIMEOUT);
            }
            break;
          case 'put':
            if (headers == HttpHelper.defaultHeader) {
              response = await http.put(url, body: body).timeout(timeout == 'extended' ? HttpHelper.TIMEOUT_EXTENDED : HttpHelper.TIMEOUT);
            } else {
              response = await http.put(url, headers: headers, body: body).timeout(timeout == 'extended' ? HttpHelper.TIMEOUT_EXTENDED : HttpHelper.TIMEOUT);
            }
            break;
          case 'get':
            if (headers == HttpHelper.defaultHeader) {
              response = await http.get(url).timeout(timeout == 'extended' ? HttpHelper.TIMEOUT_EXTENDED : HttpHelper.TIMEOUT);
            } else {
              response = await http.get(url, headers: headers).timeout(timeout == 'extended' ? HttpHelper.TIMEOUT_EXTENDED : HttpHelper.TIMEOUT);
            }
            break;
          case 'delete':
            if (headers == HttpHelper.defaultHeader) {
              response = await http.delete(url).timeout(timeout == 'extended' ? HttpHelper.TIMEOUT_EXTENDED : HttpHelper.TIMEOUT);
            } else {
              response = await http.delete(url, headers: headers).timeout(timeout == 'extended' ? HttpHelper.TIMEOUT_EXTENDED : HttpHelper.TIMEOUT);
            }
            break;
          default:
            response = {};
            break;
        }

      var endProcess = new DateTime.now();
      Duration duration = endProcess.difference(startProcess);
      responseJson = HttpHelper._getResponse(response);
      //
      await LogService.send('${type.toString().toUpperCase()} $url : ${response.statusCode.toString()} ${response.headers.toString()} ${response.body}', {'verb': type.toString().toUpperCase(), 'url': url, 'req_body': body.toString() ?? '{}', 'res_body': response.body.toString(), 'status': response.statusCode, 'elapsed_time': duration.inMilliseconds});
    } on SocketException {
      throw Exception('No Internet connection');
    }

    return responseJson;
  }

  /*
   * Get response method which set up custom response in specific standard
   * @params Response rawResponse
   * @returns Object customResponse
   */
  static ResponseXXX _getResponse(http.Response rawResponse) {
    var responseObject;
    var response = {'status': HttpHelper.UNDEFINED, 'statusCode': rawResponse.statusCode ?? 500, 'body': rawResponse.body, 'bodyBytes': rawResponse.bodyBytes, 'data': null, 'errors': null, 'message': null};
    var responseStatusCodeString = rawResponse.statusCode.toString();
    var responseRawBody = {};

    switch (responseStatusCodeString.substring(0, 1)) {
      // 2XX
      case '2':
        response['status'] = HttpHelper.OK;
        response['data'] = responseRawBody;
        // responseObject = new Response2XX.fromJson(response);
        break;

      /*{
        "errors":
          [
            {
              "message": "...",
              "type": "...",
            }
          ]
        }*/
      // 4XX
      case '4':
        /*{
          "errors" : [ ... ],
          "messages: [ ... ]
        }*/
        List errors = [];
        List messages = [];
        Iterable errorList = responseRawBody.containsKey('errors')
            ? responseRawBody['errors']
            : [
                {'type': 400, 'message': 'Bad _Request'}
              ];

        if (errorList.length > 0) {
          errorList.map((item) {
            errors.add(item['type']);
            messages.add(item['message']);
          });
        }

        response['status'] = HttpHelper.ERROR;
        response['errors'] = errors;
        response['messages'] = messages;
        // responseObject = new Response4XX.fromJson(response);
        break;

      // 5XX
      case '5':
      default:
        /*{
        "errors" : [
          {
            "message": "Server error"
          }
        ],
        "messages": ["Error en el servicio solicitado"]
        }*/
        List errors = [];
        List messages = [];
        Iterable errorList = responseRawBody.containsKey('errors')
            ? responseRawBody['errors']
            : [
                {'type': 500, 'message': 'Internal Server Error'}
              ];

        if (errorList.length > 0) {
          errorList.map((item) {
            errors.add({'type': item['type'], 'message': item['message']});
            messages.add(item['message']);
          });
        }

        response['status'] = HttpHelper.ERROR;
        response['errors'] = errors;
        response['messages'] = messages;
        // responseObject = new Response5XX.fromJson(response);
        break;
    }

    var res = new ResponseXXX.fromJson(response);
    return res;
  }
}

/*
 * Helper Class for xxx HTTP response
 */
class ResponseXXX {
  int statusCode;
  String status;
  dynamic data;
  dynamic errors;
  dynamic messages;
  dynamic bodyBytes;
  dynamic body;

  // ResponseXXX(this.statusCode, this.status, this.data, this.errors, this.messages);

  ResponseXXX.fromJson(Map json) {
    this.statusCode = json['statusCode'];
    this.status = json['status'];
    this.data = json['data'];
    this.errors = json['errors'];
    this.messages = json['messages'];
    this.bodyBytes = json['bodyBytes'];
    this.body = json['body'];
  }
}

/*
 * Helper Class for 2xx HTTP response
 */
class Response2XX {
  int statusCode;
  String status;
  Object data;

  Response2XX(this.statusCode, this.status, this.data);

  Response2XX.fromJson(Map<String, dynamic> json)
      : statusCode = json['statusCode'],
        status = json['status'],
        data = json['data'];

  Map<String, dynamic> toJson() => {
        'statusCode': statusCode,
        'status': status,
        'data': data,
      };
}

/*
 * Helper Class for 4xx HTTP response
 */
class Response4XX {
  int statusCode;
  String status;
  String errors;
  String messages;

  Response4XX(this.statusCode, this.status, this.errors, this.messages);

  Response4XX.fromJson(Map<String, dynamic> json)
      : statusCode = json['statusCode'],
        status = json['status'],
        errors = json['errors'],
        messages = json['messages'];

  Map<String, dynamic> toJson() => {
        'statusCode': statusCode,
        'status': status,
        'errors': errors,
        'messages': messages,
      };
}

/*
 * Helper Class for 5xx HTTP response
 */
class Response5XX {
  int statusCode;
  String status;
  Object data;

  Response5XX(this.statusCode, this.status, this.data);

  Response5XX.fromJson(Map<String, dynamic> json)
      : statusCode = json['statusCode'],
        status = json['status'],
        data = json['data'];

  Map<String, dynamic> toJson() => {
        'statusCode': statusCode,
        'status': status,
        'data': data,
      };
}
