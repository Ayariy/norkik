import 'package:flutter/material.dart';

Container getLogoNorkikWithTheme(context, double width) {
  String urlLogoTheme = "assets/Norkik.png";

  if (Theme.of(context).brightness == Brightness.dark) {
    urlLogoTheme = "assets/NorkikBlanco.png";
  }
  return Container(
    alignment: Alignment.center,
    child: FadeInImage(
        width: width,
        fit: BoxFit.cover,
        placeholder: AssetImage('assets/loadingUno.gif'),
        image: AssetImage(urlLogoTheme)),
  );
}
