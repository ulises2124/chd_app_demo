import 'package:barcode_scan/barcode_scan.dart';
import 'package:chd_app_demo/services/CuponesServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

class AddCouponPage extends StatefulWidget {
  AddCouponPage({Key key}) : super(key: key);

  _AddCouponPageState createState() => _AddCouponPageState();
}

class _AddCouponPageState extends State<AddCouponPage> {
  final couponFormKey = GlobalKey<FormState>();
  final codigoController = TextEditingController();
  bool _isLoading = false;
  bool _autovalidateFields = false;
  String _codigoCupon = '';
  String _tokenCupon = '';
  String barcodeProduct;

  @override
  Widget build(BuildContext context) {
    return WidgetContainer(
      Scaffold(
        resizeToAvoidBottomPadding: true,
        backgroundColor: DataUI.backgroundColor,
        appBar: GradientAppBar(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              HexColor('#F56D00'),
              HexColor('#F56D00'),
              HexColor('#F78E00'),
            ],
          ),
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Agregar Cupón',
            style: TextStyle(color: Colors.white, fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 19),
          ),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context, 'reload'),
              );
            },
          ),
        ),
        body: Column(
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: Theme(
                data: ThemeData(
                  primaryColor: DataUI.textOpaqueMedium,
                  hintColor: DataUI.opaqueBorder,
                ),
                child: Container(
                  margin: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: Offset(2.0, 3.0),
                        blurRadius: 3.0,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(15),
                  child: SingleChildScrollView(
                    child: AnimatedCrossFade(
                      sizeCurve: Curves.easeInOut,
                      duration: const Duration(milliseconds: 100),
                      crossFadeState: _isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                      firstChild: Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      secondChild: Form(
                        key: couponFormKey,
                        autovalidate: _autovalidateFields,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Text(
                                'Ingresa o escanea el código del cupón que deseas agregar a tu cuenta.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 10, top: 10),
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Flexible(
                                    child: TextFormField(
                                      textInputAction: TextInputAction.done,
                                      controller: codigoController,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Código de cupón',
                                        hintStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                      inputFormatters: <TextInputFormatter>[
                                        LengthLimitingTextInputFormatter(14),
                                        WhitelistingTextInputFormatter.digitsOnly,
                                      ],
                                      validator: _validateCouponCode,
                                      onEditingComplete: () {
                                        FocusScope.of(context).requestFocus(new FocusNode());
                                        _submitCouponForm();
                                      },
                                      onSaved: (input) {
                                        _codigoCupon = input;
                                        print(input);
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.camera_alt),
                                    onPressed: () {
                                      scan(context);
                                    },
                                  )
                                ],
                              ),
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: const EdgeInsets.only(top: 16, bottom: 16, left: 6, right: 6),
                                hintText: 'Código Token',
                                hintStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                              textInputAction: TextInputAction.done,
                              inputFormatters: <TextInputFormatter>[
                                LengthLimitingTextInputFormatter(6),
                                WhitelistingTextInputFormatter(
                                  RegExp("[a-zA-Z]|[0-9]"),
                                ),
                              ],
                              validator: _validateToken,
                              onSaved: (input) {
                                _tokenCupon = input.toUpperCase();
                                print(input);
                              },
                              onEditingComplete: () {
                                FocusScope.of(context).requestFocus(new FocusNode());
                                _submitCouponForm();
                              },
                              // onFieldSubmitted: (v) {
                              //   FocusScope.of(context).requestFocus(_focusPaterno);
                              // },
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: RaisedButton(
                                      padding: EdgeInsets.all(16),
                                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                                      color: DataUI.btnbuy,
                                      child: Text(
                                        'Guardar Cupón',
                                        style: TextStyle(
                                          fontFamily: 'Archivo',
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      onPressed: _submitCouponForm,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 30),
              child: Image.asset('assets/cuponesadd.png'),
            )
          ],
        ),
      ),
    );
  }

  String _validateCouponCode(String value) {
    if (value.length == 0) {
      return 'Código inválido';
    }
    return null;
  }

  void _submitCouponForm() async {
    setState(() {
      _autovalidateFields = true;
    });
    if (couponFormKey.currentState.validate()) {
      couponFormKey.currentState.save();
      setState(() {
        _isLoading = true;
      });
      try {
        final response = await CuponesServices.asociarCupon(_codigoCupon, _tokenCupon);
        if (response['data']['HasError']) {
          _showConfirmationDialog(false, response['data']['Message']);
        } else {
          _showConfirmationDialog(true, 'El cupón se asoció correctamente');
        }
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showConfirmationDialog(bool successStatus, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: successStatus ? Text("Listo!") : Text("Validar datos"),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: DataUI.textOpaque,
            ),
          ),
          actions: <Widget>[
            successStatus
                ? Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: RaisedButton(
                      color: DataUI.chedrauiBlueColor,
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
                        Navigator.pushNamed(context, DataUI.cuponesRoute);
                        // Navigator.of(context).pop();
                        // Navigator.pop(context);
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CuponesPage()));
                        // Navigator.of(context).pushAndRemoveUntil(
                        //   MaterialPageRoute(
                        //     builder: (BuildContext context) => MasterPage(
                        //       initialWidget: MenuItem(
                        //         id: 'misCupones',
                        //         title: 'Mis Cupones',
                        //         screen: CuponesPage(),
                        //         color: DataUI.chedrauiColor2,
                        //         textColor: DataUI.primaryText,
                        //       ),
                        //     ),
                        //   ),
                        //   (Route<dynamic> route) => false,
                        // );
                      },
                      child: Text(
                        "Continuar",
                        style: TextStyle(
                          color: DataUI.whiteText,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Continuar",
                        style: TextStyle(
                          color: DataUI.chedrauiBlueColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }

  String _validateToken(String value) {
    if (value.length == 0) {
      return null;
    } else {
      if (value.length < 6) {
        return 'Token inválido';
      } else {
        return null;
      }
    }
  }

  Future<void> scan(BuildContext context) async {
    try {
      print("Entro scan");
      String barcode = await BarcodeScanner.scan();

      setState(() => this.barcodeProduct = barcode);
      print("salgo scan");
      print("barcode1: $barcode");

      if (barcode.length >= 12) {
        barcode = barcode.substring(0, 12);
      }

      print("barcode2: $barcode");

      setState(() {
        _isLoading = true;
      });
      try {
        final response = await CuponesServices.asociarCupon(barcode, _tokenCupon);
        if (response['data']['HasError']) {
          _showConfirmationDialog(false, response['data']['Message']);
        } else {
          _showConfirmationDialog(true, 'El cupón se asoció correctamente');
        }
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcodeProduct = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcodeProduct = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.barcodeProduct = 'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcodeProduct = 'Unknown error: $e');
    }
  }
}
