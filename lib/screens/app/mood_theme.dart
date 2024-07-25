import 'package:flutter/material.dart';

class MoodTheme {
  const MoodTheme();

  ThemeData configure(bool isLightMode) {
    return ThemeData(
      brightness: isLightMode ? Brightness.light : Brightness.dark,
      colorSchemeSeed: primarySwatch(),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: primarySwatch(),
        unselectedItemColor: isLightMode ? Colors.grey.shade700 : Colors.grey.shade400,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static MaterialColor primarySwatch() => Colors.teal;
}
