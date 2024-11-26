import 'package:flutter/material.dart';

import 'class.dart';

abstract class FilterPanelWidget extends StatefulWidget {
  late FilterPanelData? data;

  FilterPanelWidget({
    super.key,
    this.data,
  });
}
