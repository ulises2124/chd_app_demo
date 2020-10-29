import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/Errors/NetworkErrorPage/NetworkErrorPage.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
// PLUGINS
import 'package:rubber/rubber.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vector_math/vector_math.dart' as VectorMath;
// COMPONENTS
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/addressData.dart';
import 'package:chd_app_demo/services/GooglePlacesServices.dart';
import 'package:chd_app_demo/services/UserProfileServices.dart';
import 'package:chd_app_demo/services/CarritoServices.dart';
import 'package:chd_app_demo/views/DeliveryMethod/ConfirmAddressPage.dart';
import 'package:chd_app_demo/views/DeliveryMethod/PlacesSearchResult.dart';
import 'package:chd_app_demo/views/DeliveryMethod/SearchPlacesBar.dart';
import 'package:chd_app_demo/views/DeliveryMethod/SelectedLocation.dart';
import 'package:chd_app_demo/views/DeliveryMethod/Tienda.dart';
import 'package:chd_app_demo/views/DeliveryMethod/ToggleDeliveryButton.dart';
// REDUX
import 'package:chd_app_demo/redux/models/AppState.dart';
import 'package:chd_app_demo/redux/actions/LocationActions.dart';
import 'package:flutter_redux/flutter_redux.dart';

class DeliveryMethodPage extends StatefulWidget {
  final bool showStores;
  final bool showConfirmationForm;
  final bool fromAddressBook;

  DeliveryMethodPage({
    Key key,
    @required this.showStores,
    @required this.showConfirmationForm,
    this.fromAddressBook = false,
  }) : super(key: key);

  @override
  State<DeliveryMethodPage> createState() => DeliveryMethodPageState();
}

class DeliveryMethodPageState extends State<DeliveryMethodPage> with TickerProviderStateMixin {
  GlobalKey<PlacesSearchResultsState> searchPlacesKey;
  GlobalKey<SearchPlacesBarState> searchPlacesBarKey;
  BitmapDescriptor pinLocationIcon;
  BitmapDescriptor pinLocationIconStores;
  RubberAnimationController _bottomSheetController;
  ScrollController _scrollController = ScrollController();

  SharedPreferences prefs;

  Completer<GoogleMapController> _controller = Completer();
  double _zoom = 17;

  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  MarkerId currentMarker = MarkerId('currentLocationMarker');

  LatLng _userLating;
  LatLng _currentUserLating;
  LatLng _nearesStore;
  LatLng _defaultLocation = LatLng(19.43733, -99.1407335);

  bool _hasLocationAccess = false;
  bool _isLoggedIn = false;
  bool _isSearching = false;
  bool _isPickUp = false;
  bool _locationSet = false;
  bool _isLocationsSaved = false;
  bool _isStoreSeleted = false;
  bool _resultBoxVisible = false;
  bool _showSavedLocation = false;
  bool _savedDelivery = false;
  bool _isReversegeocoding = true;
  bool _addressNotValid = false;

  bool isLoading = false;

  int _itemsAmount = 0;

  final searchBoxController = TextEditingController();
  String errorMessage;
  String _title = '';
  CameraPosition _center = CameraPosition(
    target: LatLng(19.4336523, -99.1454316),
    zoom: 15,
  );

  SelectedLocation selectedAddress = SelectedLocation();
  SelectedLocation retrivedAddress = SelectedLocation();

  List<Tienda> tiendas;
  Tienda selectedStore;

  List addresses;
  bool _isUpdatingAddresses = false;
  Address selectedAddressFromBook = Address();

  PermissionStatus _permissionsStatus;

  var loading = false;

