import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

import '../data/index.dart';

class BlueDarkTheme extends AppBaseThemeItem {
  @override
  init() {}

  @override
  changeSystem() {
    SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.black,
      statusBarBrightness: Brightness.light,
    );
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  @override
  get d => data;

  static dynamic data = AppThemeItem(
    name: "blueDark",
    isDefault: true,
    themeData: ThemeData(
      brightness: Brightness.dark,
      // GENERAL CONFIGURATION
      applyElevationOverlayColor: true,
      useMaterial3: true,
      // COLOR
      sliderTheme: const SliderThemeData(
        valueIndicatorTextStyle: TextStyle(
          color: Colors.white,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.black,
        modalBackgroundColor: Colors.black,
      ),
      canvasColor: Colors.yellow.shade50,
      primaryColorDark: Colors.yellow,
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white),
        displayMedium: TextStyle(color: Colors.white70),
        displaySmall: TextStyle(color: Colors.white54),
        headlineMedium: TextStyle(color: Colors.white),
        headlineSmall: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        titleSmall: TextStyle(color: Colors.white54),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white),
      ),
      switchTheme: const SwitchThemeData().copyWith(
        trackColor: WidgetStateProperty.all(Colors.yellow.withOpacity(.2)),
        thumbColor: WidgetStateProperty.all(Colors.yellow),
      ),
      inputDecorationTheme: InputDecorationTheme(hintStyle: TextStyle(color: Colors.white38)),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: const TextStyle(
          color: Colors.white,
        ),
        menuStyle: MenuStyle(
          elevation: WidgetStateProperty.all(2),
          backgroundColor: WidgetStateProperty.all(Colors.black87),
          surfaceTintColor: WidgetStateProperty.all(Colors.white),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: const Color(0x7a364e80).withOpacity(.3),
        selectionHandleColor: const Color(0xff364e80),
        cursorColor: const Color(0xff364e80),
      ),
      unselectedWidgetColor: Colors.white,
      splashColor: Colors.transparent,
      dialogTheme: const DialogTheme(
        elevation: 2,
        backgroundColor: Color(0xff405d98),
        titleTextStyle: TextStyle(
          color: Colors.white,
        ),
      ),
      highlightColor: Colors.transparent,
      scrollbarTheme: const ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(Color(0xff2e426b)),
        trackColor: WidgetStatePropertyAll(Color(0xff2e426b)),
        trackBorderColor: WidgetStatePropertyAll(Color(0xff2e426b)),
        radius: Radius.circular(3),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.white,
        circularTrackColor: Colors.transparent,
        linearTrackColor: Colors.transparent,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xff1c3762),
          borderRadius: const BorderRadius.all(Radius.circular(3.0)),
          border: Border.all(
            width: 1,
            color: Colors.white24,
          ),
        ),
        textStyle: const TextStyle(color: Colors.white),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.black,
        surfaceTintColor: Colors.black,
        textStyle: const TextStyle(
          color: Colors.white,
        ),
        labelTextStyle: WidgetStateProperty.all(const TextStyle(color: Colors.white70)),
        elevation: 2,
      ),
      listTileTheme: const ListTileThemeData(
        titleTextStyle: TextStyle(
          color: Colors.white,
        ),
        subtitleTextStyle: TextStyle(
          color: Colors.white54,
        ),
      ),
      dividerColor: Colors.white10,
      dividerTheme: const DividerThemeData(
        color: Colors.white10,
      ),
      dataTableTheme: const DataTableThemeData(
        horizontalMargin: 10,
        columnSpacing: 20,
        headingRowHeight: 40,
        checkboxHorizontalMargin: 40,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      bannerTheme: const MaterialBannerThemeData(
        backgroundColor: Color(0xff364e80),
      ),

      // 按钮 S
      buttonTheme: ButtonThemeData(
        buttonColor: const Color(0xff364e80),
        disabledColor: const Color(0xff364e80).withOpacity(.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
          side: const BorderSide(
            color: Colors.white12,
            width: 1,
          ),
        ),
      ),
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
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.yellow,
        focusColor: Color(0xff364e80),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          iconColor: const WidgetStatePropertyAll(Colors.white),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: WidgetStateProperty.all(0),
          backgroundColor: WidgetStateProperty.all(const Color(0xff1c3762)),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          visualDensity: VisualDensity.comfortable,
          shadowColor: WidgetStateProperty.all(Colors.black),
          overlayColor: WidgetStateProperty.all(const Color(0xff09121e)),
          mouseCursor: WidgetStateProperty.all(MouseCursor.defer),
          enableFeedback: true,
          splashFactory: NoSplash.splashFactory,
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
              side: const BorderSide(
                color: Colors.white12,
                width: 1,
              ),
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(const Color(0x7a364e80)),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          textStyle: WidgetStateProperty.all(
            const TextStyle(color: Colors.white),
          ),
          side: WidgetStateProperty.all(const BorderSide(
            color: Colors.white12,
            width: 1,
          )),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
              side: const BorderSide(
                color: Colors.white12,
                width: 1,
              ),
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all(
            const TextStyle(
              color: Colors.white,
            ),
          ),
          elevation: WidgetStateProperty.all(0),
          backgroundColor: WidgetStateProperty.all(const Color(0xff1a2a44)),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          visualDensity: VisualDensity.comfortable,
          shadowColor: WidgetStateProperty.all(Colors.black),
          overlayColor: WidgetStateProperty.all(const Color(0xff09121e)),
          mouseCursor: WidgetStateProperty.all(MouseCursor.defer),
          enableFeedback: true,
          splashFactory: NoSplash.splashFactory,
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
              side: const BorderSide(
                color: Colors.white12,
                width: 1,
              ),
            ),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(Colors.white),
        ),
      ),
      // 按钮 E

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
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xff364e80),
        foregroundColor: Colors.white,
        shadowColor: Colors.black26,
        elevation: 0,
        scrolledUnderElevation: 0,
        actionsIconTheme: IconThemeData(
          color: Colors.white,
          opticalSize: 60,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: FontSize.xLarge.value,
        ),
      ),
      primaryColor: const Color(0xff111b2b),
      tabBarTheme: TabBarTheme(
        unselectedLabelColor: Colors.white38,
        dividerColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.yellow,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: Colors.yellow,
            width: 3,
          ),
        ),
      ),

      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      cardTheme: CardTheme(
        color: const Color(0xff0d1323),
        shadowColor: Colors.black54,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
          side: const BorderSide(
            color: Colors.white10,
            width: 1,
          ),
        ),
      ),
      radioTheme: RadioThemeData(
        mouseCursor: WidgetStateProperty.all(MouseCursor.uncontrolled),
        overlayColor: WidgetStateProperty.all(Colors.yellow.withOpacity(.7)),
        fillColor: WidgetStateProperty.all(Colors.yellow),
      ),
      primaryTextTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white),
        displayMedium: TextStyle(color: Colors.white70),
        displaySmall: TextStyle(color: Colors.white54),
        headlineMedium: TextStyle(color: Colors.white38),
        headlineSmall: TextStyle(color: Colors.white24),
        titleLarge: TextStyle(color: Colors.white12),
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(Colors.white),
        fillColor: WidgetStateProperty.all(const Color(0xff364e80)),
        side: const BorderSide(
          color: Colors.white12,
          width: 3,
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: Colors.black12,
        secondarySelectedColor: Colors.black,
        checkmarkColor: Colors.black,
        selectedColor: Colors.yellow,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        secondaryLabelStyle: TextStyle(
          color: Colors.white,
        ),
        labelStyle: TextStyle(
          color: Colors.black,
        ),
      ),
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        outline: Colors.white10,
        primary: Color(0xff364e80),
        primaryContainer: Colors.white,
        onPrimary: Color(0xff364e80),
        secondary: Color(0xff476ab2),
        onSecondary: Color(0xff476ab2),
        error: Colors.redAccent,
        onError: Colors.redAccent,
        errorContainer: Colors.white,
        surface: Color(0xff0a101a),
        onSurface: Colors.white,
      ),
      bottomAppBarTheme: const BottomAppBarTheme(
        color: Colors.black,
        elevation: 0,
      ),
    ),
  );
}
