import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '/component/_time/index.dart';
import 'class.dart';
import 'framework.dart';

class UpdateTimeFilterPanel extends FilterPanelWidget {
  UpdateTimeFilterPanel({
    Key? key,
  }) : super(key: key);

  @override
  UpdateTimeFilterPanelState createState() => UpdateTimeFilterPanelState();
}

class UpdateTimeFilterPanelState extends State<UpdateTimeFilterPanel> {
  PickerDateRange? value;

  @override
  void initState() {
    widget.data ??= FilterPanelData(
      values: [null, null],
      names: ["updateTimeFrom", "updateTimeTo"],
    );

    super.initState();
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs date) {
    PickerDateRange dateValue = date.value;
    if (dateValue.startDate != null && dateValue.endDate != null) value = dateValue;
  }

  void _close() {
    Navigator.pop(context);
  }

  void _done() {
    if (value != null) {
      setState(() {
        widget.data!.values[0] = value!.startDate!.millisecondsSinceEpoch;
        widget.data!.values[1] = value!.endDate!.millisecondsSinceEpoch;
      });
    }

    Navigator.pop(context);
  }

  void _open() {
    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Column(
          children: [
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: const Icon(Icons.clear), onPressed: () => _close()),
                  Flexible(
                    flex: 1,
                    child: Wrap(
                      spacing: 5,
                      runAlignment: WrapAlignment.center,
                      children: [
                        const Icon(Icons.date_range),
                        Text(
                          FlutterI18n.translate(context, "list.reportTime"),
                          style: TextStyle(fontSize: FontSize.large.value),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.done),
                    onPressed: () => _done(),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              child: SfDateRangePicker(
                onSelectionChanged: _onSelectionChanged,
                selectionShape: DateRangePickerSelectionShape.rectangle,
                selectionTextStyle: Theme.of(context).textTheme.bodyMedium,
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
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
                side: BorderSide(
                  color: Theme.of(context).dividerTheme.color!,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(FlutterI18n.translate(context, "list.updateTime")),
                    if (!widget.data!.isValueNull)
                      Row(
                        children: [
                          TimeWidget(
                            data: DateTime.fromMillisecondsSinceEpoch(widget.data!.values[0] as int).toLocal().toString(),
                            timeType: "Y_D",
                            type: TimeWidgetType.convert,
                            style: Theme.of(context).listTileTheme.subtitleTextStyle,
                          ),
                          Text(
                            " - ",
                            style: Theme.of(context).listTileTheme.subtitleTextStyle,
                          ),
                          TimeWidget(
                            data: DateTime.fromMillisecondsSinceEpoch(widget.data!.values[1] as int).toLocal().toString(),
                            timeType: "Y_D",
                            type: TimeWidgetType.convert,
                            style: Theme.of(context).listTileTheme.subtitleTextStyle,
                          )
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (!widget.data!.isValueNull)
            Container(
              margin: const EdgeInsets.only(left: 10),
              child: IconButton.outlined(
                onPressed: () {
                  setState(() {
                    widget.data!.values = [null, null];
                  });
                },
                icon: const Icon(Icons.clear),
              ),
            )
        ],
      ),
      onTap: () => _open(),
    );
  }
}
