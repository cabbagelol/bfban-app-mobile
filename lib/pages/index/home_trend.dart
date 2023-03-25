import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '../../component/_empty/index.dart';
import '../../constants/api.dart';
import '../../data/index.dart';
import '../../provider/userinfo_provider.dart';
import '../../router/router.dart';
import '../../utils/http.dart';
import '../../widgets/detail/home_hint_login.dart';
import '../../widgets/index/cheat_list_card.dart';

class HomeTrendPage extends StatefulWidget {
  HomeTrendPage({Key? key}) : super(key: key);

  @override
  State<HomeTrendPage> createState() => HomeTrendPageState();
}

class HomeTrendPageState extends State<HomeTrendPage> with AutomaticKeepAliveClientMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

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

    super.initState();
  }

  /// [Response]
  /// 获取追踪
  Future getTrendList() async {
    if (trendStatus.load == true) return;

    setState(() {
      Future.delayed(const Duration(seconds: 0), () {
        _refreshIndicatorKey.currentState!.show();
      });
      trendStatus.load = true;
    });

    Response result = await Http.request(
      Config.httpHost["trend"],
      parame: trendStatus.parame!.toMap,
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      setState(() {
        trendStatus.list = result.data["data"];
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
    await getTrendList();
  }

  /// [Event]
  /// 下拉 追加数据
  Future _getMore() async {
    await getTrendList();
  }

  /// [Event]
  /// 前往案件详情
  void _opEnPlayerDetail(int index) {
    Routes.router!.navigateTo(
      context,
      '/detail/player/${trendStatus.list[index].originPersonaId}',
    );
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
                itemCount: trendStatus.list.length,
                itemBuilder: (BuildContext context, int index) {
                  if (trendStatus.list!.isEmpty) {
                    return const EmptyWidget();
                  }

                  return CheatListCard(
                    item: trendStatus.list[index].toMap,
                    isIconHotView: true,
                    onTap: () {
                      _opEnPlayerDetail(index);
                    },
                  );
                },
              ),
            );
    });
  }
}
