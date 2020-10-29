import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:flutter/cupertino.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:strings/strings.dart';

String imgBaseUrl = 'https://www.chedraui.com.mx';

class DeliveryDest {
  String placeName;
  String placeAddress;

  @override
  String getPlaceName() {
    return this.placeName;
  }

  @override
  String getPlaceAddress() {
    return this.placeAddress;
  }

  @override
  String setPlaceName(s) {
    this.placeName = s;
  }

  @override
  String setPlaceAddress(s) {
    this.placeAddress = s;
  }
}

class DeliveryOrigin extends DeliveryDest {
  String productCount;
  String warehouseCode;
  String warehouseName;
  String consignmentCode;

  @override
  String getProductCount() {
    return this.productCount;
  }

  @override
  String getWarehouseCode() {
    return this.warehouseCode;
  }

  @override
  String getWarehouseName() {
    return this.warehouseName;
  }

  @override
  String getConsignmentCode() {
    return this.consignmentCode;
  }

  @override
  void setProductCount(String s) {
    this.productCount = s;
  }

  @override
  void setWarehouseCode(String s) {
    this.warehouseCode = s;
  }

  @override
  void setWarehouseName(String s) {
    this.warehouseName = s;
  }

  @override
  void setConsignmentCode(String s) {
    this.consignmentCode = s;
  }
}

class DeliveryProduct {
  String url;
  String encabezado;
  String descripcion;
  String precioTotal;

  @override
  String getUrl() {
    return this.url;
  }

  @override
  String getEncabezado() {
    return this.encabezado;
  }

  @override
  String getDescripcion() {
    return this.descripcion;
  }

  @override
  String getPrecioTotal() {
    return this.precioTotal;
  }

  @override
  void setUrl(String s) {
    this.url = s;
  }

  @override
  void setEncabezado(String s) {
    this.encabezado = s;
  }

  @override
  void setDescripcion(String s) {
    this.descripcion = s;
  }

  @override
  void setPrecioTotal(String s) {
    this.precioTotal = s;
  }
}

class PayPalProduct {
  String sku;
  String name;
  String description;
  num quantity;
  double price;
  double tax;

  PayPalProduct(){
  }

  @override
  String getSku() {
    return this.sku;
  }

  @override
  String getName() {
    return this.name;
  }

  @override
  String getDescription() {
    return this.description;
  }

  @override
  int getQuantity() {
    return this.quantity;
  }

  @override
  double getTax() {
    return this.tax;
  }

  @override
  void setSku(String s) {
    this.sku = s;
  }

  @override
  void setName(String s) {
    this.name = s;
  }

  @override
  void setDescription(String s) {
    this.description = s;
  }

  @override
  void setQuantity(num s) {
    this.quantity = s;
  }

  @override
  void setPrice(double s) {
    this.price = s;
  }

  @override
  void setTax(double s) {
    this.tax = s;
  }

  /*PayPalProduct.fromJson(Map json) {
    this.sku = json['sku'];
    this.name = json['name'];
    this.description = json['description'];
    this.quantity = json['quantity'];
    this.price = json['price'];
  }*/

  toJson() {
    return {
      "sku": sku,
      "name": name,
      "description": description,
      "quantity": quantity,
      "price": price
    };
  }
}

class DeliveryStore extends StatefulWidget {
  final String encabezadoTiendaOrigen;
  final String direccionTiendaOrigen;
  final String encabezadoTiendaDestino;
  final String direccionTiendaDestino;
  bool isPickUp;
  bool isDHL;
  final int numeroArticulosTienda;
  final List<DeliveryProduct> listaProductos;

  DeliveryStore(
      {Key key,
      this.encabezadoTiendaOrigen,
      this.direccionTiendaOrigen,
      this.encabezadoTiendaDestino,
      this.direccionTiendaDestino,
      this.isPickUp,
      this.isDHL,
      this.numeroArticulosTienda,
      this.listaProductos})
      : super(key: key);

  @override
  String getEncabezadoTiendaOrigen() {
    final List storeNameList = this.encabezadoTiendaOrigen.split(' ');
    final String storeName = ((){
      List capNames = [];
      storeNameList.forEach((p){
        String pL = p.toString();
        pL = pL.toLowerCase();
        capNames.add(capitalize(pL));
      });
      return capNames.join(' ');
    })();
    return storeName;
  }

