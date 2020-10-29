// import 'package:chedraui_flutter/services/NotificacionesServices.dart';
// import 'package:chedraui_flutter/utils/HexValueConverter.dart';
// import 'package:chedraui_flutter/views/CarritoPage/CarritoPage.dart';
// import 'package:chedraui_flutter/views/CuentaPage/CuentaPage.dart';
// import 'package:chedraui_flutter/views/HomePage/HomePage.dart';
// import 'package:chedraui_flutter/views/ListasPage/ListasPage.dart';
// import 'package:chedraui_flutter/views/LoginPage/LoginPage.dart';
// import 'package:chedraui_flutter/views/Monedero/MonederoPage.dart';
// import 'package:chedraui_flutter/views/TiendaPage/TiendaPage.dart';
// import 'package:chedraui_flutter/views/Buzon/BuzonPage.dart';
// import 'package:chedraui_flutter/widgets/notSignedIn.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:chedraui_flutter/utils/DataUI.dart';
// import 'package:chedraui_flutter/services/CarritoServices.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:device_info/device_info.dart';
// import 'package:flutter_sidekick/flutter_sidekick.dart';

// // Home Screen Master Page with dynamic 'body' property
// class MasterPage extends StatefulWidget {
//   final Widget initialWidget;
//   const MasterPage({Key key, this.initialWidget}) : super(key: key);
//   // final FirebaseUser fbUser;

//   @override
//   _MasterPageState createState() => new _MasterPageState();
// }

// class _MasterPageState extends State<MasterPage> with TickerProviderStateMixin {
//   SidekickController controller;

//   FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
//   final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//   final _scaffoldKey = GlobalKey<ScaffoldState>();
//   SharedPreferences prefs;
//   bool _isLoggedIn = false;
//   bool _hideAppbar = false;
//   double _padding = 0;
//   Widget _bodyPage = HomePage();
//   int numberProducts = 0;
//   String _idWallet;

//   bool _deviceRegistration;///////////////////////////////////////////////////
//   // int i = 0;
//   // var pages = [
//   //   HomePage(),
//   //   ListasPage(),
//   //   MonederoPage(),
//   //   CarritoPage(),
//   //   CuentaPage(),
//   // ];

//   Future<String> _getId() async {///////////////////////////////////////////////////
//     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//     if (Theme.of(context).platform == TargetPlatform.iOS) {
//       IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
//       return iosDeviceInfo.identifierForVendor; // unique ID on iOS
//     } else {
//       AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
//       return androidDeviceInfo.androidId; // unique ID on Android
//     }
//   }

//   notificationsPush() {///////////////////////////////////////////////////
//     _firebaseMessaging.requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true));
//     _firebaseMessaging.getToken().then((token) async {
//       String udid;
//       String deviceName;
//       String build;
//       if (Theme.of(context).platform == TargetPlatform.iOS) {
//         IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
//         udid = iosDeviceInfo.identifierForVendor; // unique ID on iOS
//         deviceName = iosDeviceInfo.name;
//         build = 'IOS';
//       } else {
//         AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
//         udid = androidDeviceInfo.androidId; // unique ID on Android
//         deviceName = androidDeviceInfo.model;
//         build = 'ANDROID';
//       }
//       print('--------------------');
//       print(udid);
//       print(deviceName);
//       print(token);
//       print('--------------------');

//       var body1 = {"aplicacionId": udid, "dispositivoToken": token, "tipo_dispositivo": deviceName, "sistema_operativo": build, "usuario": _idWallet};
//       var body2 = {"aplicacionId": udid, "dispositivoId": token, "usuario": _idWallet};
//       NotificacionesServices.registroDispositivo(body1).then((res) {
//         print(res['statusOperation']['description']);
//         if (res['statusOperation']['description'] == "Procesado correctamente") {
//           NotificacionesServices.asociacionDispositivo(body2).then((response) {
//             print(response['statusOperation']['description']);
//             prefs.setBool('deviceRegistration', true);
//           });
//         }
//       });
//     });
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }

//   initState() {///////////////////////////////////////////////////
//     if (widget.initialWidget != null) {
//       _bodyPage = widget.initialWidget;
//     }
//     super.initState();
  
//     getPreferences().then((x) {
//       setState(() {
//         // prefs.clear();
//         _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//         _idWallet = prefs.getString('idWallet');
//         _deviceRegistration = prefs.getBool('deviceRegistration') ?? false;
//       });
//       if (_isLoggedIn) {
//         _firebaseMessaging.configure(
//           onMessage: (Map<String, dynamic> message) {
//             print('on message $message');
//           },
//           onResume: (Map<String, dynamic> message) {
//             print('on resume $message');
//             _scaffoldKey.currentState.openEndDrawer();
//           },
//           onLaunch: (Map<String, dynamic> message) {
//             print('on launch $message');
//           },
//         );
//       }
//       if (prefs.getBool('deviceRegistration') == null) {
//         if (_isLoggedIn) {
//           notificationsPush();
//         }
//       } else {
//         if (!_deviceRegistration) {
//           notificationsPush();
//         }
//       }
//     });
//     this.getAnonymousCart();
//   }

