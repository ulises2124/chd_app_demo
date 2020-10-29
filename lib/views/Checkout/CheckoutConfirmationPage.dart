import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/classBanner.dart';
import 'package:chd_app_demo/utils/sliderData.dart';
import 'package:chd_app_demo/views/LoginPage/LoginPage.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:chd_app_demo/views/HomePage/DepartmentsCard.dart';
import 'package:chd_app_demo/widgets/bannerCard.dart';
import 'package:chd_app_demo/widgets/bannerChedraui.dart';
import 'package:chd_app_demo/widgets/footerNavigation.dart';
import 'package:chd_app_demo/widgets/productsSlider.dart';
import 'package:chd_app_demo/views/Checkout/PaymentMethod.dart';
import 'package:chd_app_demo/widgets/deliveryInformation.dart';
import 'package:chd_app_demo/services/AuthServices.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/utils/singinUserData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:chd_app_demo/widgets/expansionTileCustom.dart' as custom;
import 'package:chd_app_demo/widgets/WidgetContainer.dart';

class CheckoutConfirmationPage extends StatefulWidget {
  final PaymentMethod paymentMethod;
  final orderData;
  final shippingData;
  final shippingDatetime;
  final monederoData;
  final additionalData;

  CheckoutConfirmationPage({Key key, this.paymentMethod, this.orderData, this.shippingData, this.shippingDatetime, this.monederoData, this.additionalData}) : super(key: key);

  _CheckoutConfirmationPageState createState() => _CheckoutConfirmationPageState();
}

class _CheckoutConfirmationPageState extends State<CheckoutConfirmationPage> {
  SharedPreferences prefs;
  bool isLoggedIn = true;
  bool isLoading = false;
  String password;
  final _formKey = GlobalKey<FormState>();
  String stringTotal = '';
  _selectSvgCard(brand) {
    switch (brand) {
      case "visa":
        return VisaSVG();
        break;
      case "master_card":
        return MasterCardSVG();
        break;
      default:
        return AmexSVG();
    }
  }

