import 'package:chd_app_demo/services/UserProfileServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/views/CuentaPage/CuentaPage.dart';
import 'package:chd_app_demo/views/Errors/NetworkErrorPage/NetworkErrorPage.dart';
import 'package:chd_app_demo/views/MasterPage/MasterPage.dart';
import 'package:chd_app_demo/views/MasterPage/MenuScreen.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SelectInterest extends StatefulWidget {
  final String clienteID;

  SelectInterest({
    Key key,
    this.clienteID,
  }) : super(key: key);

  @override
  SelectInterestState createState() => SelectInterestState();
}

class SelectInterestState extends State<SelectInterest> {
  var interest;
  bool _isUpdatingPreferences = false;
  Future interestResponse;
  @override
  void initState() {
    super.initState();
    getInterest();
    // UserProfileServices.getUserInterests().then((response) {
    //   setState(() {
    //     interest = response['clubes'];
    //     // for (var item in interest) {
    //     //   print(item['descripcion']);
    //     //   print(item['activo']);
    //     //   print('\n');
    //     // }
    //   });
    // });
  }

  void getInterest() async {
    _isUpdatingPreferences = true;
    interestResponse = UserProfileServices.getUserInterests();
    var response = await interestResponse;
    setState(() {
      interest = response['clubes'];
      _isUpdatingPreferences = false;
      // for (var item in interest) {
      //   print(item['descripcion']);
      //   print(item['activo']);
      //   print('\n');
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 12, right: 12),
        padding: EdgeInsets.only(top: 12, bottom: 12),
        color: Colors.white,
        child: FutureBuilder(
          future: interestResponse,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
                break;
              case ConnectionState.active:
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
                break;
              case ConnectionState.none:
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
                break;
              case ConnectionState.done:
                if (snapshot.hasError) {
                 if (snapshot.error.toString().contains('No Internet connection')) {
                          return NetworkErrorPage(
                            showGoHomeButton: false,
                          );
                        } else {
                          return NetworkErrorPage(
                            errorMessage: 'Ha ocurrido un error, por favor inténtalo más tarde',
                            showGoHomeButton: true,
                          );
                        }
                } else if (snapshot.hasData && snapshot.data != null) {
                  return !_isUpdatingPreferences
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                'Selecciona tus intereses de compra',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            AnimatedCrossFade(
                              sizeCurve: Curves.easeInOut,
                              duration: const Duration(milliseconds: 280),
                              crossFadeState: interest == null ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                              firstChild: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              secondChild: GridView.builder(
                                physics: ClampingScrollPhysics(),
                                shrinkWrap: true,
                                primary: true,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 4,
                                  mainAxisSpacing: 4,
                                  // childAspectRatio: constraints.maxWidth < 350 ? 22 / 32 : 22 / 32,
                                ),
                                itemCount: interest == null ? 0 : interest.length,
                                itemBuilder: (context, index) {
                                  return InkResponse(
                                    containedInkWell: true,
                                    enableFeedback: true,
                                    splashColor: DataUI.chedrauiColor,
                                    onTap: () {
                                      setState(() {
                                        interest[index]['activo'] = !interest[index]['activo'];
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: interest[index]['activo']
                                            ? Border.all(
                                                color: DataUI.chedrauiColor,
                                                width: 3,
                                              )
                                            : Border.all(
                                                color: Colors.white,
                                                width: 0,
                                              ),
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        image: DecorationImage(
                                          // image: CachedNetworkImageProvider(interest[index]['url']),
                                          image: interest[index]['url'].toString().contains('kosher')
                                              ? AssetImage(
                                                  'assets/interest/kosher-certification-service-500x500.png',
                                                )
                                              : AssetImage(
                                                  interest[index]['url'].toString().replaceAll('https://cms.chedraui.com.mx/chedraui/mis_intereses', 'assets/interest'),
                                                ),
                                          colorFilter: interest[index]['activo'] ? ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken) : ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.darken),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      padding: EdgeInsets.all(2),
                                      alignment: Alignment.center,
                                      child: Text(
                                        interest[index]['descripcion'],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: DataUI.whiteText,
                                          shadows: <Shadow>[
                                            Shadow(
                                              offset: Offset(-1.0, 2.0),
                                              blurRadius: 2.0,
                                              color: Colors.black,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10),
                                    child: RaisedButton(
                                      color: DataUI.btnbuy,
                                      child: Text(
                                        'Guardar Cambios',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      onPressed: () {
                                        updateUserInterest(widget.clienteID);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                } else {
                  return NetworkErrorPage(
                    errorMessage: 'Ha ocurrido un error, por favor inténtalo más tarde',
                    showGoHomeButton: true,
                  );
                }
                break;
              default:
                return Container();
            }
          },
        ));
  }

  Future updateUserInterest(String clienteID) async {
    setState(() {
      _isUpdatingPreferences = true;
    });
    var result = await UserProfileServices.clientescrmEditUserInterest(interest, clienteID);
    // setState(() {
    //   _isUpdatingPreferences = false;
    // });
    print(result.toString());
    if (result != null && result['statusOperation']['code'] == 0) {
      _showConfirmationDialog(true);
    } else {
      _showConfirmationDialog(false);
    }
  }

  void _showConfirmationDialog(bool success) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            success ? 'Listo!' : 'Lo sentimos',
          ),
          content: Text(
            success ? 'Tus preferencias se han actualizado correctamente' : 'Por favor intentar la operación más tarde',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: DataUI.textOpaque,
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: FlatButton(
                onPressed: () {
                  getInterest();
                  Navigator.pop(context);

                  // Navigator.of(context).pushAndRemoveUntil(
                  //   MaterialPageRoute(
                  //     builder: (BuildContext context) => MasterPage(
                  //           initialWidget: MenuItem(
                  //             id: 'cuenta',
                  //             title: ' ',
                  //             screen: CuentaPage(),
                  //             color: DataUI.backgroundColor,
                  //           ),
                  //         ),
                  //   ),
                  //   (Route<dynamic> route) => false,
                  // );
                  // Navigator.pop(context);
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (BuildContext context) => MasterPage(
                  //           initialWidget: CuentaPage(),
                  //         ),
                  //   ),
                  // );
                },
                child: Text(
                  "Continuar",
                  style: TextStyle(
                    color: DataUI.chedrauiBlueColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
