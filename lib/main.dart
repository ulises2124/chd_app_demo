import 'package:flutter/material.dart';
import 'package:chd_app_demo/services/FireBaseServices.dart';
import 'package:chd_app_demo/utils/NavigationService.dart';
import 'package:chd_app_demo/utils/locator.dart';
import 'package:chd_app_demo/utils/renewTokenIfNeeded.dart';
import 'package:chd_app_demo/views/CategoryPage/CategoryPage.dart';
import 'package:chd_app_demo/views/CategoryPage/SubCategoryPage.dart';
import 'package:chd_app_demo/views/Checkout/CheckoutPage.dart';
import 'package:chd_app_demo/views/Checkout/CheckoutConfirmationPage.dart';
import 'package:chd_app_demo/views/Checkout/NewCreditCard.dart';
import 'package:chd_app_demo/views/Checkout/PaypalPage.dart';
import 'package:chd_app_demo/views/ComparadorPrecios/ComparadorPrecios.dart';
import 'package:chd_app_demo/views/ContactanosPage/ContactanosPage.dart';
import 'package:chd_app_demo/views/ContactanosPage/ContactanosWeb.dart';
import 'package:chd_app_demo/views/ContactanosPage/ContactanosWebAndroid.dart';
import 'package:chd_app_demo/views/CuentaPage/EditAddressPage.dart';
import 'package:chd_app_demo/views/CuponesPage/AddCouponPage.dart';
import 'package:chd_app_demo/views/CuponesPage/CuponesPage.dart';
import 'package:chd_app_demo/views/DeliveryMethod/ConfirmAddressPage.dart';
import 'package:chd_app_demo/views/Facturacion/FacturacionPage.dart';
import 'package:chd_app_demo/views/ListasPage/ListaEdit.dart';
import 'package:chd_app_demo/views/ListasPage/ListaProductDetails.dart';
import 'package:chd_app_demo/views/ListasPage/ListaProducts.dart';
//import 'package:chedraui_flutter/views/DeliveryMethod/ConfirmAddressPage.dart';
import 'package:chd_app_demo/views/LoginPage/RecoveryPasswordPage.dart';
import 'package:chd_app_demo/views/Monedero/EditCard.dart';
import 'package:chd_app_demo/views/Monedero/MonederoDetails.dart';
import 'package:chd_app_demo/views/Pedidos/ChatPedido.dart';
import 'package:chd_app_demo/views/Pedidos/PedidoDetailsEnvio.dart';
import 'package:chd_app_demo/views/Pedidos/PedidosPage.dart';
import 'package:chd_app_demo/views/ProductPage/ProductPage.dart';
import 'package:chd_app_demo/views/ProductsPage/ProductsPage.dart';
import 'package:chd_app_demo/views/Servicios/MyServices.dart';
import 'package:chd_app_demo/views/Servicios/PaymentHistory.dart';
import 'package:chd_app_demo/views/Servicios/PaymentReceipt.dart';
import 'package:chd_app_demo/views/Servicios/SelectedService.dart';
import 'package:chd_app_demo/views/Servicios/ServiciosAvailable.dart';
import 'package:chd_app_demo/views/Servicios/ServiciosPage.dart';
import 'package:chd_app_demo/widgets/notSignedIn.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/DataUI.dart';

//Routes
import 'package:chd_app_demo/views/SplashScreenPage/SplashScreenPage.dart';
import 'package:chd_app_demo/views/MasterPage/MasterPage.dart';
// import 'package:chedraui_flutter/views/HomePage/HomePage.dart';
import 'package:chd_app_demo/views/DeliveryMethod/DeliveryMethodPage.dart';
// import 'package:chedraui_flutter/views/DeliveryMethod/GoogleMap.dart';

