import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:chd_app_demo/services/ArticulosServices.dart';
import 'package:chd_app_demo/services/CarritoServices.dart';
import 'package:chd_app_demo/services/Comparador.dart';
import 'package:chd_app_demo/services/FireBaseServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/DeliveryMethod/DeliveryMethodPage.dart';
import 'package:chd_app_demo/views/Errors/NetworkErrorPage/NetworkErrorPage.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:chd_app_demo/redux/models/AppState.dart';
import 'package:chd_app_demo/redux/actions/ShoppingCartsActions.dart';

class ComparadorPrecios extends StatefulWidget {
  ComparadorPrecios({Key key}) : super(key: key);

  ComparadorPreciosState createState() => ComparadorPreciosState();
}

class ComparadorPreciosState extends State<ComparadorPrecios> {
  SharedPreferences prefs;
  NumberFormat moneda = new NumberFormat.currency(locale: 'es_MX', symbol: "\$");
  String barcode;
  String barcodeProduct;
  bool loading = false;
  var formData;
  List data;
  List carrito;
  bool exist = false;
  bool loadingBuy = false;
  var total;
  var index;
  var productInfo;
  String upc;
  var price;
  String errorMessage = '';
  var productData;
  bool _hasCameraAccess;

  PermissionStatus _permissionsStatus;

  Future scanResponse;

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
        scanProducts(context);
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

  Future<void> scan() async {
    await _listenForPermissionStatus();
  }

