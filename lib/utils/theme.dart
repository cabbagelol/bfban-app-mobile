/// 主题

import 'package:bfban/utils/index.dart' show Storage, AppInfoProvider;
import 'package:bfban/constants/theme.dart';

import 'package:provider/provider.dart';

class ThemeUtil {
  ready (context) async {
    String themeName = await Storage.get('com.bfban.theme');
    await Provider.of<AppInfoProvider>(context, listen: false).setTheme(themeName ?? 'none');

    return THEMELIST[themeName];
  }
}