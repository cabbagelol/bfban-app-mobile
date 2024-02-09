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
    if (dateValue.startDate != null && dateValue.endDate != null) widget.data!.value = "${dateValue.startDate ?? 'null'},${dateValue.endDate ?? 'null'}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
      child: SfDateRangePicker(
        onSelectionChanged: _onSelectionChanged,
        headerStyle: DateRangePickerHeaderStyle(
          textStyle: Theme.of(context).textTheme.bodyMedium,
        ),
        yearCellStyle: DateRangePickerYearCellStyle(
          textStyle: Theme.of(context).textTheme.bodyMedium,
          disabledDatesTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(.4),
              ),
        ),
        monthCellStyle: DateRangePickerMonthCellStyle(
          textStyle: Theme.of(context).textTheme.bodyMedium,
          disabledDatesTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(.4),
              ),
        ),
        monthViewSettings: DateRangePickerMonthViewSettings(
          viewHeaderHeight: 0,
          viewHeaderStyle: DateRangePickerViewHeaderStyle(
            textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 15,
                ),
          ),
          weekNumberStyle: DateRangePickerWeekNumberStyle(textStyle: Theme.of(context).textTheme.bodyMedium!),
        ),
        view: DateRangePickerView.month,
        selectionMode: DateRangePickerSelectionMode.range,
        maxDate: DateTime.now(),
        minDate: DateTime.fromMicrosecondsSinceEpoch(1514764800000),
        navigationDirection: DateRangePickerNavigationDirection.vertical,
        viewSpacing: .2,
      ),
    );
  }
}
