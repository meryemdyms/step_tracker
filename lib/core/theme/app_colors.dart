import 'package:flutter/material.dart';

class AppColors{
    AppColors._(); //uygulamanın herhangi bri yerinde AppColors.renk şeklinde erişebiliriz

    // Ana renkler
  static const Color coral = Color(0xFFE98975);
  static const Color blue = Color(0xFF60A8C5);

  // Light mode
  static const Color lightBackground = Color(0xFFF5F6F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBlue = Color(0xFFD9EBF1);

  // Dark mode
  static const Color darkBackground = Color(0xFF10161D);
  static const Color darkSurface = Color(0xFF1A242E);
  static const Color darkSecondarySurface = Color(0xFF2D3B46);

  // Dark mode vurgu renkleri
  static const Color darkCoral = Color(0xFFF07F6E);
  static const Color darkBlue = Color(0xFF5DABC5);
}