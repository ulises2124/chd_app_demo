import 'dart:io';

import 'package:chd_app_demo/services/FireBaseServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/utils/input_formatters.dart';
//import 'package:chd_app_demo/views/Checkout/TextInputsFormatters.dart';
import 'package:chd_app_demo/views/ProductsPage/ProductsPage.dart';
//import 'package:chedraui_flutter/views/ResultPage/ResultPage.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:chd_app_demo/views/ProductPage/ProductPage.dart';
import 'package:chd_app_demo/services/ArticulosServices.dart';
import 'package:permission_handler/permission_handler.dart';

class SearchProducts extends StatefulWidget {
  final Function(bool) isSearching;
  final Function isSearchingManual;
  final Function(String) search;
  final bool autoFocus;
  TextEditingController searchBoxController;

  SearchProducts(
    this.isSearching,
    this.search,
    this.isSearchingManual, {
    this.autoFocus,
    this.searchBoxController,
    Key key,
  }) : super(key: key);

  @override
  _SearchProductsState createState() => _SearchProductsState();
}

class _SearchProductsState extends State<SearchProducts> {
  bool _switchIcons = false;
  String barcodeProduct;
  bool _hasCameraAccess;
  PermissionStatus _permissionsStatus;
  FocusNode textFieldFocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
      padding: const EdgeInsets.all(3.0),
      decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0xcc000000).withOpacity(0.1),
            offset: Offset(0.0, 5.0),
            blurRadius: 10.0,
          ),
        ],
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
                icon: _switchIcons
                    ? Icon(
                        Icons.close,
                        size: 33,
                        color: DataUI.chedrauiBlueSoftColor,
                      )
                    : Icon(
                        Icons.search,
                        size: 33,
                        color: DataUI.chedrauiBlueSoftColor,
                      ),
                onPressed: () {
                  widget.isSearchingManual();
                  setState(() {
                    _switchIcons = !_switchIcons;
                  });
                  FocusScope.of(context).requestFocus(new FocusNode());
                  widget.searchBoxController.text = '';
                  widget.isSearching(false);
                },
              ),
            ],
          ),
          Flexible(
            child: TextField(
              focusNode: textFieldFocus,
              autofocus: widget.autoFocus,
              textInputAction: TextInputAction.search,
              controller: widget.searchBoxController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Encuentra tus productos aquí ',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(100),
                // WhitelistingTextInputFormatter(
                //   FormsTextValidators.lettersAndNumbers,
                // ),
                 WhitelistingTextInputFormatter(
                  FormsTextValidators.searchbarWhiteList,
                ),
                BlacklistingTextInputFormatter(
                  FormsTextValidators.searchbar,
                )
                
              ],
              onEditingComplete: () {
                widget.search(widget.searchBoxController.text);
                // print('here');
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     settings: RouteSettings(name: DataUI.productsRoute),
                //     builder: (context) => ProductsPage(
                //       searchTerm: widget.searchBoxController.text,
                //       logEvent: true,
                //     ),
                //   ),
                // );
              },
              onChanged: (value) {
                print(value);
                if (value.length > 1) {
                  setState(() {
                    _switchIcons = true;
                  });
                  widget.isSearching(true);
                } else {
                  setState(() {
                    _switchIcons = false;
                  });
                  widget.isSearching(false);
                }
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
                      color: DataUI.chedrauiBlueSoftColor,
                      icon: ScanSVG(),
                      onPressed: () {
                        scan(context);
                      },
                    ),
            ],
          ),
        ],
      ),
    );
  }

///////////////////////////////////////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();
    // textFieldFocus = FocusNode();
    // if (widget.autoFocus) {
    //   FocusScope.of(context).requestFocus(textFieldFocus);
    // }
  }

  // void _showToast(BuildContext context, String message) {
  //   final scaffold = Scaffold.of(context);
  //   scaffold.showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       action: SnackBarAction(label: 'Ok', onPressed: scaffold.hideCurrentSnackBar),
  //     ),
  //   );
  // }

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
        print('s');
      } else {
        try {
          print("Entro scan");
          String barcode = await BarcodeScanner.scan();
          // final snackBar = SnackBar(
          //     content: Row(
          //   children: <Widget>[CircularProgressIndicator(), Text('Buscando tu producto.')],
          // ));
          Flushbar(
            message: "Buscando tu producto.",
            backgroundColor: HexColor('#39B54A'),
            flushbarPosition: FlushbarPosition.TOP,
            flushbarStyle: FlushbarStyle.FLOATING,
            margin: EdgeInsets.all(8),
            borderRadius: 8,
            icon: Icon(
              Icons.search,
              size: 28.0,
              color: Colors.white,
            ),
            duration: Duration(seconds: 6),
          )..show(context);
          setState(() => //this.barcode = barcode;
              this.barcodeProduct = barcode);

          print("salgo scan");
          print("barcode1: $barcode");

          barcode = barcode.substring(0, (barcode.length - 1));

          print("barcode2: $barcode");

          ArticulosServices.getProductsHybrisSearch(barcode).then(
            (products) {
              Flushbar()..dismiss();
              if (products != null) {
                print("*********> paso1");
                print(products);
                print("*********> paso2");
                print(products["products"]);
                print("*********> paso3");
                print(products["products"].length);
                Scaffold.of(context).hideCurrentSnackBar();
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
                FireBaseEventController.sendAnalyticsEventScanProduct(products["products"][0]['name'], 1).then((ok) {});
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: RouteSettings(name: DataUI.productRoute),
                    builder: (context) => ProductPage(
                      data: products["products"][0],
                    ),
                  ),
                );
              } else {
                Scaffold.of(context).hideCurrentSnackBar();
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
    }
  }

  _askCameraPermission() {
    PermissionHandler().requestPermissions([PermissionGroup.camera]).then((result) {
      print(result[PermissionGroup.camera]);
      if (result[PermissionGroup.camera] == PermissionStatus.denied) {
        print(result[PermissionGroup.camera]);
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

  Future<void> scan(BuildContext context) async {
    await _listenForPermissionStatus();
  }
}
