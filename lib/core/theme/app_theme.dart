import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme{
    AppTheme {
        AppTheme._();

    static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      scaffoldBackgroundColor: AppColors.lightBackground,

     //AppColors yalnızca renklerin değerlerini tutuyor,ColorScheme ise renklerin uygulamadaki görevlerini belirliyor
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.coral,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.coral,
        secondary: AppColors.blue,
        surface: AppColors.lightSurface,
        onSurface: const Color(0xFF20292E),
        onPrimary: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: Color(0xFF20292E),
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      scaffoldBackgroundColor: AppColors.darkBackground,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkCoral,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.darkCoral,//ana vurgu rengi
        secondary: AppColors.darkBlue,//ikincil vurgu rengi
        surface: AppColors.darkSurface,//kart gibi yüzeylerin vurgu rengi
        onSurface: Colors.white,//yüzeylerin üzerinde metin ve ikon rengi
        onPrimary: Colors.white,//ana renk üzerindeki yazı ve ikon rengi
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
    }
}