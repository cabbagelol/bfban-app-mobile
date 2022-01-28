/// 单选列表

import 'package:flutter/material.dart';

import '../index.dart';
import '../class.dart';
import '../framework.dart';

typedef IndexedFilterWidgetBuilder = Widget Function(BuildContext context, int index, int selectIndex);

class radioListFilter extends FilterPanelWidget {
  final IndexedFilterWidgetBuilder? itemBuilder;
  final int? itemCount;
  final Function? onChange;

  radioListFilter.builder({
    Key? key,
    this.itemCount,
    this.onChange,
    required this.itemBuilder,
  })
      : assert(itemCount == null || itemCount >= 0),
        super(key: key);

  @override
  _radioListFilterState createState() => _radioListFilterState();
}

class _radioListFilterState extends State<radioListFilter> {
  List? _list = [];

  @override
  void initState() {
    super.initState();
    if (!widget.isInit) {
      widget.data = FilterPanelData(
        value: 0,
        name: "",
      );
    }

    for (var i = 0; i < widget.itemCount!; i++) {
      _list?.add(i);
    }

    widget.isInit = true;
  }

  /// [Event]
  /// 通知
  onChange(value) {
    return () {
      setState(() {
        widget.data!.value = value;
      });

      widget.onChange == null ? null : widget.onChange!(widget.data);
    };
  }

  @override
  build(BuildContext context) {
    return emptyFilter(
      child: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _list!
                .map(
                  (e) =>
                  InkWell(
                    onTap: onChange(e),
                    child: widget.itemBuilder!(context, e, widget.data!.value),
                  ),
            )
                .toList(),
          ),
        ],
      ),
    );
  }
}
