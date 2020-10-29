import 'package:cached_network_image/cached_network_image.dart';
import 'package:chd_app_demo/services/ArticulosServices.dart';
import 'package:chd_app_demo/services/FireBaseServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/utils/NetworkData.dart';
import 'package:chd_app_demo/views/Errors/NetworkErrorPage/NetworkErrorPage.dart';
import 'package:chd_app_demo/views/ProductPage/ProductPage.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ListaProducts extends StatefulWidget {
  final String searchTerm;

  ListaProducts({
    Key key,
    this.searchTerm,
  }) : super(key: key);

  _ListaProductsState createState() => _ListaProductsState();
}

class _ListaProductsState extends State<ListaProducts> {
  SharedPreferences prefs;
  List productList = [];
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

  Future productsResponse;

  @override
  void initState() {
    getPreferences().then((x) {
      setState(() {
        // prefs.clear();
        _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      });
    });
    super.initState();
    query = widget.searchTerm.replaceAll(' ', '+');
    url = query + '&currentPage=' + currentPage.toString() + '&pageSize=50' + '&fields=FULL';
    print('search: ' + query);
    doSearch();
  }

  Future getPreferences() async {
    prefs = await SharedPreferences.getInstance();
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

  doSearch() async {
    productsResponse = ArticulosServices.getProductsHybrisSearch(url);
    var products = await productsResponse;
    if (products['pagination']['totalResults'] != 0) {
      setState(() {
        originalItems = products['products'];
        filters = products['facets'];
        filtersSelected = products['breadcrumbs'];
        currentPage = products['pagination']['currentPage'];
        totalPages = products['pagination']['totalPages'];
      });
      checkList();
    } else {
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
  }

  showFilters() async {
    //Navigator.of(context).pop('asdasdfasdafasfa');
    try {
      filterUrl = await getfilters(
        context,
      );
      newUrl = filterUrl + '&currentPage=' + present.toString() + '&pageSize=40' + '&fields=FULL';
      print('---------');
      print(newUrl);
      print('---------');
      ArticulosServices.getProductsHybrisSearch(newUrl).then(
        (products) {
          setState(
            () {
              selectedRadioTile = '';
              originalItems = products['products'];
              filters = products['facets'];
              filtersSelected = products['breadcrumbs'];
              currentPage = products['pagination']['currentPage'];
              totalPages = products['pagination']['totalPages'];
            },
          );
          checkList();
        },
      );
    } catch (error) {}
  }

  Future<String> getfilters(BuildContext context) async {
    return await showDialog<String>(
          context: context,
          child: new AlertDialog(
            title: Text("Filtros"),
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
                                children: <Widget>[createRadios(filters[index]['values'])],
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

  createRadios(radioData) {
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
            FireBaseEventController.sendAnalyticsEventProductFilterAndSort(radioData['name'], radioData[index]['name']).then((ok) {});
            Navigator.pop(context, url);
          },
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (currentPage < totalPages) {
      currentPage++;
      print(currentPage);
      setState(() {
        loadingProducts = true;
      });
      print(url);
      url = '';
      url = query + '&currentPage=' + currentPage.toString() + '&pageSize=50' + '&fields=FULL';
      if (newUrl != null) {
        var urlSortItems = '';
        urlSortItems = filterUrl + '&currentPage=' + present.toString() + '&pageSize=40' + '&fields=FULL';
        await ArticulosServices.getCategoryProductsFromHybris(urlSortItems).then((products) async {
          Future.forEach(products['products'], (product) {
            setState(() {
              originalItems.add(product);
            });
          });
          await checkList();
          setState(() {
            currentPage = products['pagination']['currentPage'];
            totalPages = products['pagination']['totalPages'];
            loadingProducts = false;
          });
        });
      } else {
        await ArticulosServices.getCategoryProductsFromHybris(url).then((products) async {
          Future.forEach(products['products'], (product) {
            setState(() {
              originalItems.add(product);
            });
          });
          await checkList();
          setState(() {
            currentPage = products['pagination']['currentPage'];
            totalPages = products['pagination']['totalPages'];
            loadingProducts = false;
          });
        });
      }
    } else {
      print('ya no hay resultados');
    }
  }

  checkList() async {
    await Future.forEach(originalItems, (product) {
      var result;
      result = productList.firstWhere((newproduct) => newproduct['code'] == product['code'], orElse: () => false);
      if (result != null) {
        if (result == false) {
          product['enLista'] = false;
        } else {
          product['enLista'] = true;
        }
      } else {
        product['enLista'] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WidgetContainer(
      LayoutBuilder(
        builder: (context, constraints) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(
                Icons.check,
                color: Colors.white,
              ),
              onPressed: () {
                if (productList.length > 0) {
                  Navigator.pop(context, productList);
                } else {
                  Navigator.pop(context, null);
                }
              },
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            backgroundColor: DataUI.backgroundColor,
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
                widget.searchTerm,
                style: TextStyle(color: Colors.white, fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 19),
              ),
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: Icon(Icons.close, color: Colors.white,),
                    onPressed: () => Navigator.pop(context, 'none'),
                  );
                },
              ),
            ),
            body: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                  if (loadingProducts == false) {
                    loadMore();
                  } else {
                    print('cargando');
                  }
                }
                return false;
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
                        return SingleChildScrollView(
                          physics: ClampingScrollPhysics(),
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          'Ordenar por: ',
                                          style: TextStyle(
                                            color: HexColor('#637381'),
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        DropdownButton<String>(
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
                                            if (newUrl != null) {
                                              Future.forEach(sortOptions, (newSort) {
                                                if (newUrl.contains(newSort) == true) {
                                                  newUrl = newUrl.replaceAll(newSort, sort);
                                                  newUrl = newUrl + '&currentPage=' + present.toString() + '&pageSize=40' + '&fields=FULL';
                                                  ArticulosServices.getProductsHybrisSearch(newUrl).then((products) {
                                                    setState(() {
                                                      originalItems = products['products'];
                                                      filters = products['facets'];
                                                      filtersSelected = products['breadcrumbs'];
                                                      currentPage = products['pagination']['currentPage'];
                                                      totalPages = products['pagination']['totalPages'];
                                                    });
                                                    checkList();
                                                  });
                                                }
                                              });
                                            } else {
                                              url = '';
                                              url = query + sort + '&currentPage=' + present.toString() + '&pageSize=40' + '&fields=FULL';
                                              ArticulosServices.getProductsHybrisSearch(url).then((products) {
                                                setState(() {
                                                  originalItems = products['products'];
                                                  filters = products['facets'];
                                                  filtersSelected = products['breadcrumbs'];
                                                  currentPage = products['pagination']['currentPage'];
                                                  totalPages = products['pagination']['totalPages'];
                                                });
                                                checkList();
                                              });
                                            }
                                          },
                                          value: sort,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      child: IconButton(
                                        icon: Icon(Icons.filter_list),
                                        onPressed: () {
                                          showFilters();
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              GridView.builder(
                                physics: ClampingScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: constraints.maxWidth < 350 ? 17 / 32 : 22 / 32,
                                ),
                                padding: const EdgeInsets.only(top: 15, bottom: 10, left: 10, right: 10),
                                shrinkWrap: true,
                                primary: true,
                                itemCount: originalItems.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    height: 0,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8.0),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: Color(0xcc000000).withOpacity(0.2),
                                          offset: Offset(0.0, 5.0),
                                          blurRadius: 12.0,
                                        ),
                                      ],
                                    ),
                                    child: GridTile(
                                      child: GestureDetector(
                                        onTap: () {},
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
                                                      PromosProduct(data: originalItems[index]),
                                                    ],
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(top: 14),
                                                    child: Column(
                                                      children: <Widget>[
                                                        Text(
                                                          originalItems[index]['price']['formattedValue'].toString(),
                                                          textAlign: TextAlign.left,
                                                          style: TextStyle(
                                                            fontSize: 20.0,
                                                            color: HexColor("#212B36"),
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                        Text(
                                                          originalItems[index]['strikeThroughPriceValue'] != null ? "\$ " + formatter.format(double.parse(originalItems[index]['strikeThroughPriceValue']['value'].toString()) + .0001) : "",
                                                          textAlign: TextAlign.left,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: HexColor("#919EAB"),
                                                            fontWeight: FontWeight.w200,
                                                            decoration: TextDecoration.lineThrough,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    // height: 50,
                                                    padding: EdgeInsets.only(bottom: 15),
                                                    child: Text(
                                                      originalItems[index]['name'],
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(fontSize: 14.0, color: HexColor("#919EAB"), fontWeight: FontWeight.w200, fontFamily: "Rubik"),
                                                    ),
                                                  ),
                                                  !originalItems[index]['enLista']
                                                      ? Container(
                                                          padding: EdgeInsets.only(top: 0),
                                                          alignment: Alignment.center,
                                                          child: RaisedButton(
                                                            key: null,
                                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                            onPressed: () {
                                                              setState(() {
                                                                productList.add(originalItems[index]);
                                                                originalItems[index]['enLista'] = !originalItems[index]['enLista'];
                                                              });
                                                            },
                                                            color: DataUI.btnbuy,
                                                            child: Text(
                                                              "Agregar a la lista",
                                                              style: TextStyle(
                                                                fontSize: 12.0,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : Container(
                                                          padding: EdgeInsets.only(top: 0),
                                                          alignment: Alignment.center,
                                                          child: RaisedButton(
                                                            key: null,
                                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                            onPressed: () {
                                                              setState(() {
                                                                productList.removeWhere((item) => item['code'] == originalItems[index]['code']);
                                                                originalItems[index]['enLista'] = !originalItems[index]['enLista'];
                                                              });
                                                            },
                                                            color: DataUI.btnbuy,
                                                            child: Text(
                                                              "Agregado",
                                                              style: TextStyle(
                                                                fontSize: 12.0,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
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
        },
      ),
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
    return Positioned(
      top: 0.0,
      left: 0.0,
      child: Container(
        width: 65,
        height: 65,
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                width: 65,
                height: 65,
                child: ListTile(
                  title: Container(
                    child: Column(
                      /*mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,*/
                      children: [
                        Column(
                          children: promosImageList
                              .map((element) => Container(
                                    padding: new EdgeInsets.only(bottom: 3.0),
                                    child: Stack(children: <Widget>[
                                      Image.network(
                                        element,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ]),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ), //    <-- label
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
