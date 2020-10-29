import 'package:chd_app_demo/redux/actions/LocationActions.dart';
import 'package:chd_app_demo/views/DeliveryMethod/SelectedLocation.dart';
import 'package:chd_app_demo/views/DeliveryMethod/Tienda.dart';

List<Tienda> tiendasReducer(List<Tienda> tiendas, dynamic action) {
  if (action is AddTiendasAction) {
    return addTiendas(tiendas, action);
  } 
  return tiendas;
}

List<Tienda> addTiendas(List<Tienda> tiendas, AddTiendasAction action) {
  return action.tiendas;
}


SelectedLocation currentLocationReducer(SelectedLocation currentLocation, dynamic action) {
  if (action is SetCurrentLocationAction) {
  return action.currentLocation;
  } 
  return currentLocation;
}