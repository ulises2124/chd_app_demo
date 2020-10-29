import 'package:chd_app_demo/redux/models/AppState.dart';
import 'package:chd_app_demo/services/CarritoServices.dart';
import 'package:chd_app_demo/services/FireBaseServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/Buzon/BuzonPage.dart';
import 'package:chd_app_demo/views/CarritoPage/CarritoPage.dart';
import 'package:chd_app_demo/views/ComparadorPrecios/ComparadorPrecios.dart';
// import 'package:chedraui_flutter/views/CuentaPage/CuentaPage.dart';
import 'package:chd_app_demo/views/HomePage/HomePage.dart';
import 'package:chd_app_demo/views/ListasPage/ListasPage.dart';

import 'package:chd_app_demo/views/MasterPage/MasterPage.dart';
// import 'package:chedraui_flutter/views/MasterPage/BottomNavigation.dart';
// import 'package:chedraui_flutter/views/MasterPage/MasterPage.dart';
import 'package:chd_app_demo/views/MasterPage/MenuScreen.dart';
// import 'package:chedraui_flutter/views/Monedero/MonederoPage.dart';
import 'package:chd_app_demo/views/SearchPage/SearchPage.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';
import 'package:chd_app_demo/widgets/footerNavigation.dart';
import 'package:chd_app_demo/widgets/notSignedIn.dart';
//import 'package:chd_app_demo/flare_actor.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:chedraui_flutter/views/Checkout/NewCreditCard.dart';

// import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
// import 'package:chedraui_flutter/redux/models/AppState.dart';
import 'package:chd_app_demo/redux/actions/ShoppingCartsActions.dart';

class ZoomScaffold extends StatefulWidget {
  final Widget menuScreen;
  final MenuItem initialWidget;
  String internet;
  ZoomScaffold({
    this.menuScreen,
    this.internet,
    this.initialWidget,
    Key key,
  }) : super(key: key);

  @override
  ZoomScaffoldState createState() => new ZoomScaffoldState();
}

class ZoomScaffoldState extends State<ZoomScaffold> with TickerProviderStateMixin {
  GlobalKey<ComparadorPreciosState> globalKeyComparadorPrecios = GlobalKey();
  SharedPreferences prefs;
  bool _isLoggedIn = false;
  int numberProducts = 0;
  bool isOpen = false;
  Widget bodyContent;
  MenuItem contentScreen = MenuItem(
    id: DataUI.initialRoute,
    title: 'Inicio',
    screen: HomePage(),
    color: DataUI.chedrauiColor2,
    textColor: DataUI.primaryText,
  );

  MenuController menuController;
  Curve scaleDownCurve = new Interval(0.0, 0.3, curve: Curves.easeOut);
  Curve scaleUpCurve = new Interval(0.0, 1.0, curve: Curves.easeOut);
  Curve slideOutCurve = new Interval(0.0, 1.0, curve: Curves.easeOut);
  Curve slideInCurve = new Interval(0.0, 1.0, curve: Curves.easeOut);
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;

  ///////////////////////  NEW MENU VARIABLES   ///////////////////////