//   Future getPreferences() async {
//     prefs = await SharedPreferences.getInstance();
//   }

//   refreshBody(bodyPage, [hideAppbar]) {
//     setState(
//       () {
//         _hideAppbar = hideAppbar ?? false;
//         switch (bodyPage) {
//           case 'Tienda':
//             _bodyPage = HomePage();
//             break;
//           case 'Listas':
//             if (_isLoggedIn) {
//               _bodyPage = ListasPage();
//             } else {
//               _bodyPage = NotSignedInWidget(
//                 message: 'Para poder vizualizar o crear tus listas de compras, por favor inicia sesión y disfruta de todos los beneficios de la nueva tienda Chedraui',
//               );
//             }
//             break;
//           case 'Monedero':
//             if (_isLoggedIn) {
//               _bodyPage = MonederoPage();
//             } else {
//               _bodyPage = NotSignedInWidget(
//                 message: 'Para poder agregar o administrar tus métodos de pago, por favor inicia sesión y disfruta de todos los beneficios de la nueva tienda Chedraui',
//               );
//             }
//             break;
//           case 'Carrito':
//             goCarrito();
//             // _bodyPage = CarritoPage();
//             break;
//           case 'Cuenta':
//             if (_isLoggedIn) {
//               _bodyPage = CuentaPage();
//             } else {
//               _bodyPage = NotSignedInWidget(
//                 message: 'Para poder configurar tu perfil, preferencias, cupones y direcciones de envío, por favor inicia sesión y disfruta de todos los beneficios de la nueva tienda Chedraui',
//               );
//             }
//             break;
//         }
//       },
//     );
//   }

//   goCarrito() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => CarritoPage(),
//       ),
//     );
//     getAnonymousCart();
//   }

//   Future<void> getAnonymousCart() async {
//     try {
//       SharedPreferences prefsCart = await SharedPreferences.getInstance();
//       final needsUpateLocation = prefsCart.getBool("cart-address-update") ?? false;
//       if (needsUpateLocation) {
//         await CarritoServices.setDeliveryModeCart();
//         prefsCart.setBool("cart-address-update", false);
//       }
//       final carrito = await CarritoServices.getCart();
//       setState(() {
//         numberProducts = carrito['totalItems'];
//       });
//     } catch (e) {
//       print(e.toString());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: DataUI.backgroundColor,
//       appBar: _hideAppbar
//           ? null
//           : PreferredSize(
//               preferredSize: Size.fromHeight(0.0),
//               child: TopMainAppBarContainer(),
//             ),
//       // body: pages[i],
//       body: Stack(
//         children: <Widget>[
//           Positioned(
//             // top: 20.0,
//             // left: 20.0,
//             child: GestureDetector(
//               onTap: () => controller..moveToTarget(context),
//               child: Sidekick(
//                 tag: 'source',
//                 targetTag: 'target',
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   mainAxisSize: MainAxisSize.max,
//                   children: <Widget>[
//                     Expanded(
//                       flex: 1,
//                       child: Container(
//                         color: Colors.blue,
//                         child: Text(
//                           'asdasdsadadsa',
//                           style: TextStyle(fontSize: 20),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             // bottom: 20.0,
//             // right: 20.0,
//             child: GestureDetector(
//               onTap: () => controller.moveToSource(context),
//               child: Sidekick(
//                 tag: 'target',
//                 child:  Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   mainAxisSize: MainAxisSize.max,
//                   children: <Widget>[
//                     Expanded(
//                       flex: 1,
//                       child: Container(
//                         color: Colors.amber,
//                         child: Text(
//                           'asdasdsadadsa',
//                           style: TextStyle(fontSize: 20),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // Container(color: Colors.amber, child: Text('asdasdsadadsa', style: TextStyle(fontSize: 100)),),
//           // Expanded(child: _bodyPage),
//         ],
//       ),
//       // drawer: Drawer(
//       //   child: ListView(
//       //     children: <Widget>[
//       //       Text('asd'),
//       //       Text('asd'),
//       //       Text('asd'),
//       //       Text('asd'),
//       //       Text('asd'),
//       //     ],
//       //   ),
//       // ),
//       endDrawer: _isLoggedIn
//           ? BuzonPage()
//           : Drawer(
//               child: ListView(
//                 children: <Widget>[
//                   Card(
//                     margin: EdgeInsets.only(top: 20, left: 8, right: 8),
//                     child: ListTile(
//                       title: Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: Text(
//                           'Bienvenido',
//                           style: TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.w500,
//                             color: DataUI.textOpaqueStrong,
//                           ),
//                         ),
//                       ),
//                       subtitle: Padding(
//                         padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
//                         child: Text(
//                           'Aquí recibirás notificaciones y ofertas exclusivas al ingresar a tu cuenta Chedraui',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w400,
//                             color: DataUI.textOpaqueMedium,
//                           ),
//                         ),
//                       ),
//                       onTap: () {},
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//       // bottomNavigationBar: BottomNavigationBar(
//       //   items: [
//       //     new BottomNavigationBarItem(
//       //       icon: new Icon(Icons.store_mall_directory),
//       //       title: new Text('Tienda'),
//       //     ),
//       //     new BottomNavigationBarItem(
//       //       icon: new Icon(Icons.list),
//       //       title: new Text('Listas'),
//       //     ),
//       //     new BottomNavigationBarItem(
//       //       icon: new Icon(Icons.account_balance_wallet),
//       //       title: new Text('Monedero'),
//       //     ),
//       //     new BottomNavigationBarItem(
//       //       icon: Stack(children: <Widget>[
//       //         Icon(Icons.shopping_cart),
//       //         Positioned(
//       //           top: .0,
//       //           right: 1.0,
//       //           child: Container(
//       //             width: 23,
//       //             height: 23,
//       //             child: Center(
//       //               child: Text(
//       //                 '100',
//       //                 textAlign: TextAlign.center,
//       //                 style: TextStyle(
//       //                   fontSize: 12,
//       //                   color: Colors.white,
//       //                   fontWeight: FontWeight.w300,
//       //                 ),
//       //               ),
//       //             ),
//       //             decoration: BoxDecoration(
//       //               shape: BoxShape.circle,
//       //               color: HexColor('#F57C00'),
//       //             ),
//       //           ),
//       //         ),
//       //       ]),
//       //       title: new Text('Library'),
//       //     ),
//       //     new BottomNavigationBarItem(
//       //       icon: new Icon(Icons.face),
//       //       title: new Text('Cuenta'),
//       //     ),
//       //   ],
//       //   currentIndex: i,
//       //   type: BottomNavigationBarType.fixed,
//       //   onTap: (index) {
//       //     setState(() {
//       //       i = index;
//       //     });
//       //   },
//       // ),
//       bottomNavigationBar: BottomAppBar(
        
