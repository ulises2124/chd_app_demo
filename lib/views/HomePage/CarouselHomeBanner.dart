import 'package:carousel_slider/carousel_slider.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/widgets/bannerCardHome.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/classBanner.dart';
import 'package:chd_app_demo/utils/SliderImg.dart';

class CarouselHomeBanner extends StatefulWidget {
  List<SliderImg> sliders;
  String title;
  double size;
  bool foot;
  CarouselHomeBanner({Key key, this.sliders, this.size, this.foot, this.title}) : super(key: key);
  @override
  _CarouselHomeBannerState createState() => _CarouselHomeBannerState();
}

class _CarouselHomeBannerState extends State<CarouselHomeBanner> {
  int _current = 0;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              widget.title != null
                  ? Container(
                      width: 45,
                      height: 5,
                      margin: EdgeInsets.only(left: 15),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(width: 5.0, color: HexColor('#FBC02D')),
                        ),
                      ),
                    )
                  : SizedBox(),
              widget.title != null
                  ? Container(
                      margin: constraints.maxWidth < 350 ? EdgeInsets.only(left: 15.0, bottom: 0) : EdgeInsets.only(left: 15.0, bottom: 15),
                      padding: const EdgeInsets.only(right: 20, top: 15, bottom: 0),
                      child: Text(
                        widget.title,
                        overflow: TextOverflow.clip,
                        maxLines: 2,
                        style: TextStyle(
                          color: HexColor('#0D47A1'),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Archivo',
                          fontSize: 20,
                        ),
                      ),
                    )
                  : SizedBox(height: 0),
            ],
          ),
          CarouselSlider(
            options: CarouselOptions(
              height: widget.foot == true ? 280 : 230,
              autoPlay: false,
              aspectRatio: constraints.maxWidth < 350 ? 16 / 10 : 16 / 9,
              viewportFraction: widget.size,
              onPageChanged: (index, e) {
                setState(
                  () {
                    _current = index;
                  },
                );
              },
            ),
            items: widget.sliders.map(
              (i) {
                return Builder(
                  builder: (BuildContext context) {
                    return BannerCardHome(
                      sliderImg: i,
                      isBanner: widget.foot,
                    );
                  },
                );
              },
            ).toList(),
          ),
          Container(
            margin: constraints.maxWidth < 350 ? EdgeInsets.only(top: 0) : EdgeInsets.only(top: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: map<Widget>(
                widget.sliders,
                (index, url) {
                  return Container(
                    width: _current == index ? 17 : 8.0,
                    height: 5.0,
                    // padding: EdgeInsets.only(top: 20),
                    margin: EdgeInsets.symmetric(horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: _current == index ? BoxShape.rectangle : BoxShape.circle,
                      borderRadius: _current == index ? BorderRadius.circular(10) : null,
                      color: _current == index ? HexColor("#F57C00") : HexColor("#F57C00").withOpacity(0.5),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      );
    });
  }
}

List<T> map<T>(List list, Function handler) {
  List<T> result = [];
  for (var i = 0; i < list.length; i++) {
    result.add(handler(i, list[i]));
  }

  return result;
}
