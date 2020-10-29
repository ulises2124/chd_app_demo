import 'dart:convert';

import 'package:chd_app_demo/services/ArticulosServices.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PlacesCard extends StatefulWidget {
  final Widget child;

  PlacesCard({Key key, this.child}) : super(key: key);

  _PlacesCardState createState() => _PlacesCardState();
}

class _PlacesCardState extends State<PlacesCard> {
  List data;

  getProducts() {
    ArticulosServices.getProducts().then((response) {
      setState(() {
        var resBody = json.decode(response.body);
        data = resBody;
      });
    });
    return "Success!";
  }

  initState() {
    this.getProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300.0,
      child: ListView.builder(
        physics: ClampingScrollPhysics(),
        // shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: data == null ? 0 : data.length,
        itemBuilder: (context, index) {
          return Container(
            child: Row(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.0),
                    color: Colors.white,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: Offset(0, 8.0),
                        blurRadius: 10.0,
                      ),
                    ],
                  ),
                  width: 300.0,
                  height: 80.0,
                  margin: EdgeInsets.only(left: 6, right: 6),
                  padding: EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            data[index]["url"],
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 6,
                            top: 4,
                            bottom: 4,
                            right: 2,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Selecto Chedraui Plaza Samara Sante Fé Plaza Samara Sante Fé Plaza Samara Sante Fé Plaza Samara Sante Fé",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "Av. Antonio Dovali Jaime 70 Antonio Dovali Jaime 70 Antonio Dovali Jaime 70 Antonio Dovali Jaime 70 Antonio Dovali Jaime 70",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 8.0,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                              InkWell(
                                onTap: () => launch("tel://527773886112"),
                                child: Text(
                                  "527773886112",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
