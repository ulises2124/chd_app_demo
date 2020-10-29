import 'package:chd_app_demo/views/DeliveryMethod/SelectedLocation.dart';
import 'package:chd_app_demo/views/DeliveryMethod/Tienda.dart';

class AppState {
  final bool isSessionActive;
  final bool isSearchingProducts;
  final int shoppingCartQuantity;
  final SelectedLocation currentLocation;
  final List<Tienda> tiendas;
  final String connectivity;
  AppState({
    this.isSessionActive = false,
    this.isSearchingProducts = false,
    this.shoppingCartQuantity = 0,
    this.currentLocation,
    this.tiendas,
    this.connectivity
  });

  AppState copyWith({
    bool isSessionActive,
    bool isSearchingProducts,
    int shoppingCartQuantity,
    SelectedLocation currentLocation,
    List<Tienda> tiendas,
    String connectivity,
  }) {
    return new AppState(
      isSessionActive: isSessionActive ?? this.isSessionActive,
      isSearchingProducts: isSearchingProducts ?? this.isSearchingProducts,
      shoppingCartQuantity: shoppingCartQuantity ?? this.shoppingCartQuantity,
      currentLocation: currentLocation ?? this.currentLocation,
      tiendas: tiendas,
      connectivity: connectivity ?? this.connectivity,
    );
  }

  @override
  String toString() {
    return 'AppState{isSessionActive: $isSessionActive, isSearchingProducts: $isSearchingProducts, shoppingCartQuantity: $shoppingCartQuantity, currentLocation: $currentLocation}, tiendas: $tiendas, connectivity: $connectivity';
  }
}
