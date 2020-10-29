// class Tienda {
//   final String sucursal;
//   final String delegacionMunicipio;
//   final String numExteriro;
//   final String colonia;
//   final String codigoPostal;
//   final String estado;
//   final String calle;
//   final String pais;
//   final String telefonos;
//   final String latitud;
//   final String longitud;

//   Tienda({
//     this.sucursal,
//     this.delegacionMunicipio,
//     this.numExteriro,
//     this.colonia,
//     this.codigoPostal,
//     this.estado,
//     this.calle,
//     this.pais,
//     this.telefonos,
//     this.latitud,
//     this.longitud,
//   });

//   factory Tienda.fromJson(Map<String, dynamic> json) {
//     return Tienda(
//       sucursal: json['sucursal'] as String,
//       delegacionMunicipio: json['delegacionMunicipio'] as String,
//       numExteriro: json['numExteriro'] as String,
//       colonia: json['colonia'] as String,
//       codigoPostal: json['codigoPostal'] as String,
//       estado: json['estado'] as String,
//       calle: json['calle'] as String,
//       pais: json['pais'] as String,
//       telefonos: json['telefonos'] as String,
//       latitud: json['latitud'] as String,
//       longitud: json['longitud'] as String,
//     );
//   }
// }

class Tienda {
  final String id;
  final String displayName;
  final String name;
  final String formattedAddress;
  final double latitude;
  final double longitude;

  Tienda({
    this.id,
    this.displayName,
    this.name,
    this.formattedAddress,
    this.latitude,
    this.longitude,
  });

  factory Tienda.fromJson(Map<String, dynamic> json) {
    return Tienda(
      id: json['address']['id'] as String,
      displayName: json['displayName'] as String,
      name: json['name'] as String,
      formattedAddress: json['address']['formattedAddress'] as String,
      latitude: json['geoPoint']['latitude'] as double,
      longitude: json['geoPoint']['longitude'] as double,
    );
  }
}
