import 'package:flutter/material.dart';
import 'package:log_keep/app/theme/theme_constants.dart';

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: appBarTheme(),
    textTheme: textTheme(),
    inputDecorationTheme: inputDecorationTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

InputDecorationTheme inputDecorationTheme() {
  OutlineInputBorder outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(28),
    borderSide: BorderSide(color: kTextColor),
    gapPadding: 10,
  );
  return InputDecorationTheme(
    contentPadding: EdgeInsets.symmetric(horizontal: 42, vertical: 20),
    enabledBorder: outlineInputBorder,
    focusedBorder: outlineInputBorder,
    border: outlineInputBorder,
  );
}

TextTheme textTheme() {
  return const TextTheme(
    bodyText1: TextStyle(color: kTextColor),
    bodyText2: TextStyle(color: kTextColor),
  );
}

AppBarTheme appBarTheme() {
  return const AppBarTheme(
    color: Colors.white,
    elevation: 0,
    brightness: Brightness.light,
    iconTheme: IconThemeData(color: Colors.black),
    textTheme: TextTheme(
      headline6: TextStyle(color: Color(0XFF8B8B8B), fontSize: 18),
    ),
  );
}

commonBoxShadow() {
  return const BoxShadow(
      color: Colors.black26, offset: Offset(0, 2), blurRadius: 10.0);
}

slightBoxShadow() {
  return const BoxShadow(
      color: Colors.black26, offset: Offset(0, 1), blurRadius: 5.0);
}

minorBoxShadow() {
  return const BoxShadow(
      color: Colors.black12, offset: Offset(1, 1), blurRadius: 1.0);
}

commonToolbarOptions() {
  return const ToolbarOptions(copy: true, selectAll: true, cut: false, paste: false);
}
