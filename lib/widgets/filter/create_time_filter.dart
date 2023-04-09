import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../component/_filter/class.dart';
import '../../component/_filter/framework.dart';

class CreateTimeFilterPanel extends FilterPanelWidget {
  CreateTimeFilterPanel({
    Key? key,
  }) : super(key: key);

  @override
  CreateTimeFilterPanelState createState() => CreateTimeFilterPanelState();
}

class CreateTimeFilterPanelState extends State<CreateTimeFilterPanel> {
  @override
  void initState() {
    super.initState();

    if (!widget.isInit) {
      widget.data = FilterPanelData(
        value: "updateTime",
        name: "sortBy",
      );
    }

    widget.isInit = true;
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs date) {
    PickerDateRange dateValue = date.value;
    widget.data!.value = "${dateValue.startDate},${dateValue.endDate}";
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: SfDateRangePicker(
        onSelectionChanged: _onSelectionChanged,
        view: DateRangePickerView.month,
        selectionMode: DateRangePickerSelectionMode.range,
        maxDate: DateTime.now(),
        minDate: DateTime.fromMicrosecondsSinceEpoch(1514764800000),
        navigationDirection: DateRangePickerNavigationDirection.vertical,
        monthViewSettings: const DateRangePickerMonthViewSettings(
          viewHeaderHeight: 0,
        ),
        viewSpacing: .2,
      ),
    );
  }
}
