import 'package:flutter/material.dart';

// Spotify color scheme
class AppColors {
  static const Color spotifyGreen = Color(0xFF1DB954);
  static const Color spotifyBlack = Color(0xFF191414);
  static const Color spotifyWhite = Color(0xFFFFFFFF);
  static const Color spotifyGrey = Color(0xFF535353);
  static const Color spotifyLightGrey = Color(0xFFB3B3B3);
  static const Color errorRed = Color(0xFFE61E32);
}

// Text styles
class AppTextStyles {
  static const TextStyle heading = TextStyle(
    color: AppColors.spotifyWhite,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle subHeading = TextStyle(
    color: AppColors.spotifyWhite,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle bodyText = TextStyle(
    color: AppColors.spotifyWhite,
    fontSize: 16,
  );
  
  static const TextStyle smallText = TextStyle(
    color: AppColors.spotifyLightGrey,
    fontSize: 14,
  );
}

// String constants
class AppStrings {
  static const String appName = 'Spotify Clone';
  static const String loginTitle = 'Log in to Spotify';
  static const String registerTitle = 'Sign up for free';
  static const String emailHint = 'Email address or username';
  static const String passwordHint = 'Password';
  static const String nameHint = 'Your name';
  static const String forgotPassword = 'Forgot your password?';
  static const String loginButton = 'LOG IN';
  static const String registerButton = 'SIGN UP';
  static const String noAccount = 'Don\'t have an account?';
  static const String haveAccount = 'Already have an account?';
  static const String signUp = 'SIGN UP FOR SPOTIFY';
  static const String logIn = 'LOG IN';
  static const String or = 'OR';
}

// Input decoration
class AppInputDecorations {
  static InputDecoration textFieldDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.spotifyLightGrey),
      filled: true,
      fillColor: Colors.white.withAlpha(25), // 0.1 opacity
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.spotifyGreen),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.errorRed),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.errorRed),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    );
  }
}