import 'package:flutter/material.dart';

import '../data/index.dart';

class LightnesTheme {
  static dynamic data = AppThemeItem(
    name: "lightnes",
    isDefault: true,
    themeData: ThemeData(
      backgroundColor: const Color(0xffffffff),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.black,
        modalBackgroundColor: Colors.black,
      ),
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xff364e80),
        onPrimary: Color(0xff364e80),
        secondary: Color(0xff99acd2),
        onSecondary: Color(0xff99acd2),
        error: Colors.red,
        onError: Colors.red,
        background: Colors.white,
        onBackground: Colors.white,
        surface: Colors.black,
        onSurface: Colors.black,
      ),
      canvasColor: Colors.white,
      primaryColorDark: Color(0xff364e80),
      textTheme: const TextTheme(
        headline1: TextStyle(color: Colors.black),
        headline2: TextStyle(color: Colors.black),
        headline3: TextStyle(color: Colors.black),
        headline4: TextStyle(color: Colors.black),
        headline5: TextStyle(color: Colors.black),
        headline6: TextStyle(color: Colors.black),
        subtitle1: TextStyle(color: Colors.black),
        subtitle2: TextStyle(color: Colors.black45),
        bodyText1: TextStyle(color: Colors.black),
        bodyText2: TextStyle(color: Colors.black),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: Color(0x7a364e80),
        selectionHandleColor: Color(0xff364e80),
        cursorColor: Colors.black,
      ),
      unselectedWidgetColor: Colors.black,
      scaffoldBackgroundColor: Color(0xfff7f9fd),
      bottomAppBarColor: Colors.white,
      splashColor: Colors.transparent,
      dialogBackgroundColor: Colors.white,
      dialogTheme: const DialogTheme(
        elevation: 10,
        backgroundColor: Color(0xff364e80),
        titleTextStyle: TextStyle(
          color: Colors.black,
        ),
      ),
      highlightColor: Colors.transparent,
      toggleButtonsTheme: const ToggleButtonsThemeData(
        color: Color(0xff111b2b),
        fillColor: Colors.black38,
        textStyle: TextStyle(
          color: Colors.black87,
        ),
        focusColor: Color(0xff111b2b),
        selectedColor: Colors.black,
        selectedBorderColor: Colors.black38,
        splashColor: Colors.black38,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.black87,
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: Colors.white,
        elevation: 10,
        textStyle: TextStyle(
          color: Colors.black,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.black12,
        space: .4,
        indent: .5,
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0.2),
          backgroundColor: MaterialStateProperty.all(const Color(0xff364e80)),
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
        backgroundColor: Color(0xffffffff),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.white,
        disabledColor: const Color(0xff364e80).withOpacity(.2),
      ),
      bottomAppBarTheme: const BottomAppBarTheme(
        color: Colors.white,
        elevation: 0,
      ),
      buttonBarTheme: const ButtonBarThemeData(
        layoutBehavior: ButtonBarLayoutBehavior.constrained,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        labelTextStyle: MaterialStateProperty.all(
          TextStyle(
            color: Colors.black45,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        selectedItemColor: Color(0xff364e80),
        selectedLabelStyle: TextStyle(
          color: Color(0xff364e80),
          fontSize: 14,
        ),
        elevation: 0,
        unselectedItemColor: Colors.black54,
        unselectedLabelStyle: TextStyle(
          color: Colors.black26,
          fontSize: 14,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xff283653),
        foregroundColor: Colors.white,
        shadowColor: Colors.black26,
        elevation: 0,
      ),
      primaryColor: Colors.black,
      tabBarTheme: const TabBarTheme(
        unselectedLabelColor: Colors.black54,
        labelColor: Color(0xff364e80),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: Color(0xff364e80),
            width: 3,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xff364e80),
        focusColor: Colors.white,
      ),
      iconTheme: const IconThemeData(
        color: Color(0xff364e80),
      ),
      dividerColor: Colors.white12,
      cardTheme: const CardTheme(
        elevation: 2,
        color: Colors.white,
        shadowColor: Color(0x39131372),
      ),
      cardColor: Color(0xfff2f2f2),
      radioTheme: RadioThemeData(
        mouseCursor: MaterialStateProperty.all(MouseCursor.uncontrolled),
        overlayColor: MaterialStateProperty.all(Color(0xff364e80).withOpacity(.7)),
        fillColor: MaterialStateProperty.all(Color(0xff364e80)),
      ),
      toggleableActiveColor: Colors.black,
      primaryTextTheme: const TextTheme(
        headline1: TextStyle(color: Colors.black),
        headline2: TextStyle(color: Colors.black87),
        headline3: TextStyle(color: Colors.black54),
        headline4: TextStyle(color: Colors.black45),
        headline5: TextStyle(color: Colors.black26),
        headline6: TextStyle(color: Colors.black12),
      ),
    ),
  );
}
