import 'package:flutter/material.dart';

import '../data/index.dart';

class PinkTheme {
  static dynamic data = AppThemeItem(
    name: "pink",
    isDefault: false,
    themeData: ThemeData(
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.pink),
          textStyle: MaterialStateProperty.all(
            const TextStyle(color: Colors.pink),
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.pink.withOpacity(.1),
        modalBackgroundColor: Colors.pink.withOpacity(.1),
      ),
      canvasColor: Colors.pink.shade50,
      primaryColorDark: Colors.pink.shade300,
      textTheme: TextTheme(
        displayLarge: TextStyle(color: Colors.pink.shade300),
        displayMedium: TextStyle(color: Colors.pink.shade300),
        displaySmall: TextStyle(color: Colors.pink.shade300),
        headlineMedium: TextStyle(color: Colors.pink.shade400),
        headlineSmall: TextStyle(color: Colors.pink.shade400),
        titleLarge: TextStyle(color: Colors.pink.shade400),
        titleMedium: TextStyle(color: Colors.pink.shade400),
        titleSmall: TextStyle(color: Colors.pink.shade400),
        bodyLarge: TextStyle(color: Colors.pink.shade400),
        bodyMedium: TextStyle(color: Colors.pink.shade400),
        bodySmall: TextStyle(color: Colors.pink.shade400),
      ),
      switchTheme: const SwitchThemeData().copyWith(
        trackColor: MaterialStateProperty.all(Colors.pink.withOpacity(.2)),
        thumbColor: MaterialStateProperty.all(Colors.pink),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: Colors.pink,
        selectionHandleColor: Colors.pink,
        cursorColor: Colors.pink,
      ),
      unselectedWidgetColor: Colors.white,
      scaffoldBackgroundColor: Color(0xFFFFF3F6),
      splashColor: Colors.transparent,
      dialogBackgroundColor: Colors.white,
      dialogTheme: const DialogTheme(
        elevation: 10,
        backgroundColor: Colors.pink,
        titleTextStyle: TextStyle(
          color: Colors.white,
        ),
      ),
      highlightColor: Colors.transparent,
      toggleButtonsTheme: ToggleButtonsThemeData(
        color: Colors.pink.shade50,
        fillColor: Colors.pink.shade50,
        textStyle: TextStyle(
          color: Colors.pink,
        ),
        focusColor: Colors.white60,
        selectedColor: Colors.white,
        selectedBorderColor: Colors.pink.shade800,
        splashColor: Colors.black38,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.white,
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: Colors.white,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.pink.shade100,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.white)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all(
            const TextStyle(
              color: Colors.pink,
            ),
          ),
          elevation: MaterialStateProperty.all(0.2),
          backgroundColor: MaterialStateProperty.all(Colors.pink),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          visualDensity: VisualDensity.comfortable,
          shadowColor: MaterialStateProperty.all(Colors.transparent),
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          mouseCursor: MaterialStateProperty.all(MouseCursor.defer),
          enableFeedback: true,
          splashFactory: NoSplash.splashFactory,
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      bannerTheme: const MaterialBannerThemeData(
        backgroundColor: Colors.pink,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.pink,
        disabledColor: Colors.pink.withOpacity(.2),
      ),
      buttonBarTheme: const ButtonBarThemeData(
        layoutBehavior: ButtonBarLayoutBehavior.constrained,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.pink.shade50,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        selectedItemColor: Colors.pink,
        selectedLabelStyle: const TextStyle(
          color: Colors.pink,
          fontSize: 14,
        ),
        unselectedItemColor: Colors.pink.shade200,
        unselectedLabelStyle: TextStyle(
          color: Colors.pink.shade200,
          fontSize: 14,
        ),
      ),
      appBarTheme: AppBarTheme(
        color: Colors.white,
        foregroundColor: Colors.pink.shade600,
        shadowColor: Colors.pink.shade50,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.pink,
        ),
      ),
      primaryColor: Colors.pink,
      tabBarTheme: TabBarTheme(
        unselectedLabelColor: Colors.pink.shade100,
        labelColor: Colors.pink,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: Colors.pink,
            width: 3,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.pink,
        focusColor: Colors.white,
      ),
      iconTheme: const IconThemeData(
        color: Colors.pink,
      ),
      cardTheme: CardTheme(
        color: Colors.pink.shade50,
        shadowColor: Colors.transparent,
        margin: EdgeInsets.zero,
        elevation: 0,
      ),
      radioTheme: RadioThemeData(
        mouseCursor: MaterialStateProperty.all(MouseCursor.uncontrolled),
        overlayColor: MaterialStateProperty.all(Colors.pink.withOpacity(.7)),
        fillColor: MaterialStateProperty.all(Colors.pink),
      ),
      primaryTextTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white),
        displayMedium: TextStyle(color: Colors.white70),
        displaySmall: TextStyle(color: Colors.white54),
        headlineMedium: TextStyle(color: Colors.white38),
        headlineSmall: TextStyle(color: Colors.white24),
        titleLarge: TextStyle(color: Colors.white12),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: Colors.black12,
        secondarySelectedColor: Colors.white,
        checkmarkColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.pink,
        ),
        secondaryLabelStyle: TextStyle(
          color: Colors.pink,
        ),
        labelStyle: TextStyle(
          color: Colors.pink,
        ),
      ),
      colorScheme: const ColorScheme(
        outline: Colors.white10,
        brightness: Brightness.dark,
        primary: Colors.pink,
        onPrimary: Colors.pink,
        secondary: Color(0xff0a111c),
        onSecondary: Color(0xff0a111c),
        error: Colors.red,
        onError: Colors.red,
        background: Color(0xff111b2b),
        onBackground: Color(0xff111b2b),
        surface: Colors.white,
        onSurface: Colors.white,
        // background: Colors.black,
      ),
      bottomAppBarTheme: const BottomAppBarTheme(
        color: Colors.white,
        elevation: 0,
      ),
    ),
  );
}
