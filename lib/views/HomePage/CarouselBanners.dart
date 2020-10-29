import 'package:carousel_slider/carousel_slider.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/widgets/bannerCard.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/classBanner.dart';

class CarouselBannerCard extends StatefulWidget {
  @override
  _CarouselBannerCardState createState() => _CarouselBannerCardState();
}

class _CarouselBannerCardState extends State<CarouselBannerCard> {
  List items = [banner1, banner2, banner4];
  int _current = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(builder: (context, constraints) {
          return CarouselSlider(
            options: CarouselOptions(
              autoPlay: false,
              aspectRatio: constraints.maxWidth < 350 ? 16 / 10 : 16 / 9,
              viewportFraction: 1.0,
              onPageChanged: (index, e) {
                setState(
                  () {
                    _current = index;
                  },
                );
              },
            ),
            items: items.map(
              (i) {
                return Builder(
                  builder: (BuildContext context) {
                    return BannerCard(
                      () {},
                      bannerCardData: i,
                    );
                  },
                );
              },
            ).toList(),
          );
        }),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: map<Widget>(
            items,
            (index, url) {
              return Container(
                width: _current == index ? 24 : 8.0,
                height: 5.0,
                margin: EdgeInsets.symmetric(horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: _current == index ? BoxShape.rectangle : BoxShape.circle,
                  borderRadius: _current == index ? BorderRadius.circular(10) : null,
                  color: _current == index ? HexColor("#0D47A1") : HexColor("#0D47A1").withOpacity(0.5),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

List<T> map<T>(List list, Function handler) {
  List<T> result = [];
  for (var i = 0; i < list.length; i++) {
    result.add(handler(i, list[i]));
  }

  return result;
}
