import 'dart:convert';
import 'dart:async';
import 'package:chd_app_demo/utils/NetworkData.dart';
import 'package:chd_app_demo/services/CarritoServices.dart';

import 'package:chd_app_demo/utils/HttpHelper.dart';

class MediosPagoService {

  static Future payment_with_paypal(String mode,
                                    String transactionDescription,
                                    String intent,
                                    dynamic items,
                                    double discount,
                                    double shipping,
                                    double subtotal,
                                    double tax,
                                    double total) async{

    String url = NetworkData.urlMDPPaymentWithPaypal;
    var headers = {"Content-Type": "application/json"};
    Map data = {
      "mode": mode,
      "transactionDescription": transactionDescription,
      "intent": intent,
      "items": items,
      "discount": discount,
      "shipping": shipping,
      "subtotal": subtotal,
      "tax": tax,
      "total": total
    };

    print(data);

    var response = await HttpHelper.post(url,
        headers: headers, body: utf8.encode(json.encode(data)));
    print('payment_with_paypal');
    print(response.statusCode);
    
    if (response.statusCode == 200) {
      final resBody = json.decode(utf8.decode(response.bodyBytes));
      return resBody;
    } else {
      print(response.body);
      //throw Exception('Failed to load MDP payment_with_paypal.');
      return null;
    }
  }

  static Future placeOrder(cartCode) async{
    print("=================> placeOrder.cartCode: $cartCode");
    final session = await CarritoServices.getSessionVars();
    final String userToken = session['accessToken'];
    
    String url = NetworkData.urlPlaceOrder
              .replaceAll('{{cartCode}}', cartCode);
    Map <String, String> headers = {
      'Authorization': 'Bearer $userToken'
    };
    print("=================> placeOrder.userToken: $userToken");
    if (userToken != null) {
      print("=================> paso 1");
      final response = await HttpHelper.post(
          url,
          headers: headers,
          body: {}
      )
      .timeout(NetworkData.timeout);
      print(response.body);
      
      if(response.statusCode == 200 || response.statusCode == 201){
        final resBody = json.decode(utf8.decode(response.bodyBytes));
        return resBody;
      } else {
        print(response.body);
        return null;
        //throw Exception('Error al poner la orden nueva.');
      }
    }
  }

}