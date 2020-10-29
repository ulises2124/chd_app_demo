import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Strings2 {
  static const String fieldReq = 'Requerido';
  static const String numberIsInvalid = 'Tarjeta Invalida';
}

class CardMonthInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var newText = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = new StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != newText.length) {
        buffer.write('/');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(text: string, selection: new TextSelection.collapsed(offset: string.length));
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = new StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write('  '); // Add double spaces.
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(text: string, selection: new TextSelection.collapsed(offset: string.length));
  }
}

class FormsTextValidators {
  // REGEX FOR  WhitelistingTextInputFormatter
  static RegExp commonPersonName = new RegExp("[a-zA-Z ]|[à-ú]|[À-Ú]");
  static RegExp lettersAndNumbers = new RegExp("[a-zA-Z ]|[à-ú]|[À-Ú]|[0-9]| [@]");
  static RegExp searchbar = new RegExp("[\u201C\u201D\!\:\&\|\(\)\~\+\*\?\¿\¡\-]");
  static RegExp searchbarWhiteList = new RegExp("[\u0000-~\u0080-þĀ-žƀ-ɎḀ-ỾⱠ-\u2c7e꜠-ꟾ]");

  static String validateEmail(String value) {
    String errorMessage = 'Correo no válido';
    Pattern pattern = r'^(([^<>()[\]\\.,+\{\};:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return errorMessage;
    } else {
      if (containsEmoji(value))
        return errorMessage;
      else
        return null;
    }
  }

  static String validateNewPasword(String value) {
    String errorMessage = 'La contraseña debe cumplir: \nUna mayúscula, \nUna minúscula, \nUn número, \nSer de 6 a 15 caracteres.';
    Pattern pattern = r'^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z]).{6,15}$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return errorMessage;
    } else {
      if (containsEmoji(value))
        return errorMessage;
      else
        return null;
    }
  }

  static String validateLoginPasword(String value) {
    String errorMessage = 'Ingresar contraseña válida';
    if (containsEmoji(value) || value.length == 0)
      return errorMessage;
    else
      return null;
  }

 static String validateTextWithoutEmoji(String value) {
    String errorMessage = 'Ingresar nombre válido';
    if (value.trim().length == 0  || containsEmoji(value))
      return errorMessage;
    else
      return null;
  }

  static String validateEmptyName(String value) {
    String errorMessage = 'Campo Requerido';
    if (value.trim().length < 3)
      return errorMessage;
    else
      return null;
  }

  static String validatePhone(String value) {
    String errorMessage = 'Campo Requerido';
    if (value.length < 10)
      return errorMessage;
    else
      return null;
  }

  static String validatePostalCode(String value) {
    String errorMessage = 'Campo Requerido';
    if (value.length < 5)
      return errorMessage;
    else
      return null;
  }

  static String validateDeliveryAddress(String value) {
    String errorMessage = 'Dirección no válida';
    RegExp regex = new RegExp(r'^[A-zÀ-ú0-9 .#-_]+$');
    if (!regex.hasMatch(value)) {
      return errorMessage;
    } else {
      if (containsEmoji(value))
        return errorMessage;
      else
        return null;
    }
  }

  static String validateDeliveryAddressInteriorNumber(String value) {
    String errorMessage = 'Número inválido';
    final regex = RegExp(r'^[a-zA-Z0-9]+$');
    if (value.length > 0) {
      if (!regex.hasMatch(value)) {
        return errorMessage;
      } else {
        if (containsEmoji(value))
          return errorMessage;
        else
          return null;
      }
    } else
      return null;
  }

  static String validateDeliveryAddressColonia(String value) {
    String errorMessage = 'Colonia no válida';
    RegExp regex = new RegExp(r'^[A-zÀ-ú0-9 .#]+$');
    if (!regex.hasMatch(value)) {
      return errorMessage;
    } else {
      if (containsEmoji(value))
        return errorMessage;
      else
        return null;
    }
  }

  static String validateNotEmpty(String value) {
    String errorMessage = 'Campo Requerido';
    if (value.isEmpty)
      return errorMessage;
    else
      return null;
  }

  static bool containsEmoji(String value) {
    RegExp regex = new RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');
    if (regex.hasMatch(value))
      return true;
    else
      return false;
  }
}

class FormsTextFormatters {
  static RegExp regexNames(){
    return RegExp("[a-zA-Z ]|[áéíóúü]|[ÁÉÍÓÚÜ]");
  }

  static RegExp regexAddressElements(){
    return RegExp("[a-zA-Z ]|[áéíóúü]|[ÁÉÍÓÚÜ]|[0-9]");
  }

}

