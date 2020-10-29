import 'package:chd_app_demo/services/AuthServices.dart';
import 'package:chd_app_demo/services/CuponesServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/CuponesPage/AddCouponPage.dart';
import 'package:chd_app_demo/views/DeliveryMethod/SelectedLocation.dart';
import 'package:chd_app_demo/views/Errors/GenericErrorPage/GenericErrorPage.dart';
import 'package:chd_app_demo/views/Errors/NetworkErrorPage/NetworkErrorPage.dart';
import 'package:chd_app_demo/views/HomePage/DeliveryMethodSelectionBar.dart';
import 'package:chd_app_demo/views/HomePage/SearchProductsBar.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';
import 'package:chd_app_demo/widgets/dashedLine.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'dart:async';
import 'dart:convert';
import 'package:barcode_flutter/barcode_flutter.dart';
import 'package:expandable/expandable.dart';

class CuponesPage extends StatefulWidget {
  final String accion;

  CuponesPage({
    Key key,
    this.accion,
  }) : super(key: key);

  _CuponesPageState createState() => _CuponesPageState();
}

class _CuponesPageState extends State<CuponesPage> {
  // SharedPreferences prefs;
  Future<dynamic> cupones;
  List cuponesData = [];
  bool loading = true;
  // var cuponesData;

  @override
  void initState() {
    getCupones();
    super.initState();
  }

