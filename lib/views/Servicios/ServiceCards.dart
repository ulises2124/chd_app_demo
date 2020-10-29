import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/Servicios/SelectedService.dart';
import 'package:chd_app_demo/views/Servicios/Util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:math';

class ServiceCard extends StatelessWidget {
  Widget serviceLogo;
  Color cardBackground;
  String serviceName;
  String serviceDescription;
  String sku;
  String skuComision;
  String savedReference;
  String serviceID;
  List<dynamic> categories;
  double saldoMonedero;
  String userEmail;
  dynamic montosSkus;
  String messageToUser;
  Widget toolTip;
  String toolTipDescription;
  String tipoPago;
  String status;
  String alias;
  String reminderFrequency;
  bool extendedCard;
  Function editService;
  String dbID;
  String montoMinimo;
  String montoMaximo;
  ServiceCard({
    this.cardBackground,
    this.serviceID,
    this.serviceDescription,
    this.serviceLogo,
    this.serviceName,
    this.sku,
    this.savedReference,
    this.skuComision,
    this.categories,
    this.saldoMonedero,
    this.userEmail,
    this.montosSkus,
    this.messageToUser,
    this.toolTip,
    this.toolTipDescription,
    this.tipoPago,
    this.status,
    this.alias,
    this.reminderFrequency,
    this.extendedCard,
    this.editService,
    this.dbID,
    this.montoMinimo,
    this.montoMaximo,
  });

