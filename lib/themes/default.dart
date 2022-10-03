import 'package:flutter/material.dart';

import '../data/index.dart';

class DefaultTheme {
  static dynamic data = AppThemeItem(
    name: "default",
    isDefault: true,
    themeData: ThemeData(
      backgroundColor: Colors.black,
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.black,
        modalBackgroundColor: Colors.black,
      ),
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xff364e80),
        onPrimary: Color(0xff364e80),
        secondary: Color(0xff0a111c),
        onSecondary: Color(0xff0a111c),
        error: Colors.red,
        onError: Colors.red,
        background: Color(0xff111b2b),
        onBackground: Color(0xff111b2b),
        surface: Colors.white,
        onSurface: Colors.white,
      ),
      canvasColor: Colors.yellow,
      chipTheme: const ChipThemeData(
        backgroundColor: Colors.black12,
        secondarySelectedColor: Colors.white,
        checkmarkColor: Colors.black,
      ),
      primaryColorDark: Colors.yellow,
      textTheme: const TextTheme(
        headline1: TextStyle(color: Colors.white),
        headline2: TextStyle(color: Colors.white),
        headline3: TextStyle(color: Colors.white),
        headline4: TextStyle(color: Colors.white),
        headline5: TextStyle(color: Colors.white),
        headline6: TextStyle(color: Colors.white),
        subtitle1: TextStyle(color: Colors.white),
        subtitle2: TextStyle(color: Colors.white54),
        bodyText1: TextStyle(color: Colors.white),
        bodyText2: TextStyle(color: Colors.white),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: Color(0x7a364e80),
        selectionHandleColor: Color(0xff364e80),
        cursorColor: Colors.white,
      ),
      unselectedWidgetColor: Colors.white,
      scaffoldBackgroundColor: const Color(0xff111b2b),
      bottomAppBarColor: Colors.black,
      splashColor: Colors.transparent,
      dialogBackgroundColor: Colors.white,
      dialogTheme: const DialogTheme(
        elevation: 10,
        backgroundColor: Color(0xff364e80),
        titleTextStyle: TextStyle(
          color: Colors.white,
        ),
      ),
      highlightColor: Colors.transparent,
      toggleButtonsTheme: const ToggleButtonsThemeData(
        color: Color(0xff111b2b),
        fillColor: Colors.black38,
        textStyle: TextStyle(
          color: Colors.white60,
        ),
        focusColor: Colors.white60,
        selectedColor: Colors.white,
        selectedBorderColor: Colors.black38,
        splashColor: Colors.black38,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.white,
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: Color(0xff364e80),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.black,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.white)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all(const TextStyle(
            color: Colors.white,
          )),
          elevation: MaterialStateProperty.all(0.2),
          backgroundColor: MaterialStateProperty.all(const Color(0xff111b2b)),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          visualDensity: VisualDensity.comfortable,
          shadowColor: MaterialStateProperty.all(Colors.black),
          overlayColor: MaterialStateProperty.all(Colors.yellow),
          mouseCursor: MaterialStateProperty.all(MouseCursor.defer),
          enableFeedback: true,
          splashFactory: NoSplash.splashFactory,
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      bannerTheme: const MaterialBannerThemeData(
        backgroundColor: Color(0xff364e80),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: const Color(0xff364e80),
        disabledColor: const Color(0xff364e80).withOpacity(.2),
      ),
      bottomAppBarTheme: const BottomAppBarTheme(
        color: Colors.black,
        elevation: 0,
      ),
      buttonBarTheme: const ButtonBarThemeData(
        layoutBehavior: ButtonBarLayoutBehavior.constrained,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.black,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        selectedItemColor: Colors.yellow,
        selectedLabelStyle: TextStyle(
          color: Colors.yellow,
          fontSize: 14,
        ),
        unselectedItemColor: Colors.white,
        unselectedLabelStyle: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      appBarTheme: const AppBarTheme(
        color: Color(0xff364e80),
        foregroundColor: Colors.white,
        shadowColor: Colors.black26,
        elevation: 0,
      ),
      primaryColor: const Color(0xff111b2b),
      tabBarTheme: const TabBarTheme(
        unselectedLabelColor: Colors.white38,
        labelColor: Colors.yellow,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: Colors.yellow,
            width: 3,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.yellow,
        focusColor: Color(0xff364e80),
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      cardTheme: const CardTheme(
        color: Color(0xff0d1323),
        shadowColor: Colors.black54,
        elevation: 2,
      ),
      radioTheme: RadioThemeData(
        mouseCursor: MaterialStateProperty.all(MouseCursor.uncontrolled),
        overlayColor: MaterialStateProperty.all(Colors.yellow.withOpacity(.7)),
        fillColor: MaterialStateProperty.all(Colors.yellow),
      ),
      toggleableActiveColor: Colors.white,
      primaryTextTheme: const TextTheme(
        headline1: TextStyle(color: Colors.white),
        headline2: TextStyle(color: Colors.white70),
        headline3: TextStyle(color: Colors.white54),
        headline4: TextStyle(color: Colors.white38),
        headline5: TextStyle(color: Colors.white24),
        headline6: TextStyle(color: Colors.white12),
      ),
    ),
  );
}
