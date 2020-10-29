import 'package:chd_app_demo/services/ListasServices.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/DeliveryMethod/DeliveryMethodPage.dart';
import 'package:chd_app_demo/views/Errors/NetworkErrorPage/NetworkErrorPage.dart';
import 'package:chd_app_demo/views/ListasPage/ListaEdit.dart';
import 'package:chd_app_demo/views/ListasPage/ListaProductDetails.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/NetworkData.dart';

class ListaSelected extends StatelessWidget {
  final title;
  final listID;

  ListaSelected({Key key, this.title, this.listID}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return WidgetContainer(
      Scaffold(
        appBar: GradientAppBar(
          automaticallyImplyLeading: false,
          gradient: LinearGradient(
            //stops: [0, 0, 1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              HexColor('#F56D00'),
              HexColor('#F56D00'),
              HexColor('#F78E00'),
            ],
          ),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context, 'reload');
                },
              );
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: new Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: RouteSettings(name: DataUI.listasEdit),
                    builder: (context) => ListaEdit(
                      listID: listID,
                    ),
                  ),
                );
                print(result);
                if (result == 'reload') {
                  Navigator.pop(context, 'reload');
                }
              },
            ),
          ],
          elevation: 1,
          title: Text(title, style: TextStyle(color: Colors.white, fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 19)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ListaItems(listID: listID, listTitle: title),
            ],
          ),
        ),
      ),
    );
  }
}

class ListaItems extends StatefulWidget {
  final Widget child;
  final listID;
  final listTitle;
  ListaItems({Key key, this.child, this.listID, this.listTitle}) : super(key: key);

  _ListaItemsState createState() => _ListaItemsState();
}

class _ListaItemsState extends State<ListaItems> {
  bool checkedValue = true;

  SharedPreferences prefs;
  String email;
  String listaID;
  String title;
  String cp;
  final _formKey = GlobalKey<FormState>();
  bool shared = false;

  bool loading = false;

  String tienda;

  bool loadingCarrito = false;

  bool deleteLoading = false;

  Future listResponse;
  Future<void> getList() async {
    listResponse = ListasServices.getCurrentList(listaID);
    var list = await listResponse;
    data = list['entries'];
    title = list['name'];
  }

