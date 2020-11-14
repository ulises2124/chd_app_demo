import 'package:chd_app_demo/main.dart';
import 'package:chd_app_demo/redux/actions/ShoppingCartsActions.dart';
import 'package:chd_app_demo/services/FireBaseServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/views/CarritoPage/CarritoPage.dart';
import 'package:chd_app_demo/views/HomePage/HomePage.dart';
import 'package:chd_app_demo/views/ListasPage/ListasPage.dart';
import 'package:chd_app_demo/views/MasterPage/MasterPage.dart';
import 'package:chd_app_demo/views/MasterPage/MenuScreen.dart';
import 'package:chd_app_demo/views/SearchPage/SearchPage.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:chd_app_demo/widgets/notSignedIn.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:chd_app_demo/redux/models/AppState.dart';

class _ViewModel {
  final int shoppingCartQuantity;
  final bool isSessionActive;
  SharedPreferences prefs;

  _ViewModel({
    @required this.shoppingCartQuantity,
    @required this.isSessionActive,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return new _ViewModel(
      shoppingCartQuantity: store.state.shoppingCartQuantity,
      isSessionActive: store.state.isSessionActive,
    );
  }
}

class FooterNavigation extends StatefulWidget {
  final bool mainNavigation;
  final MenuItem contentScreen;
  Function(MenuItem) bottomNavigationController;

  FooterNavigation(
    this.bottomNavigationController, {
    @required this.mainNavigation,
    this.contentScreen,
  });



  @override
  _FooterNavigationState createState() => _FooterNavigationState();
}

class _FooterNavigationState extends State<FooterNavigation> {
  int count = 0;
  int selectedIndex = 0;
  MenuItem contentScreen;
  SharedPreferences prefs;
  bool  _isLoggedIn = false;

