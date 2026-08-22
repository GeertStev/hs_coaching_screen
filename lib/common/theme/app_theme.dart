import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    //scaffoldBackgroundColor: const Color.fromARGB(255, 0, 51, 170),
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: Color.fromARGB(255, 240, 93, 94),
      //0F7173
      //B7C3F3
      onPrimary: Colors.orange,
      secondary: Colors.blue,
      onSecondary: Colors.yellow,
      error: Colors.red,
      onError: Colors.white,
      surface: const Color.fromRGBO(0, 51, 170, 1),
      onSurface: const Color.fromARGB(255, 237, 186, 32),
    ),

    textTheme: TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontWeight: FontWeight.bold),

      //Klok, website
      titleLarge: TextStyle(fontWeight: FontWeight.bold),
      //Tekststitels
      titleMedium: TextStyle(fontWeight: FontWeight.bold),
      titleSmall: TextStyle(fontWeight: FontWeight.bold),
    ),
  );
}
