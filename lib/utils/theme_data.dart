import 'package:flutter/material.dart';
import 'package:norkik_app/utils/color_util.dart';

ThemeData getNorkikTheme() {
  return ThemeData(
      brightness: Brightness.light,
      primaryColor: getPrimaryColor(),
      cardColor: getCardColor(),
      iconTheme: const IconThemeData(color: Colors.black),
      appBarTheme: AppBarTheme(
          backgroundColor: getPrimaryColor(), foregroundColor: Colors.white),
      floatingActionButtonTheme:
          FloatingActionButtonThemeData(backgroundColor: getPrimaryColor()));
}

ThemeData getColorTheme(Color colorPrimary, TextTheme? textTheme) {
  return ThemeData(
      brightness: Brightness.light,
      primaryColor: colorPrimary,
      textTheme: textTheme,
      // fontFamily: ,
      // primarySwatch: getMaterialColorPrimary().,
      cardColor: getCardColor(),
      iconTheme: IconThemeData(color: colorPrimary),
      appBarTheme: AppBarTheme(
          backgroundColor: colorPrimary, foregroundColor: Colors.white),
      floatingActionButtonTheme:
          FloatingActionButtonThemeData(backgroundColor: colorPrimary));
}

ThemeData getDarkTheme(TextTheme? textTheme) {
  return ThemeData(
      brightness: Brightness.dark,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(foregroundColor: Colors.white));
}
