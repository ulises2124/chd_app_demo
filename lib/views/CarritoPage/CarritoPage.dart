import 'package:chd_app_demo/services/ArticulosServices.dart';
import 'package:chd_app_demo/services/CarritoServices.dart';
import 'package:chd_app_demo/services/FireBaseServices.dart';
import 'package:chd_app_demo/services/ListasServices.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/CarritoPage/CarritoList.dart';
import 'package:chd_app_demo/views/Errors/NetworkErrorPage/NetworkErrorPage.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:chd_app_demo/views/DeliveryMethod/DeliveryMethodPage.dart';
import 'package:chd_app_demo/utils/NetworkData.dart';
import 'package:chd_app_demo/views/CarritoPage/TypeDelta.dart';
import 'package:chd_app_demo/views/MasterPage/MasterPage.dart';
import 'package:chd_app_demo/views/MasterPage/MenuScreen.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:chd_app_demo/redux/models/AppState.dart';
import 'package:chd_app_demo/redux/actions/ShoppingCartsActions.dart';

class CarritoPage extends StatefulWidget {
  final double total = 100;

  CarritoPage({Key key}) : super(key: key);

  _CarritoPageState createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var token;
  var cart;
  double subtotal = 0;
  double discounts = 0;
  double delivery = 0;
  double total = 0;
  num totalItems = 0;
  num totalUnitCount = 0;
  List cartItems = [];
  List deltasAmount;
  Future carritoResponse;
  bool dataLoaded = false;
  bool loadingVaciar = false;
  bool updatingCart = false;
  NumberFormat moneda = new NumberFormat.currency(locale: 'es_MX', symbol: "\$");

  bool loading = false;

  var listName;

  bool listcreated;

  SharedPreferences prefs;
  bool _isLoggedIn = false;

  int indexCart = 0;
  int indexCartA = 0;

  bool loadingProducts = false;

  void _showSnackBar(BuildContext context, String text) {
    Flushbar(
      message: text,
      backgroundColor: HexColor('#39B54A'),
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      icon: Icon(
        Icons.check_circle_outline,
        size: 28.0,
        color: Colors.white,
      ),
      duration: Duration(seconds: 3),
    )..show(context);
  }

