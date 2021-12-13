import 'package:flutter/material.dart';

Color getPrimaryColor() {
  return Color.fromRGBO(42, 74, 77, 1);
}

Color getCardColor() {
  return Color.fromRGBO(230, 230, 230, 1);
}

MaterialColor getMaterialColorPrimary() {
  Map<int, Color> colorCodes = {
    50: Color(0xffdeeced),
    100: Color(0xffadcfd2),
    200: Color(0xff7bb2b7),
    300: Color(0xff487f84),
    400: Color(0xff365f63),
    500: Color(0xff2a4a4d),
    600: Color(0xff243f42),
    700: Color(0xff1b2f31),
    800: Color(0xff122021),
    900: Color(0xff091010)
  };
  return MaterialColor(0XFF2A4A4D, colorCodes);
}
