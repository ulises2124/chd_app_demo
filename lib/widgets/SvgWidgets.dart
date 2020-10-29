import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Container FacebookSVG() {
  final String assetName = 'assets/svgs/facebook.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'facebook',
    height: 40,
    width: 40,
  );
  return Container(
    child: svg,
  );
}
Container GoogleSVG() {
  final String assetName = 'assets/svgs/google.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'google',
    height: 40,
    width: 40,
  );
  return Container(
    child: svg,
  );
}

Container ChedrauiSVG() {
  final String assetName = 'assets/svgs/chedraui.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'chedraui',
    height: 14,
    width: 187,
  );
  return Container(
    child: svg,
  );
}


Container VisaSVG() {
  final String assetName = 'assets/svgs/visa.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'visa',
    height: 18,
    width: 18,
  );
  return Container(
    child: svg,
  );
}

Container MasterCardSVG() {
  final String assetName = 'assets/svgs/mastercard.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'mastercard',
    height: 18,
    width: 18,
  );
  return Container(
    child: svg,
  );
}

Container AmexSVG() {
  final String assetName = 'assets/svgs/amex.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'amex',
    height: 18,
    width: 18,
  );
  return Container(
    child: svg,
  );
}

Container PayPalSVG(double size) {
  final String assetName = 'assets/svgs/paypal.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'paypal',
    height: size,
    width: size,
  );
  return Container(
    child: svg,
  );
}

Container PayPalPaySVG(double height, double width) {
  final String assetName = 'assets/svgs/paypalPay.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'paypalPay',
    height: height,
    width: width,
  );
  return Container(
    child: svg,
  );
}

Container WaldosSVG(double height, double width) {
  final String assetName = 'assets/svgs/waldos.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'waldos',
    height: height,
    width: width,
  );
  return Container(
    child: svg,
  );
}

Container CardVisa(double height, double width, bool selected) {
  final String assetName = selected ? 'assets/svgs/card-visa-selected.svg' : 'assets/svgs/card-visa.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'VISA',
    height: height,
    width: width,
  );
  return Container(
    child: svg,
  );
}

Container CardMasterCard(double height, double width, bool selected) {
  final String assetName = selected ? 'assets/svgs/card-mastercard-selected.svg' : 'assets/svgs/card-mastercard.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'Master Card',
    height: height,
    width: width,
  );
  return Container(
    child: svg,
  );
}

Container CardAmex(double height, double width, bool selected) {
  final String assetName = selected ? 'assets/svgs/card-amex-selected.svg' : 'assets/svgs/card-amex.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'Amex',
    height: height,
    width: width,
  );
  return Container(
    child: svg,
  );
}

Container CardCash(double height, double width, bool selected) {
  final String assetName = selected ? 'assets/svgs/card-cash-selected.svg' : 'assets/svgs/card-cash.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'Efectivo',
    height: height,
    width: width,
  );
  return Container(
    child: svg,
  );
}

Container CardEcoupon(double height, double width, bool selected) {
  final String assetName = selected ? 'assets/svgs/card-ecoupon-selected.svg' : 'assets/svgs/card-ecoupon.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'Vales electrónicos',
    height: height,
    width: width,
  );
  return Container(
    child: svg,
  );
}

Container MonederoSVG(double height, double width) {
  final String assetName = 'assets/svgs/monedero.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'monedero',
    height: height,
    width: width,
  );
  return Container(
    child: svg,
  );
}

Container UbicaTiendasSVG() {
  final String assetName = 'assets/svgs/ubica-tu-tienda.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'ubica',
    // height: 18,
    // width: 18,
  );
  return Container(
    child: svg,
  );
}

Container CallSVG() {
  final String assetName = 'assets/svgs/call.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'call',
    // height: 18,
    // width: 18,
  );
  return Container(
    child: svg,
  );
}