  @override
  void initState() {
    if (widget.initialWidget != null) {
      contentScreen = widget.initialWidget;
    }
    super.initState();
    loadCartItems();
    getPreferences().then((x) {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
    menuController = new MenuController(
      vsync: this,
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    menuController.dispose();
    super.dispose();
  }

///////////////////////  ZOOM SCAFFOLD UI BUILD   ///////////////////////

  @override
  Widget build(BuildContext context) {
    print(widget.internet);
    return WidgetContainer(
      Stack(
        children: [
          Scaffold(
            backgroundColor: HexColor('#ef7128'),
            appBar: AppBar(
              backgroundColor: HexColor('#ef7128'),
              centerTitle: true,
              title: ChedrauiHeaderWhite(185, 14),
              elevation: 0,
              leading: IconButton(
                padding: EdgeInsets.only(left: 10, top: 10, bottom: 0),
                iconSize: 32,
                color: Colors.white,
                icon: Icon(Icons.close),
                onPressed: () {
                  menuController.toggle();
                  setState(() {
                    isOpen = !isOpen;
                  });
                },
              ),
            ),
            body: widget.menuScreen,
          ),
          zoomAndSlideContent(
            Scaffold(
              key: _scaffoldKey,
              backgroundColor: contentScreen.id == DataUI.pagoServiciosRoute ? _isLoggedIn ? HexColor('#F4F6F8') : Colors.white : DataUI.backgroundColor2,
              appBar: contentScreen.id != DataUI.tiendaRoute && contentScreen.id != DataUI.initialRoute && contentScreen.id != DataUI.pagoServiciosRoute
                  ? GradientAppBar(
                      elevation: 0,
                      gradient: LinearGradient(
                        //stops: [0, 0, 1],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          HexColor('#F56D00'),
                          HexColor('#F56D00'),
                          HexColor('#F78E00'),
                        ],
                      ),
                      centerTitle: true,
                      title: Text(
                        contentScreen.title,
                        style: DataUI.appbarTitleStyle,
                      ),
                      leading: IconButton(
                        icon: Stack(
                          children: <Widget>[
                            HamburguerIconSVG(),
                          ],
                        ),
                        onPressed: () {
                          menuController.toggle();
                          setState(() {
                            isOpen = !isOpen;
                          });
                        },
                      ),
                      actions: <Widget>[
                        contentScreen.id == DataUI.carritoRoute
                            ? IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                ),
                                color: DataUI.whiteText,
                                onPressed: () {
                                  _showResponseDialog(context);
                                })
                            : SizedBox()
                      ],
                    )
                  : AppBar(
                      elevation: 0,
                      backgroundColor: contentScreen.color,
                      centerTitle: true,
                      title: ChedrauiHeaderWhite(185, 14),
                      leading: IconButton(
                        icon: Stack(
                          children: <Widget>[
                            HamburguerIconSVG(),
                          ],
                        ),
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          menuController.toggle();
                          setState(() {
                            isOpen = !isOpen;
                          });
                        },
                      ),
                      actions: <Widget>[
                        Builder(
                          builder: (context) => IconButton(
                            icon: Icon(
                              Icons.notifications_none,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () {
                              Scaffold.of(context).openEndDrawer();
                            },
                          ),
                        ),
                      ],
                    ),
              body: contentScreen.screen,
              bottomNavigationBar: contentScreen.id == DataUI.pagoServiciosRoute
                  ? SizedBox()
                  : FooterNavigation(
                      bottomNavigationController,
                      mainNavigation: true,
                      contentScreen: contentScreen,
                    ),
              endDrawer: BuzonPage(),
            ),
          ),
        ],
      ),
    );
  }

  _showResponseDialog(context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                contentPadding: EdgeInsets.all(29),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                content: Text(
                  '¿Estás seguro de que quieres vaciar tu carrito?',
                  style: TextStyle(color: HexColor('#212B36'), fontFamily: 'Archivo', fontSize: 16, fontWeight: FontWeight.bold),
                ),
                actions: <Widget>[
                  FlatButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    padding: EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                    color: HexColor('#F57C00'),
                    disabledColor: HexColor('#F57C00').withOpacity(0),
                    onPressed: loading
                        ? null
                        : () async {
                            setState(() {
                              loading = true;
                            });
                            await CarritoServices.clearCart().then((onValue) {
                              if (onValue == true) {
                                setState(() {
                                  loading = false;
                                });
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    settings: RouteSettings(name: DataUI.carritoRoute),
                                    builder: (BuildContext context) => MasterPage(
                                      initialWidget: MenuItem(
                                        id: DataUI.carritoRoute,
                                        title: 'Mi Carrito',
                                        screen: CarritoPage(),
                                        color: DataUI.chedrauiColor2,
                                        textColor: DataUI.primaryText,
                                      ),
                                    ),
                                  ),
                                  (Route<dynamic> route) => false,
                                );
                              } else {
                                setState(() {
                                  loading = false;
                                });

                                Navigator.pop(context);
                                Flushbar(
                                  message: "Ha ocurrido un error, por favor intente más tarde.",
                                  backgroundColor: HexColor('#FD5339'),
                                  flushbarPosition: FlushbarPosition.TOP,
                                  flushbarStyle: FlushbarStyle.FLOATING,
                                  margin: EdgeInsets.all(8),
                                  borderRadius: 8,
                                  icon: Icon(
                                    Icons.highlight_off,
                                    size: 28.0,
                                    color: Colors.white,
                                  ),
                                  duration: Duration(seconds: 3),
                                )..show(context);
                              }
                            });
                          },
                    child: loading
                        ? Container(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation(Colors.blue),
                            ),
                          )
                        : Text(
                            "Confirmar",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Archivo', fontWeight: FontWeight.bold),
                          ),
                  ),
                  FlatButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    padding: EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                    color: HexColor('#F57C00').withOpacity(0),
                    onPressed: loading
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                    child: Text(
                      "Cancelar",
                      style: TextStyle(
                        color: loading ? Colors.transparent : DataUI.chedrauiBlueColor,
                        fontSize: 14,
                        fontFamily: 'Archivo',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  )
                ],
              );
            },
          );
        });
  }