  _showConfirmationDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Salir"),
            content: Text("¿Deseas volver al inicio?"),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancelar",
                  style: TextStyle(
                    color: DataUI.chedrauiBlueColor,
                    fontSize: 16,
                  ),
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
                  // Navigator.pushNamed(context, '/');
                },
                child: Text(
                  "Volver a la tienda",
                  style: TextStyle(
                    color: DataUI.chedrauiBlueColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        });
  }

  getFormaPago(PaymentMethod paymentMethod) {
    switch (widget.paymentMethod) {
      case PaymentMethod.associatedStore:
        setState(() {
          stringTotal = 'Total a pagar';
        });
        return "Establecimiento asociado";
        break;
      case PaymentMethod.onDelivery:
        setState(() {
          stringTotal = 'Total a pagar';
        });
        return "Contra entrega";
        break;
      case PaymentMethod.onStore:
        setState(() {
          stringTotal = 'Total a pagar';
        });
        return "En otra tienda";
        break;
      case PaymentMethod.card:
        setState(() {
          stringTotal = 'Total pagado';
        });
        return "Tarjeta";
        break;
      case PaymentMethod.registredCard:
        setState(() {
          stringTotal = 'Total pagado';
        });
        return "Tarjeta";
        break;
      case PaymentMethod.paypal:
        setState(() {
          stringTotal = 'Total pagado';
        });
        return "Paypal";
        break;
      case PaymentMethod.monedero:
        setState(() {
          stringTotal = 'Total pagado';
        });
        return "Mi Monedero Chedraui";
        break;
      default:
        setState(() {
          stringTotal = 'Total a pagar';
        });
        return "N/D";
    }
  }

  String getFechaHoraFormateada(List fechaHoraEntrega) {
    int offset = 5;
    String finalString = "";
    if (fechaHoraEntrega.length > 0) {
      for (var i = 0; i < fechaHoraEntrega.length; i++) {
        DateTime timeFrom = DateTime.parse(fechaHoraEntrega[i]['timeFrom']);
        DateTime timeTo = DateTime.parse(fechaHoraEntrega[i]['timeTo']);
        DateTime selectedDate = DateTime.parse(fechaHoraEntrega[i]['selectedDate']);
        String _year = selectedDate.year.toString();
        String _month = "";
        switch (selectedDate.month) {
          case 1:
            _month = "Enero";
            break;
          case 2:
            _month = "Febrero";
            break;
          case 3:
            _month = "Marzo";
            break;
          case 4:
            _month = "Abril";
            break;
          case 5:
            _month = "Mayo";
            break;
          case 6:
            _month = "Junio";
            break;
          case 7:
            _month = "Julio";
            break;
          case 8:
            _month = "Agosto";
            break;
          case 9:
            _month = "Septiembre";
            break;
          case 10:
            _month = "Octubre";
            break;
          case 11:
            _month = "Noviembre";
            break;
          case 12:
            _month = "Diciembre";
            break;
        }
        String _day = selectedDate.day.toString();
        int _hourInt = timeFrom.subtract(Duration(hours: 5)).hour;
        int _hourInt2 = timeTo.subtract(Duration(hours: 5)).hour;
        String _hour = "";
        String _hour2 = "";
        String _hourAP = "";
        String _hour2AP = "";
        if (_hourInt < 10) {
          _hour = "0" + _hourInt.toString() + ":00";
        } else {
          _hour = _hourInt.toString() + ":00";
        }
        if (_hourInt2 < 10) {
          _hour2 = "0" + _hourInt2.toString() + ":00";
        } else {
          _hour2 = _hourInt2.toString() + ":00";
        }
        finalString += "$_day de $_month de $_year, entre $_hour y $_hour2";
        if (i != fechaHoraEntrega.length - 1) {
          finalString += ", ";
        }
      }
      return finalString;
    } else {
      return "Entre 5 y 7 días hábiles.";
    }
  }

  NumberFormat moneda = new NumberFormat.currency(locale: 'es_MX', symbol: "\$");

  String _validatePassword(String value) {
    Pattern pattern = r'^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z]).{6,15}$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Contraseña no válida';
    else
      return null;
  }

  _showResponseDialog(msg) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(msg),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Cerrar",
                  style: TextStyle(
                    color: DataUI.chedrauiBlueColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        });
  }

  void getSessionStatus() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  @override
  initState() {
    getSessionStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var orderData = widget.orderData;
    List<DeliveryStore> tiendasEntrega = widget.shippingData;
    var fechaHoraEntrega = widget.shippingDatetime;
    return WidgetContainer(
        Scaffold(
        backgroundColor: HexColor('#F0EFF4'),
        // appBar: GradientAppBar(
        //   elevation: 0,
        //   gradient: LinearGradient(
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //     colors: [
        //       HexColor('#F56D00'),
        //       HexColor('#F56D00'),
        //       HexColor('#F78E00'),
        //     ],
        //   ),
        //   leading: Builder(
        //     builder: (BuildContext context) {
        //       return IconButton(
        //         icon: Icon(Icons.close),
        //         onPressed: () {
        //           Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
        //         },
        //       );
        //     },
        //   ),
        //   title: Text(
        //     'Orden #' + orderData['code'] + ' - Recibida',
        //     style: TextStyle(color: Colors.white, fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 19),
        //   ),
        // ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Theme(
              data: ThemeData(
                primaryColor: Colors.transparent,
                hintColor: Colors.transparent,
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    // margin: const EdgeInsets.all(15.0),
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                        // color: Colors.white,
                        // boxShadow: <BoxShadow>[
                        //   BoxShadow(
                        //     color: Color(0xcc000000).withOpacity(0.1),
                        //     offset: Offset(0.0, 5.0),
                        //     blurRadius: 10.0,
                        //   ),
                        // ],
                        ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
                            },
                            icon: Icon(Icons.close),
                          ),
                        ),
                        Center(
                          child: Image.asset(
                            'assets/checkGreen.jpeg',
                            width: 60,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20, top: 22),
                          child: Text(
                            '¡Gracias!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          'Tu orden ha sido procesada.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, fontFamily: 'Archivo', color: HexColor('#444444')),
                        ),
                        Text(
                          'Revisa tu correo electrónico donde podrás encontrar la confirmación de tu orden y la información.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, fontFamily: 'Rubik', color: HexColor('#454F5B')),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 15),
                          padding: EdgeInsets.all(15),
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'Orden #' + orderData['code'] + ' - Recibida',
                            style: TextStyle(color: HexColor('#0D47A1'), fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Resumen de orden",
                      style: TextStyle(fontFamily: "Rubik", fontSize: 14, color: HexColor('#454F5B')),
                    ),
                  ),
                  Container(
                    child: custom.ExpansionTile(
                      backgroundColor: Colors.white,
                      headerBackgroundColor: HexColor('#0D47A1'),
                      initiallyExpanded: true,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            stringTotal,
                            style: TextStyle(fontFamily: "Archivo", fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                          ),
                          Expanded(
                            flex: 1,
                            child: SizedBox(),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              moneda.format(orderData['totalPrice']['value'] - widget.monederoData),
                              style: TextStyle(fontFamily: "Archivo", fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                            ),
                          )
                        ],
                      ),
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(right: 15, left: 15, bottom: 15),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              orderData['subTotal'] != null && orderData['subTotal']['value']  > 0 ?
                              Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      'Subtotal',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Archivo',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      moneda.format(orderData['subTotal']['value']),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Archivo',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ) : SizedBox(height: 0,),
                              widget.monederoData > 0
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Text(
                                            'Mi Monedero Chedraui',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Archivo',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '-' + moneda.format(widget.monederoData),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Archivo',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : SizedBox(
                                      height: 0,
                                    ),
                              orderData['deliveryCost'] != null && orderData['deliveryCost']['value']  > 0 ?
                              Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      'Envío/Entrega',
                                      style: TextStyle(
                                        fontFamily: 'Archivo',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      moneda.format(orderData['deliveryCost']['value']),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Archivo',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ) : SizedBox(height: 0,),
                              orderData['orderDiscounts'] != null && orderData['orderDiscounts']['value']  > 0 ?
                              Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      'Cupón',
                                      style: TextStyle(
                                        fontFamily: 'Archivo',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      '- ' + moneda.format(orderData['orderDiscounts']['value']),
                                      style: TextStyle(
                                        fontFamily: 'Archivo',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ) : SizedBox(height: 0,),
                              orderData['totalPrice'] != null && orderData['totalPrice']['value']  > 0 ?
                              Padding(
                                padding: const EdgeInsets.only(top: 10, bottom: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      'Total',
                                      style: TextStyle(
                                        fontFamily: 'Archivo',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      moneda.format(orderData['totalPrice']['value'] - widget.monederoData),
                                      style: TextStyle(
                                        fontFamily: 'Archivo',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ) : SizedBox(height: 0,),
                              Padding(
                                padding: const EdgeInsets.only(top: 10, bottom: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      'Forma de Pago:',
                                      style: TextStyle(
                                        fontFamily: 'Archivo',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    //_selectSvgCard(paymentData['card']['brand']),
                                    /*
                              Text(
                                '**** '+paymentData['card']['card_number'].substring(12),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              */
                                    Text(
                                      getFormaPago(widget.paymentMethod) ?? "",
                                      style: TextStyle(
                                        fontFamily: 'Archivo',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 15),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Fecha y hora estimado de entrega:' + '\n',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: HexColor('#444444'),
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: fechaHoraEntrega,
                            //text: "",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: DataUI.textOpaqueStrong,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  /*
                  Container(
                    margin: const EdgeInsets.all(15.0),
                    padding: const EdgeInsets.all(15.0),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Color(0xcc000000).withOpacity(0.2),
                          offset: Offset(0.0, 5.0),
                          blurRadius: 10.0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text(
                          'Crea tu cuenta Chedraui',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15, bottom: 15),
                          child: Text(
                            'Completa el registro de tu cuenta Chedraui agregando una contraseña.',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: const EdgeInsets.only(
                                  top: 12,
                                  bottom: 12,
                                  left: 6, //todo
                                  right: 6 //todo
                                  ),
                              hintText: '* Contraseña',
                              hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            ),
                            // onSaved: (input) {
                            //   personalData.nombre = input;
                            // },
                            // validator: _validateName,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: RaisedButton(
                                  color: DataUI.chedrauiBlueColor,
                                  onPressed: () {
                                    // validateCoupon();
                                  },
                                  child: Text(
                                    "Crear Cuenta",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  */
                  !isLoggedIn
                      ? Container(
                          margin: const EdgeInsets.all(15.0),
                          padding: const EdgeInsets.all(15.0),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Color(0xcc000000).withOpacity(0.2),
                                offset: Offset(0.0, 5.0),
                                blurRadius: 10.0,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("Crea tu cuenta Chedraui", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'Archivo', color: HexColor('#212B36'))),
                              Padding(
                                padding: const EdgeInsets.only(top: 15, bottom: 15),
                                child: Text(
                                  'Completa el registro de tu cuenta Chedraui agregando una contraseña.',
                                  style: TextStyle(fontSize: 14, fontFamily: 'Rubik', color: HexColor('#454F5B')),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15, bottom: 15),
                                child: Form(
                                    key: _formKey,
                                    autovalidate: false,
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          'Contraseña',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(fontSize: 14, color: HexColor('#212B36'), fontFamily: 'Archivo'),
                                        ),
                                      ),
                                      TextFormField(
                                        style: TextStyle(color: HexColor('#0D47A1'), fontSize: 14, fontFamily: 'Archivo'),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: HexColor('#F0EFF4'),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                        ),
                                        onSaved: (input) {
                                          password = input;
                                        },
                                        enabled: !isLoggedIn,
                                        enableInteractiveSelection: !isLoggedIn,
                                        validator: _validatePassword,
                                        textInputAction: TextInputAction.done,
                                        obscureText: false,
                                        onFieldSubmitted: (input) {},
                                      ),
                                    ])),
                              ),
                              Container(
                                width: double.infinity,
                                child: FlatButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState.validate()) {
                                      _formKey.currentState.save();
                                      if (!isLoading) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        SinginUserData bodyRegistro = new SinginUserData();
                                        bodyRegistro.nombre = prefs.getString("delivery-userName");
                                        bodyRegistro.paterno = prefs.getString("delivery-userLastName");
                                        bodyRegistro.materno = prefs.getString("delivery-userSecondLastName");
                                        bodyRegistro.email = prefs.getString("email");
                                        bodyRegistro.password = password;
                                        bodyRegistro.celular = prefs.getString("delivery-telefono");
                                        bodyRegistro.cpostal = prefs.getString("delivery-codigoPostal");
                                        print(bodyRegistro.nombre);
                                        print(bodyRegistro.paterno);
                                        print(bodyRegistro.materno);
                                        print(bodyRegistro.email);
                                        print(bodyRegistro.password);
                                        print(bodyRegistro.celular);
                                        print(bodyRegistro.cpostal);
                                        var responseRegistro = await AuthServices.postGCloudSignIn(bodyRegistro);
                                        setState(() {
                                          isLoading = false;
                                        });
                                        if (responseRegistro != null && responseRegistro['code'] != null) {
                                          num code = responseRegistro['code'];
                                          String desc = responseRegistro['description'];
                                          switch (code) {
                                            case 0:
                                              prefs.remove('email');
                                              prefs.remove('password');
                                              Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                    settings: RouteSettings(name: DataUI.loginRoute),
                                                    builder: (context) => LoginPage(),
                                                  ),
                                                  (Route<dynamic> route) => false);
                                              break;
                                            default:
                                              _showResponseDialog(desc);
                                              break;
                                          }
                                        } else {
                                          _showResponseDialog("Se presentó un problema al registrar su cuenta.");
                                        }
                                      }
                                    }
                                  },
                                  color: HexColor('#F57C00'),
                                  padding: EdgeInsets.only(left: 0, right: 0, bottom: 15, top: 15),
                                  child: !isLoading
                                      ? Text(
                                          "Crear Cuenta",
                                          style: TextStyle(
                                            fontFamily: 'Archivo',
                                            fontWeight: FontWeight.bold,
                                            color: DataUI.whiteText,
                                            fontSize: 16,
                                          ),
                                        )
                                      : CircularProgressIndicator(),
                                ),
                              )
                            ],
                          ))
                      : SizedBox(
                          height: 0,
                        ),
                  widget.additionalData != null
                      ? Container(
                          margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 0),
                          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 0),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(),
                          child: Column(children: <Widget>[
                            Text(
                              "Referencia: " + widget.additionalData['barCodeReference'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: DataUI.textOpaque,
                              ),
                            )
                          ]))
                      : SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.all(22),
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Image.asset('assets/checkoutConfirmation.png'),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 0),
                    padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 0),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: SizedBox(),
                        ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: OutlineButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              color: DataUI.chedrauiBlueColor,
                              borderSide: BorderSide(color: DataUI.chedrauiBlueColor),
                              child: Text(
                                'Continúa comprando',
                                style: TextStyle(
                                  fontFamily: 'Archivo',
                                  fontSize: 14,
                                  color: DataUI.chedrauiBlueColor,
                                ),
                              ),
                              onPressed: () {
                                if (!isLoggedIn) {
                                  prefs.remove('email');
                                  prefs.remove('password');
                                }
                                Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: SizedBox(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // bottomNavigationBar: FooterNavigation(
        //   (val) {},
        //   mainNavigation: false,
        // ),
      )
    );
  }
}