  Future tiendasResponse;
  Future getPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

////////////////////////////////////////// WIDGET BUILD /x///////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);
    _isLoggedIn = store.state.isSessionActive;
    _itemsAmount = store.state.shoppingCartQuantity;
    return WidgetContainer(
      WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
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
            actions: <Widget>[
              //  IconButton(
              //   icon: Icon(Icons.create),
              //   onPressed: () {},
              // ),
            ],
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
            elevation: 1,
            title: Text("Elige una tienda", style: TextStyle(color: Colors.white, fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 19)),
            centerTitle: true,
            // toolbarOpacity: 0.0,
          ),
          resizeToAvoidBottomPadding: false,
          body: FutureBuilder(
            future: tiendasResponse,
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
                    return Stack(
                      children: <Widget>[
                        GoogleMap(
                          onTap: (_position) {
                            if (!_isPickUp) {
                              _handleTap(_position);
                            }
                          },
                          markers: Set<Marker>.of(_markers.values),
                          mapType: MapType.normal,
                          initialCameraPosition: _center,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          onCameraMove: ((_position) {}),
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                        ),
                        Positioned(
                          child: Align(
                            alignment: FractionalOffset.bottomCenter,
                            child: Container(
                              child: RubberBottomSheet(
                                animationController: _bottomSheetController,
                                scrollController: _scrollController,
                                headerHeight: 20,
                                header: _getHeaderLayer(),
                                lowerLayer: _getLowerLayer(),
                                upperLayer: _getUpperLayer(),
                                menuLayer: _getMenuLayer(),
                              ),
                            ),
                          ),
                        ),
                        SafeArea(
                          child: Column(
                            children: <Widget>[
                              Stack(
                                children: <Widget>[
                                  tiendas != null && !widget.showConfirmationForm && !widget.showStores
                                      ? ToggleDelivery(
                                          _toggleDelivery,
                                          isPickup: _isPickUp,
                                        )
                                      : SizedBox(height: 0),
                                  tiendas != null
                                      ? SearchPlacesBar(
                                          activateSearching,
                                          activateSearchingManual,
                                          _getCurrentLocation,
                                          searchBoxController: searchBoxController,
                                          key: searchPlacesBarKey,
                                        )
                                      : SizedBox(height: 0),
                                ],
                              ),
                              AnimatedCrossFade(
                                crossFadeState: _isSearching && _resultBoxVisible ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                sizeCurve: Curves.easeInOut,
                                duration: const Duration(milliseconds: 280),
                                firstChild: PlacesSearchResults(
                                  setPickUpAddress,
                                  setDeliveryAddress,
                                  key: searchPlacesKey,
                                  searchBoxController: searchBoxController,
                                  userLating: _currentUserLating,
                                  isPickup: _isPickUp,
                                  tiendas: tiendas,
                                ),
                                secondChild: SizedBox(height: 0),
                              ),
                            ],
                          ),
                        ),
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
          ),
        ),
      ),
    );
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///                                   INITIAL CONFIG
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  @override
  void initState() {
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 3.0), 'assets/storeMarker.png').then((onValue) {
      pinLocationIconStores = onValue;
    }).catchError((onError) {
      print(onError);
    });
    ;
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 3.0), 'assets/locationSet.png').then((onValue) {
      pinLocationIcon = onValue;
    }).catchError((onError) {
      print(onError);
    });

    searchPlacesKey = GlobalKey();
    searchPlacesBarKey = GlobalKey();
    _bottomSheetController = RubberAnimationController(
      vsync: this,
      upperBoundValue: AnimationControllerValue(percentage: 0.7),
      halfBoundValue: AnimationControllerValue(percentage: 0.5),
      duration: Duration(milliseconds: 200),
      springDescription: SpringDescription.withDampingRatio(
        mass: 1,
        stiffness: Stiffness.MEDIUM,
        ratio: DampingRatio.MEDIUM_BOUNCY,
      ),
    );
    super.initState();
    getPreferences().then((x) {
      setState(() {
        // prefs.clear();
        _savedDelivery = prefs.getBool('isPickUp') ?? false;
        if (widget.fromAddressBook)
          _isPickUp = false;
        else
          _isPickUp = _savedDelivery;
        _isLocationsSaved = prefs.getBool('isLocationSet') ?? false;
        _showSavedLocation = _isLocationsSaved;
        _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      });
      getAddressBoook();
      _listenForPermissionStatus();
      // get chedraui stores at init to avoid bad UX
      if (!widget.showStores) {
        _loadStores();
      }
      if (_savedDelivery) {
        _displayStores();
      }
    });
  }

  void _setupInitialLocation() async {
    if (_hasLocationAccess) {
      _currentUserLating = await getUserLocation();
    } else {
      _currentUserLating = _defaultLocation;
    }
    try {
      // set marker on saved delivery location
      if (widget.showStores) {
        setState(() {
          _isPickUp = true;
        });
        initializeMap(_currentUserLating, 12);
        _loadStores().then((x) {
          _displayStores();
        });
      } else {
        // get or set delivery preferences if set
        if (_isLocationsSaved && !widget.showConfirmationForm) {
          var lat = prefs.getDouble('store-lat');
          var lng = prefs.getDouble('store-lng');
          if (_isPickUp && lat != null && lng != null) {
            initializeMap(LatLng(prefs.getDouble('store-lat'), prefs.getDouble('store-lng')), _zoom);
          } else {
            initializeMap(LatLng(prefs.getDouble('delivery-lat') ?? _currentUserLating.latitude, prefs.getDouble('delivery-lng') ?? _currentUserLating.longitude), _zoom);
          }
        } else {
          // set marker on current user location
          setState(() {
            isLoading = true;
            _locationSet = true;
            selectedAddress.lat = _currentUserLating.latitude;
            selectedAddress.lng = _currentUserLating.longitude;
          });
          initializeMap(_currentUserLating, _zoom);
          _doReverseGeocoding();
        }
      }
    } catch (e) {
      // Navigator.of(context).pop();
      Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
    }
  }

  void initializeMap(LatLng latlng, double zoom) async {
    setState(() {
      _markers[currentMarker] = Marker(
        markerId: MarkerId(latlng.toString()),
        position: latlng,
        alpha: 1,
        icon: _isPickUp ? pinLocationIcon : pinLocationIcon,
      );
      _center = new CameraPosition(
        target: latlng,
        zoom: widget.showStores ? 12 : 17,
      );
    });
    final GoogleMapController controller = await _controller.future;
    controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latlng, zoom: _zoom),
      ),
    );
  }

  @override
  void dispose() {
    _markers.clear();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return Future.value(true);
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///                                   LOCATION PERMISSIONS & SETUP
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  void _listenForPermissionStatus() {
    PermissionHandler().checkPermissionStatus(PermissionGroup.locationWhenInUse).then(_updatePermissions);
  }

  void _onPermissionStatusRequested(Map<PermissionGroup, PermissionStatus> statuses) {
    final status = statuses[PermissionGroup.locationWhenInUse];
    if (status != PermissionStatus.granted) {
      if (Platform.isIOS) {
        _showLocationDialog();
      }
    } else {
      _updatePermissions(status);
    }
  }

  Future _updatePermissions(PermissionStatus status) async {
    if (mounted) {
      setState(() {
        _permissionsStatus = status;
        _hasLocationAccess = _permissionsStatus == PermissionStatus.granted ? true : false;
        print('location ' + _hasLocationAccess.toString());
      });
      if (!_hasLocationAccess) {
        _askLocationPermission();
      } else {
        _currentUserLating = await getUserLocation();
      }
      _setupInitialLocation();
    }
  }

  void _askLocationPermission() {
    PermissionHandler().requestPermissions([PermissionGroup.locationWhenInUse]).then(_onPermissionStatusRequested);
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///                                   LOCATION AND GEOCADING CONFIGURATION
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  // set and face camera position to user current location
  Future<bool> _getCurrentLocation() async {
    try {
      final center = await getUserLocation();
      final GoogleMapController controller = await _controller.future;
      controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: center, zoom: _zoom),
        ),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

// Initialize first google maps camera with user curret location
  Future<LatLng> getUserLocation() async {
    LocationManager.LocationData currentLocation;
    final location = LocationManager.Location();
    try {
      currentLocation = await location.getLocation();
      final lat = currentLocation.latitude;
      final lng = currentLocation.longitude;
      final center = LatLng(lat, lng);
      return center;
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        _askLocationPermission();
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        _askLocationPermission();
      } else {
        _askLocationPermission();
      }
      return _defaultLocation;
    }
  }

// update address data when user changes marker position
  void _doReverseGeocoding() async {
    try {
      await LocationServices.getReverseGeocoding(
        _markers[currentMarker].position.latitude,
        _markers[currentMarker].position.longitude,
      ).then((res) {
        if (res != null) {
          setState(() {
            _isReversegeocoding = true;
            List addressComponents = res['results'][0]['address_components'];
            _extractAdderssComponents(addressComponents);
            if (selectedAddress.codigoPostal == null || selectedAddress.codigoPostal.trim().length == 0) {
              setState(() {
                _addressNotValid = true;
              });
              // _showMessageDialog("No es una ubicación válida");
            } else {
              setState(() {
                _addressNotValid = false;
              });
              selectedAddress.name = '';
              selectedAddress.lat = res['results'][0]['geometry']['location']['lat'];
              selectedAddress.lng = res['results'][0]['geometry']['location']['lng'];
              selectedAddress.formattedAddress = res['results'][0]['formatted_address'];
            }
            isLoading = false;
          });
        }
      });
    } catch (e) {
      // print(e.toString());
    }
  }

  void _extractAdderssComponents(List addressComponents) {
    for (var component in addressComponents) {
      // print(component['types'].toString());
      if (component['types'].toString().contains('street_number')) {
        selectedAddress.streetNumber = component['long_name'];
        // print('numero');
        // print(component['types']);
        // print(component['long_name']);
      } else if (component['types'].toString().contains('route')) {
        selectedAddress.route = component['long_name'];
        // print('calle');
        // print(component['types']);
        // print(component['long_name']);
      } else if (component['types'].toString().contains('sublocality')) {
        selectedAddress.sublocality = component['long_name'];
        // print('sub colonia');
        // print(component['types']);
        // print(component['long_name']);
      } else if (component['types'].toString().contains('locality')) {
        selectedAddress.locality = component['long_name'];
        // print('colonia');
        // print(component['types']);
        // print(component['long_name']);
      } else if (component['types'].toString().contains('administrative_area_level_1')) {
        selectedAddress.estado = component['long_name'];
        selectedAddress.isocode = getEstadoIsoCode(selectedAddress.estado);
        // print('estado');
        // print(component['types']);
        // print(component['long_name']);
      } else if (component['types'].toString().contains('postal_code')) {
        selectedAddress.codigoPostal = component['long_name'];
        // print('codigo postal');
        // print(component['types']);
        // print(component['long_name']);
      }
    }
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///                                   HANDLING USER MAP INTERACTION
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  Future<void> _confirmDeliveryAddressDialog(bool isLocationSet, bool isPickup) async {
    if (isLocationSet) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Icon(
                Icons.warning,
                size: 52,
                color: DataUI.chedrauiColor,
              ),
            ),
            content: Text(
              'Si cambias tu dirección de entrega, algunos de tus productos podrían desaparecer de tu compra. ¿Deseas continuar?',
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
                    Navigator.of(context).pop();
                    return false;
                  },
                  child: Text(
                    "Cancelar",
                    style: TextStyle(
                      color: DataUI.chedrauiBlueColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FlatButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _confirmDeliveryAddress(isPickup);
                  },
                  child: Text(
                    "Aceptar",
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
    } else {
      await _confirmDeliveryAddress(isPickup);
    }
  }

// Confirm delivery address
  Future<void> _confirmDeliveryAddress(isPickup) async {
    setState(() {
      isLoading = true;
    });
    if (isPickup) {
      _storePickupData();
    } else {
      if (_isReversegeocoding) {
        _storeDeliveryData();
      } else {
        try {
          await LocationServices.getPlacesByIdSearch(selectedAddress.placeId).then((res) {
            if (res != null) {
              List addressComponents = res['result']['address_components'];
              _extractAdderssComponents(addressComponents);
              if (selectedAddress.codigoPostal == null || selectedAddress.codigoPostal.trim().length == 0) {
                setState(() {
                  _addressNotValid = true;
                  isLoading = false;
                });
              } else {
                _storeDeliveryData();
              }
            }
          });
        } catch (e) {
          print(e.toString());
        }
      }
    }
  }

// set delivery address data and face google maps camera to selected location
  Future<void> setDeliveryAddress(SelectedLocation location) async {
    FocusScope.of(context).requestFocus(new FocusNode());
    activateSearching(false);
    final Marker updatedMarker = _markers[currentMarker];
    setState(() {
      _addressNotValid = false;
      _isReversegeocoding = false;
      _showSavedLocation = false;
      _resultBoxVisible = false;
      selectedAddress.route = '';
      selectedAddress.streetNumber = '';
      selectedAddress.sublocality = '';
      selectedAddress.locality = '';
      selectedAddress.estado = '';
      selectedAddress.isocode = '';
      selectedAddress.codigoPostal = '';
      selectedAddress = location;
      _locationSet = true;
      _markers[currentMarker] = updatedMarker.copyWith(
        alphaParam: 1,
        positionParam: LatLng(
          selectedAddress.lat,
          selectedAddress.lng,
        ),
        infoWindowParam: InfoWindow(
          title: selectedAddress.name,
          snippet: selectedAddress.formattedAddress,
        ),
      );
    });
    final GoogleMapController controller = await _controller.future;
    controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            selectedAddress.lat,
            selectedAddress.lng,
          ),
          zoom: _zoom,
        ),
      ),
    );
  }

