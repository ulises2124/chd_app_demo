import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/SliderImg.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/views/ProductsPage/ProductsPage.dart';

// class BannersHome extends StatefulWidget {
//   final SliderImg sliderImg;
//   bool isBanner;
//   BannersHome({
//     Key key,
//     this.sliderImg,
//     this.isBanner
//   }) : super(key: key);

//   _BannersHomeState createState() => _BannersHomeState();
// }

// class _BannersHomeState extends State<BannersHome> {

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return AspectRatio(
//           aspectRatio: constraints.maxWidth < 350 ? 16 / 10 : 16 / 9,
//           child: InkResponse(
//             containedInkWell: true,
//             enableFeedback: true,
//             splashColor: DataUI.chedrauiColor,
//             child: new GestureDetector(
//               onTap: (){

//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ProductsPage(searchTerm: widget.sliderImg.url),
//                   ),
//                 );

//               },
//               child: new Container(
//                 margin: const EdgeInsets.only(left: 20, right: 20),
//                 padding: EdgeInsets.only(left: 10, right: 10,),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8.0),
//                   image: DecorationImage(
//                     image: NetworkImage( widget.sliderImg.imagen),
//                     //colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
//                     fit: BoxFit.fitWidth,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

class BannersHome extends StatelessWidget {
  final SliderImg sliderImg;
  final bool isBanner;

  const BannersHome({Key key, this.sliderImg, this.isBanner}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 7.5),
        // color: Colors.black,
        width: double.infinity,
        height: 230,
        // alignment: Alignment.center,
        child: CachedNetworkImage(
          fit: BoxFit.fill,
          imageUrl: sliderImg.imagen,
          placeholder: (context, url) => Center(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: RouteSettings(name: DataUI.productsRoute),
            builder: (context) => ProductsPage(searchTerm: sliderImg.url),
          ),
        );
      },
    );
  }
}
