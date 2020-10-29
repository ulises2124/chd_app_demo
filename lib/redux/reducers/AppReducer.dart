import 'package:chd_app_demo/redux/models/AppState.dart';
import 'package:chd_app_demo/redux/models/AppState.dart';
import 'package:chd_app_demo/redux/reducers/ConnectivityReducer.dart';
import 'package:chd_app_demo/redux/reducers/LocationReducers.dart';
import 'package:chd_app_demo/redux/reducers/SearchingReducers.dart';
import 'package:chd_app_demo/redux/reducers/SessionReducer.dart';
import 'package:chd_app_demo/redux/reducers/ShoppingCartReducers.dart';

AppState appReducer(AppState state, action) {
  return new AppState(
    isSessionActive: isSessionActiveReducer(state.isSessionActive, action),
    isSearchingProducts: isSearchingProductsReducer(state.isSearchingProducts, action),
    shoppingCartQuantity: shoppingCartReducer(state.shoppingCartQuantity, action),
    currentLocation: currentLocationReducer(state.currentLocation, action),
    tiendas: tiendasReducer(state.tiendas, action),
    connectivity: connectivityReducer(state.connectivity, action)
  );
}
