import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
Map THEMELIST = {
  /// 默认主题
  "none": {
    "name": "默认",
    "nameColor": Color(0xff364e80),
    "detail_cheaters_tabs_label": {
      "textColor": Colors.white54,
      "backgroundColor": Colors.yellow,
    },
    "index_community": {
      "statisticsBackground": Colors.black12,
      "statisticsText": Colors.white,
      "statisticsTextSubtitle": Colors.white54,
      "card": {
        "backgroundColor": Color(0xff111b2b),
        "subtitle1": Colors.white,
        "rightsubtitle": Colors.white54,
      },
    },
    "index_home": {
      "drawer": {
        "color": Color(0xff111b2b),
      },
      "buttonEdit": {
        "textColor": Colors.black,
        "backgroundColor": Colors.yellow,
      },
      "card": {
        "backgroundColor": Colors.black12,
        "subtitle1": Colors.white,
        "subtitle2": Color.fromRGBO(255, 255, 255, .6),
        "rightsubtitle1": Colors.white,
        "rightsubtitle2": Colors.white38,
      }
    },
    "index_index_tabs": {
      "backgroundColor": Colors.black,
      "actviveColor": Colors.yellow,
      "color": Colors.white,
    },
    "login_index": {
      "backgroundColor": Color.fromRGBO(17, 27, 43, .8),
    },
    "appBar": {
      "flexibleSpace": Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            colors: [Colors.transparent, Colors.black38],
          ),
        ),
      ),
    },
    "text": {
      "contrary": Colors.black,
      "subtitle": Colors.white,
      "secondary": Colors.white54,
      "subtext1": Colors.white38,
      "subtext2": Colors.white24,
      "subtext3": Colors.white12,
    },
    "card": {
      "prominent": Colors.black,
      "color": Colors.black12,
      "secondary": Color.fromRGBO(255, 255, 255, .07),
    },
    "button": {
      "textColor": Colors.white,
      "disableTextColor": Colors.black12,
      "backgroundColor": Color(0xff364e80),
      "disableBackgroundColor": Color(0xff364e80),
    },
    "input": {
      "prominent": Color(0xff111b2b),
      "color": Color(0xff111b2b),
    },
    "hr": {
      "color": Colors.white,
      "secondary": Colors.white12,
    },
    "data": ThemeData(
      platform: TargetPlatform.iOS,
      scaffoldBackgroundColor: Color(0xff111b2b),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      buttonColor: Color(0xff364e80),
      bottomAppBarColor: Colors.black,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
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
        textTheme: TextTheme(
          headline6: TextStyle(color: Colors.white, fontSize: 18),
        ),
        color: Color(0xff364e80),
      ),
      primaryColor: Color(0xff111b2b),
      accentColor: Color(0xfff2f2f2),
      tabBarTheme: TabBarTheme(
        unselectedLabelColor: Colors.white38,
        labelColor: Colors.yellow,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: Colors.yellow,
            width: 3,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.yellow,
        focusColor: Colors.black,
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      dividerColor: Colors.white12,
      cardColor: Colors.black12,
      primaryTextTheme: TextTheme(
        headline1: TextStyle(color: Colors.white),
        headline2: TextStyle(color: Colors.white70),
        headline3: TextStyle(color: Colors.white54),
        headline4: TextStyle(color: Colors.white38),
        headline5: TextStyle(color: Colors.white24),
        headline6: TextStyle(color: Colors.white12),
      ),
    ),
  },

  /// 明亮主题
  "bright": {
    "name": "白日",
    "nameColor": Color(0xfff2f2f2),
    "detail_cheaters_tabs_label": {
      "textColor": Colors.black,
      "backgroundColor": Colors.white,
    },
    "index_community": {
      "statisticsBackground": Colors.white,
      "statisticsText": Colors.black,
      "statisticsTextSubtitle": Colors.black54,
      "card": {
        "backgroundColor": Colors.white,
        "subtitle1": Colors.black,
        "rightsubtitle": Colors.black54,
      },
    },
    "index_home": {
      "drawer": {
        "color": Color(0xfff2f2f2),
      },
      "buttonEdit": {
        "textColor": Colors.white,
        "backgroundColor": Color(0xff364e80),
      },
      "card": {
        "backgroundColor": Colors.white,
        "subtitle1": Colors.black,
        "subtitle2": Color.fromRGBO(0, 0, 0, .6),
        "rightsubtitle1": Colors.black,
        "rightsubtitle2": Colors.black38,
      },
    },
    "index_index_tabs": {
      "backgroundColor": Colors.white,
      "actviveColor": Colors.black,
      "color": Color(0xff535353),
    },
    "login_index": {
      "backgroundColor": Colors.white38,
    },
    "appBar": {
      "flexibleSpace": Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            colors: [Colors.transparent, Color.fromRGBO(0, 0, 0, .1)],
          ),
        ),
      ),
    },
    "text": {
      "contrary": Colors.white,
      "subtitle": Colors.black,
      "secondary": Colors.black54,
      "subtext1": Colors.black38,
      "subtext2": Colors.black26,
      "subtext3": Colors.black12,
    },
    "card": {
      "prominent": Colors.white,
      "color": Colors.white,
      "secondary": Colors.white12,
    },
    "button": {
      "textColor": Colors.black,
      "disableTextColor": Colors.black54,
      "backgroundColor": Colors.white,
      "disableBackgroundColor": Color(0xfff2f2f2),
    },
    "input": {
      "prominent": Colors.white,
      "color": Colors.white,
    },
    "hr": {
      "color": Color(0xfff2f2f2),
      "secondary": Colors.black12,
    },
    "data": ThemeData(
      platform: TargetPlatform.iOS,
      scaffoldBackgroundColor: Color(0xfff2f2f2),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xff364e80),
        selectedLabelStyle: TextStyle(
          color: Color(0xff364e80),
          fontSize: 14,
        ),
        unselectedItemColor: Colors.black54,
        unselectedLabelStyle: TextStyle(
          color: Colors.black54,
          fontSize: 14,
        ),
      ),
      appBarTheme: AppBarTheme(
        color: Color(0xfff2f2f2),
        textTheme: TextTheme(
          headline6: TextStyle(color: Colors.black, fontSize: 18),
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      primaryColor: Colors.black,
      accentColor: Colors.white,
      tabBarTheme: TabBarTheme(
        unselectedLabelColor: Colors.black38,
        labelColor: Colors.black,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: Color(0xff535353),
            width: 3,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(0xff364e80),
        focusColor: Colors.white,
      ),
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
      dividerColor: Colors.black12,
      cardTheme: CardTheme(
        color: Colors.white,
      ),
      primaryTextTheme: TextTheme(
        headline1: TextStyle(color: Colors.black),
        headline2: TextStyle(color: Colors.black87),
        headline3: TextStyle(color: Colors.black54),
        headline4: TextStyle(color: Colors.black38),
        headline5: TextStyle(color: Colors.black26),
        headline6: TextStyle(color: Colors.black12),
      ),
    ),
  },

  /// 粉色
