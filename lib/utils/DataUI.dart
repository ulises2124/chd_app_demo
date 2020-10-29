import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';

/*
Material Color Palette
Design Prototypes

LOGIN:
https://www.figma.com/file/LIfrDS7EKHDgz2EvOkr9oZCR/Login-(Scratch)?node-id=1%3A2

*/

class DataUI {
  static const String initialRoute = "/";
  static const String tiendaRoute = "/Tienda";
  static const String splahsScreenRoute = "/SplashScreen";
  static const String buscarRoute = "/Buscar";
  static const String loginRequiredRoute = "/LoginRequerido";
  static const String categoryRoute = "/Categoría";
  static const String subCategoryRoute = "/Subcategoría";
  static const String productRoute = "/DetalleProducto";
  static const String productsRoute = "/ProductsPage";
  static const String deliveryMethodRoute = "/MétodoEntrega";
  static const String editAddressRoute = "/EditarDirección";
  static const String confirmAddressRoute = "/AgregarDirección";
  static const String loginRoute = "/Login";
  static const String cuponesRoute = "/Cupones";
  static const String addCouponsRoute = "/AgregarCupón";
  static const String recoveryPasswordRoute = "/RecuperarContraseña";
  static const String signInRoute = "/RegistroUsuario";
  static const String pagoServiciosRoute = "/PagoServicios";
  static const String selectedPagoServiciosRoute = "/PagoServicioSeleccionado";
  static const String misServiciosRoute = "/MisServicios";
  static const String historialPagosServiciosRoute = "/HistorialPagoServicios";
  static const String reciboPagoServiciosRoute = "/ReciboPagoServicios";
  static const String serviciosDisponibles = "/ServiciosDisponibles";
  static const String listasRoute = "/Listas";
  static const String listasSearchRoute = "/ListasBuscarProducto";
  static const String listasProductDetails = "/ListasDetalleProducto";
  static const String listasEdit = "/EditarListas";
  static const String listaDetails = "/DetallesLista";
  static const String listaNew = "/NuevaLista";
  static const String contactanosRoute = "/Contáctanos";
  static const String contactanosWebRoute = '/ContáctanosWeb';
  static const String contactanosWebAndroidRoute = '/ContáctanosWebAndroid';
  static const String facturacionRoute = "/Facturación";
  static const String pedidosRoute = "/Pedidos";
  static const String pedidoDetailsRoute = "/DetallesPedido";
  static const String chatPedidosRoute = "/ChatPedidos";
  static const String monederoRoute = "/Monedero";
  static const String monederoDetailsRoute = "/DetallesMonedero";
  static const String addCardRoute = "/AgregarTarjeta";
  static const String editCardRoute = "/EditarTarjeta";
  static const String carritoRoute = "/Carrito";
  static const String checkoutRoute = "/Checkout";
  static const String checkoutConfirmationRoute = "/CheckoutConfirmación";
  static const String cuentaRoute = "/Cuenta";
  static const String comparadorPreciosRoute = "/ComparadorPrecios";
  static const String paypalRoute = "/VistaPayPal";
  static const String chatContactRoute = "/ChatContáctanos";
  //    Errors & Warnings
  static const String networkErrorRoute = "/NetworkError";
  static const String updateAppWarningRoute = "/UpdateApp";

/////////////////////////////////////////////////////////////////////
  //strings
  static const String appName = "Chedraui";

  //colors
  static TextStyle footerMenuStyle = TextStyle(
    color: DataUI.textOpaqueStrong,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    fontFamily: 'Archivo',
  );