// set pickup data and face google maps camera to selected chedraui store
  Future<void> setPickUpAddress(Tienda tiendaSelected, bool setMarker) async {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _showSavedLocation = false;
      _resultBoxVisible = false;
      _isStoreSeleted = true;
      selectedStore = tiendaSelected;
    });
    // print(selectedStore.toString());
    final GoogleMapController controller = await _controller.future;
    controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          // tilt: 50,
          target: LatLng(tiendaSelected.latitude, tiendaSelected.longitude),
          zoom: 17,
        ),
      ),
    );
    if (setMarker) {
      searchPlacesBarKey.currentState.unSetLocation();
      final Marker updatedMarker = _markers[currentMarker];
      setState(() {
        _markers[currentMarker] = updatedMarker.copyWith(
          iconParam: pinLocationIconStores,
          positionParam: LatLng(tiendaSelected.latitude, tiendaSelected.longitude),
        );
      });
    }
  }

  void _handleTap(LatLng _position) {
    activateSearching(false);
    searchPlacesBarKey.currentState.unSetLocation();
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      isLoading = true;
      _resultBoxVisible = false;
      _showSavedLocation = false;
      _locationSet = true;
      selectedAddress.placeId = '';
      selectedAddress.route = '';
      selectedAddress.streetNumber = '';
      selectedAddress.sublocality = '';
      selectedAddress.locality = '';
      selectedAddress.estado = '';
      selectedAddress.isocode = '';
      selectedAddress.codigoPostal = '';
      selectedAddress.lat = _position.latitude;
      selectedAddress.lng = _position.longitude;
      _markers[currentMarker] = Marker(
        markerId: MarkerId(_position.toString()),
        position: _position,
        alpha: 1,
        icon: pinLocationIcon,
      );
    });
    _doReverseGeocoding();
  }

