// import 'package:chedraui_flutter/services/ArticulosServices.dart';
// import 'package:chedraui_flutter/services/FireBaseServices.dart';
// import 'package:chedraui_flutter/utils/DataUI.dart';
// import 'package:chedraui_flutter/utils/HexValueConverter.dart';
// import 'package:chedraui_flutter/views/CategoryPage/SubCategoryPage.dart';
// import 'package:flutter/material.dart';
// import 'package:chedraui_flutter/services/CategoryServices.dart';

// class CategoryChip extends StatefulWidget {
//   final String apartmentId;

//   CategoryChip({Key key, this.apartmentId}) : super(key: key);

//   _CategoryChipState createState() => _CategoryChipState();
// }

// class _CategoryChipState extends State<CategoryChip> {
//   List data;
//   List productData;
//   String level = '1';
//   String url;
//   bool loading = false;
//   getSubcategorys() {
//     CategoryServices.getApartments().then((categorys) {
//       setState(() {
//         data = categorys;
//       });
//     });
//     return "Success!";
//   }

//   initState() {
//     this.getSubcategorys();
//     super.initState();
//   }

//   getProducts(id, name) {
//     setState(() {
//       loading = true;
//     });
//     if (id != null) {
//       switch (id.length) {
//         case 6:
//           level = '2';
//           break;
//         case 7:
//           level = '3';
//           break;
//         case 8:
//           level = '3';
//           break;
//         case 9:
//           level = '4';
//           break;
//         case 10:
//           level = '4';
//           break;
//         default:
//           level = "1";
//       }
//     }
//     url = ':relevance' + ':category_l_' + level + ':' + id;

//     ArticulosServices.getCategoryProductsFromHybris(url).then((products) {
//       setState(() {
//         productData = products['products'];
//       });
//       if (productData.length > 0) {
//         FireBaseEventController.sendAnalyticsEventSelectedCategory(name.toString(), '').then((ok) {});
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             settings: RouteSettings(name: DataUI.subCategoryRoute),
//             builder: (context) => SubCategoryPage(
//                   title: name.toString(),
//                   level: level,
//                   categoryID: id,
//                 ),
//           ),
//         );
//         setState(() {
//           loading = false;
//         });
//       } else {
//         setState(() {
//           loading = false;
//         });
//         _showResponseDialog();
//       }
//     });
//     return "Success!";
//   }

//   _showResponseDialog() {
//     return showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Búsqueda de productos"),
//             content: Text(
//                 'Pronto podrán ver estos productos en la aplicación, estamos trabajando en ello'),
//             actions: <Widget>[
//               FlatButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: Text(
//                   "Cerrar",
//                   style: TextStyle(
//                     color: HexColor('#454F5B'),
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ],
//           );
//         });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return data != null
//         ? SizedBox(
//             height: 100,
//             child: Container(
//               margin: EdgeInsets.only(top: 20, bottom: 20),
//               child: ListView.builder(
//                 physics: ClampingScrollPhysics(),
//                 // shrinkWrap: true,
//                 scrollDirection: Axis.horizontal,
//                 itemCount: data == null ? 0 : data.length,
//                 itemBuilder: (context, index) {
//                   return Row(
//                     children: <Widget>[
//                       data[index]['name'] != null
//                           ? Container(
//                               margin: EdgeInsets.only(left: 5.0, right: 5.0),
//                               child: InputChip(
//                                 backgroundColor: HexColor("#DFE3E8"),
//                                 onPressed: () {
//                                   loading == false
//                                       ? getProducts(data[index]['categoryCode'],
//                                           data[index]['name'])
//                                       : null;
//                                 },
//                                 label: Text(
//                                   data[index]['name'].toString(),
//                                   style: TextStyle(
//                                       color: HexColor("#454E5B"),
//                                       fontFamily: "Rubik",
//                                       fontSize: 14),
//                                 ),
//                               ),
//                             )
//                           : Container()
//                     ],
//                   );
//                 },
//               ),
//             ),
//           )
//         : Container(
//             child: Center(
//               child: CircularProgressIndicator(),
//             ),
//           );
//   }
// }
