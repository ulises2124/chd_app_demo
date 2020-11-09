import 'dart:collection';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chd_app_demo/services/CarritoServices.dart';
import 'package:chd_app_demo/services/ArticulosServices.dart';
import 'package:chd_app_demo/services/FireBaseServices.dart';
import 'package:chd_app_demo/services/ListasServices.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/utils/NetworkData.dart';
import 'package:chd_app_demo/views/CategoryPage/CategoryMenu.dart';
import 'package:chd_app_demo/views/Errors/NetworkErrorPage/NetworkErrorPage.dart';
import 'package:chd_app_demo/views/ListasPage/ListaNew.dart';
import 'package:chd_app_demo/views/ProductsPage/ProductsPage.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';
import 'package:chd_app_demo/widgets/footerNavigation.dart';
import 'package:chd_app_demo/widgets/notSignedIn.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:chd_app_demo/views/DeliveryMethod/DeliveryMethodPage.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chd_app_demo/widgets/expansionTileCustom.dart' as custom;
// import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:chd_app_demo/redux/models/AppState.dart';
import 'package:chd_app_demo/redux/actions/ShoppingCartsActions.dart';

String productName = '';
String productId = '';
String productCategories = '';
double productPrice = 0.0;

class ProductPage extends StatefulWidget {
  dynamic data;
  String code;
  ProductPage({Key key, this.data, this.code}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool checkedValue = false;

  var product;
  final formatter = new NumberFormat("###,###,###,###.00");
  int _current = 0;
  String urlShare;
  List<dynamic> promos = new List();

  List<String> imgList = new List();
  List<String> promosList = new List();
  List<String> promosImageList = new List();
  List<dynamic> caracteristicas = new List();
  List producReference;
  final Widget placeholder = Container(color: Colors.grey);
  SharedPreferences prefs;
  bool _isLoggedIn = false;
  Future productResponse;
  @override
  Future getPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  void initState() {
    productResponse = searchProduct();
    getPreferences().then((x) {
      setState(() {
         prefs.clear();
        _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      });
    });
    super.initState();
    searchProduct();
  }

  Future searchProduct() async {
    if (widget.data != null) {
      setState(() {
        product = widget.data;
        if (product != null) {
          productId = product['code'];
          productName = product['name'];
          productPrice = product['price']['value'];
          if (product['categories'] != null) {
            productCategories = product['categories'][0]['url'] ?? '';
            productCategories = Uri.decodeFull(productCategories) ?? '';
          }
          FireBaseEventController.sendAnalyticsEventViewItem(productId, productName, productCategories).then((ok) {});
          //urlShare = product['url'];
          producReference = product['productReferences'];
          if (product['images'] != null) {
            for (dynamic image in (product["images"] ?? [])) {
              //print(image);
              if (image["format"].toString().toLowerCase().contains("product")) {
                if (!imgList.contains(NetworkData.hybrisBaseUrl + image["url"])) {
                  imgList.add(NetworkData.hybrisBaseUrl + image["url"]);
                }
              }
            }
          }
          for (dynamic promos in (product["potentialPromotions"] ?? [])) {
            if (!promosList.contains(promos["description"])) {
              promosList.add(promos["description"]);
              //promosImageList.add(NetworkData.hybrisProd+promos["productBanner"]["url"]);
            }
          }
          if (product["classifications"] != null)
            for (dynamic features in (product["classifications"] ?? [])) {
              for (dynamic feature in (features["features"] ?? [])) {
                caracteristicas.add(feature /*classifications["name"]+" "+classifications["featureValues"][0]["value"] + " "+ (classifications['featureUnit']!=null?classifications['featureUnit']['symbol']:"")*/);
              }
            }
        } else {
          imgList.add(NetworkData.hybrisBaseUrl + product['images'][0]['url']);
        }
      });
      await searchUrlShare();
      return product;
    } else if (widget.code != null) {
      await ArticulosServices.getProductHybrisSearch(widget.code).then((productData) async {
        if (productData == null) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Producto no encontrado"),
                  content: Text("Lo sentimos, hay un problema con el producto seleccionado."),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Regresar",
                        style: TextStyle(
                          color: DataUI.chedrauiBlueColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                );
              });
        } else {
          setState(() {
            product = productData;
            if (product != null) {
              productId = product['code'];
              productName = product['name'];
              productPrice = product['price']['value'];
              List categoryAux = product['categories'];
              if (categoryAux != null && categoryAux.length > 0) {
                productCategories = product['categories'][0]['url'] ?? '';
               if(productCategories != null && productCategories != '') productCategories = Uri.decodeFull(productCategories) ?? '';
              }
              FireBaseEventController.sendAnalyticsEventViewItem(productId, productName, productCategories).then((ok) {});
              //urlShare = product['url'];
              producReference = product['productReferences'];
              if (product['images'] != null) {
                for (dynamic image in (product["images"] ?? [])) {
                  //print(image);
                  if (image["format"].toString().toLowerCase().contains("product")) {
                    if (!imgList.contains(NetworkData.hybrisBaseUrl + image["url"])) {
                      imgList.add(NetworkData.hybrisBaseUrl + image["url"]);
                    }
                  }
                }
              }
              for (dynamic promos in (product["potentialPromotions"] ?? [])) {
                if (!promosList.contains(promos["description"])) {
                  promosList.add(promos["description"]);
                  //promosImageList.add(NetworkData.hybrisProd+promos["productBanner"]["url"]);
                }
              }
              if (product["classifications"] != null)
                for (dynamic features in (product["classifications"] ?? [])) {
                  for (dynamic feature in (features["features"] ?? [])) {
                    caracteristicas.add(feature /*classifications["name"]+" "+classifications["featureValues"][0]["value"] + " "+ (classifications['featureUnit']!=null?classifications['featureUnit']['symbol']:"")*/);
                  }
                }
            } else {
              imgList.add(NetworkData.hybrisBaseUrl + product['images'][0]['url']);
            }
          });
          await searchUrlShare();
        }
      });
      return product;
    }
  }

  searchUrlShare() {
    if (widget.data != null && widget.code == null) {
      var url = widget.data['code'] + '&pageSize=1&fields=FULL';
      ArticulosServices.getProductsHybrisSearch(url).then(
        (products) {
          if (products != null) {
            setState(() {
              urlShare = products['products'][0]['url'];
            });
          }
        },
      );
    } else {
      var url = widget.code + '&pageSize=1&fields=FULL';
      ArticulosServices.getProductsHybrisSearch(url).then(
        (products) {
          if (products != null) {
            setState(() {
              urlShare = products['products'][0]['url'];
            });
          }
        },
      );
    }
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  showList() async {
    var ss = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return ProductToList(upc: product['code']);
        });
    print(ss);
    if (ss != null) {
      if (ss != 'error') {
        Flushbar(
          message: "El producto se agrego correctamente a la lista $ss",
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
        ss = null;
      } else {
        Flushbar(
          message: "No es posible agregar $widget.data['name']",
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
        ss = null;
      }
      ss = null;
    } else {
      ss = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WidgetContainer(
      Scaffold(
        backgroundColor: HexColor('#F0EFF4'),
        body: Scaffold(
          key: _scaffoldKey,
          appBar: GradientAppBar(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                HexColor('#F56D00'),
                HexColor('#F56D00'),
                HexColor('#F78E00'),
              ],
            ),
            elevation: 0,
            title: Text('Detalles del Artículo', style: TextStyle(color: Colors.white, fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 19)),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.share,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (urlShare != null) {
                    var newUrl = 'https://www.chedraui.com.mx' + urlShare;
                    Share.share('¡Te recomiendo este producto y descubre que en Chedraui cuesta menos! $newUrl');
                  } else {
                    Flushbar(
                      message: "Ha ocurrido un error, por favor intente de nuevo.",
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
                },
              ),
            ],
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                );
              },
            ),
            // toolbarOpacity: 0.0,
          ),
          backgroundColor: HexColor('#F0EFF4'),
          body: FutureBuilder(
            future: productResponse,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                  break;
                case ConnectionState.active:
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                  break;
                case ConnectionState.none:
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
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
                    return CategoryMenu(
                      currentWidget: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                        child: product != null && product['unit'] != null
                            ? SingleChildScrollView(
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.only(left: 15, right: 15),
                                            margin: EdgeInsets.only(top: 5, bottom: 3),
                                            child: Text(
                                              product["name"] ?? "",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(fontFamily: "Archivo", fontSize: 20, fontWeight: FontWeight.bold, color: HexColor('#0D47A1')),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(left: 15, right: 15),
                                            // alignment: Alignment.centerLeft,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  margin: EdgeInsets.only(bottom: 5),
                                                  child: Text(
                                                    product['strikeThroughPriceValue'] != null ? "Precio Original: \$ " + formatter.format(double.parse(product['strikeThroughPriceValue']["value"] != null ? product['strikeThroughPriceValue']["value"].toStringAsFixed(2) : product['strikeThroughPriceValue'].toStringAsFixed(2))) + " " + product['price']['currencyIso'] : "",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      fontFamily: "Archivo",
                                                      fontSize: product['strikeThroughPriceValue'] != null ? 12 : 0,
                                                      fontWeight: FontWeight.normal,
                                                      letterSpacing: 0.4,
                                                      color: HexColor("#637381"),
                                                    ),
                                                  ),
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                    text: product['price']['formattedValue'] + (product['unit']['code'].toString().contains("K") ? "/Kg" : " " + product['price']['currencyIso'].toString()),
                                                    style: TextStyle(
                                                      fontFamily: "Archivo",
                                                      fontSize: 30,
                                                      fontWeight: FontWeight.bold,
                                                      color: HexColor('#F56D00'),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Stack(
                                                  children: <Widget>[
                                                    product['images'] == null
                                                        ? Center(
                                                            child: Column(
                                                              children: <Widget>[
                                                                Container(
                                                                  margin: EdgeInsets.only(top: 40),
                                                                  height: 130,
                                                                  child: Image.asset('assets/chd_logo.png'),
                                                                ),
                                                                Text('Imagen no disponible')
                                                              ],
                                                            ),
                                                          )
                                                        : imgList.length > 0
                                                            ? CarouselSlider(
                                                                options: CarouselOptions(
                                                                  height: 290.0,
                                                                  aspectRatio: 1.0,
                                                                  autoPlay: false,
                                                                  viewportFraction: 1.0,
                                                                  onPageChanged: (index, e) {
                                                                    setState(
                                                                      () {
                                                                        _current = index;
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                                items: map<Widget>(
                                                                  imgList,
                                                                  (index, i) {
                                                                    return Container(
                                                                      margin: EdgeInsets.all(5.0),
                                                                      child: ClipRRect(
                                                                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                                        child: Stack(children: <Widget>[
                                                                          Image.network(i, fit: BoxFit.fitWidth),
                                                                        ]),
                                                                      ),
                                                                    );
                                                                  },
                                                                ).toList(),
                                                              )
                                                            : Center(
                                                                child: Column(
                                                                  children: <Widget>[
                                                                    Container(
                                                                      margin: EdgeInsets.only(top: 40),
                                                                      height: 130,
                                                                      child: Image.asset('assets/chd_logo.png'),
                                                                    ),
                                                                    Text('Imagen no disponible')
                                                                  ],
                                                                ),
                                                              ),
                                                    PromosProductSingle(data: product),
                                                    Positioned(
                                                      bottom: 0,
                                                      right: 0,
                                                      child: IconButton(
                                                        icon: Icon(Icons.add_circle_outline, color: HexColor('#0DA136')),
                                                        onPressed: () {
                                                          if (_isLoggedIn == true) {
                                                            showList();
                                                          } else {
                                                            showDialog(
                                                              context: context,
                                                              barrierDismissible: true,
                                                              builder: (BuildContext context) {
                                                                return AlertDialog(
                                                                  title: Text('Agregar a lista'),
                                                                  content: Container(
                                                                    height: MediaQuery.of(context).size.width < 350 ? MediaQuery.of(context).size.width * 1.0 : MediaQuery.of(context).size.width * 0.80,
                                                                    child: NotSignedInWidget(
                                                                      message: 'Para poder visualizar o crear tus listas de compras, por favor inicia sesión y disfruta de todos los beneficios de la nueva tienda Chedraui',
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                            height: 290,
                                            margin: EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8.0),
                                              boxShadow: <BoxShadow>[
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.15),
                                                  offset: Offset(2.0, 5.0),
                                                  blurRadius: 12.0,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: map<Widget>(
                                              imgList,
                                              (index, url) {
                                                return Container(
                                                  width: _current == index ? 17 : 5,
                                                  height: 5.0,
                                                  margin: EdgeInsets.symmetric(horizontal: 2.0),
                                                  decoration: BoxDecoration(
                                                    shape: _current == index ? BoxShape.rectangle : BoxShape.circle,
                                                    borderRadius: _current == index ? BorderRadius.circular(10) : null,
                                                    color: _current == index ? HexColor("#F57C00") : HexColor("#F57C00").withOpacity(0.5),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),

                                          /* Divider(
                              color: HexColor("#DFE3E8"),
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 15, left: 15),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    child: Icon(Icons.local_shipping),
                                  ),
                                  Container(
                                      margin:
                                          EdgeInsets.only(right: 15, left: 15),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "Envío el mismo día",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontFamily: "Rubik",
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                              color: HexColor("#212B36"),
                                            ),
                                          ),
                                          Text(
                                            "Comprando antes de las 6:59 pm.",
                                            style: TextStyle(
                                              fontFamily: "Rubik",
                                              fontSize: 11,
                                              fontWeight: FontWeight.normal,
                                              color: HexColor("#637381"),
                                            ),
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                            ), */
                                          SizedBox(
                                            height: 10,
                                          ),
                                          product['summary'] == null || product['summary'] == ""
                                              ? SizedBox()
                                              : Container(
                                                  child: custom.ExpansionTile(
                                                    backgroundColor: HexColor('#F0EFF4'),
                                                    headerBackgroundColor: HexColor('#F0EFF4'),
                                                    initiallyExpanded: true,
                                                    title: Text(
                                                      "Descripción",
                                                      style: TextStyle(
                                                        fontFamily: "Rubik",
                                                        fontSize: 19,
                                                      ),
                                                    ),
                                                    children: <Widget>[
                                                      Container(
                                                        padding: EdgeInsets.only(right: 15, left: 15, bottom: 15),
                                                        child: Html(defaultTextStyle: TextStyle(fontFamily: "Rubik", fontSize: 14, fontWeight: FontWeight.normal, color: HexColor("#637381"), height: 1.3), data: product['summary']),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                          product['description'] == null || product['description'] == ""
                                              ? SizedBox()
                                              : Container(
                                                  child: custom.ExpansionTile(
                                                    backgroundColor: HexColor('#F0EFF4'),
                                                    headerBackgroundColor: HexColor('#F0EFF4'),
                                                    initiallyExpanded: true,
                                                    title: Text(
                                                      "Acerca del Producto",
                                                      style: TextStyle(
                                                        fontFamily: "Rubik",
                                                        fontSize: 19,
                                                      ),
                                                    ),
                                                    children: <Widget>[
                                                      Container(
                                                        padding: EdgeInsets.only(right: 15, left: 15, bottom: 15),
                                                        child: Html(defaultTextStyle: TextStyle(fontFamily: "Rubik", fontSize: 14, fontWeight: FontWeight.normal, color: HexColor("#637381"), height: 1.3), data: "UPC: " + product['sapEAN'] + "<br/><br/>" + product['description']),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                          caracteristicas.length > 0 ? SizedBox() : Container(),
                                          caracteristicas.length == 0
                                              ? Container()
                                              : Container(
                                                  child: custom.ExpansionTile(
                                                    backgroundColor: HexColor('#F0EFF4'),
                                                    headerBackgroundColor: HexColor('#F0EFF4'),
                                                    title: Text(
                                                      "Especificaciones",
                                                      style: TextStyle(
                                                        fontFamily: "Work Sans",
                                                        fontSize: 19,
                                                      ),
                                                    ),
                                                    children: <Widget>[
                                                      Container(
                                                        padding: EdgeInsets.only(right: 15, left: 15, bottom: 15),
                                                        child: Column(
                                                          children: caracteristicas.map(
                                                            (element) {
                                                              var text2 = element['featureUnit'] != null ? element['featureUnit']['symbol'] : "";
                                                              var text = element["featureValues"][0]["value"];
                                                              return Container(
                                                                padding: EdgeInsets.only(right: 15, left: 15),
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: <Widget>[
                                                                    RichText(
                                                                      text: new TextSpan(
                                                                        children: <TextSpan>[
                                                                          new TextSpan(
                                                                            text: element["name"].toString() + " ",
                                                                            style: TextStyle(
                                                                              fontFamily: "Rubik",
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.w500,
                                                                              color: HexColor("#637381"),
                                                                            ),
                                                                          ),
                                                                          new TextSpan(
                                                                            text: '$text $text2',
                                                                            style: TextStyle(
                                                                              fontFamily: "Rubik",
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.normal,
                                                                              color: HexColor("#637381"),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Divider(
                                                                      color: HexColor("#DFE3E8"),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          ).toList(),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                          promosList.length > 0 ? SizedBox() : Container(),
                                          promosList.length > 0
                                              ? Container(
                                                  padding: EdgeInsets.only(right: 15, left: 15),
                                                  child: Text(
                                                    "Promociones asociadas",
                                                    style: TextStyle(color: HexColor('#212B36'), fontFamily: 'Archivo', fontWeight: FontWeight.w600, fontSize: 16),
                                                  ),
                                                )
                                              : Container(),
                                          promosList.length > 0
                                              ? Container(
                                                  child: ListTile(
                                                    title: Container(
                                                      child: Column(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                        Column(
                                                            children: promosList
                                                                .map((element) => Container(
                                                                      child: Column(
                                                                        children: <Widget>[
                                                                          Container(
                                                                              height: 70,
                                                                              width: double.infinity,
                                                                              decoration: BoxDecoration(border: Border.all(color: HexColor('#0D47A1'), width: 2)),
                                                                              child: Row(
                                                                                children: <Widget>[
                                                                                  Expanded(
                                                                                      flex: 1,
                                                                                      child: Icon(
                                                                                        Icons.check_box,
                                                                                        color: HexColor('#0D47A1'),
                                                                                      )),
                                                                                  Expanded(
                                                                                    flex: 8,
                                                                                    child: Text(
                                                                                      element,
                                                                                      textAlign: TextAlign.left,
                                                                                      style: TextStyle(
                                                                                        fontFamily: "Archivo",
                                                                                        fontSize: 14,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        color: HexColor("#0D47A1"),
                                                                                      ),
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              ))
                                                                        ],
                                                                      ),
                                                                    ))
                                                                .toList()),
                                                      ]),
                                                    ), //    <-- label
                                                  ),
                                                )
                                              : Container(),
                                          producReference != null
                                              ? producReference.length > 0
                                                  ? Container(
                                                      height: 310,
                                                      child: ProductsSlider2(
                                                        title: "También te puede gustar...",
                                                        productReferences: product['productReferences'],
                                                      ),
                                                    )
                                                  : SizedBox()
                                              : SizedBox(),
                                          SizedBox(
                                            height: 50,
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(100.0),
                                  child: CircularProgressIndicator(value: null),
                                ),
                              ),
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
          bottomNavigationBar: product != null
              ? BuyProduct(
                  product: product,
                )
              : SizedBox(),
          //bottomNavigationBar: MyApp(),
        ),
        bottomNavigationBar: FooterNavigation(
          (val) {},
          mainNavigation: false,
        ),
        resizeToAvoidBottomInset: true,
      ),
    );
  }
}

class BuyProduct extends StatefulWidget {
  final dynamic product;
  BuyProduct({Key key, this.product}) : super(key: key);
  _BuyProductState createState() => _BuyProductState();
}

class _BuyProductState extends State<BuyProduct> {
  num value;
  String code;
  String name;
  String conversion;
  String pesable;
  var weightPerAltSalesUnit;

  String wCode;
  String wName;
  String wConversion;

  String minOrderQuantity;
  String factorConversion;
  String incremento;
  num cartQty;
  bool withUnitEquivalence;
  String unit;
  final note = TextEditingController();
  dynamic weigthweightPerAltSalesUnit;
  dynamic total;
  dynamic newTotal = 0;
  NumberFormat moneda = new NumberFormat.currency(locale: 'es_MX', symbol: "\$");
  String label;
  String notasEntrega = '';
  bool toggle = false;
  bool processingBuy = false;
  bool open = false;

  @override
  void initState() {
    super.initState();
    setUp();
  }

  setUp() {
    notasEntrega = "";

    code = widget.product["unit"]["code"];
    name = widget.product["unit"]["name"];
    conversion = widget.product["unit"]["conversion"] != null ? widget.product["unit"]["conversion"].toString() : "100";
    total = widget.product["price"]["value"];
    newTotal = widget.product["price"]["value"];
    if (code != null && code.toUpperCase().contains("KGM")) {
      pesable = "1";
    } else {
      pesable = "0";
    }

    weigthweightPerAltSalesUnit = widget.product["weightPerAltSalesUnit"];

    if (weigthweightPerAltSalesUnit != null) {
      minOrderQuantity = weigthweightPerAltSalesUnit["conversion"].toString() != null ? weigthweightPerAltSalesUnit["conversion"].toString() : "0.1";
      factorConversion = weigthweightPerAltSalesUnit["conversion"].toString() != null ? weigthweightPerAltSalesUnit["conversion"].toString() : "0.1";
      this.incremento = weigthweightPerAltSalesUnit["conversion"].toString() != null ? weigthweightPerAltSalesUnit["conversion"].toString() : "0.1";
      this.withUnitEquivalence = true;
    } else if (widget.product["minOrderQuantity"] != null) {
      String minOrder = widget.product["minOrderQuantity"] != null ? widget.product["minOrderQuantity"].toString() : "0.1";
      double minOrderParse = double.parse(minOrder);
      double pesoUnitario = double.parse(this.conversion);
      double adjust = pesoUnitario <= 0 ? 0 : minOrderParse / pesoUnitario;
      this.minOrderQuantity = minOrder.contains(".") ? minOrder : adjust.toString();
      this.factorConversion = minOrder.contains(".") ? minOrder : adjust.toString();
      this.incremento = minOrder.contains(".") ? minOrder : adjust.toString();
      this.withUnitEquivalence = false;
    } else {
      this.minOrderQuantity = this.pesable == "1" ? "0.1" : "1";
      this.factorConversion = this.pesable == "1" ? "0.1" : "1";
      this.incremento = this.pesable == "1" ? "0.05" : "1";
      this.withUnitEquivalence = this.pesable == "1" ? false : true;
    }
    print("incremento------------> " + incremento);
    print("minOrderQuantity------> " + minOrderQuantity);
    print("factorConversion------> " + factorConversion);
    print("withUnitEquivalence---> " + withUnitEquivalence.toString());

    cartQty = double.parse(minOrderQuantity);
    unit = pesable.contains("1") ? "kg" : "pza";
    label = cartQty.toString() + " " + unit;
  }

  instrucciones() {
    return Theme(
      data: ThemeData(
        primaryColor: Colors.transparent,
        hintColor: Colors.transparent, // p
      ),
      child: GestureDetector(
        onTap: () {
          setState(() {
            open = !open;
          });
        },
        child: AnimatedContainer(
          margin: EdgeInsets.only(top: 8),
          duration: new Duration(milliseconds: 300),
          height: !open ? 23 : 131,
          color: HexColor('#F9FAFB'),
          child: Column(
            children: <Widget>[
              Center(
                child: Text(
                  notasEntrega.length > 0 ? "Editar nota" : "Agregar nota",
                  style: TextStyle(fontFamily: "Archivo", fontSize: 12, fontWeight: FontWeight.normal, color: HexColor("#0D47A1"), height: 1.3),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10, right: 15, left: 15),
                child: TextField(
                  controller: note,
                  onSubmitted: (value) {
                    setState(() {
                      open = !open;
                    });
                  },
                  onChanged: (text) {
                    this.notasEntrega = text;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: HexColor('#F0EFF4'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                    hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                  style: TextStyle(fontFamily: "Rubik", fontSize: 16, fontWeight: FontWeight.normal, color: HexColor("#0D47A1"), height: 1.3),
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 15, left: 15, top: 7),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        flex: 8,
                        child: FlatButton(
                          color: HexColor("#F57C00"),
                          onPressed: () {
                            setState(() {
                              open = !open;
                              this.notasEntrega = note.text;
                            });
                          },
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Text(
                            "Guardar nota",
                            style: TextStyle(fontFamily: "Archivo", fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white, height: 1.3),
                          ),
                        )),
                    Expanded(
                      flex: 1,
                      child: SizedBox(),
                    ),
                    Expanded(
                      flex: 8,
                      child: OutlineButton(
                        color: HexColor("#0D47A1"),
                        borderSide: BorderSide(color: HexColor("#0D47A1")),
                        onPressed: () {
                          setState(() {
                            open = !open;
                            note.text = '';
                            notasEntrega = '';
                          });
                        },
                        child: Text(
                          "Cancelar",
                          style: TextStyle(fontFamily: "Archivo", fontSize: 12, fontWeight: FontWeight.normal, color: HexColor("#0D47A1"), height: 1.3),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buy() {
    processBuy() async {
      setState(() {
        processingBuy = true;
      });
      String productCode = widget.product['code'];
      bool isRestricted = widget.product['restricted'] ?? false;
      var result;
      try {
        result = await CarritoServices.addEntryToCart(productCode.toString(), cartQty, isRestricted);
      } catch (e) {
        setState(() {
          processingBuy = false;
        });
        Flushbar(
          message: "Hubo un problema al agregar el producto al carrito [SERVER ERROR].",
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
        return;
      }
      if (result != null) {
        if (result['err'] == null) {
          List cartModifications = result['cartModifications'];
          if (cartModifications != null) {
            if (cartModifications.length > 0) {
              var statusCode = cartModifications[0]['statusCode'];
              switch (statusCode) {
                case "noStock":
                  Flushbar(
                    message: "No hay stock del producto en este momento.",
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
                  setState(() {
                    processingBuy = false;
                  });
                  break;
                case "maxOrderQuantityExceeded":
                  Flushbar(
                    message: "Máxima cantidad de este producto alcanzada.",
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
                  setState(() {
                    processingBuy = false;
                  });
                  break;
                case "lowStock":
                case "success":
                  await FireBaseEventController.sendAnalyticsEventAddToCart(
                    cartQty,
                    productName,
                    productCategories,
                    productId,
                    productPrice,
                  );
                  print(result.toString());
                  try {
                    final carrito = await CarritoServices.getCart();
                    final itemsQty = carrito['totalItems'];
                    final store = StoreProvider.of<AppState>(context);
                    store.dispatch(SetShoppingItems(itemsQty));
                  } catch (e) {
                    print(e.toString());
                  }
                  setState(() {
                    processingBuy = false;
                  });
                  Flushbar(
                    message: "Producto agregado al carrito exitosamente.",
                    backgroundColor: HexColor('#39B54A'),
                    flushbarPosition: FlushbarPosition.TOP,
                    flushbarStyle: FlushbarStyle.FLOATING,
                    margin: EdgeInsets.all(8),
                    borderRadius: 8,
                    mainButton: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Volver",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    icon: Icon(
                      Icons.check_circle_outline,
                      size: 28.0,
                      color: Colors.white,
                    ),
                    duration: Duration(seconds: 5),
                  )..show(context);
                  break;
                default:
                  setState(() {
                    processingBuy = false;
                  });
                  Flushbar(
                    message: "Hubo un problema al agregar el producto al carrito [$statusCode].",
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
            } else {
              setState(() {
                processingBuy = false;
              });
              print(result);
              Flushbar(
                message: "Hubo un problema al agregar el producto al carrito [SERVER ERROR].",
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
          } else {
            setState(() {
              processingBuy = false;
            });
            print(result);
            Flushbar(
              message: "Hubo un problema al agregar el producto al carrito [SERVER ERROR].",
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
        } else if (result['err'] != null) {
          switch (result['err']) {
            case "NO_LOCATION_IS_SET":
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("No has ingresado tu ubicación."),
                      content: Text("Debes elegir una ubicación de entrega, o bien seleccionar una tienda donde recoger tu pedido."),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () {
                            setState(() {
                              processingBuy = false;
                            });
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Cancelar",
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
                            await processBuy();
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
              break;
            default:
              setState(() {
                processingBuy = false;
              });
              Flushbar(
                message: "Hubo un problema al agregar el producto al carrito [${result['err']}].",
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
              break;
          }
        } else {
          setState(() {
            processingBuy = false;
          });
          List errorsList = result['errors'] ?? [];
          String errMsg = "";
          if (errorsList.length > 0) {
            List errListStr = [];
            errorsList.forEach((e) {
              errListStr.add(e['message']);
            });
            errMsg = errListStr.join(', ');
          } else {
            errMsg = "Error desconocido.";
          }
          Flushbar(
            message: "Hubo un problema al agregar el producto al carrito [$errMsg].",
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
      } else {
        setState(() {
          processingBuy = false;
        });
        Flushbar(
          message: "Hubo un problema al agregar el producto al carrito [SERVER ERROR].",
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
    }

    return Container(
        width: 130,
        child: !processingBuy
            ? FlatButton(
                color: HexColor("#F57C00"),
                onPressed: processBuy,
                padding: EdgeInsets.symmetric(horizontal: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Text(
                  "Agregar a carrito",
                  style: TextStyle(color: Colors.white, fontFamily: "Rubik", fontWeight: FontWeight.normal, fontSize: 13),
                ),
              )
            : FlatButton(
                color: HexColor("#F9FAFB"),
                onPressed: () {},
                child: CircularProgressIndicator(),
              ));
  }

  _selectOptions() {
    List<Widget> options = [];
    if (pesable == "1") {
      options.add(Container(
        width: 70,
        child: FlatButton.icon(
          onPressed: () {
            setState(() {
              unit = "kg";
              print(minOrderQuantity.toString() + "-" + cartQty.toString());
              if (num.parse(minOrderQuantity) > cartQty) {
                label = (cartQty * num.parse(factorConversion)).toString() + " " + unit;
              } else {
                label = cartQty.toString() + " " + unit;
              }
            });
          },
          icon: Icon(
            Icons.line_weight,
            size: 1,
          ),
          label: Text(
            'Peso',
            style: TextStyle(fontFamily: "Rubik", fontSize: 10.5, fontWeight: FontWeight.normal, color: HexColor("#2E384D"), height: 1.3),
          ),
        ),
      ));
    } else {
      options.add(Container(
        width: 70,
        child: FlatButton.icon(
          onPressed: () {
            setState(() {
              unit = "pza";
              if (minOrderQuantity == cartQty) {
                label = cartQty.toString() + " " + unit;
              } else {
                label = (cartQty / num.parse(factorConversion)).toString() + " " + unit;
              }
            });
          },
          icon: Icon(
            Icons.ac_unit,
            size: 1,
          ),
          label: Text(
            'Pieza',
            style: TextStyle(fontFamily: "Rubik", fontSize: 10.5, fontWeight: FontWeight.normal, color: HexColor("#2E384D"), height: 1.3),
          ),
        ),
      ));
    }
    return options;
  }

  toggleButton() {
    return Container(
      color: HexColor('#F9FAFB'),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  setState(() {
                    toggle = !toggle;
                  });
                },
                child: Opacity(
                  opacity: toggle ? 0.5 : 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 5.0, color: toggle ? Colors.transparent : HexColor('#F56D00')),
                      ),
                    ),
                    padding: EdgeInsets.all(7.5),
                    // decoration: BoxDecoration(),
                    child: Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 3),
                          child: Image.asset(
                            'assets/kgIcon.png',
                            height: 18,
                          ),
                        ),
                        Container(
                          child: Text(
                            'Peso',
                            style: TextStyle(color: HexColor('#454F5B'), fontFamily: 'Archivo', fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    toggle = !toggle;
                  });
                },
                child: Opacity(
                  opacity: !toggle ? 0.5 : 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 5.0, color: !toggle ? Colors.transparent : HexColor('#F56D00')),
                      ),
                    ),
                    padding: EdgeInsets.all(7.5),
                    // decoration: BoxDecoration(),
                    child: Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 3),
                          child: LemonSvg(),
                        ),
                        Container(
                          child: Text(
                            'Pieza',
                            style: TextStyle(color: HexColor('#454F5B'), fontFamily: 'Archivo', fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // print("withUnitEquivalence1---->" + withUnitEquivalence.toString());
    // print("pesable1---->" + pesable.toString());
    // print("unit code---->" + widget.product["unit"]["code"].toString());
    final formatter = new NumberFormat("######.###");

    if (!withUnitEquivalence && widget.product["unit"]["code"].toString().contains("KGM")) {
      return Container(
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0xcc000000).withOpacity(0.2),
              offset: Offset(5.0, 0.0),
              blurRadius: 12.0,
            ),
          ],
          color: HexColor('#F9FAFB'),
          borderRadius: new BorderRadius.only(topLeft: const Radius.circular(20.0), topRight: const Radius.circular(20.0)),
        ),
        //padding: EdgeInsets.only(right: 15, left: 15),
        child: CupertinoActionSheet(
          actions: <Widget>[
            Container(
              width: 10,
              height: 10,
              color: HexColor('#F9FAFB'),
            ),
            //this.toggleButton(),
            //!toggle ?
            Container(
              color: HexColor('#F9FAFB'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 36,
                    margin: EdgeInsets.only(right: 10, left: 5),
                    decoration: BoxDecoration(color: Colors.white, border: Border.all(width: 1, color: HexColor('#C4CDD5')), borderRadius: BorderRadius.circular(5)),
                    child: Row(
                      children: <Widget>[
                        IconButton(
                            icon: Icon(
                              Icons.remove,
                              size: 20,
                            ),
                            onPressed: () {
                              num newcartQty = cartQty - num.parse(incremento);
                              setState(() {
                                if (newcartQty >= num.parse(minOrderQuantity)) {
                                  cartQty = num.parse(newcartQty.toStringAsFixed(2));
                                  newTotal = total * cartQty;
                                }
                              });
                            }),
                        Text(
                          num.parse(cartQty.toStringAsFixed(2)).toString() + " kg",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: "Rubik", fontSize: 16, fontWeight: FontWeight.normal, color: HexColor("#637381"), height: 1.3),
                        ),
                        IconButton(
                            icon: Icon(Icons.add, size: 20),
                            onPressed: () {
                              num newcartQty = cartQty + num.parse(incremento);
                              setState(() {
                                cartQty = num.parse(newcartQty.toStringAsFixed(2));
                                newTotal = total * cartQty;
                              });
                            }),
                      ],
                    ),
                  ),
                  Expanded(
                    child: this.buy(),
                  )
                ],
              ),
            )
            /*
                : Container(
                    color: HexColor('#F9FAFB'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: 36,
                          margin: EdgeInsets.only(right: 10, left: 5),
                          decoration: BoxDecoration(color: Colors.white, border: Border.all(width: 1, color: HexColor('#C4CDD5')), borderRadius: BorderRadius.circular(5)),
                          child: Row(
                            children: <Widget>[
                              IconButton(
                                  icon: Icon(
                                    Icons.remove,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    num newcartQty = cartQty - num.parse(incremento);
                                    setState(() {
                                      if (newcartQty >= num.parse(minOrderQuantity)) {
                                        cartQty = num.parse(newcartQty.toStringAsFixed(2));
                                        newTotal = total * cartQty;
                                      }
                                    });
                                  }),
                              Text(
                                num.parse((cartQty / num.parse(factorConversion)).toStringAsFixed(2)).toString().split('.')[0] + " Pza",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontFamily: "Rubik", fontSize: 16, fontWeight: FontWeight.normal, color: HexColor("#637381"), height: 1.3),
                              ),
                              IconButton(
                                  icon: Icon(
                                    Icons.add,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    num newcartQty = cartQty + num.parse(incremento);
                                    setState(() {
                                      cartQty = num.parse(newcartQty.toStringAsFixed(2));
                                      newTotal = total * cartQty;
                                    });
                                  }),
                            ],
                          ),
                        ),
                        Expanded(
                          child: this.buy(),
                        )
                      ],
                    ),
                  )
                  */
            ,
            AnimatedContainer(
              duration: new Duration(milliseconds: 300),
              height: !open ? 33 : 137,
              width: 10,
              //height: 33,
              color: HexColor('#F9FAFB'),
              child: this.instrucciones(),
            ),
          ],
        ),
      );
    } else if (withUnitEquivalence && widget.product["unit"]["code"].toString().contains("PCE")) {
      return Container(
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0xcc000000).withOpacity(0.2),
              offset: Offset(5.0, 0.0),
              blurRadius: 12.0,
            ),
          ],
          color: HexColor('#F9FAFB'),
          borderRadius: new BorderRadius.only(topLeft: const Radius.circular(20.0), topRight: const Radius.circular(20.0)),
        ),
        child: CupertinoActionSheet(
          actions: <Widget>[
            Container(
              width: 10,
              height: 10,
              color: HexColor('#F9FAFB'),
            ),
            Container(
              color: HexColor('#F9FAFB'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 36,
                    margin: EdgeInsets.only(right: 10, left: 5),
                    decoration: BoxDecoration(color: Colors.white, border: Border.all(width: 1, color: HexColor('#C4CDD5')), borderRadius: BorderRadius.circular(5)),
                    child: Row(
                      children: <Widget>[
                        IconButton(
                            icon: Icon(
                              Icons.remove,
                              size: 20,
                            ),
                            onPressed: () {
                              num newcartQty = cartQty - num.parse(incremento);
                              setState(() {
                                if (newcartQty >= num.parse(minOrderQuantity)) {
                                  cartQty = num.parse(newcartQty.toStringAsFixed(2));
                                  newTotal = total * cartQty;
                                }
                              });
                            }),
                        Text(
                          int.parse(cartQty.toStringAsFixed(0)).toString() + " pza ",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: "Rubik", fontSize: 16, fontWeight: FontWeight.normal, color: HexColor("#637381"), height: 1.3),
                        ),
                        IconButton(
                            icon: Icon(Icons.add, size: 20),
                            onPressed: () {
                              num newcartQty = cartQty + num.parse(incremento);
                              setState(() {
                                cartQty = num.parse(newcartQty.toStringAsFixed(2));
                                newTotal = total * cartQty;
                              });
                            }),
                      ],
                    ),
                  ),
                  Expanded(
                    child: this.buy(),
                  )
                ],
              ),
            ),
            AnimatedContainer(
              duration: new Duration(milliseconds: 300),
              height: !open ? 33 : 137,
              width: 10,
              //height: 33,
              color: HexColor('#F9FAFB'),
              child: this.instrucciones(),
            ),
          ],
        ),
      );
    }

    return withUnitEquivalence
        ? Container(
            decoration: BoxDecoration(
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Color(0xcc000000).withOpacity(0.2),
                  offset: Offset(5.0, 0.0),
                  blurRadius: 12.0,
                ),
              ],
              color: HexColor('#F9FAFB'),
              borderRadius: new BorderRadius.only(topLeft: const Radius.circular(20.0), topRight: const Radius.circular(20.0)),
            ),
            //padding: EdgeInsets.only(right: 0, left: 0),
            child: CupertinoActionSheet(
              actions: <Widget>[
                Container(
                  width: 10,
                  height: 10,
                  color: HexColor('#F9FAFB'),
                ),
                this.toggleButton(),
                !toggle
                    ? Container(
                        color: HexColor('#F9FAFB'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              height: 36,
                              margin: EdgeInsets.only(right: 10, left: 5),
                              decoration: BoxDecoration(color: Colors.white, border: Border.all(width: 1, color: HexColor('#C4CDD5')), borderRadius: BorderRadius.circular(5)),
                              child: Row(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (unit.contains("kg")) {
                                          num newcartQty = cartQty - num.parse(incremento);
                                          if (newcartQty >= num.parse(minOrderQuantity)) {
                                            cartQty = num.parse(newcartQty.toStringAsFixed(2));
                                            newTotal = total * cartQty;
                                          }
                                        } else {
                                          if ((cartQty * num.parse(incremento)) > num.parse(minOrderQuantity) * num.parse(incremento)) {
                                            cartQty = (cartQty / num.parse(incremento)) - 1;
                                            newTotal = total * cartQty;
                                          }
                                        }
                                        label = formatter.format(double.parse(cartQty.toString())).toString() + " " + unit;
                                      });
                                    },
                                  ),
                                  Text(
                                    //label,
                                    num.parse(cartQty.toStringAsFixed(2)).toString() + " Kg",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontFamily: "Rubik", fontSize: 14, fontWeight: FontWeight.normal, color: HexColor("#637381"), height: 1.3),
                                  ),
                                  IconButton(
                                      icon: Icon(
                                        Icons.add,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          //if(cartQty>num.parse(minOrderQuantity)) {
                                          print("unit--->>>" + unit);
                                          if (unit.contains("kg")) {
                                            print("unit kg--->>>" + unit);
                                            num newcartQty = cartQty + num.parse(incremento);
                                            cartQty = num.parse(newcartQty.toStringAsFixed(2));
                                            newTotal = total * cartQty;
                                          } else {
                                            print("unit pz--->>>" + unit);
                                            total = (cartQty / num.parse(incremento)) + 1;
                                            newTotal = total * cartQty;
                                          }
                                          //}
                                          label = formatter.format(cartQty).toString() + " " + unit;
                                        });
                                      }),
                                ],
                              ),
                            ),
                            Expanded(
                              child: this.buy(),
                            )
                          ],
                        ),
                      )
                    : Container(
                        color: HexColor('#F9FAFB'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              height: 36,
                              margin: EdgeInsets.only(right: 10, left: 5),
                              decoration: BoxDecoration(color: Colors.white, border: Border.all(width: 1, color: HexColor('#C4CDD5')), borderRadius: BorderRadius.circular(5)),
                              child: Row(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (unit.contains("kg")) {
                                          num newcartQty = cartQty - num.parse(incremento);
                                          if (newcartQty >= num.parse(minOrderQuantity)) {
                                            cartQty = num.parse(newcartQty.toStringAsFixed(2));
                                            newTotal = total * cartQty;
                                          }
                                        } else {
                                          if ((cartQty * num.parse(incremento)) > num.parse(minOrderQuantity) * num.parse(incremento)) {
                                            cartQty = (cartQty / num.parse(incremento)) - 1;
                                            newTotal = total * cartQty;
                                          }
                                        }
                                        label = formatter.format(double.parse((cartQty / num.parse(factorConversion)).toString())).toString() + " " + unit;
                                      });
                                    },
                                  ),
                                  Text(
                                    //label,
                                    num.parse((cartQty / num.parse(factorConversion)).toStringAsFixed(2)).toString().split('.')[0] + " Pza",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontFamily: "Rubik", fontSize: 14, fontWeight: FontWeight.normal, color: HexColor("#637381"), height: 1.3),
                                  ),
                                  IconButton(
                                      icon: Icon(Icons.add, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          //if(cartQty>num.parse(minOrderQuantity)) {
                                          print("unit--->>>" + unit);
                                          if (unit.contains("kg")) {
                                            print("unit kg--->>>" + unit);
                                            num newcartQty = cartQty + num.parse(incremento);
                                            cartQty = num.parse(newcartQty.toStringAsFixed(2));
                                            newTotal = total * cartQty;
                                          } else {
                                            print("unit pz--->>>" + unit);
                                            cartQty = (cartQty / num.parse(incremento)) + 1;
                                            newTotal = total * cartQty;
                                          }
                                          //}
                                          label = formatter.format(cartQty / num.parse(factorConversion)).toString() + " " + unit;
                                        });
                                      }),
                                ],
                              ),
                            ),
                            Expanded(
                              child: this.buy(),
                            )
                          ],
                        ),
                      ),
                AnimatedContainer(
                  duration: new Duration(milliseconds: 300),
                  height: !open ? 33 : 137,
                  width: 10,
                  //height: 33,
                  color: HexColor('#F9FAFB'),
                  child: this.instrucciones(),
                ),
              ],
            ),
          )
        : Container(
            decoration: BoxDecoration(
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Color(0xcc000000).withOpacity(0.2),
                  offset: Offset(5.0, 0.0),
                  blurRadius: 12.0,
                ),
              ],
              color: HexColor('#F9FAFB'),
              borderRadius: new BorderRadius.only(topLeft: const Radius.circular(20.0), topRight: const Radius.circular(20.0)),
            ),
            // padding: EdgeInsets.only(right: 15, left: 15),
            child: CupertinoActionSheet(
              actions: <Widget>[
                Container(
                  width: 10,
                  height: 10,
                  color: HexColor('#F9FAFB'),
                ),
                Container(
                  color: HexColor('#F9FAFB'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 36,
                        margin: EdgeInsets.only(right: 10, left: 5),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(width: 1, color: HexColor('#C4CDD5')), borderRadius: BorderRadius.circular(5)),
                        child: Row(
                          children: <Widget>[
                            IconButton(
                                icon: Icon(
                                  Icons.remove,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (cartQty > num.parse(minOrderQuantity)) {
                                      cartQty -= num.parse(incremento);
                                      newTotal = total * cartQty;
                                    }
                                  });
                                }),
                            Text(
                              int.parse(cartQty.toStringAsFixed(0)).toString() + " pza ",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: "Rubik", fontSize: 16, fontWeight: FontWeight.normal, color: HexColor("#637381"), height: 1.3),
                            ),
                            IconButton(
                                icon: Icon(Icons.add, size: 20),
                                onPressed: () {
                                  setState(() {
                                    cartQty += num.parse(incremento);
                                    newTotal = total * cartQty;
                                  });
                                }),
                          ],
                        ),
                      ),
                      Expanded(
                        child: this.buy(),
                      )
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: new Duration(milliseconds: 300),
                  height: !open ? 33 : 137,
                  width: 10,
                  //height: 33,
                  color: HexColor('#F9FAFB'),
                  child: this.instrucciones(),
                ),
              ],
            ),
          );
  }
}

class PromosProductSingle extends StatefulWidget {
  final dynamic data;
  final size;
  final left;
  PromosProductSingle({Key key, this.data, this.size, this.left}) : super(key: key);
  _PromosProductSingle createState() => _PromosProductSingle();
}

class _PromosProductSingle extends State<PromosProductSingle> {
  List<String> promosImageList = new List();

  @override
  Widget build(BuildContext context) {
    double size = widget.size != null ? widget.size : 90.0;
    double left = widget.left != null ? widget.left : 1.0;

    promosImageList = new List();
    for (dynamic promos in (widget.data["potentialPromotions"] ?? [])) {
      if (promos["productBanner"] != null) {
        if (!promosImageList.contains(NetworkData.hybrisProd + promos["productBanner"]["url"])) {
          promosImageList.add(NetworkData.hybrisProd + promos["productBanner"]["url"]);
        }
      }
    }
    return Positioned(
      top: 1.0,
      left: left,
      child: Container(
        alignment: Alignment.topLeft,
        width: 90,
        height: 90,
        child: Center(
            child: Column(
          children: <Widget>[
            Container(
              width: size,
              height: size,
              child: ListTile(
                title: Container(
                  child: Column(children: [
                    Column(
                        children: promosImageList
                            .map((element) => Container(
                                  child: Stack(children: <Widget>[
                                    Image.network(element, fit: BoxFit.fitWidth),
                                    Divider(
                                      height: 40,
                                    ),
                                  ]),
                                ))
                            .toList()),
                  ]),
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}

class ProductsSlider2 extends StatefulWidget {
  final String title;
  final dynamic productReferences;
  ProductsSlider2({Key key, this.title, this.productReferences}) : super(key: key);

  _ProductsSliderState2 createState() => _ProductsSliderState2();
}

class _ProductsSliderState2 extends State<ProductsSlider2> {
  final formatter = new NumberFormat("###,###,###,###.00");

  String level = '1';
  List<dynamic> data = new List();
  SharedPreferences prefs;
  var favorite = Icon(Icons.favorite_border, size: 18.0);
  List data2;
  bool error;
  String buttonText = "Ver todos";
  List misListas;
  List listaFavoritos;

  bool isfavorite;

  bool loading;

  var listID;

  Future getLista() async {
    await ListasServices.getCurrentList(listID).then((res) {
      if (res != null) {
        listaFavoritos = res['entries'];
      }
    });
  }

  bool _isLoggedIn;
  Future getPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future getProducts() async {
    setState(() {
      loading = true;
    });
    for (dynamic product in widget.productReferences) {
      try {
        await ArticulosServices.getProductHybrisSearch(product['target']['code']).then((productData) {
          if (mounted) {
            setState(() {
              data.add(productData);
            });
          }
        });
      } catch (e) {
        print(e.toString());
      }
    }
    if (_isLoggedIn == true) {
      if (listaFavoritos != null && data != null) {
        favoriteProducts();
      }
    } else {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  initState() {
    // getPreferences().then((x) {
    //   setState(() {
    //     // prefs.clear();
    //     _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    //     if (_isLoggedIn == true) {
    //       listID = prefs.getString('favoriteListID');
    //       getLista();
    //     }
    //   });
    // });
    super.initState();
    favorite = Icon(Icons.favorite_border, size: 18.0);
    getProducts();
  }

  favoriteProducts() async {
    if (listaFavoritos != null && data != null) {
      await Future.forEach(data, (product) {
        if (product != null && product['code'] != null) {
          var result;
          result = listaFavoritos.firstWhere((productoFavorito) => productoFavorito['product']['code'] == product['code'], orElse: () => false);
          if (result != null) {
            if (result == false) {
              product['favorito'] = false;
            } else {
              product['favorito'] = true;
            }
          } else {
            product['favorito'] = false;
          }
        }
      });
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void _showLoginInvitation() {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Inicia Sesión"),
          content: Text(
            'Inicia sesión para poder agregar artículos favoritos y disfrutar de todos los beneficios de la nueva tienda Chedraui',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: DataUI.textOpaque,
            ),
          ),
          actions: <Widget>[
            // FlatButton(
            //   onPressed: () {
            //     Navigator.pushNamed(context, '/Login');
            //   },
            //   child: Text(
            //     "Continuar",
            //     style: TextStyle(
            //       color: DataUI.chedrauiBlueColor,
            //       fontSize: 16,
            //     ),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: RaisedButton(
                color: DataUI.chedrauiBlueColor,
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, DataUI.loginRoute);
                },
                child: Text(
                  "Iniciar Sesión",
                  style: TextStyle(
                    color: DataUI.whiteText,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 45,
                  height: 5,
                  margin: EdgeInsets.only(left: 15),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 5.0, color: HexColor('#FBC02D')),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          widget.title,
                          overflow: TextOverflow.clip,
                          maxLines: 2,
                          style: TextStyle(
                            color: HexColor('#0D47A1'),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Archivo',
                            fontSize: 20,
                          ),
                        ),
                        // InkWell(
                        //   child: Text(
                        //     "Ver todos",
                        //     textAlign: TextAlign.end,
                        //     style: TextStyle(
                        //       fontSize: 14,
                        //       fontFamily: 'Archivo',
                        //       color: HexColor("#0D47A1"),
                        //     ),
                        //   ),
                        //   onTap: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => ProductsPage(
                        //           searchTerm:
                        //               widget.seccion["codigo"].toString(),
                        //         ),
                        //       ),
                        //     );
                        //   },
                        // ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    child: ListView.builder(
                      physics: ClampingScrollPhysics(),
                      // shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: data.length < 9 ? data.length : 9,
                      itemBuilder: (context, index) {
                        return data == null
                            ? Container(
                                margin: EdgeInsets.only(left: 15, right: 7.5),
                                width: 165.0,
                                height: 210.0,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: null,
                                  ),
                                ),
                              )
                            : data[index] == null
                                ? SizedBox()
                                : GestureDetector(
                                    onTap: () {
                                      // FireBaseEventController.sendAnalyticsEventViewItem(data[index]['code'], data[index]['name'], '').then((ok) {});
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          settings: RouteSettings(name: DataUI.productRoute),
                                          builder: (context) => ProductPage(data: data[index]),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 165.0,
                                      margin: EdgeInsets.only(left: 15, right: 8, bottom: 30),
                                      padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8.0),
                                        // boxShadow: <BoxShadow>[
                                        //   BoxShadow(
                                        //     color: Color(0xcc000000)
                                        //         .withOpacity(0.2),
                                        //     offset: Offset(2.0, 5.0),
                                        //     blurRadius: 12.0,
                                        //   ),
                                        // ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Stack(
                                            children: <Widget>[
                                              data[index]['images'] == null
                                                  ? Center(
                                                      child: Column(
                                                        children: <Widget>[
                                                          Container(
                                                            width: 80,
                                                            height: 71,
                                                            child: Image.asset('assets/chd_logo.png'),
                                                          ),
                                                          Text('Imagen no disponible')
                                                        ],
                                                      ),
                                                    )
                                                  : Container(
                                                      height: 80,
                                                      // color: Colors.black,
                                                      alignment: Alignment.center,
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(0.0),
                                                        child: CachedNetworkImage(
                                                          imageUrl: NetworkData.hybrisBaseUrl + data[index]['images'][0]['url'],
                                                          placeholder: (context, url) => Center(
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(4.0),
                                                              child: CircularProgressIndicator(),
                                                            ),
                                                          ),
                                                          errorWidget: (context, url, error) => Icon(Icons.error),
                                                        ),
                                                      ),
                                                    ),
                                              // Positioned(
                                              //   top: 2.0,
                                              //   right: 2.0,
                                              //   child: Container(
                                              //     child: SizedBox(
                                              //       height: 23.0,
                                              //       width: 23.0,
                                              //       child: new IconButton(
                                              //         padding: new EdgeInsets.all(0.0),
                                              //         splashColor: Colors.white,
                                              //         color: HexColor("#0DA136"),
                                              //         icon: Icon(data[index]['favorito'] != null ? data[index]['favorito'] ? Icons.check_circle : Icons.add_circle_outline : Icons.check_circle),
                                              //         onPressed: () {
                                              //           if (_isLoggedIn) {
                                              //             setState(
                                              //               () {
                                              //                 if (data[index]['favorito'] == true) {
                                              //                   ListasServices.deleteProduct(listID, data[index]['code'], data[index]['name']).then((res) {
                                              //                     if (res == true) {
                                              //                       setState(() {
                                              //                         data[index]['favorito'] = false;
                                              //                       });
                                              //                       Scaffold.of(context).showSnackBar(new SnackBar(
                                              //                         content: new Text("Se ha eliminado el producto"),
                                              //                       ));
                                              //                     } else {
                                              //                       Scaffold.of(context).showSnackBar(new SnackBar(
                                              //                         content: new Text("Ha ocurrido un problema al eliminar el prodcuto"),
                                              //                       ));
                                              //                     }
                                              //                   });
                                              //                 } else {
                                              //                   ListasServices.addProduct(listID, data[index]['code'], '1.0').then((res) {
                                              //                     if (res == true) {
                                              //                       setState(() {
                                              //                         data[index]['favorito'] = true;
                                              //                       });
                                              //                       Scaffold.of(context).showSnackBar(new SnackBar(
                                              //                         content: new Text("Producto añadido a Lista Favoritos"),
                                              //                       ));
                                              //                     } else {
                                              //                       Scaffold.of(context).showSnackBar(new SnackBar(
                                              //                         content: new Text("Ha ocurrido un problema al añadir el prodcuto"),
                                              //                       ));
                                              //                     }
                                              //                   });
                                              //                 }
                                              //               },
                                              //             );
                                              //           } else {
                                              //             _showLoginInvitation();
                                              //           }
                                              //         },
                                              //       ),
                                              //     ),
                                              //   ),
                                              // ),
                                              PromosProduct(data: data[index]),
                                            ],
                                          ),
                                          Container(
                                            height: 18,
                                            child: Text(
                                              //"\$49.99/Kg",
                                              data[index]['strikeThroughPriceValue'] != null ? formatter.format(double.parse(data[index]['strikeThroughPriceValue']['value'].toStringAsFixed(2))) : "",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontSize: data[index]['strikeThroughPriceValue'] != null ? 12.0 : 12,
                                                color: HexColor("#454F5B").withOpacity(0.5),
                                                fontWeight: FontWeight.normal,
                                                fontFamily: 'Archivo',
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            data[index]['price']['formattedValue'],
                                            textAlign: TextAlign.left,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 18.0, color: HexColor("#0D47A1"), fontWeight: FontWeight.bold, fontFamily: 'Archivo', letterSpacing: -0.09),
                                          ),
                                          Container(
                                            height: 41,
                                            child: Text(
                                              data[index]['name'],
                                              textAlign: TextAlign.left,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                              style: TextStyle(
                                                fontSize: 13.0,
                                                fontFamily: 'Archivo',
                                                color: HexColor("#444444"),
                                              ),
                                            ),
                                          ),
                                          // Container(
                                          //   width: double.infinity,
                                          //   margin: EdgeInsets.only(
                                          //     top: 15,
                                          //   ),
                                          //   // alignment: Alignment.center,
                                          //   child: FlatButton(
                                          //     shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                                          //     key: null,
                                          //     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          //     onPressed: () {
                                          //       // FireBaseEventController.sendAnalyticsEventViewItem(data[index]['code'], data[index]['name'], '').then((ok) {});
                                          //       Navigator.push(
                                          //         context,
                                          //         MaterialPageRoute(
                                          //           settings: RouteSettings(name: DataUI.productRoute),
                                          //           builder: (context) => ProductPage(data: data[index]),
                                          //         ),
                                          //       );
                                          //     },
                                          //     color: DataUI.btnbuy,
                                          //     child: Text(
                                          //       "Más Detalles",
                                          //       style: TextStyle(
                                          //         fontSize: 12.0,
                                          //         color: Colors.white,
                                          //       ),
                                          //     ),
                                          //   ),
                                          // )
                                        ],
                                      ),
                                    ),
                                  );
                      },
                    ),
                  ),
                )
              ],
            ),
          );
  }
}

class ProductToList extends StatefulWidget {
  final dynamic upc;
  ProductToList({Key key, this.upc}) : super(key: key);

  _ProductToListState createState() => _ProductToListState();
}

class _ProductToListState extends State<ProductToList> {
  List misListas;
  var selectedRadioTile;

  var listName;
  getListas() {
    ListasServices.getListas().then(
      (listas) {
        setState(
          () {
            misListas = listas;
          },
        );
      },
    );

    return "Success!";
  }

  void initState() {
    super.initState();
    getListas();
  }

  addProducttoList(listID, listName) {
    ListasServices.addProduct(listID, widget.upc, '1.0').then((response) {
      print(response);
      if (response == true) {
        Navigator.pop(context, '$listName');
      } else {
        Navigator.pop(context, 'error');
      }
    });
  }

  createList() async {
    final result = await Navigator.pushNamed(context, DataUI.listaNew);
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => ListaNew()),
    // );
    if (result == 'reload') {
      print('reloading');
      ListasServices.getListas().then(
        (listas) {
          setState(
            () {
              misListas = listas;
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: misListas != null
          ? SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: SizedBox(
                /* height: 500, */
                width: 400,
                child: misListas.length > 0
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: misListas.length,
                        itemBuilder: (context, index) {
                          return RadioListTile(
                            activeColor: HexColor("#0D47A1"),
                            title: Text(
                              misListas[index]['name'],
                              style: TextStyle(fontSize: 14),
                            ),
                            value: misListas[index]['code'],
                            groupValue: selectedRadioTile,
                            onChanged: (value) {
                              setState(() {
                                selectedRadioTile = value;
                                listName = misListas[index]['name'];
                              });
                            },
                          );
                        },
                      )
                    : Container(
                        width: 400,
                        child: Center(
                            child: Column(
                          children: <Widget>[
                            Text(
                              'No se encontraron listas',
                              style: TextStyle(
                                fontFamily: "Rubik",
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(vertical: 20),
                              child: RaisedButton(
                                color: HexColor("#F57C00"),
                                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                onPressed: () {
                                  createList();
                                },
                                child: Text(
                                  'Crear nueva lista',
                                  style: TextStyle(
                                    color: HexColor("#F9FAFB"),
                                    fontFamily: "Rubik",
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                      ),
              ),
            )
          : Container(
              height: 30,
              width: 400,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
      title: Text('Añadir a lista de compras'),
      actions: <Widget>[
        misListas != null
            ? misListas.length > 0
                ? Container(
                    child: FlatButton(
                      onPressed: () {
                        addProducttoList(selectedRadioTile, listName);
                      },
                      child: Text(
                        "Agregar",
                        style: TextStyle(
                          color: DataUI.chedrauiBlueColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 0,
                  )
            : SizedBox(
                height: 0,
              )
      ],
    );
  }
}