//  "pink": {
//    "name": "粉色才是男人",
//    "nameColor": Colors.pinkAccent,
//    "detail_cheaters_tabs_label": {
//      "textColor": Colors.black,
//      "backgroundColor": Colors.pinkAccent,
//    },
//    "index_community": {
//      "statisticsBackground": Colors.white,
//      "statisticsText": Colors.black,
//      "statisticsTextSubtitle": Colors.black54,
//      "card": {
//        "backgroundColor": Colors.white,
//        "subtitle1": Colors.black,
//        "rightsubtitle": Colors.black54,
//      },
//    },
//    "index_home": {
//      "drawer": {
//        "color": Colors.pinkAccent,
//      },
//      "buttonEdit": {
//        "textColor": Colors.white,
//        "backgroundColor": Colors.pinkAccent,
//      },
//      "card": {
//        "backgroundColor": Colors.white,
//        "subtitle1": Colors.black,
//        "subtitle2": Color.fromRGBO(0, 0, 0, .6),
//        "rightsubtitle1": Colors.black,
//        "rightsubtitle2": Colors.black38,
//      },
//    },
//    "index_index_tabs": {
//      "backgroundColor": Color(0xfffff4f8),
//      "actviveColor": Colors.pinkAccent,
//      "color": Colors.pinkAccent.shade100,
//    },
//    "login_index": {
//      "backgroundColor": Colors.white38,
//    },
//    "appBar": {
//      "flexibleSpace": Container(
//        decoration: BoxDecoration(
//          gradient: LinearGradient(
//            begin: Alignment.bottomRight,
//            colors: [Colors.transparent, Colors.black12],
//          ),
//        ),
//      ),
//    },
//    "text": {
//      "contrary": Colors.white,
//      "subtitle": Colors.black,
//      "secondary": Colors.black54,
//      "subtext1": Colors.black38,
//      "subtext2": Colors.black26,
//      "subtext3": Colors.black12,
//    },
//    "card": {
//      "prominent": Colors.white,
//      "color": Colors.white,
//      "secondary": Colors.white12,
//    },
//    "button": {
//      "textColor": Colors.black,
//      "backgroundColor": Colors.white,
//    },
//    "input": {
//      "prominent": Colors.white,
//      "color": Colors.pinkAccent.shade50,
//    },
//    "hr": {
//      "color": Color(0xfff2f2f2),
//      "secondary": Colors.black12,
//    },
//    "data": ThemeData(
//      platform: TargetPlatform.iOS,
//      scaffoldBackgroundColor: Color(0xfff2f2f2),
//      appBarTheme: AppBarTheme(
//        color: Colors.pinkAccent,
//        textTheme: TextTheme(
//          headline6: TextStyle(color: Colors.white, fontSize: 18),
//        ),
//        iconTheme: IconThemeData(
//          color: Colors.white,
//        ),
//      ),
//      primaryColor: Colors.black,
//      accentColor: Colors.white,
//      tabBarTheme: TabBarTheme(
//        unselectedLabelColor: Colors.black38,
//        labelColor: Colors.black,
//        indicator: UnderlineTabIndicator(
//          borderSide: BorderSide(
//            color: Color(0xff535353),
//            width: 3,
//          ),
//        ),
//      ),
//      iconTheme: IconThemeData(
//        color: Colors.white,
//      ),
//    ),
//  },
};