// removes user selected address
  void _unsetAddress() {
    bool isPickUp = prefs.getBool('isPickUp') ?? false;
    if (isPickUp) {
      prefs.remove('store-id');
      prefs.remove('store-displayName');
      prefs.remove('store-formattedAddress');
      prefs.remove('store-name');
      prefs.remove('store-lat');
      prefs.remove('store-lng');
    } else {
      prefs.remove('delivery-direccion');
      prefs.remove('delivery-streetNumber');
      prefs.remove('delivery-numInterior');
      prefs.remove('delivery-estado');
      prefs.remove('delivery-isocode');
      prefs.remove('delivery-locality');
      prefs.remove('delivery-sublocality');
      prefs.remove('delivery-codigoPostal');
      prefs.remove('delivery-deliveryNote');
      //prefs.remove('delivery-telefono');
      prefs.remove('delivery-route');
      prefs.remove('delivery-locationName');
      prefs.remove('delivery-formatted_address');
      prefs.remove('delivery-lat');
      prefs.remove('delivery-lng');
    }
    prefs.remove('delivery-address-id');
    prefs.remove('isPickUp');
    prefs.setBool('isLocationSet', false);

    selectedAddress = new SelectedLocation();
    selectedAddress.isLocationSet = false;

    final store = StoreProvider.of<AppState>(context);
    store.dispatch(SetCurrentLocationAction(selectedAddress));
    Navigator.of(context).pop();
  }

// opens the native map app tracing a route to the selected store
  void _launchMapsRouteUrl() async {
    LatLng currentGeo = await getUserLocation();
    String lat = currentGeo.latitude.toString();
    String lng = currentGeo.longitude.toString();
    String storeLat = selectedStore.latitude.toString();
    String storeLng = selectedStore.longitude.toString();

    if (Platform.isAndroid) {
      String googleUrl = 'https://www.google.com/maps/dir/$lat,$lng/$storeLat,$storeLng';
      if (await canLaunch(googleUrl)) {
        await launch(googleUrl);
      } else {
        // throw 'Could not open the map.';
      }
    } else if (Platform.isIOS) {
      String url = "http://maps.apple.com/maps?saddr=$lat,$lng&daddr=$storeLat,$storeLng&dirflg=d";
      if (await canLaunch(url)) {
        launch(url);
      } else {
        // error in launching map
      }
    }
  }

