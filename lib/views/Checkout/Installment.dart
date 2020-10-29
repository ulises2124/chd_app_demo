class Installment{
  String promoId;
  int selectedInstallmentIndex;
  double baseAmount;
  String benefitType;
  String creditPlan;
  String displayMessage;
  int installments;
  double limitAmount;
  String printerMessage;
  int tender;
  String tlogMessage;
  int type;
  bool restricted;
  bool repeated;

  Installment(String promoId, bool restricted, {bool repeated}){
    this.promoId = promoId;    
    if(restricted){
      this.selectedInstallmentIndex = 0;
    }
    this.restricted = restricted;
    if(repeated){
      this.repeated = repeated;
    }
  }


}