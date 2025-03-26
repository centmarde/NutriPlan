import 'package:flutter/material.dart';

class AppTheme {
  // Color constants
  static const Color darkest = Color(0xFF5D8736);
  static const Color darker = Color(0xFF809D3C);
  static const Color light = Color(0xFFA9C46C);
  static const Color lightest = Color(0xFFF4FFC3);

  // Gradient presets
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [light, darkest],
  );

  // Text styles
  static TextStyle headingStyle = const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [
      Shadow(blurRadius: 10.0, color: Colors.black38, offset: Offset(0, 3)),
    ],
  );

  static TextStyle subheadingStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w300,
    color: Colors.white,
  );
}