  @override
  Widget build(BuildContext context) {
    return extendedCard
        ? GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  settings: RouteSettings(name: DataUI.selectedPagoServiciosRoute),
                  builder: (BuildContext context) => SelectedService(
                    serviceID: serviceID,
                    serviceSku: sku,
                    savedReference: savedReference,
                    serviceSkuComision: skuComision,
                    serviceLogo: serviceLogo,
                    serviceName: serviceName,
                    saldoMonedero: saldoMonedero,
                    userEmail: userEmail,
                    telefonia: montosSkus,
                    messageToUser: messageToUser,
                    toolTip: toolTip,
                    toolTipDescription: toolTipDescription,
                    tipoPago: tipoPago,
                    status: status,
                    montoMaximo: montoMaximo,
                    montoMinimo: montoMinimo,
                  ),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Slidable(
                delegate: SlidableDrawerDelegate(),
                actionExtentRatio: 0.20,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Color(0xcc000000).withOpacity(0.1),
                        offset: Offset(0.0, 5.0),
                        blurRadius: 10.0,
                      ),
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(left: 22, top: 15),
                          child: Row(
                            children: <Widget>[
                              Text(
                                'Recordatorio:',
                                style: TextStyle(fontFamily: 'Archivo', color: HexColor('#212B36'), letterSpacing: 0.2, fontSize: 10),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 8),
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(border: Border.all(color: HexColor('#0D47A1')), borderRadius: BorderRadius.circular(5)),
                                child: Text(
                                  reminderFrequency == 'mensual' ? 'Al principio de cada mes' : '15 de cada mes',
                                  style: TextStyle(
                                    color: HexColor('#0D47A1'),
                                    fontFamily: 'Archivo',
                                    fontSize: 10,
                                  ),
                                ),
                              )
                            ],
                          )),
                      Container(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(left: 22),
                              child: Center(
                                  child: Text(
                                serviceName,
                                style: TextStyle(
                                  color: HexColor('#0D47A1'),
                                  fontFamily: 'Archivo',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              )),
                            ),
                            Container(
                              width: 165.0,
                              height: 80.0,
                              child: FlatButton(
                                  child: serviceLogo,
                                  onPressed: () {
                                    print('g');
                                  }),
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: HexColor('#DFE3E8'),
                      ),
                      Container(
                          padding: EdgeInsets.fromLTRB(22, 0, 26, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                alias,
                                style: TextStyle(fontFamily: 'Archivo', fontSize: 11, color: HexColor('#9B9B9B'), fontWeight: FontWeight.bold),
                              ),
                              FlatButton(
                                padding: EdgeInsets.all(0),
                                onPressed: () {
                                  editService(savedReference, serviceLogo, serviceName, serviceID, userEmail, reminderFrequency, alias, dbID);
                                },
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      'Editar',
                                      style: TextStyle(
                                        color: HexColor('#0D47A1'),
                                        fontFamily: 'Archivo',
                                        fontSize: 13,
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 6),
                                      child: Transform.rotate(
                                        angle: 180 * pi / 180,
                                        child: Icon(
                                          Icons.error_outline,
                                          color: DataUI.chedrauiColor,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          )),
                    ],
                  ),
                ),
                secondaryActions: <Widget>[
                  IconSlideAction(
                    caption: '',
                    color: Colors.red,
                    icon: Icons.delete_outline,
                    onTap: () async {},
                  ),
                ],
              ),
            ),
          )
        : Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 0,
            //color: status != null && status != '' && status == 'Inactivo' ? HexColor('#212B36').withOpacity(0.1) : Colors.white,
            color: Colors.white,
            margin: EdgeInsets.symmetric(horizontal: 7.5),
            child: Container(
              child: Stack(
                children: <Widget>[
                  Container(
                    child: Container(
                      width: 165.0,
                      height: 110.0,
                      child: FlatButton(
                        child: serviceLogo,
                        // onPressed: status != null && status != '' && status == 'Inactivo'
                        //     ? null
                        //     : () {
                        //         Navigator.push(
                        //           context,
                        //           MaterialPageRoute(
                        //             settings: RouteSettings(name: DataUI.selectedPagoServiciosRoute),
                        //             builder: (BuildContext context) => SelectedService(
                        //               serviceID: serviceID,
                        //               serviceSku: sku,
                        //               savedReference: savedReference,
                        //               serviceSkuComision: skuComision,
                        //               serviceLogo: serviceLogo,
                        //               serviceName: serviceName,
                        //               saldoMonedero: saldoMonedero,
                        //               userEmail: userEmail,
                        //               telefonia: montosSkus,
                        //               messageToUser: messageToUser,
                        //               toolTip: toolTip,
                        //               toolTipDescription: toolTipDescription,
                        //               tipoPago: tipoPago,
                        //               status: status,
                        //             ),
                        //           ),
                        //         );
                        //       },
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              settings: RouteSettings(name: DataUI.selectedPagoServiciosRoute),
                              builder: (BuildContext context) => SelectedService(
                                serviceID: serviceID,
                                serviceSku: sku,
                                savedReference: savedReference,
                                serviceSkuComision: skuComision,
                                serviceLogo: serviceLogo,
                                serviceName: serviceName,
                                saldoMonedero: saldoMonedero,
                                userEmail: userEmail,
                                telefonia: montosSkus,
                                messageToUser: messageToUser,
                                toolTip: toolTip,
                                toolTipDescription: toolTipDescription,
                                tipoPago: tipoPago,
                                status: status,
                                montoMaximo: montoMaximo,
                                montoMinimo: montoMinimo,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // status != null && status != ''
                  //     ? Positioned(
                  //         top: 10,
                  //         child: Container(
                  //           height: 15,
                  //           decoration: new BoxDecoration(
                  //               color: status == 'Activo' ? HexColor('#39B54A') : status == 'Inactivo' ? HexColor('#212B36').withOpacity(0.5) : DataUI.chedrauiBlueColor,
                  //               borderRadius: new BorderRadius.only(
                  //                 topRight: const Radius.circular(5.0),
                  //                 bottomRight: const Radius.circular(5.0),
                  //               )),
                  //           width: 45,
                  //           child: Center(
                  //             child: Text(
                  //               status,
                  //               style: TextStyle(fontFamily: 'Archivo', fontSize: 12, color: Colors.white),
                  //             ),
                  //           ),
                  //         ),
                  //       )
                  //     : SizedBox(),
                  alias != null && alias != ''
                      ? Container(
                          margin: EdgeInsets.only(bottom: 10),
                          width: 165.0,
                          height: 110.0,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              alias,
                              style: TextStyle(fontFamily: 'Archivo', fontSize: 11, color: HexColor('#9B9B9B'), fontWeight: FontWeight.bold),
                            ),
                          ))
                      : SizedBox()
                ],
              ),
            ),
          );
  }
}

