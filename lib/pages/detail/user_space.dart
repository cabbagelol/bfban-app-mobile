/// 空间
/// 站内用户空间

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'package:bfban/constants/api.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../../data/index.dart';
import '../../utils/index.dart';

class UserSpacePage extends StatefulWidget {
  // 站内用户id
  late String? id;

  UserSpacePage({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  UserSpacePageState createState() => UserSpacePageState();
}

class UserSpacePageState extends State<UserSpacePage> {
  final UrlUtil _urlUtil = UrlUtil();

  /// 异步
  Future? futureBuilder;

  /// 用户信息
  UserInfoStatuc userinfo = UserInfoStatuc(
    data: {
      "username": "username",
      "introduction": "",
    },
    parame: UserInfoParame(
      id: "",
      skip: 0,
      limit: 20,
    ),
    load: false,
  );

  /// 用户举报列表
  ReportListStatuc reportListStatuc = ReportListStatuc(
    load: false,
    list: [],
    param: ReportListParam(
      id: "",
      limit: 0,
      skip: 0,
    ),
  );

  @override
  void initState() {
    super.initState();

    ready();
  }

  void ready() async {
    // 更新ID
    userinfo.parame!.setId = widget.id;

    futureBuilder = _getUserInfo();
    await _getReports();
  }

  get getReports => _getReports;

  /// [Response]
  /// 获取用户数据
  Future _getUserInfo() async {
    print("id:" + userinfo.parame.toString());

    setState(() {
      userinfo.load = true;
    });

    Response result = await Http.request(
      Config.httpHost["user_info"],
      parame: userinfo.parame!.toMap,
      method: Http.GET,
    );

    print("result:" + result.toString());

    if (result.data["success"] == 1) {
      final d = result.data["data"];

      setState(() {
        userinfo.data = d;
      });
    }

    setState(() {
      userinfo.load = false;
    });

    return userinfo.data;
  }

  /// [Response]
  /// 获取用户举报列表
  Future _getReports() async {
    setState(() {
      userinfo.load = true;
    });

    Response result = await Http.request(
      Config.httpHost["user_reports"],
      parame: userinfo.parame!.toMap,
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      final d = result.data["data"];

      setState(() {
        reportListStatuc.list = d;
      });
    }

    setState(() {
      userinfo.load = false;
    });

    return userinfo.data;
  }

  /// [Event]
  /// 作弊玩家信息 刷新
  Future<void> _onRefresh() async {
    await _getReports();
  }

  /// [Event]
  /// 聊天
  _openMessage(String id) {
    return () {
      _urlUtil.opEnPage(context, "/message/$id");
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureBuilder,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        /// 数据未加载完成时
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return Scaffold(
              appBar: AppBar(
                title: Text(translate("userspace.title")),
                centerTitle: true,
                actions: [
                  // PopupMenuButton(
                  //   onSelected: (value) {
                  //     switch (value) {
                  //       case 1:
                  //         break;
                  //       case 2:
                  //         break;
                  //     }
                  //   },
                  //   itemBuilder: (context) {
                  //     return [
                  //       PopupMenuItem(
                  //         value: 1,
                  //         child: Wrap(
                  //           children: const [
                  //             Icon(Icons.qr_code),
                  //             SizedBox(
                  //               width: 10,
                  //             ),
                  //             Text("分享"),
                  //           ],
                  //         ),
                  //       ),
                  //     ];
                  //   },
                  // ),
                ],
              ),
              body: RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    // 空间用户信息
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          CircleAvatar(
                            radius: 35,
                            child: Text(
                              snapshot.data["username"][0].toString().toUpperCase(),
                              style: const TextStyle(fontSize: 25),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                snapshot.data["username"],
                                style: const TextStyle(fontSize: 20),
                              ),
                              SizedBox(width: 5),
                              IconButton(
                                onPressed: _openMessage(userinfo.data!["id"].toString()),
                                icon: const Icon(Icons.message),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // 自我描述
                          // Card(
                          //   child: Html(
                          //     style: {"*": Style(color: Theme.of(context).textTheme.subtitle2!.color, padding: EdgeInsets.zero)},
                          //     data: snapshot.data["introduction"].toString() == "" ? translate("userspace.introduction") : snapshot.data["introduction"].toString() ?? '',
                          //   ),
                          // ),
                        ],
                      ),
                    ),

                    // 统计信息
                    Container(
                      height: 100,
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          width: 1,
                          color: Theme.of(context).dividerTheme.color!.withOpacity(.1),
                        ),
                      ),
                      child: Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Wrap(
                                    children: snapshot.data["privilege"].map<Widget>((i) {
                                      return EluiTagComponent(
                                        color: EluiTagType.none,
                                        size: EluiTagSize.no2,
                                        theme: EluiTagTheme(
                                          backgroundColor: Theme.of(context).appBarTheme.color!.withOpacity(.2),
                                        ),
                                        value: translate("basic.privilege.${i}").toString(),
                                      );
                                    }).toList(),
                                  ),
                                  Text(
                                    translate("userspace.row.privilege"),
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                height: 30,
                                width: 1,
                                color: Theme.of(context).dividerTheme.color,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    Date().getFriendlyDescriptionTime(snapshot.data["joinTime"]).toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    translate("userspace.row.joinTime"),
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                height: 30,
                                width: 1,
                                color: Theme.of(context).dividerTheme.color,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    Date().getFriendlyDescriptionTime(snapshot.data["lastOnlineTime"]).toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    translate("userspace.row.lastOnlineTime"),
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                height: 30,
                                width: 1,
                                color: Theme.of(context).dividerTheme.color,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    reportListStatuc.list!.length.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    translate("userspace.row.reportCount"),
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 举报列表
                    Column(
                      children: reportListStatuc.list!.map((item) {
                        return RecordItemCard(item: item);
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          default:
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
        }
      },
    );
  }
}

/// 举报记录卡片
class RecordItemCard extends StatelessWidget {
  final UrlUtil _urlUtil = UrlUtil();

  final Map? item;

  RecordItemCard({
    Key? key,
    this.item,
  }) : super(key: key);

  /// [Event]
  /// 前往作弊玩家详情
  _openPlayerDetail(context) {
    _urlUtil.opEnPage(
      context,
      '/detail/player/${item!["originPersonaId"]}',
      transition: TransitionType.fadeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        item!["originName"],
        style: const TextStyle(
          fontSize: 20,
        ),
      ),
      subtitle: Row(
        children: <Widget>[
          Text(
            translate("basic.status.${item!["status"]}"),
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.subtitle2!.color,
            ),
          )
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _openPlayerDetail(context),
    );
  }
}
