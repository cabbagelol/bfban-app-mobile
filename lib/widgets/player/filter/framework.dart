import 'package:flutter/material.dart';

import 'class.dart';

abstract class FilterPanelWidget extends StatefulWidget {
  FilterPanelData? data;

  FilterPanelWidget({
    Key? key,
    this.data,
  }) : super(key: key);
}
