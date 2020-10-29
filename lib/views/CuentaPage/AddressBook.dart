import 'package:chd_app_demo/redux/actions/LocationActions.dart';
import 'package:chd_app_demo/redux/models/AppState.dart';
import 'package:chd_app_demo/services/UserProfileServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/utils/addressData.dart';
import 'package:chd_app_demo/views/CuentaPage/CuentaPage.dart';
import 'package:chd_app_demo/views/CuentaPage/EditAddressPage.dart';
import 'package:chd_app_demo/views/DeliveryMethod/DeliveryMethodPage.dart';
import 'package:chd_app_demo/views/DeliveryMethod/SelectedLocation.dart';
import 'package:chd_app_demo/views/HomePage/HomePage.dart';
import 'package:chd_app_demo/views/MasterPage/MasterPage.dart';
import 'package:chd_app_demo/views/MasterPage/MenuScreen.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class AddressBook extends StatefulWidget {
  final ctx;
  AddressBook({Key key, this.ctx}) : super(key: key);

  _AddressBookState createState() => _AddressBookState();
}

class _AddressBookState extends State<AddressBook> {
  SharedPreferences prefs;
  List addresses;
  bool _isUpdatingAddresses = false;
  Address editAddress = Address();

  @override
  void initState() {
    super.initState();
    getAddressBoook();
    getPreferences();
  }

  void getAddressBoook() async {
    _isUpdatingAddresses = true;
    UserProfileServices.hybrisGetUserAddress().then((response) {
      setState(() {
        addresses = response['addresses'];
        _isUpdatingAddresses = false;
        // for (var item in interest) {
        //   print(item['descripcion']);
        //   print(item['activo']);
        //   print('\n');
        // }
      });
    });
  }

  Future getPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _deleteItem(String addressId) async {
    try {
      await UserProfileServices.hybrisDeletetUserAddress(addressId).then((response) {
        if (response.statusCode == 200) {
          getAddressBoook();
        } else {
          setState(() {
            _isUpdatingAddresses = false;
          });
        }
      });
    } catch (e) {
      print(e);
      Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
      Navigator.pushNamed(context, DataUI.cuentaRoute);
      // Navigator.of(context).pushAndRemoveUntil(
      //   MaterialPageRoute(
      //     builder: (BuildContext context) => MasterPage(
      //       initialWidget: MenuItem(
      //         id: 'cuenta',
      //         title: ' ',
      //         screen: CuentaPage(),
      //         color: DataUI.backgroundColor,
      //       ),
      //     ),
      //   ),
      //   (Route<dynamic> route) => false,
      // );
    }
  }

