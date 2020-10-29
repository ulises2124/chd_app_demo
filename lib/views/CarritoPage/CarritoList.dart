import 'package:flutter/material.dart';
import 'package:chd_app_demo/views/CarritoPage/TypeDelta.dart';
import 'package:intl/intl.dart';
import 'package:chd_app_demo/views/CarritoPage/CarritoItem.dart';

class CarritoList extends StatefulWidget {
  final List cartItems;
  final List<String> cartItemsImages;
  final Widget child;
  final Function onPressDelete;
  final Function callbackUpdate;
  final Function callbackForceUpdate;

  CarritoList(
    this.onPressDelete, {
    this.cartItems,
    this.cartItemsImages,
    Key key,
    this.child,
    this.callbackUpdate,
    this.callbackForceUpdate
  }) : super(key: key);

  _CarritoListState createState() => _CarritoListState();
}

class _CarritoListState extends State<CarritoList> {
  bool checkedValue = true;
  List cartItems;
  List cartItemsImages;
  List deltas = new List();
  NumberFormat moneda = new NumberFormat.currency(locale: 'es_MX', symbol: "\$");

  void setDelta(int index, TypeDelta typeDelta, num amount, String name) {
    List deltasC = [];
    List deltasR = [];

    double newTotal = 0;
    int newQuantity = 0;

    deltas.forEach((d) {
      if (index != d['index']) {
        if (d['typeDelta'] == TypeDelta.changedAmount) {
          deltasC.add(d);
        } else {
          deltasR.add(d);
        }
      }
    });

    deltas.clear();

    if (typeDelta == TypeDelta.changedAmount) {
      deltasC.add({'index': index, 'typeDelta': typeDelta, 'amount': amount, 'name': name});
    } else {
      deltasR.add({'index': index, 'typeDelta': typeDelta, 'amount': amount, 'name': name});
    }

    deltasC.sort((a, b) {
      return a['index'].compareTo(b['index']);
    });

    deltasR.sort((a, b) {
      return b['index'].compareTo(a['index']);
    });

    deltas.addAll(deltasC);
    deltas.addAll(deltasR);

    cartItems.forEach((item) {
      bool removed = item['toBeRemoved'] ?? false;
      if (!removed) {
        newTotal += item['totalPrice']['value'];
        newQuantity++;
      }
    });
    widget.callbackUpdate(newTotal, newQuantity, deltas);
  }

  Future modificaProductoSubstraccion(int index) async {
    String unitCode = cartItems[index]['product']['unit']['code'];
    num unitConversion = cartItems[index]['product']['unit']['conversion'];
    num step;
    num decimalQty = cartItems[index]['decimalQty'];
    if (unitCode == "KGM") {
      if (cartItems[index]['product']['weightPerAltSalesUnit'] != null) {
        step = cartItems[index]['product']['weightPerAltSalesUnit']['conversion'];
      } else if (cartItems[index]['product']['minOrderQuantity'] != null) {
        step = cartItems[index]['product']['minOrderQuantity'] / unitConversion;
      } else {
        step = 0.05;
      }
    } else if (unitCode == "PCE") {
      step = 1;
    }
    num newDecimalQty = (decimalQty * unitConversion - step * unitConversion) / unitConversion;
    newDecimalQty = num.parse(newDecimalQty.toStringAsFixed(2));
    if (newDecimalQty >= step) {
      setState(() {
        cartItems[index]['decimalQty'] = newDecimalQty;
        cartItems[index]['totalPrice']['value'] = newDecimalQty * cartItems[index]['unitaryPrice']['value'];
      });
      setDelta(index, TypeDelta.changedAmount, newDecimalQty, cartItems[index]['product']['name']);
    }
  }

  Future modificaProductoAdicion(int index) async {
    String unitCode = cartItems[index]['product']['unit']['code'];
    num unitConversion = cartItems[index]['product']['unit']['conversion'];
    num step;
    num decimalQty = cartItems[index]['decimalQty'];
    num maxOrderQuantity = cartItems[index]['product']['maxOrderQuantity'];
    if (unitCode == "KGM") {
      if (cartItems[index]['product']['weightPerAltSalesUnit'] != null) {
        step = cartItems[index]['product']['weightPerAltSalesUnit']['conversion'];
      } else if (cartItems[index]['product']['minOrderQuantity'] != null) {
        step = cartItems[index]['product']['minOrderQuantity'] / unitConversion;
      } else {
        step = 0.05;
      }
    } else if (unitCode == "PCE") {
      step = 1;
    }
    num newDecimalQty = (decimalQty * unitConversion + step * unitConversion) / unitConversion;
    newDecimalQty = num.parse(newDecimalQty.toStringAsFixed(2));
    if (maxOrderQuantity == null || newDecimalQty <= maxOrderQuantity) {
      setState(() {
        cartItems[index]['decimalQty'] = newDecimalQty;
        cartItems[index]['totalPrice']['value'] = newDecimalQty * cartItems[index]['unitaryPrice']['value'];
      });
      setDelta(index, TypeDelta.changedAmount, newDecimalQty, cartItems[index]['product']['name']);
    }
  }

  Future eliminaProducto(int index) async {
    setState(() {
      cartItems[index]['toBeRemoved'] = true;
    });
    setDelta(index, TypeDelta.toBeRemoved, 0, cartItems[index]['product']['name']);
  }

  void forceUpdate(){
    widget.callbackForceUpdate();
  }

  @override
  Widget build(BuildContext context) {
    cartItems = (cartItems == null) ? widget.cartItems : cartItems;
    return Container(
      margin: const EdgeInsets.only(
        top: 30.0,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.0),
              color: Color.fromRGBO(0, 0, 0, 0),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Color(0xcc000000).withOpacity(0.1),
                  offset: Offset(0.0, 5.0),
                  blurRadius: 10.0,
                ),
              ],
            ),
            child: ListView.builder(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                bool removed = cartItems[index]['toBeRemoved'] ?? false;
                if (!removed) {
                  return CarritoItem(
                    cartItems[index],
                    index,
                    callbackAddQty: modificaProductoAdicion,
                    callbackSubtractQty: modificaProductoSubstraccion,
                    callbackRemoveItem: eliminaProducto,
                    callbackAutomaticUpdate: forceUpdate
                  );
                } else {
                  return SizedBox(
                    height: 0,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