  getCupones() async {
    cupones = CuponesServices.getCupones().then((response) {
      if (response['response'].toString().length > 0) {
        // try {
        setState(() {
          cuponesData = response['response'];
          loading = false;
          print(cuponesData);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final key = new GlobalKey<ScaffoldState>();
    return WidgetContainer(
      Scaffold(
        key: key,
        resizeToAvoidBottomPadding: true,
        backgroundColor: DataUI.backgroundColor,
        appBar: widget.accion == null
            ? GradientAppBar(
                iconTheme: IconThemeData(
                  color: DataUI.primaryText, //change your color here
                ),
                title: Text(
                  'Mis Cupones',
                  style: TextStyle(color: Colors.white, fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 19),
                ),
                centerTitle: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    HexColor('#F56D00'),
                    HexColor('#F56D00'),
                    HexColor('#F78E00'),
                  ],
                ),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, DataUI.addCouponsRoute);
                    },
                  ),
                ],
              )
            : GradientAppBar(
                iconTheme: IconThemeData(
                  color: DataUI.primaryText, //change your color here
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
                centerTitle: true,
                title: Text(
                  'Seleccionar Cupón',
                  style: TextStyle(color: Colors.white, fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 19),
                ),
              ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 12,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: FutureBuilder(
                    future: cupones,
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
                            print(cuponesData.length);
                            return NetworkErrorPage(
                              showGoHomeButton: true,
                            );
                          } else if (cuponesData != null && cuponesData.length > 0) {
                            return Theme(
                              data: ThemeData(
                                primaryColor: DataUI.textOpaqueMedium,
                                hintColor: DataUI.opaqueBorder,
                              ),
                              child: CustomScrollView(
                                slivers: <Widget>[
                                  // SliverAppBar(
                                  //   pinned: true,
                                  //   expandedHeight: 100.0,
                                  //   flexibleSpace:
                                  //   FlexibleSpaceBar(
                                  //     title:  Text('Hola')
                                  //   ),
                                  // ),
                                  SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        // return Text(
                                        //   's',
                                        //   textAlign: TextAlign.left,
                                        //   style: TextStyle(
                                        //     fontSize: 12.0,
                                        //     color: DataUI.textOpaque,
                                        //     fontWeight: FontWeight.w400,
                                        //   ),
                                        // );
                                        List text = cuponesData[index]['texto'];
                                        String desde = cuponesData[index]['fechaDesde'] ?? '';
                                        String hasta = cuponesData[index]['fechaHasta'] ?? '';

                                        List textList = cuponesData[index]['texto'];
                                        String textMerge = '';
                                        for (var word in textList) {
                                          if (word['texto'].toString().length == 0) {
                                            textMerge += '';
                                          } else if (word['texto'].toString().contains('-----')) {
                                            textMerge += '| ';
                                          } else {
                                            textMerge += word['texto'].toString() + ' ';
                                          }
                                        }
                                        // DateTime desde = DateTime.parse(cuponesData['cupon']['fechaDesde']);
                                        // DateTime hasta = DateTime.parse(cuponesData['cupon']['fechaHasta']);
                                        // String fechaDesde = DateFormat("MMMM d").format(desde).toString();
                                        // String fechaHasta = DateFormat("MMMM d").format(hasta).toString();
                                        // String dateRange = 'Válido: Del ' + fechaDesde.toString() + ' al ' + fechaHasta.toString();
                                        String dateRange = 'Válido: Del ' + desde.toString() + ' al ' + hasta.toString();
                                        return Container(
                                          margin: EdgeInsets.only(top: 8, left: 5, right: 5, bottom: 20),
                                          padding: EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 15),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(Radius.circular(8)),
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                color: Color(0xcc000000).withOpacity(0.2),
                                                offset: Offset(0.0, 5.0),
                                                blurRadius: 12.0,
                                              ),
                                            ],
                                          ),
                                          child: GestureDetector(
                                            onTap: widget.accion == 'checkout' //&& cuponesData[index]['ValidoEcommerce'] == true
                                                ? () {
                                                    //if (cuponesData[index]['ValidoEcommerce'] == true) {
                                                    Map cuponInfo = {'codigoCupon': cuponesData[index]['codigoCupon'].toStringAsFixed(0), 'token': cuponesData[index]['Token'] != null ? cuponesData[index]['Token'].toString() : cuponesData[index]['token'].toString()};
                                                    Navigator.pop(context, cuponInfo);
                                                    /*
                                                    } else {
                                                      final snackBar = SnackBar(content: Text('Cupón no aplicable'));
                                                      Scaffold.of(context).showSnackBar(snackBar);
                                                    }
                                                    */
                                                  }
                                                : null,
                                            child: ExpandablePanel(
                                              headerAlignment: ExpandablePanelHeaderAlignment.bottom,
                                              header: Column(
                                                children: <Widget>[
                                                  Container(
                                                    margin: EdgeInsets.only(bottom: 10, top: 4),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        SizedBox(
                                                          width: 18,
                                                          height: 18,
                                                          child: Image.asset('assets/cupon.png'),
                                                        ),
                                                        Text(
                                                          'Emisión: ' + cuponesData[index]['fechaEmision'],
                                                          textAlign: TextAlign.left,
                                                          style: TextStyle(
                                                            fontSize: 12.0,
                                                            color: DataUI.textOpaque,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        flex: 12,
                                                        child: Text(
                                                          textMerge,
                                                          textAlign: TextAlign.left,
                                                          style: TextStyle(
                                                            fontSize: 12.0,
                                                            color: DataUI.textOpaqueMedium,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                              expanded: Column(
                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                children: <Widget>[
                                                  Divider(color: HexColor('#D8D8D8')),
                                                  Container(
                                                    margin: EdgeInsets.only(top: 10, bottom: 5),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: <Widget>[
                                                        Expanded(
                                                          flex: 6,
                                                          child: Text(
                                                            'Código del cupón:',
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(
                                                              fontSize: 12.0,
                                                              color: DataUI.textOpaque,
                                                              fontWeight: FontWeight.w400,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                        cuponesData[index]['codigoCupon'].toStringAsFixed(0) +
                                                            (widget.accion == 'checkout' // && cuponesData[index]['ValidoEcommerce'] == true ? " (Usar)" : ""),
                                                                ? " (Usar)"
                                                                : ""),
                                                        textAlign: TextAlign.left,
                                                        style: TextStyle(
                                                          fontSize: 20.0,
                                                          color: DataUI.chedrauiColor,
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                      ),
                                                      InkWell(
                                                        child: Text(
                                                          'Copiar',
                                                          style: TextStyle(color: HexColor('#0D47A1'), fontSize: 14, fontFamily: 'Archivo'),
                                                        ),
                                                        splashColor: DataUI.chedrauiColor,
                                                        onTap: () {
                                                          Clipboard.setData(ClipboardData(text: cuponesData[index]['codigoCupon'].toStringAsFixed(0)));

                                                          Flushbar(
                                                            message: "Código de cupón copiado",
                                                            backgroundColor: HexColor('#39B54A'),
                                                            flushbarPosition: FlushbarPosition.TOP,
                                                            flushbarStyle: FlushbarStyle.FLOATING,
                                                            margin: EdgeInsets.all(8),
                                                            borderRadius: 8,
                                                            icon: Icon(
                                                              Icons.check_circle_outline,
                                                              size: 28.0,
                                                              color: Colors.white,
                                                            ),
                                                            duration: Duration(seconds: 3),
                                                          )..show(context);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    dateRange,
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      fontSize: 12.0,
                                                      color: DataUI.textOpaque,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  Container(
                                                    child: MySeparator(),
                                                    margin: EdgeInsets.only(top: 20, bottom: 15),
                                                  ),
                                                  Center(
                                                    child: BarCodeImage(
                                                      data: cuponesData[index]['codigoCupon'].toStringAsFixed(0), // Code string. (required)
                                                      codeType: BarCodeType.Code128, // Code type (required)
                                                      lineWidth: 1, // width for a single black/white bar (default: 2.0)
                                                      barHeight: 70.0, // height for the entire widget (default: 100.0)
                                                      // hasText: true, // Render with text label or not (default: false)
                                                      onError: (error) {
                                                        // Error handler
                                                        print('error = $error');
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              tapHeaderToExpand: false,
                                              hasIcon: true,
                                              iconPlacement: ExpandablePanelIconPlacement.right,
                                            ),
                                          ),
                                        );
                                      },
                                      childCount: cuponesData.length ?? 0,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Theme(
                              data: ThemeData(
                                primaryColor: DataUI.textOpaqueMedium,
                                hintColor: DataUI.opaqueBorder,
                              ),
                              child: Container(
                                margin: EdgeInsets.only(top: 8, left: 5, right: 5),
                                padding: EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 15),
                                child: Center(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.confirmation_number,
                                          size: 58,
                                          color: DataUI.chedrauiColor,
                                        ),
                                      ),
                                      Text(
                                        'Puedes añadir cupones físicos o electrónicos para poder utilizarlos en tus compras',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: DataUI.textOpaqueMedium,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                          break;
                      }
                    },
                  ),
                ),
              ),
            ),
            widget.accion != 'checkout'
                ? !loading
                    ? Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 20, left: 29, right: 29),
                        child: OutlineButton(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                          borderSide: BorderSide(
                            width: 2,
                            color: HexColor('#0D47A1'),
                          ),
                          color: HexColor('#0D47A1'),
                          onPressed: () {
                            Navigator.pushNamed(context, DataUI.addCouponsRoute);
                          },
                          child: Text(
                            'Agregar Cupón',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Archivo',
                              fontSize: 14,
                              letterSpacing: 0.25,
                              color: HexColor('#0D47A1'),
                            ),
                          ),
                        ),
                      )
                    : SizedBox()
                : SizedBox()
          ],
        ),
      ),
    );
  }
}
