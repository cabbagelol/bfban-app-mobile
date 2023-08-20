/// 追踪

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../component/_empty/index.dart';
import '../../constants/api.dart';
import '../../data/index.dart';
import '../../provider/userinfo_provider.dart';
import '../../utils/index.dart';
import '../../widgets/detail/home_hint_login.dart';
import '../../widgets/index/cheat_list_card.dart';

class HomeTracePage extends StatefulWidget {
  const HomeTracePage({Key? key}) : super(key: key);

  @override
  State<HomeTracePage> createState() => HomeTracePageState();
}

class HomeTracePageState extends State<HomeTracePage> with AutomaticKeepAliveClientMixin {

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  // 列表视图控制器
  final ScrollController _scrollController = ScrollController();

  TraceStatus traceStatus = TraceStatus(
      load: false,
      list: [],
      parame: TraceParame(
        limit: 10,
        skip: 0,
      ));

  StoragePlayer storagePlayer = StoragePlayer();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    getTraceList();

    super.initState();
  }

  /// [Response]
  /// 获取追踪
  Future getTraceList() async {
    if (traceStatus.load == true) return;

    setState(() {
      traceStatus.load = true;
    });

    Response result = await Http.request(
      Config.httpHost["user_me"],
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      List subscribes = result.data["data"]["subscribes"] ?? [];
      List subscribesToWidgets = [];

      for (var i in subscribes) {
        Map playerData = await storagePlayer.query(i);
        subscribesToWidgets.add(playerData);
      }

      setState(() {
        traceStatus.list = subscribesToWidgets;
        traceStatus.load = false;
      });
      return;
    }

    setState(() {
      traceStatus.load = false;
    });
  }

  /// [Event]
  /// 下拉刷新方法,为list重新赋值
  Future _onRefresh() async {
    await getTraceList();
  }

  /// [Event]
  /// 下拉 追加数据
  Future _getMore() async {
    await getTraceList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<UserInfoProvider>(
      builder: (context, data, child) {
        return data.userinfo.isEmpty
            ? const HomeHintLogin()
            : traceStatus.list!.isNotEmpty ? RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _onRefresh,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: traceStatus.list!.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (traceStatus.list!.isEmpty) {
                      return const EmptyWidget();
                    }

                    return CheatListCard(
                      item: traceStatus.list![index],
                    );
                  },
                ),
              ) : const EmptyWidget();
      },
    );
  }
}