Container FamilySVG() {
  final String assetName = 'assets/svgs/family.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'family',
    // height: 18,
    // width: 18,
  );
  return Container(
    child: svg,
  );
}
Container TwitterIconSVG() {
  final String assetName = 'assets/svgs/twitterIcon.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'Twitter',
    // height: 18,
    // width: 18,
  );
  return Container(
    child: svg,
  );
}
Container YoutubeIconSVG() {
  final String assetName = 'assets/svgs/youtubeIcon.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'Youtube',
    // height: 18,
    // width: 18,
  );
  return Container(
    child: svg,
  );
}
Container FacebookIconSVG() {
  final String assetName = 'assets/svgs/facebookIcon.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'Facebook',
    // height: 18,
    // width: 18,
  );
  return Container(
    child: svg,
  );
}

Container ChdLogo() {
  final String assetName = 'assets/svgs/chd_logo.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'chd_logo',
    height: 18,
    width: 18,
  );
  return Container(
    child: svg,
  );
}

Container DhlLogo() {
  final String assetName = 'assets/svgs/094711179f.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'dhl_logo',
    height: 18,
    width: 18,
  );
  return Container(
    child: svg,
  );
}

Container OrderInProgress() {
  final String assetName = 'assets/svgs/orderInProgress.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'inProgress',
    height: 25,
    width: 20,
  );
  return Container(
    child: svg,
  );
}

Container OrderDelivered() {
  final String assetName = 'assets/svgs/orderDelivered.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'delivered',
    height: 25,
    width: 17,
  );
  return Container(
    child: svg,
  );
}

Container OrderPending() {
  final String assetName = 'assets/svgs/orderPending.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'pending',
    height: 25,
    width: 25,
  );
  return Container(
    child: svg,
  );
}

Container OrderCancelled() {
  final String assetName = 'assets/svgs/orderCancelled.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'cancelled',
    height: 25,
    width: 25,
  );
  return Container(
    child: svg,
  );
}

Container ChedrauiHeader() {
  final String assetName = 'assets/svgs/chedraui-header.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'chedraui',
    // height: 15,
    // width: 25,
  );
  return Container(
    child: svg,
  );
}

Container ChedrauiHeaderWhite(double width, double height) {
  final String assetName = 'assets/svgs/chedraui-header-white.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'chedraui',
     height: height,
     width: width,
  );
  return Container(
    child: svg,
  );
}

Container MenuBG() {
  final String assetName = 'assets/svgs/menu-bg.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'famil',
    // height: 15,
    // width: 25,
  );
  return Container(
    child: svg,
  );
}


Container MenuToggleSVG(double h, double y) {
  final String assetName = 'assets/svgs/hamburger.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'hamburguer menu',
    height: y,
    width: h,
  );
  return Container(
    child: svg,
  );
}

Container BarcodeMonedero() {
  final String assetName = 'assets/svgs/Barcode.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'famil',
    // height: 15,
    // width: 25,
  );
  return Container(
    child: svg,
  );
}

Container Camioneta() {
  final String assetName = 'assets/svgs/DeliveryVan.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'famil',
    height: 150,
    width: 150,
  );
  return Container(
    child: svg,
  );
}


Container MCSVG(double size, String department) {
  final String assetName = 'assets/svgs/mc/' + department + '.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'mc svg', 
    height: size,
    // width: h,
  );
  return Container(
    child: svg,
  );
}

Container ScanSVG() {
  final String assetName = 'assets/svgs/scan.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'scan',
     height: 23,
     width: 23,
  );
  return Container(
    child: svg,
  );
}
Container ScanWhiteSVG() {
  final String assetName = 'assets/svgs/scan_white.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'scan',
     height: 23,
     width: 23,
  );
  return Container(
    child: svg,
  );
}
Container CarritoSVG() {
  final String assetName = 'assets/svgs/cart.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'carrito',
    //  height: 23,
    //  width: 23,
  );
  return Container(
    child: svg,
  );
}
Container BillSVG() {
  final String assetName = 'assets/svgs/bill.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'bill',
    //  height: 23,
    //  width: 23,
  );
  return Container(
    child: svg,
  );
}
Container UserSVG() {
  final String assetName = 'assets/svgs/user.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'user',
    //  height: 23,
    //  width: 23,
  );
  return Container(
    child: svg,
  );
}

Container ComparadorSVG() {
  final String assetName = 'assets/svgs/balance.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'balance',
    //  height: 23,
    //  width: 23,
  );
  return Container(
    child: svg,
  );

}

