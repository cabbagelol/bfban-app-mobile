import 'package:flutter/material.dart';

import '../data/index.dart';

class PinkTheme {
  static dynamic data = AppThemeItem(
    name: "pink",
    isDefault: false,
    themeData: ThemeData(
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.pink.shade400),
          textStyle: MaterialStateProperty.all(
            TextStyle(color: Colors.pink.shade300),
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.pink.withOpacity(.1),
        modalBackgroundColor: Colors.pink.withOpacity(.1),
      ),
      canvasColor: const Color(0xFFFFFCFC),
      primaryColorDark: Colors.pink.shade300,
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Color(0xFF503050)),
        displayMedium: TextStyle(color: Color(0xFF503050)),
        displaySmall: TextStyle(color: Color(0xFF503050)),
        headlineMedium: TextStyle(color: Colors.black),
        headlineSmall: TextStyle(color: Colors.black),
        titleLarge: TextStyle(color: Color(0xFF2C1A2C)),
        titleMedium: TextStyle(color: Color(0xFF2C1A2C)),
        titleSmall: TextStyle(color: Color(0xFF2C1A2C)),
        bodyLarge: TextStyle(color: Color(0xFF2C1A2C)),
        bodyMedium: TextStyle(color: Color(0xFF2C1A2C)),
        bodySmall: TextStyle(color: Color(0xFF2C1A2C)),
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
      scaffoldBackgroundColor: const Color(0xFFFFFAFB),
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
        textStyle: const TextStyle(
          color: Colors.pink,
        ),
        focusColor: Colors.white60,
        selectedColor: Colors.white,
        selectedBorderColor: Colors.pink.shade800,
        splashColor: Colors.black38,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.white,
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: Colors.white,
        textStyle: TextStyle(
          color: Colors.black,
        ),
        elevation: 2,
      ),
      dividerColor: Colors.pink.shade50,
      dividerTheme: DividerThemeData(
        color: Colors.pink.shade50,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.white)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all(
            TextStyle(
              color: Colors.pink.shade400,
            ),
          ),
          elevation: MaterialStateProperty.all(0.2),
          backgroundColor: MaterialStateProperty.all(Colors.pink.shade400),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          visualDensity: VisualDensity.comfortable,
          shadowColor: MaterialStateProperty.all(Colors.transparent),
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          mouseCursor: MaterialStateProperty.all(MouseCursor.defer),
          enableFeedback: true,
          splashFactory: NoSplash.splashFactory,
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
              side: const BorderSide(
                color: Colors.black12,
                width: 1,
              ),
            ),
          ),
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      bannerTheme: const MaterialBannerThemeData(
        backgroundColor: Colors.pink,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.pink.shade400,
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
        elevation: 0,
        unselectedItemColor: Colors.pink.shade200,
        unselectedLabelStyle: TextStyle(
          color: Colors.pink.shade200,
          fontSize: 14,
        ),
      ),
      appBarTheme: AppBarTheme(
        color: Colors.pink.shade300,
        foregroundColor: Colors.white,
        shadowColor: Colors.pink.shade50,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
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
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.pink.shade400,
        focusColor: Colors.white,
      ),
      iconTheme: const IconThemeData(
        color: Colors.pink,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        shadowColor: Colors.transparent,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
          side: BorderSide(
            color: Colors.pink.shade50,
            width: 1,
          ),
        ),
      ),
      radioTheme: RadioThemeData(
        mouseCursor: MaterialStateProperty.all(MouseCursor.uncontrolled),
        overlayColor: MaterialStateProperty.all(Colors.pink.withOpacity(.7)),
        fillColor: MaterialStateProperty.all(Colors.pink),
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: MaterialStateProperty.all(Colors.white),
        fillColor: MaterialStateProperty.all(Colors.pink),
        side: const BorderSide(
          color: Colors.black12,
          width: 3,
        ),
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
      colorScheme: ColorScheme(
        outline: Colors.white10,
        brightness: Brightness.dark,
        primary: Colors.pink.shade400,
        onPrimary: Colors.pink.shade400,
        secondary: const Color(0xff0a111c),
        onSecondary: const Color(0xff0a111c),
        error: Colors.red,
        onError: Colors.red,
        background: const Color(0xff111b2b),
        onBackground: const Color(0xff111b2b),
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
