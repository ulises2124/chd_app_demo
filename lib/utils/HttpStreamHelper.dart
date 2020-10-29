import 'dart:io';
import 'dart:async';
import 'dart:convert';

/*
 * Http helper class for handle stream connections with external APIs
 */
class HttpStreamHelper {
  static const OK = 'OK';
  static const ERROR = 'ERROR';
  static const UNDEFINED = 'UNDEFINED';

  /*
   * Get method for fetching data
   * @params String url, Object headers
   * @returns Object data
   */
  static Future<dynamic> get(url, headers) async {
    return await HttpStreamHelper._request(url, 'get', headers, null);
  }

  /*
   * Post method for recording data
   * @params String url, Object headers, Object body
   * @returns Object data
   */
  static Future<dynamic> post(url, headers, body) async {
    return await HttpStreamHelper._request(url, 'post', headers, body);
  }

  /*
   * Put method for update data
   * @params String url, Object headers, Object body
   * @returns Object data
   */
  static Future<dynamic> put(url, headers, body) async {
    return await HttpStreamHelper._request(url, 'put', headers, body);
  }

  /*
   * Post method for remove data
   * @params String url, Object headers
   * @returns Object data
   */
  static Future<dynamic> delete(url, headers) async {
    return await HttpStreamHelper._request(url, 'delete', headers, null);
  }

  /*
   * Request method for data manipulation
   * @params String url, Object headers, Object body
   * @returns Object data
   */
  static Future<dynamic> _request(url, type, headers, body) async {
    var request;
    var statusResponse;

    // Setting up Stream Client
    final client = HttpClient();
    client.connectionTimeout = Duration(seconds: 30);

    // Making request to server
    switch(type) {
      case 'get':
        request = await client.getUrl(Uri.parse(url));
        break;
      case 'post':
        request = await client.postUrl(Uri.parse(url));
        break;
      case 'put':
        request = await client.putUrl(Uri.parse(url));
        break;
      case 'delete':
        request = await client.deleteUrl(Uri.parse(url));
        break;
      default:
        break;
    }

    // Setting up Buffer will container response
    StringBuffer builder = new StringBuffer();

    // Handle request and it's status
    if (request != null) {
      // Configuring request
      if (headers != null) {
        headers.forEach((k, v) {
          request.headers.set(k, v);
        });
      }
      if (body != null && (type=='post' || type=='put')) {
        request.write(body);
      }

      // Handle request
      final response = await request.close();
      statusResponse = HttpStreamHelper._getStatusResponse(response);

      // Writing data into buffer
      await for (String a in response.transform(utf8.decoder)) {
        if (a != null) {
          builder.write(a);
        }
      }
    }

    // Return response based on standard
    return HttpStreamHelper._getResponse({
      'headers': statusResponse!=null ? statusResponse['headers'] : '',
      'statusCode': statusResponse!=null ? statusResponse['statusCode'] : 500,
      'contentLength': statusResponse!=null ? statusResponse['contentLength'] : '',
      'connectionInfo': statusResponse!=null ? statusResponse['connectionInfo'] : '',
      'bodyBytes': builder!=null ? builder.toString() : ''
    });
  }

  /*
   * Get connection status
   * @params Object response
   * @returns Object status
   */
  static dynamic _getStatusResponse(response) {
    return {
      'headers': response!=null ? response.headers : '',
      'statusCode': response!=null ? response.statusCode : 500,
      'contentLength': response!=null ? response.contentLength : -1,
      'connectionInfo': response!=null ? response.connectionInfo : ''
    };
  }

  /*
   * Get response method which set up custom response in specific standard
   * @params Response rawResponse
   * @returns Object customResponse
   */
  static dynamic _getResponse(rawResponse) {
    var responseObject;
    var response = {
      'statusCode': rawResponse['statusCode'],
      'status': HttpStreamHelper.UNDEFINED
    };
    var responseStatusCodeString = rawResponse['statusCode'].toString();
    var responseRawBody = (rawResponse['statusCode']>=200&&rawResponse['statusCode']<203) ? json.decode(rawResponse['bodyBytes']) : {};

    switch ( responseStatusCodeString.substring(0,1) ) {
      // 2XX
      case '2':
        response['status'] = HttpStreamHelper.OK;
        response['data'] = responseRawBody;
        responseObject = new Response2XX.fromJson(response);
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
          : [{
            'type': 400,
            'message': 'Bad Request'
          }];

        if (errorList.length > 0) {
          errorList.map((item) {
            errors.add(item['type']);
            messages.add(item['message']);
          });
        }

        response['status'] = HttpStreamHelper.ERROR;
        response['errors'] = errors;
        response['messages'] = messages;
        responseObject = new Response4XX.fromJson(response);
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
          : [{
            'type': 500,
            'message': 'Internal Server Error'
          }];
        
        if (errorList.length > 0) {
          errorList.map((item) {
            errors.add({
              'type': item['type'],
              'message': item['message']
            });
            messages.add(item['message']);
          });
        }

        response['status'] = HttpStreamHelper.ERROR;
        response['errors'] = errors;
        response['messages'] = messages;
        responseObject = new Response5XX.fromJson(response);
        break;
    }

    return responseObject;
  }
}

class Response2XX {
  final int statusCode;
  final String status;
  final Object data;

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

class Response4XX {
  final int statusCode;
  final String status;
  final String errors;
  final String messages;

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

class Response5XX {
  final int statusCode;
  final String status;
  final Object data;

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