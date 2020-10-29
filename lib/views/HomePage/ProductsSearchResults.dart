import 'package:chd_app_demo/services/ArticulosServices.dart';
import 'package:chd_app_demo/services/FireBaseServices.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/ProductPage/ProductPage.dart';
import 'package:chd_app_demo/widgets/SvgWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ProductSearchResults extends StatefulWidget {
  final Widget child;
  final TextEditingController searchBoxController;

  ProductSearchResults({
    Key key,
    this.child,
    this.searchBoxController,
  }) : super(key: key);

  @override
  ProductSearchResultsState createState() => ProductSearchResultsState();
}

class ProductSearchResultsState extends State<ProductSearchResults> {
  List data;
  String query = '';
  String url;
  int totalResultsFinal = 0;
  bool loading = false;
  @override
  void initState() {
    super.initState();
    query = widget.searchBoxController.text.replaceAll(' ', '+');
    //doSearch();
  }

  doSearch() {
    setState(() {
      loading = true;
    });
    query = widget.searchBoxController.text.replaceAll(' ', '+');
    url = query + '&fields=BASIC';
    print('doSearch: ' + query);
    ArticulosServices.getProductsHybrisSearch(url).then(
      (products) {
        if (products != null) {
          totalResultsFinal = products['pagination']['totalResults'];
          setState(() {
            data = products['products'];
            loading = false;
          });
        }
      },
    );
    return "Success!";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: loading ? Colors.transparent : HexColor('#F4F6F8'),
      child: loading
          ? Container(
              margin: EdgeInsets.only(top: 30),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(height: 120, width: 120, child: BuscarIconSVG(true)),
                  Container(
                    margin: EdgeInsets.only(top: 40, bottom: 20),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Su consulta de búsqueda se está',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: HexColor('#454F5B'), fontFamily: 'Rubik', fontSize: 14),
                        ),
                        Text(
                          'procesando ...',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: HexColor('#454F5B'), fontFamily: 'Rubik', fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 96,
                    height: 2,
                    child: LinearProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(HexColor('#454F5B').withOpacity(0.5)),
                      backgroundColor: HexColor('#CFCED5'),
                    ),
                  )
                ],
              ))
          : ListView.separated(
              separatorBuilder: (context, index) {
                return Divider();
              },
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: data == null ? 0 : data.length,
              padding: EdgeInsets.symmetric(vertical: 0),
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 15,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: IconButton(
                                color: HexColor('#212B36').withOpacity(0.5),
                                onPressed: () {
                                  widget.searchBoxController.text = data[index]['name'];
                                  doSearch();
                                },
                                icon: Icon(Icons.search),
                              ),
                            ),
                            Expanded(
                              flex: 15,
                              child: FlatButton(
                                onPressed: () {
                                  FireBaseEventController.sendAnalyticsEventSearchResults(widget.searchBoxController.text, totalResultsFinal).then((ok) {});
                                  // FireBaseEventController.sendAnalyticsEventViewItem(data[index]['code'], data[index]['name'], '').then((ok) {});
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      settings: RouteSettings(name: DataUI.productRoute),
                                      builder: (context) => ProductPage(
                                        // data: data[index],
                                        code: data[index]['code'],
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.8,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    data[index]['name'],
                                    maxLines: 1,
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: HexColor('#212B36').withOpacity(0.5)),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: IconButton(
                          color: HexColor('#212B36').withOpacity(0.5),
                          onPressed: () {
                            FireBaseEventController.sendAnalyticsEventSearchResults(widget.searchBoxController.text, totalResultsFinal).then((ok) {});
                            // FireBaseEventController.sendAnalyticsEventViewItem(data[index]['code'], data[index]['name'], '').then((ok) {});
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                settings: RouteSettings(name: DataUI.productRoute),
                                builder: (context) => ProductPage(
                                  // data: data[index],
                                  code: data[index]['code'],
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.arrow_forward_ios),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}
