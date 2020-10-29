// ENABLE DEBUG
// adb shell setprop debug.firebase.analytics.app com.planetmedia.paymentsloyalty.chedraui

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'dart:async';

class FireBaseEventController {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  static Future<bool> setCurrentScreen(String screenName) async {
    try {
      await analytics.setCurrentScreen(
        screenName: screenName,
        screenClassOverride: screenName,
      );
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  static Future<bool> sendAnalyticsEventViewItem(String productID, String productName, String productListName) async {
    try {
      await analytics.logEvent(
        name: 'view_item',
        parameters: <String, dynamic>{
          'item_id': productID,
          'product_list_name': productListName,
          'nombre_producto': productName,
        },
      );
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  static Future<bool> sendAnalyticsEventScanProduct(String product, int countScan) async {
    try {
      await analytics.logEvent(
        name: 'escanear_producto',
        parameters: <String, dynamic>{
          'nombre_del_producto': product,
          'numero_de_producto': countScan,
          // 'codigo_del_producto': code,
          // 'codigo_de_barras_escaneado': barcode,
        },
      );
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  static Future<bool> sendAnalyticsEventSelectedDepartment(String departmentName) async {
    try {
      await analytics.logEvent(
        name: 'vista_departamento',
        parameters: <String, dynamic>{
          'nombre_departamento': departmentName,
        },
      );
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  static Future<bool> sendAnalyticsEventSignUp(String singUpMethod) async {
    try {
      await analytics.logEvent(
        name: 'sing_up',
        parameters: <String, dynamic>{
          'sing_up_method': singUpMethod,
        },
      );
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  static Future<bool> sendAnalyticsEventLogin(String loginMethod) async {
    try {
      await analytics.logEvent(
        name: 'login',
        parameters: <String, dynamic>{
          'sing_up_method': loginMethod,
        },
      );
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  static Future<bool> sendAnalyticsEventMenuButtonPressed(String buttonName) async {
    try {
      await analytics.logEvent(
        name: 'menu_app',
        parameters: <String, dynamic>{
          'nombre_boton': buttonName,
        },
      );
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  static Future<bool> sendAnalyticsEventShareWishlistIntend(int productsQuantity) async {
    try {
      await analytics.logEvent(
        name: 'intencion_envio_lista',
        parameters: <String, dynamic>{
          'cantidad_wishlist': productsQuantity,
        },
      );
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  static Future<bool> sendAnalyticsEventShareWishlistSuccess(int productsQuantity) async {
    try {
      await analytics.logEvent(
        name: 'lista_enviada',
        parameters: <String, dynamic>{
          'cantidad_wishlist': productsQuantity,
        },
      );
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  static Future<bool> sendAnalyticsEventRemoveFromWishList(String productName) async {
    try {
      await analytics.logEvent(
        name: 'eliminar_producto',
        parameters: <String, dynamic>{
          'nombre_del_producto': productName,
        },
      );
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  static Future<bool> sendAnalyticsEventAddToWishList(String productName) async {
    try {
      await analytics.logEvent(
        name: 'agregar_producto_wishlist',
        parameters: <String, dynamic>{
          'nombre_del_producto': productName,
        },
      );
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  static Future<bool> sendAnalyticsEventScanProductFail(String product) async {
    try {
      await analytics.logEvent(
        name: 'producto_no_encontrado',
        parameters: <String, dynamic>{
          'nombre_del_producto': 'Sin identificar',
          // 'nombre_del_producto': product,
        },
      );
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  static Future<bool> sendAnalyticsEventBeginCheckOut(dynamic cartData) async {
    try {
      var entries = cartData['entries'];
      List _productsNames = [];
      List _productsCategories = [];
      List _productsIDs = [];
      List _productsPrices = [];
      entries.forEach((entry) {
        _productsNames.add(entry['product']['name']);
        _productsCategories.add(() {
          String categories = "";
          List categoriesList = entry['product']['categories'];
          List categoriesCodes = [];
          if (categoriesList != null) {
            categoriesList.forEach((c) {
              categoriesCodes.add(c['code']);
            });
          }
          categories = categoriesCodes.join('/');
          return categories;
        }());
        _productsIDs.add(entry['product']['code']);
        _productsPrices.add(entry['totalPrice']['value'].toString());
      });

      await analytics.logEvent(
        name: 'begin_checkout',
        parameters: <String, dynamic>{
          'quantity': cartData['totalItems'],
          'value': cartData['totalPrice']['value'],
          'nombre_producto': _productsNames.join('|'),
          'item_category': _productsCategories.join('|'),
          'item_id': _productsIDs.join('|'),
          'price': _productsPrices.join('|'),
          'currency': "MXN",
        },
      );
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  static Future<bool> sendAnalyticsEventProductFilterAndSort(String type, String selected) async {
    String value = '';
    if (type == 'Ordenar') {
      switch (selected) {
        case ':relevance':
          value = 'Relevancia';
          break;
        case ':topRated':
          value = 'Mejores Valorados';
          break;
        case ':name-asc':
          value = 'Nombre asc (A-z)';
          break;
        case ':name-desc':
          value = 'Nombre desc (Z-a)';
          break;
        case ':price-asc':
          value = 'Precio (Menor-Mayor)';
          break;
        case ':price-desc':
          value = 'Precio (Mayor-Menor)';
          break;
        case ':mostSold':
          value = 'Más Vendidos';
          break;
        default:
      }
    } else {
      value = selected;
    }
    try {
      await analytics.logEvent(
        name: 'uso_filtro',
        parameters: <String, dynamic>{
          'filtro_seleccionado': type,
          'parametro_filtro': value,
        },
      );
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  static Future<bool> sendAnalyticsEventEcommercePurchase(
    dynamic orderData,
    String payMethod,
    num monederoUso,
    num monederoFinal,
  ) async {
    try {
      // List entries = orderData['entries'];
      // List _productsNames = [];
      // List _productsCategories = [];
      // List _productsIDs = [];
      // List _productsPrices = [];
      // entries.forEach((entry) {
      //   _productsNames.add(entry['product']['name']);
      //   _productsCategories.add((){
      //     String categories = "";
      //     List categoriesList = entry['product']['categories'];
      //     List categoriesCodes = [];
      //     if(categoriesList != null){
      //       categoriesList.forEach((c){
      //         categoriesCodes.add(c['code']);
      //       });
      //       categories = categoriesCodes.join('/');
      //     }
      //     return categories;
      //   }());
      //   _productsIDs.add(entry['product']['code']);
      //   _productsPrices.add(entry['totalPrice']['value'].toString());
      // });

      // String transactionId = orderData['code'];
      // String deliveryMethod = orderData['deliveryMode']['name'];
      // String tax = orderData['totalTax']['value'].toString();
      // String shippingCost = orderData['deliveryCost']['value'].toString();
      String value = orderData['totalPrice']['value'].toString();
      String quantity = orderData['totalItems'].toString();
      // String productsNames = _productsNames.join('|');
      // String productsCategories = _productsCategories.join('|');
      // String productsIDs = _productsIDs.join('|');
      // String productsPrice = _productsPrices.join('|');

      await analytics.logEvent(
        name: 'ecommerce_purchase',
        parameters: <String, dynamic>{
          // 'transaction_id': transactionId,
          'value': value,
          'quantity': quantity,
          'currency': "MXN",
          // 'nombre_producto': productsNames,
          // 'item_category': productsCategories,
          // 'item_id': productsIDs,
          // 'price': productsPrice,
          // 'shipping': shippingCost,
          // 'impuesto': tax,
          // 'tipo_entrega': deliveryMethod,
          // 'metodo_pago': payMethod,
          // 'mondero_uso': monederoUso.toString(),
          // 'mondero_saldo_final': monederoFinal.toString()
        },
      );
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  static Future<bool> sendAnalyticsEventAddToCart(
    double productQty,
    String productName,
    String productCategory,
    String productID,
    double productPrice,
  ) async {
    try {
      await analytics.logEvent(
        name: 'add_to_cart',
        parameters: <String, dynamic>{
          'quantity': productQty,
          'nombre_producto': productName,
          'item_category': productCategory,
          'item_id': productID,
          'price': productPrice,
          'value': productPrice,
          'currency': "MXN",
        },
      );
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  static Future<bool> sendAnalyticsEventSearchResults(String searchTerms, int searchResults) async {
    try {
      await analytics.logEvent(
        name: 'view_search_results',
        parameters: <String, dynamic>{
          'search_term': searchTerms,
          'numero_resultados_busqueda': searchResults,
        },
      );
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  static Future<bool> sendAnalyticsEventViewItemList(String productCategory, String productListName) async {
    try {
      await analytics.logEvent(
        name: 'view_item_list',
        parameters: <String, dynamic>{
          'item_category': productCategory,
          'product_list_name': productListName,
        },
      );
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  static Future<bool> sendAnalyticsEventSelectedCategory(String departmentName, String categoryName) async {
    try {
      await analytics.logEvent(
        name: 'vista_categoria_departamento',
        parameters: <String, dynamic>{
          'nombre_departamento': departmentName,
          'nombre_categoria_departamento': categoryName,
        },
      );
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  static Future<bool> sendAnalyticsEventSelectedCategoryDepartment(String departmentName, String categoryName, String listCategoryName) async {
    try {
      await analytics.logEvent(
        name: 'vista_lista_categoria_departamento',
        parameters: <String, dynamic>{
          'nombre_departamento': departmentName,
          'nombre_categoria_departamento': categoryName,
          'nombre_lista_categoria_departamento': listCategoryName,
        },
      );
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  // static Future<bool> sendAnalyticsEvent() async {
  //   try {
  //     await analytics.logEvent(
  //       name: 'test_event',
  //       parameters: <String, dynamic>{
  //         'string': 'Mario',
  //         'int': 24,
  //         // 'long': 12345678910,
  //         'double': 42.0,
  //         'bool': true,
  //       },
  //     );
  //     return Future.value(true);
  //   } catch (e) {
  //     return Future.value(false);
  //   }
  // }

  //   await analytics.logSearch(
  //     searchTerm: 'hotel',
  //     numberOfNights: 2,
  //     numberOfRooms: 1,
  //     numberOfPassengers: 3,
  //     origin: 'test origin',
  //     destination: 'test destination',
  //     startDate: '2015-09-14',
  //     endDate: '2015-09-16',
  //     travelClass: 'test travel class',
  //   );
  // Future<void> _testSetUserId() async {
  //   await analytics.setUserId('some-user');
  //   setMessage('setUserId succeeded');
  // }

  // Future<void> _testSetCurrentScreen() async {
  //   await analytics.setCurrentScreen(
  //     screenName: 'Analytics Demo',
  //     screenClassOverride: 'AnalyticsDemo',
  //   );
  //   setMessage('setCurrentScreen succeeded');
  // }

  // Future<void> _testSetAnalyticsCollectionEnabled() async {
  //   await analytics.setAnalyticsCollectionEnabled(false);
  //   await analytics.setAnalyticsCollectionEnabled(true);
  //   setMessage('setAnalyticsCollectionEnabled succeeded');
  // }

  // Future<void> _testSetSessionTimeoutDuration() async {
  //   await analytics.android?.setSessionTimeoutDuration(2000000);
  //   setMessage('setSessionTimeoutDuration succeeded');
  // }

  // Future<void> _testSetUserProperty() async {
  //   await analytics.setUserProperty(name: 'regular', value: 'indeed');
  //   setMessage('setUserProperty succeeded');
  // }

  // Future<void> _testAllEventTypes() async {
  //   await analytics.logAddPaymentInfo();
  //   await analytics.logAddToCart(
  //     currency: 'USD',
  //     value: 123.0,
  //     itemId: 'test item id',
  //     itemName: 'test item name',
  //     itemCategory: 'test item category',
  //     quantity: 5,
  //     price: 24.0,
  //     origin: 'test origin',
  //     itemLocationId: 'test location id',
  //     destination: 'test destination',
  //     startDate: '2015-09-14',
  //     endDate: '2015-09-17',
  //   );
  //   await analytics.logAddToWishlist(
  //     itemId: 'test item id',
  //     itemName: 'test item name',
  //     itemCategory: 'test item category',
  //     quantity: 5,
  //     price: 24.0,
  //     value: 123.0,
  //     currency: 'USD',
  //     itemLocationId: 'test location id',
  //   );
  //   await analytics.logAppOpen();
  //   await analytics.logBeginCheckout(
  //     value: 123.0,
  //     currency: 'USD',
  //     transactionId: 'test tx id',
  //     numberOfNights: 2,
  //     numberOfRooms: 3,
  //     numberOfPassengers: 4,
  //     origin: 'test origin',
  //     destination: 'test destination',
  //     startDate: '2015-09-14',
  //     endDate: '2015-09-17',
  //     travelClass: 'test travel class',
  //   );
  //   await analytics.logCampaignDetails(
  //     source: 'test source',
  //     medium: 'test medium',
  //     campaign: 'test campaign',
  //     term: 'test term',
  //     content: 'test content',
  //     aclid: 'test aclid',
  //     cp1: 'test cp1',
  //   );
  //   await analytics.logEarnVirtualCurrency(
  //     virtualCurrencyName: 'bitcoin',
  //     value: 345.66,
  //   );
  //   await analytics.logEcommercePurchase(
  //     currency: 'USD',
  //     value: 432.45,
  //     transactionId: 'test tx id',
  //     tax: 3.45,
  //     shipping: 5.67,
  //     coupon: 'test coupon',
  //     location: 'test location',
  //     numberOfNights: 3,
  //     numberOfRooms: 4,
  //     numberOfPassengers: 5,
  //     origin: 'test origin',
  //     destination: 'test destination',
  //     startDate: '2015-09-13',
  //     endDate: '2015-09-14',
  //     travelClass: 'test travel class',
  //   );
  //   await analytics.logGenerateLead(
  //     currency: 'USD',
  //     value: 123.45,
  //   );
  //   await analytics.logJoinGroup(
  //     groupId: 'test group id',
  //   );
  //   await analytics.logLevelUp(
  //     level: 5,
  //     character: 'witch doctor',
  //   );
  //   await analytics.logLogin();
  //   await analytics.logPostScore(
  //     score: 1000000,
  //     level: 70,
  //     character: 'tiefling cleric',
  //   );
  //   await analytics.logPresentOffer(
  //     itemId: 'test item id',
  //     itemName: 'test item name',
  //     itemCategory: 'test item category',
  //     quantity: 6,
  //     price: 3.45,
  //     value: 67.8,
  //     currency: 'USD',
  //     itemLocationId: 'test item location id',
  //   );
  //   await analytics.logPurchaseRefund(
  //     currency: 'USD',
  //     value: 45.67,
  //     transactionId: 'test tx id',
  //   );

  //   await analytics.logSelectContent(
  //     contentType: 'test content type',
  //     itemId: 'test item id',
  //   );
  //   await analytics.logShare(contentType: 'test content type', itemId: 'test item id', method: 'facebook');
  //   await analytics.logSignUp(
  //     signUpMethod: 'test sign up method',
  //   );
  //   await analytics.logSpendVirtualCurrency(
  //     itemName: 'test item name',
  //     virtualCurrencyName: 'bitcoin',
  //     value: 34,
  //   );
  //   await analytics.logTutorialBegin();
  //   await analytics.logTutorialComplete();
  //   await analytics.logUnlockAchievement(id: 'all Firebase API covered');
  //   await analytics.logViewItem(
  //     itemId: 'test item id',
  //     itemName: 'test item name',
  //     itemCategory: 'test item category',
  //     itemLocationId: 'test item location id',
  //     price: 3.45,
  //     quantity: 6,
  //     currency: 'USD',
  //     value: 67.8,
  //     flightNumber: 'test flight number',
  //     numberOfPassengers: 3,
  //     numberOfRooms: 1,
  //     numberOfNights: 2,
  //     origin: 'test origin',
  //     destination: 'test destination',
  //     startDate: '2015-09-14',
  //     endDate: '2015-09-15',
  //     searchTerm: 'test search term',
  //     travelClass: 'test travel class',
  //   );
  //   await analytics.logViewItemList(
  //     itemCategory: 'test item category',
  //   );
  //   await analytics.logViewSearchResults(
  //     searchTerm: 'test search term',
  //   );
  //   setMessage('All standard events logged successfully');
  // }
}
