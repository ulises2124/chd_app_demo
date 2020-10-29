import 'package:flutter/widgets.dart';

class BannerCardData {
  String callToAction = '';
  TextAlign callToActionAlignment = TextAlign.left;
  String title = '';
  TextAlign titleAlignment = TextAlign.left;
  String description = '';
  TextAlign descriptionAlignment = TextAlign.left;
  String disclaimer = '';
  TextAlign disclaimerAlignment = TextAlign.left;
  String imageUrl = '';

  BannerCardData({
    this.callToAction,
    this.callToActionAlignment,
    this.title,
    this.titleAlignment,
    this.description,
    this.descriptionAlignment,
    this.disclaimer,
    this.disclaimerAlignment,
    this.imageUrl,
  });
}

final banner1 = BannerCardData(
  callToAction: 'Descubre',
  title: 'la Nueva Tienda Chedraui',
  description: 'y llevate un 10% de descuento en tu compra',
  disclaimer: '',
  imageUrl: '1.png',
  callToActionAlignment: TextAlign.left,
  titleAlignment: TextAlign.left,
  descriptionAlignment: TextAlign.left,
  disclaimerAlignment: TextAlign.right,
);

final banner2 = BannerCardData(
  callToAction: 'Aprovecha',
  title: 'La feria del Colchón.',
  description:
      '\$100 de descuento por cada \$1000 de compra en todos los colchones.',
  disclaimer: 'Vigencia del 1 al 20 de Marzo del 2019.',
  imageUrl: '2.jpg',
  callToActionAlignment: TextAlign.left,
  titleAlignment: TextAlign.left,
  descriptionAlignment: TextAlign.left,
  disclaimerAlignment: TextAlign.right,
);

final banner4 = BannerCardData(
  callToAction: 'Precio Especial',
  title: 'en artículos de campismo.',
  description: '',
  disclaimer: 'Vigencia del 1 al 20 de Marzo del 2019.',
  imageUrl: '4.png',
  callToActionAlignment: TextAlign.left,
  titleAlignment: TextAlign.left,
  descriptionAlignment: TextAlign.left,
  disclaimerAlignment: TextAlign.left,
);

final banner5 = BannerCardData(
  callToAction: 'KD-49X72',
  title: 'Televisor Sony SmartTV4k',
  description: 'Antes: \$15,495  \$15,495',
  disclaimer: 'Vigencia del 1 al 20 de Marzo del 2019.',
  imageUrl: '5.png',
  callToActionAlignment: TextAlign.right,
  titleAlignment: TextAlign.right,
  descriptionAlignment: TextAlign.right,
  disclaimerAlignment: TextAlign.right,
);

final banner6 = BannerCardData(
  callToAction: '',
  title: 'Ubica tu tienda',
  description: 'Encuentra el Chedraui más cerca de ti',
  disclaimer: '',
  imageUrl: 'ubica.jpg',
  callToActionAlignment: TextAlign.left,
  titleAlignment: TextAlign.center,
  descriptionAlignment: TextAlign.center,
  disclaimerAlignment: TextAlign.left,
);
