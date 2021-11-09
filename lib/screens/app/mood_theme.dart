import 'package:flutter/material.dart';

class MoodTheme {
  const MoodTheme();

  ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: primarySwatch(),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: primarySwatch(),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      // A warning shows when using the dark theme including this hides the warning:
      /// I/flutter (25920): Warning: The support for configuring the foreground
      /// color of FloatingActionButtons using ThemeData.accentIconTheme has been
      /// deprecated. Please use ThemeData.floatingActionButtonTheme instead.
      /// See https://flutter.dev/go/remove-fab-accent-theme-dependency.
      /// This feature was deprecated after v1.13.2.
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: Colors.black,
      ),
    );
  }

  static MaterialColor primarySwatch() => Colors.teal;
}
