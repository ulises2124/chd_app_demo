import 'package:chd_app_demo/services/GooglePlacesServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/DeliveryMethod/SelectedLocation.dart';
import 'package:chd_app_demo/views/DeliveryMethod/Tienda.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class PlacesSearchResults extends StatefulWidget {
  final Widget child;
  final TextEditingController searchBoxController;
  final LatLng userLating;
  final bool isPickup;
  final List<Tienda> tiendas;
  final Function setDeliveryAddress;
  final Function setPickUpAddress;

  PlacesSearchResults(
    this.setPickUpAddress,
    this.setDeliveryAddress, {
    Key key,
    this.child,
    this.searchBoxController,
    this.userLating,
    this.isPickup,
    this.tiendas,
  }) : super(key: key);

  @override
  PlacesSearchResultsState createState() => PlacesSearchResultsState();
}

class PlacesSearchResultsState extends State<PlacesSearchResults> with TickerProviderStateMixin {
  List response;
  List<Tienda> storesResults;
  String query = '';
  SelectedLocation selectedAddress = SelectedLocation();
  Tienda selectedStore = Tienda();
  bool switchSearch = false;

  @override
  void initState() {
    super.initState();
    switchSearch = widget.isPickup;
  }

  @override
  void dispose() {
    super.dispose();
  }

  doSearch(_isPickUp) async {
    query = widget.searchBoxController.text.replaceAll(' ', '+').replaceAll('#', '');
    setState(() {
      switchSearch = _isPickUp;
      response = null;
    });
    try {
      if (switchSearch) {
        await LocationServices.getHybrisStoresByText(query, widget.userLating.latitude, widget.userLating.longitude).then((res) {
          if (res != null) {
            setState(() {
              var data = res['stores'] as List;
              storesResults = data.map((index) => Tienda.fromJson(index)).toList();
            });
          }
        });
      } else {
        await LocationServices.getPlacesBySearch(
          query,
          widget.userLating.latitude,
          widget.userLating.longitude,
        ).then((res) {
          if (res != null) {
            setState(() {
              response = res['candidates'];
            });
          }
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return switchSearch
        ? Container(
            margin: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
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
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Text(
                    'Tiendas cercanas a tu ubicacion:',
                    style: TextStyle(fontSize: 14, fontFamily: 'Archivo', color: HexColor('#0D47A1'), fontWeight: FontWeight.bold, letterSpacing: 0.25),
                  ),
                ),
                ConstrainedBox(
                  constraints: new BoxConstraints(
                    maxHeight: 320,
                  ),
                  child: Scrollbar(
                    child: storesResults == null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(value: null),
                            ),
                          )
                        : storesResults.length == 0
                            ? ListTile(
                                title: Text('Sin resultados'),
                              )
                            : ListView.separated(
                                separatorBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.symmetric(vertical: 15),
                                    color: HexColor('#D8D8D8'),
                                    height: 1,
                                    width: double.infinity,
                                  );
                                },
                                shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(), // new
                                itemCount: storesResults == null ? 0 : storesResults.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    onTap: () {
                                      selectedStore = storesResults[index];
                                      widget.setPickUpAddress(selectedStore, true);
                                    },
                                    title: Text(
                                      storesResults[index].displayName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 14, color: HexColor('#454F5B'), fontFamily: 'Archivo', fontWeight: FontWeight.bold, letterSpacing: 0.25),
                                    ),
                                    subtitle: Text(
                                      storesResults[index].formattedAddress,
                                      maxLines: 4,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Archivo',
                                        color: HexColor('#444444'),
                                      ),
                                    ),
                                    leading: Icon(Icons.location_on, color: HexColor('#F57C00')),
                                    // leading: IconButton(
                                    //   onPressed: () {
                                    //     selectedAddress = response[index];
                                    //     print(selectedAddress.toString());
                                    //   },
                                    //   icon: Icon(Icons.location_on),
                                  );
                                },
                              ),
                  ),
                ),
              ],
            ),
          )
        : Container(
            margin: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.white,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Color(0xcc000000).withOpacity(0.2),
                  offset: Offset(0.0, 5.0),
                  blurRadius: 10.0,
                ),
              ],
            ),
            child: response == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(value: null),
                    ),
                  )
                : response.length == 0
                    ? ListTile(
                        title: Text('Sin resultados'),
                      )
                    : ListView.separated(
                        separatorBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 15),
                            color: HexColor('#D8D8D8'),
                            height: 1,
                            width: double.infinity,
                          );
                        },
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: response == null ? 0 : response.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () {
                              selectedAddress.placeId = response[index]['place_id'];
                              selectedAddress.name = response[index]['name'];
                              selectedAddress.formattedAddress = response[index]['formatted_address'];
                              selectedAddress.lat = response[index]['geometry']['location']['lat'];
                              selectedAddress.lng = response[index]['geometry']['location']['lng'];
                              widget.setDeliveryAddress(selectedAddress);
                            },
                            title: Text(
                              response[index]['name'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14, color: HexColor('#454F5B'), fontFamily: 'Archivo', fontWeight: FontWeight.bold, letterSpacing: 0.25),
                            ),
                            subtitle: Text(
                              response[index]['formatted_address'],
                              maxLines: 4,
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Archivo',
                                color: HexColor('#444444'),
                              ),
                            ),
                            leading: Icon(Icons.location_on, color: HexColor('#F57C00')),
                            // leading: IconButton(
                            //   onPressed: () {
                            //     selectedAddress = response[index];
                            //     print(selectedAddress.toString());
                            //   },
                            //   icon: Icon(Icons.location_on),
                          );
                        },
                      ),
          );
  }
}
