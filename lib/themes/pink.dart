import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

import '../data/index.dart';

class PinkTheme extends AppBaseThemeItem {
  @override
  init() {}

  @override
  changeSystem() {
    SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.white,
      statusBarBrightness: Brightness.dark,
    );
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  @override
  get d => data;

  static dynamic data = AppThemeItem(
    name: "pink",
    isDefault: false,
    themeData: ThemeData(
      brightness: Brightness.light,
      // GENERAL CONFIGURATION
      applyElevationOverlayColor: true,
      useMaterial3: true,
      // COLOR
      sliderTheme: SliderThemeData(
        valueIndicatorColor: Colors.pink.shade50,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        modalBackgroundColor: Colors.white,
      ),
      canvasColor: Colors.pink.shade50,
      primaryColorLight: Colors.pink.shade300,
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
        trackColor: WidgetStateProperty.all(Colors.pink.shade300.withOpacity(.2)),
        thumbColor: WidgetStateProperty.all(Colors.pink.shade300),
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: Colors.pink.shade300.withOpacity(.1),
        selectionHandleColor: Colors.pink.shade300.withOpacity(.1),
        cursorColor: Colors.pink.shade300,
      ),
      unselectedWidgetColor: Colors.pink.shade100,
      scaffoldBackgroundColor: const Color(0xFFFFFAFB),
      splashColor: Colors.transparent,
      dialogBackgroundColor: Colors.white,
      dialogTheme: DialogTheme(
        elevation: 10,
        backgroundColor: Colors.pink.shade300,
        titleTextStyle: const TextStyle(
          color: Colors.white,
        ),
      ),
      highlightColor: Colors.transparent,
      toggleButtonsTheme: ToggleButtonsThemeData(
        color: Colors.pink.shade50,
        fillColor: Colors.pink.shade50,
        textStyle: TextStyle(
          color: Colors.pink.shade300,
        ),
        focusColor: Colors.white60,
        selectedColor: Colors.white,
        selectedBorderColor: Colors.pink.shade800,
        splashColor: Colors.black38,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      scrollbarTheme: const ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(Colors.pink),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.pink,
        linearTrackColor: Colors.black12,
        refreshBackgroundColor: Colors.white,
      ),
      shadowColor: Colors.red,
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: Colors.pink.shade50,
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
        labelTextStyle: WidgetStateProperty.all(TextStyle(color: Colors.pinkAccent.shade100)),
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
      dividerColor: Colors.pink.withOpacity(.2),
      dividerTheme: DividerThemeData(
        color: Colors.pink.withOpacity(.2),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      bannerTheme: MaterialBannerThemeData(
        backgroundColor: Colors.pink.shade300,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.pink.shade300,
        disabledColor: Colors.pink.shade300.withOpacity(.2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(foregroundColor: WidgetStateProperty.all(Colors.white)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          elevation: WidgetStateProperty.all(0),
          foregroundColor: WidgetStateProperty.all(Colors.pink.shade300),
          textStyle: WidgetStateProperty.all(
            TextStyle(color: Colors.pink.shade300),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all(
            TextStyle(
              color: Colors.pink.shade300,
            ),
          ),
          elevation: WidgetStateProperty.all(0.2),
          backgroundColor: WidgetStateProperty.all(Colors.pink.shade300),
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
      filledButtonTheme: FilledButtonThemeData(style: ButtonStyle(surfaceTintColor: WidgetStatePropertyAll(Colors.white), foregroundColor: WidgetStatePropertyAll(Colors.white))),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.pink.shade300,
        focusColor: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.pink.shade50,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFFFFFDFD),
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        selectedItemColor: Colors.pink.shade300,
        selectedLabelStyle: TextStyle(
          color: Colors.pink.shade300,
          fontSize: 14,
        ),
        elevation: 0,
        unselectedItemColor: Colors.pink.shade100,
        unselectedLabelStyle: TextStyle(
          color: Colors.pink.shade100,
          fontSize: 14,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.pink.shade300,
        foregroundColor: Colors.white,
        shadowColor: Colors.pink.shade50,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: FontSize.xLarge.value,
        ),
      ),
      primaryColor: Colors.pink.shade300,
      tabBarTheme: TabBarTheme(
        unselectedLabelColor: Colors.pink.shade100,
        dividerColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        labelColor: Colors.white,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: Colors.white,
            width: 3,
          ),
        ),
      ),

      iconTheme: const IconThemeData(
        color: Color(0xFFB22554),
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
        mouseCursor: WidgetStateProperty.all(MouseCursor.uncontrolled),
        overlayColor: WidgetStateProperty.all(Colors.pink.withOpacity(.7)),
        fillColor: WidgetStateProperty.all(Colors.pink),
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(Colors.white),
        fillColor: WidgetStateProperty.all(Colors.pink.shade300),
        side: const BorderSide(
          color: Colors.black12,
          width: 3,
        ),
      ),
      chipTheme: ChipThemeData(
        color: WidgetStateProperty.all(Colors.black12),
        selectedColor: Colors.yellow,
        secondarySelectedColor: Colors.white,
        secondaryLabelStyle: TextStyle(
          color: Colors.pink.shade300,
        ),
        checkmarkColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        labelStyle: const TextStyle(
          color: Colors.white,
        ),
      ),
      colorScheme: ColorScheme(
        outline: Colors.white10,
        brightness: Brightness.light,
        primary: Colors.pink.shade300,
        primaryContainer: Colors.white,
        onPrimary: Colors.pink.shade300,
        secondary: Colors.pink,
        onSecondary: Colors.pink,
        error: const Color(0xffd00649),
        onError: const Color(0xffd00649),
        errorContainer: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
      ),
      bottomAppBarTheme: const BottomAppBarTheme(
        color: Color(0xFFFFFDFD),
        elevation: 0,
      ),
    ),
  );
}
