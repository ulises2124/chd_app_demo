import 'package:chd_app_demo/services/ArticulosServices.dart';
import 'package:chd_app_demo/services/FireBaseServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/CategoryPage/CategoryPage.dart';
import 'package:chd_app_demo/views/CategoryPage/SubCategoryPage.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/services/CategoryServices.dart';

class CategorySlider extends StatefulWidget {
  CategorySlider({Key key}) : super(key: key);

  _CategorySliderState createState() => _CategorySliderState();
}

class _CategorySliderState extends State<CategorySlider> {
  List data;

  Future getApartment() async {
    await CategoryServices.getApartments().then((categorys) {
      if (categorys != null) {
        if (mounted) {
          setState(() {
            data = categorys;
          });
        }
      }
    });
    return "Success!";
  }

  initState() {
    this.getApartment();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return data != null
        ? Container(
            margin: EdgeInsets.only(top: 0, bottom: 0, left: 0, right: 0),
            height: 40,
            child: Container(
              child: ListView.builder(
                physics: ClampingScrollPhysics(),
                // shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: data == null ? 0 : data.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: <Widget>[
                      data[index]['name'] != null
                          ? Container(
                              margin: EdgeInsets.only(left: 5.0, right: 5.0),
                              child: InputChip(
                                clipBehavior: Clip.none,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                                backgroundColor: HexColor("#0D47A1"),
                                onPressed: () {
                                  // print(data[index]['name']);
                                  // print(data[index]['categoryCode']);
                                  // CategoryServices.getSubCategorys(data[index]['categoryCode']).then((response) {
                                  //   print(response);
                                  // });
                                  FireBaseEventController.sendAnalyticsEventSelectedDepartment(data[index]['name'].toString()).then((ok) {});
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      settings: RouteSettings(name: DataUI.categoryRoute),
                                      builder: (context) => CategoryPage(
                                        apartmentId: data[index]['categoryCode'],
                                        apartmentName:
                                            data[index]['name'].toString(),
                                      ),
                                    ),
                                  );
                                },
                                label: Text(
                                  data[index]['name'],
                                  style: TextStyle(color: HexColor("#FFFFFF"), fontFamily: "Archivo", fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            )
                          : Container()
                    ],
                  );
                },
              ),
            ),
          )
        : Container(
            child: Center(
              child: SizedBox(),
            ),
          );
  }
}
