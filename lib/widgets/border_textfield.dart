import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/DataUI.dart';

class BorderedTextField extends StatelessWidget {
  final String text;
  var textObscured = false;
  Icon dIcon = new Icon(null);

  BorderedTextField(
      {@required this.text, this.dIcon, @required this.textObscured});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 8.0),
      child: new TextFormField(
          decoration: new InputDecoration(
            // labelText: text,
            icon: dIcon,
            hintText: text,
            // helperText: "",
            // prefixText: ' ',
            // suffixText: ' ',
            // suffixStyle: const TextStyle(color: Colors.black),
            // fillColor: DataUI.whiteText,
            border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(25.0),
              borderSide: new BorderSide(
                  //color: DataUI.chedrauiColor,
                  width: 2.0),
            ),
          ),
          validator: (input) {
            if (input.length == 0) {
              return "Email cannot be empty";
            } else {
              return null;
            }
          },
          onSaved: (input) {},
          keyboardType: TextInputType.emailAddress,
          style: new TextStyle(
            fontWeight: FontWeight.w200,
          ),
          obscureText: textObscured,
          textAlign: TextAlign.center),
    );
  }
}
