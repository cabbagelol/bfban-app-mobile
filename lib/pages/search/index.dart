/// 搜索

import 'dart:convert';

import 'package:bfban/data/Games.dart';
import 'package:bfban/data/index.dart';
import 'package:bfban/widgets/index/search_comment.dart';
import 'package:flutter/material.dart';

import 'package:bfban/constants/api.dart';
import 'package:bfban/utils/index.dart';
import 'package:bfban/widgets/index.dart';
import 'package:flutter_elui_plugin/_load/index.dart';

import 'package:flutter_elui_plugin/_message/index.dart';
import 'package:flutter_elui_plugin/_tag/tag.dart';
import 'package:flutter_elui_plugin/_vacancy/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../widgets/index/search_in_user.dart';

class SearchPage extends StatefulWidget {
  final dynamic data;

  const SearchPage({
    Key? key,
    this.data,
  }) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final UrlUtil _urlUtil = UrlUtil();

  // 搜索框控制器
  final TextEditingController _searchController = TextEditingController();

  late TabController tabController;

  bool isFirstScreen = true;

  // 搜索参
  SearchStatus searchStatus = SearchStatus(
    load: false,
    historyList: [],
    list: SearchResultData(
      player: [],
      user: [],
      comment: [],
    ),
    params: SearchPlayerParams(
      param: "",
      game: GameType.all,
      limit: 40,
      skip: 0,
    ),
  );

  List<dynamic> searchTabsType = [
    {"text": "player", "icon": Icons.people},
    {"text": "user", "icon": Icons.person},
    {"text": "comment", "icon": Icons.comment},
  ];

  List searchTabs = [];

  int searchTabsIndex = 0;

  final GlobalKey<searchState> _titleSearchWidgetKey = GlobalKey<searchState>();

  late titleSearch titleSearchWidget;

  @override
  void initState() {
    super.initState();

    _onReady();
  }

  @override
  void didChangeDependencies() {
    searchTabs = [];
    for (var i in searchTabsType) {
      searchTabs.add({
        "text": FlutterI18n.translate(context, "search.tabs." + i["text"]),
        "icon": Icon(i["icon"]),
      });
    }

    tabController = TabController(vsync: this, length: searchTabs.length, initialIndex: 0)..addListener(() => _onToggleSearchType(tabController.index));

    super.didChangeDependencies();
  }

  /// [Event]
  /// 初始化
  void _onReady() async {
    List log = jsonDecode(await Storage().get("com.bfban.history") ?? '[]');

    log.sort();

    setState(() {
      /// 序列化
      searchStatus.params.param = jsonDecode(widget.data)["id"];

      searchStatus.historyList = log;
    });
  }

  /// [Event]
  /// 切换搜索方式，Tabs
  void _onToggleSearchType(index) {
    if (searchStatus.params.param.toString().isEmpty) {
      return;
    }

    setState(() {
      searchTabsIndex = index;
    });

    switch (index) {
      case 0:
        searchStatus.params = SearchPlayerParams(
          param: searchStatus.params.param,
          game: GameType.all,
          limit: 40,
          skip: 0,
          createTimeTo: null,
          createTimeFrom: null,
        );
        break;
      case 1:
        searchStatus.params = SearchInStationUser(
          param: searchStatus.params.param,
          gameSort: UserSortType.byDefault,
          limit: 40,
          skip: 0,
          createTimeTo: null,
          createTimeFrom: null,
        );
        break;
      case 2:
      default:
        searchStatus.params = SearchCommentParams(
          param: searchStatus.params.param,
          limit: 40,
          skip: 0,
          createTimeTo: null,
          createTimeFrom: null,
        );
        break;
    }

    _onSearch(isButtonClick: false);
  }

  /// [Response]
  /// 账户搜索
  void _onSearch({isButtonClick = true}) async {
    if (searchStatus.load) return;
    if (isButtonClick && searchStatus.params.param.toString().isEmpty) {
      // TODO add i18n
      EluiMessageComponent.error(context)(
        child: Text(FlutterI18n.translate(context, "请检测内容")),
      );
      return;
    }

    setState(() {
      searchStatus.load = true;
      _titleSearchWidgetKey.currentState?.unFocus();
    });

    print(searchStatus.params.toMap);
    Response result = await Http.request(
      Config.httpHost["search"],
      method: Http.GET,
      parame: searchStatus.params.toMap,
    );

    if (result.data["success"] == 1) {
      setState(() {
        searchStatus.list.set(searchTabsType[searchTabsIndex]["text"], result.data["data"]);
        searchStatus.load = false;
        isFirstScreen = false;

        _setSearchLog();
      });
      return;
    }

    setState(() {
      searchStatus.load = false;
      isFirstScreen = false;
    });

    // TODO add i18n
    EluiMessageComponent.error(context)(
      child: Text(FlutterI18n.translate(context, result.toString())),
    );
  }

