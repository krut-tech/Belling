import 'package:flutter/material.dart';

abstract class AppColors {
  // Light Palette
  static const lightBackground = Color(0xFFF5F2EC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightText = Color(0xFF14152B);
  static const lightMuted = Color(0xFF7A7B90);
  static const lightBorder = Color(0xFFECE7DD);
  static const lightPrimary = Color(0xFFE8590C);
  static const lightSuccess = Color(0xFF12A150);
  static const lightWarning = Color(0xFFB45309);
  static const lightDanger = Color(0xFFE5484D);

  // Haldi brand accents (header gradient, ink buttons, soft tints)
  static const ink = Color(0xFF14152B);

  // Belling 2.0 tokens
  static const accent = Color(0xFFFF6A1F);
  static const accent2 = Color(0xFFFF9F43);
  static const heroTop = Color(0xFF17183A);
  static const heroBottom = Color(0xFF2B2A72);
  static const goodBg = Color(0xFFE4F7EC);
  static const dueBg = Color(0xFFFDECEC);
  static const warnBg = Color(0xFFFFF3DC);
  static const warn = Color(0xFFF5A524);
  static const blue = Color(0xFF3E63DD);
  static const blueBg = Color(0xFFE8EEFF);
  static const violet = Color(0xFF7C5CFC);
  static const violetBg = Color(0xFFEFEAFF);
  static const accentBg = Color(0xFFFFE9DC);
  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accent2],
  );
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [heroTop, heroBottom],
  );
  static const saffron = Color(0xFFF97316);
  static const crimson = Color(0xFFDC2626);
  static const wine = Color(0xFF9F1239);
  static const softSaffron = Color(0xFFFFEDD5);
  static const whatsappGreen = Color(0xFF16A34A);

  // Dark Palette
  static const darkBackground = Color(0xFF0A0E1A);
  static const darkSurface = Color(0xFF121829);
  static const darkText = Color(0xFFE6EAF2);
  static const darkMuted = Color(0xFF9AA6BD);
  static const darkBorder = Color(0xFF26304A);
  static const darkPrimary = Color(0xFF22D3EE);
}
