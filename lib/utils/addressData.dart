class Address {
  String countryisocode = '';
  String countryname = '';
  String email = '';
  String firstName = '';
  String formattedAddress = '';
  String id = '';
  String lastName = '';
  String secondLastName = '';
  String line1 = '';
  String line2 = '';
  String phone = '';
  String postalCode = '';
  String regioncountryIso = '';
  String regionisocode = '';
  String regionisocodeShort = '';
  String regionname = '';
  bool shippingAddress = null;
  String town = '';
  bool visibleInAddressBook = null;

  Address(
    {
      this.countryisocode,
      this.countryname,
      this.email,
      this.firstName,
      this.formattedAddress,
      this.id,
      this.lastName,
      this.line1,
      this.line2,
      this.phone,
      this.postalCode,
      this.regioncountryIso,
      this.regionisocode,
      this.regionisocodeShort,
      this.regionname,
      this.shippingAddress,
      this.secondLastName,
      this.town,
      this.visibleInAddressBook
    }
  );

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
        countryisocode: json['country']['isocode'],
        countryname: json['country']['name'],
        email: json['email'],
        firstName: json['firstName'],
        formattedAddress: json['formattedAddress'],
        id: json['id'],
        lastName: json['lastName'],
        line1: json['line1'],
        line2: json['line2'],
        phone: json['phone'],
        postalCode: json['postalCode'],
        regioncountryIso: json['region']['countryIso'],
        regionisocode: json['region']['isocode'],
        regionisocodeShort: json['region']['isocodeShort'],
        regionname: json['region']['name'],
        shippingAddress: json['shippingAddress'],
        secondLastName: json['secondLastName'],
        town: json['town'],
        visibleInAddressBook: json['visibleInAddressBook']);
  }

  Map <dynamic, dynamic> toJSON(){
    Map <dynamic, dynamic> json = {
      "country": {
        "isocode": this.countryisocode
      },
      "firstName": this.firstName,
      "lastName": this.lastName,
      "secondLastName": this.secondLastName,
      "line1": this.line1,
      "line2": this.line2,
      "postalCode": this.postalCode,
      "region": {
        "isocode": this.regionisocode
      },
      "town": this.town,
      "phone": this.phone,
    };
    return json;
  }

  void updateFormattedAddress(){
    String formattedAddress = "${this.line1} ${this.town} ${this.postalCode} ${this.regionname} ${this.countryname}";
    this.formattedAddress = formattedAddress;
  }

  void updateRegionIsocodeShort(){
    List regionList = this.regionisocode.split('-');
    if(regionList.length > 1){
      this.regionisocodeShort = regionList[1];
    }
  }

}