  static TextStyle appbarTitleStyle = TextStyle(
    color: DataUI.primaryText,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle menuItemTitleStyle = TextStyle(
    color: DataUI.primaryText,
    fontWeight: FontWeight.normal,
    fontFamily: 'Archivo',
    fontSize: 16,
  );

  static TextStyle menuItemTitleStyle2 = TextStyle(
    color: DataUI.primaryText,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.11,
    fontFamily: 'Archivo',
  );

  static TextStyle mapTabButtonActiveStyle = TextStyle(
    color: DataUI.blackText,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static TextStyle mapTabButtonUnActiveStyle = TextStyle(
    color: DataUI.textDisabled,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static Color primaryText = Colors.white;
  static Color whiteText = Colors.white;
  static Color blackText = Colors.black;
  static Color textDisabled = HexColor('#9ca4ab');
  static Color textOpaque = HexColor('#919EAB');
  static Color textOpaqueMedium = HexColor('#454F5B');
  static Color textOpaqueStrong = HexColor('#212B36');
  static Color chedrauiColor = HexColor('#F28524');
  static Color chedrauiColor2 = HexColor('#F56D11');
  static Color chedrauiColorDisabled = HexColor('#F5B97C');
  static Color chedrauiBlueColor = HexColor('#0D47A1');
  static Color chedrauiBlueSoftColor = HexColor('#5967D6');
  static Color backgroundColor = HexColor('#F4F6F8');
  static Color backgroundColor2 = HexColor('#F0EFF4');
  static Color opaqueBorder = HexColor('#C4CDD5');

  static Color bgGradientTopLightBlue = HexColor('#0897FF');
  static Color bgGradientBottomBlue = HexColor('#0064FF');

  static Color btnGradienttopLightOrange = HexColor('#FFAD63');
  static Color btnGradientBottomOrange = HexColor('#EF5F31');
  static Color btnSplashColor = HexColor('#FFD6B2');

  static Color btnbuy = HexColor('#F57C00');
  static Color btnFacebook = HexColor('#385898');

  static List<Color> btnGradient = [btnGradientBottomOrange, btnGradienttopLightOrange];

  static LinearGradient appbarGradient = LinearGradient(
    //stops: [0, 0, 1],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      HexColor('#F56D00'),
      HexColor('#F56D00'),
      HexColor('#F78E00'),
    ],
  );
  //randomcolor
  static final Random _random = new Random();

  /// Returns a random color.
  static Color next() {
    return new Color(0xFF000000 + _random.nextInt(0x00FFFFFF));
  }

  //fonts
  // static const String quickFont = "Quicksand";
  // static const String ralewayFont = "Raleway";
  // static const String quickBoldFont = "Quicksand_Bold.otf";
  // static const String quickNormalFont = "Quicksand_Book.otf";
  // static const String quickLightFont = "Quicksand_Light.otf";

  //images
  // static const String imageDir = "assets/images";
  // static const String pkImage = "$imageDir/pk.jpg";

  //login
  // static const String enter_code_label = "Phone Number";
  // static const String enter_code_hint = "10 Digit Phone Number";
  // static const String enter_otp_label = "OTP";
  // static const String enter_otp_hint = "4 Digit OTP";
  // static const String get_otp = "Get OTP";
  // static const String resend_otp = "Resend OTP";
  // static const String login = "Login";
  // static const String enter_valid_number = "Enter 10 digit phone number";
  // static const String enter_valid_otp = "Enter 4 digit otp";

  //gneric
  // static const String error = "Error";
  // static const String success = "Success";
  // static const String ok = "OK";
  // static const String forgot_password = "Forgot Password?";
  // static const String something_went_wrong = "Something went wrong";
  // static const String coming_soon = "Coming Soon";

}

// ThemeData buildTheme() {
// Color bgGradientTopLightBlue = HexColor('#0897FF');
// Color bgGradientBottomBlue = HexColor('#0064FF');
// Color whiteText = Colors.white;
// Color txbBlackText = Colors.black;

// <resources>
//   <color name="primaryColor">#f28524</color>
//   <color name="primaryLightColor">#ffb656</color>
//   <color name="primaryDarkColor">#b95700</color>
//   <color name="secondaryColor">#0c6bff</color>
//   <color name="secondaryLightColor">#6c98ff</color>
//   <color name="secondaryDarkColor">#0042cb</color>
//   <color name="primaryTextColor">#000000</color>
//   <color name="secondaryTextColor">#ffffff</color>
// </resources>

//   Color chedrauiColor = HexColor('#F28524');

//   final ThemeData base = ThemeData();
//   return base.copyWith(
//     hintColor: chedrauiColor,
//     primaryColor: Colors.black,
//     inputDecorationTheme: InputDecorationTheme(
//       hintStyle: TextStyle(
//         color: chedrauiColor,
//       ),
//       labelStyle: TextStyle(
//         color: chedrauiColor,
//       ),
//     ),
//   );
// }
