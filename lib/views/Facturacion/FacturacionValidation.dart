bool _isNumeric(String str) {
  if (str == null) {
    return false;
  }
  return double.tryParse(str) != null;
}

String validateText(String value) {
  if (value.isEmpty) {
    return 'El campo no puede estar vacío';
  } else {
    return null;
  }
}

String validateEmail(String value) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value))
    return 'Introduce un correo electrónico válido';
  else
    return null;
}

String validateSucursal(String value) {
  if (value.isEmpty || int.parse(value) <= 0 || int.parse(value) > 9999) {
    return 'Introduce un número de sucursal válido';
  } else {
    return null;
  }
}

String validateRfc(String value) {
  Pattern pattern = r"(^[A-Z]{4}[0-9]{6})(.{3})$";
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value))
    return 'Introduce un RFC válido';
  else
    return null;
}

String validateTicket(String value) {
  if (value.isEmpty || value.length < 19 || !_isNumeric(value)) {
    return 'Introduce un número de ticket válido';
  } else {
    return null;
  }
}

String validateCP(String value) {
  if (value.isEmpty || int.parse(value) <= 0 || int.parse(value) > 99999 || value.length < 5) {
    return 'Introduce un código postal válido';
  } else {
    return null;
  }
}
