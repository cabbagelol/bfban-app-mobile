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

  @override
  static dynamic data = AppThemeItem(
    name: "green",
    isDefault: false,
    themeData: ThemeData(
      // GENERAL CONFIGURATION
      applyElevationOverlayColor: true,
      useMaterial3: true,
      // COLOR
      sliderTheme: SliderThemeData(
        valueIndicatorColor: Colors.pink.shade50,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0),
          foregroundColor: MaterialStateProperty.all(Colors.green.shade300),
          textStyle: MaterialStateProperty.all(
            TextStyle(color: Colors.green.shade300),
          ),
        ),
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
        trackColor: MaterialStateProperty.all(Colors.green.shade300.withOpacity(.2)),
        thumbColor: MaterialStateProperty.all(Colors.green.shade300),
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
      scrollbarTheme: const ScrollbarThemeData(
        thumbColor: MaterialStatePropertyAll(Colors.green),
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.green.shade300,
          disabledForegroundColor: Colors.green.shade300,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all(
            TextStyle(
              color: Colors.green.shade300,
            ),
          ),
          elevation: MaterialStateProperty.all(0.2),
          backgroundColor: MaterialStateProperty.all(Colors.green.shade300),
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
      bannerTheme: MaterialBannerThemeData(
        backgroundColor: Colors.green.shade300,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.green.shade300,
        disabledColor: Colors.green.shade300.withOpacity(.2),
      ),
      buttonBarTheme: const ButtonBarThemeData(
        layoutBehavior: ButtonBarLayoutBehavior.constrained,
      ),
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
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        labelColor: Colors.white,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: Colors.green,
            width: 3,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.green.shade300,
        focusColor: Colors.white,
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
        mouseCursor: MaterialStateProperty.all(MouseCursor.uncontrolled),
        overlayColor: MaterialStateProperty.all(Colors.green.withOpacity(.7)),
        fillColor: MaterialStateProperty.all(Colors.green),
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: MaterialStateProperty.all(Colors.white),
        fillColor: MaterialStateProperty.all(Colors.green.shade300),
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
        background: Colors.white,
        onBackground: Colors.white,
        surface: Colors.white,
        onSurface: Colors.white,
        // background: Colors.black,
      ),
      bottomAppBarTheme: const BottomAppBarTheme(
        color: Color(0xFFFFFDFD),
        elevation: 0,
      ),
    ),
  );
}
