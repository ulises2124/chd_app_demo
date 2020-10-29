import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:chd_app_demo/widgets/deliveryInformation.dart';
import 'package:chd_app_demo/views/Checkout/DeliveryDaysConsignmentWidget.dart';
import 'package:chd_app_demo/views/Checkout/DeliveryHoursConsignmentWidget.dart';
import 'package:chd_app_demo/services/ArticulosServices.dart';
import 'package:chd_app_demo/views/Checkout/Consignment.dart';
import 'package:chd_app_demo/views/Servicios/KenticoServices.dart';

class ConsigmentWidget extends StatefulWidget {
  final slotsList;
  final carrito;
  final isPickUp;
  final Function callback;

  ConsigmentWidget({
    Key key,
    this.slotsList,
    this.carrito,
    this.isPickUp,
    this.callback,
  }) : super(key: key);

  @override
  _ConsigmentWidgetState createState() => _ConsigmentWidgetState();
}

class _ConsigmentWidgetState extends State<ConsigmentWidget> {
  bool hasOneRestricted = false;

  NumberFormat moneda = new NumberFormat.currency(locale: 'es_MX', symbol: "\$");

  List<Consignment> consignments = [];
  List cartItemsImages = [];

  List<String> deliveryDisplayHours = ['08:00 - 10:00', '10:00 - 12:00', '12:00 - 14:00', '14:00 - 16:00', '16:00 - 18:00', '18:00 - 20:00', '20:00 - 22:00'];

  List<String> deliveryHours = [
    '8am - 10am',
    '10am - 12pm',
    '12pm - 2pm',
    '2pm - 4pm',
    '4pm - 6pm',
    '6pm - 8pm',
    '8pm - 10pm',
  ];

  DateFormat formatter = new DateFormat("MMMM-d");

  String kenticoText;

  DeliveryStore getDeliveryStore(var slot, var carrito) {
    DeliveryOrigin tempStore = new DeliveryOrigin();
    DeliveryDest tempDest = new DeliveryDest();
    DeliveryStore result = new DeliveryStore();

    tempStore.setConsignmentCode(slot['consignmentCode']);
    tempStore.setWarehouseCode(slot['warehouseCode']);
    tempStore.setWarehouseName(slot['warehouseName']);

    for (var consignment in carrito['consignments']) {
      if (consignment['code'] == tempStore.getConsignmentCode()) {
        List entries = consignment['entries'];
        int quantity = 0;
        List<DeliveryProduct> productList = new List<DeliveryProduct>();
        for (var entry in entries) {
          double number = double.parse(entry['orderEntry']['decimalQty'].toString());
          quantity++;
          /*
          var images = await ArticulosServices.getProductHybrisSearch(
              entry['orderEntry']['product']['code'].toString());
              */
          //String urlProducto = images['images'][0]['url'];
          String nombreProducto = entry['orderEntry']['product']['name'].toString();
          String code = entry['orderEntry']['product']['unit']['code'].toString();
          double totalPrice = double.parse(entry['orderEntry']['totalPrice']['value'].toString());
          double pricePerUnit = totalPrice / number.round();

          String descriptor = "";
          if (code == 'PCE') {
            descriptor =
                //'${number.round()} × ${moneda.format(pricePerUnit)}';
                '${number.round()} pieza${number > 1 ? "s" : ""}';
          } else {
            pricePerUnit = double.parse(entry['orderEntry']['totalPrice']['value'].toString()) / number;
            descriptor =
                //'${number.toString()} kg × ${moneda.format(pricePerUnit)} / kg';
                '${number.toString()} kg';
          }
          DeliveryProduct nuevoProducto = new DeliveryProduct();

          var imageProd = cartItemsImages.firstWhere((i) => i['code'] == entry['orderEntry']['product']['code']);

          nuevoProducto.setUrl(imageProd['url']);
          nuevoProducto.setEncabezado(nombreProducto);
          nuevoProducto.setDescripcion(descriptor);
          nuevoProducto.setPrecioTotal(moneda.format(totalPrice));
          productList.add(nuevoProducto);
        }
        tempStore.setProductCount(quantity.toString());
        var address = consignment['shippingAddress'];
        String placeName;
        if (slot['type'] == 'ENVIO') {
          if (address['firstName'] == null || address['firstName'].toString().isEmpty) {
            placeName = 'Envío a Domicilio';
          } else {
            placeName = address['firstName'];
          }
        } else {
          if (slot['warehouseName'] == null || slot['warehouseName'].toString().isEmpty) {
            placeName = 'Tienda Chedraui';
          } else {
            placeName = slot['warehouseName'];
          }
        }
        tempDest.setPlaceName(placeName);
        tempDest.setPlaceAddress(address['line1']);
        result = DeliveryStore(
            encabezadoTiendaOrigen: tempStore.getWarehouseName(),
            direccionTiendaOrigen: tempStore.getWarehouseCode(),
            encabezadoTiendaDestino: tempDest.getPlaceName(),
            direccionTiendaDestino: tempDest.getPlaceAddress(),
            isPickUp: widget.isPickUp,
            isDHL: slot['slots'].length == 0,
            numeroArticulosTienda: int.parse(tempStore.getProductCount()),
            listaProductos: productList);
        break;
      }
    }
    return result;
  }