///////////////////////  BODY CONTENT LOGIC   ///////////////////////

  updateBody(MenuItem item) {
    setState(() {
      contentScreen = item;
    });
  }

  bottomNavigationController(MenuItem bodyPage) {
    setState(() {
      contentScreen = bodyPage;
      bodyContent = bodyPage.screen;
    });
  }

///////////////////////  SCAFFOLD BUSINESS LOGIC   ///////////////////////

  void loadCartItems() async {
    try {
      final carrito = await CarritoServices.getCart();
      final itemsQty = carrito['totalItems'];
      final store = StoreProvider.of<AppState>(context);
      store.dispatch(SetShoppingItems(itemsQty));
    } catch (e) {
      print(e.toString());
    }
  }

  Future getPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  openEndDrawer() {
    Scaffold.of(context).openEndDrawer();
  }

  ///////////////////////  ZOOM ANIMATION SCAFFOLD LOGIC   ///////////////////////

  zoomAndSlideContent(Widget content) {
    var slidePercent, scalePercent;
    switch (menuController.state) {
      case MenuState.closed:
        slidePercent = 0.0;
        scalePercent = 0.0;
        break;
      case MenuState.open:
        slidePercent = 1.0;
        scalePercent = 1.0;
        break;
      case MenuState.opening:
        slidePercent = slideOutCurve.transform(menuController.percentOpen);
        scalePercent = scaleDownCurve.transform(menuController.percentOpen);
        break;
      case MenuState.closing:
        slidePercent = slideInCurve.transform(menuController.percentOpen);
        scalePercent = scaleUpCurve.transform(menuController.percentOpen);
        break;
    }

    final slideAmount = 275.0 * slidePercent;
    final contentScale = 1.0 - (0.24 * scalePercent);
    final cornerRadius = 10.0 * menuController.percentOpen;

    return new Transform(
      transform: new Matrix4.translationValues(slideAmount, 0.0, 0.0)..scale(contentScale, contentScale),
      alignment: Alignment.centerLeft,
      child: new Container(
        decoration: new BoxDecoration(
          boxShadow: [
            new BoxShadow(
              color: DataUI.whiteText.withOpacity(0.2),
              offset: const Offset(-15.0, 20.0),
              blurRadius: 2.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
        child: new ClipRRect(borderRadius: new BorderRadius.circular(cornerRadius), child: content),
      ),
    );
  }
}

class ZoomScaffoldMenuController extends StatefulWidget {
  final ZoomScaffoldBuilder builder;

  ZoomScaffoldMenuController({
    this.builder,
  });

  @override
  ZoomScaffoldMenuControllerState createState() {
    return new ZoomScaffoldMenuControllerState();
  }
}

class ZoomScaffoldMenuControllerState extends State<ZoomScaffoldMenuController> {
  MenuController menuController;

  @override
  void initState() {
    super.initState();

    menuController = getMenuController(context);
    menuController.addListener(_onMenuControllerChange);
  }

  @override
  void dispose() {
    menuController.removeListener(_onMenuControllerChange);
    super.dispose();
  }

  getMenuController(BuildContext context) {
    final scaffoldState = context.ancestorStateOfType(new TypeMatcher<ZoomScaffoldState>()) as ZoomScaffoldState;
    return scaffoldState.menuController;
  }

  _onMenuControllerChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, getMenuController(context));
  }
}

typedef Widget ZoomScaffoldBuilder(BuildContext context, MenuController menuController);

class MenuController extends ChangeNotifier {
  final TickerProvider vsync;
  final AnimationController _animationController;
  MenuState state = MenuState.closed;

  MenuController({
    this.vsync,
  }) : _animationController = new AnimationController(vsync: vsync) {
    _animationController
      ..duration = const Duration(milliseconds: 150)
      ..addListener(() {
        notifyListeners();
      })
      ..addStatusListener((AnimationStatus status) {
        switch (status) {
          case AnimationStatus.forward:
            state = MenuState.opening;
            break;
          case AnimationStatus.reverse:
            state = MenuState.closing;
            break;
          case AnimationStatus.completed:
            state = MenuState.open;
            break;
          case AnimationStatus.dismissed:
            state = MenuState.closed;
            break;
        }
        notifyListeners();
      });
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  get percentOpen {
    return _animationController.value;
  }

  open() {
    _animationController.forward();
  }

  close() {
    _animationController.reverse();
  }

  toggle() {
    if (state == MenuState.open) {
      close();
    } else if (state == MenuState.closed) {
      open();
    }
  }
}

enum MenuState {
  closed,
  opening,
  open,
  closing,
}
