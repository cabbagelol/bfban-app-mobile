import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  get d => data;

  @override
  static dynamic data = AppThemeItem(
    name: "pink",
    isDefault: false,
    themeData: ThemeData(
      sliderTheme: SliderThemeData(
        valueIndicatorColor: Colors.pink.shade50,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.pink.shade300),
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
        trackColor: MaterialStateProperty.all(Colors.pink.shade300.withOpacity(.2)),
        thumbColor: MaterialStateProperty.all(Colors.pink.shade300),
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: Colors.pink.shade300.withOpacity(.1),
        selectionHandleColor: Colors.pink.shade300.withOpacity(.1),
        cursorColor: Colors.pink.shade300,
      ),
      unselectedWidgetColor: Colors.white,
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
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.white,
      ),
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
              color: Colors.pink.shade300,
            ),
          ),
          elevation: MaterialStateProperty.all(0.2),
          backgroundColor: MaterialStateProperty.all(Colors.pink.shade300),
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
        backgroundColor: Colors.pink.shade300,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.pink.shade300,
        disabledColor: Colors.pink.shade300.withOpacity(.2),
      ),
      buttonBarTheme: const ButtonBarThemeData(
        layoutBehavior: ButtonBarLayoutBehavior.constrained,
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
        backgroundColor: Colors.pink.shade300,
        focusColor: Colors.white,
      ),
      iconTheme: IconThemeData(
        color: Colors.pink.shade300,
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
        fillColor: MaterialStateProperty.all(Colors.pink.shade300),
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
          color: Colors.pink.shade300,
        ),
        secondaryLabelStyle: TextStyle(
          color: Colors.pink.shade300,
        ),
        labelStyle: TextStyle(
          color: Colors.pink.shade300,
        ),
      ),
      colorScheme: ColorScheme(
        outline: Colors.white10,
        brightness: Brightness.dark,
        primary: Colors.pink.shade300,
        onPrimary: Colors.pink.shade300,
        secondary: const Color(0xff0a111c),
        onSecondary: const Color(0xff0a111c),
        error: Colors.redAccent,
        onError: Colors.redAccent,
        errorContainer: Colors.white,
        background: const Color(0xff111b2b),
        onBackground: const Color(0xff111b2b),
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
