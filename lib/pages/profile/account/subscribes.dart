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
import '/widgets/hint_login.dart';
import '/widgets/index.dart';

class UserSubscribesPage extends StatefulWidget {
  const UserSubscribesPage({Key? key}) : super(key: key);

  @override
  State<UserSubscribesPage> createState() => _UserSubscribesPageState();
}

class _UserSubscribesPageState extends State<UserSubscribesPage> {
  // 列表
  final GlobalKey<RefreshState> _refreshKey = GlobalKey<RefreshState>();

  // 列表视图控制器
  final ScrollController _scrollController = ScrollController();

  TraceStatus traceStatus = TraceStatus(
    load: false,
    list: [],
    parame: TraceParame(
      limit: 10,
      skip: 0,
    ),
  );

  StoragePlayer storagePlayer = StoragePlayer();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _getSubscribesList();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _getMore();
      }
    });

    super.initState();
  }

  /// [Response]
  /// 获取订阅列表
  Future _getSubscribesList() async {
    if (traceStatus.load == true) return;

    setState(() {
      traceStatus.load = true;
    });

    Response result = await HttpToken.request(
      Config.httpHost["user_subscribes"],
      data: traceStatus.parame.toMap,
      method: Http.POST,
    );

    dynamic d = result.data;

    if (result.data["success"] == 1) {
      setState(() {
        traceStatus.list = d["data"] ?? [];
        traceStatus.load = false;
      });

      _refreshKey.currentState?.controller.finishLoad(IndicatorResult.success);
      return;
    }

    setState(() {
      traceStatus.load = false;
    });
  }

  /// [Event]
  /// 下拉刷新方法,为list重新赋值
  Future _onRefresh() async {
    traceStatus.parame.resetPage();

    await _getSubscribesList();

    _refreshKey.currentState!.controller.finishRefresh();
    _refreshKey.currentState!.controller.resetFooter();
  }

  /// [Event]
  /// 下拉 追加数据
  Future _getMore() async {
    if (traceStatus.load!) return;

    traceStatus.parame.nextPage();
    await _getSubscribesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "app.setting.cell.subscribes.title")),
      ),
      body: Consumer<UserInfoProvider>(
        builder: (context, data, child) {
          if (data.userinfo.isEmpty) return const Center(child: HintLoginWidget());

          if (traceStatus.list!.isEmpty) return const EmptyWidget();

          return Refresh(
            key: _refreshKey,
            onRefresh: _onRefresh,
            child: Scrollbar(
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
            ),
          );
        },
      ),
    );
  }
}
