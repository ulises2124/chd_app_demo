import 'package:cached_network_image/cached_network_image.dart';
import 'package:chd_app_demo/services/FireBaseServices.dart';
import 'package:chd_app_demo/services/ListasServices.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
//import 'package:chd_app_demo/views/Servicios/Util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chd_app_demo/views/ProductPage/ProductPage.dart';
import 'package:chd_app_demo/utils/NetworkData.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/services/ArticulosServices.dart';
import 'package:chd_app_demo/views/ProductsPage/ProductsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductsSliderHome extends StatefulWidget {
  final dynamic seccion;
  ProductsSliderHome({Key key, this.seccion}) : super(key: key);

  _ProductsSliderHomeState createState() => _ProductsSliderHomeState();
}

class _ProductsSliderHomeState extends State<ProductsSliderHome> {
  final formatter = new NumberFormat("###,###,###,###.00");

  String level = '1';
  List<dynamic> data = new List();
  // SharedPreferences prefs;
  // var favorite = Icon(Icons.favorite_border, size: 18.0);
  List data2;
  bool error;
  List upcs;
  String buttonText = "Ver todos";
  // List misListas;
  // List listaFavoritos;

  // bool isfavorite;

  bool loading;

  // var listID;

  // Future getLista() async {
  //   await ListasServices.getCurrentList(listID).then((res) {
  //     if (res != null) {
  //       listaFavoritos = res['entries'];
  //     }
  //   });
  // }

  // bool _isLoggedIn;
  // Future getPreferences() async {
  //   prefs = await SharedPreferences.getInstance();
  // }

  Future getProducts() async {
    setState(() {
      loading = true;
    });
    for (dynamic product in widget.seccion["productos"]) {
      try {
        await ArticulosServices.getProductHybrisSearch(product['upc']).then((productData) {
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
    // if (_isLoggedIn == true) {
    //   if (listaFavoritos != null && data != null) {
    //     favoriteProducts();
    //   }
    // } else {
    //   if (mounted) {
    //     setState(() {
    //       loading = false;
    //     });
    //   }
    // }
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  initState() {
    // getPreferences().then((x) {
    //   setState(() {
    //     // prefs.clear();
    //     _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    //     // if (_isLoggedIn == true) {
    //     //   listID = prefs.getString('favoriteListID');
    //     //   getLista();
    //     // }
    //   });
    // });
    super.initState();
    // favorite = Icon(Icons.favorite_border, size: 18.0);
    getProducts();
  }

  // favoriteProducts() async {
  //   if (listaFavoritos != null && data != null) {
  //     await Future.forEach(data, (product) {
  //       if (product != null && product['code'] != null) {
  //         var result;
  //         result = listaFavoritos.firstWhere((productoFavorito) => productoFavorito['product']['code'] == product['code'], orElse: () => false);
  //         if (result != null) {
  //           if (result == false) {
  //             product['favorito'] = false;
  //           } else {
  //             product['favorito'] = true;
  //           }
  //         } else {
  //           product['favorito'] = false;
  //         }
  //       }
  //     });
  //     if (mounted) {
  //       setState(() {
  //         loading = false;
  //       });
  //     }
  //   }
  // }

  // void _showLoginInvitation() {
  //   showDialog(
  //     barrierDismissible: true,
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("Inicia Sesión"),
  //         content: Text(
  //           'Inicia sesión para poder agregar artículos favoritos y disfrutar de todos los beneficios de la nueva tienda Chedraui',
  //           style: TextStyle(
  //             fontSize: 14,
  //             fontWeight: FontWeight.w400,
  //             color: DataUI.textOpaque,
  //           ),
  //         ),
  //         actions: <Widget>[
  //           // FlatButton(
  //           //   onPressed: () {
  //           //     Navigator.pushNamed(context, '/Login');
  //           //   },
  //           //   child: Text(
  //           //     "Continuar",
  //           //     style: TextStyle(
  //           //       color: DataUI.chedrauiBlueColor,
  //           //       fontSize: 16,
  //           //     ),
  //           //   ),
  //           // ),
  //           Padding(
  //             padding: const EdgeInsets.only(left: 8),
  //             child: RaisedButton(
  //               color: DataUI.chedrauiBlueColor,
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //                 Navigator.pushNamed(context, DataUI.loginRoute);
  //               },
  //               child: Text(
  //                 "Iniciar Sesión",
  //                 style: TextStyle(
  //                   color: DataUI.whiteText,
  //                   fontSize: 16,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

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
                  flex: 3,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          widget.seccion["nombre"].toString(),
                          overflow: TextOverflow.clip,
                          maxLines: 2,
                          style: TextStyle(
                            color: HexColor('#0D47A1'),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Archivo',
                            fontSize: 20,
                          ),
                        ),
                        InkWell(
                          child: Text(
                            "Ver todos",
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Archivo',
                              color: HexColor("#0D47A1"),
                            ),
                          ),
                          onTap: () {
                            FireBaseEventController.sendAnalyticsEventViewItemList('Home', widget.seccion["nombre"].toString());
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                settings: RouteSettings(name: DataUI.productsRoute),
                                builder: (context) => ProductsPage(
                                  searchTerm: widget.seccion["codigo"].toString(),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 10,
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
                                height: 233.0,
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
                                              //         icon: Icon(data[index]['favorito'] != null ? data[index]['favorito'] ? Icons.check_circle_outline : Icons.add_circle_outline : Icons.add_circle_outline),
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
