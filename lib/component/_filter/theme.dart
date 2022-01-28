import 'dart:ui';

class FilterTheme {
  final FilterMaskTheme? maskTheme;
  final FilterTitleTheme? titleTheme;
  final FilterPanelTheme? panelThemel;

  FilterTheme({
    this.maskTheme,
    this.titleTheme,
    this.panelThemel,
  });
}

class FilterMaskTheme {
  final Color? color;

  FilterMaskTheme({
    this.color,
  });
}

class FilterTitleTheme {

}

class FilterPanelTheme {

}
