import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../../component/_filter/framework.dart';
import 'game_filter.dart';
import 'solt_filter.dart';

class PlayerFilterPanel extends FilterPanelWidget {
  final Function(Map value) onChange;

  PlayerFilterPanel({
    Key? key,
    required this.onChange,
  }) : super(key: key);

  @override
  State<PlayerFilterPanel> createState() => PlayerFilterPanelState();
}

class PlayerFilterPanelState extends State<PlayerFilterPanel> {
  // 筛选
  Map _playerFilter = {"status": 0};

  // 原始筛选表单
  Map _primitive_from = {};

  // 确定筛选表单
  Map _from = {};

  int get status => _playerFilter["status"] ??= false;

  Map get value => _from;

  List<Widget> slots = [
    SoltFilterPanel(),
    const SizedBox(height: 10),
    GameNameFilterPanel(),
  ];

  @override
  void initState() {
    super.initState();
  }

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
    for (var element in slots) {
      if (element is FilterPanelWidget) _from[element.data!.name] = element.data!.value!;
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
      useSafeArea: false,
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
                      child: Text(
                        FlutterI18n.translate(context, "list.colums.screenTitle"),
                        style: TextStyle(fontSize: FontSize.large.value),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  children: slots,
                ),
              )
            ],
          ),
        );
      },
    );

    filterModal.then((void value) {
      if (_playerFilter["status"] != 2)
        setState(() {
          _playerFilter["status"] = 0;
        });
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 储存初始表单值，后期对比是否变动
      for (var element in slots) {
        if (element is FilterPanelWidget && element.data != null) {
          _primitive_from[element.data!.name] = element.data!.value!;
        }
      }
    });

    return IconButton(
      onPressed: () => _openPlayerFilter(1),
      icon: Icon(
        [Icons.filter_alt_outlined, Icons.filter_alt_outlined, Icons.filter_alt][status],
        color: [Theme.of(context).tabBarTheme.unselectedLabelColor, Theme.of(context).tabBarTheme.labelColor, Theme.of(context).tabBarTheme.labelColor][status],
      ),
    );
  }
}
