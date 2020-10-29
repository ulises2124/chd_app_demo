String validateReferenceCfe(String value) {
  if (value.isEmpty) {
    return 'Introduce un número de referencia válido';
  } else {
    return null;
  }
}

 String validateNotEmpty(String value) {
    String errorMessage = 'Introduce un dígito verificador válido';
    if (value.isEmpty)
      return errorMessage;
    else
      return null;
  }


  String validatePhone(String value) {
    String errorMessage = 'Introduce un número de referencia válido';
    if (value.length < 10 || value.length > 10)
      return errorMessage;
    else
      return null;
  }