// // handles on camera move evet to update tu marker position
//   Future _updateMarker(CameraPosition _position) async {
//     searchPlacesBarKey.currentState.unSetLocation();
//     final Marker updatedMarker = _markers[currentMarker];
//     setState(() {
//       selectedAddress.lat = _position.target.latitude;
//       selectedAddress.lng = _position.target.longitude;
//       _markers[currentMarker] = updatedMarker.copyWith(
//         positionParam: LatLng(_position.target.latitude, _position.target.longitude),
//       );
//     });
//   }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///                                   SAVING USER PREFERENCES
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  Future<void> _setNewAddressToCart() async {
    var resultNewAddress = await CarritoServices.setDeliveryModeCart();

    if (resultNewAddress != null && resultNewAddress['cartModifications'] != null) {
      if (resultNewAddress['cartModifications'].length > 0) {
        List<String> modifiedProducts = [];
        for (var mod in resultNewAddress['cartModifications']) {
          if (mod['statusCode'] != "success") {
            print(mod['entry']['product']['name']);
            modifiedProducts.add(mod['entry']['product']['name']);
          }
        }
        setState(() {
          isLoading = false;
        });

        if (modifiedProducts.length > 0) {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return WillPopScope(
                    child: AlertDialog(
                      title: Text("Cambio de dirección"),
                      content: Text("Algunos artículos se modificaron debido al cambio de dirección:\n\n" + modifiedProducts.join('\n')),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
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
                    ),
                    onWillPop: () {});
              });
        } else {
          setState(() {
            loading = false;
          });
          Navigator.pop(context);
        }
      } else {
        setState(() {
          loading = false;
        });
        Navigator.pop(context);
      }
    }
  }

  void _storeDeliveryData() async {
    String mergeAddress = selectedAddress.route.length > 0 ? selectedAddress.route + ' ' : '';
    mergeAddress += selectedAddress.streetNumber.length > 0 ? selectedAddress.streetNumber + ' ' : '';
    mergeAddress += (selectedAddress.sublocality.length > 0 ? selectedAddress.sublocality : '');

    selectedAddress.isPickup = false;
    selectedAddress.isLocationSet = true;
    selectedAddress.formattedAddress = mergeAddress;
    selectedAddress.direccion = "${selectedAddress.route ?? ""} ${selectedAddress.streetNumber ?? ""}";

    prefs.setBool('isLocationSet', true);
    prefs.setBool('isPickUp', false);
    prefs.setString('delivery-direccion', selectedAddress.direccion);
    prefs.setString('delivery-streetNumber', selectedAddress.streetNumber);
    prefs.setString('delivery-numInterior', selectedAddress.numInterior);
    prefs.setString('delivery-estado', selectedAddress.estado);
    prefs.setString('delivery-isocode', selectedAddress.isocode);
    prefs.setString('delivery-locality', selectedAddress.locality);
    prefs.setString('delivery-sublocality', selectedAddress.sublocality);
    prefs.setString('delivery-codigoPostal', selectedAddress.codigoPostal);
    prefs.setString('delivery-deliveryNote', selectedAddress.deliveryNote);
    prefs.setString('delivery-route', selectedAddress.route);
    prefs.setString('delivery-locationName', selectedAddress.name);
    prefs.setString('delivery-formatted_address', selectedAddress.formattedAddress);
    prefs.setDouble('delivery-lat', selectedAddress.lat);
    prefs.setDouble('delivery-lng', selectedAddress.lng);
    //prefs.setBool("cart-address-update", true);
    prefs.remove('delivery-address-id');

    if (_isLoggedIn) {
      await _setNewAddressToCart();
    } else {
      Navigator.pop(context);
    }

    final store = StoreProvider.of<AppState>(context);
    store.dispatch(SetCurrentLocationAction(selectedAddress));

    if (widget.showConfirmationForm) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: DataUI.confirmAddressRoute),
          builder: (context) => ConfirmAddressPage(completeAddress: selectedAddress),
        ),
      );
      print(result);
      if (result == 'direcciones') {
        Navigator.pop(context, result);
      } else {
        Navigator.pop(context, result);
      }
    } else {
      //Navigator.of(context).pop();
    }

    // print('stored data: ');
    // print('isLocationSet :' + prefs.getBool('isLocationSet').toString());
    // print('userName :' + prefs.getString('delivery-userName').toString());
    // print('userLastName :' + prefs.getString('delivery-userLastName').toString());
    // print('userSecondLastName :' + prefs.getString('delivery-userSecondLastName').toString());
    // print('direccion :' + prefs.getString('delivery-direccion').toString());
    // print('streetNumber :' + prefs.getString('delivery-streetNumber').toString());
    // print('numInterior :' + prefs.getString('delivery-numInterior').toString());
    // print('estado :' + prefs.getString('delivery-estado').toString());
    // print('isocode :' + prefs.getString('delivery-isocode').toString());
    // print('locality :' + prefs.getString('delivery-locality').toString());
    // print('codigoPostal :' + prefs.getString('delivery-codigoPostal').toString());
    // print('deliveryNote :' + prefs.getString('delivery-deliveryNote').toString());
    // print('route :' + prefs.getString('delivery-route').toString());
    // print('locationName :' + prefs.getString('delivery-locationName').toString());
    // print('codigoPostal :' + prefs.getString('delivery-codigoPostal').toString());
    // print('formatted_address :' + prefs.getString('delivery-formatted_address').toString());
    // print('lat :' + prefs.getDouble('delivery-lat').toString());
    // print('lng :' + prefs.getDouble('delivery-lng').toString());
  }

  void _storePickupData() async {
    try {
      selectedAddress = SelectedLocation();
      selectedAddress.isLocationSet = true;
      selectedAddress.isPickup = true;
      selectedAddress.storeId = selectedStore.id;
      selectedAddress.storeDisplayName = selectedStore.displayName;
      selectedAddress.formattedAddress = selectedStore.formattedAddress;
      selectedAddress.storeName = selectedStore.name;
      selectedAddress.lat = selectedStore.latitude;
      selectedAddress.lng = selectedStore.longitude;

      prefs.setBool('isLocationSet', true);
      prefs.setBool('isPickUp', true);
      prefs.setString('store-id', selectedStore.id);
      prefs.setString('store-displayName', selectedStore.displayName);
      prefs.setString('store-formattedAddress', selectedStore.formattedAddress);
      prefs.setString('store-name', selectedStore.name);
      prefs.setDouble('store-lat', selectedStore.latitude);
      prefs.setDouble('store-lng', selectedStore.longitude);
      prefs.remove('delivery-address-id');
      //prefs.setBool("cart-address-update", true);

      if (_isLoggedIn) {
        await _setNewAddressToCart();
      } else {
        Navigator.pop(context);
      }

      final store = StoreProvider.of<AppState>(context);
      store.dispatch(SetCurrentLocationAction(selectedAddress));
      //Navigator.of(context).pop();
      // print('stored data: ');
      // print(prefs.getBool('isLocationSet').toString());
      // print(prefs.getBool('isPickUp').toString());
      // print(prefs.getString('store-id'));
      // print(prefs.getString('store-displayName'));
      // print(prefs.getString('store-formattedAddress'));
      // print(prefs.getString('store-name'));
      // print(prefs.getDouble('store-lat').toString());
      // print(prefs.getDouble('store-lng').toString());

    } catch (e) {
      print(e.toString());
    }
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///                                   HEADER UI (textbox & tabs) LOGIC
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// CRITICAL: Throws and switch search method
  void _toggleDelivery(bool isPickup) async {
    // await prefs.setBool('isPickUp', isPickup);
    setState(() {
      // _isSearching = true;
      _resultBoxVisible = true;
      _isPickUp = isPickup;
    });
    if (_isSearching) {
      // Trigger search method
      searchPlacesKey.currentState.doSearch(_isPickUp);
    }
    if (_isPickUp) {
      // Set chedraui stores markers
      _displayStores();
      // //  google map camera zoom out
      final GoogleMapController controller = await _controller.future;
      controller.moveCamera(
        CameraUpdate.newCameraPosition(
          //CameraPosition(target: _currentUserLating, zoom: 12),
          CameraPosition(target: _nearesStore, zoom: 12),
        ),
      );
    } else {
      // remove chedraui stores markers
      _bottomSheetController.reset();
      setState(() {
        _markers.clear();
        _markers[currentMarker] = Marker(
          markerId: MarkerId(_currentUserLating.toString()),
          position: _currentUserLating,
          alpha: 1,
          icon: pinLocationIcon,
        );
      });
      final GoogleMapController controller = await _controller.future;
      controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentUserLating, zoom: 17),
        ),
      );
    }
  }

