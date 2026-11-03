import 'package:bfban/component/_loading/index.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '/component/_empty/index.dart';
import '/component/_refresh/index.dart';
import '/constants/api.dart';
import '/data/index.dart';
import '/provider/userinfo_provider.dart';
import '/utils/index.dart';
import '/widgets/index.dart';

class UserHistoryPage extends StatefulWidget {
  const UserHistoryPage({super.key});

  @override
  State<UserHistoryPage> createState() => _UserHistoryPageState();
}

class _UserHistoryPageState extends State<UserHistoryPage> {
  // 列表
  final GlobalKey<RefreshState> _refreshKey = GlobalKey<RefreshState>();

  // 列表视图控制器
  final ScrollController _scrollController = ScrollController();

  TourRecordStatus tourRecordStatus = TourRecordStatus(
    load: false,
    list: [],
  );

  Storage storage = Storage();

  StoragePlayer storagePlayer = StoragePlayer();

  bool isEdit = false;

  bool selectAll = false;

  Map selectMap = {};

  bool get wantKeepAlive => true;

  @override
  void initState() {
    _getTourRecordList(isRefresh: true);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _getMore();
      }
    });

    super.initState();
  }

  /// [Result]
  /// 获取游览历史
  Future _getTourRecordList({bool isRefresh = false}) async {
    try {
      if (tourRecordStatus.load!) return;

      StorageData viewedData = await storage.get("viewed");
      int page = (tourRecordStatus.skip == null || tourRecordStatus.skip! < 1) ? 1 : tourRecordStatus.skip!;
      int limit = tourRecordStatus.limit ?? 40;

      Map viewed = viewedData.value is Map ? (viewedData.value as Map) : {};

      if (isRefresh) {
        setState(() {
          tourRecordStatus.list!.clear();
        });
      }

      if (viewed.isEmpty) {
        setState(() {
          tourRecordStatus.list = [];
          tourRecordStatus.load = false;
        });
        _refreshKey.currentState?.controller.finishLoad(IndicatorResult.noMore);
        return;
      }

      setState(() {
        tourRecordStatus.load = true;
      });

      // 按时间戳倒序排列（最新游览排在最前）
      List<MapEntry> sortedEntries = viewed.entries.toList();
      sortedEntries.sort((a, b) {
        num valA = (a.value is num) ? a.value as num : 0;
        num valB = (b.value is num) ? b.value as num : 0;
        return valB.compareTo(valA);
      });

      int total = sortedEntries.length;
      int start = (page - 1) * limit;

      if (start >= total) {
        setState(() {
          tourRecordStatus.load = false;
        });
        _refreshKey.currentState?.controller.finishLoad(IndicatorResult.noMore);
        return;
      }

      int end = (start + limit).clamp(0, total);
      List dbIds = sortedEntries.sublist(start, end).map((e) => int.tryParse(e.key.toString()) ?? e.key).toList();

      List<TourRecordPlayerBaseData> viewedWidgets = isRefresh ? [] : List.from(tourRecordStatus.list ?? []);

      if (dbIds.isNotEmpty) {
        Response result = await Http.request(
          Config.httpHost["player_batch"],
          data: {"dbIds": dbIds},
          method: Http.POST,
        );

        dynamic d = result.data;

        if (d != null && d["success"] == 1 && d["data"] is List) {
          // 为了保持按游览时间倒序，将返回的数据映射回 dbIds 的排序顺序
          Map<dynamic, dynamic> resultMap = {};
          for (var item in d["data"] as List) {
            if (item is Map && item["id"] != null) {
              resultMap[item["id"]] = item;
            }
          }
          for (var id in dbIds) {
            if (resultMap.containsKey(id)) {
              TourRecordPlayerBaseData baseData = TourRecordPlayerBaseData();
              baseData.setData(resultMap[id]);
              viewedWidgets.add(baseData);
            }
          }
        }
      }

      setState(() {
        tourRecordStatus.list = viewedWidgets;
        tourRecordStatus.load = false;
      });

      _refreshKey.currentState?.controller.finishLoad(
        end >= total ? IndicatorResult.noMore : IndicatorResult.success,
      );
    } catch (err) {
      setState(() {
        tourRecordStatus.load = false;
      });
    }
  }

  /// [Event]
  /// 下拉刷新方法,为list重新赋值
  Future _onRefresh() async {
    tourRecordStatus.skip = 1;

    await _getTourRecordList(isRefresh: true);

    _refreshKey.currentState?.controller.finishRefresh();
    _refreshKey.currentState?.controller.resetFooter();
  }

  /// [Event]
  /// 下拉 追加数据
  Future _getMore() async {
    if (tourRecordStatus.load!) return;

    tourRecordStatus.nextPage();
    await _getTourRecordList();
  }

  /// [Event]
  /// 全选
  void _selectAllItem(bool status) async {
    Map selectMap = {};

    setState(() {
      selectAll = status;
    });

    if (isEdit) {
      for (var i in tourRecordStatus.list!) {
        selectMap.addAll({i.id: status});
      }

      setState(() {
        this.selectMap = selectMap;
      });
    }
  }

  /// [Event]
  /// 选择删除
  void _selectDeleteItem() async {
    if (isEdit && selectMap.isNotEmpty) {
      StorageData viewedData = await storage.get("viewed");
      Map viewed = viewedData.value ?? {};

      for (var i in selectMap.entries) {
        if (i.value) {
          viewed.remove(i.key.toString());
        }
      }

      storage.set("viewed", value: viewed);

      await _getTourRecordList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "app.setting.cell.history.title")),
        actions: [
          IconButton(
            padding: const EdgeInsets.all(16),
            onPressed: () {
              setState(() {
                isEdit = !isEdit;
              });
            },
            icon: !isEdit ? const Icon(Icons.edit) : Text(FlutterI18n.translate(context, "basic.button.cancel")),
          ),
        ],
      ),
      body: Consumer<UserInfoProvider>(
        builder: (context, data, child) {
          return Refresh(
            key: _refreshKey,
            onRefresh: _onRefresh,
            child: Scrollbar(
              child: Column(
                children: [
                  /// Content List
                  if (!tourRecordStatus.load!)
                    Expanded(
                      flex: 1,
                      child: ListView(
                        controller: _scrollController,
                        children: [
                          // 列表
                          if (tourRecordStatus.list!.isNotEmpty)
                            Column(
                              children: tourRecordStatus.list!.map((i) {
                                return Row(
                                  children: [
                                    if (isEdit)
                                      Container(
                                        margin: const EdgeInsets.only(left: 0),
                                        child: Checkbox(
                                          visualDensity: VisualDensity.standard,
                                          value: selectMap[i.id] ?? false,
                                          onChanged: (status) {
                                            setState(() {
                                              selectMap[i.id] = status;
                                            });
                                          },
                                        ),
                                      ),
                                    Expanded(
                                      flex: 1,
                                      child: CheatListCard(item: i.toMap),
                                    ),
                                  ],
                                );
                              }).toList(),
                            )
                          else if (tourRecordStatus.list!.isEmpty && !tourRecordStatus.load!)
                            const EmptyWidget(),
                        ],
                      ),
                    )
                  else
                    const Expanded(
                      flex: 1,
                      child: Center(
                        child: Center(child: LoadingWidget()),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),

      /// toolbar
      bottomNavigationBar: isEdit
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.only(top: 5, bottom: 5, right: 15),
                color: Theme.of(context).bottomAppBarTheme.color,
                child: Row(
                  children: [
                    Checkbox(
                      value: selectAll,
                      onChanged: (status) => _selectAllItem(status!),
                    ),
                    const Expanded(
                      flex: 1,
                      child: SizedBox(),
                    ),
                    IconButton(
                      onPressed: () => _selectDeleteItem(),
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
