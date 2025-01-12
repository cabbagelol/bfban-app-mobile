import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

import '../data/index.dart';

class GreenTheme extends AppBaseThemeItem {
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
    name: "green",
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

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.green.withOpacity(.1),
        modalBackgroundColor: Colors.green.withOpacity(.1),
      ),
      canvasColor: const Color(0xFF4CAF50),
      primaryColorLight: const Color(0xFF4CAF50),
      primaryColorDark: const Color(0xFF4CAF50),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Color(0xFF5DB761)),
        displayMedium: TextStyle(color: Color(0xFF5DB761)),
        displaySmall: TextStyle(color: Color(0xFF5DB761)),
        headlineMedium: TextStyle(color: Colors.black),
        headlineSmall: TextStyle(color: Colors.black),
        titleLarge: TextStyle(color: Color(0xFF072F07)),
        titleMedium: TextStyle(color: Color(0xFF072F07)),
        titleSmall: TextStyle(color: Color(0xFF072F07)),
        bodyLarge: TextStyle(color: Color(0xFF072F07)),
        bodyMedium: TextStyle(color: Color(0xFF072F07)),
        bodySmall: TextStyle(color: Color(0xFF072F07)),
      ),
      switchTheme: const SwitchThemeData().copyWith(
        trackColor: WidgetStateProperty.all(Colors.green.shade300.withOpacity(.2)),
        thumbColor: WidgetStateProperty.all(Colors.green.shade300),
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: Colors.green.shade300.withOpacity(.1),
        selectionHandleColor: Colors.green.shade300.withOpacity(.1),
        cursorColor: Colors.green.shade300,
      ),
      unselectedWidgetColor: Colors.white,
      scaffoldBackgroundColor: const Color(0xFFF4FFF4),
      splashColor: Colors.transparent,
      dialogBackgroundColor: Colors.white,
      dialogTheme: DialogTheme(
        elevation: 10,
        backgroundColor: Colors.green.shade300,
        titleTextStyle: const TextStyle(
          color: Colors.white,
        ),
      ),
      highlightColor: Colors.transparent,
      scrollbarTheme: const ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(Colors.green),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.green,
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
      popupMenuTheme: const PopupMenuThemeData(
        color: Colors.white,
        textStyle: TextStyle(
          color: Colors.black,
        ),
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
      dividerColor: Colors.green.shade50,
      dividerTheme: DividerThemeData(
        color: Colors.green.shade50,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      bannerTheme: MaterialBannerThemeData(
        backgroundColor: Colors.green.shade300,
      ),

      // 按钮 S
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.green.shade300,
        disabledColor: Colors.green.shade300.withOpacity(.2),
      ),
      toggleButtonsTheme: ToggleButtonsThemeData(
        color: Colors.green.shade50,
        fillColor: Colors.green.shade50,
        textStyle: TextStyle(
          color: Colors.green.shade300,
        ),
        focusColor: Colors.white60,
        selectedColor: Colors.white,
        selectedBorderColor: Colors.green.shade800,
        splashColor: Colors.black38,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.green.shade300,
        focusColor: Colors.white,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(overlayColor: WidgetStateProperty.all(Colors.transparent)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.green.shade300,
          disabledForegroundColor: Colors.green.shade300,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          elevation: WidgetStateProperty.all(0),
          foregroundColor: WidgetStateProperty.all(Colors.green.shade300),
          textStyle: WidgetStateProperty.all(
            TextStyle(color: Colors.green.shade300),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all(
            TextStyle(
              color: Colors.green.shade300,
            ),
          ),
          elevation: WidgetStateProperty.all(0.2),
          backgroundColor: WidgetStateProperty.all(Colors.green.shade300),
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
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(Colors.white),
        ),
      ),
      // 按钮 E

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.green.shade50,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFFFFFDFD),
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        selectedItemColor: Colors.green.shade300,
        selectedLabelStyle: TextStyle(
          color: Colors.green.shade300,
          fontSize: 14,
        ),
        elevation: 0,
        unselectedItemColor: Colors.green.shade100,
        unselectedLabelStyle: TextStyle(
          color: Colors.green.shade100,
          fontSize: 14,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        shadowColor: Colors.green.shade50,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(
          color: Colors.green.shade900,
        ),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: FontSize.xLarge.value,
        ),
      ),
      primaryColor: Colors.green,
      tabBarTheme: TabBarTheme(
        unselectedLabelColor: Colors.green.shade100,
        dividerColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        labelColor: Colors.white,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: Colors.green,
            width: 3,
          ),
        ),
      ),
      iconTheme: IconThemeData(
        color: Colors.green.shade900,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        shadowColor: Colors.transparent,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
          side: BorderSide(
            color: Colors.green.shade50,
            width: 1,
          ),
        ),
      ),
      radioTheme: RadioThemeData(
        mouseCursor: WidgetStateProperty.all(MouseCursor.uncontrolled),
        overlayColor: WidgetStateProperty.all(Colors.green.withOpacity(.7)),
        fillColor: WidgetStateProperty.all(Colors.green),
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(Colors.white),
        fillColor: WidgetStateProperty.all(Colors.green.shade300),
        side: const BorderSide(
          color: Colors.black12,
          width: 3,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.black12,
        secondarySelectedColor: Colors.white,
        checkmarkColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.green.shade300,
        ),
        secondaryLabelStyle: TextStyle(
          color: Colors.green.shade300,
        ),
        labelStyle: TextStyle(
          color: Colors.green.shade300,
        ),
      ),
      colorScheme: ColorScheme(
        outline: Colors.white10,
        brightness: Brightness.light,
        primary: Colors.green.shade300,
        primaryContainer: Colors.white,
        onPrimary: Colors.green.shade300,
        secondary: Colors.green,
        onSecondary: Colors.green,
        error: Colors.redAccent,
        onError: Colors.redAccent,
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
