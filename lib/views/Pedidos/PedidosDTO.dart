class OrderDTO {
  String code;
  String guid;
  String placed;
  String status;
  String statusDisplay;
  Cost total;

  OrderDTO(
      {this.code,
      this.guid,
      this.placed,
      this.status,
      this.statusDisplay,
      this.total});

  factory OrderDTO.fromJson(Map<String, dynamic> json) {
    return OrderDTO(
        code: json['code'],
        guid: json['guid'],
        placed: json['placed'],
        status: json['status'],
        statusDisplay: json['statusDisplay'],
        total: Cost.fromJson(json['total']));
  }
  Map toMap() {
    var map = new Map<String, dynamic>();
    map["code"] = code;
    map["guid"] = guid;
    map["placed"] = placed;
    map["status"] = status;
    map["statusDisplay"] = statusDisplay;
    map["total"] = total;
    return map;
  }
}

class Cost {
  String currencyIso;
  String formattedValue;
  String priceType;
  double value;

  Cost({this.currencyIso, this.formattedValue, this.priceType, this.value});

  factory Cost.fromJson(Map<String, dynamic> json) {
    return Cost(
        currencyIso: json['currencyIso'],
        formattedValue: json['formattedValue'],
        priceType: json['priceType'],
        value: json['value']);
  }

  Map toJson() {
    var map = Map<String, dynamic>();
    map["currencyIso"] = currencyIso;
    map["formattedValue"] = formattedValue;
    map["priceType"] = priceType;
    map["value"] = value;
    return map;
  }
}