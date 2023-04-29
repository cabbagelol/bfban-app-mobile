import '../data/Theme.dart';
import '../themes/dark.dart';
import '../themes/green.dart';
import '../themes/lightnes.dart';
import '../themes/pink.dart';

String ThemeDefault = "dark";

Map<String, AppThemeItem>? ThemeList = {
  "dark": DarkTheme.data,
  "lightnes": LightnesTheme.data,
  "pink": PinkTheme.data,
  "green": GreenTheme.data,
};