  @override
  String getDireccionTiendaOrigen() {
    return this.direccionTiendaOrigen;
  }

  @override
  String getEncabezadoTiendaDestino() {
    return this.encabezadoTiendaDestino;
  }

  @override
  String getDireccionTiendaDestino() {
    return this.direccionTiendaDestino;
  }

  @override
  int getNumeroArticulosTienda() {
    return this.numeroArticulosTienda;
  }

  @override
  List<DeliveryProduct> getListaProductos() {
    return this.listaProductos;
  }

  @override
  int verifyNumeroArticulosTienda() {
    if (this.getNumeroArticulosTienda() == null) return 0;
    var parsed =
        double.parse(this.getNumeroArticulosTienda().toString(), (e) => 0);
    return parsed.toInt();
  }

  _DeliveryStoreState createState() => _DeliveryStoreState();
}

class _DeliveryStoreState extends State<DeliveryStore> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 5),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: widget.isPickUp ? 
                      Image.asset('assets/store.png', width: 20) : 
                      (!widget.isDHL ?
                      DeliverIcon(height: 15, width: 20) :
                      Image.asset('assets/094711179f@3x.png', width: 30)),
                    )
                  ),
                  Flexible(
                    flex: 5,
                    child: widget.getEncabezadoTiendaOrigen() == null ? Text('') :Text(
                      widget.getEncabezadoTiendaOrigen(),
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    flex: 2,
                    child: SizedBox(height: 0, width: 35,),
                  ),
                  Flexible(
                    flex: 5,
                    child: widget.getDireccionTiendaDestino() == null ? Text('') : Text(
                      widget.getDireccionTiendaDestino(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey
                      ),
                    ),
                  )
                ]
              ),
            ],
          ),
        ),
        /*
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Flexible(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    widget.isDHL ? 
                      DhlLogo()
                      :Icon(Icons.local_shipping),
                  ],
                ),
              ),
              Flexible(
                flex: 3,
                child: Container(
                  child: Column(
                    // mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.getEncabezadoTiendaOrigen(),
                        maxLines: 4,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      /*
                      Text(
                        widget.getDireccionTiendaOrigen(),
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      */
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Column(
                  children: <Widget>[
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
              Flexible(
                flex: 3,
                child: Column(
                  // mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    widget.getEncabezadoTiendaDestino() == null ? Text('') :Text(
                      widget.getEncabezadoTiendaDestino(),
                      maxLines: 4,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      widget.getDireccionTiendaDestino(),
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        */
        Container(
          padding: EdgeInsets.only(bottom: 15),
          child: ExpansionTile(
            title: Text(
              "Productos de esta tienda (${widget.verifyNumeroArticulosTienda()})",
              style: TextStyle(color: HexColor("#637381"), fontSize: 10),
            ),
            children: <Widget>[
              ListView.builder(
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.getListaProductos().length,
                itemBuilder: (context, position) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 15),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 50,
                          height: 50,
                          margin: EdgeInsets.only(left: 5, right: 20),
                          child: Image.network(
                              '${imgBaseUrl}${widget.getListaProductos().elementAt(position).getUrl()}'),
                          // "https://via.placeholder.com/150/92c952"),
                        ),
                        Flexible(
                          // margin: EdgeInsets.only(left: 9),
                          child: Container(
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                // "Papaya Maradol Kg.",
                                widget
                                    .getListaProductos()
                                    .elementAt(position)
                                    .getEncabezado(),

                                overflow: TextOverflow.ellipsis,

                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: HexColor("#212B36"),
                                ),
                              ),
                              Text(
                                // "2.15 kg × \$9.80/Kg",
                                widget
                                    .getListaProductos()
                                    .elementAt(position)
                                    .getDescripcion(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: HexColor("#454F5B"),
                                ),
                              ),
                              /*
                              Text(
                                // "\$21.32",
                                widget
                                    .getListaProductos()
                                    .elementAt(position)
                                    .getPrecioTotal(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: HexColor("#212B36"),
                                ),
                              ),
                              */
                            ],
                          ),
                          )
                        )
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
