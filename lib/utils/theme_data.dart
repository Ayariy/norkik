import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:norkik_app/utils/color_util.dart';

ThemeData getNorkikTheme() {
  return ThemeData(
      brightness: Brightness.light,
      primaryColor: getPrimaryColor(),
      // primarySwatch: getMaterialColorPrimary().,
      cardColor: getCardColor(),
      iconTheme: const IconThemeData(color: Colors.black),
      appBarTheme: AppBarTheme(
          backgroundColor: getPrimaryColor(), foregroundColor: Colors.white),
      floatingActionButtonTheme:
          FloatingActionButtonThemeData(backgroundColor: getPrimaryColor()));
}

ThemeData getDarkTheme() {
  return ThemeData(
      brightness: Brightness.dark,
      appBarTheme: AppBarTheme(foregroundColor: Colors.white));
}
