import 'package:chd_app_demo/views/Checkout/Installment.dart';
import 'package:chd_app_demo/views/Checkout/DeliveryHoursConsignmentWidget.dart';
import 'package:flutter/material.dart';

class InstallmentWidget extends StatefulWidget{
  final List<Installment> installmentList;
  final Function callback;
  
  InstallmentWidget({
    Key key,
    this.installmentList,
    this.callback,
  }) : super(key: key);

  @override
  _InstallmentWidgetState createState() => _InstallmentWidgetState();
}

class _InstallmentWidgetState extends State<InstallmentWidget>{

  bool hasOneRestricted = false;

  List<Installment> installments = [];

  Installment searchInstallment(String promoId){
    for(Installment singleInstallment in installments){
      if(singleInstallment.promoId == promoId){
        return singleInstallment;
      }
    }
  }

  void setInstallment(String promoId, {
    int selectedInstallmentIndex
  }){
    int i = installments.indexWhere((c){
      return c.promoId == promoId;
    });

    for (Installment elem in installments) {
      if(selectedInstallmentIndex != null) elem.selectedInstallmentIndex = selectedInstallmentIndex;  
    }
      
    this.widget.callback(installments);
  }

  int getSelectedInstallment(promoId){
    Installment temp = searchInstallment(promoId);
    return temp.selectedInstallmentIndex;
  }

  selectInstallment(String promoId, int index) {
    int _selectedInstallment = index;
    setState(() {
      setInstallment(
        promoId,
        selectedInstallmentIndex: _selectedInstallment
      );
    });
  }
  
  List<Widget> getDeliveryHourSlots(List<Installment> listaIstallment){
    int index = 0;
    int rowIndex = 0;
    List<Widget> rowList = new List<Widget>();
    List<Widget> expandList = new List<Widget>();

    for (Installment elem in listaIstallment) {
      if (index % 3 == 0) {
        // print("Nuevo Row");
        rowIndex = 0;

        expandList = [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: SizedBox(),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: SizedBox(),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: SizedBox(),
            ),
          ),
        ];

        rowList.add(Row(
          children: expandList,
        ));
      }

      var _selectedInstallment = getSelectedInstallment(elem.promoId);

      expandList[rowIndex] = Expanded(
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: DeliveryHourConsignmentItem(
            selectInstallment,
            index: index,
            isSelected: _selectedInstallment == index ? true : false,
            title: elem.displayMessage,
            consignmentCode: elem.promoId,
          ),
        ),
      );

      index++;
      rowIndex++;
    }

    return rowList;
  }

  getDeliveryDateTime(List<Installment> listaIstallment){
    if(listaIstallment.length > 0){
      bool repeated = false ?? false;
      if(!repeated){
        return Column(
          children: <Widget>[
            listaIstallment.length > 1 ?  Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(
                  top: 30,
                  right: 15,
                  left: 15,
                  bottom: 15),
              child: Text(
                'Tu tarjeta participa en las siguientes promociones a meses sin intereses.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ) : SizedBox(height: 0,),
            Container(
              child: Column(
                children: getDeliveryHourSlots(listaIstallment)
              ),
            ),
            Divider(
              height: 10,
              indent: 10,
            )
          ]
        );
      }
    } 
  }

  List<Widget> processSlots(List<Installment> listaIstallment){
    List<Widget> rows = [];
      rows.add(Container(
        child: Column(
          children: <Widget>[
            getDeliveryDateTime(listaIstallment)
          ]
        )
      ));
    return rows;
  }

  loadSlots(){
    List<Installment> installmentList = [];
    hasOneRestricted = false;
    for(var cons in widget.installmentList){
      var restricted = true;
      var repeated = hasOneRestricted && restricted;
      installmentList.add(
        new Installment(
          cons.promoId,
          restricted,
          repeated: repeated
        )
      );
      if(restricted){
        hasOneRestricted = true;
      }
    }
    setState((){
      installments = installmentList;
    });
    this.widget.callback(installments);
  }

  initState() {
    loadSlots();
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Column(
      children: installments.length > 0 ? 
        processSlots(widget.installmentList) :
        <Widget>[
          SizedBox(
            height: 50,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        ]
    );
  }
}
