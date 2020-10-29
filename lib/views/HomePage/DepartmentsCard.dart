import 'package:chd_app_demo/services/FireBaseServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/Errors/NetworkErrorPage/NetworkErrorPage.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:chd_app_demo/widgets/comparadorBanner.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/services/CategoryServices.dart';
import 'package:chd_app_demo/views/CategoryPage/CategoryPage.dart';

class DepartmentsCard extends StatefulWidget {
  final Widget child;

  DepartmentsCard({Key key, this.child}) : super(key: key);

  _DepartmentsCardState createState() => _DepartmentsCardState();
}

class _DepartmentsCardState extends State<DepartmentsCard> {
  Future response;
  var favorite = Icon(Icons.favorite_border, size: 18.0);
  var dataSuper;

  var data;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getApartment(),
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
               data = snapshot.data;
                if (data[0]['name'] == 'Súper') {
                  dataSuper = data[0];
                  data.removeWhere((item) => item['name'] == 'Súper');
                }
              return AnimatedCrossFade(
                sizeCurve: Curves.easeInOut,
                duration: const Duration(milliseconds: 280),
                crossFadeState: data.length > 0 ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                secondChild: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                firstChild: Column(
                  children: <Widget>[
                    Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
                    padding: EdgeInsets.only(bottom: 0, top: 15, right: 5, left: 5),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(child: getSuperCards(dataSuper)),
                        GridView.count(
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          primary: true,
                          crossAxisCount: 3,
                          mainAxisSpacing: 18,
                          children: List.generate(
                            data.length == 0 ? 0 : 6,
                            (index) {
                              return getApartmentCards(data[index]);
                            },
                          ),
                        ),
                        
                      ],
                    )),

                    Comparador(),
                  ],
                )
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
    );
  }

  ////////////////////////////////////////////////////////////////////////////

  initState() {
    getApartment();
    super.initState();
  }

  Future getApartment() async {
    response = CategoryServices.getApartments();
    return response;
  }

  getApartmentCards(departament) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          FireBaseEventController.sendAnalyticsEventSelectedDepartment(departament['name']).then((ok) {});
          Navigator.push(
            context,
            MaterialPageRoute(
              settings: RouteSettings(name: DataUI.categoryRoute),
              builder: (context) => CategoryPage(
                apartmentId: departament['categoryCode'],
                apartmentName: departament['name'].toString(),
              ),
            ),
          );
          // Navigator.of(context).pushAndRemoveUntil(
          //   MaterialPageRoute(
          //     builder: (BuildContext context) => MasterPage(
          //       initialWidget: MenuItem(
          //         id: 'categoria',
          //         title: departament['name'].toString(),
          //         screen: CategoryPage(
          //           apartmentId: departament['id'],
          //           apartmentName: departament['name'].toString(),
          //         ),
          //         color: DataUI.chedrauiColor2,
          //         textColor: DataUI.primaryText,
          //       ),
          //     ),
          //   ),
          //   (Route<dynamic> route) => false,
          // );
        },
        enableFeedback: true,
        splashColor: DataUI.chedrauiColor,
        child: Container(
          // margin: EdgeInsets.only(right: 5, left: 5, bottom: 9),
          child: Column(
            children: <Widget>[
              Container(
                child: MCSVG(40, departament['categoryCode']),
              ),
              Container(
                // margin: EdgeInsets.only(top: 30.0),
                padding: EdgeInsets.fromLTRB(0, 20, 0, 4),
                alignment: Alignment.bottomCenter,
                // height: 120.0,
                // width: 120.0,
                child: Text(
                  departament['name'].toString(),
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 12.0,
                    fontFamily: 'Archivo',
                    color: HexColor('#0D47A1'),
                    fontWeight: FontWeight.bold,
                    // letterSpacing: 0.35
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getSuperCards(departament) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          FireBaseEventController.sendAnalyticsEventSelectedDepartment(departament['name']).then((ok) {});
          Navigator.push(
            context,
            MaterialPageRoute(
              settings: RouteSettings(name: DataUI.categoryRoute),
              builder: (context) => CategoryPage(
                apartmentId: departament['categoryCode'],
                apartmentName: departament['name'].toString(),
              ),
            ),
          );
        },
        enableFeedback: true,
        splashColor: DataUI.chedrauiColor,
        child: Container(
          // margin: EdgeInsets.only(right: 5, left: 5, bottom: 9),
          child: Column(
            children: <Widget>[
              Container(
                child: MCSVG(90, departament['categoryCode']),
              ),
              Container(
                // margin: EdgeInsets.only(top: 30.0),
                padding: EdgeInsets.fromLTRB(2, 20, 2, 4),
                alignment: Alignment.bottomCenter,
                // height: 120.0,
                // width: 120.0,
                child: Text(
                  departament['name'].toString(),
                  softWrap: true,
                  style: TextStyle(fontSize: 18.0, fontFamily: 'Archivo', color: HexColor('#0D47A1'), fontWeight: FontWeight.bold, letterSpacing: 0.35),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 30, top: 15),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: HexColor('#CFCFCF')),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
