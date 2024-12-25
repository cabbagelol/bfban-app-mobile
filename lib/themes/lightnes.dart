import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

import '../data/index.dart';

class LightnesTheme extends AppBaseThemeItem {
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
    name: "lightnes",
    isDefault: true,
    themeData: ThemeData(
      brightness: Brightness.light,
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
        backgroundColor: Colors.white,
        modalBackgroundColor: Colors.white,
      ),
      canvasColor: Colors.white,
      primaryColorLight: const Color(0xff364e80),
      primaryColorDark: const Color(0xff364e80),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.black),
        displayMedium: TextStyle(color: Colors.black),
        displaySmall: TextStyle(color: Colors.black),
        labelLarge: TextStyle(color: Colors.black26),
        labelMedium: TextStyle(color: Colors.black26),
        labelSmall: TextStyle(color: Colors.black26),
        headlineLarge: TextStyle(color: Colors.black26),
        headlineMedium: TextStyle(color: Colors.black26),
        headlineSmall: TextStyle(color: Colors.black26),
        titleLarge: TextStyle(color: Colors.black),
        titleMedium: TextStyle(color: Colors.black),
        titleSmall: TextStyle(color: Colors.black),
        bodyLarge: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.black),
        bodySmall: TextStyle(color: Colors.black),
      ),
      switchTheme: const SwitchThemeData().copyWith(
        trackColor: WidgetStateProperty.all(const Color(0xff364e80).withOpacity(.2)),
        thumbColor: WidgetStateProperty.all(const Color(0xff364e80)),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: const TextStyle(
          color: Colors.black,
        ),
        inputDecorationTheme: const InputDecorationTheme(),
        menuStyle: MenuStyle(
          elevation: WidgetStateProperty.all(2),
          backgroundColor: WidgetStateProperty.all(Colors.black),
          surfaceTintColor: WidgetStateProperty.all(Colors.black),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: const Color(0x7a364e80),
        selectionHandleColor: const Color(0x7a364e80),
        cursorColor: const Color(0x7a364e80),
      ),
      unselectedWidgetColor: const Color(0xfff7f9fd),
      scaffoldBackgroundColor: const Color(0xfff7f9fd),
      splashColor: Colors.transparent,
      dialogBackgroundColor: Colors.white,
      dialogTheme: const DialogTheme(
        elevation: 2,
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.black,
        ),
      ),
      highlightColor: Colors.transparent,
      scrollbarTheme: const ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(Colors.black12),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.black87,
        linearTrackColor: Colors.black12,
        refreshBackgroundColor: Colors.white,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: Colors.white,
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
        labelTextStyle: WidgetStateProperty.all(const TextStyle(
          color: Colors.black,
        )),
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
      dividerColor: const Color(0xffececec),
      dividerTheme: const DividerThemeData(
        color: Color(0xffe7e7e7),
      ),
      dataTableTheme: const DataTableThemeData(
        horizontalMargin: 10,
        columnSpacing: 20,
        headingRowHeight: 40,
        checkboxHorizontalMargin: 40,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      bannerTheme: const MaterialBannerThemeData(
        backgroundColor: Color(0xffffffff),
      ),

      // 按钮 S
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.white,
        disabledColor: const Color(0xff364e80).withOpacity(.2),
      ),
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
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xff364e80),
        focusColor: Colors.white,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          iconColor: const WidgetStatePropertyAll(Color(0xff364e80)),
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
          elevation: WidgetStateProperty.all(0),
          foregroundColor: WidgetStateProperty.all(const Color(0xff364e80)),
          textStyle: WidgetStateProperty.all(
            const TextStyle(color: Color(0xff364e80)),
          ),
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
          elevation: WidgetStateProperty.all(0),
          backgroundColor: WidgetStateProperty.all(const Color(0xff364e80)),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          visualDensity: VisualDensity.comfortable,
          shadowColor: WidgetStateProperty.all(Colors.black),
          overlayColor: WidgetStateProperty.all(const Color(0xff2c416e).withOpacity(.5)),
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
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(Colors.white),
        ),
      ),
      // 按钮 E

      bottomAppBarTheme: const BottomAppBarTheme(
        color: Colors.white,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
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
        backgroundColor: Color(0xfff1f5ff),
        foregroundColor: const Color(0xff364e80),
        shadowColor: Colors.black26,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xff364e80),
        ),
        actionsIconTheme: const IconThemeData(
          color: Color(0xff364e80),
        ),
        titleTextStyle: TextStyle(
          color: const Color(0xff364e80),
          fontSize: FontSize.xLarge.value,
        ),
      ),
      primaryColor: Colors.white,

      tabBarTheme: TabBarTheme(
        unselectedLabelColor: Colors.black54,
        dividerColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        labelColor: const Color(0xff364e80),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: Color(0xff364e80),
            width: 3,
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xff364e80),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        shadowColor: const Color(0x39131372),
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
          side: const BorderSide(
            color: Colors.black12,
            width: 1,
          ),
        ),
      ),
      cardColor: const Color(0xfff2f2f2),
      radioTheme: RadioThemeData(
        mouseCursor: WidgetStateProperty.all(MouseCursor.uncontrolled),
        overlayColor: WidgetStateProperty.all(const Color(0xff364e80).withOpacity(.7)),
        fillColor: WidgetStateProperty.all(const Color(0xff364e80)),
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(Colors.white),
        fillColor: WidgetStateProperty.all(const Color(0xff364e80)),
        side: const BorderSide(
          color: Colors.black12,
          width: 3,
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: Colors.white10,
        secondarySelectedColor: Colors.black,
        checkmarkColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        secondaryLabelStyle: TextStyle(
          color: Colors.black,
        ),
        labelStyle: TextStyle(
          color: Colors.black,
        ),
      ),
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xff364e80),
        primaryContainer: Colors.white,
        onPrimary: Color(0xff364e80),
        onPrimaryContainer: Colors.white,
        secondary: Color(0xff99acd2),
        onSecondary: Color(0xff99acd2),
        error: Colors.red,
        onError: Colors.red,
        errorContainer: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
      ),
    ),
  );
}
