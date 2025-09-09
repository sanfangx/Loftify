import 'package:flutter/material.dart';

enum ActiveThemeMode {
  system,
  light,
  dark;

  ThemeMode get themeMode {
    switch (this) {
      case ActiveThemeMode.system:
        return ThemeMode.system;
      case ActiveThemeMode.light:
        return ThemeMode.light;
      case ActiveThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}

