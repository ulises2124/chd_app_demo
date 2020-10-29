import 'package:chd_app_demo/services/ArticulosServices.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/CategoryPage/SubCategoryPage.dart';
import 'package:chd_app_demo/views/ProductPage/ProductPage.dart';
import 'package:chd_app_demo/views/ProductsPage/ProductsPage.dart';
import 'package:chd_app_demo/widgets/LastProductsBought.dart';
import 'package:chd_app_demo/widgets/categorySlider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers.dart';

import 'package:chd_app_demo/services/HomeServices.dart';

import 'package:chd_app_demo/views/HomePage/BalanceMonederoBar.dart';
import 'package:chd_app_demo/views/HomePage/DeliveryMethodSelectionBar.dart';
import 'package:chd_app_demo/views/HomePage/DepartmentsCard.dart';
import 'package:chd_app_demo/views/HomePage/ProductsSearchResults.dart';
import 'package:chd_app_demo/views/HomePage/SearchProductsBar.dart';
import 'package:chd_app_demo/views/HomePage/CarouselHomeBanner.dart';
import 'package:chd_app_demo/views/DeliveryMethod/DeliveryMethodPage.dart';
import 'package:chd_app_demo/views/Errors/NetworkErrorPage/NetworkErrorPage.dart';

import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:chd_app_demo/widgets/ProductsSliderHome.dart';
import 'package:chd_app_demo/widgets/BannersHome.dart';

import 'package:chd_app_demo/utils/SliderImg.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:strings/strings.dart';

// import 'package:chedraui_flutter/views/ComparadorPrecios/ComparadorPrecios.dart';
// import 'package:chedraui_flutter/services/MonederoServices.dart';
// import 'package:chedraui_flutter/views/ContactanosPage/ContactanosPage.dart';
// import 'package:chedraui_flutter/views/CuponesPage/CuponesPage.dart';
// import 'package:chedraui_flutter/views/Facturacion/FacturacionPage.dart';
// import 'package:chedraui_flutter/views/Pedidos/PedidosPage.dart';
// import 'package:chedraui_flutter/views/Servicios/ServiciosPage.dart';

