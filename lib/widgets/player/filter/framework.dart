import 'package:flutter/material.dart';

import 'class.dart';

abstract class FilterPanelWidget extends StatefulWidget {
  final FilterPanelData? data;

  const FilterPanelWidget({
    super.key,
    this.data,
  });
}
