import 'dart:convert';

import 'package:chd_app_demo/views/Servicios/ServiceCards.dart';
import 'package:chd_app_demo/views/Servicios/ServicesList.dart';
import 'package:flutter/material.dart';
import 'package:strings/strings.dart';
import 'package:html/parser.dart';
//here goes the function

String parseHtmlString(String htmlString) {
  var document = parse(htmlString);

  String parsedString = parse(document.body.text).documentElement.text;

  return parsedString;
}

List getcategory(List categoryes) {
  List data = [];
  categoryes.forEach((f) {
    data.add(f['name']);
  });
  return data;
}

String getValue(List list, name) {
  try {
    var object = list.firstWhere((campo) => campo['sCampo'] == name);
    return object['sValor'];
  } on StateError catch (error) {
    print(error.message);
    return null;
  }
}

String truncateString(int cutoff, String myString) {
  return (myString.length <= cutoff) ? myString : '${myString.substring(0, cutoff)}...';
}

String formatMonedero(String monedero) {
  int length = monedero.length;
  String monederoFormatted = monedero.substring(0, 6);
  for (var i = 0; i < (length - 10); i++) {
    monederoFormatted += "*";
  }
  monederoFormatted += monedero.substring((length - 4), length);
  return monederoFormatted;
}

List<String> stringifyResults(List<dynamic> target) {
  return target.map((element) => element.toString()).toList();
}

List<ServiceCard> mapFavoriteServices(List<dynamic> services, double saldoMonedero, String email, Function onLongPress, bool extendedCard) {
  List<ServiceCard> serviceCards = new List<ServiceCard>();
  services.forEach(
    (service) async {
      var montos;
      if (service['serviceKenticoData']['montosSkus'] != "") {
        montos = await getMontos(service['serviceKenticoData']['montosSkus']);
      } else {
        montos = null;
      }
      List tipoPago = service['serviceKenticoData']['tipodePago'];
      var tiposPago;
      if (tipoPago.length > 0) {
        tiposPago = service['serviceKenticoData']['tipodePago'][0]['codename'];
      } else {
        tiposPago = null;
      }

      serviceCards.add(
        ServiceCard(
          editService: onLongPress,
          extendedCard: extendedCard,
          savedReference: service['reference'],
          alias: service['alias'],
          reminderFrequency: service['reminderFrequency'],
          serviceID: service['serviceKenticoData']['serviceID'],
          serviceLogo: getLogo(service['serviceKenticoData']['serviceLogo']) ?? '',
          cardBackground: Colors.indigo[50],
          serviceName: service['serviceKenticoData']['serviceName'] ?? '',
          serviceDescription: parseHtmlString(service['serviceKenticoData']['serviceDescription']) ?? '',
          sku: service['serviceKenticoData']['sku'].toString() ?? '',
          skuComision: service['serviceKenticoData']['skuComision'].toString() ?? '',
          categories: getcategory(service['serviceKenticoData']['categories']),
          saldoMonedero: saldoMonedero,
          userEmail: email,
          montosSkus: montos,
          messageToUser: parseHtmlString(service['serviceKenticoData']['mensajeUsuario']) ?? null,
          toolTip: getToolTip(service['serviceKenticoData']['toolTipImage']),
          toolTipDescription: parseHtmlString(service['serviceKenticoData']['toolTipText']) ?? null,
          tipoPago: tiposPago,
          status: service['serviceKenticoData']['status'] ?? '',
          dbID: service['_id'],
        ),
      );
    },
  );
  return serviceCards;
}

List<ServiceCard> mapServices(List<dynamic> services, double saldoMonedero, String email) {
  List<ServiceCard> serviceCards = new List<ServiceCard>();
  services.forEach(
    (service) async {
      if (service['elements']['informacion_general_de_servicios__habilitado_']['value'][0]['name'] == 'Habilitado') {
        var montos;
        if (service['elements']['informacion_general_de_servicios__skus_y_montos']['value'] != "") {
          montos = await getMontos(service['elements']['informacion_general_de_servicios__skus_y_montos']['value']);
        } else {
          montos = null;
        }
        var toolTip;
        List f = service['elements']['ilustracion']['value'];
        if (f.length > 0) {
          toolTip = getToolTip(service['elements']['ilustracion']['value'][0]['url']);
        } else {
          toolTip = null;
        }
        List tipoPago = service['elements']['informacion_general_de_servicio__tipo_de_pago']['value'];
        var tiposPago;
        if (tipoPago.length > 0) {
          tiposPago = service['elements']['informacion_general_de_servicio__tipo_de_pago']['value'][0]['codename'];
        } else {
          tiposPago = null;
        }

        serviceCards.add(
          ServiceCard(
            extendedCard: false,
            serviceID: service['system']['id'],
            serviceLogo: getLogo(service['elements']['informacion_general_de_servicios__logo_del_servicio']['value'][0]['url']) ?? '',
            cardBackground: Colors.indigo[50],
            serviceName: service['system']['name'] ?? '',
            serviceDescription: parseHtmlString(service['elements']['informacion_general_de_servicios__description_del_servicio_producto']['value']) ?? '',
            sku: service['elements']['informacion_general_de_servicios__sku_o_upc']['value'].toString() ?? '',
            skuComision: service['elements']['informacion_general_de_servicios__sku_en_chedraui']['value'].toString() ?? '',
            categories: getcategory(service['elements']['informacion_general_de_servicios__categoria']['value']),
            saldoMonedero: saldoMonedero,
            userEmail: email,
            montosSkus: montos,
            messageToUser: parseHtmlString(service['elements']['contenido']['value']) ?? null,
            toolTip: toolTip,
            toolTipDescription: parseHtmlString(service['elements']['descripcion']['value']) ?? null,
            tipoPago: tiposPago,
            status: service['elements']['informacion_general_de_servicios__estatus_del_servicio']['value'] ?? '',
            montoMinimo:service['elements']['informacion_general_de_servicio__monto_minimo_a_pagar']['value'].toString() ?? '',
            montoMaximo:service['elements']['informacion_general_de_servicio__cantidad_maxima_de_pago']['value'].toString() ?? '',
          ),
        );
      }
    },
  );
  return serviceCards;
}

String errorMessageFromResponse(String body) {
  List response = json.decode(body);
  return titleCase(response.firstWhere((campo) => campo['sCampo'] == 'CODIGORESPUESTADESCR')['sValor']);
}

String titleCase(String str) {
  var splitStr = str.toLowerCase().split(' ');
  for (var i = 0; i < splitStr.length; i++) {
    splitStr[i] = capitalize(splitStr[i]);
  }
  return splitStr.join(' ');
}

List<ServiceCard> getServicesByCategory(List<ServiceCard> services, String category) {
  return services.where((service) => service.categories.contains(category)).toList();
}

Future<List> getMontos(String input) async {
  List newInput = input.split('\n');
  List montos = [];
  await Future.forEach(newInput, (f) {
    var newSplit = f.split(',');
    montos.add({
      'monto': newSplit[0],
      'sku': newSplit[1],
      'skuChedraui': newSplit[2],
    });
  });
  return montos;
}
