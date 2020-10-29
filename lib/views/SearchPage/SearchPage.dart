import 'package:chd_app_demo/services/ArticulosServices.dart';
import 'package:chd_app_demo/services/FireBaseServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/CategoryPage/CategoryPage.dart';
import 'package:chd_app_demo/views/CategoryPage/SubCategoryPage.dart';
import 'package:chd_app_demo/views/HomePage/DepartmentsCard.dart';
import 'package:chd_app_demo/views/HomePage/ProductsSearchResults.dart';
import 'package:chd_app_demo/views/HomePage/SearchProductsBar.dart';
import 'package:chd_app_demo/views/ProductPage/ProductPage.dart';
import 'package:chd_app_demo/views/ProductsPage/ProductsPage.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:flutter/material.dart';
import 'package:strings/strings.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key}) : super(key: key);

  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchBoxController = TextEditingController();
  GlobalKey<ProductSearchResultsState> globalKeyProductSearchResults;
  bool _isSearching = false;
  bool _isLoading = false;
  List data;
  String query = '';
  String url;
  int totalResultsFinal = 0;

  String type;
  var products;
  bool loading = false;
  String level;
  @override
  void initState() {
    globalKeyProductSearchResults = GlobalKey();
    super.initState();
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DataUI.backgroundColor2,
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SearchProducts(
              activateSearching,
              search,
              activateSearchingManual,
              searchBoxController: searchBoxController,
              autoFocus: false,
            ),
            AnimatedCrossFade(
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
              crossFadeState: loading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              secondChild: Column(
                children: <Widget>[
                  AnimatedCrossFade(
                    firstChild: Column(
                      children: <Widget>[
                        DepartmentsCard(),
                      ],
                    ),
                    crossFadeState: searchBoxController.text.length > 0 ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    secondChild: SizedBox(),
                    sizeCurve: Curves.easeInOut,
                    duration: const Duration(milliseconds: 280),
                  ),
                  searchBoxController.text.length > 0
                      ? AnimatedCrossFade(
                          sizeCurve: Curves.easeInOut,
                          duration: const Duration(milliseconds: 280),
                          crossFadeState: _isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                          firstChild: Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Container(
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
                                ),
                              ),
                            ),
                          ),
                          secondChild: Container(
                            margin: EdgeInsets.only(top: 15, left: 10, right: 10),
                            padding: EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 10),
                            color: Colors.transparent,
                            child: Scrollbar(
                              child: ListView.separated(
                                separatorBuilder: (context, index) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(width: 1.0, color: HexColor('#979797').withOpacity(0.5)),
                                      ),
                                    ),
                                  );
                                },
                                padding: EdgeInsets.only(bottom: 160),
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                itemCount: data == null ? 0 : data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return ListTile(
                                    dense: true,
                                    onLongPress: () {
                                      searchBoxController.text = data[index]['name'];
                                      doSearch();
                                    },
                                    title: Container(
                                      child: Text(
                                        data[index]['name'],
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontFamily: 'Rubik', fontSize: 14, color: HexColor('#454F5B')),
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(vertical: 6.71),
                                    trailing: IconButton(
                                      onPressed: () {
                                        searchBoxController.text = data[index]['name'];
                                        doSearch();
                                      },
                                      icon: RotationTransition(
                                        turns: new AlwaysStoppedAnimation(45 / 360),
                                        child: new Icon(
                                          Icons.arrow_back,
                                          color: HexColor('#454F5B').withOpacity(0.8),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      FireBaseEventController.sendAnalyticsEventSearchResults(searchBoxController.text, totalResultsFinal).then((ok) {});
                                      // FireBaseEventController.sendAnalyticsEventViewItem(data[index]['code'], data[index]['name'], '').then((ok) {});
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          settings: RouteSettings(name: DataUI.productRoute),
                                          builder: (context) => ProductPage(
                                            // data: data[index],
                                            code: data[index]['code'],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),
                ],
              ),
              sizeCurve: Curves.easeInOut,
              duration: const Duration(milliseconds: 280),
            ),
          ],
        ),
      ),
    );
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  search(search) async {
    setState(() {
      loading = true;
    });
    print(search);
    await ArticulosServices.getProductsHybrisSearch(search).then((response) {
      setState(() {
        type = response['keywordRedirectUrl'];
        products = response;
        loading = false;
      });
    });

    if (type != null) {
      if (type.contains('/c/')) {
        var categorySplit = type.split('/c/');
        var category = categorySplit[1];
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
        // return Container();
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
  }

  doSearch() {
    query = searchBoxController.text.replaceAll(' ', '+');
    url = query + '&fields=BASIC';
    print('doSearch: ' + query);
    setState(() {
      _isLoading = true;
    });
    ArticulosServices.getProductsHybrisSearch(url).then(
      (products) {
        if (products != null) {
          totalResultsFinal = products['pagination']['totalResults'];
          setState(() {
            data = products['products'];
            _isLoading = false;
            // print(_totalResultsFinal.toString());
          });
        }
      },
    );
    return "Success!";
  }

  activateSearching(value) {
    setState(() {
      _isSearching = value;
    });
    if (_isSearching) {
      doSearch();
    }
  }

  activateSearchingManual() {
    setState(() {
      _isSearching = !_isSearching;
    });
  }
}
