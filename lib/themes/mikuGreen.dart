import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

import '../data/index.dart';

class MikuGreenTheme extends AppBaseThemeItem {
  @override
  init() {}

  static Color color = const Color(0xff39c5bb);
  static Color color0 = const Color(0xffe6fffc);
  static Color color50 = const Color(0xffd0fffa);
  static Color color100 = const Color(0xffa5fff7);
  static Color color200 = const Color(0xff82fff5);
  static Color color300 = const Color(0xff40d7cc);
  static Color color400 = const Color(0xff3cccc2);
  static Color color500 = const Color(0xff33ada4);
  static Color color600 = const Color(0xff2d9b94);
  static Color color700 = const Color(0xff2a8f88);
  static Color color800 = const Color(0xff237c76);
  static Color color900 = const Color(0xff1c625d);

  @override
  changeSystem() {
    SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.white,
      statusBarBrightness: Brightness.light,
    );
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  @override
  get d => data;

  static dynamic data = AppThemeItem(
    name: "mikuGreen",
    isDefault: false,
    themeData: ThemeData(
      brightness: Brightness.light,
      // GENERAL CONFIGURATION
      applyElevationOverlayColor: true,
      useMaterial3: true,
      // COLOR
      sliderTheme: SliderThemeData(
        valueIndicatorColor: color,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          elevation: WidgetStateProperty.all(0),
          foregroundColor: WidgetStateProperty.all(color),
          textStyle: WidgetStateProperty.all(
            TextStyle(color: color),
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        modalBackgroundColor: Colors.white,
      ),
      canvasColor: const Color(0xffdefff9),
      primaryColorLight: Colors.white,
      primaryColorDark: color,
      textTheme: TextTheme(
        displayLarge: TextStyle(color: color800.withOpacity(.8)),
        displayMedium: TextStyle(color: color800.withOpacity(.8)),
        displaySmall: TextStyle(color: color800.withOpacity(.8)),
        headlineMedium: const TextStyle(color: Colors.black),
        headlineSmall: const TextStyle(color: Colors.black),
        titleLarge: TextStyle(color: color900),
        titleMedium: TextStyle(color: color900),
        titleSmall: TextStyle(color: color900),
        bodyLarge: TextStyle(color: color800),
        bodyMedium: TextStyle(color: color800),
        bodySmall: TextStyle(color: color800),
      ),
      switchTheme: const SwitchThemeData().copyWith(
        trackColor: WidgetStateProperty.all(color.withOpacity(.2)),
        thumbColor: WidgetStateProperty.all(color),
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: color300.withOpacity(.5),
        selectionHandleColor: color300,
        cursorColor: color,
      ),
      unselectedWidgetColor: Colors.white,
      scaffoldBackgroundColor: const Color(0xfff6fffd),
      splashColor: Colors.transparent,
      dialogBackgroundColor: Colors.white,
      dialogTheme: DialogTheme(
        elevation: 10,
        backgroundColor: color300,
        titleTextStyle: const TextStyle(
          color: Colors.white,
        ),
      ),
      highlightColor: Colors.transparent,
      toggleButtonsTheme: ToggleButtonsThemeData(
        color: color,
        fillColor: color,
        textStyle: TextStyle(
          color: color,
        ),
        focusColor: Colors.white60,
        selectedColor: Colors.white,
        selectedBorderColor: color800,
        splashColor: Colors.black38,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(color),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: color,
        linearTrackColor: Colors.black12,
        refreshBackgroundColor: Colors.white,
      ),
      shadowColor: color,
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(3.0)),
          border: Border.all(
            width: 1,
            color: Colors.white24,
          ),
        ),
        textStyle: const TextStyle(color: Colors.black),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        textStyle: const TextStyle(
          color: Colors.black,
        ),
        labelTextStyle: WidgetStateProperty.all(const TextStyle(color: Colors.black54)),
        elevation: 2,
      ),
      listTileTheme: const ListTileThemeData(
        titleTextStyle: TextStyle(
          color: Colors.black,
        ),
        subtitleTextStyle: TextStyle(
          color: Colors.black54,
        ),
      ),
      dividerColor: color.withOpacity(.1),
      dividerTheme: DividerThemeData(
        color: color.withOpacity(.1),
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withOpacity(.3),
          disabledForegroundColor: color.withOpacity(.3),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all(
            TextStyle(
              color: color,
            ),
          ),
          elevation: WidgetStateProperty.all(0.2),
          backgroundColor: WidgetStateProperty.all(color),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          visualDensity: VisualDensity.comfortable,
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          mouseCursor: WidgetStateProperty.all(MouseCursor.defer),
          enableFeedback: true,
          splashFactory: NoSplash.splashFactory,
          shape: WidgetStateProperty.all(
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
      bannerTheme: MaterialBannerThemeData(
        backgroundColor: color,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: color,
        disabledColor: color300.withOpacity(.2),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: color.withOpacity(.4),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        selectedItemColor: color800,
        selectedLabelStyle: TextStyle(
          color: color800,
          fontSize: 14,
        ),
        elevation: 0,
        unselectedItemColor: color,
        unselectedLabelStyle: TextStyle(
          color: color,
          fontSize: 14,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: color800,
        foregroundColor: color500,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(
          color: color,
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: FontSize.xLarge.value,
        ),
      ),
      primaryColor: color0,
      tabBarTheme: TabBarTheme(
        unselectedLabelColor: color300,
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        indicatorColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: color,
            width: 3,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: color300,
        focusColor: Colors.white,
      ),
      iconTheme: IconThemeData(
        color: color800,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        shadowColor: Colors.transparent,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
          side: BorderSide(
            color: color50,
            width: 1,
          ),
        ),
      ),
      radioTheme: RadioThemeData(
        mouseCursor: WidgetStateProperty.all(MouseCursor.uncontrolled),
        overlayColor: WidgetStateProperty.all(color.withOpacity(.7)),
        fillColor: WidgetStateProperty.all(color),
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(Colors.white),
        fillColor: WidgetStateProperty.all(color),
        side: const BorderSide(
          color: Colors.black12,
          width: 3,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: color,
        secondarySelectedColor: Colors.white,
        surfaceTintColor: Colors.red,
        checkmarkColor: Colors.white,
        iconTheme: IconThemeData(
          color: color300,
        ),
        secondaryLabelStyle: TextStyle(
          color: color300,
        ),
        labelStyle: const TextStyle(
          color: Colors.white,
        ),
      ),
      colorScheme: ColorScheme(
        outline: color100,
        brightness: Brightness.light,
        primary: color,
        primaryContainer: Colors.white,
        onPrimary: Colors.white,
        onPrimaryContainer: color,
        secondary: color,
        onSecondary: Colors.white,
        error: const Color(0xffFC4952),
        onError: const Color(0xffA4181F),
        errorContainer: Colors.white,
        surface: color0,
        onSurface: Colors.black,
      ),
      bottomAppBarTheme: const BottomAppBarTheme(
        color: Color(0xFFFFFDFD),
        elevation: 0,
      ),
    ),
  );
}