// Listener for searchbox input
  void activateSearching(bool isSearching) {
    setState(() {
      _isSearching = isSearching;
      _resultBoxVisible = true;
    });
    if (_isSearching) {
      searchPlacesKey.currentState.doSearch(_isPickUp);
    }
  }

// Listener for search iconbutton
  void activateSearchingManual() {
    setState(() {
      _isSearching = !_isSearching;
    });
    if (!_isSearching) {
      FocusScope.of(context).requestFocus(new FocusNode());
    }
  }

// Load `tiendas` list object with hybris endpoint
  Future _loadStores() async {
    tiendasResponse = _loadStoresFuture();
  }

  _loadStoresFuture() async {
    try {
      final store = StoreProvider.of<AppState>(context);
      final tiendasTemp = store.state.tiendas;
      if (tiendasTemp == null) {
        await LocationServices.getHybrisStores().then((res) {
          if (res != null) {
            if (mounted) {
              setState(() {
                final data = res['stores'] as List;
                tiendas = data.map((index) => Tienda.fromJson(index)).toList();
                store.dispatch(AddTiendasAction(tiendas));
              });
            }
          }
        });
      } else {
        tiendas = store.state.tiendas;
      }
    } catch (e) {
      // print(e.toString());
    }
    return tiendas;
  }

  double getDistanceToCurrentLocation(LatLng coords) {
    if (_currentUserLating == null) {
      return 1e100;
    }
    final double r = 6371e3;
    double theta1 = VectorMath.radians(coords.latitude);
    double theta2 = VectorMath.radians(_currentUserLating.latitude);
    double deltaTheta = VectorMath.radians(coords.latitude - _currentUserLating.latitude);
    double deltaLambda = VectorMath.radians(coords.longitude - _currentUserLating.longitude);

    double a = sin(deltaTheta / 2) * sin(deltaTheta / 2) + cos(theta1) * cos(theta2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return r * c;
  }

  void _displayStores() {
    setState(() {
      isLoading = true;
    });
    LatLng _nearesStoreAux;
    _nearesStore = new LatLng(0, 0);
    for (var tienda in tiendas) {
      MarkerId storeId = MarkerId(tienda.displayName ?? '');
      Marker mark = Marker(
        markerId: storeId ?? '',
        position: LatLng(
          tienda.latitude ?? 0.0,
          tienda.longitude ?? 0.0,
        ),
        alpha: 1,
        icon: pinLocationIconStores,
        infoWindow: InfoWindow(
          title: tienda.displayName ?? '',
          snippet: tienda.formattedAddress ?? '',
        ),
        onTap: () {
          setPickUpAddress(tienda, false);
        },
      );
      _nearesStoreAux = new LatLng(tienda.latitude, tienda.longitude);
      if (getDistanceToCurrentLocation(_nearesStoreAux) < getDistanceToCurrentLocation(_nearesStore)) {
        _nearesStore = _nearesStoreAux;
      }
      setState(() {
        _markers[storeId] = mark;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///                                   DIALOG BOXES
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Icon(
              Icons.location_on,
              size: 52,
              color: DataUI.chedrauiColor,
            ),
          ),
          content: Text(
            'Por favor habilita tu ubicación para ofrecerte la mejor experiencia',
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
                  Navigator.of(context).pop();
                  PermissionHandler().openAppSettings().then((bool hasOpened) {
                    debugPrint('App Settings opened: ' + hasOpened.toString());
                  });
                },
                child: Text(
                  "Habilitar",
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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///                                   RubberBottomSheet CONFIG
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  void _toggleAddressList() {
    _bottomSheetController.launchTo(
      _bottomSheetController.value,
      _bottomSheetController.value - 0.1 > _bottomSheetController.lowerBound ? _bottomSheetController.lowerBound : _bottomSheetController.halfBound,
      velocity: 1,
    );
  }

  Widget _getLowerLayer() {
    return Container(
      height: 0,
    );
  }

  Widget _getHeaderLayer() {
    return !_isLoggedIn
        ? Container()
        : (widget.showStores && _isPickUp) || (_isPickUp && (_savedDelivery || _isStoreSeleted || _locationSet))
            ? Container()
            : ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20.0),
                  topRight: const Radius.circular(20.0),
                ),
                child: Container(
                  color: DataUI.backgroundColor.withOpacity(1),
                  child: Center(
                    child: IconButton(
                      icon: Icon(Icons.maximize, size: 32),
                      onPressed: () {
                        _toggleAddressList();
                      },
                    ),
                  ),
                ),
              );
  }

  Widget _getUpperLayer() {
    return !_isLoggedIn
        ? Container()
        : (widget.showStores && _isPickUp) || (_isPickUp && (_savedDelivery || _isStoreSeleted || _locationSet))
            ? Container()
            : !_isUpdatingAddresses
                ? Container(
                    decoration: BoxDecoration(
                      color: DataUI.backgroundColor.withOpacity(1),
                    ),
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: AnimatedCrossFade(
                              sizeCurve: Curves.easeInOut,
                              duration: const Duration(milliseconds: 280),
                              crossFadeState: addresses != null ? !loading ? CrossFadeState.showSecond : CrossFadeState.showFirst : CrossFadeState.showFirst,
                              firstChild: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              secondChild: addresses != null && addresses.length > 0
                                  ? Scrollbar(
                                      child: ListView.builder(
                                        padding: EdgeInsets.only(bottom: 160),
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        controller: _scrollController,
                                        itemCount: addresses == null ? 0 : addresses.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          return Container(
                                            margin: EdgeInsets.only(top: 15, left: 10, right: 10),
                                            padding: EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 10),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(8)),
                                              color: Colors.white,
                                              boxShadow: <BoxShadow>[
                                                BoxShadow(
                                                  color: Color(0xcc000000).withOpacity(0.1),
                                                  offset: Offset(0.0, 5.0),
                                                  blurRadius: 8.0,
                                                ),
                                              ],
                                            ),
                                            child: Material(
                                              color: Colors.white,
                                              child: InkWell(
                                                enableFeedback: true,
                                                onTap: () {
                                                  _confirmSelectDeliveryAddress(addresses[index], _itemsAmount > 0);
                                                },
                                                splashColor: DataUI.chedrauiColor,
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Column(
                                                      children: <Widget>[
                                                        IconButton(
                                                          splashColor: DataUI.chedrauiColor,
                                                          icon: Icon(
                                                            Icons.location_on,
                                                            size: 24,
                                                            color: DataUI.chedrauiColor,
                                                          ),
                                                          onPressed: () {
                                                            _confirmSelectDeliveryAddress(addresses[index], _itemsAmount > 0);
                                                            // _editAddress(addresses[index]);
                                                          },
                                                        ),
                                                      ],
                                                    ),
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
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Padding(
                                      padding: EdgeInsets.all(20),
                                      // width:50,
                                      // height: 50,
                                      child: Center(
                                        child: Text(
                                          'No se encontraron direcciones guardadas',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    )),
                        ),
                      ],
                    ),
                  )
                : Container(
                    color: DataUI.backgroundColor,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
  }

  Widget _getMenuLayer() {
    return tiendas != null
        ? Container(
            padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 22),
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.only(topLeft: const Radius.circular(20.0), topRight: const Radius.circular(20.0)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Color(0xcc000000).withOpacity(0.2),
                  offset: Offset(5.0, 0.0),
                  blurRadius: 12.0,
                ),
              ],
              color: Colors.white,
            ),
            child: _showSavedLocation && !widget.showStores && !widget.showConfirmationForm
                ? Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        child: _savedDelivery
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      'Recoger en:',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                        color: DataUI.textOpaqueMedium,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    prefs.getString('store-displayName') ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    prefs.getString('store-formattedAddress') ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  FlatButton(
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    padding: EdgeInsets.all(0),
                                    onPressed: () => _unsetAddress(),
                                    child: Text(
                                      "Quitar ubicación",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  // Center(
                                  //   child: GestureDetector(
                                  //     onTap: () => _toggleAddressList(),
                                  //     child: Icon(
                                  //       Icons.maximize,
                                  //       size: 32,
                                  //     ),
                                  //   ),
                                  // ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      'Enviar a:',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                        color: DataUI.textOpaqueMedium,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    prefs.getString('delivery-locationName') ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    prefs.getString('delivery-formatted_address') ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: FlatButton(
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          padding: EdgeInsets.all(0),
                                          onPressed: () => _unsetAddress(),
                                          child: Text(
                                            "Remover ubicación",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      _isLoggedIn
                                          ? Expanded(
                                              flex: 1,
                                              child: FlatButton(
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                padding: EdgeInsets.all(0),
                                                onPressed: () => _toggleAddressList(),
                                                child: Text(
                                                  "Direcciones guardadas",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                    ],
                  )
                : _isPickUp
                    ? _isStoreSeleted
                        ? Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Flexible(
                                child: isLoading
                                    ? Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: CircularProgressIndicator(),
                                      )
                                    : Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.only(top: 15, bottom: 5),
                                            child: Text(
                                              selectedStore.displayName ?? '',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                letterSpacing: 0.25,
                                                color: HexColor('#212B36'),
                                                fontFamily: 'Archivo',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            selectedStore.formattedAddress ?? '',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: HexColor('#212B36'),
                                              fontFamily: 'Archivo',
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 15),
                                            width: double.infinity,
                                            child: FlatButton(
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(4.0),
                                              ),
                                              padding: EdgeInsets.only(left: 0, right: 0, bottom: 15, top: 15),
                                              color: DataUI.btnbuy,
                                              //onPressed: () => _confirmDeliveryAddress(true),
                                              onPressed: () => _confirmDeliveryAddressDialog(_itemsAmount > 0, true),
                                              child: Text(
                                                "Recoger orden aquí",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          /*
                                            widget.showStores
                                                ? FlatButton(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    padding: EdgeInsets.all(0),
                                                    onPressed: () => _launchMapsRouteUrl(),
                                                    child: Text(
                                                      "Trazar Ruta",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        fontSize: 14.0,
                                                        color: Colors.blue,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                                */
                                        ],
                                      ),
                              ),
                            ],
                          )
                        : SizedBox(
                            height: 0,
                          )
                    : _locationSet
                        ? Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Flexible(
                                child: isLoading
                                    ? Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: CircularProgressIndicator(),
                                      )
                                    : _addressNotValid
                                        ? Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                'Ubicación no válida',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                'Porfavor seleccione una ubicación en el mapa que contenga código postal',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              Divider(),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 1,
                                                    child: FlatButton(
                                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                      padding: EdgeInsets.all(0),
                                                      onPressed: () {},
                                                      child: Text(
                                                        "Confirmar dirección",
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 12.0,
                                                          color: Colors.grey,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  _isLoggedIn
                                                      ? Expanded(
                                                          flex: 1,
                                                          child: FlatButton(
                                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                            padding: EdgeInsets.all(0),
                                                            onPressed: () => _toggleAddressList(),
                                                            child: Text(
                                                              "Direcciones guardadas",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                fontSize: 12.0,
                                                                color: Colors.blue,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                            ],
                                          )
                                        : Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                selectedAddress.name ?? '',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                selectedAddress.formattedAddress ?? '',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              Divider(),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 1,
                                                    child: FlatButton(
                                                      color: DataUI.btnbuy,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(4.0),
                                                      ),
                                                      padding: EdgeInsets.only(left: 0, right: 0, bottom: 15, top: 15),
                                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                      //onPressed: () => _confirmDeliveryAddress(false),
                                                      onPressed: () => _confirmDeliveryAddressDialog(_itemsAmount > 0, false),
                                                      child: Text(
                                                        "Confirmar dirección",
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 12.0,
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  _isLoggedIn
                                                      ? Expanded(
                                                          flex: 1,
                                                          child: FlatButton(
                                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                            padding: EdgeInsets.all(0),
                                                            onPressed: () => _toggleAddressList(),
                                                            child: Text(
                                                              "Direcciones guardadas",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                fontSize: 12.0,
                                                                color: Colors.blue,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                            ],
                                          ),
                              ),
                            ],
                          )
                        : _isLoggedIn
                            ? Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Flexible(
                                    child: isLoading
                                        ? Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: CircularProgressIndicator(),
                                          )
                                        : Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              FlatButton(
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                padding: EdgeInsets.all(0),
                                                onPressed: () => _toggleAddressList(),
                                                child: Text(
                                                  "Direcciones Guardadas",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ],
                              )
                            : Container(),
          )
        : SizedBox(
            height: 0,
          );
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///                                   ADDRESSBOOK CONFIG
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  void getAddressBoook() async {
    if (_isLoggedIn) {
      _isUpdatingAddresses = true;
      UserProfileServices.hybrisGetUserAddress().then((response) {
        setState(() {
          addresses = response['addresses'];
          _isUpdatingAddresses = false;
        });
      });
    }
  }

  Future<void> _selectDeliveryAddress(var address) async {
    print(address);

    selectedAddress = SelectedLocation();
    selectedAddress.isLocationSet = true;
    selectedAddress.isPickup = false;
    selectedAddress.userName = address['firstName'];
    selectedAddress.userLastName = address['lastName'];
    selectedAddress.direccion = address['line1'];
    selectedAddress.numInterior = address['line2'];
    selectedAddress.sublocality = address['town'];
    selectedAddress.codigoPostal = address['postalCode'];
    selectedAddress.estado = address['region'] != null ? address['region']['name'] : "";
    selectedAddress.isocode = getEstadoIsoCode(selectedAddress.estado);
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
    //prefs.setBool("cart-address-update", true);

    if (_isLoggedIn) {
      await _setNewAddressToCart();
    } else {
      Navigator.pop(context);
    }

    final store = StoreProvider.of<AppState>(context);
    store.dispatch(SetCurrentLocationAction(selectedAddress));

    // Navigator.of(context).pop();
  }

  void _confirmSelectDeliveryAddress(var address, bool isLocationSet) async {
    if (isLocationSet) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Icon(
                Icons.warning,
                size: 52,
                color: DataUI.chedrauiColor,
              ),
            ),
            content: Text(
              'Si cambias tu dirección de entrega, algunos de tus productos podrían desaparecer de tu compra. ¿Deseas continuar?',
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
                    Navigator.of(context).pop();
                    return false;
                  },
                  child: Text(
                    "Cancelar",
                    style: TextStyle(
                      color: DataUI.chedrauiBlueColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FlatButton(
                  onPressed: () async {
                    print(loading);
                    setState(() {
                      loading = true;
                    });
                    Navigator.of(context).pop();
                    await _selectDeliveryAddress(address);
                  },
                  child: Text(
                    "Aceptar",
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
    } else {
      print(loading);
      setState(() {
        loading = true;
      });
      await _selectDeliveryAddress(address);
    }
  }

  String getEstadoIsoCode(String estado) {
    if (estado == null || estado.trim().length == 0) return null;
    switch (estado.toLowerCase()) {
      case "aguascalientes":
        return "MX-AGU";
        break;
      case "baja california":
        return "MX-BCN";
        break;
      case "baja california sur":
        return "MX-BCS";
        break;
      case "campeche":
        return "MX-CAM";
        break;
      case "chiapas":
        return "MX-CHP";
        break;
      case "chihuahua":
        return "MX-CHH";
        break;
      case "coahuila":
        return "MX-COA";
        break;
      case "colima":
        return "MX-COL";
        break;
      case "ciudad de méxico":
        return "MX-CMX";
        break;
      case "durango":
        return "MX-DUR";
        break;
      case "guanajuato":
        return "MX-GUA";
        break;
      case "guerrero":
        return "MX-GRO";
        break;
      case "hidalgo":
        return "MX-HID";
        break;
      case "jalisco":
        return "MX-JAL";
        break;
      case "estado de méxico":
        return "MX-MEX";
        break;
      case "michoacán":
        return "MX-MIC";
        break;
      case "morelos":
        return "MX-MOR";
        break;
      case "nayarit":
        return "MX-NAY";
        break;
      case "nuevo león":
        return "MX-NLE";
        break;
      case "oaxaca":
        return "MX-OAX";
        break;
      case "puebla":
        return "MX-PUE";
        break;
      case "querétaro":
        return "MX-QUE";
        break;
      case "quintana roo":
        return "MX-ROO";
        break;
      case "san luis potosí":
        return "MX-SLP";
        break;
      case "sinaloa":
        return "MX-SIN";
        break;
      case "sonora":
        return "MX-SON";
        break;
      case "tabasco":
        return "MX-TAB";
        break;
      case "tamaulipas":
        return "MX-TAM";
        break;
      case "tlaxcala":
        return "MX-TLA";
        break;
      case "veracruz":
        return "MX-VER";
        break;
      case "yucatán":
        return "MX-YUC";
        break;
      case "zacatecas":
        return "MX-ZAC";
        break;
      default:
        return null;
    }
  }
}