  void onPressDelete(productID, productName) {
    ListasServices.deleteProduct(listaID, productID, productName).then((response) {
      if (response == true) {
        ListasServices.getCurrentList(listaID).then((list) {
          setState(() {
            data = list['entries'];
          });

          if (data.length == 0) {
            Navigator.pop(context, 'reload');
          }
        });
        Flushbar(
          message: "Se ha eliminado el producto",
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
      } else {
        Flushbar(
          message: "Error al intentar elimiar producto.",
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

  List data;
  Future getPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  initState() {
    super.initState();
    if (widget.listID != null) {
      listaID = widget.listID;
      getList();
      getPreferences();
    }
  }

  sharedList() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      FocusScope.of(context).requestFocus(new FocusNode());
      setState(() {
        loading = true;
      });
      ListasServices.sharedList(listaID, email, data.length).then((response) {
        if (response == true) {
          setState(() {
            loading = false;
          });
          Flushbar(
            message: "Lista $title compartida exitosamente con $email.",
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
        } else {
          setState(() {
            loading = false;
          });
          Flushbar(
            message: "Ha ocurrido un error, inténtelo más tarde.",
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

  listTocart() {
    setState(() {
      cp = prefs.getString('delivery-codigoPostal');
      tienda = prefs.getString('store-name');
      loadingCarrito = true;
    });
    print(cp);
    print(tienda);
    if (tienda != null && listaID != null) {
      ListasServices.listToCarritoTienda(listaID, tienda).then((response) async {
        Flushbar(
          message: "Los productos se han agregado correctamente al carrito.",
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
        // await Future.forEach(response['cartModifications'], (product) {
        //   if (product['quantityAdded'] == 0) {
        //     var name = product['entry']['product']['name'];
        //     Scaffold.of(context).showSnackBar(
        //       SnackBar(
        //         content: new Text('No es posible agregar $name.'),
        //       ),
        //     );
        //   }
        // });
        setState(() {
          loadingCarrito = false;
        });
      });
      // try {
      //   CarritoServices.getCart().then((carrito) {
      //     final itemsQty = carrito['totalItems'];
      //     final store = StoreProvider.of<AppState>(context);
      //     store.dispatch(SetShoppingItems(itemsQty));
      //   });
      // } catch (e) {
      //   print(e.toString());
      // }
    }
    if (cp != null && listaID != null) {
      ListasServices.listToCarrito(listaID, cp).then((response) async {
        // await Future.forEach(response['cartModifications'], (product) {
        //   if (product['quantityAdded'] == 0) {
        //     var name = product['entry']['product']['name'];
        //     Scaffold.of(context).showSnackBar(
        //       SnackBar(
        //         content: new Text('No es posible agregar $name.'),
        //       ),
        //     );
        //   }
        // });
        Flushbar(
          message: "Los productos se han agregado correctamente al carrito.",
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
        setState(() {
          loadingCarrito = false;
        });
      });
      // try {
      //   CarritoServices.getCart().then((carrito) {
      //     final itemsQty = carrito['totalItems'];
      //     final store = StoreProvider.of<AppState>(context);
      //     store.dispatch(SetShoppingItems(itemsQty));
      //   });
      // } catch (e) {
      //   print(e.toString());
      // }
    }
    if (cp == null && tienda == null) {
      setState(() {
        loadingCarrito = false;
      });
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Hace falta ubicación"),
              content: Text("Elige una ubicación de entrega o bien una tienda Chedraui donde recoger tu pedido."),
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
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: RouteSettings(name: DataUI.deliveryMethodRoute),
                        builder: (context) => DeliveryMethodPage(
                          showStores: false,
                          showConfirmationForm: false,
                        ),
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
    }
  }

  pop() {
    Navigator.pop(context);
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

  deleteConfirm() {
    setState(() {
      deleteLoading = !deleteLoading;
    });
    ListasServices.deleteList(listaID).then((x) {
      if (x == true) {
        setState(() {
          deleteLoading = !deleteLoading;
        });
        Navigator.pop(context);
        Navigator.pop(context, title);
      } else {
        setState(() {
          deleteLoading = !deleteLoading;
        });
        Navigator.pop(context);
        Flushbar(
          message: "Ha ocurrido un error al intentar eliminar la lista.",
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

  deleteList() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Eliminar lista"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                child: Text('Seguro que quiere eliminar $title'),
              ),
            ],
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: FlatButton(
                onPressed: !deleteLoading ? pop : null,
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
                color: Colors.red,
                onPressed: !deleteLoading ? deleteConfirm : null,
                child: !deleteLoading
                    ? Text(
                        "Confirmar",
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

  updateProduct(productData) async {
    // FireBaseEventController.sendAnalyticsEventViewItem(productData['code'], productData['name'], '').then((ok) {});
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          settings: RouteSettings(name: DataUI.listasProductDetails),
          builder: (context) => ListaProductDetails(
                data: productData,
                listID: listaID,
              )),
    );
    print(result);
    if (result == 'reload') {
      setState(() {
        data = null;
      });
      ListasServices.getCurrentList(listaID).then((list) {
        setState(() {
          data = list['entries'];
          title = list['name'];
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: listResponse,
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
              return Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 30.0, left: 20, right: 20, bottom: 20),
                    decoration: BoxDecoration(
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: Offset(10.0, -10.0),
                          blurRadius: 15.0,
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: data == null ? 0 : data.length,
                      itemBuilder: (context, index) {
                        var currentEnv = NetworkData.currentEnv == 'PROD' ? NetworkData.hybrisProd : NetworkData.hybrisStage;
                        var url = currentEnv + data[index]['product']['images'][0]['url'];
                        return data == null
                            ? Container(
                                margin: EdgeInsets.only(left: 15, right: 7.5),
                                height: 72,
                                child: Center(
                                  child: CircularProgressIndicator(value: null),
                                ),
                              )
                            : GestureDetector(
                                child: Slidable(
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
                                    height: 83,
                                    child: Padding(
                                      padding: EdgeInsets.all(15),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              // Container(
                                              //   height: 48,
                                              //   width: 48,
                                              //   child: Image.network(
                                              //     "https://prod.chedraui.com.mx" +
                                              //         data[index]['product']
                                              //             ['images'][0]['url'],
                                              //     fit: BoxFit.contain,
                                              //   ),
                                              // ),
                                              data[index]['product']['images'] != null
                                                  ? Container(
                                                      height: 48,
                                                      width: 48,
                                                      child: Image.network(
                                                        url,
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
                                                width: 200,
                                                margin: EdgeInsets.symmetric(horizontal: 15),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      data[index]['product']['name'].toString().length > 40 ? data[index]['product']['name'].toString().toString().substring(0, 38) + "..." : data[index]['product']['name'],
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    Text(
                                                      data[index]['product']['unit']['code'] != 'KGM' ? data[index]['quantity'].toString() + ' Piezas' : data[index]['quantity'].toString() + ' Kg',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.black.withOpacity(0.5),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  secondaryActions: <Widget>[
                                    IconSlideAction(
                                      caption: 'Quitar',
                                      color: Colors.red,
                                      icon: Icons.clear,
                                      onTap: () => onPressDelete(data[index]['product']['code'], data[index]['product']['name']),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  updateProduct(data[index]['product']);
                                },
                              );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 15),
                          width: double.infinity,
                          child: RaisedButton(
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                            color: HexColor("#F57C00"),
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            onPressed: loadingCarrito == true ? null : listTocart,
                            child: loadingCarrito == false
                                ? Text(
                                    'Comprar productos',
                                    style: TextStyle(
                                      color: HexColor("#F9FAFB"),
                                      fontFamily: "Rubik",
                                      fontSize: 16,
                                    ),
                                  )
                                : SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(),
                                  ),
                          ),
                        ),
                        shared == true
                            ? Container(
                                child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      'Ingrese el correo electrónico de quien deseas compartir tu lista.',
                                      style: TextStyle(
                                        fontFamily: "Rubik",
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: HexColor("#454F5B"),
                                      ),
                                    ),
                                  ),
                                  Form(
                                      key: _formKey,
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            flex: 6,
                                            child: TextFormField(
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                contentPadding: const EdgeInsets.only(
                                                    top: 12,
                                                    bottom: 12,
                                                    left: 6, //todo
                                                    right: 6 //todo
                                                    ),
                                                hintText: 'Email',
                                                hintStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              keyboardType: TextInputType.emailAddress,
                                              onSaved: (input) {
                                                setState(() {
                                                  email = input;
                                                });
                                              },
                                              validator: _validateEmail,
                                              textInputAction: TextInputAction.done,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Container(
                                              padding: EdgeInsets.only(left: 10),
                                              child: RaisedButton(
                                                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                                padding: EdgeInsets.all(12),
                                                child: loading == false
                                                    ? Text(
                                                        'Compartir lista',
                                                        style: TextStyle(color: Colors.white),
                                                      )
                                                    : SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child: CircularProgressIndicator(),
                                                      ),
                                                color: HexColor('#0D47A1'),
                                                onPressed: loading == false ? sharedList : null,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                ],
                              ))
                            : Container(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      shared = true;
                                    });
                                  },
                                  child: Text(
                                    "Compartir lista",
                                    style: TextStyle(fontFamily: "Rubik", fontSize: 14, color: HexColor("#0D47A1"), fontWeight: FontWeight.normal),
                                  ),
                                ),
                              ),
                        widget.listTitle != 'Favoritos'
                            ? Container(
                                margin: EdgeInsets.only(top: 20),
                                child: InkWell(
                                  onTap: deleteList,
                                  child: Text(
                                    "Eliminar lista",
                                    style: TextStyle(fontFamily: "Rubik", fontSize: 14, color: Colors.red, fontWeight: FontWeight.normal),
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: 0,
                              ),
                      ],
                    ),
                  )
                ],
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
    );
  }

  String _validateEmail(String value) {
    Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Correo no válido';
    else
      return null;
  }
}
