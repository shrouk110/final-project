import 'package:flutter/material.dart';
import 'app_colors.dart';

ThemeData appTheme = ThemeData(
  useMaterial3: true,


  scaffoldBackgroundColor: AppColors.background,


  primaryColor: AppColors.primary,

  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.white,
    error: AppColors.error,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    foregroundColor: AppColors.primary,
    elevation: 0,
    centerTitle: true,

    titleTextStyle: TextStyle(
      color: AppColors.primary,
      fontSize: 22,
      fontWeight: FontWeight.w700,
    ),
  ),


  cardTheme: CardThemeData(
    color: AppColors.white,
    elevation: 3,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
  ),

    elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.buttonColor,
      foregroundColor: AppColors.white,

      minimumSize: const Size(double.infinity, 56),

      elevation: 3,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),

      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),


  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,

      side: const BorderSide(
        color: AppColors.primary,
        width: 1.5,
      ),

      minimumSize: const Size(double.infinity, 56),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),

      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),


  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.white,

    contentPadding: const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 18,
    ),

    hintStyle: const TextStyle(
      color: AppColors.textSecondary,
      fontSize: 14,
    ),

    labelStyle: const TextStyle(
      color: AppColors.textPrimary,
      fontSize: 15,
    ),

    prefixIconColor: AppColors.secondary,
    suffixIconColor: AppColors.secondary,

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        color: AppColors.buttonColor,
        width: 2,
      ),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        color: Colors.red,
        width: 1.5,
      ),
    ),
  ),


  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.primary,

    selectedItemColor: AppColors.buttonColor,

    unselectedItemColor: AppColors.white,

    elevation: 10,

    type: BottomNavigationBarType.fixed,
  ),


  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.buttonColor,
    foregroundColor: AppColors.white,
  ),


  dividerTheme: const DividerThemeData(
    color: Color(0xFFE6E0D8),
    thickness: 1,
  ),


  textTheme: const TextTheme(


    headlineLarge: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.bold,
      color: AppColors.primary,
      letterSpacing: 0.3,
    ),


    headlineMedium: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: AppColors.primary,
    ),


    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.primary,
    ),

       bodyLarge: TextStyle(
      fontSize: 16,
      height: 1.5,
      color: AppColors.textPrimary,
    ),


    bodyMedium: TextStyle(
      fontSize: 14,
      height: 1.4,
      color: AppColors.textSecondary,
    ),


    bodySmall: TextStyle(
      fontSize: 12,
      color: AppColors.textSecondary,
    ),


    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.white,
    ),
  ),
);