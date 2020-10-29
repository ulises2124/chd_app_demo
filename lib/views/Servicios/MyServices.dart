import 'dart:convert';

import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/utils/input_formatters.dart';
import 'package:chd_app_demo/views/Servicios/ServiceCards.dart';
import 'package:chd_app_demo/views/Servicios/Util.dart';
import 'package:chd_app_demo/views/Servicios/ViewUtils.dart';
import 'package:chd_app_demo/widgets/modalbottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

import 'package:http/http.dart' as http;

class MyServices extends StatefulWidget {
  final String servicesUrl = "https://us-central1-chedraui-bill-pay.cloudfunctions.net/services";
  final saldoMonedero;
  final email;
  MyServices({Key key, this.saldoMonedero, this.email}) : super(key: key);

  @override
  MyServicesState createState() => MyServicesState();
}

class MyServicesState extends State<MyServices> {
  List<ServiceCard> services;
  bool isLoading = true;
  bool hasServices = true;
  TextEditingController aliasController;
  String selected;

  String saveServiceName;
  final _formKey = GlobalKey<FormState>();

  bool loading = false;

  @override
  void initState() {
    services = new List<ServiceCard>();
    getMyServices();
    aliasController = new TextEditingController();
    super.initState();
  }

  Future getMyServices() async {
    try {
      setState(() {
        isLoading = true;
      });
      http.Response result = await http.get('${widget.servicesUrl}/user/${widget.email}/services', headers: {"Content-Type": "application/json"});
      print(result.body);
      if (result.statusCode == 200) {
        Map<String, dynamic> map = json.decode(result.body);
        List<dynamic> response = map["services"];
        print(response);
        setState(() {
          services = mapFavoriteServices(response, widget.saldoMonedero, widget.email, saveService, true);
        });
        if (services.length == 0) {
          Navigator.pop(context);
        }
      } else if (result.statusCode == 404) {
        setState(() {
          hasServices = false;
        });
      }
    } catch (error) {
      print(error);
      showErrorMessage(context, "Error en mis servicios", "Ha ocurrido un error al cargar los servicios", false);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // onLongPressService(String userServiceId) async {
  //   displayDeleteAlert(context, () async {
  //     http.Response result = await http.delete('${widget.servicesUrl}/user/${widget.email}/services/$userServiceId', headers: {"Content-Type": "application/json"});
  //     getMyServices();
  //   });
  // }
  Future<Null> updated(StateSetter updateState, value) async {
    updateState(() {
      selected = value;
    });
  }

  Future<Null> updateLoader(StateSetter updateState, value) async {
    updateState(() {
      loading = value;
    });
  }

  void saveService(referencia, logo, serviceName, serviceID, userEmail, reminderFrequency, alias, dbID) {
    setState(() {
      selected = reminderFrequency;
      aliasController.text = alias;
    });

    _showConfirmDialog(context) {
      return showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                    contentPadding: EdgeInsets.all(29),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    content: Container(
                      height: 104,
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(bottom: 20),
                            child: Text(
                              '¿Seguro que quieres eliminar los recordatorios?',
                              style: TextStyle(color: HexColor('#212B36'), fontFamily: 'Archivo', fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          loading
                              ? Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: LinearProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation(HexColor('#FBC02D')),
                                          backgroundColor: HexColor('#CFCED5'),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    FlatButton(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                                      padding: EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                                      color: HexColor('#F57C00'),
                                      disabledColor: HexColor('#F57C00').withOpacity(0),
                                      onPressed: () async {
                                        try {
                                          setState(() {
                                            loading = true;
                                          });
                                          http.Response result = await http.delete('${widget.servicesUrl}/user/$userEmail/services/$dbID');
                                          if (result.statusCode == 202) {
                                            getMyServices();
                                            Navigator.pop(context);
                                          } else {
                                            Navigator.pop(context);
                                            showErrorMessage(context, "Error al eliminar", "Ha ocurrido un error al intentar eliminar el servicio", false);
                                          }
                                        } catch (error) {
                                          Navigator.pop(context);
                                          print(error);
                                          showErrorMessage(context, "Error al eliminar", "Ha ocurrido un error al intentar eliminar el servicio", false);
                                        } finally {
                                          setState(() {
                                            loading = false;
                                          });
                                        }
                                      },
                                      child: Text(
                                        "Confirmar",
                                        style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Archivo', fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    FlatButton(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                                      padding: EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                                      color: HexColor('#F57C00').withOpacity(0),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "Cancelar",
                                        style: TextStyle(
                                          color: loading ? Colors.transparent : DataUI.chedrauiBlueColor,
                                          fontSize: 14,
                                          fontFamily: 'Archivo',
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    )
                                  ],
                                )
                        ],
                      ),
                    ));
              },
            );
          });
    }

    showModalBottomSheetApp(
      dismissOnTap: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, state) {
            return Theme(
              data: ThemeData(canvasColor: Colors.transparent),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  print('object');
                },
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Color(0xcc000000).withOpacity(0.2),
                        offset: Offset(5.0, 0.0),
                        blurRadius: 12.0,
                      ),
                    ],
                    color: HexColor('#F9FAFB'),
                    borderRadius: new BorderRadius.only(topLeft: const Radius.circular(20.0), topRight: const Radius.circular(20.0)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
                    child: Container(
                      height: 584,
                      padding: EdgeInsets.only(
                        top: 15,
                      ),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 25),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Editar mi servicio',
                                  style: TextStyle(fontSize: 20, color: HexColor('#0D47A1'), fontFamily: 'Archivo', letterSpacing: 0.5, fontWeight: FontWeight.bold),
                                ),
                                // IconButton(
                                //   icon: Icon(Icons.close),
                                //   onPressed: () {
                                //     Navigator.pop(context);
                                //   },
                                // )
                              ],
                            ),
                          ),
                          Container(
                            height: 1,
                            color: HexColor('#D8D8D8'),
                            margin: EdgeInsets.only(top: 9),
                          ),
                          Center(
                            child: logo,
                          ),
                          Container(height: 1, color: HexColor('#D8D8D8')),
                          Container(
                            margin: EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Número de referencia',
                                  style: TextStyle(fontFamily: 'Archivo', fontSize: 14, color: HexColor('#212B36')),
                                ),
                                Text(
                                  truncateString(15, referencia),
                                  style: TextStyle(fontFamily: 'Archivo', fontSize: 14, color: HexColor('#212B36')),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 15, right: 15),
                            child: Form(
                              key: _formKey,
                              child: Theme(
                                data: ThemeData(
                                  primaryColor: Colors.transparent,
                                  hintColor: Colors.transparent,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          'Editar alias (opcional) ',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(fontSize: 12, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                                        ),
                                      ),
                                      TextFormField(
                                        controller: aliasController,
                                        style: TextStyle(color: HexColor('#0D47A1'), fontSize: 14, fontFamily: 'Archivo'),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: HexColor('#F0EFF4'),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          contentPadding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 6),
                                          hintStyle: TextStyle(color: HexColor('#0D47A1'), fontSize: 12),
                                        ),
                                        onFieldSubmitted: (v) {
                                          saveServiceName = v;
                                        },
                                        textInputAction: TextInputAction.next,
                                        inputFormatters: [],
                                        maxLength: 25,
                                        onSaved: (input) {
                                          saveServiceName = input;
                                        },
                                        validator: FormsTextValidators.validateTextWithoutEmoji,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(15, 0, 15, 15),
                            child: Text(
                              '¿Deseas que te recordemos tu próximo pago?',
                              textAlign: TextAlign.left,
                              style: TextStyle(fontSize: 12, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                            ),
                          ),
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Stack(
                                    overflow: Overflow.visible,
                                    children: <Widget>[
                                      selected == 'mensual'
                                          ? Positioned(
                                              top: -15,
                                              right: -13,
                                              child: Icon(
                                                Icons.check_circle,
                                                color: HexColor('#39B54A'),
                                              ),
                                            )
                                          : SizedBox(),
                                      OutlineButton(
                                        onPressed: () {
                                          if (selected != 'mensual') {
                                            updated(state, 'mensual');
                                          } else {
                                            updated(state, null);
                                          }
                                        },
                                        padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                        child: Column(
                                          children: <Widget>[Text("Al final de"), Text('cada mes')],
                                        ),
                                        borderSide: BorderSide(color: selected == 'mensual' ? HexColor('#39B54A') : HexColor('#DFE3E8')),
                                        shape: new RoundedRectangleBorder(
                                          borderRadius: new BorderRadius.circular(5.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Stack(
                                    overflow: Overflow.visible,
                                    children: <Widget>[
                                      selected == 'quincenal'
                                          ? Positioned(
                                              top: -15,
                                              right: -13,
                                              child: Icon(
                                                Icons.check_circle,
                                                color: HexColor('#39B54A'),
                                              ),
                                            )
                                          : SizedBox(),
                                      OutlineButton(
                                        onPressed: () {
                                          if (selected != 'quincenal') {
                                            updated(state, 'quincenal');
                                          } else {
                                            updated(state, null);
                                          }
                                        },
                                        padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                        child: Column(
                                          children: <Widget>[Text("El 15 de"), Text('cada mes')],
                                        ),
                                        borderSide: BorderSide(color: selected == 'quincenal' ? HexColor('#39B54A') : HexColor('#DFE3E8')),
                                        shape: new RoundedRectangleBorder(
                                          borderRadius: new BorderRadius.circular(5.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 15, right: 15, top: 5),
                            width: double.infinity,
                            child: Center(
                              child: InkWell(
                                // color: Colors.transparent,
                                // disabledColor: DataUI.chedrauiColorDisabled,
                                // shape: RoundedRectangleBorder(
                                //   borderRadius: BorderRadius.circular(6.0),
                                // ),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 15.0),
                                  child: Text(
                                    'Eliminar recordatorio',
                                    style: TextStyle(color: HexColor('#0D47A1'), fontSize: 14, fontFamily: 'Archivo'),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _showConfirmDialog(context);
                                },
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 15, right: 15, top: 20),
                            width: double.infinity,
                            child: loading
                                ? Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 5),
                                          child: LinearProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation(HexColor('#FBC02D')),
                                            backgroundColor: HexColor('#CFCED5'),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : FlatButton(
                                    color: DataUI.chedrauiColor,
                                    disabledColor: DataUI.chedrauiColorDisabled,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 15.0),
                                      child: Text(
                                        'Guardar',
                                        style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Archivo'),
                                      ),
                                    ),
                                    onPressed: () async {
                                      try {
                                        updateLoader(state, true);
                                        var body = {
                                          "serviceName": serviceName,
                                          "reference": referencia,
                                          "alias": aliasController.text,
                                          "serviceKenticoId": serviceID,
                                          "reminderFrequency": selected,
                                        };
                                        print('${widget.servicesUrl}/user/$userEmail/services');
                                        http.Response result = await http.put('${widget.servicesUrl}/user/$userEmail/services/$dbID', headers: {"Content-Type": "application/json"}, body: utf8.encode(json.encode(body)));
                                        if (result.statusCode == 200) {
                                          result = await showErrorMessage(context, "Servicio editado", "Servicio editado correctamente", true);
                                          if (result == null) {
                                            getMyServices();
                                          }
                                        } else {
                                          showErrorMessage(context, "Error al guardar", "Ha ocurrido un error al intentar guardar el servicio", false);
                                        }
                                      } catch (error) {
                                        print(error);
                                        showErrorMessage(context, "Error al guardar", "Ha ocurrido un error al intentar guardar el servicio", false);
                                      } finally {
                                        updateLoader(state, false);
                                      }
                                    },
                                  ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                            width: double.infinity,
                            child: FlatButton(
                              color: Colors.transparent,
                              disabledColor: DataUI.chedrauiColorDisabled,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 15.0),
                                child: Text(
                                  'Cancelar',
                                  style: TextStyle(color: HexColor('#0D47A1'), fontSize: 14, fontFamily: 'Archivo'),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> displayDeleteAlert(BuildContext context, Function confirmCallback) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Eliminar mi servicio"),
          content: Text("¿Deseas eliminar este servicio?"),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Eliminar'),
              onPressed: () {
                Navigator.of(context).pop();
                confirmCallback();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: true,
        backgroundColor: DataUI.backgroundColor,
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
          elevation: 0,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              HexColor('#F56D00'),
              HexColor('#F56D00'),
              HexColor('#F78E00'),
            ],
          ),
          title: Text(
            'Mis servicios',
            style: DataUI.appbarTitleStyle,
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
              child: Column(
            children: <Widget>[
              SizedBox(height: 0),
              isLoading
                  ? Center(
                      child: Container(
                        margin: const EdgeInsets.all(50.0),
                        child: CircularProgressIndicator(value: null),
                      ),
                    )
                  : hasServices
                      ? Container(
                          margin: const EdgeInsets.all(15.0),
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            children: services,
                          ))
                      : Center(child: Container(margin: const EdgeInsets.all(15.0), child: Text("No tienes guardado algún servicio", style: TextStyle(color: DataUI.chedrauiBlueColor, fontSize: 16.0, fontWeight: FontWeight.w700))))
            ],
          )),
        ));
  }
}
