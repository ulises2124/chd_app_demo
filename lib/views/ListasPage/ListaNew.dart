import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chd_app_demo/services/ArticulosServices.dart';
import 'package:chd_app_demo/services/FireBaseServices.dart';
import 'package:chd_app_demo/services/ListasServices.dart';
import 'package:chd_app_demo/utils/FormatCreditCard.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
//import 'package:chd_app_demo/views/HomePage/ProductsSearchResults.dart';
//import 'package:chd_app_demo/views/HomePage/SearchProductsBar.dart';
import 'package:chd_app_demo/views/ListasPage/ListaProducts.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/services.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:permission_handler/permission_handler.dart';

class ListaNew extends StatefulWidget {
  ListaNew({Key key}) : super(key: key);

  ListaNewState createState() => ListaNewState();
}

class ListaNewState extends State<ListaNew> {
  TextEditingController searchBoxController = TextEditingController();
  TextEditingController txtTicket = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String ticket;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String listName;
  bool _isSearching = false;
  String _searchQuery = '';
  List newProductsTicket = [];
  List newProducts = [];
  List data;
  bool _switchIcons = false;
  String barcodeProduct;
  Timer _timer;
  bool listcreated;

  bool loading = false;
  bool _hasCameraAccess;

  PermissionStatus _permissionsStatus;

  bool ticketScan;
  int countScan = 1;

  void _onPermissionStatusRequested(Map<PermissionGroup, PermissionStatus> statuses) {
    final status = statuses[PermissionGroup.camera];
    if (status != PermissionStatus.granted) {
      if (Platform.isIOS) {
        _showCameraDialog();
      }
    } else {
      _updatePermissions(status);
    }
  }

  _listenForPermissionStatus() {
    PermissionHandler().checkPermissionStatus(PermissionGroup.camera).then(_updatePermissions);
  }

  Future _updatePermissions(PermissionStatus status) async {
    if (mounted) {
      setState(() {
        _permissionsStatus = status;
        _hasCameraAccess = _permissionsStatus == PermissionStatus.granted ? true : false;
      });
      if (!_hasCameraAccess) {
        _askCameraPermission();
      } else {
        if (ticketScan == true) {
          scanTicket();
        } else {
          scanProducts(context);
        }
      }
    }
  }

  _askCameraPermission() {
    PermissionHandler().requestPermissions([PermissionGroup.camera]).then((result) {
      if (result[PermissionGroup.camera] == PermissionStatus.denied) {
        _showCameraDialog();
      } else {
        _onPermissionStatusRequested(result);
      }
    }).catchError((onError) {
      print(onError);
    });
  }

