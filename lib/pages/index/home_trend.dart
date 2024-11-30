import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../component/_empty/index.dart';
import '../../component/_refresh/index.dart';
import '../../constants/api.dart';
import '../../data/index.dart';
import '../../provider/userinfo_provider.dart';
import '../../utils/http.dart';
import '../../widgets/index/cheat_list_card.dart';

class HomeTrendPage extends StatefulWidget {
  const HomeTrendPage({super.key});

  @override
  State<HomeTrendPage> createState() => HomeTrendPageState();
}

class HomeTrendPageState extends State<HomeTrendPage> with AutomaticKeepAliveClientMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshState> _refreshKey = GlobalKey<RefreshState>();

  // 列表视图控制器
  final ScrollController _scrollController = ScrollController();

  TrendStatus trendStatus = TrendStatus(
    load: false,
    parame: TrendStatusParame(
      limit: 10,
      time: TrendStatusParameTime.yearly,
    ),
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    getTrendList();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _getMore();
      }
    });

    super.initState();
  }

  /// [Response]
  /// 获取趋势列表
  Future getTrendList() async {
    if (trendStatus.load == true) return;

    Future.delayed(const Duration(seconds: 0), () {
      if (trendStatus.parame.skip! <= 0 && _refreshIndicatorKey.currentState != null) _refreshIndicatorKey.currentState!.show();
    });

    setState(() {
      trendStatus.load = true;
    });

    Response result = await Http.request(
      Config.httpHost["trend"],
      parame: trendStatus.parame.toMap,
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      setState(() {
        trendStatus.clear().list = result.data["data"];
        trendStatus.load = false;
      });
      return;
    }

    setState(() {
      trendStatus.load = false;
    });
  }

  /// [Event]
  /// 下拉刷新方法,为list重新赋值
  Future _onRefresh() async {
    trendStatus.parame.resetPage();

    await getTrendList();

    _refreshKey.currentState?.controller.finishRefresh();
    _refreshKey.currentState?.controller.resetFooter();
  }

  /// [Event]
  /// 下拉 追加数据
  Future _getMore() async {
    if (trendStatus.load!) return;

    trendStatus.parame.nextPage();
    await getTrendList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<UserInfoProvider>(
      builder: (context, data, child) {
        return Refresh(
          key: _refreshKey,
          onRefresh: _onRefresh,
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: Scrollbar(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: trendStatus.list.length,
                itemBuilder: (BuildContext context, int index) {
                  if (trendStatus.list.isEmpty) {
                    return const EmptyWidget();
                  }

                  return CheatListCard(
                    item: trendStatus.list[index].toMap,
                    isIconHotView: true,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
