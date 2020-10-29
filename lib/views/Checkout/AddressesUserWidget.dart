import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/CuentaPage/EditAddressPage.dart';
import 'package:chd_app_demo/utils/addressData.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chd_app_demo/services/UserProfileServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/views/Checkout/AddDeliveryNotes.dart';
import 'package:chd_app_demo/views/DeliveryMethod/DeliveryMethodPage.dart';

class AddressesUserWidget extends StatefulWidget {
  final bool isPickUp;
  final Function callback;
  AddressesUserWidget({Key key, this.isPickUp, this.callback}) : super(key: key);

  _AddressesUserState createState() => _AddressesUserState();
}

class _AddressesUserState extends State<AddressesUserWidget> {
  bool isPickUp;
  SharedPreferences prefs;
  Future<dynamic> dataAddresses;
  List addresses;
  String currentAddressId;
  num totalAdress;
  num totalDisplay = 3;
  num remaining;
  bool addressChanged = false;

  Future<void> loadWidget({num pastTotalDisplay}) async {
    isPickUp = widget.isPickUp;
    prefs = await SharedPreferences.getInstance();
    dataAddresses = UserProfileServices.hybrisGetUserAddress().then((data) {
      setState(() {
        addresses = data['addresses'];
        totalDisplay = pastTotalDisplay ?? 
        (addresses.length < totalDisplay ? addresses.length : totalDisplay);
        currentAddressId = prefs.getString('delivery-address-id') ?? null;
        totalAdress = addresses.length;
        if (totalAdress > 3) {
          remaining = totalAdress - totalDisplay;
        } else {
          remaining = pastTotalDisplay != null ? totalAdress - pastTotalDisplay : 0 ;
        }
      });
      if(currentAddressId != null){
        try{
          var cuurAddr = addresses.firstWhere((a){
            return a['id'] == currentAddressId;
          });
          widget.callback(cuurAddr);
        } catch(e){
          widget.callback(null);
        }
      } else {
        widget.callback(null);
      }
    });
  }

  loadMore() {
    setState(() {
      remaining = 0;
      totalDisplay = addresses.length;
    });
  }

  @override
  void initState() {
    loadWidget();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: dataAddresses,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Container(child: Text("Error obteniendo las direcciones del usuario"));
            } else {
              return Container(
                  padding: EdgeInsets.only(left: 0, top: 5, bottom: 5, right: 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: Offset(2.0, 1.0),
                        blurRadius: 8.0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      !isPickUp
                          ? Column(children: <Widget>[
                              Divider(
                                color: Colors.grey,
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 25),
                                child: Row(
                                  children: <Widget>[
                                    Flexible(
                                      flex: 2,
                                      child: Icon(
                                        Icons.add,
                                        color: DataUI.chedrauiBlueColor,
                                      ),
                                    ),
                                    Flexible(
                                        flex: 4,
                                        child: FlatButton(
                                          padding: EdgeInsets.only(left: 23),
                                          textColor: DataUI.chedrauiBlueColor,
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
                                            if (result != null) {
                                              setState(() {
                                                dataAddresses = null;
                                              });
                                              await loadWidget(pastTotalDisplay: totalDisplay);
                                            }
                                          },
                                          child: Text(
                                            "Agregar nueva dirección",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Archivo',
                                            ),
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                              Divider(
                                color: Colors.grey,
                              ),
                              addresses != null
                                  ? ListView.separated(
                                      physics: ClampingScrollPhysics(),
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      separatorBuilder: (context, index) {
                                        return Divider(color: Colors.grey);
                                      },
                                      itemCount: addresses != null ? totalDisplay : 0,
                                      itemBuilder: (context, index) {
                                        return Column(
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Flexible(
                                                    flex: 4,
                                                    fit: FlexFit.tight,
                                                    child: RadioListTile<String>(
                                                      activeColor: Colors.black,
                                                      value: addresses[index]['id'],
                                                      onChanged: (newValue) {
                                                        if(!addressChanged){
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return AlertDialog(
                                                                title: Text("Cambio de dirección"),
                                                                content: Text("Si cambias tu dirección de entrega, algunos de tus productos podrían desaparecer de tu compra. ¿Deseas continuar?"),
                                                                actions: <Widget>[
                                                                  FlatButton(
                                                                    onPressed: () {
                                                                      Navigator.pop(context);
                                                                      setState(() {
                                                                        addressChanged = true;
                                                                        currentAddressId = newValue;
                                                                        widget.callback(addresses[index]);
                                                                      }); 
                                                                    },
                                                                    child: Text(
                                                                      "Continuar",
                                                                      style: TextStyle(
                                                                        color: DataUI.chedrauiBlueColor,
                                                                        fontSize: 16,
                                                                      ),
                                                                    ),
                                                                  ),
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
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        } else {
                                                          setState(() {
                                                            currentAddressId = newValue;
                                                            widget.callback(addresses[index]);
                                                          }); 
                                                        }
                                                      },
                                                      groupValue: currentAddressId,
                                                      title: Text(
                                                        "${addresses[index]['firstName']} ${addresses[index]['lastName']}\n${addresses[index]['formattedAddress']}",
                                                        style: TextStyle(color: HexColor('#454F5B'), fontSize: 12, fontFamily: 'Rubik', height: 1.2),
                                                      ),
                                                    )),
                                                Flexible(
                                                  flex: 1,
                                                  fit: FlexFit.tight,
                                                  child: FlatButton(
                                                    textColor: DataUI.chedrauiBlueColor,
                                                    onPressed: () async {
                                                      Address a = Address.fromJson(addresses[index]);
                                                      final result = await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          settings: RouteSettings(name: DataUI.deliveryMethodRoute),
                                                          builder: (context) => EditAddressPage(address: a),
                                                        ),
                                                      );
                                                      if (result != null) {
                                                        setState(() {
                                                          dataAddresses = null;
                                                        });
                                                        await loadWidget(pastTotalDisplay: totalDisplay);
                                                      }
                                                    },
                                                    child: Text(
                                                      "Editar",
                                                    ),
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        );
                                      },
                                    )
                                  : CircularProgressIndicator(),
                            ])
                          : SizedBox(
                              height: 0,
                            ),
                      Column(children: <Widget>[
                        Divider(
                          color: Colors.grey,
                        ),
                        remaining > 0 && !isPickUp
                            ? FlatButton(
                                onPressed: loadMore,
                                child: Text(
                                  'Cargar más Direcciones ($remaining)',
                                  style: TextStyle(fontFamily: 'Rubik', color: HexColor('#454F5B'), fontSize: 12, decoration: TextDecoration.underline),
                                ),
                              )
                            : SizedBox(),
                        FlatButton(
                          textColor: DataUI.chedrauiBlueColor,
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                settings: RouteSettings(name: DataUI.deliveryMethodRoute),
                                builder: (context) => AddDeliveryNotes(),
                              ),
                            );
                          },
                          child: Text("Agregar notas de entrega"),
                        )
                      ])
                    ],
                  ));
            }
            break;
          default:
            return Container(
                padding: EdgeInsets.only(left: 15, top: 20, bottom: 20, right: 15),
                decoration: BoxDecoration(color: Colors.white),
                child: Center(
                  child: CircularProgressIndicator(),
                ));
            break;
        }
      },
    );
  }
}
