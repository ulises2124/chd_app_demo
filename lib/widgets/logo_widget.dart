import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

class LogoChedraui extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var assetImage = new AssetImage('assets/logo/chedraui-isotype.png');
    var image = new Image(image: assetImage, width: 200, height: 200);
    return Container(
      child: image,
    );
    // SVG Support
    // final String assetName = 'assets/logo/chedraui-isotype.svg';
    // final Widget svg = new SvgPicture.asset(assetName, semanticsLabel: 'Chedraui Logo');
    // return svg;
  }
}
