import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:nb_utils/nb_utils.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: appPrimaryColor,
    scaffoldBackgroundColor: scaffoldBgColor,
    accentColor: appSecondaryColor,
    cardColor: Colors.white,
    dividerColor: viewLineColor,
    textTheme: TextTheme(headline6: TextStyle()),
    dialogBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      color: primaryColor,
      systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light, statusBarColor: scaffoldBgColor),
    ),
    iconTheme: IconThemeData(color: Colors.black54),
    pageTransitionsTheme: PageTransitionsTheme(builders: {
      TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
    }),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: scaffoldDarkColors,
    primaryColor: primaryDarkColor,
    iconTheme: IconThemeData(color: Colors.white70),
    cardColor: cardDarkColors,
    accentColor: appSecondaryColor,
    dividerColor: Color(0xFFB4B4B4),
    dialogBackgroundColor: cardDarkColors,
    appBarTheme: AppBarTheme(color: cardDarkColors),
    textTheme: TextTheme(headline6: TextStyle(color: textSecondaryColor)),
    pageTransitionsTheme: PageTransitionsTheme(builders: {
      TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
    }),
  );
}
