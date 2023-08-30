import '../data/Theme.dart';
import '../themes/blueDark.dart';
import '../themes/dark.dart';
import '../themes/green.dart';
import '../themes/lightnes.dart';
import '../themes/pink.dart';

String ThemeDefault = "dark";

Map<String, AppBaseThemeItem>? ThemeList = {
  "blueDark": BlueDarkTheme(),
  "dark": DarkTheme(),
  "lightnes": LightnesTheme(),
  "pink": PinkTheme(),
  "green": GreenTheme(),
};
