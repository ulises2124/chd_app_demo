import 'package:chd_app_demo/services/ListasServices.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/Errors/NetworkErrorPage/NetworkErrorPage.dart';
import 'package:chd_app_demo/views/ListasPage/ListaNew.dart';
import 'package:chd_app_demo/views/ListasPage/ListaSelected.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: <Widget>[
          // HeaderListas(),
          MisListas(),
        ],
      ),
    ));
  }
}

class MisListas extends StatefulWidget {
  MisListas({Key key}) : super(key: key);

  _MisListasState createState() => _MisListasState();
}

class _MisListasState extends State<MisListas> {
  SharedPreferences prefs;
  List misListas;
  Future response;
  getListas() async {
    response = ListasServices.getListas();
    misListas = await response;
    return response;
  }

  void initState() {
    super.initState();
    //getListas();
  }

  goToList(title, data) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: DataUI.listaDetails),
        builder: (context) => ListaSelected(
          title: title,
          listID: data['code'],
        ),
      ),
    );
    if (result != null) {
      if (result == 'reload') {
        print('reloading');
        ListasServices.getListas().then(
          (listas) {
            setState(
              () {
                misListas = listas;
              },
            );
          },
        );
      } else {
        if (result.toString().length > 0) {
          await ListasServices.getListas().then(
            (listas) {
              setState(
                () {
                  misListas = listas;
                },
              );
            },
          );
          Flushbar(
            message: "Se ha eliminado correctamente la lista $result.",
            backgroundColor: HexColor('#FD5339'),
            flushbarPosition: FlushbarPosition.TOP,
            flushbarStyle: FlushbarStyle.FLOATING,
            margin: EdgeInsets.all(8),
            borderRadius: 8,
            icon: Icon(
              Icons.highlight_off,
              size: 28.0,
              color: Colors.white,
            ),
            duration: Duration(seconds: 3),
          )..show(context);
        }
      }
    }
  }

  createList() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: DataUI.listaNew),
        builder: (context) => ListaNew(),
      ),
    );
    if (result == 'reload') {
      print('reloading');
      ListasServices.getListas().then(
        (listas) {
          setState(
            () {
              misListas = listas;
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getListas(),
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
             if (snapshot.error.toString().contains('No Internet connection')) {
                          return NetworkErrorPage(
                            showGoHomeButton: false,
                          );
                        } else {
                          return NetworkErrorPage(
                            errorMessage: 'Ha ocurrido un error, por favor inténtalo más tarde',
                            showGoHomeButton: true,
                          );
                        }
            } else if (snapshot.hasData && snapshot.data != null) {
              return misListas == null
                  ? Container(
                      child: Center(
                        child: Text(
                          'No hay listas en tu cuenta',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 20,
                          margin: EdgeInsets.only(bottom: 15),
                          // child: Text(
                          //   "Mis listas",
                          //   style: TextStyle(
                          //     color: HexColor("#919EAB"),
                          //     fontFamily: "Rubik",
                          //     fontSize: 12,
                          //   ),
                          // ),
                        ),
                        ListView.builder(
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          primary: true,
                          // shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: misListas == null ? 0 : misListas.length,
                          itemBuilder: (context, index) {
                            if (misListas[index]['isOwner'] == true) {
                              return misListas[index]['entries'].toString().length > 3
                                  ? GestureDetector(
                                      onTap: () {
                                        goToList(misListas[index]['name'], misListas[index]);
                                      },
                                      child: Container(
                                          padding: EdgeInsets.all(15),
                                          margin: EdgeInsets.only(bottom: 15),
                                          width: double.infinity,
                                          // height: 48,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(3),
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.1),
                                                offset: Offset(2.0, 1.0),
                                                blurRadius: 8.0,
                                              ),
                                            ],
                                            color: HexColor("#F9FAFB"),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                misListas[index]['name'],
                                                style: TextStyle(
                                                  fontFamily: "Rubik",
                                                  fontSize: 14,
                                                  color: HexColor("#454F5B"),
                                                ),
                                              ),
                                              Icon(Icons.keyboard_arrow_right)
                                            ],
                                          )),
                                    )
                                  : SizedBox(
                                      height: 0,
                                    );
                            } else {
                              return SizedBox(
                                height: 0,
                              );
                            }
                          },
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 15, top: 15),
                          child: Text(
                            "Listas compartidas conmigo",
                            style: TextStyle(
                              color: HexColor("#919EAB"),
                              fontFamily: "Rubik",
                              fontSize: 12,
                            ),
                          ),
                        ),
                        ListView.builder(
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          primary: true,
                          // shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: misListas == null ? 0 : misListas.length,
                          itemBuilder: (context, index) {
                            if (misListas[index]['isOwner'] == false) {
                              return misListas[index]['entries'].toString().length > 3
                                  ? GestureDetector(
                                      onTap: () {
                                        goToList(misListas[index]['name'], misListas[index]);
                                      },
                                      child: Container(
                                          padding: EdgeInsets.all(15),
                                          margin: EdgeInsets.only(bottom: 15),
                                          width: double.infinity,
                                          // height: 48,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(3),
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.1),
                                                offset: Offset(2.0, 1.0),
                                                blurRadius: 8.0,
                                              ),
                                            ],
                                            color: HexColor("#F9FAFB"),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                misListas[index]['name'],
                                                style: TextStyle(
                                                  fontFamily: "Rubik",
                                                  fontSize: 14,
                                                  color: HexColor("#454F5B"),
                                                ),
                                              ),
                                              Icon(Icons.keyboard_arrow_right)
                                            ],
                                          )),
                                    )
                                  : SizedBox(
                                      height: 0,
                                    );
                            } else {
                              return SizedBox(
                                height: 0,
                              );
                            }
                          },
                        ),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(vertical: 20),
                          child: RaisedButton(
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                            color: HexColor("#F57C00"),
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            onPressed: () {
                              createList();
                            },
                            child: Text(
                              'Crear nueva lista',
                              style: TextStyle(
                                color: HexColor("#F9FAFB"),
                                fontFamily: "Achivo",
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
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
    );
  }
}