  Future<void> scanProducts(BuildContext context) async {
    try {
      print("Entro scan");
      barcode = await BarcodeScanner.scan();
      setState(() {
        data = null;
        loading = true;
      });
      setState(() => //this.barcode = barcode;
          this.barcodeProduct = barcode);

      print("salgo scan");
      print("barcode1: $barcode");

      barcode = barcode.substring(0, (barcode.length - 1));

      print("barcode2: $barcode");

      scanResponse = ComparadorServices.consultarPrecio(barcode);
      var response = await scanResponse;
      if (response['statusOperation']['code'] == 0) {
        setState(() {
          data = response['data'];
        });
        FireBaseEventController.sendAnalyticsEventScanProduct(data[0]['producto'] ?? '', 1).then((ok) {});
        Future.forEach(data, (product) async {
          if (product['retailer'] == 'Chedraui') {
            setState(() {
              productData = product;
              loading = false;
              if (productData['mejorPrecio'] != "") {
                price = productData['mejorPrecio'];
              } else {
                price = productData['precio'];
              }
              upc = productData['codeHybris'];
            });
          }
        });
        String url = '$upc&pageSize=1&fields=FULL';
        print(url);
        var products = await ArticulosServices.getProductsHybrisSearch(url);
        if (products != null) {
          setState(() {
            productInfo = products['products'][0];
          });
          print(productInfo);
        }
      } else {
        setState(() {
          data = null;
          loading = false;
          productData = null;
        });
        errorMessage = 'No se encontraron productos, intente de nuevo';
        FireBaseEventController.sendAnalyticsEventScanProductFail(barcode).then((ok) {});
        /* Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text('No se encontraron productos, intente de nuevo'),
          )); */
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcodeProduct = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcodeProduct = 'Unknown error: $e');
      }
    } on FormatException {
      Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
      setState(() => this.barcodeProduct = 'null (User returned using the "back"-button before scanning anything. Result)');
      print(this.barcodeProduct);
    } catch (e) {
      setState(() => this.barcodeProduct = 'Unknown error: $e');
    }
    print(this.barcodeProduct);
  }

  // scan() async {
  //   scanProducts(context);
  // }

  addCarrito() async {
    setState(() {
      index = false;
      loadingBuy = true;
    });
    var now = new DateTime.now();
    var newDate = new DateFormat("dd/MM/yyyy").format(now);
    formData = {
      'upc': upc,
      'price': price,
      'date': newDate,
    };
    await CarritoServices.getCart().then((prod) async {
      carrito = prod['entries'];
      final itemsQty = prod['totalItems'];
      final store = StoreProvider.of<AppState>(context);
      store.dispatch(SetShoppingItems(itemsQty));
    });
    await Future.forEach(carrito, (action) {
      if (action['product']['code'] == upc) {
        setState(() {
          index = action['entryNumber'];
          exist = true;
          total = action['decimalQty'];
        });
      }
    });
    print(index);
    if (exist == true) {
      total++;
      print(total);
      CarritoServices.updateEntryCart(index, total).then((res) {
        if (res['statusCode'] == 'success') {
          setState(() {
            loadingBuy = false;
          });
          Flushbar(
            message: "Producto agregado al carrito exitosamente.",
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
          Future.delayed(const Duration(milliseconds: 1000), () {
            Navigator.pushNamed(context, '/');
          });
        } else {
          setState(() {
            loadingBuy = false;
          });
          Flushbar(
            message: "Hubo un problema al agregar el producto al carrito.",
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
      });
    } else {
      await CarritoServices.addEntryToCartComparator(formData).then((result) {
        setState(() {
          loadingBuy = false;
        });
        if (result != null) {
          if (result['err'] == null) {
            List cartModifications = result['cartModifications'];
            if (cartModifications.length > 0) {
              var statusCode = cartModifications[0]['statusCode'];
              setState(() {
                loadingBuy = false;
              });
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
                  break;
                case "lowStock":
                case "success":
                  Flushbar(
                    message: "Producto agregado al carrito exitosamente.",
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
                  Future.delayed(const Duration(milliseconds: 1000), () {
                    Navigator.pushNamed(context, '/');
                  });
                  break;
                default:
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
              Flushbar(
                message: "Hubo un problema al agregar el producto al carrito [NULL MODIF].",
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
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  settings: RouteSettings(name: DataUI.deliveryMethodRoute),
                                  builder: (context) => DeliveryMethodPage(showStores: false, showConfirmationForm: false),
                                ),
                              );
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
          }
        } else {
          Flushbar(
            message: "Hubo un problema al agregar el producto al carrito [NULL CART].",
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
      });
    }
  }

  Future getPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    scan();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetContainer(
      Scaffold(
        appBar: GradientAppBar(
          iconTheme: IconThemeData(
            color: DataUI.primaryText, //change your color here
          ),
          title: Text('Comparador de Precios', style: TextStyle(color: Colors.white, fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 19)),
          centerTitle: true,
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
            IconButton(
              icon: Icon(Icons.camera_alt),
              onPressed: () {
                scan();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
            children: <Widget>[
              Column(
                children: <Widget>[
                  FutureBuilder(
                    future: scanResponse,
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
                            return errorMessage.length > 0
                                ? Container(
                                    /*  margin: EdgeInsets.only(top: 170), */
                                    child: Padding(
                                      padding: EdgeInsets.all(15),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(top: 20),
                                            child: Text(
                                              'Producto no encontrado',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Archivo',
                                                fontSize: 20,
                                                letterSpacing: 0.25,
/*                               color: HexColor('#FFFFFF'), */
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 20),
                                            child: Text(
                                              'El producto que has escaneado no se encuentra en nuestro catálogo de productos y tampoco lo hemos podido comparar con otras tiendas.',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: HexColor('#212B36'),
                                                fontFamily: 'Archivo',
                                                fontSize: 16,
                                                letterSpacing: 0.25,
/*                               color: HexColor('#FFFFFF'), */
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 30),
                                            child: Image.asset('assets/productNotFound.png'),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            margin: EdgeInsets.only(top: 30),
                                            child: OutlineButton(
                                              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                                              padding: EdgeInsets.symmetric(
                                                vertical: 15,
                                              ),
                                              borderSide: BorderSide(color: HexColor('#0D47A1')),
                                              onPressed: () {
                                                scan();
                                              },
                                              child: Text(
                                                'Escanear otro producto',
                                                style: TextStyle(color: HexColor('#0D47A1')),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    margin: EdgeInsets.symmetric(horizontal: 15),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.symmetric(vertical: 10),
                                          child: Text(
                                            productData['producto'],
                                            style: TextStyle(
                                              color: HexColor('#212B36'),
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.63,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.only(left: 0, bottom: 15, top: 5, right: 15),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                color: Color(0xcc000000).withOpacity(0.1),
                                                offset: Offset(0.0, 5.0),
                                                blurRadius: 10.0,
                                              ),
                                            ],
                                          ),
                                          child: Stack(
                                            children: <Widget>[
                                              Positioned(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                                  width: 55,
                                                  height: 20,
                                                  decoration: new BoxDecoration(
                                                    color: HexColor('#F57C00'),
                                                    borderRadius: new BorderRadius.only(
                                                      topRight: const Radius.circular(40.0),
                                                      bottomRight: const Radius.circular(40.0),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Venta',
                                                    style: TextStyle(
                                                      fontFamily: 'Archivo',
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                height: 182,
                                                child: Center(
                                                  child: Image.network(
                                                    "https://prod.chedraui.com.mx" + productData['imagen'],
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          // height: 200,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                color: Color(0xcc000000).withOpacity(0.1),
                                                offset: Offset(2.0, 5.0),
                                                blurRadius: 5.0,
                                              ),
                                            ],
                                          ),
                                          margin: EdgeInsets.symmetric(vertical: 37),
                                          padding: EdgeInsets.symmetric(vertical: 15),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                width: MediaQuery.of(context).size.width * 0.4,
                                                child: ListView.builder(
                                                  physics: ClampingScrollPhysics(),
                                                  shrinkWrap: true,
                                                  primary: true,
                                                  scrollDirection: Axis.vertical,
                                                  itemCount: data == null ? 0 : data.length,
                                                  itemBuilder: (context, index) {
                                                    if (data[index]['retailer'] == 'Chedraui') {
                                                      return Container(
                                                        padding: EdgeInsets.only(left: 15, right: 15, top: 15),
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: <Widget>[
                                                            Container(
                                                              height: 30,
                                                              child: ChdLogo(),
                                                            ),
                                                            data[index]['mejorPrecio'] != ''
                                                                ? Container(
                                                                    margin: EdgeInsets.symmetric(vertical: 2.5),
                                                                    child: Text(
                                                                      moneda.format(double.parse(data[index]['mejorPrecio'])),
                                                                      style: TextStyle(color: HexColor('#212B36'), fontSize: 22, letterSpacing: 0.25, fontFamily: 'Archivo', fontWeight: FontWeight.bold),
                                                                    ),
                                                                  )
                                                                : SizedBox(
                                                                    height: 0,
                                                                  ),
                                                            data[index]['mejorPrecio'] != ''
                                                                ? Container(
                                                                    margin: EdgeInsets.only(left: 5),
                                                                    child: Text(
                                                                      moneda.format(double.parse(data[index]['precio'])),
                                                                      style: TextStyle(
                                                                        color: HexColor('#C4CDD5'),
                                                                        fontSize: 16,
                                                                        letterSpacing: 0.25,
                                                                        fontFamily: 'Archivo',
                                                                        decoration: TextDecoration.lineThrough,
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Container(
                                                                    margin: EdgeInsets.symmetric(vertical: 2.5),
                                                                    child: Text(
                                                                      moneda.format(double.parse(data[index]['precio'])),
                                                                      style: TextStyle(
                                                                        color: HexColor('#212B36'),
                                                                        fontSize: 16,
                                                                        letterSpacing: 0.25,
                                                                      ),
                                                                    ),
                                                                  ),
                                                            Center(
                                                              child: Container(
                                                                margin: EdgeInsets.only(top: 10),
                                                                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                                                width: 97,
                                                                height: 20,
                                                                decoration: BoxDecoration(
                                                                  color: HexColor('#F57C00'),
                                                                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                                                                ),
                                                                child: Text(
                                                                  'Precio Especial',
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontSize: 10,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      );
                                                    } else {
                                                      return SizedBox();
                                                    }
                                                  },
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.only(right: 15),
                                                width: MediaQuery.of(context).size.width * 0.5,
                                                child: ListView.separated(
                                                  separatorBuilder: (context, index) {
                                                    print(data[index]);
                                                    if (data[index]['precio'] != '') {
                                                      return Divider();
                                                    } else {
                                                      return SizedBox();
                                                    }
                                                  },
                                                  physics: ClampingScrollPhysics(),
                                                  shrinkWrap: true,
                                                  primary: true,
                                                  scrollDirection: Axis.vertical,
                                                  itemCount: data == null ? 0 : data.length,
                                                  itemBuilder: (context, index) {
                                                    if (data[index]['retailer'] == 'Chedraui' && data[index]['precio'] != '') {
                                                      return SizedBox();
                                                    } else {
                                                      if (data[index]['precio'] != '') {
                                                        return Container(
                                                          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                                                          // margin: EdgeInsets.symmetric(
                                                          //     vertical: 5, horizontal: 0),
                                                          color: Colors.white,
                                                          child: Row(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: <Widget>[
                                                              Text(
                                                                data[index]['retailer'],
                                                                style: TextStyle(
                                                                    color: HexColor(
                                                                      '#212B36',
                                                                    ),
                                                                    fontFamily: 'Archivo',
                                                                    fontSize: 11),
                                                              ),
                                                              Text(
                                                                moneda.format(double.parse(data[index]['precio'])),
                                                                style: TextStyle(
                                                                    color: HexColor(
                                                                      '#212B36',
                                                                    ),
                                                                    fontFamily: 'Archivo',
                                                                    fontSize: 11),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      } else {
                                                        return SizedBox();
                                                      }
                                                    }
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Center(
                                          child: Container(
                                            width: MediaQuery.of(context).size.width * 0.8,
                                            margin: EdgeInsets.only(top: 0),
                                            child: Text(
                                              'Los precios son consultados en las tiendas en línea y podrían cambiar en las tiendas físicas',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: HexColor('#919EAB'),
                                                fontSize: 12,
                                                letterSpacing: 0.25,
                                              ),
                                            ),
                                          ),
                                        ),
                                        !loadingBuy
                                            ? Container(
                                                padding: EdgeInsets.symmetric(vertical: 10),
                                                width: double.infinity,
                                                child: RaisedButton(
                                                  shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                                                  onPressed: loadingBuy ? null : addCarrito,
                                                  color: HexColor('#F57C00'),
                                                  child: Text(
                                                    'Agregar al carrito',
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      fontFamily: 'Archivo',
                                                      fontSize: 14,
                                                      letterSpacing: 0.25,
                                                      color: HexColor('#FFFFFF'),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                padding: EdgeInsets.symmetric(vertical: 10),
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      flex: 1,
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(top: 5),
                                                        child: LinearProgressIndicator(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
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
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
