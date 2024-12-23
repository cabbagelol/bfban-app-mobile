/// 搜索
library;

import 'dart:convert';

import 'package:bfban/component/_loading/index.dart';
import 'package:bfban/data/Games.dart';
import 'package:bfban/data/index.dart';
import 'package:flutter/material.dart';

import 'package:bfban/constants/api.dart';
import 'package:bfban/utils/index.dart';
import 'package:bfban/widgets/index.dart';

import 'package:flutter_elui_plugin/_message/index.dart';
import 'package:flutter_elui_plugin/_tag/tag.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../component/_empty/index.dart';
import '../../widgets/index/search_in_user.dart';
import '../../widgets/search/filter/index.dart';

class SearchPage extends StatefulWidget {
  final dynamic data;

  const SearchPage({
    super.key,
    this.data,
  });

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final UrlUtil _urlUtil = UrlUtil();

  final Storage _storage = Storage();

  // 搜索框控制器
  final TextEditingController _searchController = TextEditingController();

  late TabController tabController;

  Future? request;

  bool isFirstScreen = true;

  bool isHotRecommendationLoad = true;

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

  List<Map> searchTabsType = [
    {"value": "player", "icon": Icons.people},
    {"value": "user", "icon": Icons.person},
  ];

  List searchTabs = [];

  List searchTrends = [];

  int searchTabsIndex = 0;

