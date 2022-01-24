class SearchStatus {
  late bool? load;
  late List? historyList;
  late List? list;
  late SearchParame? parame;

  SearchStatus({
    this.load,
    this.historyList,
    this.list,
    this.parame,
  });
}

class SearchParame {
  late String value;
  late String? scope;

  SearchParame({
    this.value = "",
    this.scope
  });

  Map<String, dynamic> get toMap {
    return {
      "param": value,
      "scope": scope,
    };
  }
}
