/// 搜索

import 'dart:convert';

import 'package:bfban/data/index.dart';
import 'package:flutter/material.dart';

import 'package:bfban/constants/api.dart';
import 'package:bfban/utils/index.dart';
import 'package:bfban/widgets/index.dart';

import 'package:flutter_elui_plugin/_tag/tag.dart';
import 'package:flutter_elui_plugin/_vacancy/index.dart';

class SearchPage extends StatefulWidget {
  final data;

  const SearchPage({
    Key? key,
    this.data,
  }) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with RestorationMixin {
  final UrlUtil _urlUtil = UrlUtil();

  // 搜索框控制器
  final TextEditingController _searchController = TextEditingController();

  // 搜索类型
  List searchScope = ['current', 'history'];

  // 搜索参
  SearchStatus searchStatus = SearchStatus(
    load: false,
    historyList: [],
    list: [],
    parame: SearchParame(
      value: "",
      scope: "",
    ),
  );

  final isSelected = [RestorableBool(true), RestorableBool(false)];

  @override
  String? get restorationId => "searchScop";

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(isSelected[0], "0");
    registerForRestoration(isSelected[1], "1");
  }

  @override
  void initState() {
    super.initState();

    searchStatus.parame!.scope = searchScope[0];

    _onReady();
  }

  @override
  void dispose() {
    for (final res in isSelected) {
      res.dispose();
    }
    super.dispose();
  }

  /// [Event]
  /// 初始化
  void _onReady() async {
    List log = jsonDecode(await Storage().get("com.bfban.serachlog") ?? '[]');

    log.sort();

    setState(() {
      /// 序列化
      searchStatus.parame?.value = jsonDecode(widget.data)["id"];

      searchStatus.historyList = log;
    });
  }

  /// [Response]
  /// 账户搜索
  void _onSearch() async {
    if (searchStatus.parame!.value == "") {
      return;
    }

    Response result = await Http.request(
      Config.httpHost["search"],
      method: Http.GET,
      parame: searchStatus.parame!.toMap,
    );

    if (result.data["success"] == 1) {
      setState(() {
        searchStatus.list = result.data["data"];

        _setSearchLog();
      });
    }
  }

  /// [Event]
  /// 打开详情
  void _onPenDetail(Map item) {
    _urlUtil.opEnPage(context, "/detail/player/${item["originPersonaId"]}");
  }

  /// [Event]
  /// 储存历史
  void _setSearchLog() {
    List? list = searchStatus.historyList;

    bool isList = false;

    for (var value in list!) {
      if (value == searchStatus.parame!.value) {
        isList = true;
      }
    }

    if (!isList) {
      if (list.length >= 20) {
        list.removeAt(0);
      }
      list.add(searchStatus.parame!.value);
      Storage().set("com.bfban.serachlog", value: jsonEncode(list));
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

    Storage().set("com.bfban.serachlog", value: jsonEncode(list));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: SizedBox(
          height: 35,
          child: ToggleButtons(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: const Text("现在"),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: const Text("过去"),
              ),
            ],
            isSelected: isSelected.map((e) => e.value).toList(),
            onPressed: (int index) {
              setState(() {
                int forindex = 0;

                for (var i in isSelected) {
                  i.value = index == forindex;
                  forindex++;
                }

                searchStatus.parame!.scope = searchScope[index];
              });
            },
          ),
        ),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: titleSearch(
                        controller: _searchController,
                        theme: titleSearchTheme.white,
                        onChanged: (String value) {
                          searchStatus.parame!.value = value;
                        },
                        onSubmitted: () => _onSearch(),
                      ),
                    ),
                    Container(
                      height: 40,
                      margin: EdgeInsets.only(left: 10),
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Theme.of(context).appBarTheme.backgroundColor),
                        ),
                        onPressed: () => _onSearch(),
                        child: const Icon(
                          Icons.subdirectory_arrow_left,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Offstage(
                  offstage: searchStatus.historyList!.isEmpty,
                  child: Column(
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
                              Text(
                                "搜索历史",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white54,
                                ),
                              )
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
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              top: 20,
            ),
            child: searchStatus.list!.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: searchStatus.list!.map((i) {
                      return CheatListCard(
                        item: i,
                        onTap: () => _onPenDetail(i),
                      );
                    }).toList(),
                  )
                : EluiVacancyComponent(
                    height: 300,
                    title: "没有检索到结果",
                  ),
          ),
        ],
      ),
    );
  }
}
