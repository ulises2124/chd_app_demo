import 'dart:async';
import 'package:chd_app_demo/services/FireBaseServices.dart';
import 'package:chd_app_demo/views/Pedidos/ConsignmentStatusDTO.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chd_app_demo/services/PedidosServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/views/Pedidos/ChatPedido.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:chd_app_demo/utils/NetworkData.dart';
import 'dart:io' show Platform;

class PedidosController {
  static Widget orderDetails(BuildContext _context, _orderData) {
    String _payment;
    if (_orderData.paymentInfos[0].cardType.code == 'PayInStore' || _orderData.paymentInfos[0].cardType.code == 'PayOnDelivery') {
      _payment = 'Total a pagar';
    } else {
      _payment = 'Total pagado';
    }
    String _createdDate = formatDate(_orderData.created);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(2.0, 1.0),
            blurRadius: 5.0,
          ),
        ],
      ),
      child: ExpansionTile(
        backgroundColor: Colors.white,
        title: Text(
          'Ver detalles del pedido',
          style: TextStyle(fontSize: 14.0, color: Colors.black),
        ),
        children: <Widget>[
          Container(
            margin: const EdgeInsets.fromLTRB(17.0, 0.0, 17.0, 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 6,
                  child: Text(
                    'Fecha y hora de solicitud: ',
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Text(
                    '$_createdDate',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10),
                  ),
                )
              ],
            ),
          ),
          Container(
            height: 1.0,
            margin: const EdgeInsets.fromLTRB(17.0, 0.0, 17.0, 10.0),
            color: Colors.grey[300],
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(17.0, 0.0, 17.0, 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  'El pago de tu pedido se realizó con los siguientes datos:',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(17.0, 0.0, 17.0, 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: _deliveryAddress(_context, _orderData),
                ),
                Container(
                  child: _paymentInfos(_orderData.paymentInfos),
                ),
                Container(
                  child: _contactInfo(_orderData),
                ),
                Container(
                  height: 1.0,
                  color: Colors.grey[350],
                  margin: const EdgeInsets.only(bottom: 20.0),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              '$_payment:',
                              style: TextStyle(
                                fontSize: 20.0,
                              ),
                            ),
                          ),
                          Container(
                            child: Text(
                              '${_orderData.totalPriceWithTax.formattedValue}',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String formatDate(String date) {
    DateTime _stringToDate = DateTime.parse(date).toLocal();

    String _formatWeekday(int weekday) {
      switch (weekday) {
        case 1:
          return 'Lunes';
        case 2:
          return 'Martes';
        case 3:
          return 'Miércoles';
        case 4:
          return 'Jueves';
        case 5:
          return 'Viernes';
        case 6:
          return 'Sábado';
        case 7:
          return 'Domingo';
        default:
          return null;
      }
    }

    String _formatMonth(int month) {
      switch (month) {
        case 1:
          return 'Enero';
        case 2:
          return 'Febrero';
        case 3:
          return 'Marzo';
        case 4:
          return 'Abril';
        case 5:
          return 'Mayo';
        case 6:
          return 'Junio';
        case 7:
          return 'Julio';
        case 8:
          return 'Agosto';
        case 9:
          return 'Septiembre';
        case 10:
          return 'Octubre';
        case 11:
          return 'Noviembre';
        case 12:
          return 'Diciembre';
        default:
          return null;
      }
    }

    String _formatTime(int time) {
      if (time < 10) {
        return '0' + time.toString();
      } else {
        return time.toString();
      }
    }

    return '${_formatWeekday(_stringToDate.weekday)} ${_stringToDate.day} de ${_formatMonth(_stringToDate.month)}, ${_stringToDate.year}, ${_formatTime(_stringToDate.hour)}:${_formatTime(_stringToDate.minute)} hrs';
  }

  static Widget _deliveryAddress(BuildContext context, _orderData) {
    if (_orderData.deliveryMode.code == 'pickup') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(bottom: 3.0),
            child: Text(
              'Dirección de entrega',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 15.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.grey[400],
                    size: 16.0,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.75,
                          margin: const EdgeInsets.only(bottom: 3.0),
                          child: Text(
                            '''${_orderData.entries[0].deliveryPointOfService.displayName}''',
                            style: TextStyle(fontSize: 12.0),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.75,
                          child: Text(
                            '''${_orderData.entries[0].deliveryPointOfService.address.formattedAddress}''',
                            style: TextStyle(fontSize: 10.0, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(bottom: 3.0),
            child: Text(
              'Dirección de envío',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 15.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: Icon(
                    Icons.local_shipping,
                    color: Colors.grey[400],
                    size: 16.0,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.75,
                          margin: const EdgeInsets.only(bottom: 3.0),
                          child: Text(
                            '''${_orderData.deliveryAddress.line1}''',
                            style: TextStyle(fontSize: 12.0),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.75,
                          child: Text(
                            '''${_orderData.deliveryAddress.formattedAddress}''',
                            style: TextStyle(fontSize: 10.0, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      );
    }
  }

  static Widget _paymentInfos(List _paymentInfos) {
    Widget _payment;
    List<Widget> _payments = List<Widget>();
    for (var item in _paymentInfos) {
      switch (item.cardType.code) {
        case 'master':
          Container(
            margin: const EdgeInsets.only(right: 5.0),
            child: _payment = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(bottom: 3.0),
                  child: Text(
                    'Tarjeta Bancaria',
                    style: TextStyle(fontSize: 12.0),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 3.0),
                  child: Text(
                    '${item.cardType.name}',
                    style: TextStyle(fontSize: 10.0, color: Colors.grey),
                  ),
                ),
                // Container(
                //   margin: const EdgeInsets.only(bottom: 3.0),
                //   child: Text(
                //     'XXXX XXXX XXXX ',
                //     style: TextStyle(fontSize: 10.0, color: Colors.grey),
                //   ),
                // ),
                Container(
                  child: Text(
                    'Mi tarjeta',
                    style: TextStyle(fontSize: 10.0, color: Colors.grey),
                  ),
                ),
              ],
            ),
          );
          break;
        case 'visa':
          Container(
            margin: const EdgeInsets.only(right: 5.0),
            child: _payment = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(bottom: 3.0),
                  child: Text(
                    'Tarjeta Bancaria',
                    style: TextStyle(fontSize: 12.0),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 3.0),
                  child: Text(
                    '${item.cardType.name}',
                    style: TextStyle(fontSize: 10.0, color: Colors.grey),
                  ),
                ),
                // Container(
                //   margin: const EdgeInsets.only(bottom: 3.0),
                //   child: Text(
                //     'XXXX XXXX XXXX ',
                //     style: TextStyle(fontSize: 10.0, color: Colors.grey),
                //   ),
                // ),
                Container(
                  child: Text(
                    'Mi tarjeta',
                    style: TextStyle(fontSize: 10.0, color: Colors.grey),
                  ),
                ),
              ],
            ),
          );
          break;
        case 'amex':
          Container(
            margin: const EdgeInsets.only(right: 5.0),
            child: _payment = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(bottom: 3.0),
                  child: Text(
                    'Tarjeta Bancaria',
                    style: TextStyle(fontSize: 12.0),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 3.0),
                  child: Text(
                    '${item.cardType.name}',
                    style: TextStyle(fontSize: 10.0, color: Colors.grey),
                  ),
                ),
                // Container(
                //   margin: const EdgeInsets.only(bottom: 3.0),
                //   child: Text(
                //     'XXXX XXXX XXXX ${item.cardNumber.substring(12)}',
                //     style: TextStyle(fontSize: 10.0, color: Colors.grey),
                //   ),
                // ),
                Container(
                  child: Text(
                    'Mi tarjeta',
                    style: TextStyle(fontSize: 10.0, color: Colors.grey),
                  ),
                ),
              ],
            ),
          );
          break;
        case 'PayInStore':
          _payment = Container(
            margin: const EdgeInsets.only(bottom: 3.0, right: 5.0),
            child: Text(
              'Pagar en tienda',
              style: TextStyle(fontSize: 12.0),
            ),
          );
          break;
        case 'PayOnDelivery':
          _payment = Container(
            margin: const EdgeInsets.only(bottom: 3.0, right: 5.0),
            child: Text(
              'Pago contra entrega',
              style: TextStyle(fontSize: 12.0),
            ),
          );
          break;
        case 'PayInAssociatedStore':
          _payment = Container(
            margin: const EdgeInsets.only(bottom: 3.0, right: 5.0),
            child: Text(
              'Pago en establecimiento asociado',
              style: TextStyle(fontSize: 12.0),
            ),
          );
          break;
        default:
          _payment = Container(
            margin: const EdgeInsets.only(bottom: 3.0, right: 5.0),
            child: Text(
              '${item.cardType.name}',
              style: TextStyle(fontSize: 12.0),
            ),
          );
          break;
      }
      _payments.add(_payment);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(bottom: 3.0),
          child: Text(
            'Método de pago',
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 3.0),
                child: Icon(
                  Icons.payment,
                  color: Colors.grey[400],
                  size: 16.0,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _payments,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _contactInfo(_orderData) {
    String _phone = _orderData.deliveryMode.code != 'pickup' && _orderData.deliveryAddress != null ? '+52 ${_orderData.deliveryAddress.phone}' : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          child: Text(
            'Datos de contacto',
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 3.0),
                child: Icon(
                  Icons.person_outline,
                  color: Colors.grey[400],
                  size: 16.0,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(bottom: 3.0),
                    child: Text(
                      'Mis datos',
                      style: TextStyle(fontSize: 12.0),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 3.0),
                    child: Text(
                      "${_orderData.user.uid}",
                      style: TextStyle(fontSize: 10.0, color: Colors.grey),
                    ),
                  ),
                  Container(
                    child: Text(
                      _phone,
                      style: TextStyle(fontSize: 10.0, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget consignmentStatus(_consignments, int _index) {
    Widget _status = Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3.0),
              child: OrderInProgress(),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(bottom: 2.0),
                child: Text(
                  'Su pedido está en proceso',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(99, 115, 129, 1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    switch (_consignments[_index].status) {
      case "DELIVERY_COMPLETED":
        _status = Container(
          margin: const EdgeInsets.only(bottom: 15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(right: 8.0),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: OrderDelivered(),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(bottom: 2.0),
                    child: Text(
                      'Su pedido ha sido entregado',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(99, 115, 129, 1),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
        break;
      case "PICKUP_COMPLETE":
        _status = Container(
          margin: const EdgeInsets.only(bottom: 15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(right: 8.0),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: OrderDelivered(),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(bottom: 2.0),
                    child: Text(
                      'Su pedido ha sido recogido',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(99, 115, 129, 1),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
        break;
      case "CANCELLED":
        _status = Container(
          margin: const EdgeInsets.only(bottom: 15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(right: 8.0),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: OrderCancelled(),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(bottom: 2.0),
                    child: Text(
                      'Este pedido ha sido cancelado',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(99, 115, 129, 1),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
        break;
      default:
        break;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Paquete ${_index + 1}',
                  style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.w400, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
        _status,
      ],
    );
  }

  static Widget deliveryDetails(_orderData, int _index) {
    String _toAMPM(int _hour) {
      if (_hour < 12) {
        return '$_hour am';
      } else if (_hour == 12) {
        return "12 pm";
      } else {
        return '${_hour - 12} pm';
      }
    }

    String _deliveryTime(_consignment) {
      if (_consignment.timeFrom != null && _consignment.timeTo != null) {
        DateTime dt_from = DateTime.parse(_consignment.timeFrom).toLocal();
        DateTime dt_to = DateTime.parse(_consignment.timeTo).toLocal();
        String _dt = "${dt_from.day < 10 ? '0' + dt_from.day.toString() : dt_from.day.toString()}/${dt_from.month < 10 ? '0' + dt_from.month.toString() : dt_from.month.toString()}/${dt_from.year.toString()}";
        String _from = _toAMPM(dt_from.hour);
        String _to = _toAMPM(dt_to.hour);
        return '$_dt $_from - $_to';
      } else {
        return 'Entre 5 a 7 días\nhábiles a partir de\nla fecha de pedido.';
      }
    }

    String _deliveryName(String _deliveryCode) {
      if (_deliveryCode == 'pickup') {
        return 'Recoger en tienda';
      } else {
        return 'Envío a domicilio';
      }
    }

    String _estimatedDelivery = _deliveryTime(_orderData.consignments[_index]);
    String _deliveryType = _deliveryName(_orderData.deliveryMode.code);
    String _client = _orderData.user.name;

    return Column(
      children: <Widget>[
        Container(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 3.0),
                      child: Text(
                        'Entrega estimada',
                      ),
                    ),
                    Container(
                      child: Text(
                        '$_estimatedDelivery',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(margin: const EdgeInsets.only(bottom: 3.0), child: Text('Tipo de entrega')),
                    Container(
                      child: Text(
                        '$_deliveryType',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(margin: const EdgeInsets.only(bottom: 3.0), child: Text('Recibe')),
                    Container(
                      child: Text(
                        '$_client',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _pickupMap(
    BuildContext context,
    _orderData,
    int _index,
    //ConsignmentStatus _orderStatus) {
  ) {
    Completer<GoogleMapController> _controller = Completer();
    final Set<Marker> _markers = Set();
    final LatLng _storePosition = LatLng(_orderData.consignments[_index].deliveryPointOfService.geoPoint.latitude, _orderData.consignments[_index].deliveryPointOfService.geoPoint.longitude);
    final Marker _storeMarker = Marker(
      markerId: MarkerId('Store'),
      position: _storePosition,
      draggable: false,
      infoWindow: InfoWindow(
        title: '${_orderData.entries[_index].deliveryPointOfService.displayName}',
        snippet: '${_orderData.entries[_index].deliveryPointOfService.address.formattedAddress}',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );
    _markers.add(_storeMarker);

    void _onMapCreated(GoogleMapController controller) {
      _controller.complete(controller);
    }

    return Container(
      margin: const EdgeInsets.only(left: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          consignmentPickupTracking(_orderData.consignments[_index].status.toLowerCase()),
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: _storePosition,
                  zoom: 15.0,
                ),
                markers: _markers,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _deliveryMapBuilder(BuildContext context, ConsignmentStatus _orderStatus) {
    bool _buildMap;
    Completer<GoogleMapController> _controller = Completer();
    final Set<Marker> _markers = Set();
    LatLng _driverPosition;
    if (_orderStatus.status == null || _orderStatus.status == 'READY' || _orderStatus.status == 'DeliveryInbox' || _orderStatus.status == 'Shopping' || _orderStatus.status == 'PickingDone' || _orderStatus.status == 'ReadyToDispatch' || _orderStatus.status == 'Accepted' || _orderStatus.status == 'DeliveryPlanned' || _orderStatus.status == 'Done' || _orderStatus.status == 'Closed' || _orderStatus.status == 'Canceled') {
      _buildMap = false;
    } else {
      _buildMap = true;
      _driverPosition = LatLng(_orderStatus.data.latitude, _orderStatus.data.longitude);
      final Marker _driverMarker = Marker(
        markerId: MarkerId('Driver'),
        position: _driverPosition,
        draggable: false,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      );
      _markers.add(_driverMarker);
    }

    void _onMapCreated(GoogleMapController controller) {
      _controller.complete(controller);
    }

    if (_buildMap) {
      return Expanded(
          child: Container(
        height: MediaQuery.of(context).size.height * 0.3,
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: _driverPosition,
            zoom: 15.0,
          ),
          markers: _markers,
        ),
      ));
    } else {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Column(
                children: <Widget>[
                  Image.asset('assets/DeliveryVan.png', height: 150, width: 200, fit: BoxFit.cover),
                  Text('''Por el momento no es posible realizar el rastreo en mapa de este pedido.'''),
                ],
              )),
            ],
          ),
        ),
      );
    }
  }

  static Widget _deliveryMap(
    BuildContext context,
    _orderData,
    int _index,
    //ConsignmentStatus _orderStatus) {
  ) {
    String statusConsignment = _orderData.consignments[_index].status;
    final String _consignment = _orderData.consignments[_index].code;

    return Container(
      margin: const EdgeInsets.only(left: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          consignmentDeliveryTracking(statusConsignment.toLowerCase()),
          FutureBuilder(
            future: PedidosServices.consignmentStatus(_consignment),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Center(
                  child: Theme(
                    data: ThemeData(
                      primaryColor: DataUI.textOpaqueMedium,
                      hintColor: DataUI.opaqueBorder,
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(50.0),
                      child: CircularProgressIndicator(value: null),
                    ),
                  ),
                );
              } else {
                return _deliveryMapBuilder(context, snapshot.data);
              }
            },
          )
        ],
      ),
    );
  }

  static Widget trackingMap(BuildContext context, _orderData, int _index) {
    if (_orderData.deliveryMode.code == 'pickup') {
      return _pickupMap(context, _orderData, _index);
    } else {
      return _deliveryMap(context, _orderData, _index);
    }
    /*
    if (_orderData.deliveryMode.code == 'pickup') {
      return FutureBuilder(
        future: PedidosServices.consignmentStatus(_consignment),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: Theme(
                data: ThemeData(
                  primaryColor: DataUI.textOpaqueMedium,
                  hintColor: DataUI.opaqueBorder,
                ),
                child: Container(
                  margin: const EdgeInsets.all(100.0),
                  child: CircularProgressIndicator(value: null),
                ),
              ),
            );
          } else {
            return _pickupMap(context, _orderData, _index, snapshot.data);
          }
        },
      );
    } else {
      return FutureBuilder(
        future: PedidosServices.consignmentStatus(_consignment),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: Theme(
                data: ThemeData(
                  primaryColor: DataUI.textOpaqueMedium,
                  hintColor: DataUI.opaqueBorder,
                ),
                child: Container(
                  margin: const EdgeInsets.all(100.0),
                  child: CircularProgressIndicator(value: null),
                ),
              ),
            );
          } else {
            return _deliveryMap(context, _orderData, _index, snapshot.data);
          }
        },
      );
    }
    */
  }

  static Widget pickerInfo(BuildContext context, _orderData, int _index) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.fromLTRB(20.0, 15.0, 15.0, 15.0),
            child: CircleAvatar(
              radius: 30.0,
              backgroundColor: Colors.white,
              //backgroundImage: ,
              child: Icon(
                Icons.account_circle,
                size: 60.0,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 20.0),
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                /*Text(
                  'Your Picker',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10.0,
                  ),
                ),*/
                FlatButton(
                  child: Text(
                    'Detalles del repartidor',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: RouteSettings(name: DataUI.chatPedidosRoute),
                        builder: (BuildContext context) => ChatPedido(
                          consignment: _orderData.consignments[_index].code,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ), /*
          Container(
            child: Row(
              children: <Widget>[
                Container(
                  child: IconButton(
                    icon: Icon(Icons.phone),
                    color: Colors.grey,
                    iconSize: 30.0,
                    onPressed: () {},
                  ),
                ),
                Container(
                  child: IconButton(
                    icon: Icon(Icons.chat),
                    color: Colors.grey,
                    iconSize: 30.0,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => ChatPedido(
                                consignment:
                                    _orderData.consignments[_index].code,
                              ),
                        ),
                      );
                      //print(_orderData.consignments[_index].code);
                    },
                  ),
                ),
              ],
            ),
          ),*/
        ],
      ),
    );
  }

  static Widget _stepper(String _position, String _state, String _step) {
    switch (_position) {
      case 'start':
        if (_state == 'current') {
          return Row(
            children: <Widget>[
              Container(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    ClipOval(
                      child: Container(
                        height: 26.0,
                        width: 26.0,
                        color: Colors.green[100],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 13.0),
                      width: 5.0,
                      height: 13.0,
                      color: Colors.green[200],
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: ClipOval(
                        child: Container(
                          height: 14.0,
                          width: 14.0,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 6.0),
                child: Text(
                  '$_step',
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        } else {
          return Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(left: 6.0),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(top: 13.0),
                      width: 5.0,
                      height: 13.0,
                      color: Colors.green,
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: ClipOval(
                        child: Container(
                          height: 14.0,
                          width: 14.0,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(
                  '$_step',
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        }
        break;
      case 'end':
        if (_state == 'current') {
          return Row(
            children: <Widget>[
              Container(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    ClipOval(
                      child: Container(
                        height: 26.0,
                        width: 26.0,
                        color: Colors.green[100],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 13.0),
                      width: 5.0,
                      height: 13.0,
                      color: Colors.green,
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: ClipOval(
                        child: Container(
                          height: 14.0,
                          width: 14.0,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 6.0),
                child: Text(
                  '$_step',
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        } else {
          return Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(left: 6.0),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 13.0),
                      width: 5.0,
                      height: 13.0,
                      color: Colors.grey[400],
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: ClipOval(
                        child: Container(
                          height: 14.0,
                          width: 14.0,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(
                  '$_step',
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ],
          );
        }
        break;
      default:
        if (_state == 'current') {
          return Row(
            children: <Widget>[
              Container(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    ClipOval(
                      child: Container(
                        height: 26.0,
                        width: 26.0,
                        color: Colors.green[100],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 13.0),
                      width: 5.0,
                      height: 13.0,
                      color: Colors.green,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 13.0),
                      width: 5.0,
                      height: 13.0,
                      color: Colors.green[200],
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: ClipOval(
                        child: Container(
                          height: 14.0,
                          width: 14.0,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 6.0),
                child: Text(
                  '$_step',
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        } else if (_state == 'done') {
          return Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(left: 6.0),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 13.0),
                      width: 5.0,
                      height: 13.0,
                      color: Colors.green,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 13.0),
                      width: 5.0,
                      height: 13.0,
                      color: Colors.green,
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: ClipOval(
                        child: Container(
                          height: 14.0,
                          width: 14.0,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(
                  '$_step',
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        } else {
          return Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(left: 6.0),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 13.0),
                      width: 5.0,
                      height: 13.0,
                      color: Colors.grey[400],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 13.0),
                      width: 5.0,
                      height: 13.0,
                      color: Colors.grey[400],
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: ClipOval(
                        child: Container(
                          height: 14.0,
                          width: 14.0,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(
                  '$_step',
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ],
          );
        }
        break;
    }
  }

  static Widget consignmentPickupTracking(String _tracking) {
    Widget _pickupStepper;

    if (_tracking == 'ready') {
      _pickupStepper = Container(
        margin: const EdgeInsets.only(right: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _stepper('start', 'current', 'Pendiente'),
            _stepper('middle', 'pending', 'En proceso de surtido'),
            _stepper('end', 'pending', 'Listo para recoger'),
          ],
        ),
      );
    } else if (_tracking == 'pickpack') {
      _pickupStepper = Container(
        margin: const EdgeInsets.only(right: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _stepper('start', 'done', 'Pendiente'),
            _stepper('middle', 'current', 'En proceso de surtido'),
            _stepper('end', 'pending', 'Listo para recoger'),
          ],
        ),
      );
    } else {
      _pickupStepper = Container(
        margin: const EdgeInsets.only(right: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _stepper('start', 'done', 'Pendiente'),
            _stepper('middle', 'done', 'En proceso de surtido'),
            _stepper('end', 'current', 'Listo para recoger'),
          ],
        ),
      );
    }

    return _pickupStepper;
  }

  static Widget consignmentDeliveryTracking(String _tracking) {
    Widget _deliveryStepper;

    if (_tracking == 'ready') {
      _deliveryStepper = Container(
        margin: const EdgeInsets.only(right: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[_stepper('start', 'current', 'Pendiente'), _stepper('middle', 'pending', 'En proceso de surtido'), _stepper('middle', 'pending', 'Listo para entrega'), _stepper('end', 'pending', 'Entregada')],
        ),
      );
    } else if (_tracking == 'pickpack') {
      _deliveryStepper = Container(
        margin: const EdgeInsets.only(right: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[_stepper('start', 'done', 'Pendiente'), _stepper('middle', 'current', 'En proceso de surtido'), _stepper('middle', 'pending', 'Listo para entrega'), _stepper('end', 'pending', 'Entregada')],
        ),
      );
    } else if (_tracking == 'delivering') {
      _deliveryStepper = Container(
        margin: const EdgeInsets.only(right: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[_stepper('start', 'done', 'Pendiente'), _stepper('middle', 'done', 'En proceso de surtido'), _stepper('middle', 'current', 'Listo para entrega'), _stepper('end', 'pending', 'Entregada')],
        ),
      );
    } else {
      _deliveryStepper = Container(
        margin: const EdgeInsets.only(right: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[_stepper('start', 'done', 'Pendiente'), _stepper('middle', 'done', 'En proceso de surtido'), _stepper('middle', 'done', 'Listo para entrega'), _stepper('end', 'current', 'Entregada')],
        ),
      );
    }

    return _deliveryStepper;
  }

  static Widget pedidos(_orderData, _index) {
    String _imagesUrl = 'https://prod.chedraui.com.mx';
    List _entries = _orderData.consignments[_index].entries;
    String _itemList;
    int _items = 0;
    for (var qty in _orderData.consignments[_index].entries) {
      if (qty.orderEntry.product.unit != null && qty.orderEntry.product.unit.code == 'KGM') {
        _items += 1;
      } else {
        _items += qty.quantity;
      }
      print(_items);
    }
    if (_items > 1) {
      _itemList = 'Este paquete contiene $_items articulos';
    } else {
      _itemList = 'Este paquete contiene $_items articulo';
    }
    return Container(
      child: ExpansionTile(
        title: Text(
          '$_itemList',
          style: TextStyle(fontSize: 10.0, color: Colors.black),
        ),
        children: <Widget>[
          Container(
            child: ListView.separated(
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: _entries.length,
                separatorBuilder: (context, index) {
                  return Container(
                    color: Colors.grey[350],
                    height: 1.0,
                  );
                },
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(top: 10.0, bottom: 16.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(0.0),
                            child: Container(
                              height: 60.0,
                              child: _entries != null && _entries.length > 0
                                  ? CachedNetworkImage(
                                      imageUrl: '$_imagesUrl${_entries[index].orderEntry.product.images[0].url}',
                                      placeholder: (context, url) => Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                    )
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(top: 15),
                                          height: 60,
                                          child: Image.asset('assets/chd_logo.png'),
                                        ),
                                        Text(
                                          'Imagen no disponible',
                                          textAlign: TextAlign.center,
                                        )
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '${_entries[index].orderEntry.totalPrice.formattedValue}',
                                  style: TextStyle(fontSize: 20.0),
                                ),
                                Text(
                                  '${_entries[index].orderEntry.product.name}',
                                  style: TextStyle(fontSize: 12.0, color: Colors.grey),
                                ),
                                Text(
                                  '${_entries[index].orderEntry.basePrice.formattedValue} ${_entries[index].orderEntry.product.unit != null ? _entries[index].orderEntry.product.unit.name : "Unidad"}',
                                  style: TextStyle(fontSize: 12.0, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            margin: const EdgeInsets.only(right: 15.0),
                            child: Text(
                              '${_entries[index].orderEntry.decimalQty ?? _entries[index].quantity} ${_entries[index].orderEntry.product.unit != null ? (_entries[index].orderEntry.product.unit.name ?? "Unidad") : "Unidad"}',
                              style: TextStyle(
                                fontSize: 12.0,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }

  static Widget chatWindow(_orderData, _index) {
    FireBaseEventController.setCurrentScreen(DataUI.chatPedidosRoute).then((ok) {});
    const platform = const MethodChannel('com.cheadrui.com/mercury');
    const MethodChannel mercuryNativeCallChannel = const MethodChannel('com.cheadrui.com/NativeCall');

    // final webview = FlutterWebviewPlugin();
    final _consignment = _orderData.consignments[_index].code;
    return Container(
        child: Row(children: <Widget>[
      Expanded(
          flex: 1,
          child: FlatButton(
              onPressed: _orderData.consignments[_index].status == 'CANCELLED' || _orderData.consignments[_index].status == 'DELIVERY_COMPLETED'
                  ? null
                  : () async {
                      if (Platform.isAndroid) {
                        try {
                          await platform.invokeMethod('getWitService', {
                            "orderNumber": NetworkData.urlChatMercury + _consignment,
                          });
                        } catch (e) {
                          print(e);
                        }
                      } else if (Platform.isIOS) {
                        await mercuryNativeCallChannel.invokeMethod("openMercuryChat", {"url": NetworkData.urlChatMercury + _consignment});
                      }
                    },
              disabledTextColor: DataUI.textOpaque,
              textColor: DataUI.chedrauiBlueColor,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Image.asset(
                      'assets/img/chat_icon.png',
                      height: 15,
                      width: 15,
                    ),
                  ),
                  Expanded(
                      flex: 2,
                      child: Text(
                        'Enviar Mensaje',
                        style: TextStyle(
                          fontSize: 10.0,
                        ),
                      ))
                ],
              )))
    ]));
  }
}
