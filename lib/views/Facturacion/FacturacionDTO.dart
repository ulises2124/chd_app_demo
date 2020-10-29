class FacturacionDTO {
  String sucursal;
  String rfc;
  String homoclave;
  String numTicket;
  String correo;
  String ieps;
  String razonSocial;
  String calle;
  String noExterior;
  String noInterior;
  String colonia;
  String localidad;
  String delMunicipio;
  String codigoPostal;
  String estado;
  String pais;

  FacturacionDTO(
      {this.sucursal,
      this.rfc,
      this.homoclave,
      this.numTicket,
      this.correo,
      this.ieps,
      this.razonSocial,
      this.calle,
      this.noExterior,
      this.noInterior,
      this.colonia,
      this.localidad,
      this.delMunicipio,
      this.codigoPostal,
      this.estado,
      this.pais});

  factory FacturacionDTO.fromJson(Map<String, dynamic> json) {
    return FacturacionDTO(
        sucursal: json['sucursal'],
        rfc: json['rfc'],
        homoclave: json['homoclave'],
        numTicket: json['numTicket'],
        correo: json['correo'],
        ieps: json['ieps'],
        razonSocial: json['razonSocial'],
        calle: json['calle'],
        noExterior: json['noExterior'],
        noInterior: json['noInterior'],
        colonia: json['colonia'],
        localidad: json['localidad'],
        delMunicipio: json['delMunicipio'],
        codigoPostal: json['codigoPostal'],
        estado: json['estado'],
        pais: json['pais']);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["sucursal"] = sucursal;
    map["rfc"] = rfc;
    map["homoclave"] = homoclave;
    map["numTicket"] = numTicket;
    map["correo"] = correo;
    map["ieps"] = ieps;
    map["razonSocial"] = razonSocial;
    map["calle"] = calle;
    map["noExterior"] = noExterior;
    map["noInterior"] = noInterior;
    map["colonia"] = colonia;
    map["localidad"] = localidad;
    map["delMunicipio"] = delMunicipio;
    map["codigoPostal"] = codigoPostal;
    map["estado"] = estado;
    map["pais"] = pais;

    return map;
  }
}