  getCarrito() async {
    setState(() {
      cart = null;
      dataLoaded = false;
      updatingCart = true;
    });

    carritoResponse = CarritoServices.getCart();
    var carrito = await carritoResponse;
    if (mounted) {
      //final totalUnitCount = carrito['totalUnitCount'];
      final totalItems = carrito['totalItems'];
      final store = StoreProvider.of<AppState>(context);
      store.dispatch(SetShoppingItems(totalItems));
    }

    for (int ip = 0; ip < carrito['entries'].length; ip++) {
      carrito['entries'][ip]['customIndex'] = ip;
    }

    Future<dynamic> getDataProduct(product) async {
      int customindex = product['customIndex'];
      var singleProduct = await ArticulosServices.getProductHybrisSearch(product['product']['code']);
      product['urlImage'] = (() {
        if (singleProduct != null && singleProduct['images'] != null && singleProduct['images'].length > 0) {
          return NetworkData.hybrisBaseUrl + singleProduct['images'][0]['url'];
        } else {
          return "";
        }
      })();

      List promos = [];
      if (singleProduct != null && singleProduct['potentialPromotions'] != null) promos = singleProduct['potentialPromotions'];
      List promosPorduct = [];
      if (promos.length > 0) {
        List tempPromos = [];
        promos.forEach((p) {
          tempPromos.add(p['description']);
        });
        promosPorduct = Set.of(tempPromos).toList();
      }
      product['promosList'] = promosPorduct;

      product['unitaryPrice'] = {'value': product['totalPrice']['value'] / product['decimalQty']};

      String code = singleProduct["unit"]["code"];
      String conversion = singleProduct["unit"]["conversion"] != null ? singleProduct["unit"]["conversion"].toString() : "100";
      bool pesable = (code != null && code.toUpperCase().contains("KGM"));
      String minOrderQuantity;

      dynamic weigthweightPerAltSalesUnit = singleProduct["weightPerAltSalesUnit"];

      if (weigthweightPerAltSalesUnit != null) {
        minOrderQuantity = weigthweightPerAltSalesUnit["conversion"].toString() != null ? weigthweightPerAltSalesUnit["conversion"].toString() : "0.1";
      } else if (singleProduct["minOrderQuantity"] != null) {
        String minOrder = singleProduct["minOrderQuantity"] != null ? singleProduct["minOrderQuantity"].toString() : "0.1";
        double minOrderParse = double.parse(minOrder);
        double pesoUnitario = double.parse(conversion);
        double adjust = pesoUnitario <= 0 ? 0 : minOrderParse / pesoUnitario;
        minOrderQuantity = minOrder.contains(".") ? minOrder : adjust.toString();
      } else {
        minOrderQuantity = pesable ? "0.1" : "1";
      }

      product['minQty'] = double.parse(minOrderQuantity);

      carrito['entries'][customindex] = product;
      indexCart++;

      return product['product']['name'];
    }

    void setStateCart() {
      if (mounted) {
        setState(() {
          cart = carrito;
          cartItems = carrito['entries'];
          discounts = carrito['totalDiscounts'] != null ? carrito['totalDiscounts']['value'] : 0;
          subtotal = carrito['subTotal']['value'] + discounts;
          delivery = carrito['deliveryCost'] != null ? carrito['deliveryCost']['value'] : 0;
          total = carrito['totalPrice']['value'];
          totalItems = carrito['totalItems'];
          totalUnitCount = carrito['totalUnitCount'];
          updatingCart = false;
          dataLoaded = true;
          indexCart = 0;
        });
      }
    }

    Iterable entries = carrito['entries'];
    Iterable<Future<dynamic>> mapped = entries.map((p) => getDataProduct(p));

    if (carrito['totalItems'] > 0) {
      for (Future<dynamic> f in mapped) {
        f.then((v) {
          if (indexCart == (carrito['totalItems'])) {
            setStateCart();
          }
        });
      }
    } else {
      setStateCart();
    }
  }

  Future<dynamic> checkAvailabilityProduct(product) async {
    //int customindex = product['customIndex'];
    var singleProduct = await ArticulosServices.getProductHybrisSearch(product['product']['code']);
    /*
      if(singleProduct == ""){
        product['nonListed'] = true;
      }
      cart['entries'][customindex] = product;
      indexCartA++;
      */
    Map<dynamic, dynamic> resultProduct = {"isListed": singleProduct != "", "code": product['product']['code']};
    return resultProduct;
  }

  Future<List<dynamic>> checkRemovedProducts() async {
    setState(() {
      loadingProducts = true;
    });

    List<dynamic> unlistedProducts = [];
    Iterable entries = cartItems;
    if (entries == null || entries.isEmpty) return [];

    await Future.forEach(entries, (item) async {
      var p = await checkAvailabilityProduct(item);
      if (!p['isListed']) {
        var removedProduct = {"index": item['customIndex'], "typeDelta": TypeDelta.toBeRemoved, "amount": 0, "name": item['product']['name']};
        unlistedProducts.add(removedProduct);
      }
    });

    return unlistedProducts.reversed.toList();
  }

  Future getPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  Future<void> start() async {
    await getPreferences();
    await getCarrito();
  }

  initState() {
    start();
    super.initState();
  }

  void callbackUpdate(double newTotal, int newQuantity, var deltas) async {
    //await getCarrito();
    setState(() {
      subtotal = newTotal;
      total = newTotal;
      //discounts = 0;
      //delivery = 0;
      //totalUnitCount = newQuantity;
      deltasAmount = deltas;
    });
  }

  void forceUpdate() {
    print('force update');
    getCarrito();
  }

