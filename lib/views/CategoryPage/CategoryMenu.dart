import 'package:chd_app_demo/services/CategoryServices.dart';
import 'package:chd_app_demo/services/ArticulosServices.dart';
import 'package:chd_app_demo/services/FireBaseServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/views/CategoryPage/SubCategoryPage.dart';

class CategoryMenu extends StatefulWidget {
  final String apartmentId;
  final Widget currentWidget;
  CategoryMenu({Key key, this.apartmentId, this.currentWidget}) : super(key: key);

  _CategoryMenuState createState() => _CategoryMenuState();
}

class _CategoryMenuState extends State<CategoryMenu> {
  ScrollController _scrollController = new ScrollController();
  ScrollController _scrollControllerText = new ScrollController();
  bool isOpen = false;
  List categoryStack = [];
  List nameStack = [];
  List categories;
  String level;
  String url;
  List productData;
  String name;
  int currentview = 0;
  bool loading;

  initState() {
    getCategory('MC');
    super.initState();
  }

  getCategory(id) async {
    if (mounted) {
      setState(() {
        loading = true;
      });
      if (id == 'MC') {
        await CategoryServices.getApartments().then((categorys) async {
          if (categorys != null && mounted) {
            setState(() {
              categoryStack.add('MC');
              nameStack.add('Departamentos');
              categories = categorys;
              name = 'Departamentos';
            });
            if (categories.length == 0) {
              setState(() {
                loading = false;
                _scrollControllerText.animateTo(
                  _scrollControllerText.position.maxScrollExtent,
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 300),
                );
              });
              // getProducts(categoryStack[currentview], nameStack[currentview]);
            } else {
              setState(() {
                loading = false;
                _scrollControllerText.animateTo(
                  _scrollControllerText.position.maxScrollExtent,
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 300),
                );
              });
            }
          }
        });
      } else {
        await CategoryServices.getAllSubCategorys(id).then((categorys) async {
          if (categorys != null && mounted) {
            var categoriesAux;
            setState(() {
              categoriesAux = categorys['subcategories'];
            });
            if (categoriesAux.length == 0) {
              await getProducts(categorys['categoryCode'], categorys['name']);
              currentview--;

              setState(() {
                loading = false;
                // _scrollControllerText.animateTo(
                //   _scrollControllerText.position.maxScrollExtent,
                //   curve: Curves.easeOut,
                //   duration: const Duration(milliseconds: 300),
                // );
              });
            } else {
              setState(() {
                categories = categorys['subcategories'];
                categoryStack.add(categorys['categoryCode']);
                nameStack.add(categorys['name'] != null ? categorys['name'] : categorys['id']);

                name = categorys['name'];
                loading = false;
                _scrollControllerText.animateTo(
                  _scrollControllerText.position.maxScrollExtent,
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 300),
                );
              });
            }
          }
        });
      }
    }
  }

  getProducts(id, name) async {
    if (id != null) {
      switch (id.length) {
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
          level = "1";
      }
    }
    url = ':relevance' + ':category_l_' + level + ':' + id;

    await ArticulosServices.getCategoryProductsFromHybris(url).then((products) {
      setState(() {
        productData = products['products'];
      });
      if (productData.length > 0) {
        setState(() {
          isOpen = !isOpen;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: RouteSettings(name: DataUI.subCategoryRoute),
            builder: (context) => SubCategoryPage(
              title: name,
              level: level,
              categoryID: id,
            ),
          ),
        );
      } else {
        _showResponseDialog();
      }
    });
    return "Success!";
  }

  _showResponseDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Búsqueda de productos"),
            content: Text('Pronto podrán ver estos productos en la aplicación, estamos trabajando en ello'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Cerrar",
                  style: TextStyle(
                    color: HexColor('#454F5B'),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        });
  }

  openMenu() {
    setState(() {
      _scrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
      isOpen = !isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isOpen ? Colors.white : HexColor('#F0EFF4'),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(30),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(width: 1.0, color: HexColor('#ECECEC')),
            ),
          ),
          height: 45,
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(width: 1.0, color: HexColor('#ECECEC')),
                  ),
                ),
                child: GestureDetector(
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Departamentos',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Archivo', color: HexColor('#0D47A1')),
                        ),
                        Icon(
                          isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: HexColor('#0D47A1'),
                          size: 18,
                        )
                      ],
                    ),
                    onTap: loading ? null : openMenu),
              ),
              Container(
                margin: EdgeInsets.only(left: 10),
                height: 45,
                width: MediaQuery.of(context).size.width * 0.6,
                child: ListView.builder(
                    controller: _scrollControllerText,
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: nameStack == null ? 0 : nameStack.length,
                    itemBuilder: (context, int index) {
                      if (index == currentview) {
                        return GestureDetector(
                          onTap: () {
                            print(index);
                          },
                          child: Container(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    nameStack[index],
                                    style: TextStyle(
                                      color: HexColor('#0D47A1'),
                                      fontFamily: 'Archivo',
                                      fontSize: 12,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 10,
                                    color: HexColor('#0D47A1'),
                                  )
                                ],
                              )),
                        );
                      } else {
                        return GestureDetector(
                          onTap: () async {
                            print(index);
                            setState(() {
                              loading = true;
                              currentview = index;
                              nameStack.removeRange(index + 1, nameStack.length);
                              categoryStack.removeRange(index + 1, categoryStack.length);
                            });
                            if (nameStack[index] == 'Departamentos') {
                              await CategoryServices.getApartments().then((categorys) async {
                                if (categorys != null && mounted) {
                                  setState(() {
                                    categories = categorys;
                                    name = 'Departamentos';
                                    loading = false;
                                  });
                                }
                              });
                            } else {
                              await CategoryServices.getAllSubCategorys(categoryStack[currentview]).then((result) {
                                setState(() {
                                  categories = result['subcategories'];
                                  name = result['name'];
                                  loading = false;
                                });
                                print('object');
                              });
                              // setState(() {
                              //   currentview = index;
                              // });
                            }
                          },
                          child: Container(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    nameStack[index],
                                    style: TextStyle(
                                      color: HexColor('#0D47A1').withOpacity(0.5),
                                      fontFamily: 'Archivo',
                                      fontSize: 12,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 10,
                                    color: HexColor('#0D47A1').withOpacity(0.5),
                                  )
                                ],
                              )),
                        );
                      }
                    }),
              )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        controller: _scrollController,
        child: AnimatedCrossFade(
          sizeCurve: Curves.easeInOut,
          duration: const Duration(milliseconds: 280),
          firstChild: this.widget.currentWidget,
          secondChild: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              !loading
                  ? nameStack != null
                      ? Container(
                          color: HexColor('#FFFFFF'),
                          // duration: new Duration(milliseconds: 300),
                          width: double.infinity,
                          height: isOpen ? MediaQuery.of(context).size.height * 0.76 : 0,
                          child: categoryStack.length >= 2 && categories.length > 0
                              ? Container(
                                  //height: double.infinity,
                                  margin: EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      GestureDetector(
                                          child: Row(
                                            children: <Widget>[
                                              Container(
                                                child: Icon(
                                                  Icons.arrow_back_ios,
                                                  size: 15,
                                                ),
                                                margin: EdgeInsets.only(right: 8.5),
                                              ),
                                              Text('Volver' + ' a ' + nameStack[0],
                                                  style: TextStyle(
                                                    color: HexColor('#0D47A1'),
                                                    fontFamily: 'Archivo',
                                                    fontSize: 12,
                                                  )),
                                            ],
                                          ),
                                          onTap: () async {
                                            setState(() {
                                              _scrollControllerText.animateTo(
                                                _scrollControllerText.position.maxScrollExtent,
                                                curve: Curves.easeOut,
                                                duration: const Duration(milliseconds: 300),
                                              );
                                              currentview--;
                                              loading = true;
                                              nameStack.removeLast();
                                              categoryStack.removeLast();
                                            });
                                            if (categoryStack[currentview] == 'MC') {
                                              await CategoryServices.getApartments().then((categorys) async {
                                                if (categorys != null && mounted) {
                                                  setState(() {
                                                    categories = categorys;
                                                    name = 'Departamentos';
                                                    loading = false;
                                                  });
                                                }
                                              });
                                            } else {
                                              await CategoryServices.getAllSubCategorys(categoryStack[currentview]).then((result) {
                                                setState(() {
                                                  categories = result['subcategories'];
                                                  name = result['name'];
                                                  loading = false;
                                                });
                                                print('object');
                                              });
                                            }
                                          }),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 8,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  margin: EdgeInsets.symmetric(vertical: 18),
                                                  child: MCSVG(90, categoryStack[1]),
                                                ),
                                                Container(
                                                  child: Text(
                                                    nameStack[currentview],
                                                    style: TextStyle(color: HexColor('#0D47A1'), fontSize: 24, fontFamily: 'Archivo', fontWeight: FontWeight.bold),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: categories.length > 1
                                                ? Center(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (nameStack.length == 2) {
                                                          FireBaseEventController.sendAnalyticsEventSelectedDepartment(nameStack[1]);
                                                        } else if (nameStack.length == 3) {
                                                          FireBaseEventController.sendAnalyticsEventSelectedCategory(nameStack[1], nameStack[nameStack.length - 1]);
                                                        } else if (nameStack.length > 3) {
                                                          FireBaseEventController.sendAnalyticsEventSelectedCategoryDepartment(nameStack[1], nameStack[2], nameStack[nameStack.length - 1]);
                                                        }
                                                        getProducts(categoryStack[currentview], nameStack[currentview]);
                                                      },
                                                      child: Text('Ver todos',
                                                          style: TextStyle(
                                                            color: HexColor('#0D47A1'),
                                                            fontFamily: 'Archivo',
                                                            fontSize: 12,
                                                          )),
                                                    ),
                                                  )
                                                : SizedBox(),
                                          )
                                        ],
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(vertical: 15),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(width: 1.0, color: HexColor('#D9D9D9')),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          child: ListView.builder(
                                        physics: ClampingScrollPhysics(),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount: categories == null ? 0 : categories.length,
                                        itemBuilder: (context, index) {
                                          return categories[index]['categoryCode'] == null
                                              ? SizedBox(
                                                  height: 0,
                                                )
                                              : GestureDetector(
                                                  onTap: () {
                                                    currentview++;
                                                    getCategory(categories[index]['categoryCode']);
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.symmetric(vertical: 15),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        Text(
                                                          categories[index]['name'] ?? categories[index]['id'],
                                                          style: TextStyle(color: HexColor('#212B36'), fontSize: 18, fontFamily: 'Archivo', fontWeight: FontWeight.normal),
                                                        ),
                                                        Icon(Icons.arrow_forward_ios)
                                                      ],
                                                    ),
                                                  ));
                                        },
                                      ))
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  physics: ClampingScrollPhysics(),
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: categories == null ? 0 : categories.length,
                                  itemBuilder: (context, index) {
                                    return categories == null
                                        ? SizedBox(
                                            height: 0,
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              _scrollControllerText.animateTo(
                                                _scrollControllerText.position.maxScrollExtent,
                                                curve: Curves.easeOut,
                                                duration: const Duration(milliseconds: 300),
                                              );
                                              currentview++;
                                              getCategory(categories[index]['categoryCode']);
                                              print(currentview);
                                            },
                                            child: Container(
                                              margin: EdgeInsets.all(15),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    categories[index]['name'],
                                                    style: TextStyle(color: HexColor('#0D47A1'), fontSize: 21, fontFamily: 'Archivo', fontWeight: FontWeight.bold),
                                                  ),
                                                  Icon(Icons.arrow_forward_ios)
                                                ],
                                              ),
                                            ));
                                  },
                                ),
                        )
                      : SizedBox()
                  : Container(
                      color: Colors.white,
                      height: MediaQuery.of(context).size.height * 0.76,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
            ],
          ),
          crossFadeState: isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        ),
      ),
    );
  }
}
