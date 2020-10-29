import 'dart:convert';

import 'package:chd_app_demo/services/ArticulosServices.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/utils/classBanner.dart';
import 'package:chd_app_demo/views/CategoryPage/CategoryPage.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/DataUI.dart';

class BannerCard extends StatefulWidget {
  final BannerCardData bannerCardData;
  final Function onPressCallback;
  BannerCard(
    this.onPressCallback, {
    Key key,
    this.bannerCardData,
  }) : super(key: key);

  _BannerCardState createState() => _BannerCardState();
}

class _BannerCardState extends State<BannerCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AspectRatio(
          aspectRatio: constraints.maxWidth < 350 ? 16 / 10 : 16 / 9,
          child: InkResponse(
            containedInkWell: true,
            enableFeedback: true,
            onTap: () {
              widget.onPressCallback();
            },
            splashColor: DataUI.chedrauiColor,
            child: Container(
              margin:
                  const EdgeInsets.only(left: 20, right: 20, bottom: 8, top: 8),
              padding: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/' + widget.bannerCardData.imageUrl),
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.6), BlendMode.darken),
                  fit: BoxFit.cover,
                ),
              ),
              child: Flex(
                direction: Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                            widget.bannerCardData.callToAction.toUpperCase(),
                            textAlign:
                                widget.bannerCardData.callToActionAlignment,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: HexColor("#FFD600"),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                            widget.bannerCardData.title.toUpperCase(),
                            textAlign: widget.bannerCardData.titleAlignment,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 26.0,
                              color: HexColor("#F4F6F8"),
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                            widget.bannerCardData.description.length > 0
                                ? widget.bannerCardData.description
                                : '\n',
                            textAlign:
                                widget.bannerCardData.descriptionAlignment,
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: HexColor("#F9FAFB"),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      widget.bannerCardData.disclaimer,
                      textAlign: widget.bannerCardData.disclaimerAlignment,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 10.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