  Future<List> processDeltas() async {
    List noSuccesful = [];
    //num deletedItems = 0;
    if (deltasAmount != null) {
      setState(() {
        dataLoaded = false;
      });
      await Future.forEach(deltasAmount, (d) async {
        switch (d['typeDelta']) {
          case TypeDelta.toBeRemoved:
            var resultRemove = await CarritoServices.deleteEntryCart(d['index']);
            if (!resultRemove)
              noSuccesful.add(d['name']);
            break;
          case TypeDelta.changedAmount:
            var resultUpdate = await CarritoServices.updateEntryCart(d['index'], d['amount']);
            print(resultUpdate);
            if (resultUpdate != null && resultUpdate['statusCode'] != 'success') noSuccesful.add(d['name']);
            break;
          default:
        }
      });
      setState(() {
        deltasAmount = null;
        updatingCart = false;
      });
      //await getCarrito();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          settings: RouteSettings(name: DataUI.carritoRoute),
          builder: (BuildContext context) => MasterPage(
            initialWidget: MenuItem(
              id: DataUI.carritoRoute,
              //title: 'Mi Carrito' + '(' + (totalItems - deletedItems).toString() + ')',
              title: 'Mi Carrito',
              screen: CarritoPage(),
              color: DataUI.chedrauiColor2,
              textColor: DataUI.primaryText,
            ),
          ),
        ),
        (Route<dynamic> route) => false,
      );
    }
    print(noSuccesful);
    return noSuccesful;
  }

  saveList() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (_formKey.currentState.validate()) {
      setState(() {
        loading = true;
      });
      _formKey.currentState.save();
      listName = listName.replaceAll(' ', '+');
      await ListasServices.createList(listName).then((response) async {
        if (response['errorMessage'] == "Duplicate shopping list name exists for user.") {
          setState(() {
            loading = false;
          });
          Navigator.pop(context);
          Flushbar(
            message: "La lista $listName no se puede crear porque ya existe una lista con ese nombre",
            backgroundColor: HexColor('#FF8D41'),
            flushbarPosition: FlushbarPosition.TOP,
            flushbarStyle: FlushbarStyle.FLOATING,
            margin: EdgeInsets.all(8),
            borderRadius: 8,
            icon: Icon(
              Icons.error_outline,
              size: 28.0,
              color: Colors.white,
            ),
            duration: Duration(seconds: 3),
          )..show(context);
        } else if (response['code'] != null) {
          var listID = response['code'];
          var name = response['name'];
          print(listID);
          await Future.forEach(cartItems, (prodduct) async {
            await ListasServices.addProduct(listID, prodduct['product']['code'], prodduct['decimalQty'].toString()).then((res) {
              if (res == true) {
                setState(() {
                  listcreated = true;
                });
              }
            });
          });
          if (listcreated == true) {
            setState(() {
              loading = false;
            });
            Navigator.pop(context);
            showwsuccess(name);
          } else {
            setState(() {
              loading = false;
            });
            Navigator.pop(context);
            showErrorList();
          }
        } else {
          setState(() {
            loading = false;
          });
          Navigator.pop(context);
          showErrorList();
        }
      });
    }
  }

  void showErrorList() {
    Flushbar(
      message: "Ha ocurrido un error al crear la lista.",
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

  void showwsuccess(title) {
    Flushbar(
      message: "La lista $title ha sido creada correctamente",
      backgroundColor: HexColor('#39B54A'),
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      icon: Icon(
        Icons.check_circle_outline,
        size: 28.0,
        color: Colors.white,
      ),
      duration: Duration(seconds: 3),
    )..show(context);
  }

  showDialogNoListedProducts() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Artículos no disponibles"),
            content: Text("Existen artículos que se han eliminado del carrito debido a que ya no están disponibles"),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Revisar mi carrito",
                  style: TextStyle(
                    color: DataUI.chedrauiBlueColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        });
  }

  showDialogStock(List noSuccessList) {
    final bool isLocationSet = prefs.getBool('isLocationSet') ?? false;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Artículos no disponibles"),
            content: Text("Existen artículos que no se actualizaron por stock o cantidad de productos permitida: \n" + noSuccessList.join('\n')),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Revisar mi carrito",
                  style: TextStyle(
                    color: DataUI.chedrauiBlueColor,
                    fontSize: 16,
                  ),
                ),
              ),
              isLocationSet && total > 200
                  ? FlatButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await FireBaseEventController.sendAnalyticsEventBeginCheckOut(cart);
                        var checkoutResult = await Navigator.pushNamed(context, DataUI.checkoutRoute);
                        if (checkoutResult == 'bounce') {
                          await Navigator.pushNamed(context, DataUI.checkoutRoute);
                        }
                        setState(() {
                          deltasAmount = [];
                        });
                      },
                      child: Text(
                        "Ir a checkout",
                        style: TextStyle(
                          color: DataUI.chedrauiBlueColor,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : SizedBox(height: 0),
            ],
          );
        });
  }

  createList() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Guardar Lista"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    child: Text('Ingresa un nombre a tu lista para guardarla en tu cuenta.'),
                  ),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: const EdgeInsets.only(
                            top: 12,
                            bottom: 12,
                            left: 6, //todo
                            right: 6 //todo
                            ),
                        hintText: 'Nombre de la Lista',
                        hintStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                      validator: (String arg) {
                        if (arg.length < 1)
                          return 'Ingrese un nombre';
                        else
                          return null;
                      },
                      keyboardType: TextInputType.text,
                      onSaved: (input) {
                        setState(() {
                          listName = input;
                        });
                      },
                    ),
                  )
                ],
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: FlatButton(
                    onPressed: loading ? null : () => Navigator.pop(context),
                    child: Text(
                      "Cancelar",
                      style: TextStyle(
                        color: DataUI.chedrauiBlueColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: RaisedButton(
                      color: DataUI.chedrauiBlueColor,
                      onPressed: loading ? null : saveList,
                      child: loading
                          ? SizedBox(
                              height: 13,
                              width: 13,
                              child: CircularProgressIndicator(),
                            )
                          : Text(
                              "Guardar",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            )),
                )
              ],
            );
          },
        );
      },
    );
  }

  // onRefresh: () async{
  //           List noSuccessList = await processDeltas();
  //           if(noSuccessList.length > 0){
  //             showDialogStock(noSuccessList);
  //           }
  //         },

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: HexColor('#F0EFF4'),
      // appBar: GradientAppBar(
      //   elevation: 0,

      //   gradient: LinearGradient(
      //     begin: Alignment.topCenter,
      //     end: Alignment.bottomCenter,
      //     colors: [
      //       HexColor('#F56D00'),
      //       HexColor('#F56D00'),
      //       HexColor('#F78E00'),
      //     ],
      //   ),
      //   centerTitle: true,
      //   // leading: Builder(
      //   //   builder: (BuildContext context) {
      //   //     return IconButton(
      //   //       icon: Icon(Icons.arrow_back),
      //   //       color: DataUI.whiteText,
      //   //       /*
      //   //       onPressed: !updatingCart ? () async{
      //   //         await processDeltas();
      //   //         Navigator.pop(context, 'reload');
      //   //       } : null,
      //   //       */
      //   //       onPressed: (){
      //   //         if(deltasAmount != null){
      //   //           showDialog(
      //   //             context: context,
      //   //             builder: (BuildContext context) {
      //   //               return AlertDialog(
      //   //                 title:
      //   //                     Text("Cambios pendientes"),
      //   //                 content: Text(
      //   //                     "¿Está seguro de salir sin actualizar los cambios de su carrito?"),
      //   //                 actions: <Widget>[
      //   //                   Column(
      //   //                     children: <Widget>[
      //   //                       FlatButton(
      //   //                         onPressed: () {
      //   //                           Navigator.pop(context);
      //   //                         },
      //   //                         child: Text(
      //   //                           "Permanecer en el carrito",
      //   //                           style: TextStyle(
      //   //                             color: DataUI
      //   //                                 .chedrauiBlueColor,
      //   //                             fontSize: 16,
      //   //                           ),
      //   //                         ),
      //   //                       ),
      //   //                       FlatButton(
      //   //                         onPressed: () {
      //   //                           Navigator.pop(context);
      //   //                           Navigator.pop(context);
      //   //                         },
      //   //                         child: Text(
      //   //                           "Volver al inicio",
      //   //                           style: TextStyle(
      //   //                             color: DataUI
      //   //                                 .chedrauiBlueColor,
      //   //                             fontSize: 16,
      //   //                           ),
      //   //                         ),
      //   //                       ),
      //   //                     ],
      //   //                   )
      //   //                 ],
      //   //               );
      //   //             });
      //   //         } else {
      //   //           Navigator.pop(context, 'reload');
      //   //         }
      //   //       }
      //   //     );
      //   //   },
      //   // ),
      //   actions: <Widget>[
      //     IconButton(
      //       icon: Icon(Icons.playlist_add , color: Colors.white,),
      //       color: DataUI.whiteText,
      //       onPressed: totalItems > 0 ? () async {
      //         if (_isLoggedIn == true) {
      //           print(deltasAmount);
      //           await processDeltas();
      //           if(totalItems > 0){
      //             createList();
      //           }
      //         } else {
      //           showDialog(
      //             context: context,
      //             barrierDismissible: true,
      //             builder: (BuildContext context) {
      //               return AlertDialog(
      //                 title: Text('Crear Lista'),
      //                 content: Container(
      //                   height: MediaQuery.of(context).size.width < 350 ? MediaQuery.of(context).size.width * 1.0 : MediaQuery.of(context).size.width * 0.80,
      //                   child: NotSignedInWidget(
      //                   message:
      //                       'Para poder visualizar o crear tus listas de compras, por favor inicia sesión y disfruta de todos los beneficios de la nueva tienda Chedraui',
      //                 ),
      //                 )
      //               );
      //             });
      //         }
      //       } : null,
      //     )
      //   ],
      //   title: Text(
      //     //'Carrito de Compras',
      //     cart != null
      //         ? 'Mi Carrito (' + totalUnitCount.toString() + ')'
      //         : 'Mi Carrito',
      //     style: TextStyle(color: Colors.white, fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 19),
      //   ),
      // ),
      body: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        // color: Colors.green,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: FutureBuilder(
            future: carritoResponse,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(100.0),
                      child: CircularProgressIndicator(value: null),
                    ),
                  );
                  break;
                case ConnectionState.active:
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(100.0),
                      child: CircularProgressIndicator(value: null),
                    ),
                  );
                  break;
                case ConnectionState.none:
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(100.0),
                      child: CircularProgressIndicator(value: null),
                    ),
                  );
                  break;
                case ConnectionState.done:
                  if (snapshot.hasError) {
                   if (snapshot.error.toString().contains('No Internet connection')) {
                          return NetworkErrorPage(
                            showGoHomeButton: false,
                          );
                        } else {
                          return NetworkErrorPage(
                            errorMessage: 'Ha ocurrido un error, por favor inténtalo más tarde',
                            showGoHomeButton: true,
                          );
                        }
                  } else if (snapshot.hasData && snapshot.data != null) {
                    return cart != null && dataLoaded
                        ? (cartItems.length > 0
                            ? Container(
                                child: CarritoList(_showSnackBar, cartItems: cartItems, callbackUpdate: this.callbackUpdate, callbackForceUpdate: forceUpdate),
                              )
                            : Center(
                                child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(top: 125, bottom: 5),
                                    child: Image.asset(
                                      'assets/chedraui_family.png',
                                      width: 300,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 30, bottom: 20),
                                    child: Text("Tu carrito está vacío", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                                  ),
                                  Container(
                                      width: double.infinity,
                                      margin: EdgeInsets.symmetric(horizontal: 15),
                                      padding: const EdgeInsets.only(
                                        top: 10,
                                        bottom: 10,
                                      ),
                                      child: FlatButton(
                                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                                        padding: EdgeInsets.symmetric(vertical: 15),
                                        color: DataUI.btnbuy,
                                        textColor: DataUI.whiteText,
                                        onPressed: () async {
                                          Navigator.of(context).pushNamedAndRemoveUntil(DataUI.tiendaRoute, (Route<dynamic> route) => false);
                                        },
                                        child: Text("Compra ahora"),
                                      )),
                                ],
                              )))
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(100.0),
                              child: CircularProgressIndicator(value: null),
                            ),
                          );
                  } else {
                    return NetworkErrorPage(
                      errorMessage: 'Ha ocurrido un error, por favor inténtalo más tarde',
                      showGoHomeButton: true,
                    );
                  }
                  break;
                default:
                  return Container();
              }
            },
          ),
        ),
      ),
      bottomNavigationBar: cartItems.length > 0 && dataLoaded
          ? SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Container(
                //  color: Colors.red,
                // height: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(
                        top: 10,
                        left: 20,
                        right: 20,
                        bottom: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 6,
                                child: Text(
                                  'Subtotal',
                                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: DataUI.textOpaqueMedium),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                flex: 6,
                                child: Text(
                                  moneda.format(subtotal),
                                  textAlign: TextAlign.end,
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: DataUI.textOpaqueMedium),
                                ),
                              ),
                            ],
                          ),
                          discounts > 0
                              ? Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 6,
                                      child: Text(
                                        'en Chedraui Ahorras',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          color: DataUI.chedrauiColor,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 6,
                                      child: Text(
                                        discounts >= 0 ? '-' + moneda.format(discounts) : 'N/D',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: DataUI.chedrauiColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox(
                                  height: 0,
                                ),
                          delivery > 0
                              ? Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 6,
                                      child: Text(
                                        'Envío',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 6,
                                      child: Text(
                                        delivery >= 0 ? moneda.format(delivery) : 'N/D',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox(
                                  height: 0,
                                ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 7,
                                child: Text(
                                  'Total de tu pedido',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: DataUI.chedrauiBlueColor,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Text(
                                  moneda.format(total),
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: DataUI.chedrauiBlueColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    deltasAmount != null
                        ? Center(
                            child: Container(
                                margin: EdgeInsets.symmetric(vertical: 7),
                                width: 130,
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTap: () async {
                                    List noSuccessList = await processDeltas();
                                    if (noSuccessList.length > 0) {
                                      showDialogStock(noSuccessList);
                                    }
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      RefreshSVG(),
                                      Container(
                                        child: Text(
                                          'Actualizar carrito',
                                          style: TextStyle(
                                            color: HexColor('#0D47A1'),
                                            fontFamily: 'Archivo',
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          )
                        : _isLoggedIn
                            ? Container(
                                margin: EdgeInsets.symmetric(vertical: 7),
                                width: 130,
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTap: () async {
                                    createList();
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.add_circle_outline,
                                        color: HexColor('#0D47A1'),
                                      ),
                                      Container(
                                        child: Text(
                                          'Crear lista',
                                          style: TextStyle(
                                            color: HexColor('#0D47A1'),
                                            fontFamily: 'Archivo',
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            : SizedBox(),
                    Container(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: RaisedButton(
                              color: DataUI.chedrauiColor,
                              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5)),
                              child: Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                child: !loadingProducts
                                    ? Text(
                                        'Realizar Pedido',
                                        style: TextStyle(color: Colors.white, fontSize: 16),
                                      )
                                    : CircularProgressIndicator(
                                        valueColor: new AlwaysStoppedAnimation<Color>(DataUI.chedrauiBlueColor),
                                      ),
                              ),
                              onPressed: deltasAmount == null || loadingProducts
                                  ? () async {
                                      if (totalItems > 0) {
                                        SharedPreferences prefs = await SharedPreferences.getInstance();
                                        //final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
                                        final bool isLocationSet = prefs.getBool('isLocationSet') ?? false;
                                        //final String phone = prefs.getString('delivery-telefono');
                                        if (total < 200.00) {
                                          messageModal(context, 'El monto de compra debe ser mayor a \$200.00 MXN');
                                        } else {
                                          if (isLocationSet) {
                                            List noSuccessList = await processDeltas();
                                            if (noSuccessList != null && noSuccessList.length > 0) {
                                              showDialogStock(noSuccessList);
                                            } else {
                                              List resultCheckProducts = await checkRemovedProducts();
                                              if (resultCheckProducts.length > 0) {
                                                showDialogNoListedProducts();
                                                deltasAmount = resultCheckProducts;
                                                await processDeltas();
                                                setState(() {
                                                  loadingProducts = false;
                                                });
                                              } else {
                                                await FireBaseEventController.sendAnalyticsEventBeginCheckOut(cart);
                                                setState(() {
                                                  loadingProducts = false;
                                                });
                                                var checkoutResult = await Navigator.pushNamed(context, DataUI.checkoutRoute);
                                                if (checkoutResult == 'bounce') {
                                                  await Navigator.pushNamed(context, DataUI.checkoutRoute);
                                                }
                                                setState(() {
                                                  deltasAmount = [];
                                                });
                                              }
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //     builder: (context) => CheckoutPage(),
                                              //   ),
                                              // );
                                            }
                                          } else {
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text("Hace falta ubicación"),
                                                    content: Text("Elige una ubicación de entrega o bien una tienda Chedraui donde recoger tu pedido."),
                                                    actions: <Widget>[
                                                      FlatButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                        child: Text(
                                                          "Cerrar",
                                                          style: TextStyle(
                                                            color: DataUI.chedrauiBlueColor,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                      FlatButton(
                                                        onPressed: () async {
                                                          Navigator.pop(context);
                                                          await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              settings: RouteSettings(name: DataUI.deliveryMethodRoute),
                                                              builder: (context) => DeliveryMethodPage(
                                                                showStores: false,
                                                                showConfirmationForm: false,
                                                              ),
                                                            ),
                                                          );
                                                          setState(() {
                                                            deltasAmount = [];
                                                          });
                                                          // getCarrito();
                                                        },
                                                        child: Text(
                                                          "Asignar ubicación",
                                                          style: TextStyle(
                                                            color: DataUI.chedrauiBlueColor,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                });
                                          }
                                        }
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text("No hay productos en tu carrito"),
                                              content: Text('Por favor agrega productos para realizar tu compra'),
                                              actions: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 8),
                                                  child: FlatButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                      "Cerrar",
                                                      style: TextStyle(
                                                        color: DataUI.chedrauiBlueColor,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // Padding(
                                                //   padding:
                                                //       const EdgeInsets.only(left: 8),
                                                //   child: RaisedButton(
                                                //     color: DataUI.chedrauiBlueColor,
                                                //     onPressed: () {
                                                //       Navigator.pop(context);
                                                //       Navigator.pushNamed(context, '/Tienda');
                                                //     },
                                                //     child: Text(
                                                //       "Buscar productos",
                                                //       style: TextStyle(
                                                //         color: Colors.white,
                                                //         fontSize: 16,
                                                //       ),
                                                //     ),
                                                //   ),
                                                // )
                                              ],
                                            );
                                          },
                                        );
                                      }
                                      //     }
                                      //   },
                                      // );

                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //       builder: (context) => {return CheckoutPage();}),
                                      // );
                                    }
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SizedBox(),
    );
  }
}

void messageModal(BuildContext context, String message) {
  var alertDialog = AlertDialog(
    title: Center(
      child: Text('Error al procesar la compra'),
    ),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Text(
            message,
            textAlign: TextAlign.center,
          ),
        )
      ],
    ),
    actions: <Widget>[
      FlatButton(
        onPressed: () => Navigator.pop(context),
        child: Text(
          "Aceptar",
          style: TextStyle(
            color: DataUI.chedrauiBlueColor,
            fontSize: 16,
          ),
        ),
      ),
    ],
  );

  showDialog(context: context, barrierDismissible: true, builder: (BuildContext context) => alertDialog);
}
