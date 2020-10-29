import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:flutter/material.dart';

class CFEInformation extends StatelessWidget {
  CFEInformation({
    this.balanceController,
    this.serviceStatus,
  });
  final TextEditingController balanceController;
  final String serviceStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(bottom: 20.0, left: 15, right: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color.fromRGBO(13, 19, 15, 0.15),
                offset: Offset(0.0, 2.0),
                blurRadius: 5.0,
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
          child: Container(
            margin: const EdgeInsets.fromLTRB(17.0, 15.0, 17.0, 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    'Monto del servicio',
                    style: TextStyle(
                      color: DataUI.chedrauiBlueColor,
                      fontSize: 16.0,
                      fontFamily: 'Archivo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Theme(
                  data: ThemeData(
                    primaryColor: Colors.transparent,
                    hintColor: Colors.transparent,
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: balanceController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.attach_money),
                      // contentPadding: const EdgeInsets.all(10.0),
                      // border: OutlineInputBorder(),
                      filled: true,
                      fillColor: HexColor('#F0EFF4'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                      hintStyle: TextStyle(color: HexColor('#0D47A1'), fontSize: 12),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 40.0, left: 15, right: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color.fromRGBO(13, 19, 15, 0.15),
                offset: Offset(0.0, 2.0),
                blurRadius: 5.0,
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
          child: Container(
            margin: const EdgeInsets.fromLTRB(17.0, 20.0, 17.0, 15.0),
            child: Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(bottom: 15.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Información del servicio',
                        style: TextStyle(
                          color: DataUI.chedrauiBlueColor,
                          fontSize: 16.0,
                          fontFamily: 'Archivo',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Estado del servicio',
                        style: TextStyle(fontSize: 14.0, fontFamily: 'Archivo'),
                      ),
                      Text(
                        serviceStatus,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'Archivo',
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Balance del servicio',
                        style: TextStyle(
                          fontFamily: 'Archivo',
                          fontSize: 14.0,
                        ),
                      ),
                      Text(
                        '\$ ${balanceController.text}',
                        style: TextStyle(
                          fontFamily: 'Archivo',
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
