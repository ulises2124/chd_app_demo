class Consignment{
  String consignmentCode;
  String type;
  int selectedDateIndex;
  int selectedHourIndex;
  DateTime timeFrom;
  DateTime timeTo;
  DateTime dateSelected;
  String formatedDateTime;
  bool restricted;
  bool repeated;
  String storeFrom;
  List<dynamic> productos;

  Consignment(String consignmentCode, bool restricted, {bool repeated}){
    this.consignmentCode = consignmentCode;
    if(restricted){
      this.selectedDateIndex = 0;
      this.selectedHourIndex = 0;
    }
    this.restricted = restricted;
    if(repeated){
      this.repeated = repeated;
    }
  }

}