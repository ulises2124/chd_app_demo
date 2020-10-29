import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chd_app_demo/services/ArticulosServices.dart';
import 'package:chd_app_demo/services/FireBaseServices.dart';
import 'package:chd_app_demo/services/ListasServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/utils/NetworkData.dart';
import 'package:chd_app_demo/views/CategoryPage/CategoryMenu.dart';
import 'package:chd_app_demo/views/Errors/NetworkErrorPage/NetworkErrorPage.dart';
import 'package:chd_app_demo/views/ProductPage/ProductPage.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ProductsPage extends StatefulWidget {
  final String searchTerm;
  bool logEvent = false;

  ProductsPage({
    Key key,
    this.searchTerm,
    this.logEvent,
  }) : super(key: key);

  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer _timer;
  SharedPreferences prefs;
  bool _isLoggedIn = false;
  bool loadingProducts = false;
  int currentPage = 0;
  int totalPages;
  String filterUrl;
  String url;
  var filters;
  var selectedRadioTile;
  int present = 0;
  int perPage = 40;
  int selectedRadio;
  List sortOptions = [":mostSold", ":price-desc", ":price-asc", ":name-desc", ":name-asc", ":topRated", ":relevance"];
  List originalItems;
  List newItems;
  List filtersSelected;
  String newUrl;
  String sort = ':relevance';

  String query = '';
  final formatter = new NumberFormat("###,###,###,###.00");

  String listID;
  Future productsResponse;
  List listaFavoritos;

  bool loading = false;

  bool nomore = false;
  // Future getLista() async {
  //   await ListasServices.getCurrentList(listID).then((res) {
  //     if (res != null) {
  //       listaFavoritos = res['entries'];
  //     }
  //   });
  // }

  // favoriteProducts() async {
  //   if (listaFavoritos != null && originalItems != null) {
  //     await Future.forEach(originalItems, (product) {
  //       var result;
  //       result = listaFavoritos.firstWhere((productoFavorito) => productoFavorito['product']['code'] == product['code'], orElse: () => false);
  //       if (result != null) {
  //         if (result == false) {
  //           product['favorito'] = false;
  //         } else {
  //           product['favorito'] = true;
  //         }
  //       } else {
  //         product['favorito'] = false;
  //       }
  //     });
  //     setState(() {
  //       loading = false;
  //     });
  //   }
  // }

  @override
  void initState() {
    super.initState();
    query = widget.searchTerm.replaceAll(' ', '+');
    url = query +
        ':relevance'
            '&currentPage=' +
        currentPage.toString() +
        '&pageSize=48' +
        '&fields=FULL';
    print('init: ' + url);
    // getPreferences().then((x) async {
    //   setState(() {
    //     loading = true;
    //     // prefs.clear();
    //     _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    //   });
    //   if (_isLoggedIn == true) {
    //     listID = prefs.getString('favoriteListID');
    //     await getLista();
    //   }
    //   doSearch();
    // });

    doSearch();
  }

  // Future getPreferences() async {
  //   prefs = await SharedPreferences.getInstance();
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

  doSearch() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
      productsResponse = ArticulosServices.getProductsHybrisSearch(url);
      var products = await productsResponse;
      if (products['pagination']['totalResults'] != 0) {
        if (widget.logEvent != null) {
          if (widget.logEvent) {
            FireBaseEventController.sendAnalyticsEventSearchResults(widget.searchTerm, products['pagination']['totalResults']).then((ok) {});
          }
        }
        setState(() {
          originalItems = products['products'];
          filters = products['facets'];
          filtersSelected = products['breadcrumbs'];
          currentPage = products['pagination']['currentPage'];
          totalPages = products['pagination']['totalPages'];
        });
        // if (_isLoggedIn == true) {
        //   if (listaFavoritos != null && originalItems != null) {
        //     await favoriteProducts();
        //     setState(() {
        //       loading = false;
        //     });
        //   }
        // } else {
        //   setState(() {
        //     loading = false;
        //   });
        // }
      } else {
        setState(() {
          loading = false;
        });
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Búsqueda de productos"),
              content: Text("¡No se encontraron resultados de la búsqueda, intenta nuevamente!"),
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
              ],
            );
          },
        );
      }
      setState(() {
        loading = false;
      });
      //return "Success!";
    }
  }

  showFilters() async {
    //Navigator.of(context).pop('asdasdfasdafasfa');
    try {
      filterUrl = await getfilters(
        context,
      );
      newUrl = filterUrl + '&currentPage=' + present.toString() + '&pageSize=48' + '&fields=FULL';
      print('---------');
      print('newUrl');
      print(newUrl);
      print('---------');
      await ArticulosServices.getProductsHybrisSearch(newUrl).then(
        (newProducts) async {
          setState(() {
            loading = true;
            selectedRadioTile = '';
            originalItems = newProducts['products'];
            filters = newProducts['facets'];
            filtersSelected = newProducts['breadcrumbs'];
            currentPage = newProducts['pagination']['currentPage'];
            totalPages = newProducts['pagination']['totalPages'];
          });
          // if (_isLoggedIn == true) {
          //   await getLista();
          //   if (listaFavoritos != null && originalItems != null) {
          //     await favoriteProducts();
          //     setState(() {
          //       loading = false;
          //     });
          //   }
          // } else {
          //   setState(() {
          //     loading = false;
          //   });
          // }
          setState(() {
            loading = false;
          });
        },
      );
    } catch (error) {}
  }

  Future<String> getfilters(BuildContext context) async {
    return await showDialog<String>(
          context: context,
          child: new AlertDialog(
            title: Text(
              widget.searchTerm.toUpperCase(),
            ),
            content: Container(
              width: 400,
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Column(
                  children: <Widget>[
                    filtersSelected.length != 0
                        ? SizedBox(
                            height: 40,
                            child: ListView.builder(
                              physics: ClampingScrollPhysics(),
                              shrinkWrap: false,
                              scrollDirection: Axis.horizontal,
                              itemCount: filtersSelected.length,
                              itemBuilder: (context, index) {
                                return Row(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(left: 5.0, right: 5.0),
                                      child: InputChip(
                                        backgroundColor: HexColor("#DFE3E8"),
                                        onDeleted: () {
                                          setState(() {
                                            url = filtersSelected[index]['removeQuery']['query']['value'];
                                          });
                                          Navigator.pop(context, url);
                                        },
                                        label: Text(
                                          filtersSelected[index]['facetValueName'].toString(),
                                          style: TextStyle(color: HexColor("#454E5B"), fontFamily: "Rubik", fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          )
                        : SizedBox(
                            height: 0,
                          ),
                    filters.length != 0
                        ? ListView.builder(
                            physics: ClampingScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: filters.length,
                            itemBuilder: (context, index) {
                              return ExpansionTile(
                                initiallyExpanded: index == 0 ? false : false,
                                title: Text(
                                  filters[index]['name'],
                                ),
                                children: <Widget>[createRadios(filters[index])],
                              );
                            },
                          )
                        : Container(
                            margin: EdgeInsets.symmetric(vertical: 15),
                            child: Center(
                              child: Text('No hay filtros disponibles'),
                            ),
                          )
                  ],
                ),
              ),
            ),
          ),
        ) ??
        false;
  }

  createRadios(data) {
    var radioGroupName = data['name'];
    var radioData = data['values'];
    return ListView.builder(
      physics: ClampingScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: radioData.length,
      itemBuilder: (context, index) {
        return RadioListTile(
          activeColor: HexColor("#0D47A1"),
          title: Text(
            radioData[index]['name'],
            style: TextStyle(fontSize: 14),
          ),
          value: radioData[index]['query']['query']['value'],
          groupValue: selectedRadioTile,
          onChanged: (value) {
            setState(() {
              selectedRadioTile = value;
              url = selectedRadioTile;
            });
            FireBaseEventController.sendAnalyticsEventProductFilterAndSort(radioGroupName, radioData[index]['name']).then((ok) {});
            Navigator.pop(context, url);
          },
        );
      },
    );
  }

  Future<void> loadMore() async {
    print('aca');
    if (currentPage < totalPages && totalPages != 1) {
      setState(() {
        loadingProducts = true;
      });
      currentPage++;
      print('here');
      print(url);
      url = '';
      url = query + sort + '&currentPage=' + currentPage.toString() + '&pageSize=48' + '&fields=FULL';
      if (newUrl != null) {
        var urlSortItems = '';
        urlSortItems = filterUrl + '&currentPage=' + present.toString() + '&pageSize=48' + '&fields=FULL';
        await ArticulosServices.getCategoryProductsFromHybris(urlSortItems).then((products) async {
          await Future.forEach(products['products'], (product) {
            setState(() {
              originalItems.add(product);
            });
          });
          setState(() {
            currentPage = products['pagination']['currentPage'];
            totalPages = products['pagination']['totalPages'];
            loadingProducts = false;
          });
          // if (_isLoggedIn == true) {
          //   await getLista();
          //   if (listaFavoritos != null && originalItems != null) {
          //     await favoriteProducts();
          //     setState(() {
          //       loading = false;
          //     });
          //   }
          // } else {
          //   setState(() {
          //     loading = false;
          //   });
          // }
        });
      } else {
        await ArticulosServices.getCategoryProductsFromHybris(url).then((products) async {
          await Future.forEach(products['products'], (product) {
            setState(() {
              originalItems.add(product);
            });
          });
          setState(() {
            currentPage = products['pagination']['currentPage'];
            totalPages = products['pagination']['totalPages'];
            loadingProducts = false;
          });
          // if (_isLoggedIn == true) {
          //   await getLista();
          //   if (listaFavoritos != null && originalItems != null) {
          //     await favoriteProducts();
          //     setState(() {
          //       loading = false;
          //     });
          //   }
          // } else {
          //   setState(() {
          //     loading = false;
          //   });
          // }
        });
      }
    } else {
      // _scaffoldKey.currentState.showSnackBar(
      //   SnackBar(
      //     content: new Text('No existen mas resultados.'),
      //   ),
      // );
      setState(() {
        loadingProducts = false;
        nomore = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WidgetContainer(
      LayoutBuilder(builder: (context, constraints) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: HexColor('#F0EFF4'),
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
            title: Text(
              widget.searchTerm.toUpperCase(),
              style: TextStyle(color: Colors.white, fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 19),
            ),
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
            centerTitle: true,
          ),
          body: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if ((scrollInfo.metrics.pixels - 200) == (scrollInfo.metrics.maxScrollExtent - 200)) {
                if (!nomore) {
                  if (!loadingProducts) {
                    loadMore();
                  } else {
                    print('cargando');
                  }
                } else {
                  setState(() {
                    loadingProducts = true;
                  });
                }
              }
            },
            child: FutureBuilder(
              future: productsResponse,
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
                      return loading
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : CategoryMenu(
                              currentWidget: SingleChildScrollView(
                                physics: ClampingScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                            margin: EdgeInsets.only(right: 10, left: 10, top: 15),
                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                            width: (sort.length * 21).toDouble(),
                                            height: 30,
                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.white),
                                            child: Row(
                                              children: <Widget>[
                                                Container(
                                                  margin: EdgeInsets.only(right: 7),
                                                  child: FilterIcon(),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(right: 7),
                                                  child: Text(
                                                    'Ordenar:',
                                                    style: TextStyle(color: HexColor('#212B36'), fontSize: 12, fontFamily: 'Archivo'),
                                                  ),
                                                ),
                                                DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
                                                    elevation: 8,
                                                    iconEnabledColor: Colors.transparent,
                                                    style: TextStyle(color: HexColor('#212B36'), fontSize: 12, fontFamily: 'Archivo'),
                                                    isDense: true,
                                                    items: [
                                                      DropdownMenuItem(
                                                        value: ":relevance",
                                                        child: Text(
                                                          "Relevancia",
                                                        ),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: ":topRated",
                                                        child: Text(
                                                          "Mejores Valorados",
                                                        ),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: ":name-asc",
                                                        child: Text(
                                                          "Nombre asc (A-z)",
                                                        ),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: ":name-desc",
                                                        child: Text(
                                                          "Nombre desc (Z-a)",
                                                        ),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: ":price-asc",
                                                        child: Text(
                                                          "Precio (Menor-Mayor)",
                                                        ),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: ":price-desc",
                                                        child: Text(
                                                          "Precio (Mayor-Menor)",
                                                        ),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: ":mostSold",
                                                        child: Text(
                                                          "Más Vendidos",
                                                        ),
                                                      ),
                                                    ],
                                                    onChanged: (value) {
                                                      setState(() {
                                                        sort = value;
                                                      });
                                                      FireBaseEventController.sendAnalyticsEventProductFilterAndSort("Ordenar", value).then((ok) {});
                                                      if (newUrl != null) {
                                                        Future.forEach(sortOptions, (newSort) {
                                                          if (newUrl.contains(newSort) == true) {
                                                            newUrl = newUrl.replaceAll(newSort, sort);
                                                            //newUrl = newUrl + '&currentPage=' + present.toString() + '&pageSize=48' + '&fields=FULL';
                                                            ArticulosServices.getProductsHybrisSearch(newUrl).then((products) {
                                                              setState(() {
                                                                originalItems = products['products'];
                                                                filters = products['facets'];
                                                                filtersSelected = products['breadcrumbs'];
                                                                currentPage = products['pagination']['currentPage'];
                                                                totalPages = products['pagination']['totalPages'];
                                                              });
                                                            });
                                                          }
                                                        });
                                                      } else {
                                                        url = '';
                                                        url = query + sort + '&currentPage=0' '&pageSize=48' + '&fields=FULL';
                                                        ArticulosServices.getProductsHybrisSearch(url).then((products) {
                                                          setState(() {
                                                            originalItems = products['products'];
                                                            filters = products['facets'];
                                                            filtersSelected = products['breadcrumbs'];
                                                            currentPage = products['pagination']['currentPage'];
                                                            totalPages = products['pagination']['totalPages'];
                                                          });
                                                        });
                                                      }
                                                    },
                                                    value: sort,
                                                  ),
                                                ),
                                              ],
                                            )),
                                        IconButton(
                                          icon: Icon(Icons.filter_list),
                                          onPressed: showFilters,
                                        )
                                      ],
                                    ),
                                    originalItems != null && originalItems.length != 0
                                        ? GridView.builder(
                                            physics: ClampingScrollPhysics(),
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 14,
                                              mainAxisSpacing: 14,
                                              childAspectRatio: constraints.maxWidth < 350 ? 21 / 32 : 26 / 32,
                                            ),
                                            padding: const EdgeInsets.only(top: 15, bottom: 10, left: 10, right: 10),
                                            shrinkWrap: true,
                                            primary: true,
                                            itemCount: originalItems.length > 0 ? originalItems.length : 0,
                                            itemBuilder: (context, index) {
                                              if (originalItems[index] != null) {
                                                return Container(
                                                  height: 0,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(8.0),
                                                    // borderRadius: BorderRadius.circular(8.0),
                                                    // boxShadow: <BoxShadow>[
                                                    //   BoxShadow(
                                                    //     color: Color(0xcc000000)
                                                    //         .withOpacity(0.2),
                                                    //     offset: Offset(0.0, 5.0),
                                                    //     blurRadius: 12.0,
                                                    //   ),
                                                    // ],
                                                  ),
                                                  child: GridTile(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        // FireBaseEventController.sendAnalyticsEventViewItem(originalItems[index]['code'], originalItems[index]['name'], '').then((ok) {});
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            settings: RouteSettings(name: DataUI.productRoute),
                                                            builder: (context) => ProductPage(data: originalItems[index]),
                                                          ),
                                                        );
                                                      },
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisSize: MainAxisSize.max,
                                                        verticalDirection: VerticalDirection.down,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              mainAxisSize: MainAxisSize.max,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: <Widget>[
                                                                Stack(
                                                                  children: <Widget>[
                                                                    Container(
                                                                      width: 400,
                                                                      height: 92,
                                                                      child: originalItems[index]['images'] != null
                                                                          ? CachedNetworkImage(
                                                                              imageUrl: NetworkData.hybrisBaseUrl + originalItems[index]['images'][0]['url'],
                                                                              placeholder: (context, url) => Center(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(4.0),
                                                                                  child: CircularProgressIndicator(),
                                                                                ),
                                                                              ),
                                                                              errorWidget: (context, url, error) => Icon(Icons.error),
                                                                            )
                                                                          : Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: <Widget>[
                                                                                Container(
                                                                                  margin: EdgeInsets.only(top: 15),
                                                                                  height: 60,
                                                                                  child: Image.asset('assets/chd_logo.png'),
                                                                                ),
                                                                                Text(
                                                                                  'Imagen no disponible',
                                                                                  textAlign: TextAlign.center,
                                                                                )
                                                                              ],
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
                                                                    //         icon: Icon(originalItems[index]['favorito'] != null ? originalItems[index]['favorito'] ? Icons.check_circle_outline : Icons.add_circle_outline : Icons.add_circle_outline),
                                                                    //         onPressed: () {
                                                                    //           if (_isLoggedIn) {
                                                                    //             setState(
                                                                    //               () {
                                                                    //                 if (originalItems[index]['favorito'] == true) {
                                                                    //                   ListasServices.deleteProduct(listID, originalItems[index]['code'], originalItems[index]['name']).then((res) {
                                                                    //                     if (res == true) {
                                                                    //                       setState(() {
                                                                    //                         originalItems[index]['favorito'] = false;
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
                                                                    //                   ListasServices.addProduct(listID, originalItems[index]['code'], '1.0').then((res) {
                                                                    //                     if (res == true) {
                                                                    //                       setState(() {
                                                                    //                         originalItems[index]['favorito'] = true;
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
                                                                    PromosProduct(data: originalItems[index]),
                                                                  ],
                                                                ),
                                                                Container(
                                                                  margin: EdgeInsets.only(bottom: 14),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: <Widget>[
                                                                      Text(
                                                                        originalItems[index]['strikeThroughPriceValue'] != null ? "\$ " + formatter.format(double.parse(originalItems[index]['strikeThroughPriceValue']['value'].toString()) + .0001) : "",
                                                                        textAlign: TextAlign.left,
                                                                        style: TextStyle(
                                                                          fontSize: 12,
                                                                          color: HexColor("#454F5B"),
                                                                          fontWeight: FontWeight.w200,
                                                                          decoration: TextDecoration.lineThrough,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        originalItems[index]['price']['formattedValue'].toString(),
                                                                        textAlign: TextAlign.left,
                                                                        style: TextStyle(
                                                                          fontSize: 20.0,
                                                                          fontFamily: 'Archivo',
                                                                          color: HexColor("#0D47A1"),
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Container(
                                                                  height: 45,
                                                                  padding: EdgeInsets.only(bottom: 10),
                                                                  child: Text(
                                                                    originalItems[index]['name'],
                                                                    maxLines: 2,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    textAlign: TextAlign.left,
                                                                    style: TextStyle(
                                                                        fontSize: 14.0,
                                                                        color: HexColor("#444444"),
                                                                        // fontWeight: FontWeight.w200,
                                                                        fontFamily: "Archivo"),
                                                                  ),
                                                                ),
                                                                // Container(
                                                                //   width: double.infinity,
                                                                //   padding: EdgeInsets.only(top: 0),
                                                                //   child: FlatButton(
                                                                //     padding: EdgeInsets.symmetric(vertical: 15),
                                                                //     shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                                                                //     key: null,
                                                                //     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                                //     onPressed: () {
                                                                //       // FireBaseEventController.sendAnalyticsEventViewItem(originalItems[index]['code'], originalItems[index]['name'], '').then((ok) {});
                                                                //       Navigator.push(
                                                                //         context,
                                                                //         MaterialPageRoute(
                                                                //           settings: RouteSettings(name: DataUI.productRoute),
                                                                //           builder: (context) => ProductPage(
                                                                //             data: originalItems[index],
                                                                //           ),
                                                                //         ),
                                                                //       );
                                                                //     },
                                                                //     color: DataUI.btnbuy,
                                                                //     child: Text(
                                                                //       "Más Detalles",
                                                                //       style: TextStyle(
                                                                //         fontSize: 14.0,
                                                                //         fontFamily: 'Archivo',
                                                                //         color: Colors.white,
                                                                //       ),
                                                                //     ),
                                                                //   ),
                                                                // )
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            // childAspectRatio: 9 / 16,
                                            // padding: EdgeInsets.only(top: 16, bottom: 0, right: 16, left: 16),
                                            // children: List.generate(
                                            //   data == null ? 0 : data.length,
                                            //   (index) {
                                            //     // return Container(
                                            //     //   height: 500,
                                            //     //   decoration: BoxDecoration(
                                            //     //     color: Colors.black,
                                            //     //     boxShadow: <BoxShadow>[
                                            //     //       BoxShadow(
                                            //     //         color: Color(0xcc000000).withOpacity(0.2),
                                            //     //         offset: Offset(0.0, 5.0),
                                            //     //         blurRadius: 12.0,
                                            //     //       ),
                                            //     //     ],
                                            //     //   ),
                                            //     //   child: Column(
                                            //     //     crossAxisAlignment: CrossAxisAlignment.start,
                                            //     //     mainAxisSize: MainAxisSize.max,
                                            //     //     verticalDirection: VerticalDirection.down,
                                            //     //     children: <Widget>[
                                            //     //       Padding(
                                            //     //         padding: const EdgeInsets.all(8.0),
                                            //     //         child: Column(
                                            //     //           mainAxisAlignment: MainAxisAlignment.start,
                                            //     //           mainAxisSize: MainAxisSize.max,
                                            //     //           crossAxisAlignment: CrossAxisAlignment.start,
                                            //     //           children: <Widget>[
                                            //     //             Stack(
                                            //     //               children: <Widget>[
                                            //     //                 Container(
                                            //     //                   width: 400,
                                            //     //                   height: 80,
                                            //     //                   child: CachedNetworkImage(
                                            //     //                     imageUrl: NetworkData.hybrisBaseUrl + data[index]['images'][0]['url'],
                                            //     //                     placeholder: (context, url) => Center(
                                            //     //                           child: Padding(
                                            //     //                             padding: const EdgeInsets.all(4.0),
                                            //     //                             child: CircularProgressIndicator(),
                                            //     //                           ),
                                            //     //                         ),
                                            //     //                     errorWidget: (context, url, error) => Icon(Icons.error),
                                            //     //                   ),
                                            //     //                 ),
                                            //     //                 Positioned(
                                            //     //                   top: 2.0,
                                            //     //                   right: 2.0,
                                            //     //                   child: Container(
                                            //     //                     child: SizedBox(
                                            //     //                       height: 23.0,
                                            //     //                       width: 23.0,
                                            //     //                       child: IconButton(
                                            //     //                         splashColor: Colors.white,
                                            //     //                         padding: EdgeInsets.all(0.0),
                                            //     //                         color: HexColor("#0D47A1"),
                                            //     //                         icon: Icon(Icons.favorite_border, size: 18.0),
                                            //     //                         onPressed: () {
                                            //     //                           print("object");
                                            //     //                         },
                                            //     //                       ),
                                            //     //                     ),
                                            //     //                   ),
                                            //     //                 ),
                                            //     //                 PromosProduct(data: data[index]),
                                            //     //               ],
                                            //     //             ),
                                            //     //             Container(
                                            //     //               margin: EdgeInsets.only(top: 14),
                                            //     //               child: Column(
                                            //     //                 children: <Widget>[
                                            //     //                   Text(
                                            //     //                     data[index]['price']['formattedValue'].toString(),
                                            //     //                     textAlign: TextAlign.left,
                                            //     //                     style: TextStyle(
                                            //     //                       fontSize: 20.0,
                                            //     //                       color: HexColor("#212B36"),
                                            //     //                       fontWeight: FontWeight.w500,
                                            //     //                     ),
                                            //     //                   ),
                                            //     //                   Text(
                                            //     //                     data[index]['strikeThroughPriceValue'] != null ? "\$ " + formatter.format(double.parse(data[index]['strikeThroughPriceValue']['value'].toString()) + .0001) : "",
                                            //     //                     textAlign: TextAlign.left,
                                            //     //                     style: TextStyle(
                                            //     //                       fontSize: 12,
                                            //     //                       color: HexColor("#919EAB"),
                                            //     //                       fontWeight: FontWeight.w200,
                                            //     //                       decoration: TextDecoration.lineThrough,
                                            //     //                     ),
                                            //     //                   ),
                                            //     //                 ],
                                            //     //               ),
                                            //     //             ),
                                            //     //             Container(
                                            //     //               padding: EdgeInsets.only(bottom: 10),
                                            //     //               child: Text(
                                            //     //                 data[index]['name'],
                                            //     //                 maxLines: 2,
                                            //     //                 overflow: TextOverflow.ellipsis,
                                            //     //                 textAlign: TextAlign.left,
                                            //     //                 style: TextStyle(fontSize: 14.0, color: HexColor("#919EAB"), fontWeight: FontWeight.w200, fontFamily: "Rubik"),
                                            //     //               ),
                                            //     //             ),
                                            //     //             Container(
                                            //     //               padding: EdgeInsets.only(top: 0),
                                            //     //               alignment: Alignment.center,
                                            //     //               child: RaisedButton(
                                            //     //                 key: null,
                                            //     //                 materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            //     //                 onPressed: () {
                                            //     //                   Navigator.push(
                                            //     //                     context,
                                            //     //                     MaterialPageRoute(
                                            //     //                       builder: (context) => ProductPage(
                                            //     //                             data: data[index],
                                            //     //                           ),
                                            //     //                     ),
                                            //     //                   );
                                            //     //                 },
                                            //     //                 color: DataUI.btnbuy,
                                            //     //                 child: Text(
                                            //     //                   "Comprar",
                                            //     //                   style: TextStyle(
                                            //     //                     fontSize: 12.0,
                                            //     //                     color: Colors.white,
                                            //     //                   ),
                                            //     //                 ),
                                            //     //               ),
                                            //     //             )
                                            //     //           ],
                                            //     //         ),
                                            //     //       )
                                            //     //     ],
                                            //     //   ),
                                            //     // );

                                            //   },
                                            // ),
                                          )
                                        : SizedBox(),
                                    loadingProducts
                                        ? SizedBox(
                                            // child: Center(
                                            //     child: CircularProgressIndicator(),
                                            //   ),
                                            )
                                        : SizedBox(
                                            child: Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                          ),
                                  ],
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
          ),
        );
      }),
    );
  }
}

class PromosProduct extends StatefulWidget {
  final dynamic data;

  PromosProduct({Key key, this.data}) : super(key: key);

  _PromosProduct createState() => _PromosProduct();
}

class _PromosProduct extends State<PromosProduct> {
  List<String> promosImageList = new List();

  @override
  Widget build(BuildContext context) {
    promosImageList = new List();
    if (widget.data["potentialPromotions"] != null)
      for (dynamic promos in widget.data["potentialPromotions"]) {
        if (promos["productBanner"] != null) {
          promosImageList.add(NetworkData.hybrisProd + promos["productBanner"]["url"]);
        }
      }
    return promosImageList != null && promosImageList.length > 0
        ? Positioned(
            top: 0.0,
            left: 0.0,
            child: Container(
                width: 38,
                height: 38,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 38,
                      height: 38,
                      child: ListView.builder(
                        itemCount: 1,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            padding: new EdgeInsets.only(bottom: 3.0),
                            child: Stack(children: <Widget>[
                              Image.network(
                                promosImageList[index],
                                fit: BoxFit.fitWidth,
                              )
                            ]),
                          );
                        },
                      ),
                    ),
                  ],
                )),
          )
        : SizedBox();
  }
}