  Consignment searchConsignment(String code) {
    for (Consignment singleConsignment in consignments) {
      if (singleConsignment.consignmentCode == code) {
        return singleConsignment;
      }
    }
  }

  void setConsigment(String code,
      {String type, int selectedDateIndex, int selectedHourIndex, DateTime timeFrom, DateTime timeTo, DateTime dateSelected, String formatedDateTime, String storeFrom, List<dynamic> productos}) {
    int i = consignments.indexWhere((c) {
      return c.consignmentCode == code;
    });
    if (selectedDateIndex != null) consignments[i].selectedDateIndex = selectedDateIndex;
    if (selectedHourIndex != null) consignments[i].selectedHourIndex = selectedHourIndex;
    if (timeFrom != null) consignments[i].timeFrom = timeFrom;
    if (timeTo != null) consignments[i].timeTo = timeTo;
    if (dateSelected != null) consignments[i].dateSelected = dateSelected;
    if (formatedDateTime != null) consignments[i].formatedDateTime = formatedDateTime;
    if (productos != null) consignments[i].productos = productos;
    this.widget.callback(consignments);
  }

  int getSelectedDayConsignment(consignmentCode) {
    Consignment temp = searchConsignment(consignmentCode);
    return temp.selectedDateIndex;
  }

  int getSelectedHourConsignment(consignmentCode) {
    Consignment temp = searchConsignment(consignmentCode);
    return temp.selectedHourIndex;
  }

  selectDeliveryDayConsignment(String consignmentCode, int index, DateTime linkedDate) {
    int _selectedDay = index;
    //int _selectedHour = _selectedDay != index ? 0 : getSelectedHourConsignment(consignmentCode);
    int _selectedHour = 0;
    setState(() {
      setConsigment(consignmentCode, selectedDateIndex: index, selectedHourIndex: _selectedHour, dateSelected: linkedDate);
    });
  }

  selectDeliveryHourConsigment(String consignmentCode, int index) {
    int _selectedHour = index;
    setState(() {
      setConsigment(consignmentCode, selectedHourIndex: _selectedHour);
    });
  }

