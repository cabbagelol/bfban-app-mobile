import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '../../../component/_empty/index.dart';
import '../../../component/_refresh/index.dart';
import '../../../constants/api.dart';
import '../../../data/index.dart';
import '../../../provider/userinfo_provider.dart';
import '../../../utils/index.dart';
import '../../../widgets/hint_login.dart';
import '../../../widgets/index.dart';

class UserHistoryPage extends StatefulWidget {
  const UserHistoryPage();

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

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _getTourRecordList();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _getMore();
      }
    });

    super.initState();
  }

  /// [Result]
  /// 获取游览历史
  Future _getTourRecordList() async {
    try {
      if (tourRecordStatus.load!) return;

      StorageData viewedData = await storage.get("viewed");
      int skip = tourRecordStatus.skip ?? 0;
      int limit = tourRecordStatus.limit ?? 40;

      Map viewed = viewedData.value ?? {};
      List<TourRecordPlayerBaseData>? viewedWidgets = [];

      setState(() {
        tourRecordStatus.list!.clear();
        tourRecordStatus.load = true;
      });

      List dbIds = [];
      int start = (skip - 1) * limit;
      int end = (skip * limit) <= viewed.length ? skip * limit : viewed.length;
      viewed.entries.toList().sort((a, b) => a.value > b.value ? 1 : -1);
      dbIds = viewed.entries.toList().sublist(start, end).map((e) => e.key).toList();

      Response result = await Http.request(
        Config.httpHost["player_batch"],
        parame: {"dbIds": dbIds},
        method: Http.GET,
      );

      dynamic d = result.data;

      if (result.data["success"] == 1) {
        for (var playerItem in d["data"] as List) {
          TourRecordPlayerBaseData tourRecordPlayerBaseData = TourRecordPlayerBaseData();
          tourRecordPlayerBaseData.setData(playerItem);
          viewedWidgets.add(tourRecordPlayerBaseData);
        }
      }

      setState(() {
        tourRecordStatus.list = viewedWidgets;
        tourRecordStatus.load = false;
      });

      _refreshKey.currentState!.controller.finishLoad(IndicatorResult.success);
    } catch (err) {
      setState(() {
        tourRecordStatus.load = false;
      });
    }
  }

  /// [Event]
  /// 下拉刷新方法,为list重新赋值
  Future _onRefresh() async {
    tourRecordStatus.resetPage();

    await _getTourRecordList();

    _refreshKey.currentState!.controller.finishRefresh();
    _refreshKey.currentState!.controller.resetFooter();
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
            onPressed: () {
              setState(() {
                isEdit = !isEdit;
              });
            },
            icon: !isEdit ? const Icon(Icons.edit) : Text(FlutterI18n.translate(context, "basic.button.cancel")),
          ),
          IconButton(
            onPressed: () {
              _getTourRecordList();
            },
            icon: const Icon(Icons.rotate_right),
          ),
        ],
      ),
      body: Consumer<UserInfoProvider>(
        builder: (context, data, child) {
          return Refresh(
            key: _refreshKey,
            onRefresh: _onRefresh,
            child: Column(
              children: [
                /// toolbar
                if (isEdit)
                  Container(
                    padding: const EdgeInsets.only(top: 5, bottom: 5, right: 15),
                    color: Theme.of(context).appBarTheme.backgroundColor!.withOpacity(.5),
                    height: 35,
                    child: Row(
                      children: [
                        Checkbox(
                          value: selectAll,
                          onChanged: (status) => _selectAllItem(status!),
                        ),
                        TextButton(
                          onPressed: () => _selectDeleteItem(),
                          child: const Icon(Icons.delete, size: 15),
                        ),
                      ],
                    ),
                  ),

                /// Content List
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

                      if (tourRecordStatus.load!)
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