  void _selectDeliveryAddress(var address) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar Dirección'),
          content: Text(
            'Seleccionar como dirección de envio actual?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: DataUI.textOpaque,
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancelar",
                  style: TextStyle(
                    color: DataUI.chedrauiBlueColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: RaisedButton(
                color: DataUI.chedrauiBlueColor,
                onPressed: () async {
                  print(address);

                  SelectedLocation selectedAddress = SelectedLocation();
                  selectedAddress.isLocationSet = true;
                  selectedAddress.isPickup = false;
                  selectedAddress.userName = address['firstName'];
                  selectedAddress.userLastName = address['lastName'];
                  selectedAddress.direccion = address['line1'];
                  selectedAddress.numInterior = address['line2'];
                  selectedAddress.sublocality = address['town'];
                  selectedAddress.codigoPostal = address['postalCode'];
                  selectedAddress.estado = address['region'] != null ? address['region']['name'] : "";
                  selectedAddress.telefono = address['phone'];
                  selectedAddress.formattedAddress = address['formattedAddress'];
                  selectedAddress.addressId = address['id'];

                  prefs.setBool('isLocationSet', true);
                  prefs.setBool('isPickUp', false);
                  prefs.setString('delivery-userName', address['firstName']);
                  prefs.setString('delivery-userLastName', address['lastName']);
                  prefs.setString('delivery-direccion', address['line1']);
                  prefs.setString('delivery-numInterior', address['line2']);
                  prefs.setString('delivery-sublocality', address['town']);
                  prefs.setString('delivery-codigoPostal', address['postalCode']);
                  prefs.setString('delivery-estado', address['region'] != null ? address['region']['name'] : "");
                  prefs.setString("delivery-telefono", address["phone"]);
                  prefs.setString("delivery-formatted_address", address["formattedAddress"]);
                  prefs.setString("delivery-address-id", address["id"]);
                  prefs.setBool("cart-address-update", true);

                  final store = StoreProvider.of<AppState>(context);
                  store.dispatch(SetCurrentLocationAction(selectedAddress));

                  // Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
                  // Navigator.pushNamed(context, DataUI.cuentaRoute);

                  Navigator.pop(context);
                  print(widget.ctx);
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: new Text('Se ha eliminado correctamente la lista.'),
                    ),
                  );
                  // Navigator.of(context).pushAndRemoveUntil(
                  //   MaterialPageRoute(
                  //     builder: (BuildContext context) => MasterPage(
                  //       initialWidget: MenuItem(
                  //         id: 'cuenta',
                  //         title: ' ',
                  //         screen: CuentaPage(),
                  //         color: DataUI.backgroundColor2,
                  //         textColor: Colors.black,
                  //       ),
                  //     ),
                  //   ),
                  //   (Route<dynamic> route) => false,
                  // );
                },
                child: Text(
                  "Seleccionar",
                  style: TextStyle(
                    color: DataUI.whiteText,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(String addressId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Dirección'),
          content: Text(
            'Al eliminar esta dirección ya no aparecerá en tu lista',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: DataUI.textOpaque,
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancelar",
                  style: TextStyle(
                    color: DataUI.chedrauiBlueColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: RaisedButton(
                color: DataUI.chedrauiBlueColor,
                onPressed: () async {
                  setState(() {
                    _isUpdatingAddresses = true;
                  });
                  Navigator.of(context).pop();
                  _deleteItem(addressId);
                },
                child: Text(
                  "Eliminar",
                  style: TextStyle(
                    color: DataUI.whiteText,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _editAddress(var adressToUpdate) async {
    editAddress.countryisocode = adressToUpdate['country']['isocode'];
    editAddress.countryname = adressToUpdate['country']['name'];
    editAddress.email = adressToUpdate['email'];
    editAddress.firstName = adressToUpdate['firstName'];
    editAddress.formattedAddress = adressToUpdate['formattedAddress'];
    editAddress.id = adressToUpdate['id'];
    editAddress.lastName = adressToUpdate['lastName'];
    editAddress.secondLastName = adressToUpdate['secondLastName'] ?? '';
    editAddress.line1 = adressToUpdate['line1'];
    editAddress.line2 = adressToUpdate['line2'] ?? '';
    editAddress.phone = adressToUpdate['phone'];
    editAddress.postalCode = adressToUpdate['postalCode'];
    editAddress.regioncountryIso = adressToUpdate['region']['countryIso'];
    editAddress.regionisocode = adressToUpdate['region']['isocode'];
    editAddress.regionisocodeShort = adressToUpdate['region']['isocodeShort'];
    editAddress.regionname = adressToUpdate['region']['name'];
    editAddress.shippingAddress = adressToUpdate['shippingAddress'];
    editAddress.town = adressToUpdate['town'];
    editAddress.visibleInAddressBook = adressToUpdate['visibleInAddressBook'];

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: DataUI.editAddressRoute),
        builder: (BuildContext context) => EditAddressPage(address: editAddress),
      ),
    );
    if (result == 'direcciones') {
      getAddressBoook();
    }
    // print(editAddress.countryisocode.toString());
    // print(editAddress.countryname.toString());
    // print(editAddress.email.toString());
    // print(editAddress.firstName.toString());
    // print(editAddress.formattedAddress.toString());
    // print(editAddress.id.toString());
    // print(editAddress.lastName.toString());
    // print(editAddress.secondLastName.toString());
    // print(editAddress.line1.toString());
    // print(editAddress.phone.toString());
    // print(editAddress.postalCode.toString());
    // print(editAddress.regioncountryIso.toString());
    // print(editAddress.regionisocode.toString());
    // print(editAddress.regionisocodeShort.toString());
    // print(editAddress.regionname.toString());
    // print(editAddress.shippingAddress.toString());
    // print(editAddress.town.toString());
    // print(editAddress.visibleInAddressBook.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 12, right: 12),
      padding: EdgeInsets.only(top: 12, bottom: 12),
      // color: Colors.white,
      child: !_isUpdatingAddresses
          ? Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AnimatedCrossFade(
                  sizeCurve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 280),
                  crossFadeState: addresses == null ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                  firstChild: Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  secondChild: addresses.length > 0 && addresses != null
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: addresses == null ? 0 : addresses.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(top: 8, left: 10, right: 10),
                              padding: EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                // border: addresses[index]['activo']
                                //     ? Border.all(
                                //         color: DataUI.chedrauiColor,
                                //         width: 3,
                                //       )
                                //     : Border.all(
                                //         color: Colors.white,
                                //         width: 0,
                                //       ),
                              ),
                              child: Material(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                color: Colors.transparent,
                                child: InkResponse(
                                  containedInkWell: true,
                                  enableFeedback: true,
                                  onTap: () {
                                    _selectDeliveryAddress(addresses[index]);
                                  },
                                  splashColor: DataUI.chedrauiColor,
                                  child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 4.0),
                                                child: Text(
                                                  addresses[index]["firstName"].toString() + ' ' + addresses[index]["lastName"].toString(),
                                                  style: TextStyle(
                                                    fontFamily: 'Archivo',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                addresses[index]["formattedAddress"].toString(),
                                                style: TextStyle(
                                                  fontFamily: 'Archivo',
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: DataUI.textOpaque,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: <Widget>[
                                            IconButton(
                                              splashColor: DataUI.chedrauiColor,
                                              icon: Icon(
                                                Icons.edit_location,
                                                size: 34,
                                                color: DataUI.chedrauiColor,
                                              ),
                                              onPressed: () {
                                                _editAddress(addresses[index]);
                                              },
                                            ),
                                            IconButton(
                                              splashColor: DataUI.chedrauiColor,
                                              icon: Icon(
                                                Icons.delete,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                _showDeleteDialog(addresses[index]["id"]);
                                              },
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.white,
                          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                          child: Column(
                            children: <Widget>[
                              Center(
                                child: NoUbicaciones(),
                              ),
                              Center(
                                child: Text(
                                  'Agrega una direccion a tu cuenta presionando el boton de “Agregar Nueva Dirección."',
                                  style: TextStyle(color: HexColor('#454F5B'), fontFamily: 'Rubik', fontSize: 14),
                                ),
                              )
                            ],
                          ),
                        ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10),
                        child: FlatButton(
                          padding: EdgeInsets.all(15),
                          color: DataUI.btnbuy,
                          child: Text(
                            'Agregar Nueva Dirección',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                settings: RouteSettings(name: DataUI.deliveryMethodRoute),
                                builder: (context) => DeliveryMethodPage(
                                  showStores: false,
                                  showConfirmationForm: true,
                                  fromAddressBook: true,
                                ),
                              ),
                            );
                            if (result == 'direcciones') {
                              getAddressBoook();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }
}
