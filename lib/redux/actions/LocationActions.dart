import 'package:chd_app_demo/views/DeliveryMethod/SelectedLocation.dart';
import 'package:chd_app_demo/views/DeliveryMethod/Tienda.dart';

class AddTiendasAction {
  final List<Tienda> tiendas;
  AddTiendasAction(this.tiendas);
}



class SetCurrentLocationAction {
  final SelectedLocation currentLocation;
  SetCurrentLocationAction(this.currentLocation);
}
