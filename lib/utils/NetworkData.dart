class NetworkData {
  // Routes declaration
  static const String currentEnv = 'PROD';

  static const String hybrisProd = 'https://prod.chedraui.com.mx';
  static const String hybrisProdAlternative = 'https://chedraui.com.mx';
  static const String hybrisStage = 'https://stage.chedraui.com.mx';

  static const String monederoProd = 'http://sbeam.chedraui.com.mx:9003/api';
  static const String monederoStage = 'http://129.150.87.103:9103/api';

  static const String saldoMonederoProd = 'http://sbeam.chedraui.com.mx:9010/api';
  static const String saldoMonederoStage = 'http://129.150.87.103:9110/api';

  static const String monederoRcsProd = 'https://us-central1-chedraui-omnicanal.cloudfunctions.net/monederoService';
  static const String monederoRcsStage = 'https://us-central1-chedraui-pre.cloudfunctions.net/monederoService';

  //static const String bovedaStage = 'http://129.150.87.103:9100/api';
  //static const String bovedaProd = 'https://chedraui-pre.appspot.com/api';
  //static const String bovedaProd = 'https://boveda-dot-chedraui-pre.appspot.com/api';
  static const String bovedaProd = 'https://boveda-services-dot-chedraui-omnicanal.appspot.com/api';
  //static const String bovedaStage = 'https://chedraui-omnicanal.appspot.com/api';
  //static const String bovedaStage = 'https://boveda-dot-chedraui-omnicanal.appspot.com/api';
  static const String bovedaStage = 'https://boveda-services-dot-chedraui-pre.appspot.com/api';

  static const String pushNotificationsProd = 'http://sbeam.chedraui.com.mx:9009/api';
  static const String pushNotificationsStage = 'http://129.150.87.103:9109/api';

  static const String comparadorProd = 'http://sbeam.chedraui.com.mx:9006/api';
  static const String comparadorStage = 'http://129.150.87.103:9106/api';

  static const String crmProd = 'http://sbeam.chedraui.com.mx:9008/api';
  static const String crmStage = 'http://129.150.87.103:9108/api';

  static const String promoProd = 'http://sbeam.chedraui.com.mx:9004/api';
  static const String promoStage = 'http://129.150.87.103:9104/api';

  static const String pagoProd = 'https://mdp-dot-chedraui-pre.appspot.com/api';
  static const String pagoStage = 'http://129.150.87.103:9101/api';

  static const String seguridadProd = 'http://sbeam.chedraui.com.mx:9002/api';
  static const String seguridadStage = 'http://129.150.87.103:9102/api';

  static const String facturacionProd = 'https://us-central1-chedraui-pre.cloudfunctions.net';
  static const String facturacionStage = 'http://129.150.87.103:9114/api/';

  static const String pedidosProd = 'https://www.wit-cx.com:2444/api/v1/orders';
  static const String pedidosStage = 'https://www.wit-cx.com:3444/api/v1/orders';

  static const String chatProd = 'https://www.wit-cx.com:9447';
  static const String chatStage = 'https://www.wit-cx.com:3447';

  // Routes final URL
  static const String hybrisBaseUrl = currentEnv == 'PROD' ? hybrisProd : hybrisStage;
  static const String monederoBaseUrl = currentEnv == 'PROD' ? monederoProd : monederoStage;
  static const String saldoMonederoBaseUrl = currentEnv == 'PROD' ? saldoMonederoProd : saldoMonederoStage;
  static const String monederoRcsBaseUrl = currentEnv == 'PROD' ? monederoRcsProd : monederoRcsStage;
  static const String bovedaBaseUrl = currentEnv == 'PROD' ? bovedaProd : bovedaStage;
  static const String pushNotificationsBaseUrl = currentEnv == 'PROD' ? pushNotificationsProd : pushNotificationsStage;
  static const String comparadorBaseUrl = currentEnv == 'PROD' ? comparadorProd : comparadorStage;
  static const String crmBaseUrl = currentEnv == 'PROD' ? crmProd : crmStage;
  static const String promoBaseUrl = currentEnv == 'PROD' ? promoProd : promoStage;
  static const String pagoBaseurl = currentEnv == 'PROD' ? pagoProd : pagoStage;
  static const String seguridadBaseUrl = currentEnv == 'PROD' ? seguridadProd : seguridadStage;
  static const String facturacionBaseUrl = currentEnv == 'PROD' ? facturacionProd : facturacionStage;
  static const String pedidosBaseUrl = currentEnv == 'PROD' ? pedidosProd : pedidosStage;
  static const String urlBaseChatMercury = currentEnv == 'PROD' ? chatProd : chatStage;

  // OpenPayKey
  static const String openPayKey = currentEnv == 'PROD' ? "c2tfMTZjYTAxYWFlYzI0NGMxZDhiMGU2ZWViYzFlOWNhM2M6" : "c2tfM2YzNjFlYWU0ZjVjNGIzZjlkNmY1ZjBjYmVjNjRjMzg6";

  // PLACEHOLDER LINK (TEST PURPOSES)
  static const String articulosServices = 'https://jsonplaceholder.typicode.com/photos';

  // Stores
  static const String hybrisStoresByText = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/stores?pageSize=500&radius=5000&fields=FULL';
  static const String hybrisStores = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/stores?pageSize=500&radius=5000&fields=FULL';

  // User
  static const String hybrisLogin = hybrisBaseUrl + '/authorizationserver/oauth/token';
  static const String hybrisUser = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/current';

  // Cart
  static const String hybrisGetCartByID = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/current/carts/';
  static const String urlCarritosActualesDescriptor = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/current/carts/';
  static const String urlCarritoActualDescriptor = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/current/carts/current/';
  static const String urlCarritoActualDescriptorEntries = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/current/carts/current/entries';
  static const String urlCarritoActualDescriptorEntry = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/current/carts/current/entries/{{pos}}';
  static const String urlCarritoActualDescriptorEntryUpdate = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/current/carts/current/entries/{{pos}}?qty={{qty}}';
  static const String urlCarritoActualTimeSlots = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/current/carts/current/timeslots';
  static const String urlCarritoActualTimeSlotsAnonimo = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/anonymous/carts/{{cartId}}/timeslots';
  static const String urlCarritoActualComment = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/current/carts/current/comments';
  static const String urlCarritoAnonimo = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/anonymous/carts';
  static const String urlCarritoAnonimoGuid = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/anonymous/carts/{{guid}}';
  static const String urlCarritoInStoreRecipient = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/current/carts/current/recipient';
  static const String urlCarritoInStoreRecipientAnonimous = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/anonymous/carts/{{guid}}/email';
  static const String urlCarritoInStoreRecipientAnonimousUpdate = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/anonymous/carts/{{guid}}/recipient';
  static const String urlCarritoAnonimoEntries = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/anonymous/carts/{{guid}}/entries';
  static const String urlCarritoAnonimoEntry = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/anonymous/carts/{{guid}}/entries/{{pos}}';
  static const String urlCarritoAnonimoEntryUpdate = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/anonymous/carts/{{guid}}/entries/{{pos}}?qty={{qty}}';
  static const String urlCartDeliveryMode = hybrisBaseUrl + "/chedrauicommercewebservices/v2/chedraui/users/current/carts/current/deliverymode";
  static const String urlCartDeliveryModeAnonymous = hybrisBaseUrl + "/chedrauicommercewebservices/v2/chedraui/users/anonymous/carts/{{cartId}}/deliverymode";
  static const String urlCarritoActualAgregarCupon = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/current/carts/current/vouchers';
  static const String urlCarritoAnonimoAgregarCupon = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/anonymous/carts/{{cartId}}/vouchers';
  static const String urlCarritoAnonimoComment = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/anonymous/carts/{{cartId}}/comments';

  // Checkout
  static const String urlPayMethods = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/current/carts/current/checkout/payment-methods';
  static const String urlPayMethodsAnonymous = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/anonymous/carts/{{cartId}}/checkout/payment-methods';
  static const String urlAssociatedStores = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/{{email}}/carts/{{cartCode}}/paymentdetails/associatedStores';
  static const String urlSetPaymethod = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/{{email}}/carts/{{cartCode}}/paymentdetails';
  static const String urlPlaceOrder = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/current/orders?cartId={{cartCode}}';
  static const String urlPlaceOrderAnonymous = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/anonymous/orders?cartId={{cartCode}}';
  static const String urlGetPaynetPaymentDetail = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/orders/{{orderCode}}/paynetpaymentdetail';
  static const String openPayUrl = 'https://us-central1-chedraui-omnicanal.cloudfunctions.net/openpay/realizaCargo'; //NOT USED
  //static const String urlMonederoVincular = 'https://us-central1-chedraui-pre.cloudfunctions.net/monedero/vincularMonedero';
  static const String urlMonederoVincular = monederoBaseUrl + '/monedero/vincularMonedero';

  static const String urlTokenOpenPay = currentEnv == 'PROD' ? 'https://api.openpay.mx/v1/maguopugd9yegq2h8bhy/tokens' : 'https://sandbox-api.openpay.mx/v1/ml7ihaxhfomook7tp9ei/tokens';
  static const String urlPointsOpenPay = currentEnv == 'PROD' ? 'https://api.openpay.mx/v1/maguopugd9yegq2h8bhy/tokens/{TOKEN_ID}/points' : 'https://sandbox-api.openpay.mx/v1/ml7ihaxhfomook7tp9ei/tokens/{TOKEN_ID}/points';
  static const String urlCardsOpenPay = currentEnv == 'PROD' ? 'https://api.openpay.mx/v1/maguopugd9yegq2h8bhy/cards' : 'https://sandbox-api.openpay.mx/v1/ml7ihaxhfomook7tp9ei/cards';
  static const String urlUpdateCvv2OpenPay = currentEnv == 'PROD' ? 'https://api.openpay.mx/v1/maguopugd9yegq2h8bhy/customers/{CUSTOMER_ID}/cards/{TOKEN_ID}' : 'https://sandbox-api.openpay.mx/v1/ml7ihaxhfomook7tp9ei/customers/{CUSTOMER_ID}/cards/{TOKEN_ID}';

  static const String urlCardInstallments = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/current/carts/current/paymentdetails/installments';
  static const String urlCardInstallmentsAnonymous = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/anonymous/carts/{{guid}}/paymentdetails/installments';
  static const String urlMDPPaymentWithPaypal = 'https://us-central1-chedraui-pre.cloudfunctions.net/mdp/payment_with_paypal';
  //static const String urlMDPPaymentWithPaypal = pagoBaseurl + '/mdp/payment_with_paypal';
  static const String urlTokenTarjetaRegistrada = currentEnv == 'PROD' ? 'https://mdp-dot-chedraui-pre.appspot.com/api/mdp/obtenerToken' : pagoBaseurl + "/mdp/obtenerToken"; // NO FUNCIONA POR CVV2
  //static const String urlTokenTarjetaRegistrada = 'https://mdp-dot-chedraui-pre.appspot.com/api/mdp/obtenerToken';
  static const String urlBankPoints = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/current/carts/current/paymentdetails/bankPoints';

  // Products search
  static const String hybrisProductsSearch = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/products/search?query=';
  static const String hybrisProductSearch = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/products/';
  static const String urlArticulosHybris = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/products/search/?fields=FULL&pageSize=100';
  static const String urlCategorias = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/catalogs/chedrauiProductCatalog/Online/categories/';
  static const String urlArticuloIndividualHybris = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/products/search/?query=';
  static const String urlArticulosHybrisCategorias = '/products/search?query=:relevance:category_l_';
  static const String urlNewCategoryNode = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/navigation/navigationNode';
  // Buzón
  //static const String urlBuzonConsultar = 'https://us-central1-chedraui-pre.cloudfunctions.net/buzon/{{idWallet}}/consultarBuzon';
  static const String urlBuzonConsultar = pushNotificationsBaseUrl + '/buzon/{{idWallet}}/consultarBuzon';
  //static const String urlBuzonLeido = 'https://us-central1-chedraui-pre.cloudfunctions.net/buzon/{{idWallet}}/{{idMessage}}/leido';
  static const String urlBuzonLeido = pushNotificationsBaseUrl + '/buzon/{{idWallet}}/{{idMessage}}/leido';

  // Monedero
  //static const String urlIdMonedero = 'https://us-central1-chedraui-pre.cloudfunctions.net/monedero/obtenerMonedero';
  static const String urlIdMonedero = monederoBaseUrl + '/monedero/obtenerMonedero';
  static const String urlSaldoMonedero = saldoMonederoBaseUrl + '/monedero/saldo/{{idMonedero}}?sucursal=-1&destino=WP';
  static const String urlSaldoMonederoRCS = monederoRcsBaseUrl + '/balancequery?tarjeta={{idMonedero}}';
  static const String urlBovedaCartera = bovedaBaseUrl + '/boveda/listarTarjetas';
  static const String urlAddCard = bovedaBaseUrl + '/boveda/crearTarjeta';
  static const String urlEditCard = bovedaBaseUrl + '/boveda/actualizarTarjeta';
  static const String urlDeleteCard = bovedaBaseUrl + '/boveda/cancelarTarjeta';
  static const String urlBuscarTarjeta = bovedaBaseUrl + '/boveda/buscarTarjeta';
  static const String urlGetTarjeta = bovedaBaseUrl + '/boveda/getTarjeta';
  //static const String urlRechargeMonedero = currentEnv == 'PROD' ? 'https://boveda-dot-chedraui-pre.appspot.com/api/boveda/recargarMonedero' : 'https://boveda-dot-chedraui-omnicanal.appspot.com/api/boveda/recargarMonedero';
  //static const String urlGetInfoTarjeta = currentEnv == 'PROD' ? 'https://boveda-dot-chedraui-pre.appspot.com/api/boveda/obtenerBanco' : 'https://boveda-dot-chedraui-omnicanal.appspot.com/api/boveda/obtenerBanco';
  //static const String urlGetWalletByEmail = currentEnv == 'PROD' ? 'https://boveda-dot-chedraui-pre.appspot.com/api/boveda/TblUsuarioDAO/findByEmail?email={{email}}' : 'https://boveda-dot-chedraui-omnicanal.appspot.com/api/boveda/TblUsuarioDAO/findByEmail?email={{email}}';
  static const String urlRechargeMonedero = bovedaBaseUrl + '/boveda/recargarMonedero';
  static const String urlGetInfoTarjeta = bovedaBaseUrl + '/boveda/obtenerBanco';
  static const String urlGetWalletByEmail = bovedaBaseUrl + '/boveda/TblUsuarioDAO/findByEmail?email={{email}}';

  //PROD
  static const String urlActualizaTarjetaTokenizada = 'https://api.openpay.mx/v1/maguopugd9yegq2h8bhy/customers/{CUSTOMER_ID}/cards/{CARD_ID}';
  //STAGE
  //static const String urlActualizaTarjetaTokenizada = 'https://sandbox-api.openpay.mx/v1/ml7ihaxhfomook7tp9ei/customers/{CUSTOMER_ID}/cards/{CARD_ID}';

  //PROD
  static const String urlPuntosTarjetaTokenizada = 'https://api.openpay.mx/v1/maguopugd9yegq2h8bhy/customers/{CUSTOMER_ID}/cards/{CARD_ID}/points';
  //STAGE
  //static const String urlPuntosTarjetaTokenizada = 'https://sandbox-api.openpay.mx/v1/ml7ihaxhfomook7tp9ei/customers/{CUSTOMER_ID}/cards/{CARD_ID}/points';

  static const String getOptionsMonederoRechargeUrl = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/{{ email }}/recharge/options';
  static const String createMonederoRechargeOperationUrl = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/{{ email }}/recharge/create';
  static const String setPaymentMethodRechargeMonederoPayPalUrl = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/current/recharge/{{ code }}/paymentdetails';
  static const String setPaymentMethodRechargeMonederoCardUrl = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/{{ email }}/recharge/{{ code }}/paymentdetails';

  static const String monederoRcsToken = currentEnv == 'PROD' ? 'e2046c13-6ad4-4f5a-b914-f4d92672a74a' : '8b1020d4-53e4-405a-b489-e2abb62fd2dc';

  // Login
  static const String urlLoginHybris = 'https://${currentEnv == 'PROD' ? 'prod' : 'stage'}.chedraui.com.mx/authorizationserver/oauth/token';
  static const String urlLoginFacebook = currentEnv == 'PROD' ? 'https://www.facebook.com/v4.0/dialog/oauth?client_id=1202201879981370&redirect_uri=https://chedraui.com.mx&request_type=code&scope=email' : 'https://www.facebook.com/v4.0/dialog/oauth?client_id=2342219652710176&redirect_uri=https://stage.chedraui.com.mx&request_type=code&scope=email';
  static const String urlCurrentEnv = currentEnv == 'PROD' ? hybrisProdAlternative : hybrisStage;
  // Seguridad
  static const String gCloudRecoverPassword = seguridadBaseUrl + '/seguridad/recoverPassword';
  static const String urlLogin = //currentEnv == 'PROD' ?
      //'https://us-central1-chedraui-pre.cloudfunctions.net/seguridad/login' :
      seguridadBaseUrl + '/seguridad/login';
  static const String gCloudSignIn = seguridadBaseUrl + '/seguridad/registro';
  static const String gCloudHome = seguridadBaseUrl + '/seguridad/obtenerHome?idUsuario={{idUsuario}}';

  // Push Notifications
  static const String urlNotificacionesRegistro = pushNotificationsBaseUrl + '/dispositivo/registrar';
  static const String urlNotificacionesAsociacion = pushNotificationsBaseUrl + '/dispositivo/asociar';

  // Listas
  static const String urlListasTicket = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/current/ticket/';
  static const String urlListas = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/{{userId}}/shoppinglists';
  static const String urlListasDeleteProduct = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/current/shoppinglists/{{listID}}/entry/';
  static const String urlListasShared = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/current/shoppinglists/{{listID}}/share';
  static const String urlListatoCarrito = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/current/carts/current/shoppinglists/{{listID}}?zipCode=';
  static const String urlListatoCarritoTienda = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/current/carts/current/shoppinglists/{{listID}}?posName=';

  //Comparador
  static const String urlComparador = comparadorBaseUrl + '/comparador/consultaPrecio';

  // CRM
  static const String hybrisGetUserInfo = crmBaseUrl + '/clientescrm/consultaCliente';
  static const String postClientescrmEditUserInfo = crmBaseUrl + '/clientescrm/agregaInfoCliente';
  static const String getClientescrmUserInterest = crmBaseUrl + '/clientescrm/obtenerIntereses';

  // Addresses
  static const String getAdderss = hybrisBaseUrl + "/chedrauicommercewebservices/v2/chedraui/users/{{userId}}/addresses?fields=FULL";
  static const String getAddress = hybrisBaseUrl + "/chedrauicommercewebservices/v2/chedraui/users/{{userId}}/addresses";
  static const String saveAddress = hybrisBaseUrl + "/chedrauicommercewebservices/v2/chedraui/users/current/addresses";
  static const String setAddressToCar = hybrisBaseUrl + "/chedrauicommercewebservices/v2/chedraui/users/current/carts/current/addresses/delivery";
  static const String setAddressToCarAnonymous = hybrisBaseUrl + "/chedrauicommercewebservices/v2/chedraui/users/anonymous/carts/{{cartId}}/addresses/delivery";

  // Pedidos
  static const String urlUserOrders = hybrisBaseUrl + "/chedrauicommercewebservices/v2/chedraui/users/";
  static const String urlLastOrders = hybrisBaseUrl + '/chedrauicommercewebservices/v2/chedraui/users/{{userId}}/mostpurchasedproducts';

  // Facturación
  //static const String urlFacturacion = "https://us-central1-chedraui-pre.cloudfunctions.net/facturacion/emitir";
  static const String urlFacturacion = facturacionBaseUrl + "/facturacion/emitir";
  //static const String urlFacturacionRegistrar = "https://us-central1-chedraui-pre.cloudfunctions.net/facturacion/registraryemitir";
  static const String urlFacturacionRegistrar = facturacionBaseUrl + "/facturacion/registraryemitir";

  // Cupones
  static const String consultarCuponesPorMonedero = promoBaseUrl + '/promo/consultarCuponesPorMonedero';
  static const String consultarCupones = promoBaseUrl + '/promo/consultarCupones';
  static const String asociarCupon = promoBaseUrl + '/promo/asociarCupon';

  // Google Maps
  static const String findNearby = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?';
  static const String findPlaceByTextUrl = 'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?language=es&';
  static const String getPlaceByIdUrl = 'https://maps.googleapis.com/maps/api/place/details/json?language=es&';
  static const String reverseGeocoding = 'https://maps.googleapis.com/maps/api/geocode/json?language=es&';

  // Mercury
  static const String urlChatMercury = urlBaseChatMercury + "/order/";

  // Kentico App
  static const String urlKenticoApp = 'https://deliver.kenticocloud.com/29390711-11c7-0062-a2b1-d875d6bda227/items';

  //Session Status
  static const String urlDeviceID = 'https://us-central1-advncd-manknd-internal.cloudfunctions.net/sessionLog/deviceData';
  static const String urlSessionStatus = 'https://us-central1-advncd-manknd-internal.cloudfunctions.net/sessionLog/statusCheck';

  //Timeouts
  static Duration timeout = new Duration(seconds: 30);
  static Duration extendedTimeout = new Duration(seconds: 120);

  //Paypal
  static const String paypalMode = currentEnv == 'PROD' ? 'live' : 'sandbox';
}