  String getMesDia(DateTime d) {
    final int n_month = d.month;
    final int n_day = d.day;
    String s_month = "";
    String s_day = "";
    final dt_today = DateTime.now().toLocal();
    if (n_day == dt_today.day) {
      return "Hoy";
    }
    if (n_day == dt_today.day + 1) {
      return "Mañana";
    }
    switch (n_month) {
      case 1:
        s_month = "Ene";
        break;
      case 2:
        s_month = "Feb";
        break;
      case 3:
        s_month = "Mar";
        break;
      case 4:
        s_month = "Abr";
        break;
      case 5:
        s_month = "May";
        break;
      case 6:
        s_month = "Jun";
        break;
      case 7:
        s_month = "Jul";
        break;
      case 8:
        s_month = "Ago";
        break;
      case 9:
        s_month = "Sep";
        break;
      case 10:
        s_month = "Oct";
        break;
      case 11:
        s_month = "Nov";
        break;
      case 12:
        s_month = "Dic";
        break;
    }
    s_day = n_day < 10 ? "0" + n_day.toString() : n_day.toString();
    return "$s_day - $s_month";
  }

  List<Widget> getDeliveryDateSlots(var slot) {
    List<Widget> expandedSlots = [];
    if (slot == null) return expandedSlots;
    var dateSlotIndex = 0;
    var code = slot['consignmentCode'];
    for (var slotUnico in slot['slots']) {
      List<List<String>> fechaHorasList = new List<List<String>>();
      List<String> fechaHoras = new List<String>();
      String fechaKey = slotUnico["key"];
      var hourSlotIndex = 0;
      for (var timeSlot in slotUnico["value"]["slots"]) {
        fechaHoras.add(timeSlot["displayTime"]);
        hourSlotIndex++;
      }
      fechaHorasList.add(fechaHoras);
      List<String> tmpFecha = slotUnico["key"].split("/");
      DateTime fecha = DateTime(int.parse(tmpFecha[2]), int.parse(tmpFecha[1]), int.parse(tmpFecha[0]));
      expandedSlots.add(Expanded(
        flex: 3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DeliveryDayConsignmentItem(
            selectDeliveryDayConsignment,
            index: dateSlotIndex,
            isSelected: getSelectedDayConsignment(code) == dateSlotIndex,
            //title: DateFormat.MMMMd('es').format(fecha).toString(),
            //title: formatter.format(fecha).toString(),
            title: getMesDia(fecha),
            linkedDate: fecha,
            consignmentCode: code,
          ),
        ),
      ));
      dateSlotIndex++;
    }
    return expandedSlots;
  }

  List<Widget> getDeliveryHourSlots(var slot) {
    List<Widget> expandedSlots = [];
    int index = 0;
    int rowIndex = 0;
    List<Widget> rowList = new List<Widget>();
    List<Widget> expandList = new List<Widget>();
    Map<String, String> deliveryHoursMap = Map.fromIterables(deliveryDisplayHours, deliveryHours);
    List<List<String>> fechaHorasList = new List<List<String>>();
    var code = slot['consignmentCode'];
    for (var slotUnico in slot['slots']) {
      List<String> fechaHoras = new List<String>();
      String fechaKey = slotUnico["key"];
      var hourSlotIndex = 0;
      for (var timeSlot in slotUnico["value"]["slots"]) {
        fechaHoras.add(timeSlot["displayTime"]);
        hourSlotIndex++;
      }
      fechaHorasList.add(fechaHoras);
    }

    if (fechaHorasList == null || fechaHorasList.length == 0) return rowList;

    var _selectedDay = getSelectedDayConsignment(code);

    for (var timeSlot in fechaHorasList[_selectedDay]) {
      if (index % 3 == 0) {
        // print("Nuevo Row");
        rowIndex = 0;

        expandList = [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: SizedBox(),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: SizedBox(),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: SizedBox(),
            ),
          ),
        ];

        rowList.add(Row(
          children: expandList,
        ));
      }

      var _selectedHour = getSelectedHourConsignment(code);

      expandList[rowIndex] = Expanded(
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: DeliveryHourConsignmentItem(
            selectDeliveryHourConsigment,
            index: index,
            isSelected: _selectedHour == index ? true : false,
            title: deliveryHoursMap[timeSlot],
            consignmentCode: code,
          ),
        ),
      );

      index++;
      rowIndex++;
    }

    return rowList;
  }

  getDeliveryDateTime(var slot) {
    List slotsDateTime = slot['slots'];
    if (slotsDateTime.length > 0) {
      Consignment savedSlot = searchConsignment(slot['consignmentCode']);
      bool repeated = savedSlot.repeated ?? false;
      if (!repeated) {
        return Column(children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(top: 15, right: 15, left: 15, bottom: 5),
            child: Text(
              'Selecciona la fecha de entrega de tu pedido.',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ),
          Container(
            child:kenticoText == null ?  LinearProgressIndicator()  : Text(kenticoText ?? ''),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(100),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          Row(children: getDeliveryDateSlots(slot)),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(top: 10, right: 15, left: 15, bottom: 10),
            child: Text(
              'Ahora, escoge la hora en que deseas que tu orden sea entregada.',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ),
          Container(
            child: Column(children: getDeliveryHourSlots(slot)),
          ),
          Divider(
            height: 10,
            indent: 10,
          )
        ]);
      } else {
        //return SizedBox(height: 0,);
        return Column(children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(top: 20, right: 15, left: 15, bottom: 5),
            child: Text(
              'Estos productos llegarán en el horario seleccionado anteriormente:',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ),
          Divider(
            height: 10,
            indent: 10,
          )
        ]);
      }
    } else {
      //return SizedBox(height: 0,);
      return Column(children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(top: 20, right: 15, left: 15, bottom: 5),
          child: Text(
            'Estos productos llegarán entre los siguientes 5 a 7 días hábiles:',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ),
        Divider(
          height: 10,
          indent: 10,
        )
      ]);
    }
  }

  List<Widget> processSlots(slotsList, carrito) {
    List<Widget> rows = [];
    slotsList.forEach((slot) {
      rows.add(Container(
          child: Column(children: <Widget>[
        getDeliveryDateTime(slot),
        getDeliveryStore(slot, carrito),
      ])));
    });
    return rows;
  }

  loadSlots() {
    List<Consignment> consignmentsList = [];
    hasOneRestricted = false;
    for (var cons in widget.slotsList) {
      var restricted = cons['slots'].length > 0;
      var repeated = hasOneRestricted && restricted;
      consignmentsList.add(new Consignment(cons['consignmentCode'], restricted, repeated: repeated));
      if (restricted) {
        hasOneRestricted = true;
      }
    }
    setState(() {
      consignments = consignmentsList;
    });
    this.widget.callback(consignments);
  }

  loadImages() async {
    List imagesList = [];
    int indexCart = 0;

    Future<dynamic> getImages(product) async {
      var singleProduct = await ArticulosServices.getProductHybrisSearch(product['product']['code']);
      String prodImage = (() {
        if (singleProduct != null && singleProduct['images'] != null && singleProduct['images'].length > 0) {
          return singleProduct['images'][0]['url'];
        } else {
          return "";
        }
      })();
      String code = product['product']['code'];

      var imgProduct = {"code": code, "url": prodImage};
      imagesList.add(imgProduct);
      indexCart++;

      return product['product']['name'];
    }

    Iterable entries = widget.carrito['entries'];
    Iterable<Future<dynamic>> mapped = entries.map((p) => getImages(p));

    if (widget.carrito['totalItems'] > 0) {
      for (Future<dynamic> f in mapped) {
        f.then((v) {
          if (indexCart == (widget.carrito['totalItems'])) {
            setState(() {
              cartItemsImages = imagesList;
            });
          }
        });
      }
    } else {
      setState(() {
        cartItemsImages = imagesList;
      });
    }
  }

  initState() {
    loadImages();
    loadSlots();
    super.initState();
    textCheckout();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: consignments.length > 0 && cartItemsImages.length > 0
            ? processSlots(widget.slotsList, widget.carrito)
            : <Widget>[
                SizedBox(
                  height: 50,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              ]);
  }

  textCheckout() async {
    List body = await KenticoServices.getTextCheckout();
    String text = '';
    text = body.first['elements']['informacion_de_entrega']['value'];
    setState(() {
      kenticoText = text;
    });
  }
}
