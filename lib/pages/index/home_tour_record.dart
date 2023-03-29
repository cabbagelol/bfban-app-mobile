import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/index.dart';
import '../../provider/userinfo_provider.dart';
import '../../router/router.dart';
import '../../utils/index.dart';
import '../../widgets/detail/home_hint_login.dart';
import '../../widgets/index/cheat_list_card.dart';
import '../../component/_empty/index.dart';

class HomeTourRecordPage extends StatefulWidget {
  const HomeTourRecordPage({Key? key}) : super(key: key);

  @override
  State<HomeTourRecordPage> createState() => _HomeTourRecordPageState();
}

class _HomeTourRecordPageState extends State<HomeTourRecordPage> with AutomaticKeepAliveClientMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  // 列表视图控制器
  final ScrollController _scrollController = ScrollController();

  TourRecordStatus tourRecordStatus = TourRecordStatus(
    load: false,
    list: [],
  );

  Storage storage = Storage();

  StoragePlayer storagePlayer = StoragePlayer();

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    _getTourRecordList();

    super.initState();
  }

  /// [Result]
  /// 获取游览历史
  Future _getTourRecordList() async {
    Map viewed = jsonDecode(await storage.get("viewed")) ?? {};
    List<TourRecordPlayerBaseData>? viewedWidgets = [];

    viewed.forEach((key, value) async {
      Map playerData = await storagePlayer.query(key);
      TourRecordPlayerBaseData tourRecordPlayerBaseData = TourRecordPlayerBaseData();
      tourRecordPlayerBaseData.setData(playerData);
      viewedWidgets.add(tourRecordPlayerBaseData);

      setState(() {
        tourRecordStatus.list = viewedWidgets;
      });
    });

    setState(() {
      tourRecordStatus.load = false;
    });
  }

  /// [Event]
  /// 下拉刷新方法,为list重新赋值
  Future _onRefresh() async {
    await _getTourRecordList();
  }

  /// [Event]
  /// 下拉 追加数据
  Future _getMore() async {
    await _getTourRecordList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserInfoProvider>(builder: (context, data, child) {
      return data.userinfo.isEmpty
          ? const HomeHintLogin()
          : RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _onRefresh,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: tourRecordStatus.list!.length,
                itemBuilder: (BuildContext context, int index) {
                  if (tourRecordStatus.list!.isEmpty) {
                    return const EmptyWidget();
                  }

                  return CheatListCard(
                    item: tourRecordStatus.list![index].toMap,
                  );
                },
              ),
            );
    });
  }
}