  /// [Event]
  /// 前往案件详情
  void _onPenDetail(Map item) {
    _urlUtil.opEnPage(context, "/detail/player/${item["originPersonaId"]}");
  }

  /// [Event]
  /// 前往站内用户
  void _onPenInUserDetail(Map item) {
    _urlUtil.opEnPage(context, "/detail/player/${item["originPersonaId"]}");
  }

  /// [Event]
  /// 储存历史
  void _setSearchLog() {
    List? list = searchStatus.historyList;

    bool isList = false;

    for (var value in list!) {
      if (value == searchStatus.params.param) {
        isList = true;
      }
    }

    if (!isList) {
      if (list.length >= 20) {
        list.removeAt(0);
      }
      list.add(searchStatus.params.param);
      Storage().set("com.bfban.history", value: jsonEncode(list));
    }
  }

  /// [Event]
  /// 删除历史
  void _deleSearchLog(String value) {
    List? list = searchStatus.historyList;

    list?.remove(value);

    setState(() {
      searchStatus.historyList = list;
    });

    Storage().set("com.bfban.history", value: jsonEncode(list));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: searchTabs.length,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 1,
                child: titleSearch(
                  key: _titleSearchWidgetKey,
                  controller: _searchController,
                  theme: titleSearchTheme.white,
                  onChanged: (String value) {
                    setState(() {
                      searchStatus.params.param = value;
                    });
                  },
                  onSubmitted: () => _onSearch(isButtonClick: true),
                ),
              ),
              Container(
                height: 40,
                margin: const EdgeInsets.only(left: 5),
                child: TextButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                    backgroundColor: MaterialStateProperty.all(Theme.of(context).appBarTheme.backgroundColor),
                  ),
                  onPressed: () => _onSearch(),
                  child: AnimatedSwitcher(
                    transitionBuilder: (child, anim) {
                      return ScaleTransition(scale: anim, child: child);
                    },
                    duration: const Duration(milliseconds: 300),
                    child: searchStatus.load
                        ? ELuiLoadComponent(
                            type: "line",
                            color: Theme.of(context).textTheme.subtitle1!.color!,
                            size: 20,
                            lineWidth: 2,
                          )
                        : Icon(Icons.search),
                  ),
                ),
              ),
            ],
          ),
          bottom: TabBar(
            automaticIndicatorColorAdjustment: true,
            controller: tabController,
            tabs: searchTabs.map((e) {
              return Tab(
                icon: e["icon"],
                text: e["text"],
                iconMargin: EdgeInsets.zero,
              );
            }).toList(),
          ),
        ),
        body: isFirstScreen
            ? Padding(
                padding: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Wrap(
                              spacing: 5,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: const <Widget>[
                                Icon(
                                  Icons.history,
                                  size: 17,
                                ),
                              ],
                            ),
                            EluiTagComponent(
                              color: EluiTagType.none,
                              size: EluiTagSize.no2,
                              value: "${searchStatus.historyList!.length}/20",
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Wrap(
                          spacing: 10,
                          runSpacing: 5,
                          children: searchStatus.historyList!.map((value) {
                            return EluiTagComponent(
                              value: value,
                              isClose: true,
                              theme: EluiTagTheme(
                                textColor: Colors.white,
                              ),
                              onTap: () {
                                setState(() {
                                  _searchController.value = TextEditingValue(
                                    text: value,
                                  );

                                  _onSearch();
                                });
                              },
                              onClose: () => _deleSearchLog(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              )
            : TabBarView(
                controller: tabController,
                children: [
                  ListView(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: searchStatus.list.data("player").isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: searchStatus.list.data("player").map((i) {
                                  return CheatListCard(
                                    item: i,
                                    onTap: () => _onPenDetail(i),
                                  );
                                }).toList(),
                              )
                            : EluiVacancyComponent(
                                height: 200,
                                title: FlutterI18n.translate(context, "basic.tip.notContent"),
                              ),
                      ),
                    ],
                  ),
                  ListView(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: searchStatus.list.data("user").isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: searchStatus.list.data("user").map((i) {
                                  return SearchInUserCard(
                                    item: i,
                                    onTap: () => _onPenInUserDetail(i),
                                  );
                                }).toList(),
                              )
                            : EluiVacancyComponent(
                                height: 200,
                                title: FlutterI18n.translate(context, "basic.tip.notContent"),
                              ),
                      ),
                    ],
                  ),
                  ListView(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: searchStatus.list.data("comment").isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: searchStatus.list.data("comment").map((i) {
                                  return SearchCommentCard(
                                    item: i,
                                    onTap: () => _onPenInUserDetail(i),
                                  );
                                }).toList(),
                              )
                            : EluiVacancyComponent(
                                height: 200,
                                title: FlutterI18n.translate(context, "basic.tip.notContent"),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