  Future getPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      print(_isLoggedIn);
    });
  }


  @override
  void initState() {

    getPreferences();
    if (widget.mainNavigation) {
      switch (widget.contentScreen.id) {
        case 'listas':
          selectedIndex = 1;
          break;
        case 'loginRequired':
          selectedIndex = 1;
          break;
        case 'buscar':
          selectedIndex = 2;
          break;
        case '/Carrito':
          selectedIndex = 3;
          break;
        case '/Tienda':
          selectedIndex = 0;
          break;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      onInit: (store) {},
      onWillChange: (_viewModel) {},
      converter: _ViewModel.fromStore,
      builder: (BuildContext context, _ViewModel vm) {
        return Material(
          child: BottomNavigationBar(
            elevation: 1,
            currentIndex: selectedIndex,
            iconSize: 26,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                title: Text('Tienda', style: DataUI.footerMenuStyle),
                icon: Stack(children: <Widget>[TiendaIconSVG(false)]),
                activeIcon: Stack(children: <Widget>[TiendaIconSVG(true)]),
              ),
              BottomNavigationBarItem(
                title: Text('Listas', style: DataUI.footerMenuStyle),
                icon: Stack(children: <Widget>[ListasIconSVG(false)]),
                activeIcon: Stack(children: <Widget>[ListasIconSVG(true)]),
              ),
              BottomNavigationBarItem(
                title: Text('Buscar', style: DataUI.footerMenuStyle),
                icon: Stack(children: <Widget>[BuscarIconSVG(false)]),
                activeIcon: Stack(children: <Widget>[BuscarIconSVG(true)]),
              ),
              BottomNavigationBarItem(
                title: Text('Carrito', style: DataUI.footerMenuStyle),
                icon: Stack(
                  children: <Widget>[
                    CarritoIconSVG(false),
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                        constraints: BoxConstraints(minWidth: 12, minHeight: 12),
                        child: Text(
                          vm.shoppingCartQuantity.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                activeIcon: Stack(
                  children: <Widget>[
                    CarritoIconSVG(true),
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: BoxConstraints(minWidth: 12, minHeight: 12),
                        child: Text(
                          vm.shoppingCartQuantity.toString(),
                          style: TextStyle(color: Colors.white, fontSize: 8),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            onTap: (screen) {
              if (widget.mainNavigation) {
                setState(() {
                  selectedIndex = screen;
                });
                switch (screen) {
                  case 0:
                    contentScreen = MenuItem(
                      id: DataUI.tiendaRoute,
                      title: 'Inicio',
                      screen: HomePage(),
                      color: DataUI.chedrauiColor2,
                      textColor: DataUI.primaryText,
                    );
                    break;
                  case 1:
                    if (_isLoggedIn) {
                      contentScreen = MenuItem(
                        id: DataUI.listasRoute,
                        title: 'Mis Listas',
                        screen: ListasPage(),
                        color: DataUI.chedrauiColor2,
                        textColor: DataUI.primaryText,
                      );
                    } else {
                      contentScreen = MenuItem(
                        id: DataUI.listasRoute,
                        title: 'Mis Listas',
                        screen: NotSignedInWidget(
                          message: 'Para poder vizualizar o crear tus listas de compras, por favor inicia sesión y disfruta de todos los beneficios de la nueva tienda Chedraui',
                        ),
                        color: DataUI.chedrauiColor2,
                        textColor: DataUI.primaryText,
                      );
                    }
                    break;
                  case 2:
                    contentScreen = MenuItem(
                      id: DataUI.buscarRoute,
                      title: 'Buscar',
                      screen: SearchPage(),
                      color: DataUI.chedrauiColor2,
                      textColor: DataUI.primaryText,
                    );
                    break;
                  case 3:
                    contentScreen = MenuItem(
                      id: DataUI.carritoRoute,
                      //title: 'Mi Carrito' + '(' + vm.shoppingCartQuantity.toString() + ')',
                      title: 'Mi Carrito',
                      screen: CarritoPage(),
                      color: DataUI.chedrauiColor2,
                      textColor: DataUI.primaryText,
                    );
                    break;
                }
                FireBaseEventController.setCurrentScreen(contentScreen.id).then((ok) {});
                widget.bottomNavigationController(contentScreen);
              } else {
                switch (screen) {
                  case 0:
                    Navigator.of(context).pushNamedAndRemoveUntil(DataUI.tiendaRoute, (Route<dynamic> route) => false);
                    break;
                  case 1:
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        settings: RouteSettings(name: DataUI.listasRoute),
                        builder: (BuildContext context) => MasterPage(
                          initialWidget: _isLoggedIn
                              ? MenuItem(
                                  id: DataUI.listasRoute,
                                  title: 'Mis Listas',
                                  screen: ListasPage(),
                                  color: DataUI.chedrauiColor2,
                                  textColor: DataUI.primaryText,
                                )
                              : MenuItem(
                                  id: DataUI.listasRoute,
                                  title: 'Mis Listas',
                                  screen: NotSignedInWidget(
                                    message: 'Para poder vizualizar o crear tus listas de compras, por favor inicia sesi��n y disfruta de todos los beneficios de la nueva tienda Chedraui22',
                                  ),
                                  color: DataUI.chedrauiColor2,
                                  textColor: DataUI.primaryText,
                                ),
                        ),
                      ),
                      (Route<dynamic> route) => false,
                    );
                    break;
                  case 2:
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        settings: RouteSettings(name: DataUI.buscarRoute),
                        builder: (BuildContext context) => MasterPage(
                          initialWidget: MenuItem(
                            id: DataUI.buscarRoute,
                            title: 'Buscar',
                            screen: SearchPage(),
                            color: DataUI.chedrauiColor2,
                            textColor: DataUI.primaryText,
                          ),
                        ),
                      ),
                      (Route<dynamic> route) => false,
                    );
                    break;
                  case 3:
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        settings: RouteSettings(name: DataUI.carritoRoute),
                        builder: (BuildContext context) => MasterPage(
                          initialWidget: MenuItem(
                            id: DataUI.carritoRoute,
                            //title: 'Mi Carrito' + '(' + vm.shoppingCartQuantity.toString() + ')',
                            title: 'Mi Carrito',
                            screen: CarritoPage(),
                            color: DataUI.chedrauiColor2,
                            textColor: DataUI.primaryText,
                          ),
                        ),
                      ),
                      (Route<dynamic> route) => false,
                    );
                    break;
                  default:
                }
              }
            },
          ),
        );
      },
    );
  }
}
