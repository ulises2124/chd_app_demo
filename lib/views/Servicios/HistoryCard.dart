import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryCard extends StatelessWidget {
  final formatter = NumberFormat("###,###,###,##0.00");
  final String logId;
  final String description;
  final Widget logo;
  final String paymentDate;
  final String reference;
  final double totalPaid;
  final Function downloadPDF;
  final dynamic categories;
  HistoryCard({
    Key key,
    this.logId,
    this.description,
    this.logo,
    this.paymentDate,
    this.reference,
    this.totalPaid,
    this.downloadPDF,
    this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15),
      child: Card(
          elevation: 2,
          child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Text(
                          "$description",
                          style: TextStyle(color: DataUI.chedrauiBlueColor, fontSize: 16.0, fontFamily: 'Archivo', fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                        //margin: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween ,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(bottom: 26),
                              child: Text(
                              paymentDate,
                              style: TextStyle(fontFamily: 'Archivo', fontSize: 11, color: HexColor('#637381'), letterSpacing: 0.28),
                            ),
                            ),
                            Text(
                              '-\$${formatter.format(totalPaid)}',
                              style: TextStyle(fontFamily: 'Archivo Black', fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.29),
                            )
                          ],
                        ),
                      ),),
                    ],
                  ),
                ),
                Container(
                  color: HexColor('#DFE3E8'),
                  height: 1,
                  width: double.infinity,
                ),
                InkWell(
                  onTap: () {
                    downloadPDF(logId);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                         Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Text("Descargar PDF",
                              style: TextStyle(
                                fontSize: 13.0,
                                color: DataUI.chedrauiBlueColor,
                              )),
                        ),
                        Icon(Icons.file_download, color: DataUI.chedrauiColor)
                       
                      ],
                    ),
                  ),
                ),
              ],
            ),),
    );
  }
}