//         child: Padding(
//           padding: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: <Widget>[
//               MainBottomNavigationItem(
//                 refreshBody,
//                 displayText: 'Tienda',
//                 displayIcon: Icon(Icons.store_mall_directory),
//               ),
//               MainBottomNavigationItem(
//                 refreshBody,
//                 displayText: 'Listas',
//                 displayIcon: Icon(Icons.list),
//               ),
//               MainBottomNavigationItem(
//                 refreshBody,
//                 displayText: 'Monedero',
//                 displayIcon: Icon(Icons.account_balance_wallet),
//               ),
//               Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
//                 Stack(children: <Widget>[
//                   IconButton(
//                     icon: Icon(Icons.shopping_cart),
//                     onPressed: () {
//                       refreshBody('Carrito', true);
//                     },
//                     color: HexColor('#212B36'),
//                   ),
//                   Positioned(
//                     top: 0.0,
//                     right: 0.0,
//                     child: Container(
//                         width: 23,
//                         height: 23,
//                         child: Center(
//                           child: Text(
//                             numberProducts.toString(),
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.white,
//                               fontWeight: FontWeight.w300,
//                             ),
//                           ),
//                         ),
//                         decoration: numberProducts > 0
//                             ? BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: HexColor('#F57C00'),
//                               )
//                             : null),
//                   ),
//                 ]),
//                 Text(
//                   'Carrito',
//                   style: TextStyle(
//                     fontSize: 10.0,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ]),
//               MainBottomNavigationItem(
//                 refreshBody,
//                 displayText: 'Cuenta',
//                 displayIcon: Icon(Icons.face),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//     // controller: controller;
//   }
// }

// class MainBottomNavigationItem extends StatefulWidget {
//   // final String routePath;
//   final String displayText;
//   final Icon displayIcon;
//   Function(String, [bool]) refreshBody;
//   // Function(Widget, [bool]) refreshBody;

//   MainBottomNavigationItem(
//     this.refreshBody, {
//     Key key,
//     // @required this.routePath,
//     @required this.displayText,
//     @required this.displayIcon,
//   }) : super(key: key);

//   @override
//   _MainBottomNavigationItemState createState() => _MainBottomNavigationItemState();
// }

// class _MainBottomNavigationItemState extends State<MainBottomNavigationItem> {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: <Widget>[
//         IconButton(
//           icon: widget.displayIcon,
//           color: HexColor('#212B36'),
//           onPressed: () {
//             widget.refreshBody(widget.displayText, false);
//           },
//         ),
//         Text(
//           widget.displayText,
//           style: TextStyle(
//             fontSize: 10.0,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
// }

// // Defines the AppBar wWidget
// class TopMainAppBarContainer extends StatelessWidget {
//   final Widget child;
//   TopMainAppBarContainer({Key key, this.child}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: DataUI.backgroundColor,
//       centerTitle: true,
//       // titleSpacing: 0.0,
//       title: Column(
//         children: <Widget>[
//           // Text(
//           //   'Recoger en:',
//           //   style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.w700),
//           // ),
//         ],
//       ),
//     );
//   }
// }
