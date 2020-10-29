

// import 'package:chedraui_flutter/utils/HexValueConverter.dart';
// import 'package:flutter/material.dart';

// class MainBottomNavigationItem extends StatefulWidget {
//   final String displayText;
//   final Icon displayIcon;
//   Function(String, [bool]) bottomNavigationController;

//   MainBottomNavigationItem(
//     this.bottomNavigationController, {
//     Key key,
//     @required this.displayText,
//     @required this.displayIcon,
//   }) : super(key: key);

//   @override
//   _MainBottomNavigationItemState createState() => _MainBottomNavigationItemState();
// }

// class _MainBottomNavigationItemState extends State<MainBottomNavigationItem> {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: <Widget>[
//         IconButton(
//           icon: widget.displayIcon,
//           color: HexColor('#212B36'),
//           onPressed: () {
//             widget.bottomNavigationController(widget.displayText, false);
//           },
//         ),
//         Text(
//           widget.displayText,
//           style: TextStyle(
//             fontSize: 10.0,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
// }