  final GlobalKey<TitleSearchState> _titleSearchWidgetKey = GlobalKey<TitleSearchState>();

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
        "text": FlutterI18n.translate(context, "search.tabs.${i["value"]}"),
        "icon": Icon(i["icon"]),
      });
    }

    tabController = TabController(vsync: this, length: searchTabs.length, initialIndex: 0)
      ..addListener(() {
        _onToggleSearchType(tabController.index);
      });

    super.didChangeDependencies();
  }

  /// [Event]
  /// 初始化
  void _onReady() async {
    StorageData searchHistoryData = await _storage.get("search.history");
    List history = searchHistoryData.value ?? [];
    Map param = jsonDecode(widget.data);

    _getTrend();

    setState(() {
      /// 序列化
      searchStatus.params.param = param["text"];
      searchStatus.historyList = history;

      /// 如果初始页面包含内容则直接搜索
      _onPenByType({"type": param["type"], "keyword": param["text"] ?? "player"});
    });
  }

  /// [Event]
  /// 切换搜索方式，Tabs
  void _onToggleSearchType(index) {
    setState(() {
      searchTabsIndex = index;
    });

    if (searchStatus.load && searchStatus.params.param.toString().isEmpty) {
      return;
    }

    setState(() {
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
    });
  }

  /// [Response]
  /// 账户搜索
  void _onSearch({isButtonClick = true}) async {
    try {
      _titleSearchWidgetKey.currentState?.unFocus();

      if (searchStatus.load && !isButtonClick) return;
      if (searchStatus.params.param.isEmpty || searchStatus.params.param.length < 3) return;

      setState(() {
        searchStatus.load = true;
      });

      request = Http.request(
        Config.httpHost["search"],
        method: Http.GET,
        parame: searchStatus.params.toMap,
      );
      Response result = await request;

      if (result.data["success"] == 1) {
        if (!mounted) return;
        setState(() {
          searchStatus.list.set(searchTabsType[searchTabsIndex]["value"], result.data["data"]);
          searchStatus.load = false;
          isFirstScreen = false;

          _setSearchHistory();
        });
        return;
      }
    } catch (e) {
      EluiMessageComponent.error(context)(
        child: Text(FlutterI18n.translate(context, "$e")),
      );
    } finally {
      setState(() {
        searchStatus.load = false;
        isFirstScreen = false;
      });
    }
  }

  /// [Response]
  /// 获取热门案件
  Future _getTrend() async {
    setState(() {
      isHotRecommendationLoad = true;
    });

    Response result = await Http.request(
      Config.httpHost["trend"],
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      if (!mounted) return;
      setState(() {
        searchTrends = result.data["data"];
      });
    }

    setState(() {
      isHotRecommendationLoad = false;
    });
  }

  /// [Event]
  /// 前往案件详情
  void _onPenPlayerDetail(Map item) {
    _urlUtil.opEnPage(context, "/player/personaId/${item["originPersonaId"]}");
  }

  /// [Event]
  /// 前往站内用户
  void _onPenInUserDetail(Map item) {
    _urlUtil.opEnPage(context, '/account/${item["dbId"]}');
  }

  /// [Event]
  /// 依照类型
  void _onPenByType(Map item) {
    setState(() {
      switch (item["type"]) {
        case "user":
          searchTabsIndex = 1;
          break;
        case "player":
        default:
          searchTabsIndex = 0;
          break;
      }
      searchStatus.params.param = item["keyword"];
      _searchController.text = searchStatus.params.param;
      tabController.index = searchTabsIndex;
    });
    if (searchStatus.params.param.isNotEmpty) _onSearch();
  }

  /// [Event]
  /// 储存历史
  void _setSearchHistory() {
    List? list = searchStatus.historyList;

    bool isIncluded = false;

    for (var value in list!) {
      if (value["keyword"] == searchStatus.params.param && value["type"] == searchTabsType[searchTabsIndex]["value"]) {
        isIncluded = true;
        continue;
      }
    }

    if (isIncluded) return;
    if (list.length >= 20) list.removeAt(0);
    list.add({
      "keyword": searchStatus.params.param,
      "type": searchTabsType[searchTabsIndex]["value"],
      "count": searchStatus.list.data(searchTabsType[searchTabsIndex]["value"]).length,
    });
    _storage.set("search.history", value: list);
  }

  /// [Event]
  /// 删除历史
  void _deleteSearchLog(Map value) {
    List? list = searchStatus.historyList;
    list?.removeAt(list.indexOf(value));

    setState(() {
      searchStatus.historyList = list;
    });

    _storage.set("search.history", value: list);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: searchTabs.length,
      child: Scaffold(
        appBar: AppBar(
          actionsIconTheme: Theme.of(context).appBarTheme.iconTheme,
          titleSpacing: 5,
          centerTitle: true,
          title: Container(
            margin: const EdgeInsets.only(left: 5),
            child: SearchAppBarWidget(
              key: _titleSearchWidgetKey,
              controller: _searchController,
              theme: TitleSearchTheme.white,
              laterInterChild: _searchController.text.isNotEmpty
                  ? SearchFilterPanel(
                      onChange: (Map value) {
                        if (value.isEmpty) return;

                        SearchPlayerParams d = searchStatus.params as SearchPlayerParams;
                        d.gameSort = value["sort"];

                        _onSearch(isButtonClick: false);
                      },
                    )
                  : null,
              onChanged: (String value) {
                setState(() {
                  searchStatus.params.param = value;
                });
              },
              onSubmitted: (dynamic data) => _onSearch(isButtonClick: true),
            ),
          ),
          actions: [
            IconButton(
              padding: const EdgeInsets.all(16),
              style: ButtonStyle(shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))), backgroundColor: WidgetStateProperty.all(Theme.of(context).appBarTheme.backgroundColor)),
              highlightColor: searchStatus.load ? Colors.transparent : Theme.of(context).highlightColor,
              onPressed: () => _onSearch(),
              icon: AnimatedSwitcher(
                transitionBuilder: (child, anim) {
                  return ScaleTransition(scale: anim, child: child);
                },
                duration: const Duration(milliseconds: 300),
                child: searchStatus.load
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: LoadingWidget(
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        Icons.search,
                        color: Theme.of(context).appBarTheme.iconTheme?.color as Color,
                      ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              color: Theme.of(context).appBarTheme.backgroundColor,
              child: TabBar(
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
            const Divider(height: 1),
            Expanded(
              flex: 1,
              child: Scrollbar(
                child: isFirstScreen
                    ? ListView(
                        padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                        children: <Widget>[
                          const SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Wrap(
                                    spacing: 10,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: <Widget>[
                                      const Icon(Icons.history),
                                      I18nText("app.search.historySearch", child: const Text("", style: TextStyle())),
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
                              searchStatus.historyList!.isNotEmpty
                                  ? Wrap(
                                      spacing: 10,
                                      runSpacing: 5,
                                      children: searchStatus.historyList!.map((i) {
                                        return InputChip(
                                          label: GestureDetector(
                                            child: Wrap(
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              children: [
                                                Text("${FlutterI18n.translate(context, "search.tabs.${i['type']}")}:\t"),
                                                Text(i["keyword"]),
                                              ],
                                            ),
                                            onTap: () => _onPenByType(i),
                                          ),
                                          onDeleted: () => _deleteSearchLog(i),
                                        );
                                      }).toList(),
                                    )
                                  : const EmptyWidget(),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Wrap(
                                spacing: 10,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: <Widget>[
                                  const Icon(Icons.local_fire_department_rounded),
                                  I18nText("app.search.hotRecommendation", child: const Text("", style: TextStyle())),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (isHotRecommendationLoad)
                                Center(
                                  child: LoadingWidget(
                                    color: Theme.of(context).progressIndicatorTheme.color!,
                                    size: 20,
                                  ),
                                )
                              else
                                searchTrends.isNotEmpty
                                    ? Wrap(
                                        spacing: 10,
                                        runSpacing: 10,
                                        children: searchTrends.map((i) {
                                          return InputChip(
                                            label: Wrap(
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.person,
                                                  size: 16,
                                                  color: Theme.of(context).chipTheme.iconTheme!.color,
                                                ),
                                                Text(i["originName"]),
                                                const SizedBox(width: 5),
                                                Icon(
                                                  Icons.local_fire_department_outlined,
                                                  size: 16,
                                                  color: Theme.of(context).chipTheme.iconTheme!.color,
                                                ),
                                                Text(i["hot"].toString()),
                                              ],
                                            ),
                                            onSelected: (select) {
                                              _onPenPlayerDetail(i);
                                            },
                                          );
                                        }).toList(),
                                      )
                                    : const EmptyWidget(),
                            ],
                          ),
                        ],
                      )
                    : TabBarView(
                        controller: tabController,
                        physics: const NeverScrollableScrollPhysics(),
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
                                          );
                                        }).toList(),
                                      )
                                    : const EmptyWidget(),
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
                                            onTap: () {
                                              _onPenInUserDetail(i);
                                            },
                                          );
                                        }).toList(),
                                      )
                                    : const EmptyWidget(),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchHotContentWidget extends StatelessWidget {
  const SearchHotContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
