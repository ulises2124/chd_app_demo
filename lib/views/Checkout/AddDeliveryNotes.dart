import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chd_app_demo/services/CarritoServices.dart';
import 'package:chd_app_demo/widgets/WidgetContainer.dart';

class AddDeliveryNotes extends StatefulWidget {
  AddDeliveryNotes({Key key}) : super(key: key);

  @override
  _AddDeliveryNotesState createState() => _AddDeliveryNotesState();
}

class _AddDeliveryNotesState extends State<AddDeliveryNotes> {
  
  ScrollController _scrollController = new ScrollController();
  TextEditingController _controller;
  SharedPreferences prefs;
  String instrucciones = "";
  bool flagLoad = false;
  Future<dynamic> cart;

  Future<void> loadWidget() async{
    var prefsAux = await SharedPreferences.getInstance();
    cart = CarritoServices.getCart().then((data){
      setState((){
        instrucciones = data['comment'] ?? '';
      });
    });
    setState(() {
      prefs = prefsAux;
    });
  }

  @override
  void initState() {
    loadWidget();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetContainer(
      Scaffold(
        backgroundColor: DataUI.backgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: DataUI.btnbuy,
          title: Text(
            'Información de contacto',
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: DataUI.whiteText
            ),
          )
        ),
        body: prefs != null ? SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: ClampingScrollPhysics(),
            child: Theme(
              data: ThemeData(
                primaryColor: Colors.orange,
                hintColor: Colors.black,
              ),
              child: FutureBuilder(
                future: cart,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return Container(
                          child: Text(
                            "Error obteniendo el carrito del usuario"
                          )
                        );
                      } else {
                        _controller = new TextEditingController(text: instrucciones);
                        return Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  "Agrega instrucciones de entrega",
                                  style: TextStyle(
                                    fontSize: 16
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: TextField(
                                  decoration: InputDecoration(
                                    fillColor: Colors.grey.withAlpha(50),
                                    filled: true,
                                      border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(3.0)),
                                      borderSide: BorderSide(color: Colors.grey)
                                    )
                                  ),
                                  minLines: 5,
                                  maxLines: 10,
                                  controller: _controller,
                                  onChanged: (String textValue){
                                    print(textValue);
                                    instrucciones = textValue;
                                  },
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5, bottom: 5),
                                child: RaisedButton(
                                  color: DataUI.chedrauiColor,
                                  textColor: DataUI.whiteText,
                                  onPressed: () async{
                                    if(instrucciones.trim().length > 0){
                                      setState(() {
                                        flagLoad = true;
                                      });
                                      await CarritoServices.addCommentToCart(instrucciones);
                                      setState(() {
                                        flagLoad = false;
                                      });
                                      Navigator.pop(context, instrucciones);
                                    }
                                  },
                                  child: !flagLoad ? Text(
                                    "Guardar"
                                  ) : CircularProgressIndicator(),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 0,),
                                child: FlatButton(
                                  textColor: DataUI.btnbuy,
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Cancelar',
                                    style: TextStyle(
                                      fontSize: 14
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      }
                    break;
                    default:
                      return Container(
                        padding: EdgeInsets.only(left: 15, top: 20, bottom: 20, right: 15),
                        decoration: BoxDecoration(
                          color: Colors.white
                        ),
                        child: Center(
                          child: CircularProgressIndicator(),
                      )
                      );
                    break;
                  }
                }
              ),
            )
          )
        ) : Center(
          child: CircularProgressIndicator()
        )
      )
    );
  }
}