import 'package:chd_app_demo/views/LoginPage/LoginPage.dart';
// import 'package:chedraui_flutter/views/TiendaPage/TiendaPage.dart';
import 'package:chd_app_demo/views/ListasPage/ListasPage.dart';
import 'package:chd_app_demo/views/CarritoPage/CarritoPage.dart';
import 'package:chd_app_demo/views/Monedero/MonederoPage.dart';
import 'package:chd_app_demo/views/CuentaPage/CuentaPage.dart';
import 'package:chd_app_demo/views/Errors/NetworkErrorPage/NetworkErrorPage.dart';
import 'package:chd_app_demo/views/Errors/UpdateAppPage/UpdateAppPage.dart';
// Redux Implementation
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux_logging/redux_logging.dart';
import 'package:chd_app_demo/redux/models/AppState.dart';
import 'package:chd_app_demo/redux/reducers/AppReducer.dart';
// import 'package:chedraui_flutter/redux/middleware/SessionMiddleware.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAnalytics analytics = FireBaseEventController.analytics;
  final FirebaseAnalyticsObserver observer = FireBaseEventController.observer;
  final store = new Store<AppState>(
    appReducer,
    initialState: new AppState(),
    middleware: []
      // ..addAll(createAuthMiddleware())
      ..add(new LoggingMiddleware.printer()),
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: store,
      child: MaterialApp(
        navigatorKey: locator<NavigationService>().navigatorKey,
        onGenerateRoute: (routeSettings) {
          switch (routeSettings.name) {
            case 'login':
              return MaterialPageRoute(builder: (context) => LoginPage(logout: true));
          }
        },
        title: DataUI.appName,
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: DataUI.chedrauiColor,
          accentColor: DataUI.chedrauiColor,
          hintColor: DataUI.chedrauiColor,
          fontFamily: 'Rubik',
          textTheme: TextTheme(
            headline: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
            title: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
            body1: TextStyle(fontSize: 10.0, fontWeight: FontWeight.normal),
          ),
        ),
        navigatorObservers: <NavigatorObserver>[observer],
        initialRoute: DataUI.initialRoute,
        routes: <String, WidgetBuilder>{
          // DataUI.homeRoute: (BuildContext context) => HomePage(),
          DataUI.initialRoute: (BuildContext context) => MasterPage(),
          DataUI.tiendaRoute: (BuildContext context) => MasterPage(),
          DataUI.splahsScreenRoute: (BuildContext context) => SplashScreenPage(),
          DataUI.categoryRoute: (BuildContext context) => CategoryPage(),
          DataUI.subCategoryRoute: (BuildContext context) => SubCategoryPage(title: ''),
          DataUI.productRoute: (BuildContext context) => ProductPage(),
          DataUI.productsRoute: (BuildContext context) => ProductsPage(),
          DataUI.deliveryMethodRoute: (BuildContext context) => DeliveryMethodPage(showStores: true, showConfirmationForm: false),
          DataUI.editAddressRoute: (BuildContext context) => EditAddressPage(),
          DataUI.confirmAddressRoute: (BuildContext context) => ConfirmAddressPage(),
          DataUI.loginRoute: (BuildContext context) => LoginPage(),
          DataUI.recoveryPasswordRoute: (BuildContext context) => RecoveryPasswordPage(),
          DataUI.cuponesRoute: (BuildContext context) => CuponesPage(),
          DataUI.loginRequiredRoute: (BuildContext context) => NotSignedInWidget(),
          DataUI.addCouponsRoute: (BuildContext context) => AddCouponPage(),
          DataUI.pagoServiciosRoute: (BuildContext context) => PagoServicios(),
          DataUI.selectedPagoServiciosRoute: (BuildContext context) => SelectedService(),
          DataUI.misServiciosRoute: (BuildContext context) => MyServices(),
          DataUI.historialPagosServiciosRoute: (BuildContext context) => PaymentHistory(),
          DataUI.reciboPagoServiciosRoute: (BuildContext context) => PaymentReceipt(),
          DataUI.listasRoute: (BuildContext context) => ListasPage(),
          DataUI.listasSearchRoute: (BuildContext context) => ListaProducts(),
          DataUI.listasProductDetails: (BuildContext context) => ListaProductDetails(),
          DataUI.listasEdit: (BuildContext context) => ListaEdit(),
          DataUI.listaDetails: (BuildContext context) => ListaEdit(),
          DataUI.listaNew: (BuildContext context) => ListaEdit(),
          DataUI.contactanosRoute: (BuildContext context) => Contactanos(),
          DataUI.contactanosWebRoute: (BuildContext context) => ContactanosWeb(),
          DataUI.contactanosWebAndroidRoute: (BuildContext context) => ContactanosWebAndroid(),
          DataUI.facturacionRoute: (BuildContext context) => FacturacionPage(),
          DataUI.pedidosRoute: (BuildContext context) => PedidosPage(),
          DataUI.pedidoDetailsRoute: (BuildContext context) => DeliveryOrderDetails(),
          DataUI.chatPedidosRoute: (BuildContext context) => ChatPedido(),
          DataUI.monederoRoute: (BuildContext context) => MonederoPage(),
          DataUI.monederoDetailsRoute: (BuildContext context) => MonederoDetails(),
          DataUI.addCardRoute: (BuildContext context) => NewCreditCard(),
          DataUI.editCardRoute: (BuildContext context) => EditCard(),
          DataUI.carritoRoute: (BuildContext context) => CarritoPage(),
          DataUI.checkoutRoute: (BuildContext context) => CheckoutPage(),
          DataUI.checkoutConfirmationRoute: (BuildContext context) => CheckoutConfirmationPage(),
          DataUI.cuentaRoute: (BuildContext context) => CuentaPage(),
          DataUI.comparadorPreciosRoute: (BuildContext context) => ComparadorPrecios(),
          DataUI.paypalRoute: (BuildContext context) => PaypalPage(),
          DataUI.serviciosDisponibles: (BuildContext context) => ServiciosAvailable(),
          // Errors & Warnings
          DataUI.networkErrorRoute: (BuildContext context) => NetworkErrorPage(showGoHomeButton: true),
          DataUI.updateAppWarningRoute: (BuildContext context) => UpdateAppPage(),
        },
      ),
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