// import 'package:chedraui_flutter/widgets/toastPromo.dart';
// import 'package:chedraui_flutter/widgets/bannerCard.dart';
// import 'package:chedraui_flutter/utils/classBanner.dart';
// import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final bool showStores;

  HomePage({Key key, this.showStores}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  TextEditingController searchBoxController = TextEditingController();
  GlobalKey<ProductSearchResultsState> globalKeyProductSearchResults;
  SharedPreferences prefs;
  ScrollController _scrollController;
  bool _isSearching = false;
  bool _isLoggedIn = false;
  String _idWallet = "";
  List<SliderImg> sliders = new List();
  List<SliderImg> destacado = new List();
  List<dynamic> seccion = new List();
  List<SliderImg> list = new List();

  String type;
  var products;
  bool loading = false;

  String monederoId;
  // int _current = 0;

  var refreshKey = GlobalKey<RefreshIndicatorState>();
  Future<dynamic> homeResponse;

  String level;

  @override
  void initState() {
    _scrollController = ScrollController();
    globalKeyProductSearchResults = GlobalKey();
    startHome();
    super.initState();
    // if (widget.showStores != null && widget.showStores) {
    //   Future.delayed(const Duration(milliseconds: 2000), () {
    //     _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 1000), curve: Curves.easeOut);
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Container(
            child: StickyHeader(
                overlapHeaders: false,
                header: Container(
                  margin: EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(color: DataUI.chedrauiColor2),
                  child: Flex(
                    direction: Axis.vertical,
                    children: <Widget>[
                      Stack(
                        overflow: Overflow.visible,
                        children: <Widget>[
                          Positioned(
                            top: -10,
                            child: Container(
                              color: DataUI.chedrauiColor2,
                              height: 30,
                              width: MediaQuery.of(context).size.width,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 74),
                            child: Column(
                              children: <Widget>[
                                AnimatedCrossFade(
                                  sizeCurve: Curves.easeInOut,
                                  duration: const Duration(milliseconds: 280),
                                  firstChild: Container(height: 0, color: DataUI.chedrauiColor2),
                                  secondChild: DeliveryMethodSelection(),
                                  crossFadeState: _isSearching ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                ),
                                AnimatedCrossFade(
                                  sizeCurve: Curves.easeInOut,
                                  duration: const Duration(milliseconds: 280),
                                  firstChild: Container(
                                    height: 0,
                                    color: DataUI.chedrauiColor2,
                                  ),
                                  secondChild: _isLoggedIn ? BalanceMonederoBar() : Container(),
                                  crossFadeState: _isSearching ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                ),
                              ],
                            ),
                          ),
                          // _isLoggedIn ? BalanceMonederoBar() : Container(),
                          Positioned(
                            width: MediaQuery.of(context).size.width * 1.0,
                            height: 74,
                            bottom: 0,
                            child: SearchProducts(
                              activateSearching,
                              search,
                              activateSearchingManual,
                              searchBoxController: searchBoxController,
                              autoFocus: false,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                content: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AnimatedCrossFade(
                        sizeCurve: Curves.easeInOut,
                        duration: const Duration(milliseconds: 280),
                        crossFadeState: loading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                        firstChild: Container(
                            margin: EdgeInsets.only(top: 30),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(height: 120, width: 120, child: BuscarIconSVG(true)),
                                Container(
                                  margin: EdgeInsets.only(top: 40, bottom: 20),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        'Su consulta de búsqueda se está',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: HexColor('#454F5B'), fontFamily: 'Rubik', fontSize: 14),
                                      ),
                                      Text(
                                        'procesando ...',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: HexColor('#454F5B'), fontFamily: 'Rubik', fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 96,
                                  height: 2,
                                  child: LinearProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(HexColor('#454F5B').withOpacity(0.5)),
                                    backgroundColor: HexColor('#CFCED5'),
                                  ),
                                )
                              ],
                            )),
                        secondChild: AnimatedCrossFade(
                          sizeCurve: Curves.easeInOut,
                          duration: const Duration(milliseconds: 280),
                          crossFadeState: _isSearching ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                          firstChild: Container(
                            child: ProductSearchResults(
                              key: globalKeyProductSearchResults,
                              searchBoxController: searchBoxController,
                            ),
                          ),
                          secondChild: Flex(
                            direction: Axis.vertical,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(bottom: 15),
                                child: CategorySlider(),
                              ),
                              FutureBuilder(
                                future: homeResponse,
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
                                        return Container(
                                          child: Column(
                                            children: <Widget>[
                                              // _isLoggedIn ? BalanceMonederoBar(idMonedero: monederoId) : SizedBox(height: 0),
                                              AnimatedCrossFade(
                                                crossFadeState: sliders.length == 0 ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                                sizeCurve: Curves.easeInOut,
                                                duration: const Duration(milliseconds: 280),
                                                firstChild: SizedBox(
                                                  height: 0,
                                                ),
                                                secondChild: CarouselHomeBanner(
                                                  sliders: sliders,
                                                  size: 1,
                                                  foot: true,
                                                ),
                                              ),
                                              _isLoggedIn ? LastProductsBought() : SizedBox(),
                                              AnimatedCrossFade(
                                                crossFadeState: destacado.length == 0 ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                                sizeCurve: Curves.easeInOut,
                                                duration: const Duration(milliseconds: 280),
                                                firstChild: SizedBox(
                                                  height: 0,
                                                ),
                                                secondChild: CarouselHomeBanner(
                                                  sliders: destacado,
                                                  size: 1,
                                                  title: "Destacados",
                                                  foot: false,
                                                ),
                                              ),
                                              AnimatedCrossFade(
                                                crossFadeState: seccion.length == 0 ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                                sizeCurve: Curves.easeInOut,
                                                duration: const Duration(milliseconds: 280),
                                                firstChild: SizedBox(
                                                  height: 0,
                                                ),
                                                secondChild: LayoutBuilder(builder: (context, constraints) {
                                                  return Container(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.max,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: <Widget>[
                                                        seccion == null
                                                            ? CircularProgressIndicator(value: null)
                                                            : GridView.count(
                                                                physics: ClampingScrollPhysics(),
                                                                shrinkWrap: true,
                                                                primary: false,
                                                                crossAxisCount: 1,
                                                                childAspectRatio: constraints.maxWidth < 350 ? 36 / 32 : 36 / 26,
                                                                padding: EdgeInsets.only(top: 0, bottom: 0, right: 0, left: 0),
                                                                children: List.generate(
                                                                  seccion.length,
                                                                  (index) {
                                                                    return (ProductsSliderHome(seccion: seccion[index]));
                                                                  },
                                                                ),
                                                              ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                              ),
                                              AnimatedCrossFade(
                                                crossFadeState: list.length == 0 ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                                sizeCurve: Curves.easeInOut,
                                                duration: const Duration(milliseconds: 280),
                                                firstChild: SizedBox(
                                                  height: 0,
                                                ),
                                                secondChild: Container(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      GridView.count(
                                                        mainAxisSpacing: 1,
                                                        physics: ClampingScrollPhysics(),
                                                        shrinkWrap: true,
                                                        primary: true,
                                                        crossAxisCount: 1,
                                                        childAspectRatio: 1.5,
                                                        children: List.generate(
                                                          list.length,
                                                          (index) {
                                                            return (BannersHome(sliderImg: list[index]));
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              InkResponse(
                                                containedInkWell: true,
                                                enableFeedback: true,
                                                onTap: () {
                                                  showStores();
                                                },
                                                splashColor: DataUI.chedrauiColor,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                                                        child: UbicaTiendasSVG(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
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

                              // Padding(
                              //   padding: const EdgeInsets.only(top: 15, bottom: 15),
                              //   child: ChedrauiSloganSVG(),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          )),
    );
  }

  search(search) async {
    if (!loading) {
      setState(() {
        loading = true;
      });
      print(search);
      await ArticulosServices.getProductsHybrisSearch(search).then((response) {
        if (response != null) {
          setState(() {
            type = response['keywordRedirectUrl'];
            products = response;
            loading = false;
          });
          if (type != null) {
            if (type.contains('/c/')) {
              if (type.contains('/p/')) {
                var prodcutSplit = type.split('/p/');
                var product = prodcutSplit[1];
                print(product);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductPage(
                      code: product,
                    ),
                  ),
                );
                return;
              } else {
                var categorySplit = type.split('/c/');
                RegExp exp = new RegExp(r"MC([0-9]*)");
                String str = categorySplit[1];
                Iterable<RegExpMatch> categorys = exp.allMatches(str);
                var start = categorys.first.start;
                var end = categorys.first.end;
                var category = str.substring(start, end);
                print(category);
                switch (category.length) {
                  case 6:
                    level = '2';
                    break;
                  case 7:
                    level = '3';
                    break;
                  case 8:
                    level = '3';
                    break;
                  case 9:
                    level = '4';
                    break;
                  case 10:
                    level = '4';
                    break;
                  default:
                    level = "0";
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubCategoryPage(
                      title: capitalize(search),
                      level: level,
                      categoryID: category,
                    ),
                  ),
                );
              }
              // // return Container();
            }
            if (type.contains('/p/')) {
              var prodcutSplit = type.split('/p/');
              var product = prodcutSplit[1];
              print(product);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductPage(
                    code: product,
                  ),
                ),
              );
            }
          } else {
            print('Busqueda General');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductsPage(
                  searchTerm: search,
                  logEvent: true,
                ),
              ),
            );
          }
          setState(() {
            loading = false;
            _isSearching = false;
          });
        } else {
          setState(() {
            loading = false;
          });
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
      });
    } else {
      print('Ya');
    }
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///
  Future<void> startHome() async {
    // await getSlider();
    //  getDestacados();
    //  getProductsSliders();
    //  getBanners();
    // await getPreferences();
    // setState(() {
    //   _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    //   _idWallet = prefs.getString('idWallet') == null ? '' : prefs.getString('idWallet');
    // });

    // homeResponse = HomeServices.getHome(_idWallet);
    // var home = await homeResponse;

    // // for (dynamic din in home["data"]["banner"]) {
    // //   SliderImg sliderImg = new SliderImg();
    // //   sliderImg.url = din["url"].toString();
    // //   sliderImg.imagen = din["imagen"].toString();
    // //   if (mounted) {
    // //     setState(() {
    // //       list.add(sliderImg);
    // //     });
    // //   }
    // // }

    // return home;
    await getPreferences();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _idWallet = prefs.getString('idWallet') == null ? '' : prefs.getString('idWallet');
    });

    homeResponse = HomeServices.getHome(_idWallet);
    var home = await homeResponse;

    for (dynamic din in home["data"]["slider"]) {
      SliderImg sliderObj = new SliderImg();
      sliderObj.url = din["url"];
      sliderObj.imagen = din["imagen"];
      if (mounted) {
        setState(() {
          sliders.add(sliderObj);
        });
      }
    }

    for (dynamic din in home["data"]["destacado"]) {
      SliderImg sliderObj = new SliderImg();
      sliderObj.url = din["url"];
      sliderObj.imagen = din["imagen"];
      if (mounted) {
        setState(() {
          destacado.add(sliderObj);
        });
      }
    }

    for (dynamic din in home["data"]["seccion"]) {
      if (mounted) {
        setState(() {
          seccion.add(din);
        });
      }
    }

    for (dynamic din in home["data"]["banner"]) {
      SliderImg sliderImg = new SliderImg();
      sliderImg.url = din["url"].toString();
      sliderImg.imagen = din["imagen"].toString();
      if (mounted) {
        setState(() {
          list.add(sliderImg);
        });
      }
    }

    return home;
  }

  Future getPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  activateSearching(value) {
    setState(() {
      _isSearching = value;
      loading = false;
    });
    if (_isSearching) {
      globalKeyProductSearchResults.currentState.doSearch();
    }
    // print(_isSearching);
  }

  activateSearchingManual() {
    setState(() {
      _isSearching = !_isSearching;
    });
  }

  showStores() {
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
  }

  getSlider() async {
    await HomeServices.getKenticoSeccion('?system.type=sliders').then((res) {
      List resSliders = res['items'];
      resSliders.forEach((f) {
        SliderImg sliderImg = new SliderImg();
        sliderImg.url = f["elements"]['categoria__upc_o_sku']['value'];
        sliderImg.imagen = f["elements"]['imagen_del_slider']['value'][0]['url'];
        if (mounted) {
          setState(() {
            sliders.add(sliderImg);
          });
        }
      });
    });
  }

  getDestacados() async {
    await HomeServices.getKenticoSeccion('?system.type=productos_destacados').then((res) {
      List resDestacados = res['items'];
      resDestacados.forEach((f) {
        SliderImg sliderObj = new SliderImg();
        sliderObj.url = f["elements"]['codigo_de_la_seccion']['value'];
        sliderObj.imagen = f["elements"]['imagen_del_producto_destacado']['value'][0]['url'];
        if (mounted) {
          setState(() {
            destacado.add(sliderObj);
          });
        }
      });
    });
  }

  getProductsSliders() async {
    await HomeServices.getKenticoSeccion('?system.type=seccion_de_productos').then((res) {
      List resSlidersProductos = res['items'];
      resSlidersProductos.forEach((f) {
        if (mounted) {
          setState(() {
            seccion.add(f);
          });
        }
      });
    });
  }

  getBanners() async {
    await HomeServices.getKenticoSeccion('?system.type=promo_banner').then((res) {
      List resBanners = res['items'];
      resBanners.forEach((f) {
        SliderImg sliderImg = new SliderImg();
        sliderImg.url = f["elements"]['categoria__upc_o_sku']['value'];
        sliderImg.imagen = f["elements"]['banner_background_image']['value'][0]['url'];
        if (mounted) {
          setState(() {
            list.add(sliderImg);
          });
        }
      });
    });
  }
}
