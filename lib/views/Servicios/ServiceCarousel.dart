import 'package:carousel_slider/carousel_slider.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/Servicios/ServiceCards.dart';
import 'package:flutter/material.dart';

class ServiceCarousel extends StatelessWidget {
  final String title;
  final List<ServiceCard> services;
  final Function seeMore;
  final double heightCarousel;
  ServiceCarousel({
    this.title,
    this.services,
    this.seeMore,
    this.heightCarousel = 165,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 45,
            height: 5,
            margin: EdgeInsets.only(left: 20.0, top: 20.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 5.0, color: HexColor('#FBC02D')),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 20.0, top: 8.0, bottom: 10.0),
                child: Text(
                  "$title",
                  style: TextStyle(color: DataUI.chedrauiBlueColor, fontSize: 20.0, fontWeight: FontWeight.w600),
                ),
              ),
              seeMore != null && services.length > 0
                  ? Container(
                      margin: EdgeInsets.only(left: 20.0, top: 8.0, bottom: 10.0, right: 20.0),
                      child: InkWell(
                        onTap: seeMore,
                        child: Text(
                          "Ver todos",
                          style: TextStyle(color: DataUI.chedrauiBlueColor, fontSize: 15.0, fontWeight: FontWeight.w400),
                        ),
                      ))
                  : Container()
            ],
          ),
          Container(
            //margin: EdgeInsets.symmetric(horizontal: 15),
            height: 110,
            child: title == 'Tus servicios'
                ? services.length > 0
                    ? ListView.builder(
                        // shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          return ServiceCard(
                            extendedCard: services[index].extendedCard,
                            savedReference: services[index].savedReference,
                            serviceID: services[index].serviceID,
                            cardBackground: services[index].cardBackground,
                            categories: services[index].categories,
                            saldoMonedero: services[index].saldoMonedero,
                            serviceDescription: services[index].serviceDescription,
                            serviceLogo: services[index].serviceLogo,
                            serviceName: services[index].serviceName,
                            sku: services[index].sku,
                            skuComision: services[index].skuComision,
                            userEmail: services[index].userEmail,
                            montosSkus: services[index].montosSkus,
                            messageToUser: services[index].messageToUser,
                            toolTip: services[index].toolTip,
                            toolTipDescription: services[index].toolTipDescription,
                            tipoPago: services[index].tipoPago,
                            status: services[index].status,
                            alias: services[index].alias,
                            reminderFrequency: services[index].reminderFrequency,
                          );
                        },
                      )
                    : Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        //margin: EdgeInsets.symmetric(horizontal: 10, vertical: 35),
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 35,
                          ),
                          child: Center(
                            child: Text(
                              'Después de pagar un servicio, tendrá la opción de agregar ese servicio a la sección "Mi servicio".',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Archivo',
                                fontSize: 14,
                                letterSpacing: 0.25,
                                color: HexColor('#454F5B'),
                              ),
                            ),
                          ),
                        ))
                : ListView.builder(
                    // shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      return ServiceCard(
                        savedReference: services[index].savedReference,
                        serviceID: services[index].serviceID,
                        cardBackground: services[index].cardBackground,
                        categories: services[index].categories,
                        saldoMonedero: services[index].saldoMonedero,
                        serviceDescription: services[index].serviceDescription,
                        serviceLogo: services[index].serviceLogo,
                        serviceName: services[index].serviceName,
                        sku: services[index].sku,
                        skuComision: services[index].skuComision,
                        userEmail: services[index].userEmail,
                        montosSkus: services[index].montosSkus,
                        messageToUser: services[index].messageToUser,
                        toolTip: services[index].toolTip,
                        toolTipDescription: services[index].toolTipDescription,
                        tipoPago: services[index].tipoPago,
                        status: services[index].status,
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
