import 'package:chd_app_demo/redux/actions/SessionActions.dart';
import 'package:chd_app_demo/redux/models/AppState.dart';
import 'package:chd_app_demo/services/FireBaseServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/DeliveryMethod/DeliveryMethodPage.dart';
import 'package:chd_app_demo/views/HomePage/HomePage.dart';
import 'package:chd_app_demo/views/MasterPage/MasterPage.dart';
import 'package:chd_app_demo/views/MasterPage/ZoomScaffold.dart';
//import 'package:chd_app_demo/views/Servicios/ServiciosPage.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

// final menuScreenKey = new GlobalKey(debugLabel: 'MenuScreen');

class MenuScreen extends StatefulWidget {
  final MenuItem selectedItemId;
  final Function onMenuItemSelected;


  MenuScreen({
    Key key,
    this.selectedItemId,
    this.onMenuItemSelected,
  }) : super(key: key);

  @override
  _MenuScreenState createState() => new _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  bool _isLoggedIn = false;
  AnimationController titleAnimationController;
  double selectorYTop;
  double selectorYBottom;
  String userName = '';
  SharedPreferences prefs;
//////////////////////////////////  INIT VARIABLES //////////////////////////////////

  @override
  void initState() {
    getPreferences();
    super.initState();
    titleAnimationController = new AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void dispose() {
    titleAnimationController.dispose();
    super.dispose();
  }

  Future getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('account-userName') ?? '';
       if (prefs.getBool('isLoggedIn') == null) {
         _isLoggedIn = false;
       } else {
         _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
       }

    });
  }