  _showCameraDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Icon(
              Icons.camera_alt,
              size: 52,
              color: DataUI.chedrauiColor,
            ),
          ),
          content: Text(
            'Por favor habilita tu cámara para ofrecerte la mejor experiencia',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: DataUI.textOpaque,
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  PermissionHandler().openAppSettings().then((bool hasOpened) {
                    debugPrint('App Settings opened: ' + hasOpened.toString());
                  });
                },
                child: Text(
                  "Habilitar",
                  style: TextStyle(
                    color: DataUI.chedrauiBlueColor,
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

  Future<void> scan(bool ticket) async {
    if (ticket == true) {
      setState(() {
        ticketScan = true;
      });
    } else {
      setState(() {
        ticketScan = false;
      });
    }
    await _listenForPermissionStatus();
  }

  @override
  void initState() {
    //doSearch();
    super.initState();
  }

  listaSearch() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 50),
      padding: const EdgeInsets.all(3.0),
      decoration: new BoxDecoration(
        border: new Border.all(
          color: HexColor('#C4CDD5'),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                color: HexColor('#919EAB'),
                icon: _switchIcons ? Icon(Icons.close) : Icon(Icons.search),
                onPressed: () {
                  activateSearchingManual();
                  setState(() {
                    _switchIcons = !_switchIcons;
                  });
                  if (_switchIcons == false) {
                    searchBoxController.clear();
                    FocusScope.of(context).requestFocus(new FocusNode());
                  }
                },
              ),
            ],
          ),
          Flexible(
            child: TextField(
              textInputAction: TextInputAction.search,
              controller: searchBoxController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Encuentra tus productos aquí ',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              onEditingComplete: () {
                gotoSearch();
              },
              onChanged: (value) {
                search(value);
              },
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _switchIcons
                  ? SizedBox(
                      height: 0,
                    )
                  : IconButton(
                      color: HexColor('#919EAB'),
                      icon: Icon(Icons.camera_alt),
                      onPressed: () {
                        scan(false);
                      },
                    ),
            ],
          ),
        ],
      ),
    );
  }

  void search(value) {
    if (value.length > 1) {
      setState(() {
        _switchIcons = true;
        _isSearching = true;
      });
      if (_isSearching) {
        doSearch();
      }
    } else {
      setState(() {
        _switchIcons = false;
        _isSearching = false;
      });
    }
  }

  Future<void> scanProducts(BuildContext context) async {
    try {
      print("Entro scan");
      String barcode = await BarcodeScanner.scan();

      setState(() => //this.barcode = barcode;
          this.barcodeProduct = barcode);

      print("salgo scan");
      print("barcode1: $barcode");

      if (barcode.length >= 12) {
        barcode = barcode.substring(0, 12);
      }

      print("barcode2: $barcode");

      ArticulosServices.getProductsHybrisSearch(barcode).then(
        (products) {
          if (products != null) {
            print("*********> paso1");
            print(products);
            print("*********> paso2");
            print(products["products"]);
            print("*********> paso3");
            print(products["products"].length);

            if (products["products"].length == 0) {
              FireBaseEventController.sendAnalyticsEventScanProductFail(barcode).then((ok) {});
              return showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Busqueda de productos'),
                    content: Text("No se encontró producto relacionado al código de barras ingresado"),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Ok'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }

            print("*********> paso4");
            print(products["products"][0]);
            print("*********> paso5");
            FireBaseEventController.sendAnalyticsEventScanProduct(products["products"][0]['name'], countScan).then((ok) {});
            countScan++;
            gotoSearchBarcode(barcode);
          } else {
            FireBaseEventController.sendAnalyticsEventScanProductFail(barcode).then((ok) {});
            return showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Busqueda de productos'),
                  content: Text("No se encontró producto relacionado al código de barras ingresado"),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Ok'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
      );
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcodeProduct = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcodeProduct = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.barcodeProduct = 'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcodeProduct = 'Unknown error: $e');
    }
  }

  activateSearchingManual() {
    print(_isSearching);
    setState(() {
      _isSearching = !_isSearching;
    });
    if (_isSearching) {
      doSearch();
    }
  }

  gotoSearchBarcode(barcode) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: DataUI.listasSearchRoute),
        builder: (context) => ListaProducts(
          searchTerm: barcode,
        ),
      ),
    );
    if (result != null) {
      if (result != 'none') {
        if (newProducts.length > 0) {
          await Future.forEach(result, (product) {
            var f;
            f = newProducts.firstWhere((newproduct) => newproduct['code'] == product['code'], orElse: () => false);
            if (f != null) {
              if (f == false) {
                newProducts.add(product);
              } else {
                showErrorMessage();
              }
            } else {
              newProducts.add(product);
            }
          });
        } else {
          await Future.forEach(result, (add) {
            newProducts.add(add);
          });
        }
      }
    }
  }

  gotoSearch() async {
    setState(() {
      _isSearching = false;
    });
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: DataUI.listasSearchRoute),
        builder: (context) => ListaProducts(
          searchTerm: searchBoxController.text,
        ),
      ),
    );
    setState(() {
      _isSearching = false;
    });
    if (result != null) {
      if (result != 'none') {
        if (newProducts.length > 0) {
          await Future.forEach(result, (product) {
            var f;
            f = newProducts.firstWhere((newproduct) => newproduct['code'] == product['code'], orElse: () => false);
            if (f != null) {
              if (f == false) {
                newProducts.add(product);
              } else {
                showErrorMessage();
              }
            } else {
              newProducts.add(product);
            }
          });
        } else {
          await Future.forEach(result, (add) {
            newProducts.add(add);
          });
        }
      }
    }
    setState(() {
      _isSearching = false;
    });
  }

  void showErrorMessage() {
    Flushbar(
      message: "El producto ya ha sido agregado.",
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
    _timer = new Timer(const Duration(milliseconds: 2000), () {
      Navigator.pop(context, 'reload');
    });
  }

  doSearch() {
    var query = searchBoxController.text.replaceAll(' ', '+');
    var url = query + '&fields=BASIC';
    print('doSearch: ' + query);
    ArticulosServices.getProductsHybrisSearch(url).then(
      (products) {
        if (products != null) {
          setState(() {
            data = products['products'];
          });
        }
      },
    );
    return "Success!";
  }

  saveList() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        loading = true;
      });
      listName = listName.replaceAll(' ', '+');
      await ListasServices.createList(listName).then((response) async {
        if (response['code'] != null) {
          var listID = response['code'];
          if (newProducts.length != 0) {
            await Future.forEach(newProducts, (product) async {
              await ListasServices.addProduct(listID, product['code'], '1.0').then((res) {
                print(res);
                if (res == true) {
                  setState(() {
                    listcreated = true;
                  });
                }
              });
            });
          }
          if (newProductsTicket.length != 0) {
            await Future.forEach(newProductsTicket, (product) async {
              await ListasServices.addProduct(listID, product['product']['code'], '1.0').then((res) {
                print(res);
                if (res == true) {
                  setState(() {
                    listcreated = true;
                  });
                }
              });
            });
          }
          if (listcreated == true) {
            setState(() {
              loading = false;
            });
            Navigator.pop(context);
            showwsuccess(response['name']);
          } else {
            setState(() {
              loading = false;
            });
            Navigator.pop(context);
            showErrorList();
          }
        } else {
          Navigator.pop(context);
          setState(() {
            loading = false;
          });
          if (response['errorMessage'] == "Duplicate shopping list name exists for user.") {
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
          }
        }
      });
    }
  }

  pop() {
    Navigator.pop(context);
  }

  createList() {
    // _formKey.currentState.reset();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
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
                  inputFormatters: [WhitelistingTextInputFormatter(RegExp(r'^((?=.*[0-9])|(?=.*[a-z])|(?=.*[A-Z])|(?=.*[\ \-\!\$\%\^\&\*\(\)\_\+\|\~\=\`\{\}\[\]\:\"\;\<\>\?\,\.\/])).{1,}$'))],
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
                onPressed: !loading ? pop : null,
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
                onPressed: !loading ? saveList : null,
                child: !loading
                    ? Text(
                        "Guardar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      )
                    : SizedBox(
                        height: 13,
                        width: 13,
                        child: CircularProgressIndicator(),
                      ),
              ),
            )
          ],
        );
      },
    );
  }

  listaSearchResults() {
    return Container(
      color: HexColor('#F4F6F8'),
      child: data == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(100.0),
                child: CircularProgressIndicator(value: null),
              ),
            )
          : ListView.separated(
              separatorBuilder: (context, index) {
                return Divider();
              },
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: data == null ? 0 : data.length,
              padding: EdgeInsets.symmetric(vertical: 0),
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          IconButton(
                            color: HexColor('#212B36').withOpacity(0.5),
                            onPressed: () {
                              searchBoxController.text = data[index]['name'];
                              doSearch();
                            },
                            icon: Icon(Icons.search),
                          ),
                          FlatButton(
                            onPressed: () {
                              gotoSearch();
                            },
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                data[index]['name'],
                                maxLines: 1,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: HexColor('#212B36').withOpacity(0.5)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  bool changeView = false;

  toggleButton() {
    return Container(
      margin: EdgeInsets.only(top: 15, right: 30, left: 30, bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FlatButton(
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
            onPressed: () {
              setState(() {
                changeView = false;
              });
            },
            color: changeView == false ? HexColor("#F57C00") : HexColor("#F4F6F8"),
            child: Text(
              "Agregar productos",
              style: TextStyle(
                fontFamily: "Rubik",
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: changeView == false ? HexColor("#F9FAFB") : HexColor("#454F5B"),
              ),
            ),
          ),
          FlatButton(
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
            onPressed: () {
              setState(() {
                changeView = true;
              });
            },
            color: changeView == true ? HexColor("#F57C00") : HexColor("#F4F6F8"),
            child: Text(
              "Agregar ticket",
              style: TextStyle(
                fontFamily: "Rubik",
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: changeView == true ? HexColor("#F9FAFB") : HexColor("#454F5B"),
              ),
            ),
          )
        ],
      ),
    );
  }

  getTicket(barcode) {
    ListasServices.ticketToLista(barcode).then((onValue) {
      setState(() {
        txtTicket.text = barcode;
        newProductsTicket = onValue['products'];
      });
    }).catchError((onError) {
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
    });
  }

  scanTicket() async {
    try {
      print("Entro scan ticket");
      String barcode = await BarcodeScanner.scan();
      barcode = barcode.substring(0, 19);
      print(barcode.length);
      if (barcode.length != 19) {
        Flushbar(
          message: "Por favor ingrese un ticket valido.",
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
      } else {
        await getTicket(barcode);
      }
      print("salgo scan");
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.ticket = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.ticket = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.ticket = 'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.ticket = 'Unknown error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WidgetContainer(
      Scaffold(
        key: _scaffoldKey,
        appBar: _isSearching
            ? null
            : GradientAppBar(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    HexColor('#F56D00'),
                    HexColor('#F56D00'),
                    HexColor('#F78E00'),
                  ],
                ),
                actions: <Widget>[
                  //  IconButton(
                  //   icon: Icon(Icons.create),
                  //   onPressed: () {},
                  // ),
                ],
                leading: Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context, 'reload'),
                    );
                  },
                ),
                elevation: 1,
                title: Text("Crear Nueva Lista", style: TextStyle(color: Colors.white, fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 19)),
                centerTitle: true,
                // toolbarOpacity: 0.0,
              ),
        body: Builder(
          builder: (BuildContext contex) {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Column(
                  children: <Widget>[
                    Flex(
                      direction: Axis.vertical,
                      children: <Widget>[
                        AnimatedCrossFade(
                          sizeCurve: Curves.easeInOut,
                          duration: const Duration(milliseconds: 280),
                          firstChild: SizedBox(
                            height: 0,
                          ),
                          secondChild: Column(
                            children: <Widget>[
                              toggleButton(),
                              changeView
                                  ? Container(
                                      margin: EdgeInsets.symmetric(horizontal: 15),
                                      child: Text(
                                        "Crea una nueva lista ingresando o escaneando el número de ticket de tu recibo impreso.",
                                        style: TextStyle(
                                          fontFamily: "Rubik",
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          color: HexColor("#637381"),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      margin: EdgeInsets.symmetric(horizontal: 15),
                                      child: Text(
                                        "Busca y agrega productos a tu lista de compras o bien agrégalos escaneando sus códigos de barras.",
                                        style: TextStyle(
                                          fontFamily: "Rubik",
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          color: HexColor("#637381"),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                          crossFadeState: _isSearching ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                        ),
                        changeView
                            ? Theme(
                                data: ThemeData(
                                  primaryColor: HexColor('#C4CDD5'),
                                  hintColor: HexColor('#C4CDD5'),
                                ),
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(),
                                    controller: txtTicket,
                                    onFieldSubmitted: getTicket,
                                    decoration: InputDecoration(
                                      suffixIcon: IconButton(
                                        icon: Icon(Icons.camera_alt),
                                        onPressed: () {
                                          scan(true);
                                        },
                                      ),
                                      contentPadding: EdgeInsets.all(10),
                                      border: OutlineInputBorder(),
                                      fillColor: HexColor("#F4F6F8"),
                                      filled: true,
                                      hintText: '1903 0817 3024 1120 334',
                                      hintStyle: TextStyle(
                                        fontSize: 14.0,
                                        color: HexColor('#C4CDD5'),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Por favor rellene este campo';
                                      }
                                      if (value.length != 19) {
                                        return 'Introduce un número de ticket válido.';
                                      }
                                    },
                                  ),
                                ),
                              )
                            : listaSearch(),
                        AnimatedCrossFade(
                          sizeCurve: Curves.easeInOut,
                          duration: const Duration(milliseconds: 280),
                          firstChild: SizedBox(
                            height: 0,
                          ),
                          secondChild: newProducts.length > 0 || newProductsTicket.length > 0
                              ? Container(
                                  margin: EdgeInsets.all(15),
                                  child: Column(
                                    children: <Widget>[
                                      ListView.builder(
                                        physics: ClampingScrollPhysics(),
                                        shrinkWrap: true,
                                        primary: false,
                                        // shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount: newProducts == null ? 0 : newProducts.length,
                                        itemBuilder: (context, index) {
                                          print(newProducts[index]);
                                          return Slidable(
                                            delegate: SlidableDrawerDelegate(),
                                            actionExtentRatio: 0.25,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: BorderDirectional(
                                                  bottom: BorderSide(
                                                    color: HexColor("#EFEFEF"),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                              height: 72,
                                              child: Padding(
                                                padding: EdgeInsets.all(15),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Row(
                                                      children: <Widget>[
                                                        newProducts[index]['images'] != null
                                                            ? Container(
                                                                height: 48,
                                                                width: 48,
                                                                child: Image.network(
                                                                  "https://prod.chedraui.com.mx" + newProducts[index]['images'][0]['url'],
                                                                  fit: BoxFit.contain,
                                                                ),
                                                              )
                                                            : Container(
                                                                width: 48,
                                                                height: 48,
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: <Widget>[
                                                                    Container(
                                                                      margin: EdgeInsets.only(top: 0),
                                                                      height: 20,
                                                                      child: Image.asset('assets/chd_logo.png'),
                                                                    ),
                                                                    Text(
                                                                      'Imagen no disponible',
                                                                      textAlign: TextAlign.center,
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                        Container(
                                                          margin: EdgeInsets.symmetric(horizontal: 15),
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.max,
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget>[
                                                              Text(
                                                                newProducts[index]['name'].toString().length > 30 ? newProducts[index]['name'].toString().toString().substring(0, 28) + "..." : newProducts[index]['name'],
                                                                style: TextStyle(
                                                                  fontFamily: "Rubik",
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.normal,
                                                                  color: HexColor("#454F5B"),
                                                                ),
                                                              ),
                                                              Text(
                                                                newProducts[index]['price']['formattedValue'],
                                                                style: TextStyle(
                                                                  fontFamily: "Rubik",
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.normal,
                                                                  color: HexColor("#454F5B"),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      child: Icon(Icons.delete_outline),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            secondaryActions: <Widget>[
                                              IconSlideAction(
                                                caption: 'Quitar',
                                                color: Colors.red,
                                                icon: Icons.clear,
                                                onTap: () {
                                                  setState(() {
                                                    newProducts.removeWhere((item) => item['code'] == newProducts[index]['code']);
                                                  });
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      ListView.builder(
                                        physics: ClampingScrollPhysics(),
                                        shrinkWrap: true,
                                        primary: false,
                                        // shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount: newProductsTicket == null ? 0 : newProductsTicket.length,
                                        itemBuilder: (context, index) {
                                          return Slidable(
                                            delegate: SlidableDrawerDelegate(),
                                            actionExtentRatio: 0.25,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: BorderDirectional(
                                                  bottom: BorderSide(
                                                    color: HexColor("#EFEFEF"),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                              height: 75,
                                              child: Padding(
                                                padding: EdgeInsets.all(15),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Row(
                                                      children: <Widget>[
                                                        newProductsTicket[index]['product']['images'] != null
                                                            ? Container(
                                                                height: 48,
                                                                width: 48,
                                                                child: Image.network(
                                                                  "https://prod.chedraui.com.mx" + newProductsTicket[index]['product']['images'][0]['url'],
                                                                  fit: BoxFit.contain,
                                                                ),
                                                              )
                                                            : Container(
                                                                width: 48,
                                                                height: 48,
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: <Widget>[
                                                                    Container(
                                                                      margin: EdgeInsets.only(top: 0),
                                                                      height: 20,
                                                                      child: Image.asset('assets/chd_logo.png'),
                                                                    ),
                                                                    Text(
                                                                      'Imagen no disponible',
                                                                      textAlign: TextAlign.center,
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                        Container(
                                                          margin: EdgeInsets.symmetric(horizontal: 15),
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.max,
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget>[
                                                              Text(
                                                                newProductsTicket[index]['product']['name'].toString().length > 30 ? newProductsTicket[index]['product']['name'].toString().toString().substring(0, 28) + "..." : newProductsTicket[index]['product']['name'],
                                                                style: TextStyle(
                                                                  fontFamily: "Rubik",
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.normal,
                                                                  color: HexColor("#454F5B"),
                                                                ),
                                                              ),
                                                              Text(
                                                                '\$ ' + newProductsTicket[index]['displayPrice'],
                                                                style: TextStyle(
                                                                  fontFamily: "Rubik",
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.normal,
                                                                  color: HexColor("#454F5B"),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      child: Icon(Icons.delete_outline),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            secondaryActions: <Widget>[
                                              IconSlideAction(
                                                caption: 'Quitar',
                                                color: Colors.red,
                                                icon: Icons.clear,
                                                onTap: () {
                                                  setState(() {
                                                    newProductsTicket.removeWhere((item) => item['product']['code'] == newProductsTicket[index]['product']['code']);
                                                  });
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      Container(
                                        width: double.infinity,
                                        margin: EdgeInsets.only(top: 50),
                                        child: RaisedButton(
                                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                                          color: HexColor("#F57C00"),
                                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                          onPressed: newProducts.length > 0 || newProductsTicket.length > 0 ? createList : null,
                                          child: Text(
                                            'Guardar Lista',
                                            style: TextStyle(
                                              color: HexColor("#F9FAFB"),
                                              fontFamily: "Rubik",
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ))
                              : Container(
                                  margin: EdgeInsets.all(15),
                                  padding: EdgeInsets.symmetric(vertical: 25, horizontal: 30),
                                  height: 90,
                                  child: Center(
                                    child: Text(
                                      "🤔 hmm... Tu lista esta un poco sola. Agrega productos buscándolos arriba.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: HexColor("#C4CDD5"),
                                        fontFamily: "Rubik",
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: HexColor("#F9FAFB"),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        offset: Offset(5.0, 1.0),
                                        blurRadius: 20.0,
                                      ),
                                    ],
                                  ),
                                ),
                          crossFadeState: _isSearching ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                        ),
                      ],
                    ),
                    AnimatedCrossFade(
                      sizeCurve: Curves.easeInOut,
                      duration: const Duration(milliseconds: 280),
                      firstChild: listaSearchResults(),
                      secondChild: SizedBox(
                        height: 0,
                      ),
                      crossFadeState: _isSearching ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
