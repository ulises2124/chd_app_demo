import 'package:chd_app_demo/services/BuzonServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
//import 'package:chd_app_demo/views/Servicios/Util.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/widgets/buzonMessage.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuzonMessageDetails extends StatefulWidget {
  final String idWallet;
  final String notificacionId;
  final String mensajeId;
  final String accion;
  final dynamic date;
  final String tipoNotificacion;
  final String encabezado;
  final String descripcion;
  final String imagen;
  final bool leido;
  final Function callback;
  BuzonMessageDetails({Key key, this.date, this.idWallet, this.notificacionId, this.mensajeId, this.accion, this.tipoNotificacion, this.encabezado, this.descripcion, this.imagen, this.leido, this.callback}) : super(key: key);

  _BuzonMessageDetailsState createState() => _BuzonMessageDetailsState();
}

class _BuzonMessageDetailsState extends State<BuzonMessageDetails> {
  IconData icon;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tipodeNotificacion();
  }

  tipodeNotificacion() {
    switch (widget.tipoNotificacion) {
      case "Informativa":
        setState(() {
          icon = Icons.notification_important;
        });
        break;
      case "Promocional":
        setState(() {
          icon = Icons.shopping_cart;
        });
        break;
      case "Actualización de Versión":
        setState(() {
          icon = Icons.system_update;
        });
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return WidgetContainer(
      Scaffold(
        backgroundColor: HexColor('#F4F6F8'),
        appBar: GradientAppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              );
            },
          ),
          gradient: DataUI.appbarGradient,
          title: Text(
            'Notificacion',
            style: DataUI.appbarTitleStyle,
          ),
        ),
        body: Center(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  child: Image.asset('assets/notificaciones.png'),
                ),
                Container(
                  margin: EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: HexColor('#0D47A1')),
                          height: 24,
                          width: 24,
                          child: Icon(
                            icon,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                widget.encabezado,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'Archivo', color: HexColor('#0D47A1')),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 0),
                              child: Text(widget.descripcion, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, fontFamily: 'Rubik', color: HexColor('#454F5B'))),
                            ),
                            // Container(
                            //   margin: EdgeInsets.symmetric(vertical: 5),
                            //   child: Text(DateFormat.yMMMMEEEEd().format(DateTime.parse(widget.date)), style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, fontFamily: 'Archivo', color: HexColor('#454F5B'))),
                            // ),
                            // GestureDetector(
                            //   onTap: () {},
                            //   // margin: EdgeInsets.symmetric(vertical: 0),
                            //   child: Text('Mas detalles de la promocion', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, fontFamily: 'Archivo', color: HexColor('#0D47A1'))),
                            // )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
