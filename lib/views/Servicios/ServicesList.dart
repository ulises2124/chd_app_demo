import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget getLogo(String serviceName) {
  return Container(
    width: 155,
    height: 110,
    child: CachedNetworkImage(
      imageUrl: serviceName,
    ),
  );
}

Widget getToolTip(String serviceName) {
  return CachedNetworkImage(
    imageUrl: serviceName,
  );
}
