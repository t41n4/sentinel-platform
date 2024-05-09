import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'custom_colors_theme.dart';

class AppTheme {
  static HexColor colorOrange = HexColor('#FFA400');
  static HexColor colorGray = HexColor('#373A36');

  static HexColor primaryLightColor = HexColor('#67022D');
  static HexColor secondaryLightColor = HexColor('#F1EEE6');
  static HexColor thirdLightColor = HexColor('#A0A8BE');
  static HexColor fourthLightColor = HexColor('#AD2C53');
  static HexColor fifthLightColor = HexColor('#EF382D');

  static ThemeData get({required bool isLight, required BuildContext context}) {
    final base = isLight ? ThemeData.light() : ThemeData.dark();
    return base.copyWith(
      extensions: [
        CustomColorsTheme(
          colorLabelColor: isLight ? Colors.grey : const Color(0xFF7A7FB0),
          bottomNavigationBarBackgroundColor:
              isLight ? primaryLightColor : colorGray,
          activeNavigationBarColor: isLight ? thirdLightColor : colorOrange,
          notActiveNavigationBarColor: secondaryLightColor,
          shadowNavigationBarColor: isLight ? primaryLightColor : colorOrange,
        )
      ],
      primaryTextTheme: isLight
          ? GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
          : GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
              .apply(bodyColor: Colors.white),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isLight ? primaryLightColor : colorOrange,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isLight ? primaryLightColor : colorGray,
      ),
      scaffoldBackgroundColor: isLight ? secondaryLightColor : colorGray,
      colorScheme: base.colorScheme.copyWith(
        surface: isLight ? secondaryLightColor : colorGray,
        background: isLight ? secondaryLightColor : colorGray,
      ),
    );
  }
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }
}