//////////////////////////////////  WIDGET BUILD //////////////////////////////////

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);

    return new ZoomScaffoldMenuController(
      builder: (BuildContext context, MenuController menuController) {
        var shouldRenderSelector = true;
        var actualSelectorYTop = selectorYTop;
        var actualSelectorYBottom = selectorYBottom;
        var selectorOpacity = 1.0;

        if (menuController.state == MenuState.closed || menuController.state == MenuState.closing || selectorYTop == null) {
          final RenderBox menuScreenRenderBox = context.findRenderObject() as RenderBox;

          if (menuScreenRenderBox != null) {
            final menuScreenHeight = menuScreenRenderBox.size.height;

            actualSelectorYTop = menuScreenHeight - 50.0;
            actualSelectorYBottom = menuScreenHeight;
            selectorOpacity = 0.0;
          } else {
            shouldRenderSelector = false;
          }
        }

        return Container(
          // height: MediaQuery.of(context).size.height * 0.66,
          padding: EdgeInsets.only(top: 20, right: MediaQuery.of(context).size.width / 2.9, bottom: 0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                HexColor('#ef7128'),
                HexColor('#f5a440'),
              ],
            ),
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                child: Align(
                  alignment: Alignment(-1, 1.0),
                  child: MenuBG(),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.67,
                // padding: EdgeInsets.only(bottom: 120),
                child: Scrollbar(
                  child: CustomScrollView(
                    shrinkWrap: true,
                    slivers: <Widget>[
                      // SliverAppBar(
                      //   pinned: true,
                      //   elevation: 0,
                      //   backgroundColor: HexColor('#ef7128'),
                      //   leading: IconButton(
                      //     padding: EdgeInsets.only(left: 10, top: 10, bottom: 0),
                      //     iconSize: 32,
                      //     color: Colors.white,
                      //     icon: Icon(Icons.arrow_back),
                      //     onPressed: () {
                      //       menuController.toggle();
                      //     },
                      //   ),
                      // ),
                      SliverList(
                        delegate: SliverChildListDelegate([
                          Container(
                            height: _isLoggedIn ? null : MediaQuery.of(context).size.height * 0.67,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    ListTile(
                                        onTap: () {
                                          FireBaseEventController.sendAnalyticsEventMenuButtonPressed('Tienda en línea').then((ok) {});
                                          menuController.close();
                                          Navigator.of(context).pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              settings: RouteSettings(name: DataUI.carritoRoute),
                                              builder: (BuildContext context) => MasterPage(
                                                initialWidget: MenuItem(
                                                  id: DataUI.tiendaRoute,
                                                  title: 'Inicio',
                                                  screen: HomePage(),
                                                  color: DataUI.chedrauiColor2,
                                                ),
                                              ),
                                            ),
                                            (Route<dynamic> route) => false,
                                          );
                                        },
                                        title: Row(
                                          children: <Widget>[
                                            Container(
                                              margin: EdgeInsets.only(right: 15),
                                              child: CarritoSVG(),
                                            ),
                                            Text(
                                              'Tienda en línea',
                                              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.11, fontFamily: 'Archivo'),
                                            ),
                                          ],
                                        )),
                                    // ListTile(
                                    //   onTap: () {
                                    //     FireBaseEventController.sendAnalyticsEventMenuButtonPressed('Pago de Servicios').then((ok) {});
                                    //     // Navigator.pushNamed(context, DataUI.pagoServiciosRoute);
                                    //     widget.onMenuItemSelected(
                                    //       MenuItem(
                                    //         id: DataUI.pagoServiciosRoute,
                                    //         title: 'Pago de servicios',
                                    //         screen: PagoServicios(),
                                    //         color: DataUI.chedrauiColor2,
                                    //       ),
                                    //     );

                                    //     menuController.close();
                                    //   },
                                    //   title: Row(
                                    //     children: <Widget>[
                                    //       Container(
                                    //         margin: EdgeInsets.only(right: 15),
                                    //         child: BillSVG(),
                                    //       ),
                                    //       Text(
                                    //         'Pago de Servicios',
                                    //         style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.11, fontFamily: 'Archivo'),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    _isLoggedIn
                                        ? SizedBox()
                                        : Container(
                                            margin: const EdgeInsets.only(
                                              left: 15.0,
                                              right: 25,
                                            ),
                                            padding: EdgeInsets.all(0),
                                            decoration: BoxDecoration(
                                              border: Border(bottom: BorderSide(width: 1.0, color: HexColor('#FFB775')), top: BorderSide(width: 1.0, color: HexColor('#FFB775'))),
                                            ),
                                            child: ListTile(
                                              contentPadding: const EdgeInsets.only(left: 0.0),
                                              onTap: () {
                                                FireBaseEventController.sendAnalyticsEventMenuButtonPressed('Iniciar Sesión').then((ok) {});

                                                menuController.close();
                                                Navigator.pushNamed(context, DataUI.loginRoute);
                                              },
                                              title: Row(
                                                children: <Widget>[
                                                  Container(
                                                    margin: EdgeInsets.only(right: 15),
                                                    child: UserSVG(),
                                                  ),
                                                  Text(
                                                    'Iniciar sesión',
                                                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.11, fontFamily: 'Archivo'),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                    _isLoggedIn
                                        ? Container(
                                            margin: const EdgeInsets.only(left: 15.0, right: 25),
                                            decoration: BoxDecoration(
                                              border: Border(bottom: BorderSide(width: 1.0, color: HexColor('#FFB775')), top: BorderSide(width: 1.0, color: HexColor('#FFB775'))),
                                            ),
                                            child: Column(
                                              children: <Widget>[
                                                _isLoggedIn
                                                    ? ListTile(
                                                        contentPadding: EdgeInsets.all(0),
                                                        title: Row(
                                                          children: <Widget>[
                                                            Container(
                                                              margin: EdgeInsets.only(right: 15),
                                                              child: UserSVG(),
                                                            ),
                                                            Text(
                                                              'Hola $userName',
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.11, fontFamily: 'Archivo'),
                                                            ),
                                                          ],
                                                        ))
                                                    : SizedBox(),
                                                _isLoggedIn
                                                    ? ListTile(
                                                        contentPadding: const EdgeInsets.only(left: 40.0),
                                                        title: Text('Mi Perfil', style: DataUI.menuItemTitleStyle),
                                                        onTap: () {
                                                          FireBaseEventController.sendAnalyticsEventMenuButtonPressed('Mi Perfil').then((ok) {});
                                                          Navigator.pushNamed(context, DataUI.cuentaRoute);
                                                          menuController.close();
                                                        },
                                                      )
                                                    : Container(),
                                                _isLoggedIn
                                                    ? ListTile(
                                                        contentPadding: const EdgeInsets.only(left: 40.0),
                                                        title: Text('Mis Pedidos', style: DataUI.menuItemTitleStyle),
                                                        onTap: () {
                                                          FireBaseEventController.sendAnalyticsEventMenuButtonPressed('Mis Pedidos').then((ok) {});
                                                          Navigator.pushNamed(context, DataUI.pedidosRoute);
                                                          menuController.close();
                                                        },
                                                      )
                                                    : Container(),
                                                _isLoggedIn
                                                    ? ListTile(
                                                        contentPadding: const EdgeInsets.only(left: 40.0),
                                                        title: Text('Mis Tarjetas', style: DataUI.menuItemTitleStyle),
                                                        onTap: () {
                                                          FireBaseEventController.sendAnalyticsEventMenuButtonPressed('Mis Tarjetas').then((ok) {});
                                                          Navigator.pushNamed(context, DataUI.monederoRoute);
                                                          menuController.close();
                                                        },
                                                      )
                                                    : Container(),
                                                _isLoggedIn
                                                    ? ListTile(
                                                        contentPadding: const EdgeInsets.only(left: 40.0),
                                                        title: Text('Mis Cupones', style: DataUI.menuItemTitleStyle),
                                                        onTap: () {
                                                          FireBaseEventController.sendAnalyticsEventMenuButtonPressed('Mis Cupones').then((ok) {});
                                                          Navigator.pushNamed(context, DataUI.cuponesRoute);
                                                          menuController.close();
                                                        },
                                                      )
                                                    : Container(),
                                                _isLoggedIn
                                                    ? ListTile(
                                                        contentPadding: const EdgeInsets.only(left: 40.0),
                                                        title: Text('Comparador de Precios', style: DataUI.menuItemTitleStyle),
                                                        onTap: () {
                                                          FireBaseEventController.sendAnalyticsEventMenuButtonPressed('Comparador de Precios').then((ok) {});
                                                          Navigator.pushNamed(context, DataUI.comparadorPreciosRoute);
                                                          menuController.close();
                                                        },
                                                      )
                                                    : Container(),
                                                _isLoggedIn
                                                    ? ListTile(
                                                        contentPadding: const EdgeInsets.only(left: 40.0),
                                                        title: Text('Cerrar Sesión', style: DataUI.menuItemTitleStyle),
                                                        onTap: () {
                                                          FireBaseEventController.sendAnalyticsEventMenuButtonPressed('Cerrar Sesión').then((ok) {});
                                                          _storeLogOut();
                                                        },
                                                      )
                                                    : SizedBox()
                                              ],
                                            ),
                                          )
                                        : SizedBox()
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    ListTile(
                                      contentPadding: const EdgeInsets.only(left: 30.0),
                                      title: Text('Centro de ayuda', style: DataUI.menuItemTitleStyle2),
                                      onTap: () {
                                        FireBaseEventController.sendAnalyticsEventMenuButtonPressed('Centro de ayuda').then((ok) {});
                                        if (Theme.of(context).platform == TargetPlatform.iOS) {
                                          Navigator.pushNamed(context, DataUI.contactanosWebRoute);
                                        } else {
                                          Navigator.pushNamed(context, DataUI.contactanosWebAndroidRoute);
                                        }
                                        menuController.close();
                                      },
                                    ),
                                    ListTile(
                                      contentPadding: const EdgeInsets.only(left: 30.0),
                                      title: Text('Ubicación de tiendas', style: DataUI.menuItemTitleStyle2),
                                      onTap: () {
                                        FireBaseEventController.sendAnalyticsEventMenuButtonPressed('Ubicación de tiendas').then((ok) {});
                                        try {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              settings: RouteSettings(name: DataUI.deliveryMethodRoute),
                                              builder: (context) => DeliveryMethodPage(
                                                showStores: true,
                                                showConfirmationForm: false,
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          Navigator.pushReplacementNamed(context, DataUI.initialRoute);
                                        }
                                        menuController.close();
                                      },
                                    ),
                                    ListTile(
                                      contentPadding: const EdgeInsets.only(left: 30.0),
                                      title: Text('Facturación Electrónica', style: DataUI.menuItemTitleStyle2),
                                      onTap: () {
                                        FireBaseEventController.sendAnalyticsEventMenuButtonPressed('Facturación Electrónica').then((ok) {});
                                        Navigator.pushNamed(context, DataUI.facturacionRoute);
                                        menuController.close();
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

//////////////////////////////////////////////////////////////////////////////////
///////////////////////  MENU BUSINESS LOGIC   ///////////////////////

  setSelectedRenderBox(RenderBox newRenderBox) async {
    final newYTop = newRenderBox.localToGlobal(const Offset(0.0, 0.0)).dy;
    final newYBottom = newYTop + newRenderBox.size.height;
    if (newYTop != selectorYTop) {
      setState(() {
        selectorYTop = newYTop;
        selectorYBottom = newYBottom;
      });
    }
  }

  Future<void> _storeLogOut() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      final store = StoreProvider.of<AppState>(context);
      store.dispatch(LogOut());
      Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
      // Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      print(e.toString());
    }
  }

  // Future getPreferences() async {
  //   prefs = await SharedPreferences.getInstance();
  // }

/////////////////////// ANIMATED LIST  BACKUP   ///////////////////////
  // createMenuItems(MenuController menuController) {
  //   final List<Widget> listItems = [];
  //   final animationIntervalDuration = 0.5;
  //   final perListItemDelay = menuController.state != MenuState.closing ? 0.15 : 0.0;
  //   for (var i = 0; i < menu.items.length; ++i) {
  //     final animationIntervalStart = i * perListItemDelay;
  //     final animationIntervalEnd = animationIntervalStart + animationIntervalDuration;
  //     final isSelected = menu.items[i].id == widget.selectedItemId;

  //     listItems.add(
  //       new AnimatedMenuListItem(
  //         menuState: menuController.state,
  //         isSelected: isSelected,
  //         duration: const Duration(milliseconds: 240),
  //         // curve: new Interval(animationIntervalStart, animationIntervalEnd, curve: Curves.easeOut),
  //         menuListItem: new _MenuListItem(
  //           title: menu.items[i].title,
  //           isSelected: isSelected,
  //           onTap: () {
  //             // Widget screen;
  //             // switch (widget.menu.items[i].id) {
  //             //   case 'home':
  //             //     screen = HomePage(menuController.toggle);
  //             //     break;
  //             //   case 'misPedidos':
  //             //     screen = PedidosPage(menuController.toggle);
  //             //     break;
  //             //   case 'misCupones':
  //             //     screen = CuponesPage(menuController.toggle);
  //             //     break;
  //             //   case 'facturacion':
  //             //     screen = FacturacionPage(menuController.toggle);
  //             //     break;
  //             //   case 'contactanos':
  //             //     screen = Contactanos(menuController.toggle);
  //             //     break;
  //             //   case 'comparadorPrecios':
  //             //     screen = ComparadorPrecios(menuController.toggle);
  //             //     break;
  //             //   default:
  //             //      screen = HomePage(menuController.toggle);
  //             //     break;
  //             // }
  //             widget.onMenuItemSelected(menu.items[i]);
  //             menuController.close();
  //           },
  //         ),
  //       ),
  //     );
  //   }
  //   return new Transform(
  //     transform: new Matrix4.translationValues(
  //       0.0,
  //       30.0,
  //       0.0,
  //     ),
  //     child: Container(
  //       padding: EdgeInsets.only(left: 10, top: 0, bottom: 5),
  //       child: Column(
  //         children: listItems,
  //       ),
  //     ),
  //   );
  // }
}

class MenuItem {
  final String id;
  final String title;
  final List<Widget> actions;
  final Color color;
  final Color textColor;
  final Widget screen;

  MenuItem({
    this.id,
    this.title,
    this.actions,
    this.color,
    this.textColor,
    this.screen,
  });
}

// class ItemSelector extends ImplicitlyAnimatedWidget {
//   final double topY;
//   final double bottomY;
//   final double opacity;

//   ItemSelector({
//     this.topY,
//     this.bottomY,
//     this.opacity,
//   }) : super(duration: const Duration(milliseconds: 250));

//   @override
//   _ItemSelectorState createState() => new _ItemSelectorState();
// }

// class _ItemSelectorState extends AnimatedWidgetBaseState<ItemSelector> {
//   Tween<double> _topY;
//   Tween<double> _bottomY;
//   Tween<double> _opacity;

//   @override
//   void forEachTween(TweenVisitor visitor) {
//     _topY = visitor(
//       _topY,
//       widget.topY,
//       (dynamic value) => new Tween<double>(begin: value),
//     );
//     _bottomY = visitor(
//       _bottomY,
//       widget.bottomY,
//       (dynamic value) => new Tween<double>(begin: value),
//     );
//     _opacity = visitor(
//       _opacity,
//       widget.opacity,
//       (dynamic value) => new Tween<double>(begin: value),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return new Positioned(
//       top: _topY.evaluate(animation),
//       child: new Opacity(
//         opacity: _opacity.evaluate(animation),
//         child: new Container(
//           width: 5.0,
//           height: _bottomY.evaluate(animation) - _topY.evaluate(animation),
//           color: Colors.red,
//         ),
//       ),
//     );
//   }
// }

// class AnimatedMenuListItem extends ImplicitlyAnimatedWidget {
//   final _MenuListItem menuListItem;
//   final MenuState menuState;
//   final bool isSelected;
//   final Duration duration;

//   AnimatedMenuListItem({
//     this.menuListItem,
//     this.menuState,
//     this.isSelected,
//     this.duration,
//     // curve,
//   }) : super(duration: duration);

//   @override
//   _AnimatedMenuListItemState createState() => new _AnimatedMenuListItemState();
// }

// class _AnimatedMenuListItemState extends AnimatedWidgetBaseState<AnimatedMenuListItem> {
//   final double closedSlidePosition = 200.0;
//   final double openSlidePosition = 0.0;

//   Tween<double> _translation;
//   Tween<double> _opacity;

//   updateSelectedRenderBox() {
//     final renderBox = context.findRenderObject() as RenderBox;
//     if (renderBox != null && widget.isSelected) {
//       (menuScreenKey.currentState as _MenuScreenState).setSelectedRenderBox(renderBox);
//     }
//   }

//   @override
//   void forEachTween(TweenVisitor visitor) {
//     var slide, opacity;

//     switch (widget.menuState) {
//       case MenuState.closed:
//       case MenuState.closing:
//         slide = closedSlidePosition;
//         opacity = 0.0;
//         break;
//       case MenuState.open:
//       case MenuState.opening:
//         slide = openSlidePosition;
//         opacity = 1.0;
//         break;
//     }

//     _translation = visitor(
//       _translation,
//       slide,
//       (dynamic value) => new Tween<double>(begin: value),
//     );

//     _opacity = visitor(
//       _opacity,
//       opacity,
//       (dynamic value) => new Tween<double>(begin: value),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     updateSelectedRenderBox();

//     return new Opacity(
//       opacity: _opacity.evaluate(animation),
//       child: new Transform(
//         transform: new Matrix4.translationValues(
//           0.0,
//           _translation.evaluate(animation),
//           0.0,
//         ),
//         child: widget.menuListItem,
//       ),
//     );
//   }
// }

// class _MenuListItem extends StatelessWidget {
//   final String title;
//   final bool isSelected;
//   final Function() onTap;

//   _MenuListItem({
//     this.title,
//     this.isSelected,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       splashColor: const Color(0x44000000),
//       onTap: isSelected ? null : onTap,
//       child: Container(
//         width: double.infinity,
//         child: Padding(
//           padding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
//           child: Text(
//             title,
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: isSelected ? FontWeight.w800 : FontWeight.w300,
//               fontSize: 16.0,
//               fontFamily: 'Archivo',
//               // letterSpacing: 2.0,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class Menu {
//   final List<MenuItem> items;

//   Menu({
//     this.items,
//   });
// }
