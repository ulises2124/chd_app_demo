import 'package:flutter/services.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  TextEditingValue formatEditUpdate(
      TextEditingValue originalString, TextEditingValue newString) {
    return newString.copyWith(text: newString.text.toUpperCase());
  }
}