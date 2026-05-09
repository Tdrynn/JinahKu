import 'package:flutter/material.dart';

import 'light_colors.dart' as lg;
import 'dark_colors.dart' as dk;

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,

    fontFamily: 'Inter',

    scaffoldBackgroundColor: lg.lightColors.background,

    cardColor: lg.lightColors.card,
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        color: lg.lightColors.textPrimary,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    fontFamily: 'Inter',

    scaffoldBackgroundColor: dk.darkColors.background,

    cardColor: dk.darkColors.card,
    
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        color: dk.darkColors.textPrimary,
      ),
    ),
  );
}