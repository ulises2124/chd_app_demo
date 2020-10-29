import 'package:chd_app_demo/views/ProductPage/ProductPage.dart';
import 'package:chd_app_demo/services/ArticulosServices.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class CarritoItem extends StatefulWidget {
  final dynamic itemData;
  final int index;
  final Function callbackAddQty;
  final Function callbackSubtractQty;
  final Function callbackRemoveItem;
  final Function callbackAutomaticUpdate;

  CarritoItem(
    this.itemData,
    this.index, {
    this.callbackAddQty,
    this.callbackSubtractQty,
    this.callbackRemoveItem,
    this.callbackAutomaticUpdate,
    Key key,
  }) : super(key: key);

  _CarritoItemState createState() => _CarritoItemState();
}

class _CarritoItemState extends State<CarritoItem> {
  dynamic itemData;
  int index;

  bool isMoreThanMinimum = true;

  NumberFormat moneda = new NumberFormat.currency(locale: 'es_MX', symbol: "\$");

  bool isLoadingSinglePorduct = false;

  Future<void> goToSingleProduct (String code) async{
    setState(() {
      isLoadingSinglePorduct = true;
    });
    var selectedProduct = await ArticulosServices.getProductHybrisSearch(code);
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: DataUI.productRoute),
        builder: (context) => ProductPage(data: selectedProduct),
      ),
    );
    setState(() {
      isLoadingSinglePorduct = false;
    });
    widget.callbackAutomaticUpdate();
  }

  @override
  void initState() {
    itemData = widget.itemData;
    index = widget.index;
    isMoreThanMinimum = widget.itemData['decimalQty'] > widget.itemData['minQty'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 0.5, bottom: 0.5),
        child: Slidable(
          delegate: SlidableDrawerDelegate(),
          actionExtentRatio: 0.20,
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(3)),
                color: Colors.white,
              ),
              child: Column(children: <Widget>[
                Row(children: <Widget>[
                  Expanded(
                      flex: 3,
                      child: Container(
                        margin: EdgeInsets.all(10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(0.0),
                          child: GestureDetector(
                            onTap: !isLoadingSinglePorduct? (){
                              goToSingleProduct(itemData['product']['code']);
                            } : null,
                            child: itemData['urlImage'] != null
                              ? CachedNetworkImage(
                                  imageUrl: itemData['urlImage'],
                                  placeholder: (context, url) => Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(top: 15),
                                      height: 60,
                                      child: Image.asset('assets/chd_logo.png'),
                                    ),
                                    Text(
                                      'Imagen no disponible',
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                          )
                        ),
                      )),
                  Expanded(
                      flex: 9,
                      child: Padding(
                          padding: const EdgeInsets.only(
                            left: 6,
                            top: 10,
                            bottom: 5,
                            right: 2,
                          ),
                          child: 
                            itemData != null && 
                            itemData['product'] != null && 
                            itemData['basePrice'] != null && 
                            itemData['totalPrice'] != null ?
                          Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                            Row(children: <Widget>[
                              Expanded(
                                flex: 12,
                                child: Container(
                                  width: double.infinity,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: GestureDetector(
                                    onTap: !isLoadingSinglePorduct? (){
                                      goToSingleProduct(itemData['product']['code']);
                                    } : null,
                                    child: Text(
                                      itemData['product']['name'],
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: DataUI.blackText),
                                    ),
                                  ),
                                ),
                              )
                            ]),
                            Row(children: <Widget>[
                              Expanded(
                                  flex: 12,
                                  child: RichText(
                                    text: TextSpan(
                                      text: moneda.format(itemData['basePrice']['value']) + ' ' + itemData['product']['unit']['name'] + ' ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ))
                            ]),
                            Row(children: <Widget>[
                              Expanded(
                                  flex: 7,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: DataUI.opaqueBorder, width: 2),
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                    ),
                                    margin: const EdgeInsets.only(top: 5, right: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 2,
                                              child: IconButton(
                                                onPressed: () async {
                                                  if(isMoreThanMinimum)
                                                    await widget.callbackSubtractQty(index);
                                                  else
                                                    await widget.callbackRemoveItem(index);
                                                  setState(() {
                                                    isMoreThanMinimum = widget.itemData['decimalQty'] > widget.itemData['minQty'];
                                                  });
                                                },
                                                icon: isMoreThanMinimum ? Icon(Icons.remove) : Icon(Icons.delete),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                // '5Kg',
                                                itemData['decimalQty'].toString(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: IconButton(
                                                onPressed: () async {
                                                  await widget.callbackAddQty(index);
                                                  setState(() {
                                                    isMoreThanMinimum = widget.itemData['decimalQty'] > widget.itemData['minQty'];
                                                  });
                                                },
                                                icon: Icon(Icons.add),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  )),
                              Expanded(
                                  flex: 5,
                                  child: Text(
                                    moneda.format(itemData['totalPrice']['value']),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DataUI.chedrauiBlueColor),
                                  ))
                            ])
                          ]): SizedBox(height: 0,)) )
                ]),
                Row(children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
                      child: Container(
                          /*
                      child: ListView.builder(
                        physics: ClampingScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: itemData['promos'] == null ? 0 : itemData['promos'].length,
                        itemBuilder: (context, index) {
                          print(itemData['promos']);
                          return Row(
                            children: <Widget>[
                              Container(
                                child: InputChip(
                                  clipBehavior: Clip.none,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 15),
                                  backgroundColor: DataUI.textOpaque,
                                  onPressed: () {
                                  },
                                  label: Text(
                                    itemData['promos'][index],
                                    style: TextStyle(
                                        color: DataUI.whiteText,
                                        fontFamily: "Archivo",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                              )
                            ]
                          );
                        }
                      )
                      */
                          ))
                ])
              ])),
          secondaryActions: <Widget>[
            IconSlideAction(
              caption: '',
              color: Colors.red,
              icon: Icons.delete_outline,
              onTap: () async {
                await widget.callbackRemoveItem(index);
                setState(() {
                  isMoreThanMinimum = widget.itemData['decimalQty'] > widget.itemData['minQty'];
                });
              },
            ),
          ],
        ));
  }
}
