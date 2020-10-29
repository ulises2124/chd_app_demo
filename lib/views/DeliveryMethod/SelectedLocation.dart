class SelectedLocation {

  bool isLocationSet;
  bool isPickup;
  String addressId;
  // google place params
  String name;
  String placeId;
  String formattedAddress;
  double lat;
  double lng;
  // // google address components
  String streetNumber;
  String route;
  String sublocality;
  String locality;
  // manual user inputs
  String estado;
  String isocode;
  String codigoPostal;
  String direccion;
  String numInterior;
  String userName;
  String userLastName;
  String userSecondLastName;
  String deliveryNote;
  String telefono;
  // pickup variables
  String storeId;
  String storeDisplayName;
  String storeName;

  SelectedLocation({
    this.isLocationSet = false,
    this.isPickup = false,
    this.addressId = '',
    this.name = '',
    this.placeId = '',
    this.formattedAddress = '',
    this.lat = 0,
    this.lng = 0,
    this.streetNumber = '',
    this.route = '',
    this.sublocality = '',
    this.locality = '',
    this.estado = '',
    this.isocode = '',
    this.codigoPostal = '',
    this.direccion = '',
    this.numInterior = '',
    this.userName = '',
    this.userLastName = '',
    this.userSecondLastName = '',
    this.deliveryNote = '',
    this.telefono = '',
    this.storeId = '',
    this.storeDisplayName = '',
    this.storeName = '',
  });

  // factory SelectedLocation.initial() {
  //   return new SelectedLocation(
  //     isPickup: false,
  //     name: '',
  //     placeId: '',
  //     formattedAddress: '',
  //     lat: 0,
  //     lng: 0,
  //     streetNumber: '',
  //     route: '',
  //     sublocality: '',
  //     locality: '',
  //     estado: '',
  //     isocode: '',
  //     codigoPostal: '',
  //     direccion: '',
  //     numInterior: '',
  //     userName: '',
  //     userLastName: '',
  //     userSecondLastName: '',
  //     deliveryNote: '',
  //     telefono: '',
  //   );
  // }

  
}
