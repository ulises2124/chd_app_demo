import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/views/Buzon/BuzonMessageDetails.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:chd_app_demo/services/BuzonServices.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class BuzonMessage extends StatefulWidget {
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
  BuzonMessage({Key key, this.date, this.idWallet, this.notificacionId, this.mensajeId, this.accion, this.tipoNotificacion, this.encabezado, this.descripcion, this.imagen, this.leido, this.callback})
      : super(key: key);
      
  _BuzonMessageState createState() => _BuzonMessageState();
}

class _BuzonMessageState extends State<BuzonMessage> {
  IconData icon;
  // String f = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tipodeNotificacion();
    initializeDateFormatting("es", null);
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
    var s = DateFormat.yMMMMEEEEd('es').format(DateTime.parse(widget.date)).toString();
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Archivo', color: HexColor('#212B36')),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 0),
                  child: Text(widget.descripcion, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, fontFamily: 'Rubik', color: HexColor('#454F5B'))),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: Text('${s[0].toUpperCase()}${s.substring(1)}', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, fontFamily: 'Archivo', color: HexColor('#454F5B'))),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BuzonMessageDetails(
                          accion: widget.accion,
                          idWallet: widget.idWallet,
                          notificacionId: widget.notificacionId,
                          mensajeId: widget.mensajeId,
                          date: widget.date,
                          tipoNotificacion: widget.tipoNotificacion,
                          encabezado: widget.encabezado,
                          descripcion: widget.descripcion,
                          imagen: widget.imagen,
                          leido: widget.leido,
                          callback: widget.callback,
                        ),
                      ),
                    );
                  },
                  // margin: EdgeInsets.symmetric(vertical: 0),
                  child: Text('Mas detalles de la promocion', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, fontFamily: 'Archivo', color: HexColor('#0D47A1'))),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Slidable(
//       delegate: SlidableDrawerDelegate(),
//       actionExtentRatio: 0.4,
//       child: Card(
//         child: ListBody(
//           children: <Widget>[
//             ListTile(
//               title: Container(
//                 margin: EdgeInsets.only(bottom: 5, top: 5),
//                 child: Text(
//                   widget.encabezado,
//                   style: TextStyle(
//                     fontWeight: FontWeight.w500,
//                     fontSize: 14,
//                     color: HexColor('#212B36'),
//                   ),
//                 ),
//               ),
//               subtitle: Text(
//                 widget.descripcion,
//                 style: TextStyle(
//                   fontWeight: FontWeight.normal,
//                   fontSize: 14,
//                   color: HexColor('#454F5B'),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       // secondaryActions: <Widget>[
//       //   IconSlideAction(
//       //     caption: 'Archivar',
//       //     color: Colors.red,
//       //     icon: Icons.clear,
//       //     onTap: () async {
//       //       await BuzonServices.markAsRead(widget.idWallet, widget.mensajeId);
//       //       widget.callback();
//       //     },
//       //   )
//       // ]
//     );
