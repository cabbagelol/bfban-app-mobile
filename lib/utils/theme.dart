/// 主题

import 'package:bfban/utils/index.dart' show Storage, AppInfoProvider;
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

/// eumn
enum appThemeType {
  none,
  main,
}

/// 主题列表
final Map<String, AppThemeItem> appThemeList = {
  "default": AppThemeItem(
    name: "default",
    isDefault: true,
    themeData: ThemeData(
      backgroundColor: Color(0xff0d1421),
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xff364e80),
        onPrimary: Color(0xff364e80),
        secondary: Color(0xfff2f2f2),
        onSecondary: Color(0xfff2f2f2),
        error: Colors.red,
        onError: Colors.red,
        background: Color(0xff111b2b),
        onBackground: Color(0xff111b2b),
        surface: Colors.white,
        onSurface: Colors.white,
      ),
      textTheme: TextTheme(
        // displayLarge: const TextStyle(color: Colors.white),
        // displayMedium: const TextStyle(color: Colors.white),
        // displaySmall: const TextStyle(color: Colors.white),
        // headlineLarge: const TextStyle(color: Colors.white),
        // headlineMedium: const TextStyle(color: Colors.white),
        // headlineSmall: const TextStyle(color: Colors.white),
        // titleLarge: const TextStyle(color: Colors.white),
        // titleMedium: const TextStyle(color: Colors.white),
        // titleSmall: const TextStyle(color: Colors.white),
        // bodyLarge: const TextStyle(color: Colors.white),
        // bodyMedium: const TextStyle(color: Colors.white),
        // bodySmall: const TextStyle(color: Colors.white),
        // labelLarge: const TextStyle(color: Colors.white),
        // labelMedium: const TextStyle(color: Colors.white),
        // labelSmall: const TextStyle(color: Colors.white),
        headline1: const TextStyle(color: Colors.white),
        headline2: const TextStyle(color: Colors.white),
        headline3: const TextStyle(color: Colors.white),
        headline4: const TextStyle(color: Colors.white),
        headline5: const TextStyle(color: Colors.white),
        headline6: const TextStyle(color: Colors.white),
        subtitle1: const TextStyle(color: Colors.white),
        subtitle2: const TextStyle(color: Colors.white54),
        bodyText1: const TextStyle(color: Colors.white),
        bodyText2: const TextStyle(color: Colors.white),
        // caption: const TextStyle(color: Colors.white),
        // button: const TextStyle(color: Colors.white),
        // overline: const TextStyle(color: Colors.white),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: Color(0x7a364e80),
        selectionHandleColor: Color(0xff364e80),
        cursorColor: Colors.white,
      ),
      unselectedWidgetColor: Colors.white,
      scaffoldBackgroundColor: const Color(0xff111b2b),
      bottomAppBarColor: Colors.black,
      splashColor: Colors.transparent,
      dialogBackgroundColor: Colors.white,
      dialogTheme: DialogTheme(
        elevation: 10,
        backgroundColor: Color(0xff364e80),
        titleTextStyle: TextStyle(
          color: Colors.white,
        ),
      ),
      highlightColor: Colors.transparent,
      toggleButtonsTheme: ToggleButtonsThemeData(
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
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: Colors.white,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: const Color(0xff364e80),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0.2),
          backgroundColor: MaterialStateProperty.all(Color(0xff111b2b)),
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
      bannerTheme: MaterialBannerThemeData(
        backgroundColor: Color(0xff364e80),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Color(0xff364e80),
        disabledColor: Color(0xff364e80).withOpacity(.2),
      ),
      bottomAppBarTheme: BottomAppBarTheme(
        color: Colors.black,
        elevation: 0,
      ),
      buttonBarTheme: ButtonBarThemeData(
        layoutBehavior: ButtonBarLayoutBehavior.constrained,
      ),
      navigationBarTheme: NavigationBarThemeData(
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
        color: Color(0xff364e80),
        foregroundColor: Colors.white,
        shadowColor: Colors.black26,
        elevation: 0,
      ),
      primaryColor: const Color(0xff111b2b),
      tabBarTheme: const TabBarTheme(
        unselectedLabelColor: Colors.white38,
        labelColor: Colors.yellow,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: Colors.yellow,
            width: 3,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.yellow,
        focusColor: Colors.black,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      dividerColor: Colors.white12,
      cardTheme: const CardTheme(
        color: Color(0xff0d1323),
        shadowColor: Color(0xff0d1323),
      ),
      cardColor: const Color(0xff0d1323),
      primaryTextTheme: const TextTheme(
        headline1: const TextStyle(color: Colors.white),
        headline2: const TextStyle(color: Colors.white70),
        headline3: const TextStyle(color: Colors.white54),
        headline4: TextStyle(color: Colors.white38),
        headline5: const TextStyle(color: Colors.white24),
        headline6: const TextStyle(color: Colors.white12),
      ),
    ),
  )
};

/// 主题管理类
class ThemeUtil {
  // 当前主题
  AppThemeItem appTheme = AppThemeItem(name: "none");

  /// 公开 获取主题列表
  Map<String, AppThemeItem> get list => appThemeList;

  /// 初始化
  ready(context) async {
    final String storageThemeName = await Storage().get('com.bfban.theme');
    String themeName = "default";

    if (storageThemeName.isNotEmpty) {
      themeName = storageThemeName;
    }

    // await Provider.of<AppInfoProvider>(context, listen: false)
    //     .setTheme(themeName);

    print("default: " + themeName);
    return name(themeName);
  }

  /// 获取特定主题实例
  AppThemeItem? name(String name) {
    return appThemeList[name];

    // 没有取默认
    // return appThemeList["default"];
  }
}

/// 单个主题
class AppThemeItem {
  final String name;
  final bool isDefault;
  final ThemeData? themeData;

  AppThemeItem({
    this.name = "none",
    this.isDefault = false,
    this.themeData,
  });
}
