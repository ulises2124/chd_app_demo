import 'dart:async';
import 'package:chd_app_demo/views/DeliveryMethod/SelectedLocation.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:chd_app_demo/redux/models/AppState.dart';

import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/views/DeliveryMethod/DeliveryMethodPage.dart';

class _ViewModel {
  final SelectedLocation currentLocation;
  _ViewModel({
    @required this.currentLocation,
  });
  static _ViewModel fromStore(Store<AppState> store) {
    return new _ViewModel(currentLocation: store.state.currentLocation);
  }
}

class DeliveryMethodSelection extends StatefulWidget {
  final Widget child;
  DeliveryMethodSelection({Key key, this.child}) : super(key: key);

  @override
  _DeliveryMethodSelectionState createState() => _DeliveryMethodSelectionState();
}

class _DeliveryMethodSelectionState extends State<DeliveryMethodSelection> {
  SharedPreferences prefs;
  bool _isPickUp;
  bool _isLocationsSaved;
  String _currentAddress = "Seleccionar tu tienda...";

  @override
  initState() {
    super.initState();
    setLabels();
  }

  Future setLabels() async {
    prefs = await SharedPreferences.getInstance();
    if(mounted){
    setState(() {
      _isPickUp = prefs.getBool('isPickUp') ?? false;
      _isLocationsSaved = prefs.getBool('isLocationSet') ?? false;
      if (_isLocationsSaved) {
        _currentAddress = _isPickUp ? prefs.getString('store-displayName') ?? '' : prefs.getString('delivery-formatted_address') ?? '';
      }
    });

    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocationsSaved != null) {
      return StoreConnector<AppState, _ViewModel>(
        onInit: (store) {
          if (store.state.currentLocation != null && store.state.currentLocation.isLocationSet) {
            if (store.state.currentLocation.isPickup) {
              _currentAddress = store.state.currentLocation.storeDisplayName;
            } else {
              _currentAddress = store.state.currentLocation.formattedAddress;
            }
          }
        },
        onWillChange: (_viewModel) {
          if (_viewModel.currentLocation != null) {
            setState(() {
              if (_viewModel.currentLocation.isLocationSet && prefs.getBool('isLocationSet') != null) {
                _isPickUp = _viewModel.currentLocation.isPickup;
                if (_isPickUp) {
                  _currentAddress = _viewModel.currentLocation.storeDisplayName;
                } else {
                  _currentAddress = _viewModel.currentLocation.formattedAddress;
                }
              } else {
                _currentAddress = "Seleccionar tu tienda...";
              }
            });
          }
        },
        converter: _ViewModel.fromStore,
        builder: (BuildContext context, _ViewModel vm) {
          return Container(
            height: 20,
            margin: EdgeInsets.only(left: 10, right: 10),
            child: FlatButton(
              onPressed: () {
                try {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: RouteSettings(name: DataUI.deliveryMethodRoute),
                      builder: (context) => DeliveryMethodPage(
                        showStores: false,
                        showConfirmationForm: false,
                      ),
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pushNamedAndRemoveUntil(DataUI.initialRoute, (Route<dynamic> route) => false);
                  // Navigator.pushReplacementNamed(context, '/');
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: Colors.white,
                  ),
                  Text(
                    _isPickUp ? 'Recoger en: ' : 'Enviar a: ',
                    style: TextStyle(
                      fontFamily: 'Archivo',
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 160),
                      child: Text(
                        _currentAddress,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        maxLines: 1,
                        style: TextStyle(
                          letterSpacing: 0.3,
                          fontSize: 13.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(top: 4, left: 10, right: 10, bottom: 4),
        child: Center(
          child: CircularProgressIndicator(
            value: null,
          ),
        ),
      );
    }
  }
}
