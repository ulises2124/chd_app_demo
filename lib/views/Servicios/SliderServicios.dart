import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:flutter/material.dart';

class SliderServicios extends StatefulWidget {
  final dynamic slider;
  SliderServicios({Key key, this.slider}) : super(key: key);

  @override
  _SliderServiciosState createState() => _SliderServiciosState();
}

class _SliderServiciosState extends State<SliderServicios> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Center(
            // padding: const EdgeInsets.symmetric(horizontal: 31, vertical: 60),
            child: Image.asset(
              widget.slider['image'],
              width: 300,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 20.0),
          child: ListView.builder(
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: widget.slider['title'].length,
            itemBuilder: (context, index) {
              return Center(
                child: Text(
                  widget.slider['title'][index],
                  textAlign: TextAlign.center,
                  style: TextStyle(color: DataUI.chedrauiBlueColor, fontSize: 20.0, fontWeight: FontWeight.bold, fontFamily: 'Archivo'),
                ),
              );
            },
          ),
        ),
        Center(
          child: Builder(
            builder: (BuildContext context) {
              return ListView.builder(
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: widget.slider['subTitle'].length,
                itemBuilder: (context, index) {
                  return Center(
                    child: Text(
                      widget.slider['subTitle'][index],
                      style: TextStyle(color: HexColor('#212B36').withOpacity(0.7), fontFamily: 'Archivo', fontSize: 14, letterSpacing: 0.25),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
