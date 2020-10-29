import 'dart:io';

import 'package:chd_app_demo/redux/actions/ConnectivityActions.dart';
import 'package:chd_app_demo/redux/actions/SessionActions.dart';
import 'package:chd_app_demo/redux/models/AppState.dart';
import 'package:chd_app_demo/services/AuthServices.dart';
import 'package:chd_app_demo/services/FireBaseServices.dart';
import 'package:chd_app_demo/services/NotificacionesServices.dart';
import 'package:chd_app_demo/utils/Connectivity.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/CategoryPage/CategoryPage.dart';
import 'package:chd_app_demo/views/HomePage/HomePage.dart';
import 'package:chd_app_demo/views/MasterPage/MenuScreen.dart';
import 'package:chd_app_demo/views/MasterPage/ZoomScaffold.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:flutter_redux/flutter_redux.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException, SystemChannels;

import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

const APP_STORE_URL = 'https://apps.apple.com/mx/app/chedraui/id1239945600';
const PLAY_STORE_URL = 'https://play.google.com/store/apps/details?id=com.planetmedia.paymentsloyalty.chedraui&hl=es';

// Home Screen Master Page with dynamic 'body' property
class MasterPage extends StatefulWidget {
  final MenuItem initialWidget;

  const MasterPage({
    Key key,
    this.initialWidget,
  }) : super(key: key);

  @override
  _MasterPageState createState() => new _MasterPageState();
}

class _MasterPageState extends State<MasterPage> with TickerProviderStateMixin {
  String email;

  String token;
  String nombreCompleto;

  Map _source = {ConnectivityResult.wifi: false};
  MyConnectivity _connectivity = MyConnectivity.instance;

  _MasterPageState();
  // final databaseReference = FirebaseDatabase.instance.reference();
  GlobalKey<ZoomScaffoldState> zoomScaffoldKey;
  SharedPreferences prefs;
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  bool _isLoggedIn = false;
  MenuItem selectedMenuItemId = MenuItem(
    id: DataUI.initialRoute,
    title: 'Inicio',
    screen: HomePage(),
    color: DataUI.chedrauiColor2,
    textColor: DataUI.primaryText,
  );
  void fcmSubscribe() {
    _firebaseMessaging.subscribeToTopic('all');
  }
//////////////////////////////////  INIT VARIABLES //////////////////////////////////
  Future<Null> initUniLinks() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      String initialLink = await getInitialLink();
      print('///////////////////////////////////');
      print(initialLink);
      print('///////////////////////////////////');
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      // return?
    }
  }

  @override
  initState() {
    getPreferences().then((x) {
      notificationsPush();
      setState(() {
        // prefs.clear();
        final store = StoreProvider.of<AppState>(context);
        if (_isLoggedIn) {
          store.dispatch(LogIn());
        } else {
          store.dispatch(LogOut());
        }
      });
    });

    zoomScaffoldKey = GlobalKey();
    if (widget.initialWidget != null) {
      selectedMenuItemId = widget.initialWidget;
    }
    super.initState();
    initUniLinks();
    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      setState(() => _source = source);
    });
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('on message $message');
        zoomScaffoldKey.currentState.openEndDrawer();
      },
      onResume: (Map<String, dynamic> message) {
        print('on resume $message');
        zoomScaffoldKey.currentState.openEndDrawer();
      },
      onLaunch: (Map<String, dynamic> message) {
        print('on launch $message');
        zoomScaffoldKey.currentState.openEndDrawer();
      },
    );
  }

//////////////////////////////////  WIDGET BUILD //////////////////////////////////

  @override
  Widget build(BuildContext context) {
    String string;
    switch (_source.keys.toList()[0]) {
      case ConnectivityResult.none:
        string = "Sin conexión";
        break;
      case ConnectivityResult.mobile:
        string = 'Conectado';
        break;
      case ConnectivityResult.wifi:
        string = 'Conectado';
        break;
    }
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(ConnectivityActions(string));
    return ZoomScaffold(
      key: zoomScaffoldKey,
      initialWidget: selectedMenuItemId,
      menuScreen: new MenuScreen(
        selectedItemId: selectedMenuItemId,
        onMenuItemSelected: (MenuItem item) {
          refrehScaffoldBody(item);
        },
      ),
    );
  }

  @override
  void dispose() {
    //_connectivity.disposeStream();
    super.dispose();
  }
//////////////////////////////////////////////////////////////////////////////////

  notificationsPush() {
    _firebaseMessaging.requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.getToken().then((tokenID) async {
      await _firebaseMessaging.subscribeToTopic('all').then((onValue) {
        print('onValue');
        print('onValue');
      }).catchError((onError) {
        print(onError);
      });
    });
  }

  Future getPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  refrehScaffoldBody(MenuItem item) {
    zoomScaffoldKey.currentState.updateBody(item);
  }

  ////////////////////////////////    FIREBASE ANALITYCS       //////////////////////////

}

//  @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('data'),
//       ),
//       body: Column(
//         children: <Widget>[
//           MaterialButton(
//             child: const Text('Test logEvent'),
//             onPressed: _sendAnalyticsEvent,
//           ),
//           MaterialButton(
//             child: const Text('Test standard event types'),
//             onPressed: _testAllEventTypes,
//           ),
//           MaterialButton(
//             child: const Text('Test setUserId'),
//             onPressed: _testSetUserId,
//           ),
//           MaterialButton(
//             child: const Text('Test setCurrentScreen'),
//             onPressed: _testSetCurrentScreen,
//           ),
//           MaterialButton(
//             child: const Text('Test setAnalyticsCollectionEnabled'),
//             onPressed: _testSetAnalyticsCollectionEnabled,
//           ),
//           MaterialButton(
//             child: const Text('Test setSessionTimeoutDuration'),
//             onPressed: _testSetSessionTimeoutDuration,
//           ),
//           MaterialButton(
//             child: const Text('Test setUserProperty'),
//             onPressed: _testSetUserProperty,
//           ),
//            MaterialButton(
//             child: const Text('navigtion'),
//            onPressed: () {
//               Navigator.of(context).push(MaterialPageRoute<CategoryPage>(
//                   settings: const RouteSettings(name: CategoryPage.routeName),
//                   builder: (BuildContext context) {
//                     return TabsPage(observer);
//                   }));
//             }),
//           Text(
//             _message,
//             style: const TextStyle(color: Color.fromARGB(255, 0, 155, 0)),
//           ),
//         ],
//       ),
//     );
//   }
