import 'package:chd_app_demo/services/CategoryServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/CategoryPage/CategoryMenu.dart';
// import 'package:chedraui_flutter/utils/sliderData.dart';
// import 'package:chedraui_flutter/views/CarritoPage/CarritoPage.dart';
import 'package:chd_app_demo/views/Errors/NetworkErrorPage/NetworkErrorPage.dart';
// import 'package:chedraui_flutter/views/ListasPage/ListasPage.dart';
// import 'package:chedraui_flutter/views/SearchPage/SearchPage.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';
import 'package:chd_app_demo/widgets/comparadorBanner.dart';
import 'package:chd_app_demo/widgets/footerNavigation.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/widgets/productsSlider.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryPage extends StatefulWidget {
  final String apartmentId;
  final String apartmentName;
  final String parentId;
  final String parentName;

  CategoryPage({
    Key key,
    this.apartmentId,
    this.apartmentName,
    this.parentId,
    this.parentName,
  }) : super(key: key);

  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  SharedPreferences prefs;

  bool _isLoggedIn = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSubcategorys();
    getPreferences().then((x) {
      setState(() {
        _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      });
    });
  }

  Future getPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  List data;

  Future categoryResponse;
  getSubcategorys() async {
    categoryResponse = CategoryServices.getAllSubCategorys(widget.apartmentId);
    var categorys = await categoryResponse;
    setState(() {
      data = categorys['subcategories'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return WidgetContainer(
      Scaffold(
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
            widget.apartmentName,
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
        body: FutureBuilder(
          future: categoryResponse,
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
                    currentWidget: Column(
                      children: <Widget>[
                        _isLoggedIn ? Comparador() : Container(),
                        // CategoryChip(
                        //   apartmentId: widget.apartmentId,
                        // ),
                        Container(
                          margin: EdgeInsets.only(top: 15),
                          child: ListView.builder(
                            physics: ClampingScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: data == null ? 0 : data.length,
                            itemBuilder: (context, index) {
                              return data != null && data[index]['categoryCode'] != null
                                  ? ProductsSlider(
                                      parentView: widget.apartmentName,
                                      title: data[index]['name'] ?? data[index]['id'],
                                      id: data[index]['categoryCode'],
                                    )
                                  : SizedBox();
                            },
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
        bottomNavigationBar: FooterNavigation(
          (val) {},
          mainNavigation: false,
        ),
      ),
    );
  }
}
