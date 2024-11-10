import 'package:bfban/widgets/search/filter/search_sort_filter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../player/filter/framework.dart';

class SearchFilterPanel extends StatefulWidget {
  final Function(Map value) onChange;

  SearchFilterPanel({
    Key? key,
    required this.onChange,
  }) : super(key: key);

  @override
  State<SearchFilterPanel> createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterPanel> {
  // 筛选
  final Map _playerFilter = {"status": 0};

  // 原始筛选表单
  final Map _primitive_from = {};

  // 确定筛选表单
  final Map _from = {};

  List<Widget> slots = [
    SearchSortFilterPanel(),
    const SizedBox(height: 10),
  ];

  int get status => _playerFilter["status"] ??= false;

  Map get value => _from;

  /// [Event]
  /// 对比表单变化
  bool diffFrom() {
    bool hasChange = false;
    _from.forEach((key, value) {
      if (_primitive_from.containsKey(key) && _primitive_from[key] != value || _from.keys.length != _primitive_from.keys.length) {
        hasChange = true;
      }
    });
    return hasChange;
  }

  void _closePlayerFilter() {
    setState(() {
      _playerFilter["status"] = 0;
    });

    widget.onChange(_primitive_from);

    Navigator.pop(context);
  }

  void _donePlayerFilter() {
    _from.clear();

    for (var element in slots) {
      if (element is FilterPanelWidget) _from.addAll(element.data!.toMap());
    }

    setState(() {
      _playerFilter["status"] = 2;
    });

    if (diffFrom()) widget.onChange(_from);

    Navigator.pop(context);
  }

  /// [Event]
  /// 玩家筛选
  void _openPlayerFilter(int status) {
    setState(() {
      if (_playerFilter["status"] != 2) _playerFilter["status"] = status;
    });

    Future<void> filterModal = showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _closePlayerFilter(),
                    ),
                    Flexible(
                      flex: 1,
                      child: Wrap(
                        spacing: 5,
                        runAlignment: WrapAlignment.center,
                        children: [
                          const Icon(Icons.filter_list),
                          Text(
                            FlutterI18n.translate(context, "list.colums.screenTitle"),
                            style: TextStyle(fontSize: FontSize.large.value),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.done),
                      onPressed: () => _donePlayerFilter(),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: slots,
                ),
              )
            ],
          ),
        );
      },
    );

    filterModal.then((void value) {
      if (_playerFilter["status"] != 2) {
        setState(() {
          _playerFilter["status"] = 0;
        });
      }
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _openPlayerFilter(1),
      icon: Icon(
        [Icons.filter_alt_outlined, Icons.filter_alt_outlined, Icons.filter_alt][status],
        color: [Theme.of(context).colorScheme.primary, Color.lerp(Theme.of(context).colorScheme.primary, Colors.white, .5), Theme.of(context).colorScheme.primary][status],
      ),
    );
  }
}
