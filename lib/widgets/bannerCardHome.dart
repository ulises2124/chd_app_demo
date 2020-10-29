import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chd_app_demo/services/ArticulosServices.dart';
import 'package:chd_app_demo/services/FireBaseServices.dart';
import 'package:chd_app_demo/services/HomeServices.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/utils/classBanner.dart';
import 'package:chd_app_demo/views/CategoryPage/CategoryPage.dart';
import 'package:chd_app_demo/views/CategoryPage/SubCategoryPage.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/SliderImg.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/views/ProductsPage/ProductsPage.dart';
import 'package:chd_app_demo/views/ProductPage/ProductPage.dart';

class BannerCardHome extends StatefulWidget {
  final SliderImg sliderImg;
  bool isBanner;
  BannerCardHome({Key key, this.sliderImg, this.isBanner}) : super(key: key);

  _BannerCardHomeState createState() => _BannerCardHomeState();
}

class _BannerCardHomeState extends State<BannerCardHome> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dynamic product;
    bool loadingContet = false;

    return LayoutBuilder(
      builder: (context, constraints) {
        return AspectRatio(
          aspectRatio: constraints.maxWidth < 350 ? 16 / 10 : 16 / 9,
          child: GestureDetector(
            onTap: () async {
              if (!loadingContet) {
                loadingContet = true;
                try {
                  if (!widget.isBanner) {
                    await HomeServices.getProductHybrisSearch(widget.sliderImg.url).then((productData) {
                      print(productData);
                      print(widget.sliderImg.url);
                      Navigator.push(
                        context,
                        MaterialPageRoute(settings: RouteSettings(name: DataUI.productRoute), builder: (context) => ProductPage(data: productData)),
                      );
                      FireBaseEventController.sendAnalyticsEventViewItem(productData, productData['name'], '').then((ok) {});
                      
                    });
                  } else {
                    if (widget.sliderImg.url == 'martimiercoles') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: RouteSettings(name: DataUI.productsRoute),
                          builder: (context) => SubCategoryPage(
                            title: widget.sliderImg.url.toUpperCase(),
                            categoryID: 'MC2101',
                            level: '2',
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: RouteSettings(name: DataUI.productsRoute),
                          builder: (context) => ProductsPage(searchTerm: widget.sliderImg.url),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  loadingContet = false;
                }
              }
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              // color: Colors.black,
              width: double.infinity,
              // alignment: Alignment.center,
              child: CachedNetworkImage(
                fit: BoxFit.fitWidth,
                imageUrl: widget.sliderImg.imagen,
                placeholder: (context, url) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
        );
      },
    );
  }
}
