import 'package:chd_app_demo/services/BuzonServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/Errors/NetworkErrorPage/NetworkErrorPage.dart';
import 'package:chd_app_demo/views/Servicios/Util.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/widgets/buzonMessage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuzonPage extends StatefulWidget {
  BuzonPage({Key key}) : super(key: key);

  _BuzonPageState createState() => _BuzonPageState();
}

class _BuzonPageState extends State<BuzonPage> {
  List data;
  String _idWallet;
  SharedPreferences prefs;

  bool _isLoggedIn = false;

  Future buzonResponse;
  // Future getBuzon() async {
  //   if (idWallet != null) {}
  // }

  reload() {
    setState(() {
      _idWallet = null;
    });
    // getBuzon();
  }

  getPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
    if (_isLoggedIn) {
      var mensajes = await BuzonServices.getBuzonKentico();
      if (mounted) {
        if (mensajes != null) {
          setState(() {
            data = mensajes['items'];
            data = data.reversed.toList();
          });
        }
      }
    }
    return data;
  }

  initState() {
    buzonResponse = getPreferences();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder(
        future: buzonResponse,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
              break;
            case ConnectionState.active:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
              break;
            case ConnectionState.none:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
              break;
            case ConnectionState.done:
              if (snapshot.hasError) {
                if (snapshot.error.toString().contains('Socket')) {
                  return NetworkErrorPage(
                    showGoHomeButton: true,
                  );
                }
                return SizedBox(height: 0);
              } else if (snapshot.hasData && snapshot.data != null) {
                return _isLoggedIn
                    ? Container(
                        margin: EdgeInsets.only(left: 15, right: 7.5),
                        width: 50.0,
                        height: 100.0,
                        child: Container(
                          margin: data != null ? data.length < 0 ? EdgeInsets.only(top: 30) : EdgeInsets.only(top: 0) : EdgeInsets.only(top: 0),
                          child: data.length > 0
                              ? ListView.separated(
                                  separatorBuilder: (context, index) {
                                    return Container(
                                      margin: EdgeInsets.symmetric(vertical: 18),
                                      color: HexColor('#D8D8D8'),
                                      height: 1,
                                      width: double.infinity,
                                    );
                                  },
                                  physics: ClampingScrollPhysics(),
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: data == null ? 0 : data.length,
                                  itemBuilder: (context, index) {
                                    return BuzonMessage(
                                      notificacionId: data[index]['system']['id'],
                                      mensajeId: data[index]['system']['id'],
                                      // accion: data[index]['accion'] != null ? data[index]['accion'] : "",
                                      tipoNotificacion: data[index]['elements']['tipo_notificacion']['value'][0]['name'],
                                      date: data[index]['elements']['fecha_de_publicacion']['value'],
                                      encabezado: data[index]['system']['name'],
                                      descripcion: parseHtmlString(data[index]['elements']['descripcion']['value']),
                                      imagen: data[index]['elements']['descripcion']['value'][0] ?? '',
                                      // leido: data[index]['leido'] != null ? data[index]['leido'] : false,
                                      callback: reload,
                                    );
                                  },
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      child: Image.asset('assets/notifiacionesClean.png'),
                                    ),
                                    Text("No tienes ninguna notificación"),
                                  ],
                                ),
                        ),
                      )
                    : ListView(
                        children: <Widget>[
                          Card(
                            margin: EdgeInsets.only(top: 20, left: 8, right: 8),
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  'Bienvenido',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w500,
                                    color: DataUI.textOpaqueStrong,
                                  ),
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                                child: Text(
                                  'Aquí recibirás notificaciones y ofertas exclusivas al ingresar a tu cuenta Chedraui',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: DataUI.textOpaqueMedium,
                                  ),
                                ),
                              ),
                              onTap: () {},
                            ),
                          ),
                        ],
                      );
              } else {
                return NetworkErrorPage(
                  errorMessage: 'Ha ocurrido un error, por favor inténtalo más tarde',
                  showGoHomeButton: true,
                );
              }
              break;
            default:
              return Container();
          }
        },
      ),
    );
  }
}