Container TiendaIconSVG(bool isActive) {
  final String assetName = isActive ? 'assets/svgs/footerIcons/iconTiendaActive.svg' : 'assets/svgs/footerIcons/iconTienda.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'tienda',
    //  height: 23,
    //  width: 23,
  );
  return Container(
    child: svg,
  );
}

Container ListasIconSVG(bool isActive) {
  final String assetName = isActive ? 'assets/svgs/footerIcons/iconListasActive.svg' : 'assets/svgs/footerIcons/iconListas.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'listas',
    //  height: 23,
    //  width: 23,
  );
  return Container(
    child: svg,
  );
}

Container BuscarIconSVG(bool isActive) {
  final String assetName = isActive ? 'assets/svgs/footerIcons/iconBuscarActive.svg' : 'assets/svgs/footerIcons/iconBuscar.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'buscar',
    //  height: 23,
    //  width: 23,
  );
  return Container(
    child: svg,
  );
}

Container CarritoIconSVG(bool isActive) {
  final String assetName = isActive ? 'assets/svgs/footerIcons/iconCarritoActive.svg' : 'assets/svgs/footerIcons/iconCarrito.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'carrito',
    //  height: 23,
    //  width: 23,
  );
  return Container(
    child: svg,
  );
}

Container HamburguerIconSVG() {
  final String assetName = 'assets/svgs/hamburguerIcon.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'menu',
     height: 18,
     width: 18,
  );
  return Container(
    child: svg,
  );
}

Container FilterIcon() {
  final String assetName = 'assets/svgs/filter_icon.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'filter_icon',
    //  height: 18,
    //  width: 18,
  );
  return Container(
    child: svg,
  );
}

Container LogoSvgLogin() {
  final String assetName = 'assets/svgs/family_orange.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'family_orange',
    //  height: 18,
    //  width: 18,
  );
  return Container(
    child: svg,
  );
}

Container InstruccionesSvg() {
  final String assetName = 'assets/svgs/instrucciones.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'instrucciones',
    //  height: 18,
    //  width: 18,
    );
  return Container(
    child: svg,
  );
}

Container DeliverIcon({double height = 20, double width = 20}) {
  final String assetName = 'assets/svgs/Deliver.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'Deliver',
    height: height,
    width: width,
  );
  return Container(
    child: svg,
  );
}

Container CurrentLocationArrow() {
  final String assetName = 'assets/svgs/currentLocationArrow.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'Current Location',
    // height: height,
    // width: width,
  );
  return Container(
    child: svg,
  );
}

Container LemonSvg() {
  final String assetName = 'assets/svgs/lemon.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'lemon',
    height: 18,
    width: 18,
  );
  return Container(
    child: svg,
  );
}


Container RefreshSVG() {
  final String assetName = 'assets/svgs/refresh.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'refresh Icon',
    height: 25,
    width: 25,
  );
  return Container(
    child: svg,
  );
}

Container RedSVG() {
  final String assetName = 'assets/svgs/red.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'refresh Icon',
    height: 50,
    width: 50,
  );
  return Container(
    child: svg,
  );
}

Container NoUbicaciones() {
  final String assetName = 'assets/svgs/noubicacion.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'refresh Icon',
    height: 170,
    width: 153,
    );
  return Container(
    child: svg,
  );
}

Container EnvioCheckoutSVG(){
  final String assetName = 'assets/svgs/envio_checkout.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'Envio Icon',
    height: 25,
    width: 25,
  );
  return Container(
    child: svg,
  );
}

Container MonederoCheckoutSVG(){
  final String assetName = 'assets/svgs/monedero_checkout.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'Monedero Icon',
    height: 25,
    width: 25,
  );
  return Container(
    child: svg,
  );
}

Container PedidosCheckoutSVG(){
  final String assetName = 'assets/svgs/pedidos_checkout.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'Pedidos Icon',
    height: 25,
    width: 25,
  );
  return Container(
    child: svg,
  );
}

Container StateConnectivitySVG(){
  final String assetName = 'assets/svgs/EnableNotifications.svg';
  final Widget svg = new SvgPicture.asset(
    assetName,
    semanticsLabel: 'Conectividad Icon',
  );
  return Container(
    child: svg,
  );
}