class ServiceCardAvailable extends StatelessWidget {
  Widget serviceLogo;
  Color cardBackground;
  String serviceName;
  String serviceDescription;
  String sku;
  String skuComision;
  String savedReference;
  String serviceID;
  List<dynamic> categories;
  double saldoMonedero;
  String userEmail;
  dynamic montosSkus;
  String messageToUser;
  Widget toolTip;
  String toolTipDescription;
  String tipoPago;
  String status;
  String alias;
  String reminderFrequency;
  String montoMinimo;
  String montoMaximo;
  ServiceCardAvailable({
    this.cardBackground,
    this.serviceID,
    this.serviceDescription,
    this.serviceLogo,
    this.serviceName,
    this.sku,
    this.savedReference,
    this.skuComision,
    this.categories,
    this.saldoMonedero,
    this.userEmail,
    this.montosSkus,
    this.messageToUser,
    this.toolTip,
    this.toolTipDescription,
    this.tipoPago,
    this.status,
    this.alias,
    this.reminderFrequency,
    this.montoMinimo,
    this.montoMaximo,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: status != null && status != '' && status == 'Inactivo'
      //     ? null
      //     : () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             settings: RouteSettings(name: DataUI.selectedPagoServiciosRoute),
      //             builder: (BuildContext context) => SelectedService(
      //               serviceID: serviceID,
      //               serviceSku: sku,
      //               savedReference: savedReference,
      //               serviceSkuComision: skuComision,
      //               serviceLogo: serviceLogo,
      //               serviceName: serviceName,
      //               saldoMonedero: saldoMonedero,
      //               userEmail: userEmail,
      //               telefonia: montosSkus,
      //               messageToUser: messageToUser,
      //               toolTip: toolTip,
      //               toolTipDescription: toolTipDescription,
      //               tipoPago: tipoPago,
      //               status: status,
      //             ),
      //           ),
      //         );
      //       },
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: RouteSettings(name: DataUI.selectedPagoServiciosRoute),
            builder: (BuildContext context) => SelectedService(
              serviceID: serviceID,
              serviceSku: sku,
              savedReference: savedReference,
              serviceSkuComision: skuComision,
              serviceLogo: serviceLogo,
              serviceName: serviceName,
              saldoMonedero: saldoMonedero,
              userEmail: userEmail,
              telefonia: montosSkus,
              messageToUser: messageToUser,
              toolTip: toolTip,
              toolTipDescription: toolTipDescription,
              tipoPago: tipoPago,
              status: status,
              montoMaximo: montoMaximo,
              montoMinimo: montoMinimo,
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 0,
        color: Colors.white,
        //color: status != null && status != '' && status == 'Inactivo' ? HexColor('#212B36').withOpacity(0.1) : Colors.white,
        margin: EdgeInsets.symmetric(horizontal: 7.5, vertical: 7.5),
        child: Container(
            width: 165.0,
            height: 110.0,
            child: Stack(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 22),
                      child: Center(
                          child: Text(
                        serviceName,
                        style: TextStyle(
                          color: HexColor('#0D47A1'),
                          fontFamily: 'Archivo',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )),
                    ),
                    Container(
                      width: 165.0,
                      height: 110.0,
                      child: FlatButton(
                          child: serviceLogo,
                          onPressed: () {
                            print('g');
                          }),
                    )
                  ],
                ),
                // status != null && status != ''
                //     ? Positioned(
                //         top: 10,
                //         child: Container(
                //           height: 15,
                //           decoration: new BoxDecoration(
                //               color: status == 'Activo' ? HexColor('#39B54A') : status == 'Inactivo' ? HexColor('#212B36').withOpacity(0.5) : DataUI.chedrauiBlueColor,
                //               borderRadius: new BorderRadius.only(
                //                 topRight: const Radius.circular(5.0),
                //                 bottomRight: const Radius.circular(5.0),
                //               )),
                //           width: 45,
                //           child: Center(
                //             child: Text(
                //               status,
                //               style: TextStyle(fontFamily: 'Archivo', fontSize: 12, color: Colors.white),
                //             ),
                //           ),
                //         ),
                //       )
                //     : SizedBox()
              ],
            )),
      ),
    );
  }
}
